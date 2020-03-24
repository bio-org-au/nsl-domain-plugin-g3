-- NSL-752 NSL-2894
-- functions to get ordered output as needed by the APNI format

-- find basionym
drop function if exists basionym(bigint);
create function basionym(nameid bigint)
    returns bigint
    language sql
as $$
select coalesce(
               (select coalesce(bas_name.id, primary_inst.name_id)
                from instance primary_inst
                         left join instance bas_inst
                         join name bas_name on bas_inst.name_id = bas_name.id
                         join instance_type bas_it on bas_inst.instance_type_id = bas_it.id and bas_it.name in ('basionym','replaced synonym')
                         join instance cit_inst on bas_inst.cites_id = cit_inst.id
                              on bas_inst.cited_by_id = primary_inst.id
                         join instance_type primary_it on primary_inst.instance_type_id = primary_it.id and primary_it.primary_instance
                where primary_inst.name_id = nameid
                limit 1), nameid);
$$;

drop function if exists ref_parent_date(bigint);
create function ref_parent_date(ref_id BIGINT)
    returns text
    language sql
as
$$
select case
           when rt.use_parent_details = true
               then coalesce(r.iso_publication_date, pr.iso_publication_date)
           else r.iso_publication_date
           end
from reference r
         join ref_type rt on r.ref_type_id = rt.id
         left outer join reference pr on r.parent_id = pr.id
where r.id = ref_id;
$$;

-- ref.year from iso publication date
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

-- find the name an orth var or alt name is of

drop function if exists orth_or_alt_of(bigint);
create function orth_or_alt_of(nameid bigint)
    returns bigint
    language sql
as $$
select coalesce((select alt_of_inst.name_id
                 from name n
                          join name_status ns on n.name_status_id = ns.id
                          join instance alt_inst on n.id = alt_inst.name_id
                          join instance_type alt_it on alt_inst.instance_type_id = alt_it.id and
                                                       alt_it.name in ('orthographic variant', 'alternative name')
                          join instance alt_of_inst on alt_of_inst.id = alt_inst.cited_by_id
                 where n.id = nameid
                   and ns.name ~ '(orth. var.|nom. alt.)' limit 1), nameid) id
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
       ref_year(iso_date) as year,
       coalesce(iso_date, '-'),
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
         left outer join ref_parent_date(r.id) iso_date on true
where i.cited_by_id = instanceid
order by (it.sort_order < 20) desc,
         it.nomenclatural desc,
         iso_date,
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
       ref_year(iso_date)                                as year,
       coalesce(iso_date,'-'),
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
         left outer join ref_parent_date(r.id) iso_date on true
where i.cited_by_id = instanceid
order by (it.sort_order < 20) desc,
         it.taxonomic desc,
         group_iso_pub_date,
         group_name,
         group_head desc,
         og_iso_pub_date,
         og_name,
         og_head desc,
         iso_date,
         n.sort_name,
         it.pro_parte,
         it.misapplied desc,
         it.doubtful,
         cites.page,
         cites.id;
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

-- apni ordered synonymy as a text output

drop function if exists apni_ordered_synonymy_text(bigint);
create function apni_ordered_synonymy_text(instanceid bigint)
    returns text
    language sql
as $$
select string_agg('  ' ||
                  syn.instance_type ||
                  ': ' ||
                  syn.full_name ||
                  (case
                       when syn.name_status = 'legitimate' then ''
                       when syn.name_status = '[n/a]' then ''
                       else ' ' || syn.name_status end) ||
                  (case
                       when syn.misapplied then syn.citation
                       else '' end), E'\n') || E'\n'
from apni_ordered_synonymy(instanceid) syn;
$$;

-- apni ordered synonymy as a jsonb output
drop function if exists apni_ordered_synonymy_jsonb(bigint);
create function apni_ordered_synonymy_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'instance_id', syn.instance_id,
                       'instance_uri', syn.instance_uri,
                       'instance_type', syn.instance_type,
                       'name_uri', syn.name_uri,
                       'full_name_html', syn.full_name_html,
                       'name_status', syn.name_status,
                       'misapplied', syn.misapplied,
                       'citation_html', syn.citation_html
                   )
           )
from apni_ordered_synonymy(instanceid) syn;
$$;

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
       ref_year(iso_date),
       iso_date,
       i.page,
       it.misapplied,
       n.sort_name
from instance i
         join instance_type it on i.instance_type_id = it.id
         join instance cites on i.cited_by_id = cites.id
         join name n on cites.name_id = n.id
         join name_status ns on n.name_status_id = ns.id
         join reference r on i.reference_id = r.id
         left outer join ref_parent_date(r.id) iso_date on true
where i.id = instanceid
  and it.relationship;
$$;

