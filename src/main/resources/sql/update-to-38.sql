/* taxon_view.sql */

/* materialized view to export shard taxonomy using the instance graph */
/* ghw 20210525 : fix parent link*/
/* ghw 20210531 : afd scientificNameAuthorship  needs bypass pending services ICZN name constructor*/
/* - (no tree_element cache) */

drop materialized view if exists taxon_view;
create materialized view taxon_view
            ("taxonID", "nameType", "acceptedNameUsageID", "acceptedNameUsage", "nomenclaturalStatus",
             "taxonomicStatus", "proParte", "scientificName", "scientificNameID", "canonicalName",
             "scientificNameAuthorship", "parentNameUsageID", "taxonRank", "taxonRankSortOrder", kingdom,
             class, subclass, family, created, modified, "datasetName", "taxonConceptID", "nameAccordingTo",
             "nameAccordingToID", "taxonRemarks", "taxonDistribution", "higherClassification",
             "firstHybridParentName", "firstHybridParentNameID", "secondHybridParentName",
             "secondHybridParentNameID", "nomenclaturalCode", license, "ccAttributionIRI")
AS
SELECT (tree.host_name || '/' || syn_inst.uri)                           AS "taxonID",
       syn_nt.name                                                       AS "nameType",
       (tree.host_name || tve.taxon_link)                                AS "acceptedNameUsageID",
       acc_name.full_name                                                AS "acceptedNameUsage",
       CASE
           WHEN syn_ns.name not in ('legitimate', '[default]') THEN syn_ns.name
           END                                                           AS "nomenclaturalStatus",
       syn_it.name                                                       AS "taxonomicStatus",
       syn_it.pro_parte                                                  AS "proParte",
       syn_name.full_name                                                AS "scientificName",
       (tree.host_name || '/' || syn_name.uri)                           AS "scientificNameID",
       syn_name.simple_name                                              AS "canonicalName",
       CASE
           WHEN ng.rdf_id = 'zoological' THEN (select abbrev from author where id = syn_name.author_id)
           WHEN syn_nt.autonym THEN NULL::text
           ELSE regexp_replace(
                   "substring"((syn_name.full_name_html)::text, '<authors>(.*)</authors>'::text),
                   '<[^>]*>'::text, ''::text, 'g'::text)
           END                                                           AS "scientificNameAuthorship",
       NULL::text                                                        AS "parentNameUsageID",
       syn_rank.name                                                     AS "taxonRank",
       syn_rank.sort_order                                               AS "taxonRankSortOrder",
       (SELECT find_tree_rank.name_element
        FROM find_tree_rank(tve.element_link, (select sort_order from name_rank where rdf_id ~ '(regnum|kingdom)')) find_tree_rank(name_element, rank, sort_order)
        ORDER BY find_tree_rank.sort_order
        LIMIT 1)                                                         AS kingdom,
       (SELECT find_tree_rank.name_element
        FROM find_tree_rank(tve.element_link, (select sort_order from name_rank where rdf_id ~ '^class')) find_tree_rank(name_element, rank, sort_order)
        ORDER BY find_tree_rank.sort_order
        LIMIT 1)                                                         AS class,
       (SELECT find_tree_rank.name_element
        FROM find_tree_rank(tve.element_link, (select sort_order from name_rank where rdf_id = '^subclass')) find_tree_rank(name_element, rank, sort_order)
        ORDER BY find_tree_rank.sort_order
        LIMIT 1)                                                         AS subclass,
       (SELECT find_tree_rank.name_element
        FROM find_tree_rank(tve.element_link, (select sort_order from name_rank where rdf_id = '(^familia|^family)')) find_tree_rank(name_element, rank, sort_order)
        ORDER BY find_tree_rank.sort_order
        LIMIT 1)                                                         AS family,
       syn_name.created_at                                               AS created,
       syn_name.updated_at                                               AS modified,
       tree.name                                                         AS "datasetName",
       (tree.host_name || '/' || syn_inst.uri)                           AS "taxonConceptID",
       syn_ref.citation                                                  AS "nameAccordingTo",
       ((((tree.host_name || '/reference/'::text) || lower((name_space.value)::text)) || '/'::text) ||
        syn_ref.id)                                                      AS "nameAccordingToID",

       NULL::text                                                        AS "taxonRemarks",
       NULL::text                                                        AS "taxonDistribution",
       regexp_replace(tve.name_path, '/'::text, '|'::text, 'g'::text)    AS "higherClassification",
       CASE
           WHEN (firsthybridparent.id IS NOT NULL) THEN firsthybridparent.full_name
           ELSE NULL::character varying
           END                                                           AS "firstHybridParentName",
       CASE
           WHEN (firsthybridparent.id IS NOT NULL)
               THEN ((tree.host_name || '/'::text) || firsthybridparent.uri)
           ELSE NULL::text
           END                                                           AS "firstHybridParentNameID",
       CASE
           WHEN (secondhybridparent.id IS NOT NULL) THEN secondhybridparent.full_name
           ELSE NULL::character varying
           END                                                           AS "secondHybridParentName",
       CASE
           WHEN (secondhybridparent.id IS NOT NULL)
               THEN ((tree.host_name || '/'::text) || secondhybridparent.uri)
           ELSE NULL::text
           END                                                           AS "secondHybridParentNameID",
       ((SELECT COALESCE((SELECT shard_config.value
                          FROM shard_config
                          WHERE ((shard_config.name)::text = 'nomenclatural code'::text)),
                         'ICN'::character varying) AS "coalesce"))::text AS "nomenclaturalCode",
       'http://creativecommons.org/licenses/by/3.0/'::text               AS license,
       (tree.host_name || '/' || syn_inst.uri)                           AS "ccAttributionIRI"
