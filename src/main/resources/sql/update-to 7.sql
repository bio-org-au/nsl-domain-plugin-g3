
alter table if exists nsl_simple_name
drop constraint if exists FK_lgtnu32ysbg6l2ys5d6bhfgmq;

alter table if exists nsl_simple_name
drop constraint if exists FK_on28vygd1e7aqn9owbhv3u23h;

alter table if exists nsl_simple_name
drop constraint if exists FK_ctg301hhg3x41rjl09d7noti1;

alter table if exists nsl_simple_name
drop constraint if exists FK_k4ryd8xarm9hhk1aitqtfg0tb;

alter table if exists nsl_simple_name
drop constraint if exists FK_bexlla3pvlm2x8err16puv16f;

alter table if exists nsl_simple_name
drop constraint if exists FK_gbcxpwubk8cdlh5fxnd3ln4up;

alter table if exists nsl_simple_name
drop constraint if exists FK_kquvd2hkcl7aj2vhylvp1k7vb;

alter table if exists nsl_simple_name
drop constraint if exists FK_mvjeehgt584v9ep11ixe1iyok;

alter table if exists nsl_simple_name
drop constraint if exists FK_rpqdbhi21sdix5tmmj5ul61su;

drop table if exists nsl_simple_name cascade;

create table nsl_simple_name (
  id int8 not null,
  apc_comment varchar(4000),
  apc_distribution varchar(4000),
  apc_excluded boolean default false not null,
  apc_familia varchar(255),
  apc_instance_id int8,
  apc_name varchar(512),
  apc_proparte boolean default false not null,
  apc_relationship_type varchar(255),
  apni boolean default false,
  author varchar(255),
  authority varchar(255),
  autonym boolean default false,
  base_name_author varchar(255),
  classifications varchar(255),
  classis varchar(255),
  created_at timestamp,
  created_by varchar(255),
  cultivar boolean default false not null,
  cultivar_name varchar(255),
  dup_of_id int8,
  ex_author varchar(255),
  ex_base_name_author varchar(255),
  familia varchar(255),
  family_nsl_id int8,
  formula boolean default false not null,
  full_name_html varchar(2048),
  genus varchar(255),
  genus_nsl_id int8,
  homonym boolean default false,
  hybrid boolean default false,
  infraspecies varchar(255),
  name varchar(255) not null,
  name_element varchar(255),
  name_rank_id int8 not null,
  name_status_id int8 not null,
  name_type_id int8 not null,
  name_type_name varchar(255) not null,
  nom_illeg boolean default false,
  nom_inval boolean default false,
  nom_stat varchar(255) not null,
  parent_nsl_id int8,
  proto_year int2,
  rank varchar(255) not null,
  rank_abbrev varchar(255),
  rank_sort_order int4,
  sanctioning_author varchar(255),
  scientific boolean default false,
  second_parent_nsl_id int8,
  simple_name_html varchar(2048),
  species varchar(255),
  species_nsl_id int8,
  subclassis varchar(255),
  taxon_name varchar(512) not null,
  updated_at timestamp,
  updated_by varchar(255),
  primary key (id)
);

alter table if exists nsl_simple_name
add constraint FK_lgtnu32ysbg6l2ys5d6bhfgmq
foreign key (apc_instance_id)
references instance;

alter table if exists nsl_simple_name
add constraint FK_on28vygd1e7aqn9owbhv3u23h
foreign key (family_nsl_id)
references name;

alter table if exists nsl_simple_name
add constraint FK_ctg301hhg3x41rjl09d7noti1
foreign key (genus_nsl_id)
references name;

alter table if exists nsl_simple_name
add constraint FK_k4ryd8xarm9hhk1aitqtfg0tb
foreign key (name_rank_id)
references name_rank;

alter table if exists nsl_simple_name
add constraint FK_bexlla3pvlm2x8err16puv16f
foreign key (name_status_id)
references name_status;

alter table if exists nsl_simple_name
add constraint FK_gbcxpwubk8cdlh5fxnd3ln4up
foreign key (name_type_id)
references name_type;

alter table if exists nsl_simple_name
add constraint FK_kquvd2hkcl7aj2vhylvp1k7vb
foreign key (parent_nsl_id)
references name;

alter table if exists nsl_simple_name
add constraint FK_mvjeehgt584v9ep11ixe1iyok
foreign key (second_parent_nsl_id)
references name;

alter table if exists nsl_simple_name
add constraint FK_rpqdbhi21sdix5tmmj5ul61su
foreign key (species_nsl_id)
references name;


-- fixing the column ordering in these indexes. Big effects on performance.

DROP INDEX idx_tree_node_taxon_in;
CREATE INDEX idx_tree_node_taxon_in ON tree_node (taxon_uri_id_part, taxon_uri_ns_part_id, tree_arrangement_id);

DROP INDEX idx_tree_node_name_in;
CREATE INDEX idx_tree_node_name_in ON tree_node (name_uri_id_part, name_uri_ns_part_id, tree_arrangement_id);

DROP INDEX idx_tree_node_resource_in;
CREATE INDEX idx_tree_node_resource_in ON tree_node (resource_uri_id_part, resource_uri_ns_part_id, tree_arrangement_id);

DROP INDEX idx_tree_node_name_id_in;
CREATE INDEX idx_tree_node_name_id_in ON tree_node (name_id, tree_arrangement_id);

DROP INDEX idx_tree_node_instance_id_in;
CREATE INDEX idx_tree_node_instance_id_in ON tree_node (instance_id, tree_arrangement_id);


UPDATE db_version
SET version = 7
WHERE id = 1;
