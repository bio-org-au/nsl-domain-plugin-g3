-- fix up live patch of taxon view in production and apply across all the things.
-- From NSL-3453
DROP MATERIALIZED VIEW IF EXISTS taxon_view;

-- taxon-view uses this function
DROP FUNCTION IF EXISTS find_tree_rank(TEXT, INT);
-- this function is a little slow, but it works for now.
CREATE FUNCTION find_tree_rank(tve_id TEXT, rank_sort_order INT)
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
    SELECT tve.parent_id,
           n.name_element,
           r.name,
           r.sort_order
    FROM tree_version_element tve
             JOIN tree_element te ON tve.tree_element_id = te.id
             JOIN name n ON te.name_id = n.id
             JOIN name_rank r ON n.name_rank_id = r.id
    WHERE tve.element_link = tve_id
      AND r.sort_order >= rank_sort_order
    UNION ALL
    SELECT tve.parent_id,
           n.name_element,
           r.name,
           r.sort_order
    FROM walk w,
         tree_version_element tve
             JOIN tree_element te ON tve.tree_element_id = te.id
             JOIN name n ON te.name_id = n.id
             JOIN name_rank r ON n.name_rank_id = r.id
    WHERE tve.element_link = w.parent_id
      AND r.sort_order >= rank_sort_order
)
SELECT w.name_element,
       w.rank,
       w.sort_order
FROM walk w
WHERE w.sort_order = rank_sort_order
limit 1
$$;

CREATE MATERIALIZED VIEW taxon_view AS

    -- synonyms bit
