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

-- *** NSL-3356 fix reference year to iso publication date ***

create index iso_pub_index on reference (iso_publication_date asc);

-- fix no closing year tag in tree_element
update tree_element
set synonyms_html=regexp_replace(synonyms_html, '<year>([^<]*)</?', '<year>\1</', 'g')
where tree_element.synonyms_html <> '<synonyms></synonyms>';

-- redo functions using ref.year
drop function if exists ref_year(text);
create function ref_year(iso_publication_date text)
    returns integer
    language sql
as
$$
select cast(substring(iso_publication_date from 1 for 4) AS integer)
$$;

-- Find earliest local instance for a name.
drop function if exists first_ref(bigint);
create function first_ref(nameid bigint)
    returns table
            (
                group_id           bigint,
                group_name         text,
                group_iso_pub_date text
            )
    language sql
as
$$
select n.id group_id, n.sort_name group_name, min(r.iso_publication_date)
from name n
         join instance i
         join reference r on i.reference_id = r.id
              on n.id = i.name_id
where n.id = nameid
group by n.id, sort_name
$$;

-- get the synonyms of a name in flora order for apni
drop function if exists apni_ordered_nom_synonymy(bigint);
create function apni_ordered_nom_synonymy(instanceid bigint)
    returns TABLE
            (
                instance_id          bigint,
                instance_uri         text,
                instance_type        text,
                instance_type_id     bigint,
                name_id              bigint,
                name_uri             text,
                full_name            text,
                full_name_html       text,
                name_status          text,
                citation             text,
                citation_html        text,
                year                 int,
                iso_publication_date text,
                page                 text,
                sort_name            text,
                misapplied           boolean,
                ref_id               bigint
            )
    language sql
as
$$
select i.id,
       i.uri,
       it.has_label                     as instance_type,
       it.id                            as instance_type_id,
       n.id                             as name_id,
       n.uri,
       n.full_name,
       n.full_name_html,
       ns.name                          as name_status,
       r.citation,
       r.citation_html,
       ref_year(r.iso_publication_date) as year,
       r.iso_publication_date,
       cites.page,
       n.sort_name,
       false,
       r.id
from instance i
         join instance_type it on i.instance_type_id = it.id and it.nomenclatural
         join name n on i.name_id = n.id
         join name_status ns on n.name_status_id = ns.id
         left outer join instance cites on i.cites_id = cites.id
         left outer join reference r on cites.reference_id = r.id
where i.cited_by_id = instanceid
order by (it.sort_order < 20) desc,
         it.nomenclatural desc,
         r.iso_publication_date,
         n.sort_name,
         it.pro_parte,
         it.doubtful,
         cites.page,
         cites.id;
$$;

drop function if exists apni_ordered_other_synonymy(bigint);
create function apni_ordered_other_synonymy(instanceid bigint)
    returns TABLE
            (
                instance_id          bigint,
                instance_uri         text,
                instance_type        text,
                instance_type_id     bigint,
                name_id              bigint,
                name_uri             text,
                full_name            text,
                full_name_html       text,
                name_status          text,
                citation             text,
                citation_html        text,
                year                 int,
                iso_publication_date text,
                page                 text,
                sort_name            text,
                group_name           text,
                group_head           boolean,
                group_iso_pub_date   text,
                misapplied           boolean,
                ref_id               bigint,
                og_id                bigint,
                og_head              boolean,
                og_name              text,
                og_year              text
            )
    language sql
as
$$
select i.id                                                            as instance_id,
       i.uri                                                           as instance_uri,
       it.has_label                                                    as instance_type,
       it.id                                                           as instance_type_id,
       n.id                                                            as name_id,
       n.uri                                                           as name_uri,
       n.full_name,
       n.full_name_html,
       ns.name                                                         as name_status,
       r.citation,
       r.citation_html,
       ref_year(r.iso_publication_date)                                as year,
       r.iso_publication_date,
       cites.page,
       n.sort_name,
       ng.group_name                                                   as group_name,
       ng.group_id = n.id                                              as group_head,
       coalesce(ng.group_iso_pub_date, r.iso_publication_date) :: text as group_iso_pub_date,
       it.misapplied,
       r.id                                                            as ref_id,
       og_id                                                           as og_id,
       og_id = n.id                                                    as og_head,
       coalesce(ogn.sort_name, n.sort_name)                            as og_name,
       coalesce(ogr.iso_publication_date, r.iso_publication_date)      as og_iso_pub_date
from instance i
         join instance_type it on i.instance_type_id = it.id and not it.nomenclatural and it.relationship
         join name n on i.name_id = n.id
         join name_type nt on n.name_type_id = nt.id
         join orth_or_alt_of(case when nt.autonym then n.parent_id else n.id end) og_id on true
         left outer join name ogn on ogn.id = og_id and not og_id = n.id
         left outer join instance ogi
         join reference ogr on ogr.id = ogi.reference_id
              on ogi.name_id = og_id and ogi.id = i.cited_by_id and not og_id = n.id
         left outer join first_ref(basionym(og_id)) ng on true
         join name_status ns on n.name_status_id = ns.id
         left outer join instance cites on i.cites_id = cites.id
         left outer join reference r on cites.reference_id = r.id
where i.cited_by_id = instanceid
order by (it.sort_order < 20) desc,
         it.taxonomic desc,
         group_iso_pub_date,
         group_name,
         group_head desc,
         og_iso_pub_date,
         og_name,
         og_head desc,
         r.iso_publication_date,
         n.sort_name,
         it.pro_parte,
         it.misapplied desc,
         it.doubtful,
         cites.page,
         cites.id;