-- if this is a relationship instance what are we a synonym of as text
drop function if exists apni_synonym_text(bigint);
create function apni_synonym_text(instanceid bigint)
    returns text
    language sql
as $$
select string_agg('  ' ||
                  syn.instance_type ||
                  ': ' ||
                  syn.full_name ||
                  (case
                       when syn.name_status = 'legitimate' then ''
                       when syn.name_status = '[n/a]' then ''
                       else ' ' || syn.name_status end) ||
                  (case
                       when syn.misapplied
                           then 'by ' || syn.citation
                       else '' end), E'\n') || E'\n'
from apni_synonym(instanceid) syn;
$$;

-- if this is a relationship instance what are we a synonym of as jsonb
drop function if exists apni_synonym_jsonb(bigint);
create function apni_synonym_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'instance_id', syn.instance_id,
                       'instance_uri', syn.instance_uri,
                       'instance_type', syn.instance_type,
                       'name_uri', syn.name_uri,
                       'full_name_html', syn.full_name_html,
                       'name_status', syn.name_status,
                       'misapplied', syn.misapplied,
                       'citation_html', syn.citation_html
                   )
           )
from apni_synonym(instanceid) syn;
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
       ref_year(iso_date),
       iso_date,
       r.pages,
       coalesce(i.page, citedby.page, '-')
from instance i
         join reference r on i.reference_id = r.id
         join instance_type it on i.instance_type_id = it.id
         left outer join instance citedby on i.cited_by_id = citedby.id
         left outer join ref_parent_date(r.id) iso_date on true
where i.name_id = nameid
group by r.id, iso_date, i.id, it.id, citedby.id
order by iso_date, it.protologue, it.primary_instance, r.citation, r.pages, i.page, r.id;
$$;

drop function if exists format_isodate(text);
create function format_isodate(isodate text)
    returns text
    language sql
as
$$
with m(k, v) as (values ('', ''),
                        ('01', 'January'),
                        ('02', 'February'),
                        ('03', 'March'),
                        ('04', 'April'),
                        ('05', 'May'),
                        ('06', 'June'),
                        ('07', 'July'),
                        ('08', 'August'),
                        ('09', 'September'),
                        ('10', 'October'),
                        ('11', 'November'),
                        ('12', 'December'))
select trim(coalesce(day.d, '')  ||
            ' ' || coalesce(m.v, '') ||
            ' ' || year)
from m,
     (select nullif(split_part(isodate, '-', 3),'')::numeric::text d) day,
     split_part(isodate, '-', 2) month,
     split_part(isodate, '-', 1) year
where m.k = month
   or (month = '' and m.k = '00')
$$;

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
                    '</name-status> <year>(' || format_isodate(iso_publication_date) || ')</year> <type>' || instance_type ||
                    '</type></nom>'
           WHEN it.taxonomic
               THEN '<tax>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                    '</name-status> <year>(' || format_isodate(iso_publication_date) || ')</year> <type>' || instance_type ||
                    '</type></tax>'
           WHEN it.misapplied
               THEN '<mis>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                    '</name-status><type>' || instance_type || '</type> by <citation>' ||
                    citation_html || '</citation></mis>'
           WHEN it.synonym
               THEN '<syn>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                    '</name-status> <year>(' || format_isodate(iso_publication_date) || ')</year> <type>' || it.name || '</type></syn>'
           ELSE '<oth>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                '</name-status> <type>' || it.name || '</type></oth>'
           END
FROM apni_ordered_synonymy(instanceid)
         join instance_type it on instance_type_id = it.id
$$;

drop function if exists synonyms_as_html(bigint);
create function synonyms_as_html(instance_id bigint) returns text
    language sql
as $$
SELECT '<synonyms>' || string_agg(html, '') || '</synonyms>'
FROM synonym_as_html(instance_id) AS html;
$$
;

-- build JSONB representation of synonyms inside a shard TODO fix links
DROP FUNCTION IF EXISTS synonyms_as_jsonb(BIGINT, TEXT);
CREATE FUNCTION synonyms_as_jsonb(instance_id BIGINT, host TEXT)
    RETURNS JSONB
    LANGUAGE SQL
AS
$$
SELECT jsonb_build_object('list',
                          coalesce(
                                  jsonb_agg(jsonb_build_object(
                                          'host', host,
                                          'instance_id', syn_inst.id,
                                          'instance_link', syn_inst.uri,
                                          'concept_link', coalesce(cites_inst.uri, syn_inst.uri),
                                          'simple_name', synonym.simple_name,
                                          'type', it.name,
                                          'name_id', synonym.id :: BIGINT,
                                          'name_link', synonym.uri,
                                          'full_name_html', synonym.full_name_html,
                                          'nom', it.nomenclatural,
                                          'tax', it.taxonomic,
                                          'mis', it.misapplied,
                                          'cites', coalesce(cites_ref.citation, syn_ref.citation),
                                          'cites_html', coalesce(cites_ref.citation_html, syn_ref.citation_html),
                                          'cites_link', '/reference/'|| lower(conf.value) || '/' || (coalesce(cites_ref.id, syn_ref.id)),
                                          'year', cites_ref.year
                                      )), '[]' :: JSONB)
           )