(
SELECT (syn ->> 'host') || (syn ->> 'instance_link')                                                   AS "taxonID",
       syn_nt.name                                                                                     AS "nameType",
       tree.host_name || tve.taxon_link                                                                AS "acceptedNameUsageID",
       acc_name.full_name                                                                              AS "acceptedNameUsage",
       CASE
           WHEN acc_ns.name NOT IN ('legitimate', '[default]')
               THEN acc_ns.name
           ELSE NULL END                                                                               AS "nomenclaturalStatus",
       (syn ->> 'type')                                                                                AS "taxonomicStatus",
       (syn ->> 'type' ~ 'parte')                                                                      AS "proParte",
       syn_name.full_name                                                                              AS "scientificName",
       (syn ->> 'host') || (syn ->> 'name_link')                                                       AS "scientificNameID",
       syn_name.simple_name                                                                            AS "canonicalName",
       CASE
           WHEN syn_nt.autonym
               THEN NULL
           ELSE regexp_replace(substring(syn_name.full_name_html FROM '<authors>(.*)</authors>'), '<[^>]*>', '',
                               'g')
           END                                                                                         AS "scientificNameAuthorship",
       -- only in accepted names
       NULL                                                                                            AS "parentNameUsageID",
       syn_rank.name                                                                                   AS "taxonRank",
       syn_rank.sort_order                                                                             AS "taxonRankSortOrder",
       (SELECT name_element
        FROM find_tree_rank(tve.element_link, 10)
        ORDER BY sort_order ASC
        LIMIT 1)                                                                                       AS "kingdom",
       -- the below works but is a little slow
       -- find another efficient way to do it.
       (SELECT name_element FROM find_tree_rank(tve.element_link, 30) ORDER BY sort_order ASC LIMIT 1) AS "class",
       (SELECT name_element
        FROM find_tree_rank(tve.element_link, 40)
        ORDER BY sort_order ASC
        LIMIT 1)                                                                                       AS "subclass",
       (SELECT name_element FROM find_tree_rank(tve.element_link, 80) ORDER BY sort_order ASC LIMIT 1) AS "family",
       syn_name.created_at                                                                             AS "created",
       syn_name.updated_at                                                                             AS "modified",
       tree.name                                                                                       AS "datasetName",
       (syn ->> 'host') || (syn ->> 'concept_link')                                                    AS "taxonConceptID",
       (syn ->> 'cites')                                                                               AS "nameAccordingTo",
       (syn ->> 'host') || (syn ->> 'cites_link')                                                      AS "nameAccordingToID",
       profile -> (tree.config ->> 'comment_key') ->> 'value'                                          AS "taxonRemarks",
       profile -> (tree.config ->> 'distribution_key') ->> 'value'                                     AS "taxonDistribution",
       -- todo check this is ok for synonyms
       regexp_replace(tve.name_path, '/', '|', 'g')                                                    AS "higherClassification",
       CASE
           WHEN firstHybridParent.id IS NOT NULL
               THEN firstHybridParent.full_name
           ELSE NULL END                                                                               AS "firstHybridParentName",
       CASE
           WHEN firstHybridParent.id IS NOT NULL
               THEN tree.host_name || '/' || firstHybridParent.uri
           ELSE NULL END                                                                               AS "firstHybridParentNameID",
       CASE
           WHEN secondHybridParent.id IS NOT NULL
               THEN secondHybridParent.full_name
           ELSE NULL END                                                                               AS "secondHybridParentName",
       CASE
           WHEN secondHybridParent.id IS NOT NULL
               THEN tree.host_name || '/' || secondHybridParent.uri
           ELSE NULL END                                                                               AS "secondHybridParentNameID",
       -- boiler plate stuff at the end of the record
       (select coalesce((SELECT value FROM shard_config WHERE name = 'nomenclatural code'),
                        'ICN')) :: TEXT                                                                AS "nomenclaturalCode",
       'http://creativecommons.org/licenses/by/3.0/' :: TEXT                                           AS "license",
       (syn ->> 'host') || (syn ->> 'instance_link')                                                   AS "ccAttributionIRI"
FROM tree_version_element tve
         JOIN tree ON tve.tree_version_id = tree.current_tree_version_id AND tree.accepted_tree = TRUE
         JOIN tree_element te ON tve.tree_element_id = te.id
         JOIN instance acc_inst ON te.instance_id = acc_inst.id
         JOIN instance_type acc_it ON acc_inst.instance_type_id = acc_it.id
         JOIN reference acc_ref ON acc_inst.reference_id = acc_ref.id
         JOIN NAME acc_name ON te.name_id = acc_name.id
         JOIN name_type acc_nt ON acc_name.name_type_id = acc_nt.id
         JOIN name_status acc_ns ON acc_name.name_status_id = acc_ns.id,
     jsonb_array_elements(synonyms -> 'list') syn
         JOIN NAME syn_name ON syn_name.id = (syn ->> 'name_id') :: NUMERIC :: BIGINT
         JOIN name_rank syn_rank ON syn_name.name_rank_id = syn_rank.id
         JOIN name_type syn_nt ON syn_name.name_type_id = syn_nt.id
         LEFT OUTER JOIN NAME firstHybridParent ON syn_name.parent_id = firstHybridParent.id AND syn_nt.hybrid
         LEFT OUTER JOIN NAME secondHybridParent
                         ON syn_name.second_parent_id = secondHybridParent.id AND syn_nt.hybrid
UNION -- The accepted names bit
SELECT tree.host_name || tve.taxon_link                                                                AS "taxonID",
       acc_nt.name                                                                                     AS "nameType",
       tree.host_name || tve.taxon_link                                                                AS "acceptedNameUsageID",
       acc_name.full_name                                                                              AS "acceptedNameUsage",
       CASE
           WHEN acc_ns.name NOT IN ('legitimate', '[default]')
               THEN acc_ns.name
           ELSE NULL END                                                                               AS "nomenclaturalStatus",
       CASE
           WHEN te.excluded
               THEN 'excluded'
           ELSE 'accepted'
           END                                                                                         AS "taxonomicStatus",
       FALSE                                                                                           AS "proParte",
       acc_name.full_name                                                                              AS "scientificName",
       te.name_link                                                                                    AS "scientificNameID",
       acc_name.simple_name                                                                            AS "canonicalName",
       CASE
           WHEN acc_nt.autonym
               THEN NULL
           ELSE regexp_replace(substring(acc_name.full_name_html FROM '<authors>(.*)</authors>'), '<[^>]*>', '',
                               'g')
           END                                                                                         AS "scientificNameAuthorship",
       tree.host_name || tve.parent_id                                                                 AS "parentNameUsageID",
       te.rank                                                                                         AS "taxonRank",
       acc_rank.sort_order                                                                             AS "taxonRankSortOrder",
       (SELECT name_element
        FROM find_tree_rank(tve.element_link, 10)
        ORDER BY sort_order ASC
        LIMIT 1)                                                                                       AS "kingdom",
       -- the below works but is a little slow
       -- find another efficient way to do it.
       (SELECT name_element FROM find_tree_rank(tve.element_link, 30) ORDER BY sort_order ASC LIMIT 1) AS "class",
       (SELECT name_element
        FROM find_tree_rank(tve.element_link, 40)
        ORDER BY sort_order ASC
        LIMIT 1)                                                                                       AS "subclass",
       (SELECT name_element FROM find_tree_rank(tve.element_link, 80) ORDER BY sort_order ASC LIMIT 1) AS "family",
       acc_name.created_at                                                                             AS "created",
       acc_name.updated_at                                                                             AS "modified",
       tree.name                                                                                       AS "datasetName",
       te.instance_link                                                                                AS "taxonConceptID",
       acc_ref.citation                                                                                AS "nameAccordingTo",
       tree.host_name || '/reference/' || lower(name_space.value) || '/' ||
       acc_ref.id                                                                                      AS "nameAccordingToID",
       profile -> (tree.config ->> 'comment_key') ->> 'value'                                          AS "taxonRemarks",
       profile -> (tree.config ->> 'distribution_key') ->> 'value'                                     AS "taxonDistribution",
       -- todo check this is ok for synonyms
       regexp_replace(tve.name_path, '/', '|', 'g')                                                    AS "higherClassification",
       CASE
           WHEN firstHybridParent.id IS NOT NULL
               THEN firstHybridParent.full_name
           ELSE NULL END                                                                               AS "firstHybridParentName",
       CASE
           WHEN firstHybridParent.id IS NOT NULL
               THEN tree.host_name || '/' || firstHybridParent.uri
           ELSE NULL END                                                                               AS "firstHybridParentNameID",
       CASE
           WHEN secondHybridParent.id IS NOT NULL
               THEN secondHybridParent.full_name
           ELSE NULL END                                                                               AS "secondHybridParentName",
       CASE
           WHEN secondHybridParent.id IS NOT NULL
               THEN tree.host_name || '/' || secondHybridParent.uri
           ELSE NULL END                                                                               AS "secondHybridParentNameID",
       -- boiler plate stuff at the end of the record
       (select coalesce((SELECT value FROM shard_config WHERE name = 'nomenclatural code'),
                        'ICN')) :: TEXT                                                                AS "nomenclaturalCode",
       'http://creativecommons.org/licenses/by/3.0/' :: TEXT                                           AS "license",
       tree.host_name || tve.element_link                                                              AS "ccAttributionIRI"
FROM tree_version_element tve
         JOIN tree ON tve.tree_version_id = tree.current_tree_version_id AND tree.accepted_tree = TRUE
         JOIN tree_element te ON tve.tree_element_id = te.id
         JOIN instance acc_inst ON te.instance_id = acc_inst.id
         JOIN instance_type acc_it ON acc_inst.instance_type_id = acc_it.id
         JOIN reference acc_ref ON acc_inst.reference_id = acc_ref.id
         JOIN NAME acc_name ON te.name_id = acc_name.id
         JOIN name_type acc_nt ON acc_name.name_type_id = acc_nt.id
         JOIN name_status acc_ns ON acc_name.name_status_id = acc_ns.id
         JOIN name_rank acc_rank ON acc_name.name_rank_id = acc_rank.id
         LEFT OUTER JOIN NAME firstHybridParent ON acc_name.parent_id = firstHybridParent.id AND acc_nt.hybrid
         LEFT OUTER JOIN NAME secondHybridParent
                         ON acc_name.second_parent_id = secondHybridParent.id AND acc_nt.hybrid
         LEFT OUTER JOIN shard_config name_space on name_space.name = 'name space'
ORDER BY "higherClassification");