FROM tree_version_element tve
         JOIN tree ON (tve.tree_version_id = tree.current_tree_version_id AND
                       tree.accepted_tree = true)
         JOIN tree_element te ON tve.tree_element_id = te.id
         JOIN instance acc_inst ON te.instance_id = acc_inst.id
         JOIN name acc_name ON te.name_id = acc_name.id
         JOIN instance syn_inst on ( te.instance_id = syn_inst.cited_by_id and syn_inst.name_id != acc_name.id )
         JOIN reference syn_ref on syn_inst.reference_id = syn_ref.id
         JOIN instance_type syn_it on syn_inst.instance_type_id = syn_it.id
         JOIN name syn_name on syn_inst.name_id = syn_name.id
         JOIN name_rank syn_rank on syn_name.name_rank_id = syn_rank.id
         JOIN name_type syn_nt on syn_name.name_type_id = syn_nt.id
         join name_group ng on syn_nt.name_group_id = ng.id
         JOIN name_status syn_ns on syn_name.name_status_id = syn_ns.id
         LEFT JOIN name firsthybridparent
                   ON (syn_name.parent_id = firsthybridparent.id AND syn_nt.hybrid)
         LEFT JOIN name secondhybridparent
                   ON (syn_name.second_parent_id = secondhybridparent.id AND syn_nt.hybrid)
         LEFT JOIN shard_config name_space ON name_space.name::text = 'name space'::text
