--drop resource and media tables and rebuild
alter table resource drop column if exists resource_type_id;
alter table name drop column if exists apni_json;
alter table author drop column if exists uri;
alter table instance drop column if exists uri;
alter table instance drop column if exists cached_synonymy_html;
alter table name drop column if exists uri;
alter table name drop column if exists published_year;
alter table reference drop column if exists uri;
alter table tree_version_element drop column if exists merge_conflict;
drop table if exists resource_type;
drop table if exists media;

-- delete existing resources as they'll be re-created correctly where needed
delete from instance_resources;
delete from resource;

-- create new resource description and media tables
create table media (
  id int8 default nextval('hibernate_sequence') not null,
  version int8 not null,
  data bytea not null,
  description text not null,
  file_name text not null,
  mime_type text not null,
  primary key (id)
);

create table resource_type (
  id int8 default nextval('nsl_global_seq') not null,
  lock_version int8 default 0 not null,
  css_icon text,
  deprecated boolean default false not null,
  description text not null,
  display boolean default true not null,
  media_icon_id int8,
  name text not null,
  rdf_id varchar(50),
  primary key (id)
);

alter table resource add column resource_type_id int8 not null; -- there shouldn't be any yet

alter table if exists resource
  add constraint FK_i2tgkebwedao7dlbjcrnvvtrv
  foreign key (resource_type_id)
  references resource_type;

alter table if exists resource_type
  add constraint FK_6nxjoae1hvplngbvpo0k57jjt
  foreign key (media_icon_id)
  references media;

-- add uri columns to author, instance,name and reference nullable for now.

alter table author add column uri text;
alter table instance add column uri text;
alter table name add column uri text;
alter table reference add column uri text;
alter table tree_version_element add column merge_conflict boolean default false not null;

-- alter table if exists author
--   add constraint UK_rd7q78koyhufe1edfb2rgfrum  unique (uri);
-- alter table if exists instance
--   add constraint UK_bl9pesvdo9b3mp2qdna1koqc7  unique (uri);
-- alter table if exists name
--   add constraint UK_66rbixlxv32riosi9ob62m8h5  unique (uri);
-- alter table if exists reference
--   add constraint UK_nivlrafbqdoj0yie46ixithd3  unique (uri);

-- add cached synonymy on instance
alter table instance add column cached_synonymy_html text;

-- NSL-3099 add changed_combination flag on name.
alter table name add column changed_combination boolean default false not null;

-- NSL-3101 add published_year to name to support iczn
alter table name add column published_year int4;
alter table name add constraint published_year_limits check (published_year > 0 and published_year < 2500);

-- NSL-3065
alter table name_category add column max_parents_allowed int4 default 0 not null;
alter table name_category add column min_parents_required int4 default 0 not null;
alter table name_category add column parent_1_help_text text;
alter table name_category add column parent_2_help_text text;
alter table name_category add column requires_family boolean default false not null;
alter table name_category add column requires_higher_ranked_parent boolean default false not null;
alter table name_category add column requires_name_element boolean default false not null;
alter table name_category add column takes_author_only boolean default false not null;
alter table name_category add column takes_authors boolean default false not null;
alter table name_category add column takes_cultivar_scoped_parent boolean default false not null;
alter table name_category add column takes_hybrid_scoped_parent boolean default false not null;
alter table name_category add column takes_name_element boolean default false not null;
alter table name_category add column takes_verbatim_rank boolean default false not null;
alter table name_category add column takes_rank boolean default false not null;

update name_category
set sort_order = 50,
    description_html = 'names entered and edited as cultivar names',
    min_parents_required = 1,
    max_parents_allowed = 1,
    parent_1_help_text = 'cultivar - genus and below, or unranked if unranked',
    takes_hybrid_scoped_parent = false,
    requires_family = true,
    takes_name_element = true,
    takes_authors = false,
    takes_author_only = false,
    requires_name_element = true,
    requires_higher_ranked_parent = false,
    takes_cultivar_scoped_parent  = true,
    takes_verbatim_rank = true,
    takes_rank = true
where name = 'cultivar';

