DROP MATERIALIZED VIEW IF EXISTS name_view;

-- --- name-view uses these functions
DROP FUNCTION IF EXISTS find_rank(BIGINT, INT);
CREATE FUNCTION find_rank(name_id BIGINT, rank_sort_order INT)
  RETURNS TABLE
          (
            name_element TEXT,
            rank         TEXT,
            sort_order   INT
          )
  LANGUAGE SQL
AS
$$
WITH RECURSIVE walk (parent_id, name_element, rank, sort_order) AS (
  SELECT parent_id,
         n.name_element,
         r.name,
         r.sort_order
  FROM name n
         JOIN name_rank r ON n.name_rank_id = r.id
  WHERE n.id = name_id
    AND r.sort_order >= rank_sort_order
  UNION ALL
  SELECT n.parent_id,
         n.name_element,
         r.name,
         r.sort_order
  FROM walk w,
       name n
         JOIN name_rank r ON n.name_rank_id = r.id
  WHERE n.id = w.parent_id
    AND r.sort_order >= rank_sort_order
)
SELECT w.name_element,
       w.rank,
       w.sort_order
FROM walk w
WHERE w.sort_order = rank_sort_order
limit 1
$$;

drop function if exists inc_status(nameId bigint);
CREATE function inc_status(nameId bigint)
  returns text
  language sql
as
$$
select 'included' :: text
where exists(select 1
             from tree_element te2
             where synonyms @> (select '{"list":[{"name_id":' || nameId || ', "mis":false}]}') :: JSONB)
$$;

drop function if exists excluded_status(nameId bigint);
CREATE function excluded_status(nameId bigint)
  returns text
  language sql
as
$$
select case when te.excluded = true then 'excluded' else 'accepted' end
from tree_element te
       JOIN tree_version_element tve ON te.id = tve.tree_element_id
       JOIN tree ON tve.tree_version_id = tree.current_tree_version_id AND tree.accepted_tree = TRUE
where te.name_id = nameId
$$;

drop function if exists accepted_status(nameId BIGINT);
CREATE FUNCTION accepted_status(nameId BIGINT)
  RETURNS TEXT
  LANGUAGE SQL
AS
$$
select coalesce(excluded_status(nameId), inc_status(nameId), 'unplaced');
$$;