comment on materialized view taxon_view is 'The Taxon View provides a complete list of Names and their synonyms accepted by CHAH in Australia.';
comment on column taxon_view."taxonomicStatus" is 'Is this name accepted, excluded or a synonym of an accepted name.';
comment on column taxon_view."scientificName" is 'The full scientific name including authority.';
comment on column taxon_view."scientificNameID" is 'The identifying URI of the scientific name in this dataset.';
comment on column taxon_view."acceptedNameUsage" is 'The accepted name for this concept in this classification.';
comment on column taxon_view."acceptedNameUsageID" is 'The identifying URI of the accepted name concept.';
comment on column taxon_view."taxonID" is 'The identifying URI of the taxon concept used here. For an accepted name it identifies the taxon concept and what it encloses (subtaxa). For a synonym it identifies the relationship.';
comment on column taxon_view."nameType" is 'A categorisation of the name, e.g. scientific, hybrid, cultivar';
comment on column taxon_view."nomenclaturalStatus" is 'The nomencultural status of this name. http://rs.gbif.org/vocabulary/gbif/nomenclatural_status.xml';
comment on column taxon_view."proParte" is 'A flag that indicates this name is applied to this accepted name in part. If a name is ''pro parte'' then the name will have more than 1 accepted name.';
comment on column taxon_view."canonicalName" is 'The name without authorship.';
comment on column taxon_view."scientificNameAuthorship" is 'Authorship of the name.';
comment on column taxon_view."parentNameUsageID" is 'The identifying URI of the parent taxon for accepted names in the classification.';
comment on column taxon_view."taxonRank" is 'The taxonomic rank of the scientificName.';
comment on column taxon_view."taxonRankSortOrder" is 'A sort order that can be applied to the rank.';
comment on column taxon_view.kingdom is 'The canonical name of the kingdom based on this classification.';
comment on column taxon_view.class is 'The canonical name of the class based on this classification.';
comment on column taxon_view.subclass is 'The canonical name of the subclass based on this classification.';
comment on column taxon_view.family is 'The canonical name of the family based on this classification.';
comment on column taxon_view.created is 'Date the record for this concept was created. Format ISO:86 01';
comment on column taxon_view.modified is 'Date the record for this concept was modified. Format ISO:86 01';
comment on column taxon_view."datasetName" is 'Name of the taxonomy (tree) that contains this concept. e.g. APC, AusMoss';
comment on column taxon_view."taxonConceptID" is 'The identifying URI taxanomic concept this record refers to.';
comment on column taxon_view."nameAccordingTo" is 'The reference citation for this name.';
comment on column taxon_view."nameAccordingToID" is 'The identifying URI for the reference citation for this name.';
comment on column taxon_view."taxonRemarks" is 'Comments made specifically about this name in this classification.';
comment on column taxon_view."taxonDistribution" is 'The State or Territory distribution of the accepted name.';
comment on column taxon_view."higherClassification" is 'A list of names representing the branch down to (and including) this name separated by a "|".';
comment on column taxon_view."firstHybridParentName" is 'The scientificName for the first hybrid parent. For hybrids.';
comment on column taxon_view."firstHybridParentNameID" is 'The identifying URI the scientificName for the first hybrid parent.';
comment on column taxon_view."secondHybridParentName" is 'The scientificName for the second hybrid parent. For hybrids.';
comment on column taxon_view."secondHybridParentNameID" is 'The identifying URI the scientificName for the second hybrid parent.';
comment on column taxon_view."nomenclaturalCode" is 'The nomenclatural code under which this name is constructed.';
comment on column taxon_view.license is 'The license by which this data is being made available.';
comment on column taxon_view."ccAttributionIRI" is 'The attribution to be used when citing this concept.';

