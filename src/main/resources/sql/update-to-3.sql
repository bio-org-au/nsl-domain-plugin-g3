
-- note that the indexes are not unique. The mapping is that multiple records may collapse down to a single
-- rdf entity across shards and name groups.

-- the sequence of regexes in the update queries does:
-- convert to lcase, change all [nonletter, nondigit]+ to a dash, trim dashes of the start and end of the line
-- thus:
--   [N/A] -> [n/a] -> -n-a- -> n-a
--   nom. inval., opera utique oppressa -> nom-inval-opera-utique-oppressa


alter table name_group add column description_html text;
alter table name_group add column rdf_id varchar(50);
update name_group set
  rdf_id = regexp_replace(regexp_replace(regexp_replace(lower(name), '[^\w-]+', '-', 'g'), '^-+', ''), '-+$', ''),
  description_html = '(description of <b>'||name||'</b>)';
create index name_group_rdfId on name_group(rdf_id);

alter table name_category add column description_html text;
alter table name_category add column rdf_id varchar(50);
update name_category set
  rdf_id = regexp_replace(regexp_replace(regexp_replace(lower(name), '[^\w-]+', '-', 'g'), '^-+', ''), '-+$', ''),
  description_html = '(description of <b>'||name||'</b>)';
create index name_category_rdfId on name_category(rdf_id);

alter table namespace add column description_html text;
alter table namespace add column rdf_id varchar(50);
update namespace set
  rdf_id = regexp_replace(regexp_replace(regexp_replace(lower(name), '[^\w-]+', '-', 'g'), '^-+', ''), '-+$', ''),
  description_html = '(description of <b>'||name||'</b>)';
create index namespace_rdfId on namespace(rdf_id);

alter table nomenclatural_event_type add column description_html text;
alter table nomenclatural_event_type add column rdf_id varchar(50);
update nomenclatural_event_type set
  rdf_id = regexp_replace(regexp_replace(regexp_replace(lower(nomenclatural_event_type), '[^\w-]+', '-', 'g'), '^-+', ''), '-+$', ''),
  description_html = '(description of <b>'||nomenclatural_event_type||'</b>)';
create index nomenclatural_event_type_rdfId on nomenclatural_event_type(rdf_id);

alter table name_rank add column description_html text;
alter table name_rank add column rdf_id varchar(50);
update name_rank set
  rdf_id = regexp_replace(regexp_replace(regexp_replace(lower(name), '[^\w-]+', '-', 'g'), '^-+', ''), '-+$', ''),
  description_html = '(description of <b>'||name||'</b>)';
create index name_rank_rdfId on name_rank(rdf_id);

alter table name_status add column description_html text;
alter table name_status add column rdf_id varchar(50);
update name_status set
  rdf_id = regexp_replace(regexp_replace(regexp_replace(lower(name), '[^\w-]+', '-', 'g'), '^-+', ''), '-+$', ''),
  description_html = '(description of <b>'||name||'</b>)';
create index name_status_rdfId on name_status(rdf_id);

alter table name_type add column description_html text;
alter table name_type add column rdf_id varchar(50);
update name_type set
  rdf_id = regexp_replace(regexp_replace(regexp_replace(lower(name), '[^\w-]+', '-', 'g'), '^-+', ''), '-+$', ''),
  description_html = '(description of <b>'||name||'</b>)';
create index name_type_rdfId on name_type(rdf_id);

alter table ref_author_role add column description_html text;
alter table ref_author_role add column rdf_id varchar(50);
update ref_author_role set
  rdf_id = regexp_replace(regexp_replace(regexp_replace(lower(name), '[^\w-]+', '-', 'g'), '^-+', ''), '-+$', ''),
  description_html = '(description of <b>'||name||'</b>)';
create index ref_author_role_rdfId on ref_author_role(rdf_id);

alter table ref_type add column description_html text;
alter table ref_type add column rdf_id varchar(50);
update ref_type set
  rdf_id = regexp_replace(regexp_replace(regexp_replace(lower(name), '[^\w-]+', '-', 'g'), '^-+', ''), '-+$', ''),
  description_html = '(description of <b>'||name||'</b>)';
create index ref_type_rdfId on ref_type(rdf_id);

alter table instance_type add column description_html text;
alter table instance_type add column rdf_id varchar(50);
update instance_type set
  rdf_id = regexp_replace(regexp_replace(regexp_replace(lower(name), '[^\w-]+', '-', 'g'), '^-+', ''), '-+$', ''),
  description_html = '(description of <b>'||name||'</b>)';
create index instance_type_rdfId on instance_type(rdf_id);

alter table instance_note_key add column description_html text;
alter table instance_note_key add column rdf_id varchar(50);
update instance_note_key set
  rdf_id = regexp_replace(regexp_replace(regexp_replace(lower(name), '[^\w-]+', '-', 'g'), '^-+', ''), '-+$', ''),
  description_html = '(description of <b>'||name||'</b>)';
create index instance_note_key_rdfId on instance_note_key(rdf_id);

update db_version set version = 3 where id = 1;
