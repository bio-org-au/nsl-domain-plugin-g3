ALTER TABLE instance
  ADD CONSTRAINT no_duplicate_synonyms UNIQUE (name_id, reference_id, instance_type_id, page, cites_id, cited_by_id);

ALTER TABLE tree_arrangement
  ADD COLUMN shared BOOLEAN DEFAULT TRUE;

DROP TRIGGER IF EXISTS reference_update
ON author;

CREATE TRIGGER reference_update
AFTER INSERT OR UPDATE OR DELETE ON reference
FOR EACH ROW
EXECUTE PROCEDURE reference_notification();

UPDATE namespace
SET name = 'Algae'
WHERE name = 'AusAlgae';
UPDATE namespace
SET description_html = '(description of <b>Algae</b>)'
WHERE name = 'Algae';
UPDATE namespace
SET rdf_id = 'algae'
WHERE name = 'Algae';

INSERT INTO namespace (id, lock_version, name, description_html, rdf_id)
VALUES (nextval('nsl_global_seq'), 0, 'Lichen', '(description of <b>Lichen</b>)', 'lichen');
INSERT INTO public.namespace (id, lock_version, name, description_html, rdf_id)
VALUES (nextval('nsl_global_seq'), 0, 'Fungi', '(description of <b>Fungi</b>)', 'fungi');

-- indexes to speed up queries against the current tree

CREATE INDEX idx_node_current_name_a
  ON tree_node (name_id, tree_arrangement_id)
  WHERE replaced_at_id IS NULL;

CREATE INDEX idx_node_current_name_b
  ON tree_node (name_id, tree_arrangement_id)
  WHERE next_node_id IS NULL;

CREATE INDEX idx_node_current_instance_a
  ON tree_node (instance_id, tree_arrangement_id)
  WHERE replaced_at_id IS NULL;

CREATE INDEX idx_node_current_instance_b
  ON tree_node (instance_id, tree_arrangement_id)
  WHERE next_node_id IS NULL;

CREATE INDEX idx_node_current_a
  ON tree_node (tree_arrangement_id)
  WHERE replaced_at_id IS NULL;

CREATE INDEX idx_node_current_b
  ON tree_node (tree_arrangement_id)
  WHERE next_node_id IS NULL;

-- delete all workspaces

DELETE FROM tree_link l
WHERE
  (SELECT tree_type
   FROM tree_node n
     JOIN tree_arrangement a ON n.tree_arrangement_id = a.id
   WHERE n.id = l.supernode_id) = 'U';

UPDATE tree_arrangement
SET node_id = NULL
WHERE tree_type = 'U';

DELETE FROM tree_node n
WHERE
  (SELECT tree_type
   FROM tree_arrangement a
   WHERE n.tree_arrangement_id = a.id) = 'U';

DELETE FROM tree_arrangement
WHERE tree_type = 'U';

-- add new field and constraint

ALTER TABLE tree_arrangement
  ADD base_arrangement_id INT8 REFERENCES tree_arrangement;

ALTER TABLE tree_arrangement
  ADD CONSTRAINT chk_work_trees_have_base_trees CHECK (tree_type <> 'U' OR base_arrangement_id IS NOT NULL);

-- version
UPDATE db_version
SET version = 18
WHERE id = 1;
