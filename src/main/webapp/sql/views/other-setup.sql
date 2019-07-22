--other setup
ALTER TABLE instance
  ADD CONSTRAINT citescheck CHECK (cites_id IS NULL OR cited_by_id IS NOT NULL);

ALTER TABLE instance
  ADD CONSTRAINT no_duplicate_synonyms UNIQUE (name_id, reference_id, instance_type_id, page, cites_id, cited_by_id);

CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE OR REPLACE FUNCTION f_unaccent(TEXT)
  RETURNS TEXT AS
$func$
SELECT unaccent('unaccent', $1)
$func$ LANGUAGE SQL IMMUTABLE SET search_path = public, pg_temp;

CREATE INDEX name_lower_f_unaccent_full_name_like
  ON name (lower(f_unaccent(full_name)) varchar_pattern_ops);
CREATE INDEX ref_citation_text_index
  ON reference USING GIN (to_tsvector('english' :: REGCONFIG, f_unaccent(
      coalesce((citation) :: TEXT, '' :: TEXT))));

-- add unique constraint on name_rank, name_type and name_status name+nameGroup
-- GORM/Hibernate mapping doesn't set a unique constraint name so it fails in postgresql
alter table name_rank drop constraint if exists nr_unique_name;
alter table name_rank add constraint nr_unique_name unique (name_group_id, name);

alter table name_type drop constraint if exists nt_unique_name;
alter table name_type add constraint nt_unique_name unique (name_group_id, name);

alter table name_status drop constraint if exists ns_unique_name;
alter table name_status add constraint ns_unique_name unique (name_group_id, name);

alter table name add constraint published_year_limits check (published_year > 1700 and published_year < 2500);

-- pg_trgm indexs for like and regex queries NSL-1773
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX name_lower_full_name_gin_trgm
  ON name USING GIN (lower(full_name) gin_trgm_ops);
CREATE INDEX name_lower_simple_name_gin_trgm
  ON name USING GIN (lower(simple_name) gin_trgm_ops);
CREATE INDEX name_lower_unacent_full_name_gin_trgm
  ON name USING GIN (lower(f_unaccent(full_name)) gin_trgm_ops);
CREATE INDEX name_lower_unacent_simple_name_gin_trgm
  ON name USING GIN (lower(f_unaccent(simple_name)) gin_trgm_ops);

-- new tree GIN indexes
DROP INDEX IF EXISTS tree_synonyms_index;
CREATE INDEX tree_synonyms_index
  ON tree_element USING GIN (synonyms);

-- tree make sure the draft is not also the current version.
ALTER TABLE tree
  ADD CONSTRAINT draft_not_current CHECK (current_tree_version_id <> default_draft_tree_version_id);
--

-- make sure a set of distributions only contains a region once
alter table dist_entry add constraint de_unique_region unique (region_id, tree_element_id);

INSERT INTO db_version (id, version) VALUES (1, 33);