UNION
SELECT (tree.host_name || tve.taxon_link)                                AS "taxonID",
       acc_nt.name                                                       AS "nameType",
       (tree.host_name || tve.taxon_link)                                AS "acceptedNameUsageID",
       acc_name.full_name                                                AS "acceptedNameUsage",
       CASE
           WHEN ((acc_ns.name)::text <> ALL
                 (ARRAY [('legitimate'::character varying)::text, ('[default]'::character varying)::text]))
               THEN acc_ns.name
           ELSE NULL::character varying
           END                                                           AS "nomenclaturalStatus",
       CASE
           WHEN te.excluded THEN 'excluded'::text
           ELSE 'accepted'::text
           END                                                           AS "taxonomicStatus",
       false                                                             AS "proParte",
       acc_name.full_name                                                AS "scientificName",
       (tree.host_name || '/') || acc_name.uri                     AS "scientificNameID",
       acc_name.simple_name                                              AS "canonicalName",
       CASE
           WHEN ng.rdf_id = 'zoological' THEN (select abbrev from author where id = acc_name.author_id)
           WHEN acc_nt.autonym THEN NULL::text
           ELSE regexp_replace(
                   "substring"((acc_name.full_name_html)::text, '<authors>(.*)</authors>'::text),
                   '<[^>]*>'::text, ''::text, 'g'::text)
           END                                                           AS "scientificNameAuthorship",
       nullif((tree.host_name || pve.taxon_link), tree.host_name)        AS "parentNameUsageID",
       te.rank                                                           AS "taxonRank",
       acc_rank.sort_order                                               AS "taxonRankSortOrder",
       (SELECT find_tree_rank.name_element
        FROM find_tree_rank(tve.element_link, (select sort_order from name_rank where rdf_id ~ '(regnum|kingdom)')) find_tree_rank(name_element, rank, sort_order)
        ORDER BY find_tree_rank.sort_order
        LIMIT 1)                                                         AS kingdom,
       (SELECT find_tree_rank.name_element
        FROM find_tree_rank(tve.element_link, (select sort_order from name_rank where rdf_id ~ '^class')) find_tree_rank(name_element, rank, sort_order)
        ORDER BY find_tree_rank.sort_order
        LIMIT 1)                                                         AS class,
       (SELECT find_tree_rank.name_element
        FROM find_tree_rank(tve.element_link, (select sort_order from name_rank where rdf_id ~ '^subclass')) find_tree_rank(name_element, rank, sort_order)
        ORDER BY find_tree_rank.sort_order
        LIMIT 1)                                                         AS subclass,
       (SELECT find_tree_rank.name_element
        FROM find_tree_rank(tve.element_link, (select sort_order from name_rank where rdf_id ~ '(^family|^familia)')) find_tree_rank(name_element, rank, sort_order)
        ORDER BY find_tree_rank.sort_order
        LIMIT 1)                                                         AS family,
       acc_name.created_at                                               AS created,
       acc_name.updated_at                                               AS modified,
       tree.name                                                         AS "datasetName",
       te.instance_link                                                  AS "taxonConceptID",
       acc_ref.citation                                                  AS "nameAccordingTo",
       ((((tree.host_name || '/reference/'::text) || lower((name_space.value)::text)) || '/'::text) ||
        acc_ref.id)                                                      AS "nameAccordingToID",
       ((te.profile -> (tree.config ->> 'comment_key'::text)) ->>
        'value'::text)                                                   AS "taxonRemarks",
       ((te.profile -> (tree.config ->> 'distribution_key'::text)) ->>
        'value'::text)                                                   AS "taxonDistribution",
       regexp_replace(tve.name_path, '/'::text, '|'::text, 'g'::text)    AS "higherClassification",
       CASE
           WHEN (firsthybridparent.id IS NOT NULL) THEN firsthybridparent.full_name
           ELSE NULL::character varying
           END                                                           AS "firstHybridParentName",
       CASE
           WHEN (firsthybridparent.id IS NOT NULL)
               THEN ((tree.host_name || '/'::text) || firsthybridparent.uri)
           ELSE NULL::text
           END                                                           AS "firstHybridParentNameID",
       CASE
           WHEN (secondhybridparent.id IS NOT NULL) THEN secondhybridparent.full_name
           ELSE NULL::character varying
           END                                                           AS "secondHybridParentName",
       CASE
           WHEN (secondhybridparent.id IS NOT NULL)
               THEN ((tree.host_name || '/'::text) || secondhybridparent.uri)
           ELSE NULL::text
           END                                                           AS "secondHybridParentNameID",
       ((SELECT COALESCE((SELECT shard_config.value
                          FROM shard_config
                          WHERE ((shard_config.name)::text = 'nomenclatural code'::text)),
                         'ICN'::character varying) AS "coalesce"))::text AS "nomenclaturalCode",
       'http://creativecommons.org/licenses/by/3.0/'::text               AS license,
       (tree.host_name || tve.taxon_link)                                AS "ccAttributionIRI"