FROM Instance i,
     Instance syn_inst
         JOIN instance_type it ON syn_inst.instance_type_id = it.id
         JOIN reference syn_ref on syn_inst.reference_id = syn_ref.id
         LEFT JOIN instance cites_inst ON syn_inst.cites_id = cites_inst.id
         LEFT JOIN reference cites_ref ON cites_inst.reference_id = cites_ref.id
        ,
     name synonym,
     shard_config conf
WHERE i.id = instance_id
  AND syn_inst.cited_by_id = i.id
  AND synonym.id = syn_inst.name_id
  AND conf.name = 'name space';
$$;

-- instance notes

drop function if exists type_notes(bigint);
create function type_notes(instanceid bigint)
    returns TABLE(note_key text,
                  note     text)
    language sql
as $$
select k.name, nt.value
from instance_note nt
         join instance_note_key k on nt.instance_note_key_id = k.id
where nt.instance_id = instanceid
  and k.name ilike '%type'
$$;

drop function if exists type_notes_text(bigint);
create function type_notes_text(instanceid bigint)
    returns text
    language sql
as $$
select string_agg('  ' || nt.note_key || ': ' || nt.note || E'\n', E'\n')
from type_notes(instanceid) as nt
$$;

drop function if exists type_notes_jsonb(bigint);
create function type_notes_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'note_key', nt.note_key,
                       'note_value', nt.note
                   )
           )
from type_notes(instanceid) as nt
$$;

drop function if exists non_type_notes(bigint);
create function non_type_notes(instanceid bigint)
    returns TABLE(note_key text,
                  note     text)
    language sql
as $$
select k.name, nt.value
from instance_note nt
         join instance_note_key k on nt.instance_note_key_id = k.id
where nt.instance_id = instanceid
  and k.name not ilike '%type'
$$;

drop function if exists non_type_notes_text(bigint);
create function non_type_notes_text(instanceid bigint)
    returns text
    language sql
as $$
select string_agg('  ' || nt.note_key || ': ' || nt.note || E'\n', E'\n')
from non_type_notes(instanceid) as nt
$$;

drop function if exists non_type_notes_jsonb(bigint);
create function non_type_notes_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'note_key', nt.note_key,
                       'note_value', nt.note
                   )
           )
from non_type_notes(instanceid) as nt
$$;

-- profile stuff
drop function if exists latest_accepted_profile(bigint);
create function latest_accepted_profile(instanceid bigint)
    returns table(comment_key text, comment_value text, dist_key text, dist_value text)
    language sql
as $$
select config ->> 'comment_key'                                 as comment_key,
       (profile -> (config ->> 'comment_key')) ->> 'value'      as comment_value,
       config ->> 'distribution_key'                            as dist_key,
       (profile -> (config ->> 'distribution_key')) ->> 'value' as dist_value
from tree_version_element tve
         join tree_element te on tve.tree_element_id = te.id
         join tree_version tv on tve.tree_version_id = tv.id and tv.published
         join tree t on tv.tree_id = t.id and t.accepted_tree
where te.instance_id = instanceid
order by tv.id desc
limit 1
$$;

drop function if exists latest_accepted_profile_jsonb(bigint);
create function latest_accepted_profile_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_build_object(
               'comment_key', comment_key,
               'comment_value', comment_value,
               'dist_key', dist_key,
               'dist_value', dist_value
           )
from latest_accepted_profile(instanceid)
$$;

drop function if exists latest_accepted_profile_text(bigint);
create function latest_accepted_profile_text(instanceid bigint)
    returns text
    language sql
as $$
select '  ' ||
       case
           when comment_value is not null
               then comment_key || ': ' || comment_value
           else ''
           end ||
       case
           when dist_value is not null
               then dist_key || ': ' || dist_value
           else ''
           end ||
       E'\n'
from latest_accepted_profile(instanceid)
$$;

-- resources

drop function if exists instance_resources(bigint);
create function instance_resources(instanceid bigint)
    returns table(name text, description text, url text, css_icon text, media_icon text)
    language sql
as $$
select rd.name, rd.description, s.url || '/' || r.path, rd.css_icon, 'media/' || m.id
from instance_resources ir
         join resource r on ir.resource_id = r.id
         join site s on r.site_id = s.id
         join resource_type rd on r.resource_type_id = rd.id
         left outer join media m on m.id = rd.media_icon_id
where ir.instance_id = instanceid
$$;

