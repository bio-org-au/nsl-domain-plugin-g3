
-- NOTE THAT THIS SCRIPT UPDATES Th TREE TO THE APNI NAMESPACE. ALTER IT TO DO AUSMOSS


alter table tree_event add namespace_id int8;

alter table tree_event add foreign key (namespace_id) references namespace(id);

update tree_event set namespace_id = (select id from namespace where name = 'APNI') where id <> 0;

alter table tree_arrangement add namespace_id int8;

alter table tree_arrangement add foreign key (namespace_id) references namespace(id);

drop index tree_arrangement_label;

create unique index tree_arrangement_label on tree_arrangement(label, namespace_id);

update tree_arrangement set namespace_id = (select id from namespace where name = 'APNI') where id <> 0;

UPDATE db_version
SET version = 11
WHERE id = 1;

-- zap bad identifiers

delete from mapper.identifier_identities ii
where exists (
    select 1 FROM mapper.identifier i where
      i.id = ii.identifier_id
      and i.name_space in ('APC', 'tree')
);

delete from mapper.identifier where name_space in ('APC', 'tree');

delete from mapper.match
where uri like '%/APC/%' or uri like '%/tree/%';


-- ADDENDUM - new domain for namespaces.

-- this needs to be different for the different shards because the code shares the tree_ns_id table
-- the correct fix would be to use different namespace prefixes and to have a config item
-- for 'what uri prefix to use for your names', or even to have it in the namespace table.

update tree_uri_ns set uri = 'http://id.biodiversity.org.au/name/apni/' where label='nsl-name';
update tree_uri_ns set uri = 'http://id.biodiversity.org.au/instance/apni/' where label='nsl-instance';

--update tree_uri_ns set uri = 'http://id.biodiversity.org.au/name/ausmoss/' where label='nsl-name';
--update tree_uri_ns set uri = 'http://id.biodiversity.org.au/instance/ausmoss/' where label='nsl-instance';