FROM tree_version_element tve
         JOIN tree ON (tve.tree_version_id = tree.current_tree_version_id AND
                       tree.accepted_tree = true)
         JOIN tree_element te ON tve.tree_element_id = te.id
         JOIN instance acc_inst ON te.instance_id = acc_inst.id
         JOIN instance_type acc_it ON acc_inst.instance_type_id = acc_it.id
         JOIN reference acc_ref ON acc_inst.reference_id = acc_ref.id
         JOIN name acc_name ON te.name_id = acc_name.id
         JOIN name_type acc_nt ON acc_name.name_type_id = acc_nt.id
         join name_group ng on acc_nt.name_group_id = ng.id
         JOIN name_status acc_ns ON acc_name.name_status_id = acc_ns.id
         JOIN name_rank acc_rank ON acc_name.name_rank_id = acc_rank.id
         LEFT JOIN tree_version_element pve on pve.element_link = tve.parent_id
         LEFT JOIN name firsthybridparent ON (acc_name.parent_id = firsthybridparent.id AND acc_nt.hybrid)
         LEFT JOIN name secondhybridparent ON (acc_name.second_parent_id = secondhybridparent.id AND acc_nt.hybrid)
         LEFT JOIN shard_config name_space ON name_space.name::text = 'name space'::text
ORDER BY 27;

comment on materialized view taxon_view is 'The Taxon View provides a listing of the "accepted" classification for the sharda as Darwin Core taxon records (almost): All taxa and their synonyms.';
comment on column taxon_view."taxonID" is 'The record identifier (URI): The node ID from the "accepted" classification for the taxon concept; the Taxon_Name_Usage (relationship instance) for a synonym. For higher taxa it uniquely identifiers the subtended branch.';
comment on column taxon_view."nameType" is 'A categorisation of the name, e.g. scientific, hybrid, cultivar';
comment on column taxon_view."acceptedNameUsageID" is 'For a synonym, the "taxon_id" in this listing of the accepted concept. Self, for a taxon_record';
comment on column taxon_view."acceptedNameUsage" is 'For a synonym, the accepted taxon name in this classification.';
comment on column taxon_view."nomenclaturalStatus" is 'The nomencultural status of this name. http://rs.gbif.org/vocabulary/gbif/nomenclatural_status.xml';
comment on column taxon_view."taxonomicStatus" is 'Is this record accepted, excluded or a synonym of an accepted name.';
comment on column taxon_view."proParte" is 'A flag on a synonym for a partial taxonomic relationship with the accepted taxon';
comment on column taxon_view."scientificName" is 'The full scientific name including authority.';
comment on column taxon_view."scientificNameID" is 'The identifier (URI) for the scientific name in this shard.';
comment on column taxon_view."canonicalName" is 'The name without authorship.';
comment on column taxon_view."scientificNameAuthorship" is 'Authorship of the name.';
comment on column taxon_view."parentNameUsageID" is 'The identifier ( a URI) in this listing for the parent taxon in the classification.';
comment on column taxon_view."taxonRank" is 'The taxonomic rank of the scientificName.';
comment on column taxon_view."taxonRankSortOrder" is 'A sort order that can be applied to the rank.';
comment on column taxon_view.kingdom is 'The canonical name of the kingdom in this branch of the classification.';
comment on column taxon_view.class is 'The canonical name of the class in this branch of the classification.';
comment on column taxon_view.subclass is 'The canonical name of the subclass in this branch of the classification.';
comment on column taxon_view.family is 'The canonical name of the family in this branch of the classification.';
comment on column taxon_view.created is 'Date the record for this concept was created. Format ISO:86 01';
comment on column taxon_view.modified is 'Date the record for this concept was modified. Format ISO:86 01';
comment on column taxon_view."datasetName" is 'the Name for this ibranch of the classification  (tree). e.g. APC, AusMoss';
comment on column taxon_view."taxonConceptID" is 'The URI for the congruent "published" concept cited by this record.';
comment on column taxon_view."nameAccordingTo" is 'The reference citation for the congruent concept.';
comment on column taxon_view."nameAccordingToID" is 'The identifier (URI) for the reference citation for the congriuent concept.';
comment on column taxon_view."taxonRemarks" is 'Comments made specifically about this taxon in this classification.';
comment on column taxon_view."taxonDistribution" is 'The State or Territory distribution of the taxon.';
comment on column taxon_view."higherClassification" is 'The taxon hierarchy, down to (and including) this taxon, as a list of names separated by a "|".';
comment on column taxon_view."firstHybridParentName" is 'The scientificName for the first hybrid parent. For hybrids.';
comment on column taxon_view."firstHybridParentNameID" is 'The identifier (URI) the scientificName for the first hybrid parent.';
comment on column taxon_view."secondHybridParentName" is 'The scientificName for the second hybrid parent. For hybrids.';
comment on column taxon_view."secondHybridParentNameID" is 'The identifier (URI) the scientificName for the second hybrid parent.';
comment on column taxon_view."nomenclaturalCode" is 'The nomenclatural code governing this classification.';
comment on column taxon_view.license is 'The license by which this data is being made available.';
comment on column taxon_view."ccAttributionIRI" is 'The attribution to be used when citing this concept.';

