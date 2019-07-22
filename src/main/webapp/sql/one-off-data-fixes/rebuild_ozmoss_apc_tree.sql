-- psql -f rebuild_ozmoss_apc_tree.sql ozmoss pg

CREATE OR REPLACE FUNCTION rebuild_ozmoss_apc_tree()
  RETURNS INTEGER AS
$BODY$
-- query from Nils is

--SELECT n.id, n.full_name, n.parent_id, r.id AS reference_id, r.citation, it.name AS instance_type, inote.value AS distribution
--FROM name n
--JOIN instance i ON n.id=i.name_id AND i.reference_id=10018098
--JOIN instance_type it ON i.instance_type_id=it.id
--JOIN reference r ON i.reference_id=r.id
--LEFT JOIN instance_note inote ON i.id=inote.instance_id AND inote.instance_note_key_id=10000003
--WHERE n.name_status_id=54360;

-- dont need instance note or the reference to build the tree, so this reduces to

--SELECT n.id as name_id, i.id as instance_id, n.parent_id as parent_name_id, it.name AS instance_type
--FROM name n
--JOIN instance i ON n.id=i.name_id AND i.reference_id=10018098
--JOIN instance_type it ON i.instance_type_id=it.id
--WHERE n.name_status_id=54360;

-- this build only supports instance type 'excluded' vs anything else. Ideally, the instance type would become
-- the node type because all of these instances are ozmoss instances. Our tree gear won't support this at present.
-- that is: the underlying data will, but the editor and display only understand apc attributes. What ought to happen is
-- that we have an ozmoss tree vocabulary for these things

DECLARE
  mApcVoc          INTEGER;
  mNslNameVoc      INTEGER;
  mNslInstanceVoc  INTEGER;
  mOzmossNs        INTEGER;
  mApcTree         INTEGER;
  mApcNode         INTEGER;
  mCurrentRootNode INTEGER;
  mEvent           INTEGER;
  mRootNode        INTEGER;
  nn               INTEGER;
