-- NOTE!!! The "apc" tree in lichen is named 'ABRSL'.

-- psql -f rebuild_ozmoss_apc_tree.sql ozmoss pg

CREATE OR REPLACE FUNCTION rebuild_lichen_apc_tree()
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
  mLichenNs        INTEGER;
  mApcTree         INTEGER;
  mApcNode         INTEGER;
  mCurrentRootNode INTEGER;
  mEvent           INTEGER;
  mRootNode        INTEGER;
  tmp              INTEGER;
  nn               INTEGER;
BEGIN
  RAISE INFO 'rebuild_lichen_apc_tree';
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
  INTO mLichenNs
  FROM namespace
  WHERE name = 'Lichen';
  RAISE INFO 'Lichen namespace is %', mLichenNs;

  SELECT id
  INTO mApcTree
  FROM tree_arrangement
  WHERE namespace_id = mLichenNs AND tree_type = 'P' AND label = 'ABRSL';
  RAISE INFO 'APC tree is %', mApcTree;
  SELECT node_id
  INTO mApcNode
  FROM tree_arrangement
  WHERE id = mApcTree;
  RAISE INFO 'APC top node is %', mApcNode;
  SELECT subnode_id
  INTO mCurrentRootNode
  FROM tree_link
  WHERE supernode_id = mApcNode;
  RAISE INFO 'APC current root is %', mCurrentRootNode;

  IF mApcTree IS NULL
  THEN
    --     create a new APC tree
    RAISE INFO 'NO APC tree, creating one.';

    SELECT nextval('nsl_global_seq')
    INTO mEvent;
    RAISE INFO 'Event for creation of the empty tree %', mEvent;

    INSERT INTO tree_event (id, namespace_id, lock_version, auth_user, note, time_stamp)
    VALUES (mEvent, mLichenNs, 1, 'nsl', 'create empty lichen tree', current_timestamp);

    SELECT nextval('nsl_global_seq')
    INTO mApcTree;
    SELECT nextval('nsl_global_seq')
    INTO mApcNode;
    SELECT nextval('nsl_global_seq')
    INTO mCurrentRootNode;


    INSERT INTO tree_arrangement (
      id, lock_version, tree_type, label, namespace_id, owner, shared, is_synthetic
    )
      SELECT
        mApcTree,
        1,
        'P',
        'Lichen',
        mLichenNs,
        'nsl',
        TRUE,
        'N';

    INSERT INTO tree_node (
      id, lock_version, checked_in_at_id, prev_node_id,
      internal_type, tree_arrangement_id, is_synthetic,
      type_uri_ns_part_id, type_uri_id_part
    )
    VALUES (
      mApcNode, 1, mEvent, NULL,
      'S', mApcTree, 'N',
      1, 'classification-node'
    );

    UPDATE tree_arrangement
    SET node_id = mApcNode
    WHERE id = mApcTree;

    INSERT INTO tree_node (
      id, lock_version, checked_in_at_id, prev_node_id,
      internal_type, tree_arrangement_id, is_synthetic,
      type_uri_ns_part_id, type_uri_id_part
    )
    VALUES (
      mCurrentRootNode, 1, mEvent, NULL,
      'T', mApcTree, 'Y',
      1, 'classification-root'
    );

    SELECT nextval('nsl_global_seq')
    INTO tmp;

    INSERT INTO tree_link (
      id, lock_version, link_seq, supernode_id, subnode_id, is_synthetic, type_uri_ns_part_id, type_uri_id_part, versioning_method
    )
    VALUES (
      tmp, 1, 1, mApcNode, mCurrentRootNode, 'Y', 1, 'classification-root-link', 'T'
    );

  END IF;
  -- end create APC tree if it doesn't exist

  -- create a root node
  SELECT nextval('nsl_global_seq')
  INTO mEvent;
  RAISE INFO 'Event for these operations will be %', mEvent;
  SELECT nextval('nsl_global_seq')
  INTO mRootNode;
  RAISE INFO 'New root node will be %', mRootNode;

  INSERT INTO tree_event (id, namespace_id, lock_version, auth_user, note, time_stamp)
  VALUES (mEvent, mLichenNs, 1, 'nsl', 'rebuild lichen apc tree', current_timestamp);

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
  -- end create a root node

  -- count and end date all existing tree nodes except the tree node
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

  -- set the tree node to point to the new root node
  UPDATE tree_node
  SET next_node_id = mRootNode, replaced_at_id = mEvent
  WHERE id = mCurrentRootNode;

  -- set the tree link subnode to point to the new Root node
  UPDATE tree_link
  SET subnode_id = mRootNode
  WHERE supernode_id = mApcNode;

  -- count instances that we need to insert onto the tree
  SELECT count(*)
  INTO nn
  FROM name n
    JOIN instance i ON n.id = i.name_id AND i.reference_id = 30005166
    JOIN instance_type it ON i.instance_type_id = it.id
    JOIN name_status st ON n.name_status_id = st.id
  WHERE it.standalone;

  RAISE INFO 'creating % new nodes', nn;

  -- make the nodes for the instances
  INSERT INTO tree_node (
    id, lock_version,
    checked_in_at_id,
    internal_type,
    is_synthetic,
    tree_arrangement_id,
    type_uri_ns_part_id,
    type_uri_id_part,
    name_id,
    name_uri_ns_part_id,
    name_uri_id_part,
    instance_id,
    taxon_uri_ns_part_id,
    taxon_uri_id_part)
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
      JOIN instance i ON n.id = i.name_id AND i.reference_id = 30005166
      JOIN instance_type it ON i.instance_type_id = it.id
      JOIN name_status st ON n.name_status_id = st.id
    WHERE it.standalone;

  -- link all the nodes to the root node (or top of the tree) so that they all exists
  INSERT INTO tree_link (
    id, lock_version,
    link_seq,
    subnode_id,
    supernode_id,
    is_synthetic,
    type_uri_id_part,
    type_uri_ns_part_id,
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

  -- re-arrange the node links into the tree structure
  UPDATE tree_link
  SET supernode_id =
  coalesce(
      (
        -- use the name.parent_id to work out the super node to link this node to
        SELECT supernode.id
        FROM tree_node subnode
          JOIN name ON subnode.name_id = name.id
          JOIN tree_node supernode ON supernode.name_id = name.parent_id
                                      AND supernode.tree_arrangement_id = mApcTree
                                      AND supernode.checked_in_at_id = mEvent
        WHERE subnode.id = tree_link.subnode_id
      ), mRootNode)
  WHERE supernode_id = mRootNode;

  -- set the new nodes to point to back to pre-existing nodes on this tree that
  -- were end-dated in this operation by mEvent
  UPDATE tree_node
  SET prev_node_id = (SELECT id
                      FROM tree_node n2
                      WHERE tree_node.name_id = n2.name_id
                            AND n2.replaced_at_id = mEvent)
  WHERE name_id IS NOT NULL
        AND checked_in_at_id = mEvent;

  -- point the pre-existing nodes 'next_node' to the new node that replaces it
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

SELECT rebuild_lichen_apc_tree();

COMMIT;
