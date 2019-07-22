ALTER TABLE name_tag ADD COLUMN lock_version INT8 DEFAULT 0 NOT NULL;
ALTER TABLE name_tag_name ADD COLUMN created_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE name_tag_name ADD COLUMN created_by VARCHAR(255);
ALTER TABLE name_tag_name ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE name_tag_name ADD COLUMN updated_by VARCHAR(255);

-- recreate nsl simple name
ALTER TABLE IF EXISTS nsl_simple_name
DROP CONSTRAINT IF EXISTS FK_on28vygd1e7aqn9owbhv3u23h;

ALTER TABLE IF EXISTS nsl_simple_name
DROP CONSTRAINT IF EXISTS FK_ctg301hhg3x41rjl09d7noti1;

ALTER TABLE IF EXISTS nsl_simple_name
DROP CONSTRAINT IF EXISTS FK_kquvd2hkcl7aj2vhylvp1k7vb;

ALTER TABLE IF EXISTS nsl_simple_name
DROP CONSTRAINT IF EXISTS FK_mvjeehgt584v9ep11ixe1iyok;

ALTER TABLE IF EXISTS nsl_simple_name
DROP CONSTRAINT IF EXISTS FK_rpqdbhi21sdix5tmmj5ul61su;

DROP TABLE nsl_simple_name;