/* name_view.sql */
drop materialized view if exists name_view;
create materialized view name_view
            (name_id,
             "scientificName", "scientificNameHTML", "canonicalName", "canonicalNameHTML", "nameElement",
             "scientificNameID", "nameType",
             "taxonomicStatus", "nomenclaturalStatus", "scientificNameAuthorship", "cultivarEpithet", autonym, hybrid,
             cultivar, formula,
             scientific, "nomInval", "nomIlleg", "namePublishedIn", "namePublishedInID","namePublishedInYear", "nameInstanceType",
             "nameAccordingToID", "nameAccordingTo", "originalNameUsage", "originalNameUsageID",
             "originalNameUsageYear",
             "typeCitation", kingdom, family, "genericName", "specificEpithet", "infraspecificEpithet", "taxonRank",
             "taxonRankSortOrder", "taxonRankAbbreviation", "firstHybridParentName", "firstHybridParentNameID",
             "secondHybridParentName",
             "secondHybridParentNameID", created, modified, "nomenclaturalCode", "datasetName", license,
             "ccAttributionIRI"
                )
AS
SELECT distinct on (n.id) n.id                                                                                      AS "nsl:name_id",
                          n.full_name                                                                               AS "scientificName",
                          n.full_name_html                                                                          AS "scientificNameHTML",
                          n.simple_name                                                                             AS "canonicalName",
                          n.simple_name_html                                                                        AS "canonicalNameHTML",
                          n.name_element                                                                            AS "nameElement",
                          ((mapper_host.value)::text || n.uri)                                                      AS "scientificNameID",
                          nt.name                                                                                   AS "nameType",

                          CASE
                              WHEN t.accepted_tree THEN
                                  CASE
                                      WHEN te.excluded THEN 'excluded'::text
                                      ELSE 'accepted'::text
                                      END
                              WHEN t2.accepted_tree THEN
                                  CASE
                                      WHEN te2.excluded THEN 'excluded'::text
                                      ELSE 'included'::text
                                      END
                              ELSE
                                  'unplaced'::text
                              END                                                                                   AS "taxonomicStatus",


                          CASE
                              WHEN ns.name !~ '(^legitimate$|^\[default\]$)' THEN ns.name
                              ELSE NULL::character varying
                              END                                                                                   AS "nomenclaturalStatus",
                          CASE
                              WHEN nt.autonym THEN NULL::text
                              ELSE regexp_replace(
                                      "substring"((n.full_name_html)::text, '<authors>(.*)</authors>'::text),
                                      '<[^>]*>'::text,
                                      ''::text, 'g'::text)
                              END                                                                                   AS "scientificNameAuthorship",
                          CASE
                              WHEN (nt.cultivar = true) THEN n.name_element
                              ELSE NULL::character varying
                              END                                                                                   AS "cultivarEpithet",
                          nt.autonym,
                          nt.hybrid,
                          nt.cultivar,
                          nt.formula,
                          nt.scientific,
                          ns.nom_inval                                                                              AS "nomInval",
                          ns.nom_illeg                                                                              AS "nomIlleg",
                          COALESCE(primary_ref.citation, 'unknown'::character varying)                              AS "namePublishedIn",
                          primary_ref.id                                                                            AS "namePublishedInID",
                          COALESCE(substr(primary_ref.iso_publication_date, 1, 4),
                                   primary_ref.year::text)::INTEGER                                                 AS "namePublishedInYear",
                          primary_it.name                                                                           AS "nameInstanceType",
                          mapper_host.value || primary_inst.uri::text                                               AS "nameAccordingtoID",
                          primary_auth.name || CASE
                                                   WHEN coalesce(primary_ref.iso_publication_date, primary_ref.year::text) is not null
                                                       THEN
                                                               ' (' ||
                                                               coalesce(primary_ref.iso_publication_date, primary_ref.year::text) ||
                                                               ')'
                              END                                                    AS "nameAccordingto",
                          basionym.full_name                                                                        AS "originalNameUsage",
                          CASE
                              WHEN basionym_inst.id IS NOT NULL
                                  THEN mapper_host.value || basionym_inst.id::text
                              END                                                                         AS "originalNameUsageID",
                          COALESCE(substr(basionym_ref.iso_publication_date, 1, 4), basionym_ref.year::text)
                                                                                                                    AS "originalNameUsageYear",
                          CASE
                              WHEN nt.autonym = true THEN parent_name.full_name
                              ELSE (SELECT string_agg(regexp_replace((key1.rdf_id || ': ' || note.value)::text,
                                                                     '[\r\n]+'::text, ' '::text, 'g'::text),
                                                      '; '::text) AS string_agg
                                    FROM instance_note note
                                             JOIN instance_note_key key1
                                                  ON key1.id = note.instance_note_key_id AND
                                                     key1.rdf_id ~* 'type$'
                                    WHERE note.instance_id in (primary_inst.id, basionym_inst.cites_id)
                              )
                              END                                                                                   AS "typeCitation",

                          COALESCE((SELECT find_tree_rank.name_element
                                    FROM find_tree_rank(coalesce(tve.element_link, tve2.element_link), (select sort_order from name_rank where rdf_id ~ '(regnum|kingdom)')) find_tree_rank(name_element, rank, sort_order)),
                                   CASE
                                       WHEN code.value = 'ICN' THEN 'Plantae'
                                       END)                                                               AS kingdom,


                          COALESCE((SELECT find_tree_rank.name_element
                                    FROM find_tree_rank(coalesce(tve.element_link, tve2.element_link), (select sort_order from name_rank where rdf_id ~ '(^family|^familia)')) find_tree_rank(name_element, rank, sort_order)),
                                   family_name.name_element)                                                        AS family,

                          (SELECT find_rank.name_element
                           FROM find_rank(n.id, (select sort_order from name_rank where rdf_id = 'genus')) find_rank(name_element, rank, sort_order))                     AS "genericName",
                          (SELECT find_rank.name_element
                           FROM find_rank(n.id, (select sort_order from name_rank where rdf_id = 'species')) find_rank(name_element, rank, sort_order))                     AS "specificEpithet",
                          (SELECT find_rank.name_element
                           FROM find_rank(n.id, (select sort_order from name_rank where rdf_id = 'subspecies')) find_rank(name_element, rank, sort_order))                     AS "infraspecificEpithet",
                          rank.name                                                                                 AS "taxonRank",
                          rank.sort_order                                                                           AS "taxonRankSortOrder",
                          rank.abbrev                                                                               AS "taxonRankAbbreviation",
                          first_hybrid_parent.full_name                                                             AS "firstHybridParentName",
                          ((mapper_host.value)::text || first_hybrid_parent.uri)                                    AS "firstHybridParentNameID",
                          second_hybrid_parent.full_name                                                            AS "secondHybridParentName",
                          ((mapper_host.value)::text || second_hybrid_parent.uri)                                   AS "secondHybridParentNameID",
                          n.created_at                                                                              AS created,
                          n.updated_at                                                                              AS modified,
                          COALESCE(code.value, 'ICN'::character varying)::text                                      AS "nomenclaturalCode",
                          dataset.value                                                                             AS "datasetName",
                          'http://creativecommons.org/licenses/by/3.0/'::text                                       AS license,
                          ((mapper_host.value)::text || n.uri)                                                      AS "ccAttributionIRI"
