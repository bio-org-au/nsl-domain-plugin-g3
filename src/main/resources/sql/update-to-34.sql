alter table if exists name_resources
    drop constraint if exists FK_nhx4nd4uceqs7n5abwfeqfun5;

alter table if exists name_resources
    drop constraint if exists FK_goyj9wmbb1y4a6y4q5ww3nhby;

drop table if exists name_resources cascade;

create table name_resources
(
    resource_id int8 not null,
    name_id     int8 not null,
    primary key (name_id, resource_id)
);

alter table if exists name_resources
    add constraint FK_nhx4nd4uceqs7n5abwfeqfun5
        foreign key (name_id)
            references name;

alter table if exists name_resources
    add constraint FK_goyj9wmbb1y4a6y4q5ww3nhby
        foreign key (resource_id)
            references resource;

GRANT SELECT, INSERT, UPDATE, DELETE ON name_resources TO ${webUserName};
GRANT SELECT ON name_resources TO read_only;

-- version
UPDATE db_version
SET version = 34
WHERE id = 1;
