--triggers

-- Name change trigger

CREATE OR REPLACE FUNCTION name_notification()
  RETURNS TRIGGER AS $name_note$
BEGIN
  IF (TG_OP = 'DELETE')
  THEN
    INSERT INTO notification (id, version, message, object_id)
      SELECT
        nextval('hibernate_sequence'),
        0,
        'name deleted',
        OLD.id;
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE')
    THEN
      INSERT INTO notification (id, version, message, object_id)
        SELECT
          nextval('hibernate_sequence'),
          0,
          'name updated',
          NEW.id;
      RETURN NEW;
  ELSIF (TG_OP = 'INSERT')
    THEN
      INSERT INTO notification (id, version, message, object_id)
        SELECT
          nextval('hibernate_sequence'),
          0,
          'name created',
          NEW.id;
      RETURN NEW;
  END IF;
  RETURN NULL;
END;
$name_note$ LANGUAGE plpgsql;


CREATE TRIGGER name_update
AFTER INSERT OR UPDATE OR DELETE ON name
FOR EACH ROW
EXECUTE PROCEDURE name_notification();

-- Author change trigger

CREATE OR REPLACE FUNCTION author_notification()
  RETURNS TRIGGER AS $author_note$
BEGIN
  IF (TG_OP = 'DELETE')
  THEN
    INSERT INTO notification (id, version, message, object_id)
      SELECT
        nextval('hibernate_sequence'),
        0,
        'author deleted',
        OLD.id;
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE')
    THEN
      INSERT INTO notification (id, version, message, object_id)
        SELECT
          nextval('hibernate_sequence'),
          0,
          'author updated',
          NEW.id;
      RETURN NEW;
  ELSIF (TG_OP = 'INSERT')
    THEN
      INSERT INTO notification (id, version, message, object_id)
        SELECT
          nextval('hibernate_sequence'),
          0,
          'author created',
          NEW.id;
      RETURN NEW;
  END IF;
  RETURN NULL;
END;
$author_note$ LANGUAGE plpgsql;


CREATE TRIGGER author_update
AFTER INSERT OR UPDATE OR DELETE ON author
FOR EACH ROW
EXECUTE PROCEDURE author_notification();

-- Reference change trigger
CREATE OR REPLACE FUNCTION reference_notification()
  RETURNS TRIGGER AS $ref_note$
BEGIN
  IF (TG_OP = 'DELETE')
  THEN
    INSERT INTO notification (id, version, message, object_id)
      SELECT
        nextval('hibernate_sequence'),
        0,
        'reference deleted',
        OLD.id;
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE')
    THEN
      INSERT INTO notification (id, version, message, object_id)
        SELECT
          nextval('hibernate_sequence'),
          0,
          'reference updated',
          NEW.id;
      RETURN NEW;
  ELSIF (TG_OP = 'INSERT')
    THEN
      INSERT INTO notification (id, version, message, object_id)
        SELECT
          nextval('hibernate_sequence'),
          0,
          'reference created',
          NEW.id;
      RETURN NEW;
  END IF;
  RETURN NULL;
END;
$ref_note$ LANGUAGE plpgsql;


CREATE TRIGGER reference_update
AFTER INSERT OR UPDATE OR DELETE ON reference
FOR EACH ROW
EXECUTE PROCEDURE reference_notification();

-- Instance change trigger
CREATE OR REPLACE FUNCTION instance_notification()
  RETURNS TRIGGER AS $inst_note$
BEGIN
  IF (TG_OP = 'DELETE')
  THEN
    INSERT INTO notification (id, version, message, object_id)
      SELECT
        nextval('hibernate_sequence'),
        0,
        'instance deleted',
        OLD.id;
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE')
    THEN
      INSERT INTO notification (id, version, message, object_id)
        SELECT
          nextval('hibernate_sequence'),
          0,
          'instance updated',
          NEW.id;
      RETURN NEW;
  ELSIF (TG_OP = 'INSERT')
    THEN
      INSERT INTO notification (id, version, message, object_id)
        SELECT
          nextval('hibernate_sequence'),
          0,
          'instance created',
          NEW.id;
      RETURN NEW;
  END IF;
  RETURN NULL;
END;
$inst_note$ LANGUAGE plpgsql;

CREATE TRIGGER instance_update
    AFTER UPDATE OF cited_by_id ON instance
    FOR EACH ROW
EXECUTE PROCEDURE instance_notification();

CREATE TRIGGER instance_insert_delete
    AFTER INSERT OR DELETE ON instance
    FOR EACH ROW
EXECUTE PROCEDURE instance_notification();

-- create trigger function
CREATE OR REPLACE FUNCTION update_synonyms_and_cache()
    RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR NEW.instance_type_id <> OLD.instance_type_id THEN
        UPDATE instance
        SET cached_synonymy_html = coalesce(synonyms_as_html(instance.id), '<synonyms></synonyms>')
        WHERE instance.id=NEW.id;
        UPDATE instance
        SET cached_synonymy_h7tml = coalesce(synonyms_as_html(instance.id), '<synonyms></synonyms>')
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