update name_category
set sort_order = 10,
    description_html = 'names entered and edited as scientific names',
    min_parents_required = 1,
    max_parents_allowed = 1,
    parent_1_help_text = 'ordinary - restricted by rank, or unranked if unranked',
    takes_hybrid_scoped_parent = false,
    requires_family = true,
    takes_name_element = true,
    takes_authors = true,
    takes_author_only = false,
    requires_name_element = true,
    requires_higher_ranked_parent = true,
    takes_cultivar_scoped_parent  = false,
    takes_verbatim_rank = true,
    takes_rank = true
where name = 'scientific';

insert into name_category
    (name,
     sort_order,
     description_html,
     min_parents_required,
     max_parents_allowed,
     parent_1_help_text,
     takes_hybrid_scoped_parent,
     requires_family,
     takes_name_element,
     takes_authors,
     takes_author_only,
     requires_name_element,
     requires_higher_ranked_parent,
     parent_2_help_text,
     takes_cultivar_scoped_parent ,
     takes_verbatim_rank,
     takes_rank)
values
       ('cultivar hybrid',60,'names entered and edited as cultivar hybrid names',2,2,'cultivar - genus and below, or unranked if unranked',false,true,true,false,false,true,false,'cultivar - genus and below, or unranked if unranked',true,true,true),
       ('other',70,'names entered and edited as other names',0,0,'ordinary - restricted by rank, or unranked if unranked',false,false,true,false,false,true,false,null,true,true,false),
       ('phrase name',20,'names entered and edited as scientific phrase names',1,1,'ordinary - restricted by rank, or unranked if unranked',false,true,true,false,true,false,false,null,false,false,true),
       ('scientific hybrid formula',30,'names entered and edited as scientific hybrid formulae',2,2,'hybrid - species and below or unranked if unranked',true,true,false,false,false,false,false,'hybrid - species and below or unranked if unranked',false,true,true),
       ('scientific hybrid formula unknown 2nd parent',40,'names entered and edited as scientific hybrid formulae with unknown 2nd parent',1,1,'hybrid - species and below or unranked if unranked',true,true,false,false,false,false,false,null,true,true,true)
;

update name_type set name_category_id = (select id from name_category where name_category.name = 'other' ) where name_type.name = '[default]';
update name_type set name_category_id = (select id from name_category where name_category.name = 'other' ) where name_type.name = '[n/a]';
update name_type set name_category_id = (select id from name_category where name_category.name = 'other' ) where name_type.name = '[unknown]';
update name_type set name_category_id = (select id from name_category where name_category.name = 'cultivar' ) where name_type.name = 'acra';
update name_type set name_category_id = (select id from name_category where name_category.name = 'cultivar hybrid' ) where name_type.name = 'acra hybrid';
update name_type set name_category_id = (select id from name_category where name_category.name = 'scientific' ) where name_type.name = 'autonym';
update name_type set name_category_id = (select id from name_category where name_category.name = 'scientific' ) where name_type.name = 'candidatus';
update name_type set name_category_id = (select id from name_category where name_category.name = 'other' ) where name_type.name = 'common';
update name_type set name_category_id = (select id from name_category where name_category.name = 'cultivar' ) where name_type.name = 'cultivar';
update name_type set name_category_id = (select id from name_category where name_category.name = 'cultivar hybrid' ) where name_type.name = 'cultivar hybrid';
update name_type set name_category_id = (select id from name_category where name_category.name = 'scientific hybrid formula' ) where name_type.name = 'cultivar hybrid formula';
update name_type set name_category_id = (select id from name_category where name_category.name = 'scientific hybrid formula' ) where name_type.name = 'graft/chimera';
update name_type set name_category_id = (select id from name_category where name_category.name = 'scientific hybrid formula' ) where name_type.name = 'hybrid autonym';
update name_type set name_category_id = (select id from name_category where name_category.name = 'scientific hybrid formula' ) where name_type.name = 'hybrid formula parents known';
update name_type set name_category_id = (select id from name_category where name_category.name = 'scientific hybrid formula unknown 2nd parent' ) where name_type.name = 'hybrid formula unknown 2nd parent';
update name_type set name_category_id = (select id from name_category where name_category.name = 'other' ) where name_type.name = 'informal';
update name_type set name_category_id = (select id from name_category where name_category.name = 'scientific hybrid formula' ) where name_type.name = 'intergrade';
update name_type set name_category_id = (select id from name_category where name_category.name = 'scientific' ) where name_type.name = 'named hybrid';
update name_type set name_category_id = (select id from name_category where name_category.name = 'scientific' ) where name_type.name = 'named hybrid autonym';
update name_type set name_category_id = (select id from name_category where name_category.name = 'cultivar' ) where name_type.name = 'pbr';
update name_type set name_category_id = (select id from name_category where name_category.name = 'cultivar hybrid' ) where name_type.name = 'pbr hybrid';
update name_type set name_category_id = (select id from name_category where name_category.name = 'phrase name' ) where name_type.name = 'phrase name';
update name_type set name_category_id = (select id from name_category where name_category.name = 'scientific' ) where name_type.name = 'sanctioned';
update name_type set name_category_id = (select id from name_category where name_category.name = 'scientific' ) where name_type.name = 'scientific';
update name_type set name_category_id = (select id from name_category where name_category.name = 'cultivar' ) where name_type.name = 'trade';
update name_type set name_category_id = (select id from name_category where name_category.name = 'cultivar hybrid' ) where name_type.name = 'trade hybrid';
update name_type set name_category_id = (select id from name_category where name_category.name = 'other' ) where name_type.name = 'vernacular';

