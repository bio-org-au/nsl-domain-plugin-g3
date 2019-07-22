-- NSL-3076 make sure common names are in synonyms for tree so we export them.

DROP FUNCTION IF EXISTS synonyms_as_jsonb(BIGINT, TEXT);
CREATE FUNCTION synonyms_as_jsonb(instance_id BIGINT, host TEXT)
  RETURNS JSONB
  LANGUAGE SQL
AS
$$
SELECT jsonb_build_object('list',
                          coalesce(
                              jsonb_agg(jsonb_build_object(
                                  'host', host,
                                  'instance_id', syn_inst.id,
                                  'instance_link', syn_inst.uri,
                                  'concept_link', coalesce(cites_inst.uri, syn_inst.uri),
                                  'simple_name', synonym.simple_name,
                                  'type', it.name,
                                  'name_id', synonym.id :: BIGINT,
                                  'name_link', synonym.uri,
                                  'full_name_html', synonym.full_name_html,
                                  'nom', it.nomenclatural,
                                  'tax', it.taxonomic,
                                  'mis', it.misapplied,
                                  'cites', coalesce(cites_ref.citation, syn_ref.citation),
                                  'cites_html', coalesce(cites_ref.citation_html, syn_ref.citation_html),
                                  'cites_link', '/reference/'|| lower(conf.value) || '/' || (coalesce(cites_ref.id, syn_ref.id)),
                                  'year', cites_ref.year
                                )), '[]' :: JSONB)
         )
FROM Instance i,
     Instance syn_inst
       JOIN instance_type it ON syn_inst.instance_type_id = it.id
       JOIN reference syn_ref on syn_inst.reference_id = syn_ref.id
       LEFT JOIN instance cites_inst ON syn_inst.cites_id = cites_inst.id
       LEFT JOIN reference cites_ref ON cites_inst.reference_id = cites_ref.id
    ,
     name synonym,
     shard_config conf
WHERE i.id = instance_id
  AND syn_inst.cited_by_id = i.id
  AND synonym.id = syn_inst.name_id
  AND conf.name = 'name space';
$$;

-- add common names to tree html output
drop function if exists synonym_as_html(bigint);
create function synonym_as_html(instanceid bigint)
  returns TABLE(html text)
  language sql
as
$$
SELECT CASE
         WHEN it.nomenclatural
           THEN '<nom>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                '</name-status> <year>(' || year || ')<year> <type>' || instance_type || '</type></nom>'
         WHEN it.taxonomic
           THEN '<tax>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                '</name-status> <year>(' || year || ')<year> <type>' || instance_type || '</type></tax>'
         WHEN it.misapplied
           THEN '<mis>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                '</name-status><type>' || instance_type || '</type> by <citation>' ||
                citation_html || '</citation></mis>'
         WHEN it.synonym
           THEN '<syn>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                '</name-status> <year>(' || year || ')<year> <type>' || it.name || '</type></syn>'
         ELSE '<oth>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
              '</name-status> <type>' || it.name || '</type></oth>'
         END
FROM apni_ordered_synonymy(instanceid)
       join instance_type it on instance_type_id = it.id
$$;

-- update all current tree_elements
update tree_element ute
set synonyms = synonyms_as_jsonb(ute.instance_id, 'id.biodiversity.org.au'),
    synonyms_html = synonyms_html = coalesce(synonyms_as_html(ute.instance_id), '<synonyms></synonyms>')
where ute.id in (select distinct(te.id)
                 from tree_element te
                        join tree_version_element tve on te.id = tve.tree_element_id
                        join tree t on (t.current_tree_version_id = tve.tree_version_id) OR
                                       (t.default_draft_tree_version_id = tve.tree_version_id)
                 where te.synonyms <> synonyms_as_jsonb(te.instance_id, 'id.biodiversity.org.au'));

-- version
UPDATE db_version
SET version = 29
WHERE id = 1;