FROM name n
         JOIN name_type nt ON n.name_type_id = nt.id
         JOIN name_status ns ON n.name_status_id = ns.id
         JOIN name_rank rank ON n.name_rank_id = rank.id
         LEFT JOIN name parent_name ON n.parent_id = parent_name.id
         LEFT JOIN name family_name ON n.family_id = family_name.id
         LEFT JOIN name first_hybrid_parent
                   ON n.parent_id = first_hybrid_parent.id AND nt.hybrid
         LEFT JOIN name second_hybrid_parent
                   ON n.second_parent_id = second_hybrid_parent.id AND nt.hybrid
         LEFT JOIN instance primary_inst
         JOIN instance_type primary_it ON primary_it.id = primary_inst.instance_type_id AND primary_it.primary_instance
         JOIN reference primary_ref ON primary_inst.reference_id = primary_ref.id
         Join author primary_auth ON primary_ref.author_id = primary_auth.id
         LEFT JOIN instance basionym_rel
         JOIN instance_type bt ON bt.id = basionym_rel.instance_type_id AND bt.rdf_id = 'basionym'
         JOIN instance basionym_inst on basionym_rel.cites_id = basionym_inst.id
         JOIN reference basionym_ref ON basionym_inst.reference_id = basionym_ref.id
         JOIN name basionym ON basionym.id = basionym_inst.name_id
              ON basionym_rel.cited_by_id = primary_inst.id
              ON primary_inst.name_id = n.id
         LEFT JOIN shard_config mapper_host ON mapper_host.name::text = 'mapper host'::text
         LEFT JOIN shard_config dataset ON dataset.name::text = 'name label'::text
         LEFT JOIN shard_config code ON code.name::text = 'nomenclatural code'::text
         LEFT JOIN tree_element te
         JOIN tree_version_element tve ON te.id = tve.tree_element_id
         JOIN tree t ON tve.tree_version_id = t.current_tree_version_id AND t.accepted_tree
              ON te.name_id = n.id
         LEFT JOIN instance s
         JOIN tree_element te2 on te2.instance_id = s.cited_by_id
         JOIN tree_version_element tve2 ON te2.id = tve2.tree_element_id
         JOIN tree t2 ON tve2.tree_version_id = t2.current_tree_version_id AND t2.accepted_tree
              ON s.name_id = n.id -- and te.name_id is NULL