delete from name_category where name = '[n/a]';
delete from name_category where name = '[unknown]';
delete from name_category where name = 'common';
delete from name_category where name = 'informal';

-- NSL-752 NSL-2894
-- functions to get ordered output as needed by the APNI format

-- drop functions no longer used if they exist.
drop function if exists nom_group(bigint);
drop function if exists apni_ordered_refrences(bigint);

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
                 join instance cit_inst on bas_inst.cites_id = cit_inst.id on bas_inst.cited_by_id = primary_inst.id
                 join instance_type primary_it on primary_inst.instance_type_id = primary_it.id and primary_it.primary_instance
          where primary_inst.name_id = nameid
          limit 1), nameid);
$$;

-- Find earliest local instance for a name.
drop function if exists first_ref(bigint);
create function first_ref(nameid bigint)
  returns table(group_id bigint, group_name text, group_year integer)
language sql
as $$
select n.id group_id, n.sort_name group_name, min(r.year)
from name n
       join instance i
       join reference r on i.reference_id = r.id
         on n.id  = i.name_id
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
  returns TABLE(instance_id      bigint,
                instance_uri     text,
                instance_type    text,
                instance_type_id bigint,
                name_id          bigint,
                name_uri         text,
                full_name        text,
                full_name_html   text,
                name_status      text,
                citation         text,
                citation_html    text,
                year             int,
                page             text,
                sort_name        text,
                misapplied       boolean,
                ref_id           bigint)
language sql
as $$
select i.id,
       i.uri,
       it.has_label as instance_type,
       it.id        as instance_type_id,
       n.id         as name_id,
       n.uri,
       n.full_name,
       n.full_name_html,
       ns.name      as name_status,
       r.citation,
       r.citation_html,
       r.year,
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
         r.year,
         n.sort_name,
         it.pro_parte,
         it.doubtful,
         cites.page,
         cites.id;
$$;

drop function if exists apni_ordered_other_synonymy(bigint);
create function apni_ordered_other_synonymy(instanceid bigint)
  returns TABLE(instance_id      bigint,
                instance_uri     text,
                instance_type    text,
                instance_type_id bigint,
                name_id          bigint,
                name_uri         text,
                full_name        text,
                full_name_html   text,
                name_status      text,
                citation         text,
                citation_html    text,
                year             int,
                page             text,
                sort_name        text,
                group_name       text,
                group_head       boolean,
                group_year       integer,
                misapplied       boolean,
                ref_id           bigint,
                og_id            bigint,
                og_head          boolean,
                og_name text,
                og_year integer)
