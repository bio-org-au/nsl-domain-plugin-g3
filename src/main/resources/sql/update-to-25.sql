vacuum analyse;
DROP VIEW IF EXISTS public.workspace_value_namespace_vw;
DROP VIEW IF EXISTS public.workspace_instance_value_vw;
DROP VIEW IF EXISTS public.workspace_value_vw;
DROP VIEW IF EXISTS public.accepted_synonym_vw;
DROP VIEW IF EXISTS public.accepted_name_vw;
DROP MATERIALIZED VIEW IF EXISTS public.name_view;
DROP MATERIALIZED VIEW IF EXISTS public.taxon_view;

-- new tree structure
DROP INDEX IF EXISTS tree_simple_name_index;
DROP INDEX IF EXISTS tree_name_path_index;
DROP INDEX IF EXISTS tree_tree_path_index;
DROP INDEX IF EXISTS instance_path_index;
DROP INDEX IF EXISTS tree_synonyms_index;
DROP INDEX IF EXISTS tree_version_element_element_index;
DROP INDEX IF EXISTS tree_version_element_version_index;
DROP INDEX IF EXISTS tree_version_element_taxon_id_index;
DROP INDEX IF EXISTS tree_version_element_taxon_link_index;

ALTER TABLE IF EXISTS name
  DROP CONSTRAINT IF EXISTS FK_whce6pgnqjtxgt67xy2lfo34;

ALTER TABLE IF EXISTS tree
  DROP CONSTRAINT IF EXISTS FK_svg2ee45qvpomoer2otdc5oyc;

ALTER TABLE IF EXISTS tree
  DROP CONSTRAINT IF EXISTS FK_48skgw51tamg6ud4qa8oh0ycm;

ALTER TABLE IF EXISTS tree_version
  DROP CONSTRAINT IF EXISTS FK_tiniptsqbb5fgygt1idm1isfy;

ALTER TABLE IF EXISTS tree_version
  DROP CONSTRAINT IF EXISTS FK_4q3huja5dv8t9xyvt5rg83a35;

ALTER TABLE IF EXISTS tree_element
  DROP CONSTRAINT IF EXISTS FK_eoywd7l5fhjpjgn461r6ni2ak;

ALTER TABLE IF EXISTS tree_element
  DROP CONSTRAINT IF EXISTS FK_5sv181ivf7oybb6hud16ptmo5;

ALTER TABLE IF EXISTS tree_version_element
  DROP CONSTRAINT IF EXISTS FK_ufme7yt6bqyf3uxvuvouowhh;

ALTER TABLE IF EXISTS tree_version_element
  DROP CONSTRAINT IF EXISTS FK_80khvm60q13xwqgpy43twlnoe;

ALTER TABLE IF EXISTS tree_version_element
  DROP CONSTRAINT IF EXISTS FK_8nnhwv8ldi9ppol6tg4uwn4qv;

