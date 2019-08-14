-- re-create name view NSL-3350 NSL-3352
drop materialized view if exists name_view;
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

-- version
UPDATE db_version
SET version = 35
WHERE id = 1;