$$;

-- ...

-- if this is a relationship instance what are we a synonym of
drop function if exists apni_synonym(bigint);
create function apni_synonym(instanceid bigint)
    returns TABLE
            (
                instance_id          bigint,
                instance_uri         text,
                instance_type        text,
                instance_type_id     bigint,
                name_id              bigint,
                name_uri             text,
                full_name            text,
                full_name_html       text,
                name_status          text,
                citation             text,
                citation_html        text,
                year                 int,
                iso_publication_date text,
                page                 text,
                misapplied           boolean,
                sort_name            text
            )
    language sql
as
$$
select i.id,
       i.uri,
       it.of_label as instance_type,
       it.id       as instance_type_id,
       n.id        as name_id,
       n.uri,
       n.full_name,
       n.full_name_html,
       ns.name,
       r.citation,
       r.citation_html,
       ref_year(r.iso_publication_date),
       r.iso_publication_date,
       i.page,
       it.misapplied,
       n.sort_name
from instance i
         join instance_type it on i.instance_type_id = it.id
         join instance cites on i.cited_by_id = cites.id
         join name n on cites.name_id = n.id
         join name_status ns on n.name_status_id = ns.id
         join reference r on i.reference_id = r.id
where i.id = instanceid
  and it.relationship;
$$;

-- apni ordered references for a name
drop function if exists apni_ordered_references(bigint);
create function apni_ordered_references(nameid bigint)
    returns TABLE
            (
                instance_id          bigint,
                instance_uri         text,
                instance_type        text,
                citation             text,
                citation_html        text,
                year                 int,
                iso_publication_date text,
                pages                text,
                page                 text
            )
    language sql
as
$$
select i.id,
       i.uri,
       it.name,
       r.citation,
       r.citation_html,
       ref_year(r.iso_publication_date),
       r.iso_publication_date,
       r.pages,
       coalesce(i.page, citedby.page, '-')
from instance i
         join reference r on i.reference_id = r.id
         join instance_type it on i.instance_type_id = it.id
         left outer join instance citedby on i.cited_by_id = citedby.id
where i.name_id = nameid
group by r.id, i.id, it.id, citedby.id
order by r.iso_publication_date, it.protologue, it.primary_instance, r.citation, r.pages, i.page, r.id;
$$;

drop function if exists apni_ordered_synonymy(bigint);
create function apni_ordered_synonymy(instanceid bigint)
    returns TABLE
            (
                instance_id          bigint,
                instance_uri         text,
                instance_type        text,
                instance_type_id     bigint,
                name_id              bigint,
                name_uri             text,
                full_name            text,
                full_name_html       text,
                name_status          text,
                citation             text,
                citation_html        text,
                iso_publication_date text,
                page                 text,
                sort_name            text,
                misapplied           boolean,
                ref_id               bigint
            )
    language sql
as
$$

select instance_id,
       instance_uri,
       instance_type,
       instance_type_id,
       name_id,
       name_uri,
       full_name,
       full_name_html,
       name_status,
       citation,
       citation_html,
       iso_publication_date,
       page,
       sort_name,
       misapplied,
       ref_id
from apni_ordered_nom_synonymy(instanceid)
union all
select instance_id,
       instance_uri,
       instance_type,
       instance_type_id,
       name_id,
       name_uri,
       full_name,
       full_name_html,
       name_status,
       citation,
       citation_html,
       iso_publication_date,
       page,
       sort_name,
       misapplied,
       ref_id
from apni_ordered_other_synonymy(instanceid)
$$;

-- get the synonyms of an instance as html to store in the tree in apni synonymy order
drop function if exists synonym_as_html(bigint);
create function synonym_as_html(instanceid bigint)
    returns TABLE
            (
                html text
            )
    language sql
as
$$
SELECT CASE
           WHEN it.nomenclatural
               THEN '<nom>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                    '</name-status> <year>(' || iso_publication_date || ')</year> <type>' || instance_type ||
                    '</type></nom>'
           WHEN it.taxonomic
               THEN '<tax>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                    '</name-status> <year>(' || iso_publication_date || ')</year> <type>' || instance_type ||
                    '</type></tax>'
           WHEN it.misapplied
               THEN '<mis>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                    '</name-status><type>' || instance_type || '</type> by <citation>' ||
                    citation_html || '</citation></mis>'
           WHEN it.synonym
               THEN '<syn>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                    '</name-status> <year>(' || iso_publication_date || ')</year> <type>' || it.name || '</type></syn>'
           ELSE '<oth>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                '</name-status> <type>' || it.name || '</type></oth>'
           END
FROM apni_ordered_synonymy(instanceid)
         join instance_type it on instance_type_id = it.id
$$;

-- fix the year in the synonyms html
update instance
set cached_synonymy_html = coalesce(synonyms_as_html(id), '<synonyms></synonyms>')
where id in (select distinct instance_id from tree_element);

-- update all those where just the publication date has changed
update tree_element te
set synonyms_html = i.cached_synonymy_html
from instance i,
     tree_version_element tve,
     tree t
where te.instance_id = i.id
  and te.id = tve.tree_element_id
  and t.default_draft_tree_version_id = tve.tree_version_id
  and te.synonyms_html <> i.cached_synonymy_html
  and regexp_replace(te.synonyms_html, '<year>[^<]*</year>', '', 'g') =
      regexp_replace(i.cached_synonymy_html, '<year>[^<]*</year>', '', 'g')
;
-- version
UPDATE db_version
SET version = 35
WHERE id = 1;
