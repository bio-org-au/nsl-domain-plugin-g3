drop index name_tree_path_path_index;
drop index name_tree_path_treepath_index;
drop index name_tree_path_name_index;

DROP TABLE name_tree_path;

create table name_tree_path (
  id int8 not null,
  version int8 not null,
  inserted int8 not null,
  name_id int8 not null,
  name_id_path TEXT not null,
  name_path TEXT not null,
  next_id int8,
  node_id_path TEXT not null,
  parent_id int8,
  rank_path TEXT not null,
  tree_id int8 not null,
  primary key (id)
);

create index name_tree_path_path_index on name_tree_path (name_id_path);
create index name_tree_path_treepath_index on name_tree_path (node_id_path);
create index name_tree_path_name_index on name_tree_path (name_id);

UPDATE db_version
SET version = 10
WHERE id = 1;
