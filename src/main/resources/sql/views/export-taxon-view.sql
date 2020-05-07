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