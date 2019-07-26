ALTER TABLE name
  ADD COLUMN sort_name VARCHAR(250);

UPDATE db_version
SET version = 14
WHERE id = 1;
