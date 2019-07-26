alter table if exists name
drop constraint if exists FK_mue061w1t8dtwwijttm3kq2jt;

alter table name drop COLUMN primary_instance_id;

UPDATE db_version
SET version = 8
WHERE id = 1;
