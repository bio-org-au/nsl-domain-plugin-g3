alter table tree_arrangement add owner varchar(255);

REVOKE INSERT ON name_tag FROM read_only;
REVOKE INSERT ON name_tag_name FROM read_only;
REVOKE INSERT ON comment FROM read_only;
GRANT SELECT ON name_tag TO read_only;
GRANT SELECT ON name_tag_name TO read_only;
GRANT SELECT ON comment TO read_only;

UPDATE db_version
SET version = 15
WHERE id = 1;