language sql
as $$
select i.id                            as instance_id,
       i.uri                           as instance_uri,
       it.has_label                    as instance_type,
       it.id                           as instance_type_id,
       n.id                            as name_id,
       n.uri                           as name_uri,
       n.full_name,
       n.full_name_html,
       ns.name                         as name_status,
       r.citation,
       r.citation_html,
       r.year,
       cites.page,
       n.sort_name,
       ng.group_name                   as group_name,
       ng.group_id = n.id              as group_head,
       coalesce(ng.group_year, r.year) as group_year,
       it.misapplied,
       r.id                            as ref_id,
       og_id                           as og_id,
       og_id = n.id                    as og_head,
       coalesce(ogn.sort_name, n.sort_name) as og_name,
       coalesce(ogr.year,r.year)       as og_year
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
         group_year,
         group_name,
         group_head desc,
         og_year,
         og_name,
         og_head desc,
         r.year,
         n.sort_name,
         it.pro_parte,
         it.misapplied desc,
         it.doubtful,
         cites.page,
         cites.id;
$$;

drop function if exists apni_ordered_synonymy(bigint);

create function apni_ordered_synonymy(instanceid bigint)
  returns TABLE(instance_id      bigint,
                instance_uri     text,
                instance_type    text,
                instance_type_id bigint,
                name_id          bigint,
                name_uri         text,
                full_name        text,
                full_name_html   text,
                name_status      text,
                citation         text,
                citation_html    text,
                year             int,
                page             text,
                sort_name        text,
                misapplied       boolean,
                ref_id           bigint)
language sql
as $$

select instance_id, instance_uri, instance_type, instance_type_id, name_id, name_uri, full_name, full_name_html,
       name_status, citation, citation_html, year, page, sort_name, misapplied, ref_id
from apni_ordered_nom_synonymy(instanceid)
union all
select instance_id, instance_uri, instance_type, instance_type_id, name_id, name_uri, full_name, full_name_html,
       name_status, citation, citation_html, year, page, sort_name, misapplied, ref_id
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
  returns TABLE(instance_id    bigint,
                instance_uri   text,
                instance_type  text,
                instance_type_id bigint,
                name_id        bigint,
                name_uri       text,
                full_name      text,
                full_name_html text,
                name_status    text,
                citation       text,
                citation_html  text,
                year           int,
                page           text,
                misapplied     boolean,
                sort_name      text)
language sql
as $$
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
       r.year,
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
  returns TABLE(instance_id   bigint,
                instance_uri text,
                instance_type text,
                citation      text,
                citation_html text,
                year          int,
                pages         text,
                page          text)
language sql
as $$
select i.id, i.uri, it.name, r.citation, r.citation_html, r.year, r.pages, coalesce(i.page, citedby.page, '-')
from instance i
       join reference r on i.reference_id = r.id
       join instance_type it on i.instance_type_id = it.id
       left outer join instance citedby on i.cited_by_id = citedby.id
where i.name_id = nameid
group by r.id, i.id, it.id, citedby.id
order by r.year, it.protologue, it.primary_instance, r.citation, r.pages, i.page, r.id;
$$;

-- get the synonyms of an instance as html to store in the tree in apni synonymy order

drop function if exists synonym_as_html(bigint);
create function synonym_as_html(instanceid bigint)
  returns TABLE(html text)
language sql
as $$
SELECT CASE
         WHEN it.nomenclatural
                 THEN '<nom>' || full_name_html || '<name-status class="' || name_status|| '">, ' || name_status ||
                      '</name-status> <year>('|| year || ')<year> <type>' || instance_type || '</type></nom>'
         WHEN it.taxonomic
                 THEN '<tax>' || full_name_html || '<name-status class="' || name_status|| '">, ' || name_status ||
                      '</name-status> <year>('|| year || ')<year> <type>' || instance_type || '</type></tax>'
         WHEN it.misapplied
                 THEN '<mis>' || full_name_html || '<name-status class="' || name_status|| '">, ' || name_status ||
                      '</name-status><type>' || instance_type || '</type> by <citation>' ||
                      citation_html || '</citation></mis>'
         WHEN it.synonym
                 THEN '<syn>' || full_name_html || '<name-status class="' || name_status|| '">, ' || name_status ||
                      '</name-status> <year>('|| year || ')<year> <type>' || it.name || '</type></syn>'
         ELSE ''
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
DROP FUNCTION IF EXISTS synonyms_as_jsonb( BIGINT, TEXT );
CREATE FUNCTION synonyms_as_jsonb(instance_id BIGINT, host TEXT)
  RETURNS JSONB
