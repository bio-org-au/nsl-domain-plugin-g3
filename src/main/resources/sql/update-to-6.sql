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

DROP TABLE nsl_simple_name;

CREATE TABLE nsl_simple_name (
  id                    INT8                  NOT NULL,
  apc_comment           VARCHAR(4000),
  apc_distribution      VARCHAR(4000),
  apc_excluded          BOOLEAN DEFAULT FALSE NOT NULL,
  apc_family            VARCHAR(255),
  apc_instance_id       INT8,
  apc_name              VARCHAR(512),
  apc_proparte          BOOLEAN DEFAULT FALSE NOT NULL,
  apc_relationship_type VARCHAR(255),
  apni                  BOOLEAN DEFAULT FALSE,
  author                VARCHAR(255),
  authority             VARCHAR(255),
  autonym               BOOLEAN DEFAULT FALSE,
  base_name_author      VARCHAR(255),
  classifications       VARCHAR(255),
  created_at            TIMESTAMP,
  created_by            VARCHAR(255),
  cultivar              BOOLEAN DEFAULT FALSE NOT NULL,
  cultivar_name         VARCHAR(255),
  dup_of_id             INT8,
  ex_author             VARCHAR(255),
  ex_base_name_author   VARCHAR(255),
  family                VARCHAR(255),
  family_nsl_id         INT8,
  formula               BOOLEAN DEFAULT FALSE NOT NULL,
  full_name_html        VARCHAR(2048),
  genus                 VARCHAR(255),
  genus_nsl_id          INT8,
  homonym               BOOLEAN DEFAULT FALSE,
  hybrid                BOOLEAN DEFAULT FALSE,
  infraspecies          VARCHAR(255),
  name                  VARCHAR(255)          NOT NULL,
  class                 VARCHAR(255),
  name_element          VARCHAR(255),
  name_rank_id          INT8                  NOT NULL,
  name_status_id        INT8                  NOT NULL,
  subclass              VARCHAR(255),
  name_type_id          INT8                  NOT NULL,
  name_type_name        VARCHAR(255)          NOT NULL,
  nom_illeg             BOOLEAN DEFAULT FALSE,
  nom_inval             BOOLEAN DEFAULT FALSE,
  nom_stat              VARCHAR(255)          NOT NULL,
  parent_nsl_id         INT8,
  proto_year            INT2,
  rank                  VARCHAR(255)          NOT NULL,
  rank_abbrev           VARCHAR(255),
  rank_sort_order       INT4,
  sanctioning_author    VARCHAR(255),
  scientific            BOOLEAN DEFAULT FALSE,
  second_parent_nsl_id  INT8,
  simple_name_html      VARCHAR(2048),
  species               VARCHAR(255),
  species_nsl_id        INT8,
  taxon_name            VARCHAR(512)          NOT NULL,
  updated_at            TIMESTAMP,
  updated_by            VARCHAR(255),
  PRIMARY KEY (id)
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

UPDATE db_version
SET version = 6
WHERE id = 1;