-- NSL-3555
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
WHERE w.sort_order >= rank_sort_order
order by w.sort_order asc
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

create materialized view name_view as
SELECT n.full_name                                                           AS "scientificName",
       n.full_name_html                                                      AS "scientificNameHTML",
       n.simple_name                                                         AS "canonicalName",
       n.simple_name_html                                                    AS "canonicalNameHTML",
       n.name_element                                                        AS "nameElement",
       ((mapper_host.value)::text || n.uri)                                  AS "scientificNameID",
       nt.name                                                               AS "nameType",
       (SELECT COALESCE((SELECT CASE
                                    WHEN (te.excluded = true) THEN 'excluded'::text
                                    ELSE 'accepted'::text
                                    END AS "case"
                         FROM ((tree_element te
                             JOIN tree_version_element tve ON ((te.id = tve.tree_element_id)))
                                  JOIN tree ON (((tve.tree_version_id = tree.current_tree_version_id) AND
                                                 (tree.accepted_tree = true))))
                         WHERE (te.name_id = n.id)), (SELECT 'included'::text AS text
                                                      WHERE (EXISTS(SELECT 1
                                                                    FROM tree_element te2
                                                                    WHERE (te2.synonyms @>
                                                                           ((SELECT (('{"list":[{"name_id":'::text || n.id) || ', "mis":false}]}'::text)))::jsonb)))),
                        'unplaced'::text) AS "coalesce")                     AS "taxonomicStatus",
       CASE
           WHEN ((ns.name)::text <> ALL
                 (ARRAY [('legitimate'::character varying)::text, ('[default]'::character varying)::text])) THEN ns.name
           ELSE NULL::character varying
           END                                                               AS "nomenclaturalStatus",
       CASE
           WHEN nt.autonym THEN NULL::text
           ELSE regexp_replace("substring"((n.full_name_html)::text, '<authors>(.*)</authors>'::text), '<[^>]*>'::text,
                               ''::text, 'g'::text)
           END                                                               AS "scientificNameAuthorship",
       CASE
           WHEN (nt.cultivar = true) THEN n.name_element
           ELSE NULL::character varying
           END                                                               AS "cultivarEpithet",
       nt.autonym,
       nt.hybrid,
       nt.cultivar,
       nt.formula,
       nt.scientific,
       ns.nom_inval                                                          AS "nomInval",
       ns.nom_illeg                                                          AS "nomIlleg",
       COALESCE(primary_ref.citation, 'unknown')                             AS "namePublishedIn",
       COALESCE(primary_ref.year, 0)                                         AS "namePublishedInYear",
       primary_it.name                                                       AS "nameInstanceType",
       basionym.full_name                                                    AS "originalNameUsage",
       CASE
           WHEN (basionym_inst.id IS NOT NULL) THEN ((mapper_host.value)::text || (SELECT instance.uri
                                                                                   FROM instance
                                                                                   WHERE (instance.id = basionym_inst.cites_id)))
           ELSE
               CASE
                   WHEN (primary_inst.id IS NOT NULL) THEN ((mapper_host.value)::text || primary_inst.uri)
                   ELSE NULL::text
                   END
           END                                                               AS "originalNameUsageID",
       CASE
           WHEN (nt.autonym = true) THEN (parent_name.full_name)::text
           ELSE (SELECT string_agg(regexp_replace((note.value)::text, '[

 ]+'::text, ' '::text, 'g'::text), ' '::text) AS string_agg
                 FROM (instance_note note
                          JOIN instance_note_key key1
                               ON (((key1.id = note.instance_note_key_id) AND ((key1.name)::text = 'Type'::text))))
                 WHERE (note.instance_id = COALESCE(basionym_inst.cites_id, primary_inst.id)))
           END                                                               AS "typeCitation",
       (SELECT find_rank.name_element
        FROM find_rank(n.id, 10) find_rank(name_element, rank, sort_order))  AS kingdom,
       family_name.name_element                                              AS family,
       (SELECT find_rank.name_element
        FROM find_rank(n.id, 120) find_rank(name_element, rank, sort_order)) AS "genericName",
       (SELECT find_rank.name_element
        FROM find_rank(n.id, 190) find_rank(name_element, rank, sort_order)) AS "specificEpithet",
       (SELECT find_rank.name_element
        FROM find_rank(n.id, 191) find_rank(name_element, rank, sort_order)) AS "infraspecificEpithet",
       rank.name                                                             AS "taxonRank",
       rank.sort_order                                                       AS "taxonRankSortOrder",
       rank.abbrev                                                           AS "taxonRankAbbreviation",
       first_hybrid_parent.full_name                                         AS "firstHybridParentName",
       ((mapper_host.value)::text || first_hybrid_parent.uri)                AS "firstHybridParentNameID",
       second_hybrid_parent.full_name                                        AS "secondHybridParentName",
       ((mapper_host.value)::text || second_hybrid_parent.uri)               AS "secondHybridParentNameID",
       n.created_at                                                          AS created,
       n.updated_at                                                          AS modified,
       ((SELECT COALESCE((SELECT shard_config.value
                          FROM shard_config
                          WHERE ((shard_config.name)::text = 'nomenclatural code'::text)),
                         'ICN'::character varying) AS "coalesce"))::text     AS "nomenclaturalCode",
       dataset.value                                                         AS "datasetName",
       'http://creativecommons.org/licenses/by/3.0/'::text                   AS license,
       ((mapper_host.value)::text || n.uri)                                  AS "ccAttributionIRI"
FROM (((((((((((name n
    JOIN name_type nt ON ((n.name_type_id = nt.id)))
    JOIN name_status ns ON ((n.name_status_id = ns.id)))
    JOIN name_rank rank ON ((n.name_rank_id = rank.id)))
    LEFT JOIN name parent_name ON ((n.parent_id = parent_name.id)))
    LEFT JOIN name family_name ON ((n.family_id = family_name.id)))
    LEFT JOIN name first_hybrid_parent ON (((n.parent_id = first_hybrid_parent.id) AND nt.hybrid)))
    LEFT JOIN name second_hybrid_parent ON (((n.second_parent_id = second_hybrid_parent.id) AND nt.hybrid)))
    LEFT JOIN ((instance primary_inst
        JOIN instance_type primary_it ON (((primary_it.id = primary_inst.instance_type_id) AND
                                           (primary_it.primary_instance = true))))
        JOIN reference primary_ref ON ((primary_inst.reference_id = primary_ref.id))) ON ((primary_inst.name_id = n.id)))
    LEFT JOIN ((instance basionym_inst
        JOIN instance_type "bit" ON ((("bit".id = basionym_inst.instance_type_id) AND
                                      (("bit".name)::text = 'basionym'::text))))
        JOIN name basionym ON ((basionym.id = basionym_inst.name_id))) ON ((basionym_inst.cited_by_id = primary_inst.id)))
    LEFT JOIN shard_config mapper_host ON (((mapper_host.name)::text = 'mapper host'::text)))
         LEFT JOIN shard_config dataset ON (((dataset.name)::text = 'name label'::text)))
WHERE (EXISTS(SELECT 1
              FROM instance
              WHERE (instance.name_id = n.id)))
ORDER BY n.sort_name;

GRANT SELECT ON taxon_view to ${webUserName};
GRANT SELECT ON name_view to ${webUserName};

-- NSL-3559 make sure reference parent can't be itself.
alter table if exists reference drop constraint if exists parent_not_self;
ALTER TABLE reference add constraint parent_not_self CHECK ( parent_id <> id );

-- version
UPDATE db_version
SET version = 37
WHERE id = 1;
