CREATE OR REPLACE FUNCTION find_name_in_tree(pname name.id%TYPE, ptree tree_arrangement.id%TYPE) RETURNS tree_link.id%TYPE AS $$
DECLARE
  -- declarations
  ct integer;
  base_id tree_arrangement.id%TYPE;
  link_id tree_link.id%TYPE;
BEGIN
  -- if this is a simple tree, then we can just look for the tree link directly.
  -- if it is a tree based on another tree, then we must do a treewalk

  select base_arrangement_id into base_id from tree_arrangement a where a.id = ptree;

  begin
    IF base_id is null then
      -- ok. look for the name as a current node in the tree, and find the link to its current parent.

      select l.id INTO STRICT link_id
      from tree_node c
        join tree_link l on c.id = l.subnode_id
        join tree_node p on l.supernode_id = p.id
      where c.name_id = pname
            and c.tree_arrangement_id = ptree
            and c.next_node_id is null
            and p.tree_arrangement_id = ptree
            and p.next_node_id is null;
    ELSE
      -- ok. we need to do a treewalk. As always, this gets nasty.

      with RECURSIVE walk as (
        select l.id as stem_link, l.id as leaf_link, p.tree_arrangement_id = ptree as foundit
        from tree_node c
          join tree_link l on c.id = l.subnode_id
          join tree_node p on l.supernode_id = p.id
        where
          c.name_id = pname
          and (c.tree_arrangement_id = ptree or c.tree_arrangement_id = base_id)
          and c.next_node_id is null
          and (p.tree_arrangement_id = ptree or p.tree_arrangement_id = base_id)
          and p.next_node_id is null
        UNION ALL
        SELECT
          superlink.id as stem_link, walk.leaf_link, p.tree_arrangement_id = ptree as foundit
        FROM walk
          JOIN tree_link sublink on walk.stem_link = sublink.id
          join tree_link superlink on sublink.supernode_id = superlink.subnode_id
          join tree_node p on superlink.supernode_id = p.id
        where not walk.foundit -- clip the search
              and (p.tree_arrangement_id = ptree or p.tree_arrangement_id = base_id)
              and p.next_node_id is null
      )
      select leaf_link INTO STRICT link_id from walk where foundit;

    END IF;

    return link_id;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise notice 'no data found';
      return null;
    WHEN TOO_MANY_ROWS THEN
      raise notice 'too many rows';
      RAISE 'Multiple placements of name % in tree %', pname, ptree USING ERRCODE = 'unique_violation';
  end;
END;
$$ LANGUAGE plpgsql;


-- version
UPDATE db_version
SET version = 20
WHERE id = 1;