drop function if exists instance_resources_jsonb(bigint);
create function instance_resources_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'type', ir.name,
                       'description', ir.description,
                       'url', ir.url,
                       'css_icon', ir.css_icon,
                       'media_icon', ir.media_icon
                   )
           )
from instance_resources(instanceid) ir
$$;

-- latest tree version this instance has been on
drop function if exists instance_on_accepted_tree(bigint);
create function instance_on_accepted_tree(instanceId bigint)
    returns table(current boolean, excluded boolean, element_link text, tree_name text)
    language sql
as $$
select t.current_tree_version_id = tv.id, te.excluded, tve.element_link, t.name
from tree_element te
         join tree_version_element tve on te.id = tve.tree_element_id
         join tree_version tv on tve.tree_version_id = tv.id
         join tree t on tv.tree_id = t.id and t.accepted_tree
where te.instance_id = instanceId
  and tv.published
order by tve.tree_version_id desc
limit 1;
$$;

drop function if exists instance_on_accepted_tree_jsonb(bigint);
create function instance_on_accepted_tree_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'current', tve.current,
                       'excluded', tve.excluded,
                       'element_link', tve.element_link,
                       'tree_name', tve.tree_name
                   )
           )
from instance_on_accepted_tree(instanceid) tve
$$;


-- apni details as text output
drop function if exists apni_detail_text(bigint);
create function apni_detail_text(nameid bigint)
    returns text
    language sql
as $$
select string_agg(' ' ||
                  refs.citation ||
                  ': ' ||
                  refs.page || E'\n' ||
                  coalesce(type_notes_text(refs.instance_id), '') ||
                  coalesce(apni_ordered_synonymy_text(refs.instance_id), apni_synonym_text(refs.instance_id), '') ||
                  coalesce(non_type_notes_text(refs.instance_id), '') ||
                  coalesce(latest_accepted_profile_text(refs.instance_id), ''),
                  E'\n')
from apni_ordered_references(nameid) refs
$$;

-- apni details as jsonb output
drop function if exists apni_detail_jsonb(bigint);
create function apni_detail_jsonb(nameid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'ref_citation_html', refs.citation_html,
                       'ref_citation', refs.citation,
                       'instance_id', refs.instance_id,
                       'instance_uri', refs.instance_uri,
                       'instance_type', refs.instance_type,
                       'page', refs.page,
                       'type_notes', coalesce(type_notes_jsonb(refs.instance_id), '{}' :: jsonb),
                       'synonyms', coalesce(apni_ordered_synonymy_jsonb(refs.instance_id), apni_synonym_jsonb(refs.instance_id), '[]' :: jsonb),
                       'non_type_notes', coalesce(non_type_notes_jsonb(refs.instance_id), '{}' :: jsonb),
                       'profile', coalesce(latest_accepted_profile_jsonb(refs.instance_id), '{}' :: jsonb),
                       'resources', coalesce(instance_resources_jsonb(refs.instance_id), '{}' :: jsonb),
                       'tree', coalesce(instance_on_accepted_tree_jsonb(refs.instance_id), '{}' :: jsonb)
                   )
           )
from apni_ordered_references(nameid) refs
$$;

-- functions to construct display distribution strings
drop function if exists dist_entry_status(BIGINT);
create function dist_entry_status(entry_id BIGINT)
    returns text
    language sql as
$$
with status as (
    SELECT string_agg(ds.name, ' and ') status
    from (
             select ds.name
             FROM dist_entry de
                      join dist_region dr on de.region_id = dr.id
                      join dist_entry_dist_status deds on de.id = deds.dist_entry_status_id
                      join dist_status ds on deds.dist_status_id = ds.id
             where de.id = entry_id
             order by ds.sort_order) ds
)
select case
           when status.status = 'native' then
               ''
           else
                       '(' || status.status || ')'
           end
from status;
$$;

drop function if exists distribution(BIGINT);
create function distribution(element_id BIGINT)
    returns text
    language sql as
$$
select string_agg(e.display, ', ') from
    (select entry.display display
     from dist_entry entry
              join dist_region dr on entry.region_id = dr.id
              join tree_element_distribution_entries tede
                   on tede.dist_entry_id = entry.id and tede.tree_element_id = element_id
     order by dr.sort_order) e
$$;

drop function if exists is_iso8601(varchar);
create or replace function is_iso8601(isoString varchar) returns boolean as $$
DECLARE match boolean;
begin
    match := isoString ~ '^[1,2][0-9]{3}$' or
             isoString ~ '^[1,2][0-9]{3}-(01|02|03|04|05|06|07|08|09|10|11|12)$';
    if match then
        return true;
    end if;
    perform isoString::TIMESTAMP;
    return true;
exception when others then
    return false;
end;
$$ language plpgsql;
