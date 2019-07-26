ALTER TABLE instance_type
  ADD COLUMN has_label VARCHAR(255) NOT NULL DEFAULT 'not set';
ALTER TABLE instance_type
  ADD COLUMN of_label VARCHAR(255) NOT NULL DEFAULT 'not set';
ALTER TABLE instance_type
  ADD COLUMN bidirectional BOOLEAN DEFAULT FALSE NOT NULL;

UPDATE instance_type
SET has_label = name
WHERE misapplied = FALSE;
UPDATE instance_type
SET of_label = name || ' of'
WHERE misapplied = FALSE;
UPDATE instance_type
SET has_label = regexp_replace(name, 'misapplied', 'misapplication')
WHERE misapplied = TRUE;
UPDATE instance_type
SET of_label = name || ' to'
WHERE misapplied = TRUE;

-- NSL-1827 add use parent detail boolean to reference type
ALTER TABLE ref_type
  ADD COLUMN use_parent_details BOOLEAN DEFAULT FALSE NOT NULL;

-- NSL-1818 add family to name tree path
ALTER TABLE name_tree_path
  ADD COLUMN family_id INT8;
CREATE INDEX name_tree_path_family_index ON name_tree_path (family_id);
ALTER TABLE IF EXISTS name_tree_path
  ADD CONSTRAINT FK_4kc2kv5choyybkaetmshegbet
FOREIGN KEY (family_id)
REFERENCES name;

-- version
UPDATE db_version
SET version = 17
WHERE id = 1;
