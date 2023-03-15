-- yes I know this is the same as #40, but a typo somehow got into production.
CREATE OR REPLACE FUNCTION update_synonyms_and_cache()
    RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR NEW.instance_type_id <> OLD.instance_type_id THEN
        UPDATE instance
        SET cached_synonymy_html = coalesce(synonyms_as_html(instance.id), '<synonyms></synonyms>')
        WHERE instance.id=NEW.id;
        UPDATE instance
        SET cached_synonymy_html = coalesce(synonyms_as_html(instance.id), '<synonyms></synonyms>')
        WHERE instance.id IN (SELECT cited_by_id FROM instance WHERE instance.id=NEW.id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger
DROP TRIGGER IF EXISTS update_instance_synonyms_and_cache on instance;

-- create trigger
CREATE TRIGGER update_instance_synonyms_and_cache
    AFTER INSERT OR UPDATE ON instance
    FOR EACH ROW EXECUTE PROCEDURE update_synonyms_and_cache();

-- update version
UPDATE db_version
SET version = 41
WHERE id = 1;
