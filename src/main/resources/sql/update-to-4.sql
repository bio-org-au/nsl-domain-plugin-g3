create table name_tag_name (
  name_id int8 not null,
  tag_id int8 not null,
  primary key (name_id, tag_id)
);

create table name_tag (
  id int8 default nextval('nsl_global_seq') not null,
  version int8 not null,
  name varchar(255) not null,
  primary key (id)
);

create index Name_Tag_Name_Index on name_tag_name (name_id);

create index Name_Tag_Tag_Index on name_tag_name (tag_id);

alter table if exists name_tag
add constraint UK_o4su6hi7vh0yqs4c1dw0fsf1e  unique (name);

alter table if exists name_tag_name
add constraint FK_22wdc2pxaskytkgpdgpyok07n
foreign key (name_id)
references name;

alter table if exists name_tag_name
add constraint FK_2uiijd73snf6lh5s6a82yjfin
foreign key (tag_id)
references name_tag;

insert into name_tag (version, name) values (0, 'ACRA');
insert into name_tag (version, name) values (0, 'PBR');
insert into name_tag (version, name) values (0, 'Trade');

insert into name_tag_name (name_id, tag_id) (select n.id as name_id, t.id as tag_id from name n, name_tag t where n.name_type_id = 54347 and t.name = 'ACRA');
insert into name_tag_name (name_id, tag_id) (select n.id as name_id, t.id as tag_id from name n, name_tag t where n.name_type_id = 54348 and t.name = 'ACRA');
insert into name_tag_name (name_id, tag_id) (select n.id as name_id, t.id as tag_id from name n, name_tag t where n.name_type_id = 54349 and t.name = 'PBR');
insert into name_tag_name (name_id, tag_id) (select n.id as name_id, t.id as tag_id from name n, name_tag t where n.name_type_id = 54350 and t.name = 'PBR');
insert into name_tag_name (name_id, tag_id) (select n.id as name_id, t.id as tag_id from name n, name_tag t where n.name_type_id = 54351 and t.name = 'Trade');
insert into name_tag_name (name_id, tag_id) (select n.id as name_id, t.id as tag_id from name n, name_tag t where n.name_type_id = 54352 and t.name = 'Trade');

update name set name_type_id = 54344 where name_type_id in (54347,54349,54351);
update name set name_type_id = 54345 where name_type_id in (54348,54350,54352);

alter table name_type add COLUMN deprecated boolean default false not null;

update name_type set deprecated = true where id in (
  54347,
  54348,
  54349,
  54350,
  54351,
  54352
);

drop table nsl_simple_name;

create table nsl_simple_name (
  id int8 not null,
  apc_family varchar(255),
  apni boolean default false,
  author varchar(255),
  authority varchar(255),
  autonym boolean default false,
  base_name_author varchar(255),
  classifications varchar(255),
  created_at timestamp,
  created_by varchar(255),
  cultivar_name varchar(255),
  dup_of_id int8,
  ex_author varchar(255),
  ex_base_name_author varchar(255),
  family varchar(255),
  family_nsl_id int8,
  full_name_html varchar(2048) not null,
  genus varchar(255),
  genus_nsl_id int8,
  homonym boolean default false,
  hybrid boolean default false,
  infraspecies varchar(255),
  name varchar(255) not null,
  class varchar(255),
  name_element varchar(255),
  name_status_id int8 not null,
  subclass varchar(255),
  name_type varchar(255) not null,
  name_type_id int8 not null,
  nom_illeg boolean default false,
  nom_inval boolean default false,
  nom_stat varchar(255) not null,
  parent_nsl_id int8,
  proto_year int2,
  rank varchar(255) not null,
  rank_abbrev varchar(255),
  rank_id int8 not null,
  rank_sort_order int4,
  sanctioning_author varchar(255),
  second_parent_nsl_id int8,
  simple_name_html varchar(2048) not null,
  species varchar(255),
  species_nsl_id int8,
  taxon_name varchar(512) not null,
  transdate timestamp,
  updated_at timestamp,
  updated_by varchar(255),
  primary key (id)
);

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

update db_version set version = 4 where id = 1;
