-- NSL-3328
-- NOTE: need to update citations first
update tree_element te
set display_html = '<data>' || n.full_name_html ||
                   '<name-status class="' || ns.name || '">, ' || ns.name || '</name-status> <citation>' ||
                   r.citation_html || '</citation></data>'
from name n
         join name_status ns on n.name_status_id = ns.id,
     instance i,
     reference r
where te.name_id = n.id
  and te.instance_id = i.id
  and i.reference_id = r.id;

-- NOTE: need to update the citations first otherwise mis-applications are missed
update instance
set cached_synonymy_html = coalesce(synonyms_as_html(id), '<synonyms></synonyms>')
where id in (select distinct instance_id from tree_element);

update tree_element te
set synonyms_html = i.cached_synonymy_html
from instance i
         join reference r on i.reference_id = r.id,
     tree t
         join tree_version_element tve on tve.tree_version_id = t.current_tree_version_id
where te.id = tve.tree_element_id
  and te.instance_id = i.id
  and te.synonyms_html <> i.cached_synonymy_html
  and t.accepted_tree;