DROP TABLE IF EXISTS distribution;
CREATE TABLE distribution (
  id                        INT8 DEFAULT nextval('nsl_global_seq') NOT NULL,
  lock_version              INT8 DEFAULT 0                         NOT NULL,
  description               VARCHAR(100)                           NOT NULL,
  is_doubtfully_naturalised BOOLEAN DEFAULT FALSE                  NOT NULL,
  is_extinct                BOOLEAN DEFAULT FALSE                  NOT NULL,
  is_native                 BOOLEAN DEFAULT FALSE                  NOT NULL,
  is_naturalised            BOOLEAN DEFAULT FALSE                  NOT NULL,
  region                    VARCHAR(10)                            NOT NULL,
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS tree;
CREATE TABLE tree (
  id                            INT8 DEFAULT nextval('nsl_global_seq') NOT NULL,
  lock_version                  INT8 DEFAULT 0                         NOT NULL,
  accepted_tree                 BOOLEAN DEFAULT FALSE                  NOT NULL,
  config                        JSONB,
  current_tree_version_id       INT8,
  default_draft_tree_version_id INT8,
  description_html              TEXT DEFAULT 'Edit me'                 NOT NULL,
  group_name                    TEXT                                   NOT NULL,
  host_name                     TEXT                                   NOT NULL,
  link_to_home_page             TEXT,
  name                          TEXT                                   NOT NULL,
  reference_id                  INT8,
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS tree_version;
CREATE TABLE tree_version (
  id                  INT8 DEFAULT nextval('nsl_global_seq') NOT NULL,
  lock_version        INT8 DEFAULT 0                         NOT NULL,
  created_at          TIMESTAMP WITH TIME ZONE               NOT NULL,
  created_by          VARCHAR(255)                           NOT NULL,
  draft_name          TEXT                                   NOT NULL,
  log_entry           TEXT,
  previous_version_id INT8,
  published           BOOLEAN DEFAULT FALSE                  NOT NULL,
  published_at        TIMESTAMP WITH TIME ZONE,
  published_by        VARCHAR(100),
  tree_id             INT8                                   NOT NULL,
  PRIMARY KEY (id)
);
DROP TABLE IF EXISTS tree_element;
CREATE TABLE tree_element (
  id                  INT8 DEFAULT nextval('nsl_global_seq') NOT NULL,
  lock_version        INT8 DEFAULT 0                         NOT NULL,
  display_html        TEXT                                   NOT NULL,
  excluded            BOOLEAN DEFAULT FALSE                  NOT NULL,
  instance_id         INT8                                   NOT NULL,
  instance_link       TEXT                                   NOT NULL,
  name_element        VARCHAR(255)                           NOT NULL,
  name_id             INT8                                   NOT NULL,
  name_link           TEXT                                   NOT NULL,
  previous_element_id INT8,
  profile             JSONB,
  rank                VARCHAR(50)                            NOT NULL,
  simple_name         TEXT                                   NOT NULL,
  source_element_link TEXT,
  source_shard        TEXT                                   NOT NULL,
  synonyms            JSONB,
  synonyms_html       TEXT                                   NOT NULL,
  updated_at          TIMESTAMP WITH TIME ZONE               NOT NULL,
  updated_by          VARCHAR(255)                           NOT NULL,
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS tree_version_element;
CREATE TABLE tree_version_element (
  element_link    TEXT                     NOT NULL,
  depth           INT4                     NOT NULL,
  name_path       TEXT                     NOT NULL,
  parent_id       TEXT,
  taxon_id        INT8                     NOT NULL,
  taxon_link      TEXT                     NOT NULL,
  tree_element_id INT8                     NOT NULL,
  tree_path       TEXT                     NOT NULL,
  tree_version_id INT8                     NOT NULL,
  updated_at      TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_by      VARCHAR(255)             NOT NULL,
  PRIMARY KEY (element_link)
);

DROP TABLE IF EXISTS event_record;
create table event_record (
  id         int8                     not null,
  version    int8                     not null,
  created_at timestamp with time zone not null,
  created_by varchar(50)              not null,
  data       jsonb,
  dealt_with boolean default false    not null,
  type       text                     not null,
  updated_at timestamp with time zone not null,
  updated_by varchar(50)              not null,
  primary key (id)
);

ALTER TABLE name
  ADD COLUMN family_id INT8;
ALTER TABLE name
  ADD COLUMN name_path TEXT DEFAULT '' NOT NULL;

ALTER TABLE IF EXISTS tree
  ADD CONSTRAINT FK_svg2ee45qvpomoer2otdc5oyc
FOREIGN KEY (current_tree_version_id)
REFERENCES tree_version;

ALTER TABLE IF EXISTS tree
  ADD CONSTRAINT FK_48skgw51tamg6ud4qa8oh0ycm
FOREIGN KEY (default_draft_tree_version_id)
REFERENCES tree_version;

ALTER TABLE IF EXISTS tree_element
  ADD CONSTRAINT FK_5sv181ivf7oybb6hud16ptmo5
FOREIGN KEY (previous_element_id)
REFERENCES tree_element;

ALTER TABLE IF EXISTS tree_version
  ADD CONSTRAINT FK_tiniptsqbb5fgygt1idm1isfy
FOREIGN KEY (previous_version_id)
REFERENCES tree_version;

ALTER TABLE IF EXISTS tree_version
  ADD CONSTRAINT FK_4q3huja5dv8t9xyvt5rg83a35
FOREIGN KEY (tree_id)
REFERENCES tree;

ALTER TABLE IF EXISTS name
  ADD CONSTRAINT FK_whce6pgnqjtxgt67xy2lfo34
FOREIGN KEY (family_id)
REFERENCES name;

ALTER TABLE IF EXISTS tree_version_element
  ADD CONSTRAINT FK_ufme7yt6bqyf3uxvuvouowhh
FOREIGN KEY (tree_element_id)
REFERENCES tree_element;

ALTER TABLE IF EXISTS tree_version_element
  ADD CONSTRAINT FK_80khvm60q13xwqgpy43twlnoe
FOREIGN KEY (tree_version_id)
REFERENCES tree_version;

ALTER TABLE IF EXISTS tree_version_element
  ADD CONSTRAINT FK_8nnhwv8ldi9ppol6tg4uwn4qv
FOREIGN KEY (parent_id)
REFERENCES tree_version_element;

CREATE INDEX tree_version_element_link_index
  ON tree_version_element (element_link);

CREATE INDEX tree_version_element_parent_index
  ON tree_version_element (parent_id);

CREATE INDEX tree_simple_name_index
  ON tree_element (simple_name);

CREATE INDEX tree_path_index
  ON tree_version_element (tree_path);

CREATE INDEX tree_version_element_element_index
  ON tree_version_element (tree_element_id);

CREATE INDEX tree_version_element_version_index
  ON tree_version_element (tree_version_id);

CREATE INDEX tree_version_element_taxon_id_index
  ON tree_version_element (taxon_id);

CREATE INDEX tree_version_element_taxon_link_index
  ON tree_version_element (taxon_link);

CREATE INDEX tree_name_path_index
  ON tree_version_element (name_path);

CREATE INDEX tree_element_instance_index
  ON tree_element (instance_id);

CREATE INDEX tree_element_name_index
  ON tree_element (name_id);

CREATE INDEX tree_element_previous_index
  ON tree_element (previous_element_id);

CREATE INDEX tree_synonyms_index
  ON tree_element
  USING GIN (synonyms);

create index event_record_created_index
  on event_record (created_at);

create index event_record_index
  on event_record (created_at, dealt_with, type);

create index event_record_dealt_index
  on event_record (dealt_with);

create index event_record_type_index
  on event_record (type);

-- new tree make sure the draft is not also the current version.
ALTER TABLE tree
  ADD CONSTRAINT draft_not_current CHECK (current_tree_version_id <> default_draft_tree_version_id);

-- add default grants for the web user
GRANT SELECT, INSERT, UPDATE, DELETE ON tree TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON tree_version TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON tree_version_element TO ${webUserName};
GRANT SELECT, INSERT, UPDATE, DELETE ON tree_element TO ${webUserName};

-- add Instance change trigger
CREATE OR REPLACE FUNCTION instance_notification()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE')
  THEN
    INSERT INTO notification (id, version, message, object_id)
      SELECT
        nextval('hibernate_sequence'),
        0,
        'instance deleted',
        OLD.id;
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE')
    THEN
      INSERT INTO notification (id, version, message, object_id)
        SELECT
          nextval('hibernate_sequence'),
          0,
          'instance updated',
          NEW.id;
      RETURN NEW;
  ELSIF (TG_OP = 'INSERT')
    THEN
      INSERT INTO notification (id, version, message, object_id)
        SELECT
          nextval('hibernate_sequence'),
          0,
          'instance created',
          NEW.id;
      RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER instance_update
  AFTER INSERT OR UPDATE OR DELETE
  ON instance
  FOR EACH ROW
EXECUTE PROCEDURE instance_notification();

-- import old tree data into the new structure
vacuum analyse;

-- get current classification-root and follow the prev links back to find versions back to jan 2016
DROP FUNCTION IF EXISTS daily_top_nodes( TEXT, TIMESTAMP );
CREATE FUNCTION daily_top_nodes(tree_label TEXT, since TIMESTAMP)
  RETURNS TABLE(latest_node_id BIGINT, year DOUBLE PRECISION, month DOUBLE PRECISION, day DOUBLE PRECISION)
LANGUAGE SQL
AS $$

WITH RECURSIVE treewalk AS (
  SELECT class_root.*
  FROM tree_node class_node
    JOIN tree_arrangement a ON class_node.id = a.node_id AND a.label = tree_label
    JOIN tree_link sublink ON class_node.id = sublink.supernode_id
    JOIN tree_node class_root ON sublink.subnode_id = class_root.id
  UNION ALL
  SELECT node.*
  FROM treewalk
    JOIN tree_node node ON treewalk.prev_node_id = node.id
)
SELECT
  max(tw.id) AS latest_node_id,
  year,
  month,
  day
FROM treewalk tw
  JOIN tree_event event ON tw.checked_in_at_id = event.id
  ,
      extract(YEAR FROM event.time_stamp) AS year,
      extract(MONTH FROM event.time_stamp) AS month,
      extract(DAY FROM event.time_stamp) AS day
WHERE event.time_stamp > since
GROUP BY year, month, day
ORDER BY latest_node_id ASC
$$;

DROP FUNCTION IF EXISTS tree_element_data_from_start_node( BIGINT );
CREATE FUNCTION tree_element_data_from_start_node(root_node BIGINT)
  RETURNS TABLE(tree_id     BIGINT, node_id BIGINT, excluded BOOLEAN, declared_bt BOOLEAN, instance_id BIGINT, name_id BIGINT,
                simple_name TEXT, name_path TEXT, instance_path TEXT, parent_instance_path TEXT, parent_excluded BOOLEAN,
                depth       INT4)
LANGUAGE SQL
AS $$
WITH RECURSIVE treewalk (tree_id, node_id, excluded, declared_bt, instance_id, name_id, simple_name, name_path, instance_path,
    parent_instance_path, parent_excluded, depth) AS (
  SELECT
    tree.id                   AS tree_id,
    node.id                   AS node_id,
    (node.type_uri_id_part <>
     'ApcConcept') :: BOOLEAN AS excluded,
    (node.type_uri_id_part =
     'DeclaredBt') :: BOOLEAN AS declared_bt,
    node.instance_id          AS instance_id,
    node.name_id              AS name_id,
    n.simple_name :: TEXT     AS simple_name,
    coalesce(n.name_element,
             '?')             AS name_path,
    CASE
    WHEN (node.type_uri_id_part = 'ApcConcept')
      THEN
        node.instance_id :: TEXT
    WHEN (node.type_uri_id_part = 'DeclaredBt')
      THEN
        'b' || node.instance_id :: TEXT
    ELSE
      'x' || node.instance_id :: TEXT
    END                       AS instance_path,
    ''                        AS parent_instance_path,
    FALSE                     AS parent_excluded,
    1                         AS depth
  FROM tree_link link
    JOIN tree_node node ON link.subnode_id = node.id
    JOIN tree_arrangement tree ON node.tree_arrangement_id = tree.id
    JOIN name n ON node.name_id = n.id
    JOIN name_rank rank ON n.name_rank_id = rank.id
    JOIN instance inst ON node.instance_id = inst.id
    JOIN reference ref ON inst.reference_id = ref.id
  WHERE link.supernode_id = root_node
        AND node.internal_type = 'T'
  UNION ALL
  SELECT
    treewalk.tree_id                           AS tree_id,
    node.id                                    AS node_id,
    (node.type_uri_id_part <>
     'ApcConcept') :: BOOLEAN                  AS excluded,
    (node.type_uri_id_part =
     'DeclaredBt') :: BOOLEAN                  AS declared_bt,
    node.instance_id                           AS instance_id,
    node.name_id                               AS name_id,
    n.simple_name :: TEXT                      AS simple_name,
    treewalk.name_path || '/' || COALESCE(n.name_element,
                                          '?') AS name_path,
    CASE
    WHEN (node.type_uri_id_part = 'ApcConcept')
      THEN
        treewalk.instance_path || '/' || node.instance_id :: TEXT
    WHEN (node.type_uri_id_part = 'DeclaredBt')
      THEN
        treewalk.instance_path || '/b' || node.instance_id :: TEXT
    ELSE
      treewalk.instance_path || '/x' || node.instance_id :: TEXT
    END                                        AS instance_path,
    treewalk.instance_path                     AS parent_instance_path,
    treewalk.excluded                          AS parent_excluded,
    treewalk.depth + 1                         AS depth
  FROM treewalk
    JOIN tree_link link ON link.supernode_id = treewalk.node_id
    JOIN tree_node node ON link.subnode_id = node.id
    JOIN name n ON node.name_id = n.id
    JOIN name_rank rank ON n.name_rank_id = rank.id
    JOIN instance inst ON node.instance_id = inst.id
    JOIN reference REF ON inst.reference_id = REF.id
  WHERE node.internal_type = 'T'
        AND node.tree_arrangement_id = treewalk.tree_id
)
SELECT
  tree_id,
  node_id,
  excluded,
  declared_bt,
  instance_id,
  name_id,
  simple_name,
  name_path,
  instance_path,
  parent_instance_path,
  parent_excluded,
  depth
FROM treewalk
$$;

-- ************ build new tree data *******************

INSERT INTO tree (group_name, name, config, description_html, accepted_tree, host_name)
VALUES ('treebuilder',
        '${classificationTreeName}',
        '{
          "distribution_key": "${classificationTreeName} Dist.",
          "comment_key": "${classificationTreeName} Comment"
        }' :: JSONB,
        '<p>The Australian Plant Census (APC) is a nationally-accepted taxonomy for the Australian flora. APC covers all '
        ||
        'published scientific plant names used in an Australian context in the taxonomic literature, but excludes taxa known '
        ||
        'only from cultivation in Australia. The taxonomy and nomenclature adopted for the APC are endorsed by the Council of '
        ||
        'Heads of Australasian Herbaria (CHAH). </p><p>Information available from APC includes:</p><ul class="discs"> '
        ||
        '<li>Accepted scientific name and author abbreviation(s);</li> <li>Reference to the taxonomic and nomenclatural '
        ||
        'concept adopted for APC;</li>  <li>Synonym(s) and misapplications;</li> <li>State distribution;</li><li>Relevant '
        ||
        'comments and notes</li></ul><p>APC is currently maintained within the Centre for Australian National Biodiversity '
        ||
        'Research with staff, resources and financial support from the Australian National Herbarium, Australian National '
        ||
        'Botanic Gardens and the Australian Biological Resources Study. The CANBR, ANBG and ABRS collaborate to further the '
        ||
        'updating and delivery of APNI and APC.</p>',
        TRUE,
        '${scheme}//${mapperPreferredHost}'
);

-- create versions
INSERT INTO tree_version
(id,
 lock_version,
 draft_name,
 log_entry,
 previous_version_id,
 published,
 created_at,
 created_by,
 published_at,
 published_by,
 tree_id)
  (SELECT
     nextval('nsl_global_seq' :: REGCLASS)             AS id,
     0                                                 AS lock_version,
     'import'                                          AS draft_name,
     'import'                                          AS log_entry,
     NULL                                              AS previous_version_id,
     TRUE                                              AS published,
     (year || '-' || month || '-' || day) :: TIMESTAMP AS created_at,
     'import'                                          AS created_by,
     (year || '-' || month || '-' || day) :: TIMESTAMP AS published_at,
     'import'                                          AS published_by,
     a.id                                              AS tree_id
   FROM daily_top_nodes('${classificationTreeName}', '2016-01-01'), tree a
   WHERE a.name = '${classificationTreeName}');

UPDATE tree_version
SET previous_version_id = id - 1
WHERE id > (SELECT min(id)
            FROM tree_version);

UPDATE tree t
SET current_tree_version_id = (SELECT max(id)
                               FROM tree_version v
                               WHERE v.tree_id = t.id)
WHERE name = '${classificationTreeName}';

VACUUM ANALYSE;

-- create elements


DROP INDEX IF EXISTS instance_path_index;
DROP INDEX IF EXISTS parent_instance_path_index;
DROP INDEX IF EXISTS unique_instance_path_index;

DROP TABLE IF EXISTS instance_paths;
CREATE TABLE instance_paths (
    id,
    instance_path,
    parent_instance_path,
    name_path,
    instance_id,
    name_id,
    excluded,
    declared_bt,
    depth,
    nodes,
    versions,
    ver_node_map
) AS
  SELECT
    nextval('nsl_global_seq'),
    instance_path,
    parent_instance_path,
    name_path,
    instance_id,
    name_id,
    excluded,
    declared_bt,
    depth,
    jsonb_agg(DISTINCT (node_id)),
    jsonb_agg(v.id),
    jsonb_object_agg(text(v.id), node_id)
  FROM daily_top_nodes('${classificationTreeName}', '2016-01-01') AS dtn,
    tree_version v,
        tree_element_data_from_start_node(dtn.latest_node_id) AS el_data
  WHERE v.published_at = (dtn.year || '-' || dtn.month || '-' || dtn.day) :: TIMESTAMP
        AND el_data.instance_id IS NOT NULL
  GROUP BY instance_path, excluded,
    declared_bt, parent_instance_path, name_path, instance_id, name_id,
    depth;

CREATE INDEX instance_path_index
  ON instance_paths (instance_path);
CREATE INDEX parent_instance_path_index
  ON instance_paths (parent_instance_path);
CREATE UNIQUE INDEX unique_instance_path_index
  ON instance_paths (instance_path, excluded);

-- create function synonym_as_html
DROP FUNCTION IF EXISTS synonym_as_html( BIGINT );
CREATE FUNCTION synonym_as_html(instance_id BIGINT)
  RETURNS TABLE(html TEXT)
LANGUAGE SQL
AS $$
SELECT CASE
       WHEN it.nomenclatural
         THEN '<nom>' || synonym.full_name_html || ' <type>' || it.name || '</type></nom>'
       WHEN it.taxonomic
         THEN '<tax>' || synonym.full_name_html || ' <type>' || it.name || '</type></tax>'
       WHEN it.misapplied
         THEN '<mis>' || synonym.full_name_html || ' <type>' || it.name || '</type> by <citation>' ||
              cites_ref.citation_html
              ||
              '</citation></mis>'
       WHEN it.synonym
         THEN '<syn>' || synonym.full_name_html || ' <type>' || it.name || '</type></syn>'
       ELSE ''
       END
FROM Instance i,
  Instance syn_inst
  JOIN instance_type it ON syn_inst.instance_type_id = it.id
  JOIN instance cites_inst ON syn_inst.cites_id = cites_inst.id
  JOIN reference cites_ref ON cites_inst.reference_id = cites_ref.id
  ,
  NAME synonym
WHERE syn_inst.cited_by_id = i.id
      AND i.id = instance_id
      AND synonym.id = syn_inst.name_id
ORDER BY it.nomenclatural DESC, it.taxonomic DESC, it.misapplied DESC, synonym.simple_name, cites_ref.year ASC;
$$;

-- create function synonyms_as_html
DROP FUNCTION IF EXISTS synonyms_as_html( BIGINT );
CREATE FUNCTION synonyms_as_html(instance_id BIGINT)
  RETURNS TEXT
LANGUAGE SQL
AS $$
SELECT '<synonyms>' || string_agg(html, '') || '</synonyms>'
FROM synonym_as_html(instance_id) AS html;
$$;

-- create function profile_as_jsonb
DROP FUNCTION IF EXISTS profile_as_jsonb( BIGINT );
CREATE FUNCTION profile_as_jsonb(source_instance_id BIGINT)
  RETURNS JSONB
LANGUAGE SQL
AS $$
SELECT jsonb_object_agg(key.name, jsonb_build_object(
    'value', note.value,
    'created_at', note.created_at,
    'created_by', note.created_by,
    'updated_at', note.updated_at,
    'updated_by', note.updated_by,
    'source_link', '${scheme}//${mapperPreferredHost}' || '/instanceNote/${nameSpace}/' || note.id
))
FROM instance i
  JOIN instance_note note ON i.id = note.instance_id
  JOIN instance_note_key key ON note.instance_note_key_id = key.id
WHERE i.id = source_instance_id;
$$;

-- create function synonyms_as_jsonb
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
                                            '/instance/${nameSpace}/' || syn_inst.id,
                                            'concept_link',
                                            '/instance/${nameSpace}/' || cites_inst.id,
                                            'simple_name', synonym.simple_name,
                                            'type', it.name,
                                            'name_id', synonym.id :: BIGINT,
                                            'name_link',
                                            '/name/${nameSpace}/' || synonym.id,
                                            'full_name_html', synonym.full_name_html,
                                            'nom', it.nomenclatural,
                                            'tax', it.taxonomic,
                                            'mis', it.misapplied,
                                            'cites', cites_ref.citation_html,
                                            'cites_link',
                                            '/reference/${nameSpace}/' || cites_ref.id,
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

-- adding tree_path to tree_element as this is the quikcer way to create tree_path then set it on tree_version_element
-- this is also a quicker conversion from the old structure of tree_path on tree_element.
ALTER TABLE tree_element
  ADD COLUMN parent_element_id INT8;

INSERT INTO tree_element
(id,
 lock_version,
 excluded,
 display_html,
 synonyms_html,
 instance_id,
 instance_link,
 name_id,
 name_link,
 parent_element_id,
 previous_element_id,
 profile,
 synonyms,
 rank,
 simple_name,
 name_element,
 source_shard,
 updated_at,
 updated_by
)
  (SELECT
     ipath.id                                                                                  AS id,
     0 :: BIGINT                                                                               AS lock_version,
     ipath.excluded                                                                            AS excluded,
     '<data>' || n.full_name_html || '<citation>' || ref.citation_html || '</citation></data>' AS display_html,
     coalesce(synonyms_as_html(ipath.instance_id), '<synonyms></synonyms>')                    AS synonyms_html,
     ipath.instance_id :: BIGINT                                                               AS instance_id,
     '${scheme}//${mapperPreferredHost}' || '/instance/${nameSpace}/' || ipath.instance_id             AS instance_link,
     ipath.name_id :: BIGINT                                                                   AS name_id,
     '${scheme}//${mapperPreferredHost}' || '/name/${nameSpace}/' || ipath.name_id                     AS name_link,
     coalesce(parent_ipath.id, NULL)                                                           AS parentelementid,
     NULL                                                                                      AS previouselementid,
     profile_as_jsonb(ipath.instance_id)                                                       AS profile,
     synonyms_as_jsonb(ipath.instance_id, '${mapperPreferredHost}')                            AS synonyms,
     rank.name                                                                                 AS rank,
     n.simple_name                                                                             AS simple_name,
     coalesce(n.name_element, '?')                                                             AS name_element,
     'APNI'                                                                                    AS source_shard,
     now()                                                                                     AS updated_at,
     'import'                                                                                  AS updated_by
   FROM instance_paths ipath
     JOIN name n ON ipath.name_id = n.id
     JOIN name_rank rank ON n.name_rank_id = rank.id
     JOIN instance i ON ipath.instance_id = i.id
     JOIN reference ref ON i.reference_id = ref.id
     LEFT OUTER JOIN instance_paths parent_ipath
       ON ipath.parent_instance_path = parent_ipath.instance_path);

-- remove declared BTs by making the children point to the next parent up.

CREATE INDEX tree_element_parent_index
  ON tree_element (parent_element_id);

UPDATE tree_element child_el
SET parent_element_id = par_el.parent_element_id
FROM instance_paths ipath
  JOIN tree_element par_el ON par_el.id = ipath.id
WHERE child_el.parent_element_id = par_el.id
      AND ipath.declared_bt = TRUE;

DELETE FROM tree_element
WHERE tree_element.id IN (SELECT ipath.id
                          FROM instance_paths ipath
                          WHERE ipath.declared_bt);

-- link tree_elements to versions

ALTER TABLE IF EXISTS tree_version_element
  DROP CONSTRAINT IF EXISTS FK_8nnhwv8ldi9ppol6tg4uwn4qv;

-- 19min create tree_version_elements
INSERT INTO tree_version_element (element_link, parent_id, taxon_link, tree_version_id, tree_element_id, taxon_id,
                                  tree_path, name_path, depth, updated_at, updated_by)
  SELECT
    '/tree/' || v.id || '/' || ipath.id                    AS element_link,
    CASE WHEN te.parent_element_id IS NOT NULL
      THEN
        '/tree/' || v.id || '/' || te.parent_element_id
    ELSE NULL
    END                                                    AS parent_id,
    '/node/${nameSpace}/' || (ipath.ver_node_map ->> (text(v.id))) AS taxon_link,
    v.id                                                   AS tree_version_id,
    ipath.id                                               AS tree_element_id,
    (ipath.ver_node_map ->> (text(v.id))) :: BIGINT        AS taxon_id,
    'not_set'                                              AS tree_path,
    ipath.name_path                                        AS name_path,
    ipath.depth                                            AS depth,
    v.created_at                                           AS updated_at,
    v.created_by                                           AS updated_by
  FROM instance_paths ipath
    JOIN tree_element te ON te.id = ipath.id
    ,
    tree_version v
  WHERE ipath.versions @> to_jsonb(v.id);

-- set the tree_path to tree elements instead of instance path

WITH RECURSIVE walk (element_id, tree_path) AS (
  SELECT
    id        AS element_id,
    '/' || id AS tree_path
  FROM tree_element
  WHERE parent_element_id IS NULL
  UNION ALL
  SELECT
    e.id                          AS element_id,
    walk.tree_path || '/' || e.id AS tree_path
  FROM walk, tree_element e
  WHERE e.parent_element_id = walk.element_id

)
UPDATE tree_version_element element
SET tree_path = walk.tree_path
FROM walk
WHERE element.tree_element_id = walk.element_id;

-- clean up
DROP INDEX tree_element_parent_index;

ALTER TABLE tree_element
  DROP COLUMN parent_element_id;

ALTER TABLE IF EXISTS tree_version_element
  ADD CONSTRAINT FK_8nnhwv8ldi9ppol6tg4uwn4qv
FOREIGN KEY (parent_id)
REFERENCES tree_version_element;

VACUUM ANALYSE;

-- *************** end tree creation ***************

-- set all the existing name paths and family from ${classificationTreeName} tree
UPDATE name n
SET name_path = '', family_id = NULL;

DROP FUNCTION IF EXISTS find_family_name_id( TEXT );
CREATE FUNCTION find_family_name_id(target_element_link TEXT)
  RETURNS BIGINT
LANGUAGE SQL AS
$$
WITH RECURSIVE walk (name_id, rank, parent_id) AS (
  SELECT
    te.name_id,
    te.rank,
    tve.parent_id
  FROM tree_version_element tve
    JOIN tree_element te ON tve.tree_element_id = te.id
  WHERE element_link = target_element_link
  UNION ALL
  SELECT
    te.name_id,
    te.rank,
    tve.parent_id
  FROM walk, tree_version_element tve
    JOIN tree_element te ON tve.tree_element_id = te.id
  WHERE element_link = walk.parent_id
)
SELECT name_id
FROM walk
WHERE rank = 'Familia';
$$;

DROP FUNCTION IF EXISTS name_name_path( BIGINT );
CREATE FUNCTION name_name_path(target_name_id BIGINT)
  RETURNS TABLE(name_path TEXT, family_id BIGINT)
LANGUAGE SQL AS
$$
with pathElements (id, path_element, rank_name) as (
  WITH RECURSIVE walk (id, parent_id, path_element, pos, rank_name) AS (
    SELECT
      n.id,
      n.parent_id,
      n.name_element,
      1,
      rank.name
    FROM name n
      join name_rank rank on n.name_rank_id = rank.id
    WHERE n.id = target_name_id
    UNION ALL
    SELECT
      n.id,
      n.parent_id,
      n.name_element,
      walk.pos + 1,
      rank.name
    FROM walk, name n
      join name_rank rank on n.name_rank_id = rank.id
    WHERE n.id = walk.parent_id
  )
  SELECT
    id,
    path_element,
    rank_name
  FROM walk
  order by walk.pos desc)
select
  string_agg(path_element, '/'),
  (select id
   from pathElements p2
   where p2.rank_name = 'Familia'
   limit 1)
from pathElements;
$$;

drop table if exists tmp_path_fam;
select
  id,
  blah.name_path,
  blah.family_id
into tmp_path_fam
from name n, name_name_path(n.id) blah;

alter table tmp_path_fam
  add foreign key (id) references name (id);

-- first set all the name paths to the name parent path and the family to the family in that path
update name
set name_path = blah.name_path, family_id = blah.family_id
from tmp_path_fam blah
where blah.id = name.id;
drop table if exists tmp_path_fam;

-- now set the family to the accepted taxon family for all names and synonyms on ${classificationTreeName}
-- don't change the name_path because that is the name_name_path
UPDATE name name
SET family_id = find_family_name_id(tvte.element_link)
FROM
  tree_element element
  JOIN tree_version_element tvte ON element.id = tvte.tree_element_id
  JOIN tree ON tvte.tree_version_id = tree.current_tree_version_id AND tree.name = '${classificationTreeName}'
  ,
  Instance i,
  Instance s,
  name synonym
WHERE name.id = s.name_id
      AND (s.cited_by_id = i.id OR s.id = i.id) AND i.id = element.instance_id
      AND synonym.id = i.name_id;

-- remove all the notifications caused by the trigger on name changes
DELETE FROM notification;

-- drop name_tree_path

ALTER TABLE IF EXISTS name_tree_path
  DROP CONSTRAINT IF EXISTS FK_4kc2kv5choyybkaetmshegbet;

ALTER TABLE IF EXISTS name_tree_path
  DROP CONSTRAINT IF EXISTS FK_j4j0kq9duod9gm019pl1xec7c;

ALTER TABLE IF EXISTS name_tree_path
  DROP CONSTRAINT IF EXISTS FK_try5dwb6jcy5fngk09bf7f7on;

ALTER TABLE IF EXISTS name_tree_path
  DROP CONSTRAINT IF EXISTS FK_sfj3hoevcuni3ak7no6byjp3;

ALTER TABLE IF EXISTS name_tree_path
  DROP CONSTRAINT IF EXISTS FK_3xnmxe5p6ed258euacrfflwrj;

DROP MATERIALIZED VIEW IF EXISTS taxon_view;
DROP MATERIALIZED VIEW IF EXISTS name_view;

DROP TABLE IF EXISTS name_tree_path;

DROP TABLE IF EXISTS name_part;

-- version
UPDATE db_version
SET version = 25
WHERE id = 1;

vacuum analyse;