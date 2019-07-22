drop function if exists synonym_as_html( bigint );
create function synonym_as_html(instanceid bigint)
  returns TABLE(html text)
language sql
as $$
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
      AND i.id = instanceid
      AND synonym.id = syn_inst.name_id
ORDER BY it.nomenclatural DESC, it.taxonomic DESC, it.misapplied DESC, synonym.simple_name, cites_ref.year ASC,
  cites_inst.id ASC, synonym.id ASC;
$$;

-- temporary functions to update current synonymy

drop function if exists synonym_current_as_html(bigint);

create function synonym_current_as_html(elementid bigint)
  returns TABLE(html text)
language sql
as $$
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
FROM tree_element e1,
      jsonb_array_elements(e1.synonyms -> 'list') AS tax_syn1
  join instance syn_inst on syn_inst.id = ((tax_syn1 ->> 'instance_id') :: numeric :: bigint)
  JOIN instance_type it ON syn_inst.instance_type_id = it.id
  JOIN instance cites_inst ON syn_inst.cites_id = cites_inst.id
  JOIN reference cites_ref ON cites_inst.reference_id = cites_ref.id
  ,
  NAME synonym
where e1.id = elementid
      AND synonym.id = syn_inst.name_id
ORDER BY it.nomenclatural DESC, it.taxonomic DESC, it.misapplied DESC, synonym.simple_name, cites_ref.year ASC,
  cites_inst.id ASC, synonym.id ASC;
$$;

drop function if exists current_synonyms_as_html(bigint);

create function current_synonyms_as_html(elementid bigint)
  returns text
language sql
as $$
SELECT '<synonyms>' || string_agg(html, '') || '</synonyms>'
FROM synonym_current_as_html(elementid) AS html;
$$;

update tree_element te
set synonyms_html = coalesce(current_synonyms_as_html(te.id), '<synonyms></synonyms>')
from tree_version_element tve join tree on tve.tree_version_id = tree.current_tree_version_id
where tve.tree_element_id = te.id
;

update tree_element te
set synonyms_html = coalesce(current_synonyms_as_html(te.id), '<synonyms></synonyms>')
from tree_version_element tve join tree on tve.tree_version_id = tree.default_draft_tree_version_id
where tve.tree_element_id = te.id
;

drop function if exists synonym_current_as_html(bigint);
drop function if exists current_synonyms_as_html(bigint);

-- version
UPDATE db_version
SET version = 26
WHERE id = 1;