CREATE TABLE nsl_simple_name (
  id                   INT8                  NOT NULL,
  apc_family           VARCHAR(255),
  apni                 BOOLEAN DEFAULT FALSE,
  author               VARCHAR(255),
  authority            VARCHAR(255),
  autonym              BOOLEAN DEFAULT FALSE,
  base_name_author     VARCHAR(255),
  classifications      VARCHAR(255),
  created_at           TIMESTAMP,
  created_by           VARCHAR(255),
  cultivar             BOOLEAN DEFAULT FALSE NOT NULL,
  cultivar_name        VARCHAR(255),
  dup_of_id            INT8,
  ex_author            VARCHAR(255),
  ex_base_name_author  VARCHAR(255),
  family               VARCHAR(255),
  family_nsl_id        INT8,
  formula              BOOLEAN DEFAULT FALSE NOT NULL,
  full_name_html       VARCHAR(2048),
  genus                VARCHAR(255),
  genus_nsl_id         INT8,
  homonym              BOOLEAN DEFAULT FALSE,
  hybrid               BOOLEAN DEFAULT FALSE,
  infraspecies         VARCHAR(255),
  name                 VARCHAR(255)          NOT NULL,
  class                VARCHAR(255),
  name_element         VARCHAR(255),
  name_rank_id         INT8                  NOT NULL,
  name_status_id       INT8                  NOT NULL,
  subclass             VARCHAR(255),
  name_type_id         INT8                  NOT NULL,
  name_type_name       VARCHAR(255)          NOT NULL,
  nom_illeg            BOOLEAN DEFAULT FALSE,
  nom_inval            BOOLEAN DEFAULT FALSE,
  nom_stat             VARCHAR(255)          NOT NULL,
  parent_nsl_id        INT8,
  proto_year           INT2,
  rank                 VARCHAR(255)          NOT NULL,
  rank_abbrev          VARCHAR(255),
  rank_sort_order      INT4,
  sanctioning_author   VARCHAR(255),
  scientific           BOOLEAN DEFAULT FALSE,
  second_parent_nsl_id INT8,
  simple_name_html     VARCHAR(2048),
  species              VARCHAR(255),
  species_nsl_id       INT8,
  taxon_name           VARCHAR(512)          NOT NULL,
  updated_at           TIMESTAMP,
  updated_by           VARCHAR(255),
  PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS nsl_simple_name
ADD CONSTRAINT FK_on28vygd1e7aqn9owbhv3u23h
FOREIGN KEY (family_nsl_id)
REFERENCES name;

ALTER TABLE IF EXISTS nsl_simple_name
ADD CONSTRAINT FK_ctg301hhg3x41rjl09d7noti1
FOREIGN KEY (genus_nsl_id)
REFERENCES name;

ALTER TABLE IF EXISTS nsl_simple_name
ADD CONSTRAINT FK_k4ryd8xarm9hhk1aitqtfg0tb
FOREIGN KEY (name_rank_id)
REFERENCES name_rank;

ALTER TABLE IF EXISTS nsl_simple_name
ADD CONSTRAINT FK_bexlla3pvlm2x8err16puv16f
FOREIGN KEY (name_status_id)
REFERENCES name_status;

ALTER TABLE IF EXISTS nsl_simple_name
ADD CONSTRAINT FK_gbcxpwubk8cdlh5fxnd3ln4up
FOREIGN KEY (name_type_id)
REFERENCES name_type;

ALTER TABLE IF EXISTS nsl_simple_name
ADD CONSTRAINT FK_kquvd2hkcl7aj2vhylvp1k7vb
FOREIGN KEY (parent_nsl_id)
REFERENCES name;

ALTER TABLE IF EXISTS nsl_simple_name
ADD CONSTRAINT FK_mvjeehgt584v9ep11ixe1iyok
FOREIGN KEY (second_parent_nsl_id)
REFERENCES name;

ALTER TABLE IF EXISTS nsl_simple_name
ADD CONSTRAINT FK_rpqdbhi21sdix5tmmj5ul61su
FOREIGN KEY (species_nsl_id)
REFERENCES name;

GRANT SELECT, INSERT, UPDATE, DELETE ON nsl_simple_name TO web;

UPDATE name_tag_name
SET created_at = now();
UPDATE name_tag_name
SET updated_at = now();
UPDATE name_tag_name
SET created_by = 'NSL-929 update 4';
UPDATE name_tag_name
SET updated_by = 'NSL-1007 update 5';


ALTER TABLE tree_node
DROP CONSTRAINT IF EXISTS FK_1g9477sa8plad5cxkxmiuh5b;

ALTER TABLE tree_node
DROP CONSTRAINT IF EXISTS FK_eqw4xo7vty6e4tq8hy34c51om;

ALTER TABLE tree_node
ADD name_id INT8,
ADD instance_id INT8;

CREATE INDEX idx_tree_node_instance_id ON tree_node (instance_id);
CREATE INDEX idx_tree_node_instance_id_in ON tree_node (instance_id, tree_arrangement_id);
CREATE INDEX idx_tree_node_name_id ON tree_node (name_id);
CREATE INDEX idx_tree_node_name_id_in ON tree_node (name_id, tree_arrangement_id);

ALTER TABLE tree_node
ADD CONSTRAINT FK_eqw4xo7vty6e4tq8hy34c51om
FOREIGN KEY (name_id)
REFERENCES name;

ALTER TABLE tree_node
ADD CONSTRAINT FK_1g9477sa8plad5cxkxmiuh5b
FOREIGN KEY (instance_id)
REFERENCES instance;

ALTER TABLE tree_node
ADD CONSTRAINT chk_tree_node_name_matches
CHECK (name_id IS NULL OR
       cast(name_id AS VARCHAR) = name_uri_id_part);

ALTER TABLE tree_node
ADD CONSTRAINT chk_tree_node_instance_matches
CHECK (instance_id IS NULL OR
       cast(instance_id AS VARCHAR) =
       taxon_uri_id_part);


-- part 2 after applications up to date

ALTER TABLE name_tag_name ALTER COLUMN created_at SET NOT NULL;
ALTER TABLE name_tag_name ALTER COLUMN created_by SET NOT NULL;
ALTER TABLE name_tag_name ALTER COLUMN updated_at SET NOT NULL;
ALTER TABLE name_tag_name ALTER COLUMN updated_by SET NOT NULL;
ALTER TABLE name_tag DROP COLUMN version;

UPDATE tree_node
SET name_id = cast(name_uri_id_part AS INT8)
WHERE name_id IS NULL
      AND name_uri_ns_part_id = (SELECT id
                                 FROM tree_uri_ns
                                 WHERE label = 'nsl-name')
      AND exists(SELECT 1
                 FROM name
                 WHERE id = cast(name_uri_id_part AS INT8));

UPDATE tree_node
SET instance_id = cast(taxon_uri_id_part AS INT8)
WHERE instance_id IS NULL
      AND taxon_uri_ns_part_id = (SELECT id
                                  FROM tree_uri_ns
                                  WHERE label = 'nsl-instance')
      AND exists(SELECT 1
                 FROM instance
                 WHERE id = cast(taxon_uri_id_part AS INT8));


UPDATE db_version
SET version = 5
WHERE id = 1;