CREATE MATERIALIZED VIEW name_view AS
SELECT n.full_name                                           AS "scientificName",
       n.full_name_html                                      AS "scientificNameHTML",
       n.simple_name                                         AS "canonicalName",
       n.simple_name_html                                    AS "canonicalNameHTML",
       n.name_element                                        AS "nameElement",
       mapper_host.value || n.uri                            AS "scientificNameID",

       nt.name                                               AS "nameType",
       accepted_status(n.id)                                AS "taxonomicStatus",

       CASE
         WHEN ns.name NOT IN ('legitimate', '[default]')
           THEN ns.name
         ELSE NULL END                                       AS "nomenclaturalStatus",

       CASE
         WHEN nt.autonym
           THEN NULL
         ELSE
           regexp_replace(substring(n.full_name_html FROM '<authors>(.*)</authors>'), '<[^>]*>', '', 'g')
         END                                                 AS "scientificNameAuthorship",

       CASE
         WHEN nt.cultivar = TRUE
           THEN n.name_element
         ELSE NULL END                                       AS "cultivarEpithet",

       nt.autonym                                            AS "autonym",
       nt.hybrid                                             AS "hybrid",
       nt.cultivar                                           AS "cultivar",
       nt.formula                                            AS "formula",
       nt.scientific                                         AS "scientific",
       ns.nom_inval                                          AS "nomInval",
       ns.nom_illeg                                          AS "nomIlleg",
       coalesce(primary_ref.citation,
                (SELECT r.citation
                 FROM instance s
                        JOIN instance_type it ON s.instance_type_id = it.id AND it.secondary_instance
                        JOIN reference r ON s.reference_id = r.id
                 ORDER BY r.year ASC
                 LIMIT 1
                ))                                           AS "namePublishedIn",
       coalesce(primary_ref.year,
                (SELECT r.year
                 FROM instance s
                        JOIN instance_type it ON s.instance_type_id = it.id AND it.secondary_instance
                        JOIN reference r ON s.reference_id = r.id
                 ORDER BY r.year ASC
                 LIMIT 1
                ))                                           AS "namePublishedInYear",
       primary_it.name                                       AS "nameInstanceType",
       basionym.full_name                                    AS "originalNameUsage",
       CASE
         WHEN basionym_inst.id IS NOT NULL
           THEN mapper_host.value || (select uri from instance where id = basionym_inst.cites_id) :: TEXT
         ELSE
           CASE
             WHEN primary_inst.id IS NOT NULL
               THEN mapper_host.value || primary_inst.uri :: TEXT
             ELSE NULL END
         END                                                 AS "originalNameUsageID",

       CASE
         WHEN nt.autonym = TRUE
           THEN parent_name.full_name
         ELSE
           (SELECT string_agg(regexp_replace(VALUE, E'[\n\r\u2028]+', ' ', 'g'), ' ')
            FROM instance_note note
                   JOIN instance_note_key key1
                        ON key1.id = note.instance_note_key_id
                          AND key1.name = 'Type'
            WHERE note.instance_id = coalesce(basionym_inst.cites_id, primary_inst.id))
         END                                                 AS "typeCitation",

       (SELECT name_element FROM find_rank(n.id, 10))        AS "kingdom",
       family_name.name_element                              AS "family",
       (SELECT name_element FROM find_rank(n.id, 120))       AS "genericName",
       (SELECT name_element FROM find_rank(n.id, 190))       AS "specificEpithet",
       (SELECT name_element FROM find_rank(n.id, 191))       AS "infraspecificEpithet",

       rank.name                                             AS "taxonRank",
       rank.sort_order                                       AS "taxonRankSortOrder",
       rank.abbrev                                           AS "taxonRankAbbreviation",

       first_hybrid_parent.full_name                         AS "firstHybridParentName",
       mapper_host.value || first_hybrid_parent.uri          AS "firstHybridParentNameID",
       second_hybrid_parent.full_name                        AS "secondHybridParentName",
       mapper_host.value || second_hybrid_parent.uri         AS "secondHybridParentNameID",

       n.created_at                                          AS "created",
       n.updated_at                                          AS "modified",
       -- boiler plate
       (select coalesce((SELECT value FROM shard_config WHERE name = 'nomenclatural code'),
                        'ICN')) :: TEXT                      AS "nomenclaturalCode",
       dataset.value                                         AS "datasetName",
       'http://creativecommons.org/licenses/by/3.0/' :: TEXT AS "license",
       mapper_host.value || n.uri                            AS "ccAttributionIRI"

FROM name n
       JOIN name_type nt ON n.name_type_id = nt.id
       JOIN name_status ns ON n.name_status_id = ns.id
       JOIN name_rank rank ON n.name_rank_id = rank.id

       LEFT OUTER JOIN name parent_name ON n.parent_id = parent_name.id
       LEFT OUTER JOIN name family_name ON n.family_id = family_name.id

       LEFT OUTER JOIN NAME first_hybrid_parent ON n.parent_id = first_hybrid_parent.id AND nt.hybrid
       LEFT OUTER JOIN NAME second_hybrid_parent ON n.second_parent_id = second_hybrid_parent.id AND nt.hybrid

       LEFT OUTER JOIN INSTANCE primary_inst
       JOIN instance_type primary_it
            ON primary_it.id = primary_inst.instance_type_id AND primary_it.primary_instance = TRUE
       JOIN REFERENCE primary_ref ON primary_inst.reference_id = primary_ref.id
            ON primary_inst.name_id = n.id

       LEFT OUTER JOIN INSTANCE basionym_inst
       JOIN instance_type bit ON bit.id = basionym_inst.instance_type_id AND bit.name = 'basionym'
       JOIN NAME basionym ON basionym.id = basionym_inst.name_id
            ON basionym_inst.cited_by_id = primary_inst.id
       LEFT OUTER JOIN shard_config mapper_host on mapper_host.name = 'mapper host'
       LEFT OUTER JOIN shard_config dataset on dataset.name = 'name label'
WHERE exists(SELECT 1
             FROM instance
             WHERE name_id = n.id)
ORDER BY n.sort_name;