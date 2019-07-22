DROP TABLE IF EXISTS shard_config;

CREATE TABLE shard_config (
  id    INT8 DEFAULT nextval('hibernate_sequence') NOT NULL,
  name  VARCHAR(255)                               NOT NULL,
  value VARCHAR(5000)                              NOT NULL,
  PRIMARY KEY (id)
);

-- add back the defaults, which will need to be configured per shard
INSERT INTO public.shard_config (id, name, value) 
VALUES (nextval('hibernate_sequence'), 
        'config rules', 
        'All lower case names, space separated, follow the pattern hierachy');
INSERT INTO public.shard_config (id, name, value) 
VALUES (nextval('hibernate_sequence'), 
        'name space', 
        'APNI');
INSERT INTO public.shard_config (id, name, value) 
VALUES (nextval('hibernate_sequence'), 
        'name tree label', 
        'APNI');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'), 
        'classification tree label', 
        'APC');

-- add default descriptions
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'), 
        'APNI description',
        'The Australian Plant Name Index (APNI) is a tool for the botanical community that deals with plant names ' ||
        'and their usage in the scientific literature, whether as a current name or synonym. APNI does not recommend ' ||
        'any particular taxonomy or nomenclature. For a listing of currently accepted scientific names for the Australian ' ||
        'vascular flora, please use the Australian Plant Census (APC) link above.');

INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'), 
        'APC description',
        'The Australian Plant Census (APC) is a list of the accepted scientific names for the Australian vascular flora, ' ||
        'ferns, gymnosperms, hornworts and liverworts, both native and introduced, and includes synonyms and misapplications ' ||
        'for these names. The APC covers all published scientific plant names used in an Australian context in the ' ||
        'taxonomic literature, but excludes taxa known only from cultivation in Australia. The taxonomy and nomenclature ' ||
        'adopted for the APC are endorsed by the Council of Heads of Australasian Herbaria (CHAH).');

