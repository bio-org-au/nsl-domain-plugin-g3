ALTER TABLE nsl_simple_name ADD COLUMN basionym VARCHAR(512);
ALTER TABLE nsl_simple_name ADD COLUMN proto_citation VARCHAR(512);
ALTER TABLE nsl_simple_name ADD COLUMN proto_instance_id INT8;
ALTER TABLE nsl_simple_name ADD COLUMN replaced_synonym VARCHAR(512);

ALTER TABLE IF EXISTS nsl_simple_name
ADD CONSTRAINT FK_59i6is32bt6v19i51ql9n2r9i
FOREIGN KEY (proto_instance_id)
REFERENCES instance;

ALTER TABLE reference ALTER COLUMN pages TYPE VARCHAR(255) USING pages::VARCHAR(255);

UPDATE db_version
SET version = 9
WHERE id = 1;
