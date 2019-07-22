/*****
-- drop-uncited-names.sql
-- @ghwhitbread [20180820:]
-- Deleting as many names without instances as possible
-- Move uncited names, their comments and tags to schema "uncited"
-- tested @ taxamatics & apni test instance
******/

/*Deleting as many names without instances as possible*/
/* tested @ taxamatics & apni test instance */

-- begin;

create schema if not exists uncited authorization nsl;
comment on schema uncited is 'Archive of name records "uncited" by instance; along with name_tags and comments';

drop table if exists uncited.name_bkp;

create table uncited.name_bkp as select * from public.name;

comment on table uncited.name_bkp is 'All names prior to uncited cull';

drop table if exists uncited.apni;

create table uncited.apni as
  select id, family_id, parent_id, second_parent_id, duplicate_of_id from name
  where id in ( select name_id from instance);
comment on table uncited.apni is 'the names to remain';

drop table if exists uncited.name;

create table uncited.name
  as select * from name
  where not exists ( select 1 from instance where name_id = name.id );
comment on table uncited.name is 'All uncited names';

create index name_idx on uncited.name (id);

update name set
  parent_id = null,
  second_parent_id = null,
  duplicate_of_id = null
where id in ( select id from uncited.name);

update name set
  family_id = null
where id in ( select id from uncited.name)
and family_id in (select id from uncited.name);

drop table if exists uncited.all_links;
create table uncited.all_links
  as select distinct id, link, sp, rm from (
    select distinct id, family_id as link, 'f' as sp, FALSE as rm
     from name
    union all
     select distinct id, parent_id, 'p', FALSE
      from name
    union all
     select distinct id, second_parent_id, 's', FALSE
      from name
    union all
      select distinct id, duplicate_of_id, 'd', FALSE
     from name
    ) alinks where link is not null
;
comment on table uncited.all_links is 'All of the internal name references: parent, second_parent, family, duplicate';
create index all_links_idx on uncited.all_links (id);
create index all_links_link_idx on uncited.all_links (link);

drop table if exists uncited.unlinked_name;

create table uncited.unlinked_name
  as select * from uncited.name
  where not exists ( select 1 from uncited.all_links where link = name.id);
comment on table uncited.unlinked_name is 'No dependent links to clean up before deletion';

drop table if exists uncited.linked_name;

create table uncited.linked_name
  as select * from uncited.name
  where exists ( select 1 from uncited.all_links where link = name.id);
comment on table uncited.linked_name is 'uncited names with dependants';

create index linked_name_idx on uncited.linked_name (id);

drop table if exists uncited.name_tag_name;

create table uncited.name_tag_name as
  ( select * from name_tag_name ntn
  where exists (select 1 from uncited.unlinked_name na where na.id = ntn.name_id))
;
comment on table uncited.name_tag_name is 'The name_tag_names referencing uncited names';

delete from name_tag_name where name_id in ( select name_id from uncited.name_tag_name);

drop table if exists uncited.comment;

create table uncited.comment as
  select * from comment where name_id in
                              (select id from uncited.unlinked_name);
comment on table uncited.comment is 'The comments referencing uncited names';

delete from comment where name_id in ( select name_id from uncited.comment);

alter table name
  drop constraint fk_3pqdqa03w5c6h4yyrrvfuagos /* duplicate_of_id*/
;

alter table name
  drop constraint fk_5gp2lfblqq94c4ud3340iml0l /* second_parent_id */
;

alter table name
  drop constraint fk_dd33etb69v5w5iah1eeisy7yt
/*parent_id*/
;

alter table name
  drop constraint fk_whce6pgnqjtxgt67xy2lfo34 /*family_id*/
;

delete from name where id in ( select id from uncited.unlinked_name);

alter table name
  add constraint fk_3pqdqa03w5c6h4yyrrvfuagos
foreign key (duplicate_of_id) references name
  not deferrable
;

alter table name
  add constraint fk_5gp2lfblqq94c4ud3340iml0l
foreign key (second_parent_id) references name
  not deferrable
;

alter table name
  add constraint fk_dd33etb69v5w5iah1eeisy7yt
foreign key (parent_id) references name
  not deferrable
;

alter table name
  add constraint fk_whce6pgnqjtxgt67xy2lfo34
foreign key (family_id) references name
  not deferrable
;

-- commit;

-- vacuum analyze;