LANGUAGE SQL
AS $$
SELECT jsonb_build_object('list',
                          coalesce(
                            jsonb_agg(jsonb_build_object(
                                        'host', host,
                                        'instance_id', syn_inst.id,
                                        'instance_link',
                                        '/instance/apni/' || syn_inst.id,
                                        'concept_link',
                                        '/instance/apni/' || cites_inst.id,
                                        'simple_name', synonym.simple_name,
                                        'type', it.name,
                                        'name_id', synonym.id :: BIGINT,
                                        'name_link',
                                        '/name/apni/' || synonym.id,
                                        'full_name_html', synonym.full_name_html,
                                        'nom', it.nomenclatural,
                                        'tax', it.taxonomic,
                                        'mis', it.misapplied,
                                        'cites', cites_ref.citation_html,
                                        'cites_link',
                                        '/reference/apni/' || cites_ref.id,
                                        'year', cites_ref.year
                                          )), '[]' :: JSONB)
           )
FROM Instance i,
     Instance syn_inst
       JOIN instance_type it ON syn_inst.instance_type_id = it.id
       JOIN instance cites_inst ON syn_inst.cites_id = cites_inst.id
       JOIN reference cites_ref ON cites_inst.reference_id = cites_ref.id
    ,
     name synonym
WHERE i.id = instance_id
  AND syn_inst.cited_by_id = i.id
  AND synonym.id = syn_inst.name_id;
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

-- Add apni_json field to name

alter table name add column apni_json jsonb;

-- add default mapper host to shard config (using tree.host_name
delete from shard_config where name = 'mapper host';
INSERT INTO shard_config (name, value, deprecated, use_notes)
    (select 'mapper host', t.host_name || '/' , false, 'The external host address for the mapper with a trailing slash' from tree t where t.accepted_tree);

-- re-write the synonymy html with new ordering - on current draft elements
-- this will include current published elements, but shouldn't change synonymy except if it has been changed within the
-- last 24 hours and not published.

update tree_element te
set synonyms_html = coalesce(synonyms_as_html(te.instance_id), '<synonyms></synonyms>')
from tree_version_element tve
       join tree_version tv on tve.tree_version_id = tv.id and tv.published = false
where tve.tree_element_id = te.id;

-- pre-emptive update of tree_element.display_html
update tree_element te
set display_html = '<data>' || n.full_name_html ||
                   '<name-status class="' || ns.name|| '">, ' || ns.name || '</name-status> <citation>' || r.citation_html || '</citation></data>'
from name n join name_status ns on n.name_status_id = ns.id,
     instance i, reference r
where te.name_id = n.id
  and te.instance_id = i.id
  and i.reference_id = r.id;

-- clean up bhl_urls that are blank

update instance set bhl_url = null where bhl_url = '';

-- update the cached_synonymy_html
update instance set cached_synonymy_html = coalesce(synonyms_as_html(id), '<synonyms></synonyms>') where id in (select distinct instance_id from tree_element);

-- NSL-3097 NSL-2884 update hybrid name_elements
update name set name_element = ne,  name_path = np || '/' || ne
from (select n.id, p1.name_path np, (p1.name_element || ' ' || nt.connector|| ' ' || p2.name_element) ne
      from name n
             join name_type nt on n.name_type_id = nt.id and nt.formula
             join name p1 on n.parent_id = p1.id
             join name p2 on n.second_parent_id = p2.id
      where p1.name_element <> '[unknown]'
        and p2.name_element <> '[unknown]'
        and (n.name_element is null or n.name_element = '[unknown]')) as hybrid
where name.id = hybrid.id
;

-- do it twice to catch the last 10 that were unknown parents
update name set name_element = ne,  name_path = np || '/' || ne
from (select n.id, p1.name_path np, (p1.name_element || ' ' || nt.connector|| ' ' || p2.name_element) ne
      from name n
             join name_type nt on n.name_type_id = nt.id and nt.formula
             join name p1 on n.parent_id = p1.id
             join name p2 on n.second_parent_id = p2.id
      where p1.name_element <> '[unknown]'
        and p2.name_element <> '[unknown]'
        and (n.name_element is null or n.name_element = '[unknown]')) as hybrid
where name.id = hybrid.id
;

delete from notification;

-- version
UPDATE db_version
SET version = 28
WHERE id = 1;