-- add search app defaults
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'menu label',
        'Vascular Plants');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'banner text',
        'Vascular Plants');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'description html',
        '<p>This section of the National Species List infrastructure delivers names and taxonomies for  flowering plants, ' ||
        'ferns, gymnosperms, hornworts, and liverworts. The currently available data comprise names, bibliographic ' ||
        'information, and taxonomic concepts for plants that are either native to or naturalised in Australia.</p>' ||
        '<p>The Australian Plant Name Index (APNI) provides names and bibliographic information.</p><p>The Australian ' ||
        'Plant Census (APC) provides a nationally-accepted taxonomy.</p><p>Additional names and taxonomies will be ' ||
        'accessible here as they become available.</p>');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'tree banner text',
        'Australian Plant Census');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'name label',
        'APNI');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'tree description html',
        '<p>The Australian Plant Census (APC) is a nationally-accepted taxonomy for the Australian flora. APC covers all ' ||
        'published scientific plant names used in an Australian context in the taxonomic literature, but excludes taxa ' ||
        'known only from cultivation in Australia. The taxonomy and nomenclature adopted for the APC are endorsed by the ' ||
        'Council of Heads of Australasian Herbaria (CHAH). </p><p>Information available from APC includes:</p>' ||
        '<ul class="discs"> ' ||
        '<li>Accepted scientific name and author abbreviation(s);</li> ' ||
        '<li>Reference to the taxonomic and nomenclatural concept adopted for APC;</li>  ' ||
        '<li>Synonym(s) and misapplications;</li> ' ||
        '<li>State distribution;</li>' ||
        '<li>Relevant comments and notes</li>' ||
        '</ul>' ||
        '<p>APC is currently maintained within the Centre for Australian National Biodiversity Research with staff, ' ||
        'resources and financial support from the Australian National Herbarium, Australian National Botanic Gardens and ' ||
        'the Australian Biological Resources Study. The CANBR, ANBG and ABRS collaborate to further the updating and ' ||
        'delivery of APNI and APC.</p>');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'tree label',
        'APC');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'tree label text',
        'Australian Plant Census');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'page title',
        'Vascular Plants');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'tree search help text html',
        'The Australian Plant Census (APC) provides a listing of currently accepted names for the Australian native and ' ||
        'introduced flora, including angiosperms, ferns, gymnosperms, hornworts and liverworts. APC does not de full ' ||
        'details of the usage of these names in the taxonomic literature.   For comprehensive bibliographic information, ' ||
        'see the <a href="/names">Australian Plant Name Index database (APNI)</a>.</p>');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'services path name element',
        'apni');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'name search help text html',
        '<p>The Australian Plant Name Index (APNI) is a resource for the botanical community that deals with vascular ' ||
        'plant names and their usage in the scientific literature, whether as a current name or synonym.  Names of ' ||
        'cultivars derived from the Australian flora are also included.</p><p>APNI does not recommend any particular ' ||
        'taxonomy or nomenclature.</p><p>For a listing of currently accepted scientific names for the Australian vascular ' ||
        'flora, use the <a href="/taxonomy/accepted">Australian Plant Census (APC)</a>.</p>');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'services path tree element',
        'apc');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'name link title',
        'Vascular Plant Names in the Australian Plant Names Index');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'menu link title',
        'Vascular Plants');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'name label text',
        'Australian Plant Name Index');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'name banner text',
        'Australian Plant Name Index');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'tree link title',
        'Australian Plant Census Taxonomy');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'),
        'name description html',
        '<p>The Australian Plant Name Index (APNI) is a national resource providing information on the names of native ' ||
        'and naturalised Australian plants and the usage of these names in the scientific literature, whether as a current ' ||
        'name or synonym. APNI includes data for angiosperms, ferns, gymnosperms, hornworts, and liverworts. It also ' ||
        'includes names for cultivars derived from the Australian flora. APNI does not recommend any particular taxonomy ' ||
        'or nomenclature. For a listing of currently accepted scientific names for the Australian vascular flora, see ' ||
        'the Australian Plant Census (APC). </p> Information available from APNI includes:' ||
        '<ul class="discs">' ||
        '<li>Scientific plant names;' ||
        '<li>Author details;</li>' ||
        '<li>Original publication details (protologue) with links to the publication when available;</li>' ||
        '<li>Subsequent usage of the name in the scientific literature (in an Australian context);</li>' ||
        '<li>Typification details;</li>' ||
        '<li>Icons indicating which, if any, is the currently accepted concept in the Australian Plant Census (APC);</li>' ||
        '<li>State distribution (from APC); </li>' ||
        '<li>Relevant comments and notes; and </li>' ||
        '<li>Links to other information where available. </li>' ||
        '</ul>' ||
        '<p>APNI is currently maintained within the Centre for Australian National Biodiversity Research with staff, ' ||
        'resources and financial support from the Australian National Herbarium, Australian National Botanic Gardens and ' ||
        'the Australian Biological Resources Study. The CANBR, ANBG and ABRS collaborate to further the updating and ' ||
        'delivery of APNI and APC.</p>');

CREATE OR REPLACE FUNCTION is_instance_in_tree(pinstance instance.id%TYPE, ptree tree_arrangement.id%TYPE) RETURNS boolean AS $$
DECLARE
  -- declarations
  ct integer;
  base_id tree_arrangement.id%TYPE;
BEGIN
  -- OK. Is this instance directly in the tree as a current node?

  select count(*) into ct
  from tree_node n
  where n.instance_id = pinstance
        and n.tree_arrangement_id = ptree
        and n.next_node_id is null;

  if ct <> 0 then
    return true;
  end if;

  -- is the tree derived from some other tree?

  select base_arrangement_id into base_id from tree_arrangement a where a.id = ptree;

  if base_id is null then
    return false;
  end if;

  -- right. This tree is derived from another tree. That means that the instance might be in that
  -- other tree and adopted to this one. here's where we need to do a treewalk.
  -- this code assumes that the tree will have at least one node belonging to it at the root, which currently
  -- is the case.

  with recursive treewalk as (
    select n.id as node_id, n.tree_arrangement_id
    from tree_node n
    where n.instance_id = pinstance
          and n.tree_arrangement_id = base_id
          and n.next_node_id is null
    union all
    select n.id as node_id, n.tree_arrangement_id
    from treewalk
      join tree_link l on treewalk.node_id = l.subnode_id
      join tree_node n on l.supernode_id = n.id
    where treewalk.tree_arrangement_id <> ptree -- clip search here
          and n.next_node_id is null
          and n.tree_arrangement_id in (ptree, base_id)
  )
  select count(node_id) into ct from treewalk where treewalk.tree_arrangement_id = ptree;

  return ct <> 0;
END;
$$ LANGUAGE plpgsql;


-- version
UPDATE db_version
SET version = 19
WHERE id = 1;
