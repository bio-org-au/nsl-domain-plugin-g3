--NSL-1922 make orthographic variant unsourced
update instance_type set unsourced = false where name = 'orthographic variant';

-- version
UPDATE db_version
SET version = 24
WHERE id = 1;