WHERE EXISTS(SELECT 1
             FROM instance
             WHERE instance.name_id = n.id
    )
  and nt.rdf_id !~ '(common|vernacular)'
  -- and n.name_path !~ '^C[^P]/*'
ORDER BY n.id, "namePublishedInYear", "originalNameUsageYear";

-- moziauddin start
-- The function to push tree synonymy changes to tree_element on changes to references
-- DROP FUNCTION fn_errata_ref_change(v_ref_id reference.id%TYPE);
-- DROP FUNCTION fn_errata_author_change(v_author_id author.id%TYPE);
-- DROP FUNCTION fn_errata_name_change_get_instance_ids(v_name_id bigint) ;
-- DROP FUNCTION fn_errata_name_change_update_te(v_name_id bigint);

-- A function to update tree synonymy on updates to references
CREATE OR REPLACE FUNCTION fn_errata_ref_change(v_ref_id reference.id%TYPE)
    RETURNS VOID
    LANGUAGE plpgsql
AS $fn_errata_ref_change$
DECLARE
BEGIN
    -- Update the tree_element synonyms_html where reference is directly quoted
    UPDATE tree_element
    SET
        synonyms_html = coalesce(
                synonyms_as_html(instance_id),
                '<synonyms></synonyms>'),
        synonyms = coalesce(
                synonyms_as_jsonb(
                        instance_id,
                        (SELECT host_name FROM tree WHERE accepted_tree = TRUE)), '[]' :: jsonb),
        updated_at = NOW(),
        updated_by = 'F_ErrReference'
    WHERE id IN ( SELECT id
                  FROM tree_element
                  WHERE synonyms ->> 'list' LIKE '%reference/apni/' || v_ref_id || '%');
    RAISE NOTICE 'Updating instance for ref: %', v_ref_id;
