DROP MATERIALIZED VIEW IF EXISTS apc_taxon_view;
DROP MATERIALIZED VIEW IF EXISTS name_view;
DROP TABLE IF EXISTS name_tree_path;

CREATE TABLE name_tree_path (
  id           INT8 DEFAULT nextval('hibernate_sequence') NOT NULL,
  version      INT8                                       NOT NULL,
  inserted     INT8                                       NOT NULL,
  name_id      INT8                                       NOT NULL,
  name_id_path TEXT                                       NOT NULL,
  name_path    TEXT                                       NOT NULL,
  next_id      INT8,
  parent_id    INT8,
  rank_path    TEXT                                       NOT NULL,
  tree_id      INT8                                       NOT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX name_tree_path_treename_index ON name_tree_path (name_id, tree_id);
DROP INDEX IF EXISTS name_tree_path_treepath_index;

GRANT SELECT, INSERT, UPDATE, DELETE ON name_tree_path TO web;
GRANT SELECT ON name_tree_path TO read_only;

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX name_lower_full_name_gin_trgm ON name USING GIN (lower(full_name) gin_trgm_ops);
CREATE INDEX name_lower_simple_name_gin_trgm ON name USING GIN (lower(simple_name) gin_trgm_ops);
CREATE INDEX name_lower_unacent_full_name_gin_trgm ON name USING GIN (lower(f_unaccent(full_name)) gin_trgm_ops);
CREATE INDEX name_lower_unacent_simple_name_gin_trgm ON name USING GIN (lower(f_unaccent(simple_name)) gin_trgm_ops);

UPDATE db_version
SET version = 13
WHERE id = 1;
