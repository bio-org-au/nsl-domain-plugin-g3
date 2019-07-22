-- fix buggered synonyms_html from update 29
update tree_element ute
set synonyms_html = coalesce(synonyms_as_html(ute.instance_id), '<synonyms></synonyms>')
where ute.synonyms_html = 'false';

update tree_element ute
set synonyms_html = coalesce(synonyms_as_html(ute.instance_id), '<synonyms></synonyms>')
where ute.synonyms_html = 'true';

-- version
UPDATE db_version
SET version = 30
WHERE id = 1;