END;
$fn_errata_ref_change$;

-- The function to push tree synonymy changes to tree_element on changes to author
CREATE OR REPLACE FUNCTION fn_errata_author_change(v_author_id author.id%TYPE)
    RETURNS VOID
    LANGUAGE plpgsql
AS $fn_errata_author_change$
DECLARE row record;
BEGIN
    -- Update the tree_element synonymy_html
    UPDATE tree_element
    SET
        synonyms_html = coalesce(
                synonyms_as_html(instance_id),
                '<synonyms></synonyms>'),
        synonyms = coalesce(
                synonyms_as_jsonb(
                        instance_id,
                        (SELECT host_name FROM tree WHERE accepted_tree = TRUE)), '[]' :: jsonb),
        updated_at = NOW(),
        updated_by = 'F_ErrAuthor'
    WHERE instance_id IN (
        select distinct instance_id
        from tree_element
             -- removed author to accomodate base, ex and ex-base author types
        where synonyms->>'list' like '% data-id=''' || v_author_id || ''' title=%'
    );
    RAISE NOTICE 'Updated te synonyms_html and synonyms jsonb for direct references';
END;
$fn_errata_author_change$;

-- The function to update instance cached_synonymy_html attribute
CREATE OR REPLACE FUNCTION fn_update_ics()
    RETURNS VOID
    LANGUAGE plpgsql
AS
$fn_update_ics$
DECLARE
BEGIN
    -- Update instance cached_synonymy_html attribute
    update instance
    set
        cached_synonymy_html = coalesce(synonyms_as_html(id), '<synonyms></synonyms>'),
        updated_by = 'SynonymyUpdateJob',
        updated_at = now()
    where
            id in (select distinct instance_id from tree_element)
      and
            cached_synonymy_html <> coalesce(synonyms_as_html(id), '<synonyms></synonyms>');
END
$fn_update_ics$;

-- The helper function to get ids of instances that cite instances
-- for a name on the tree
CREATE OR REPLACE FUNCTION fn_errata_name_change_get_instance_ids(v_name_id bigint)
    RETURNS TABLE(in_id bigint)
AS
$fn_errata_name_change_get_instance_ids$
DECLARE
    row record;
BEGIN
    for row in (select id from name
                where id = v_name_id)
        LOOP
            RETURN QUERY select instance_id
                         from tree_element
                         where synonyms_html ilike '%<name data-id=''' || row.id || '''>%';
            RAISE NOTICE '% processing', row.id;
        end loop;
end
$fn_errata_name_change_get_instance_ids$ LANGUAGE plpgsql STABLE STRICT;

-- The function to push tree synonymy changes to tree_element on changes to names
CREATE OR REPLACE FUNCTION fn_errata_name_change_update_te(v_name_id bigint)
    RETURNS VOID
AS
$fn_errata_name_change_update_te$
DECLARE
    row record;
BEGIN
    for row in (select distinct in_id
                from fn_errata_name_change_get_instance_ids(v_name_id))
        LOOP
            RAISE NOTICE 'Updating Instance ID: %', row.in_id;
            UPDATE tree_element
            SET synonyms = coalesce(
                    synonyms_as_jsonb(
                            row.in_id,
                            (SELECT host_name FROM tree WHERE accepted_tree = TRUE)), '[]' :: jsonb),
                synonyms_html = coalesce(
                        synonyms_as_html(row.in_id), '<synonyms></synonyms>'),
                updated_at = NOW(),
                updated_by = 'F_ErrName'
            WHERE instance_id = row.in_id;
        end loop;
end
$fn_errata_name_change_update_te$ LANGUAGE plpgsql;

-- moziauddin end

-- version
UPDATE db_version
SET version = 38
WHERE id = 1;
