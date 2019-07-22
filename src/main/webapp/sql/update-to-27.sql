--drop old tree stuff

drop index if exists by_root_id;
drop index if exists idx_node_current_a;
drop index if exists idx_node_current_b;
drop index if exists idx_node_current_instance_a;
drop index if exists idx_node_current_instance_b;
drop index if exists idx_node_current_name_a;
drop index if exists idx_node_current_name_b;
drop index if exists idx_tree_link_seq;
drop index if exists idx_tree_node_instance_id;
drop index if exists idx_tree_node_instance_id_in;
drop index if exists idx_tree_node_literal;
drop index if exists idx_tree_node_name;
drop index if exists idx_tree_node_name_id;
drop index if exists idx_tree_node_name_id_in;
drop index if exists idx_tree_node_name_in;
drop index if exists idx_tree_node_resource;
drop index if exists idx_tree_node_resource_in;
drop index if exists idx_tree_node_taxon;
drop index if exists idx_tree_node_taxon_in;
drop index if exists idx_tree_uri_ns_label;
drop index if exists idx_tree_uri_ns_uri;
drop index if exists link_uri_index;
drop index if exists node_uri_index;
drop index if exists tree_arrangement_label;
drop index if exists tree_arrangement_node;
drop index if exists tree_link_subnode;
drop index if exists tree_link_supernode;
drop index if exists tree_node_next;
drop index if exists tree_node_prev;

drop function if exists is_instance_in_tree(BIGINT, BIGINT);
drop function if exists find_name_in_tree(bigint, bigint);
drop function if exists current_workspace_taxonomic_nodes(bigint);
drop function if exists draft_nodes_below_this_node(bigint);
drop view if exists name_or_synonym_vw;

alter table if exists tree_arrangement
  drop constraint if exists FK_akuqsiv75wpw6mk3m8gj6g30m;

alter table if exists tree_arrangement
  drop constraint if exists FK_skqp6co7fy5lcq0qts3yghy02;

alter table if exists tree_arrangement
  drop constraint if exists FK_fvfq13j3dqv994o9vg54yj5kk;

alter table if exists tree_event
  drop constraint if exists FK_7y8cj9fpsh1sblm744xuq6i1g;

alter table if exists tree_link
  drop constraint if exists FK_tgankaahxgr4p0mw4opafah05;

alter table if exists tree_link
  drop constraint if exists FK_kqshktm171nwvk38ot4d12w6b;

alter table if exists tree_link
  drop constraint if exists FK_2dk33tolvn16lfmp25nk2584y;

alter table if exists tree_node
  drop constraint if exists FK_nlq0qddnhgx65iojhj2xm8tay;

alter table if exists tree_node
  drop constraint if exists FK_1g9477sa8plad5cxkxmiuh5b;

alter table if exists tree_node
  drop constraint if exists FK_eqw4xo7vty6e4tq8hy34c51om;

alter table if exists tree_node
  drop constraint if exists FK_gc6f9ykh7eaflvty9tr6n4cb6;

alter table if exists tree_node
  drop constraint if exists FK_sbuntfo4jfai44yjh9o09vu6s;

alter table if exists tree_node
  drop constraint if exists FK_budb70h51jhcxe7qbtpea0hi2;

alter table if exists tree_node
  drop constraint if exists FK_pc0tkp9bgp1cxull530y60v46;

alter table if exists tree_node
  drop constraint if exists FK_4y1qy9beekbv71e9i6hto6hun;

alter table if exists tree_node
  drop constraint if exists FK_t6kkvm8ubsiw6fqg473j0gjga;

alter table if exists tree_node
  drop constraint if exists FK_16c4wgya68bwotwn6f50dhw69;

alter table if exists tree_node
  drop constraint if exists FK_oge4ibjd3ff3oyshexl6set2u;

alter table if exists tree_uri_ns
  drop constraint if exists FK_q9k8he941kvl07j2htmqxq35v;

alter table if exists tree_value_uri
  drop constraint if exists FK_ds3bc89iy6q3ts4ts85mqiys;

alter table if exists tree_value_uri
  drop constraint if exists FK_djkn41tin6shkjuut9nam9xvn;

alter table if exists tree_value_uri
  drop constraint if exists FK_nw785lqesvg8ntfaper0tw2vs;

drop table if exists tree_arrangement cascade;
drop table if exists tree_event cascade;
drop table if exists tree_link cascade;
drop table if exists tree_node cascade;
drop table if exists tree_uri_ns cascade;
drop table if exists tree_value_uri cascade;

-- clean up unused fields and constraints
drop index if exists Name_whyIsThisHere_Index;

alter table if exists name
  drop constraint if exists FK_dqhn53mdh0n77xhsw7l5dgd38;
alter table if exists nomenclatural_event_type
  drop constraint if exists FK_ql5g85814a9y57c1ifd0nkq3v;

drop table if exists help_topic cascade;
drop table if exists locale cascade;
drop table if exists nomenclatural_event_type cascade;
drop table if exists user_query cascade;
drop table if exists why_is_this_here cascade;

alter table author drop column if exists trash;
alter table reference drop column if exists trash;
alter table instance drop column if exists trash;
alter table instance_note drop column if exists trash;
alter table name drop column if exists trash;
alter table name drop column if exists why_is_this_here_id;

--create new name_rank display_name column
alter table name_rank drop column if exists display_name;
alter table name_rank add column display_name text;
update name_rank set display_name = name;
alter table name_rank alter column display_name set not null;

alter table name_rank drop constraint if exists nr_unique_name;
alter table name_rank add constraint nr_unique_name unique (name_group_id, name);

-- change constraint on name_type and name_status
alter table name_type drop constraint if exists UK_314uhkq8i7r46050kd1nfrs95;
alter table name_type drop constraint if exists nt_unique_name;
alter table name_type add constraint nt_unique_name unique (name_group_id, name);

alter table name_status drop constraint if exists UK_se7crmfnhjmyvirp3p9hiqerx;
alter table name_status drop constraint if exists ns_unique_name;
alter table name_status add constraint ns_unique_name unique (name_group_id, name);
-- version
UPDATE db_version
SET version = 27
WHERE id = 1;