BEGIN
  RAISE INFO 'rebuild_ozmoss_apc_tree';
  SELECT id
  INTO mNslNameVoc
  FROM tree_uri_ns
  WHERE label = 'nsl-name';
  RAISE INFO 'mNslNameVoc is %', mNslNameVoc;
  SELECT id
  INTO mNslInstanceVoc
  FROM tree_uri_ns
  WHERE label = 'nsl-instance';
  RAISE INFO 'mNslInstanceVoc is %', mNslInstanceVoc;
  SELECT id
  INTO mApcVoc
  FROM tree_uri_ns
  WHERE label = 'apc-voc';
  RAISE INFO 'APC vocabulary is %', mApcVoc;
  SELECT id
  INTO mOzmossNs
  FROM namespace
  WHERE name = 'AusMoss';
  RAISE INFO 'AusMoss namespace is %', mOzmossNs;
  SELECT id
  FROM tree_arrangement
  INTO mApcTree WHERE namespace_id = mOzmossNs AND tree_type = 'P' AND LABEL = 'APC';
  RAISE INFO 'APC tree is %', mApcTree;
  SELECT node_id
  FROM tree_arrangement
  INTO mApcNode WHERE id = mApcTree;
  RAISE INFO 'APC top node is %', mApcNode;
  SELECT subnode_id
  FROM tree_link
  INTO mCurrentRootNode WHERE supernode_id = mApcNode;
  RAISE INFO 'APC current root is %', mCurrentRootNode;
  SELECT nextval('nsl_global_seq')
  INTO mEvent;
  RAISE INFO 'Event for this operation will be %', mEvent;
  SELECT nextval('nsl_global_seq')
  INTO mRootNode;
  RAISE INFO 'New root node will be %', mRootNode;

  INSERT INTO tree_event (id, namespace_id, lock_version, auth_user, note, time_stamp)
  VALUES (mEvent, mOzmossNs, 1, 'nsl', 'rebuild ozmoss apc tree', current_timestamp);

  INSERT INTO tree_node (
    id, lock_version, checked_in_at_id, prev_node_id,
    internal_type, tree_arrangement_id, is_synthetic,
    type_uri_ns_part_id, type_uri_id_part
  )
  VALUES (
    mRootNode, 1, mEvent, mCurrentRootNode,
    'T', mApcTree, 'Y',
    1, 'classification-root'
  );

  SELECT count(*)
  INTO nn
  FROM tree_node
  WHERE tree_arrangement_id = mApcTree
        AND internal_type <> 'V'
        AND id <> mApcNode
        AND tree_arrangement_id IS NULL;

  RAISE INFO 'end-dating % nodes', nn;

  UPDATE tree_node
  SET next_node_id = 0, replaced_at_id = mEvent
  WHERE tree_arrangement_id = mApcTree
        AND internal_type <> 'V'
        AND id <> mApcNode
        AND tree_arrangement_id IS NULL;

  RAISE DEBUG 'building new empty tree';

  UPDATE tree_node
  SET next_node_id = mRootNode, replaced_at_id = mEvent
  WHERE id = mCurrentRootNode;
  UPDATE tree_link
  SET subnode_id = mRootNode
  WHERE supernode_id = mApcNode;

  SELECT count(*)
  INTO nn
  FROM name n
    JOIN instance i ON n.id = i.name_id AND i.reference_id = 10018098
    JOIN instance_type it ON i.instance_type_id = it.id
  WHERE n.name_status_id = 54360 AND it.standalone;

  RAISE INFO 'creating % new nodes', nn;

  INSERT INTO tree_node (
    id, lock_version, checked_in_at_id, internal_type, is_synthetic,
    tree_arrangement_id,
    type_uri_ns_part_id, type_uri_id_part,
    name_id, name_uri_ns_part_id, name_uri_id_part,
    instance_id, taxon_uri_ns_part_id, taxon_uri_id_part)
    SELECT
      nextval('nsl_global_seq'),
      1,
      mEvent,
      'T',
      'Y',
      mApcTree,
      mApcVoc,
      CASE
      WHEN it.name = 'excluded name' OR it.name = 'occurrence doubtful' OR it.name = 'status uncertain'
        THEN 'ApcExcluded'
      ELSE 'ApcConcept' END,
      n.id,
      mNslNameVoc,
      n.id,
      i.id,
      mNslInstanceVoc,
      i.id
    FROM name n
      JOIN instance i ON n.id = i.name_id AND i.reference_id = 10018098
      JOIN instance_type it ON i.instance_type_id = it.id
    WHERE n.name_status_id = 54360 AND it.standalone;

  INSERT INTO tree_link (
    id, lock_version, link_seq,
    subnode_id, supernode_id, is_synthetic,
    type_uri_id_part, type_uri_ns_part_id,
    versioning_method)
    SELECT
      nextval('nsl_global_seq'),
      1,
      name_id,
      -- use name id as link seq, will magically make link history work
      id,
      mRootNode,
      'Y',
      NULL,
      0,
      'V'
    FROM tree_node
    WHERE checked_in_at_id = mEvent
          AND id <> mRootNode;

  RAISE DEBUG 'relinking the names';

  UPDATE tree_link
  SET supernode_id =
  coalesce(
      (
        SELECT supnode.id
        FROM tree_node subnode
          JOIN name ON subnode.name_id = name.id
          JOIN tree_node supnode ON supnode.name_id = name.parent_id AND supnode.tree_arrangement_id = mApcTree AND
                                    supnode.checked_in_at_id = mEvent
        WHERE subnode.id = tree_link.subnode_id
      ), mRootNode)
  WHERE supernode_id = mRootNode;

  UPDATE tree_node
  SET prev_node_id = (SELECT id
                      FROM tree_node n2
                      WHERE tree_node.name_id = n2.name_id AND n2.replaced_at_id = mEvent)
  WHERE name_id IS NOT NULL AND checked_in_at_id = mEvent;

  UPDATE tree_node
  SET next_node_id =
  (SELECT id
   FROM tree_node n2
   WHERE tree_node.name_id = n2.name_id AND n2.checked_in_at_id = mEvent)
  WHERE name_id IS NOT NULL AND replaced_at_id = mEvent;

  RETURN 0;
END;
$BODY$
LANGUAGE plpgsql;

SELECT rebuild_ozmoss_apc_tree();

COMMIT;
