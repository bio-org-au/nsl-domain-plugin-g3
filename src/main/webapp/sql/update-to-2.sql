    create table comment (
        id int8 default nextval('hibernate_sequence') not null,
        lock_version int8 default 0 not null,
        author_id int8,
        created_at timestamp with time zone not null,
        created_by varchar(50) not null,
        instance_id int8,
        name_id int8,
        reference_id int8,
        text text not null,
        updated_at timestamp with time zone not null,
        updated_by varchar(50) not null,
        primary key (id)
    );

    create table why_is_this_here (
        id int8 default nextval('nsl_global_seq') not null,
        lock_version int8 default 0 not null,
        name varchar(50) not null,
        sort_order int4 default 0 not null,
        primary key (id)
    );

    create table db_version (
        id int8 not null,
        version int4 not null,
        primary key (id)
    );

--     don't need to create name tree path table as it's already been created by the service layer

    alter table name drop COLUMN manuscript;
    alter table name add COLUMN why_is_this_here_id int8;
    alter table instance drop COLUMN verbatim_rank;
    alter table name ADD COLUMN verbatim_rank varchar(50);

    alter table if exists why_is_this_here
    add constraint UK_sv1q1i7xve7xgmkwvmdbeo1mb  unique (name);

    alter table if exists comment
    add constraint FK_9aq5p2jgf17y6b38x5ayd90oc
    foreign key (author_id)
    references author;

    alter table if exists comment
    add constraint FK_6oqj6vquqc33cyawn853hfu5g
    foreign key (instance_id)
    references instance;

    alter table if exists comment
    add constraint FK_h9t5eaaqhnqwrc92rhryyvdcf
    foreign key (name_id)
    references name;

    alter table if exists comment
    add constraint FK_3tfkdcmf6rg6hcyiu8t05er7x
    foreign key (reference_id)
    references reference;

    alter table if exists name
    add constraint FK_dqhn53mdh0n77xhsw7l5dgd38
    foreign key (why_is_this_here_id)
    references why_is_this_here;

    INSERT into why_is_this_here (name,lock_version) VALUES ('ANHSIR record', 0);
    INSERT INTO db_version (id, version) VALUES (1, 2);

    create index Comment_author_Index on comment (author_id);
    create index Comment_instance_Index on comment (instance_id);
    create index Comment_name_Index on comment (name_id);
    create index Comment_reference_Index on comment (reference_id);
    create index Name_author_Index on name (author_id);
    create index Name_baseAuthor_Index on name (base_author_id);
    create index Name_exAuthor_Index on name (ex_author_id);
    create index Name_exBaseAuthor_Index on name (ex_base_author_id);
    create index Name_sanctioningAuthor_Index on name (sanctioning_author_id);
    create index Name_whyIsThisHere_Index on name (why_is_this_here_id);


