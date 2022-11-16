create sequence hibernate_sequence start 1 increment 1;

create sequence nsl_global_seq start 1 increment 1;
create table author (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, duplicate_of_id int8, namespace_id int8 not null, ipni_id varchar(50), updated_by varchar(255) not null, source_id_string varchar(100), notes varchar(1000), full_name varchar(255), abbrev varchar(100), source_id int8, created_at timestamp with time zone not null, updated_at timestamp with time zone not null, name varchar(1000), source_system varchar(50), date_range varchar(50), created_by varchar(255) not null, uri text, valid_record boolean default false not null, primary key (id));
create table comment (id int8 default nextval('hibernate_sequence') not null, lock_version int8 default 0 not null, updated_by varchar(50) not null, text text not null, author_id int8, created_at timestamp with time zone not null, updated_at timestamp with time zone not null, name_id int8, created_by varchar(50) not null, instance_id int8, reference_id int8, primary key (id));
create table db_version (id int8 not null, version int4 not null, primary key (id));
create table delayed_jobs (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, created_at timestamp with time zone not null, locked_at timestamp with time zone, last_error text, queue varchar(4000), priority numeric(19, 2), failed_at timestamp with time zone, updated_at timestamp with time zone not null, handler text, locked_by varchar(4000), run_at timestamp with time zone, attempts numeric(19, 2), primary key (id));
create table dist_entry (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, display varchar(255) not null, region_id int8 not null, sort_order int4 default 0 not null, primary key (id));
create table dist_entry_dist_status (dist_entry_status_id int8 not null, dist_status_id int8);
create table dist_region (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, def_link varchar(255), description_html text, sort_order int4 default 0 not null, name varchar(255) not null, deprecated boolean default false not null, primary key (id));
create table dist_status (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, def_link varchar(255), description_html text, sort_order int4 default 0 not null, name varchar(255) not null, deprecated boolean default false not null, primary key (id));
create table dist_status_dist_status (dist_status_combining_status_id int8 not null, dist_status_id int8);
create table event_record (id int8 not null, version int8 not null, created_at timestamp with time zone not null, updated_at timestamp with time zone not null, updated_by varchar(50) not null, type text not null, created_by varchar(50) not null, dealt_with boolean default false not null, data jsonb not null, primary key (id));
create table id_mapper (id int8 not null, from_id int8 not null, to_id int8, system varchar(20) not null, namespace_id int8 not null, primary key (id));
create table instance (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, nomenclatural_status varchar(50), bhl_url varchar(4000), namespace_id int8 not null, updated_by varchar(1000) not null, source_id_string varchar(100), draft boolean default false not null, page varchar(255), cites_id int8, verbatim_name_string varchar(255), source_id int8, created_at timestamp with time zone not null, page_qualifier varchar(255), cited_by_id int8, name_id int8 not null, updated_at timestamp with time zone not null, source_system varchar(50), created_by varchar(50) not null, instance_type_id int8 not null, cached_synonymy_html text, uri text, valid_record boolean default false not null, parent_id int8, reference_id int8 not null, primary key (id));
create table instance_note (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, namespace_id int8 not null, updated_by varchar(50) not null, source_id_string varchar(100), source_id int8, created_at timestamp with time zone not null, updated_at timestamp with time zone not null, source_system varchar(50), value varchar(4000) not null, created_by varchar(50) not null, instance_note_key_id int8 not null, instance_id int8 not null, primary key (id));
create table instance_note_key (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, rdf_id varchar(50), description_html text, sort_order int4 default 0 not null, name varchar(255) not null, deprecated boolean default false not null, primary key (id));
create table instance_resources (resource_id int8 not null, instance_id int8 not null, primary key (instance_id, resource_id));
create table instance_type (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, rdf_id varchar(50), description_html text, bidirectional boolean default false not null, secondary_instance boolean default false not null, misapplied boolean default false not null, relationship boolean default false not null, unsourced boolean default false not null, synonym boolean default false not null, protologue boolean default false not null, sort_order int4 default 0 not null, primary_instance boolean default false not null, taxonomic boolean default false not null, standalone boolean default false not null, name varchar(255) not null, pro_parte boolean default false not null, nomenclatural boolean default false not null, doubtful boolean default false not null, has_label varchar(255) not null, deprecated boolean default false not null, citing boolean default false not null, of_label varchar(255) not null, primary key (id));
create table language (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, iso6391code varchar(2), name varchar(50) not null, iso6393code varchar(3) not null, primary key (id));
create table media (id int8 default nextval('hibernate_sequence') not null, version int8 not null, mime_type text not null, file_name text not null, data bytea not null, description text not null, primary key (id));
create table name (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, family_id int8, duplicate_of_id int8, sanctioning_author_id int8, name_element varchar(255), namespace_id int8 not null, name_rank_id int8 not null, updated_by varchar(50) not null, source_id_string varchar(100), published_year int4, full_name varchar(512), source_dup_of_id int8, author_id int8, source_id int8, changed_combination boolean default false not null, ex_author_id int8, created_at timestamp with time zone not null, ex_base_author_id int8, sort_name varchar(250), second_parent_id int8, name_status_id int8 not null, simple_name varchar(250), updated_at timestamp with time zone not null, source_system varchar(50), apni_json jsonb, simple_name_html varchar(2048), base_author_id int8, verbatim_rank varchar(50), created_by varchar(50) not null, orth_var boolean default false not null, name_type_id int8 not null, status_summary varchar(50), uri text, valid_record boolean default false not null, name_path text not null, full_name_html varchar(2048), parent_id int8, primary key (id));
create table name_category (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, rdf_id varchar(50), description_html text, requires_family boolean default false not null, takes_rank boolean default false not null, parent_1_help_text text, takes_verbatim_rank boolean default false not null, parent_2_help_text text, takes_hybrid_scoped_parent boolean default false not null, requires_name_element boolean default false not null, sort_order int4 default 0 not null, requires_higher_ranked_parent boolean default false not null, takes_cultivar_scoped_parent boolean default false not null, name varchar(50) not null, max_parents_allowed int4 not null, takes_name_element boolean default false not null, min_parents_required int4 not null, takes_authors boolean default false not null, takes_author_only boolean default false not null, primary key (id));
create table name_group (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, rdf_id varchar(50), description_html text, name varchar(50), primary key (id));
create table name_rank (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, rdf_id varchar(50), description_html text, italicize boolean default false not null, visible_in_name boolean default true not null, has_parent boolean default false not null, display_name text not null, abbrev varchar(20) not null, name_group_id int8 not null, sort_order int4 default 0 not null, use_verbatim_rank boolean default false not null, name varchar(50) not null, major boolean default false not null, deprecated boolean default false not null, parent_rank_id int8, primary key (id));
create table name_resources (resource_id int8 not null, name_id int8 not null, primary key (name_id, resource_id));
create table name_status (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, rdf_id varchar(50), description_html text, nom_illeg boolean default false not null, display boolean default true not null, name_group_id int8 not null, name_status_id int8, name varchar(50), deprecated boolean default false not null, nom_inval boolean default false not null, primary key (id));
create table name_tag (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, name varchar(255) not null, primary key (id));
create table name_tag_name (name_id int8 not null, tag_id int8 not null, created_at timestamp with time zone not null, updated_at timestamp with time zone not null, updated_by varchar(255) not null, created_by varchar(255) not null, primary key (name_id, tag_id));
create table name_type (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, rdf_id varchar(50), description_html text, cultivar boolean default false not null, name_category_id int8 not null, formula boolean default false not null, autonym boolean default false not null, name_group_id int8 not null, connector varchar(1), sort_order int4 default 0 not null, hybrid boolean default false not null, scientific boolean default false not null, name varchar(255) not null, deprecated boolean default false not null, primary key (id));
create table namespace (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, rdf_id varchar(50), description_html text, name varchar(255) not null, primary key (id));
create table notification (id int8 not null, version int8 not null, message varchar(255) not null, object_id int8, primary key (id));
create table ref_author_role (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, rdf_id varchar(50), description_html text, name varchar(255) not null, primary key (id));
create table ref_type (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, rdf_id varchar(50), description_html text, use_parent_details boolean default false not null, name varchar(50) not null, parent_optional boolean default false not null, parent_id int8, primary key (id));
create table reference (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, display_title varchar(2000) not null, duplicate_of_id int8, publisher varchar(1000), verbatim_reference varchar(1000), publication_date varchar(50), ref_author_role_id int8 not null, citation varchar(4000), bhl_url varchar(4000), edition varchar(100), published boolean default false not null, published_location varchar(1000), namespace_id int8 not null, doi varchar(255), updated_by varchar(1000) not null, source_id_string varchar(100), notes varchar(1000), isbn varchar(16), tl2 varchar(30), language_id int8 not null, author_id int8 not null, issn varchar(16), iso_publication_date varchar(10), source_id int8, volume varchar(100), title varchar(2000) not null, verbatim_citation varchar(2000), created_at timestamp with time zone not null, verbatim_author varchar(1000), ref_type_id int8 not null, abbrev_title varchar(2000), updated_at timestamp with time zone not null, source_system varchar(50), created_by varchar(255) not null, year int4, citation_html varchar(4000), pages varchar(1000), uri text, valid_record boolean default false not null, parent_id int8, primary key (id));
create table resource (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, path varchar(2400) not null, updated_by varchar(50) not null, resource_type_id int8 not null, created_at timestamp with time zone not null, updated_at timestamp with time zone not null, created_by varchar(50) not null, site_id int8 not null, primary key (id));
create table resource_type (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, display boolean default false not null, rdf_id varchar(50), name text not null, css_icon text, deprecated boolean default false not null, media_icon_id int8, description text not null, primary key (id));
create table shard_config (id int8 default nextval('hibernate_sequence') not null, use_notes varchar(255), name varchar(255) not null, value varchar(5000) not null, deprecated boolean default false not null, primary key (id));
create table site (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, created_at timestamp with time zone not null, url varchar(500) not null, name varchar(100) not null, updated_at timestamp with time zone not null, updated_by varchar(50) not null, created_by varchar(50) not null, description varchar(1000) not null, primary key (id));
create table tree (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, description_html Text default 'Edit me' not null, link_to_home_page Text, reference_id int8, config jsonb not null, host_name Text not null, current_tree_version_id int8, default_draft_tree_version_id int8, accepted_tree boolean default false not null, name Text not null, group_name Text not null, primary key (id));
create table tree_element (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, instance_link Text not null, profile jsonb not null, rank varchar(50) not null, name_element varchar(255) not null, previous_element_id int8, updated_by varchar(255) not null, name_link Text not null, display_html Text not null, synonyms jsonb, excluded boolean default false not null, source_shard Text not null, synonyms_html Text not null, updated_at timestamp with time zone not null, simple_name Text not null, instance_id int8 not null, name_id int8 not null, source_element_link Text, primary key (id));
create table tree_element_distribution_entries (dist_entry_id int8 not null, tree_element_id int8 not null, primary key (tree_element_id, dist_entry_id));
create table tree_version (id int8 default nextval('nsl_global_seq') not null, lock_version int8 default 0 not null, previous_version_id int8, published_by varchar(100), tree_id int8 not null, published boolean default false not null, published_at timestamp with time zone, created_at timestamp with time zone not null, log_entry Text, created_by varchar(255) not null, draft_name Text not null, primary key (id));
create table tree_version_element (element_link Text not null, taxon_link Text not null, taxon_id int8 not null, updated_by varchar(255) not null, depth int4 not null, tree_element_id int8 not null, tree_path Text not null, updated_at timestamp with time zone not null, merge_conflict boolean default false not null, name_path Text not null, tree_version_id int8 not null, parent_id Text, primary key (element_link));
create index Auth_Source_Index on author (namespace_id, source_id, source_system);
create index Auth_Source_String_Index on author (source_id_string);
create index Author_Abbrev_Index on author (abbrev);
create index Author_Name_Index on author (name);
create index Auth_System_Index on author (source_system);
alter table if exists author add constraint UK_9kovg6nyb11658j2tv2yv4bsi unique (abbrev);
create index Comment_author_Index on comment (author_id);
create index Comment_name_Index on comment (name_id);
create index Comment_instance_Index on comment (instance_id);
create index Comment_reference_Index on comment (reference_id);
alter table if exists dist_region add constraint UK_dtx2gm3sr51pk6b0fysp1ij9r unique (name);
alter table if exists dist_status add constraint UK_l9d1nxtobmh259wkmxkduec09 unique (name);
create index event_record_created_index on event_record (created_at);
create index event_record_index on event_record (created_at, type, dealt_with);
create index event_record_type_index on event_record (type);
create index event_record_dealt_index on event_record (dealt_with);
create index id_mapper_from_Index on id_mapper (from_id, system, namespace_id);
alter table if exists id_mapper add constraint UK630173311065655b761a1f3ca603 unique (to_id, from_id);
create index Instance_Source_Index on instance (namespace_id, source_id, source_system);
create index Instance_Source_String_Index on instance (source_id_string);
create index Instance_Cites_Index on instance (cites_id);
create index Instance_CitedBy_Index on instance (cited_by_id);
create index Instance_Name_Index on instance (name_id);
create index Instance_System_Index on instance (source_system);
create index Instance_InstanceType_Index on instance (instance_type_id);
create index Instance_Parent_Index on instance (parent_id);
create index Instance_Reference_Index on instance (reference_id);
create index Note_Source_Index on instance_note (namespace_id, source_id, source_system);
create index Note_Source_String_Index on instance_note (source_id_string);
create index Note_System_Index on instance_note (source_system);
create index Note_Key_Index on instance_note (instance_note_key_id);
create index Note_Instance_Index on instance_note (instance_id);
alter table if exists instance_note_key add constraint UK_a0justk7c77bb64o6u1riyrlh unique (name);
alter table if exists instance_type add constraint UK_j5337m9qdlirvd49v4h11t1lk unique (name);
alter table if exists language add constraint UK_hghw87nl0ho38f166atlpw2hy unique (iso6391code);
alter table if exists language add constraint UK_g8hr207ijpxlwu10pewyo65gv unique (name);
alter table if exists language add constraint UK_rpsahneqboogcki6p1bpygsua unique (iso6393code);
create index Name_sanctioningAuthor_Index on name (sanctioning_author_id);
create index Name_Name_Element_Index on name (name_element);
create index Name_Source_Index on name (namespace_id, source_id, source_system);
create index Name_Rank_Index on name (name_rank_id);
create index Name_Source_String_Index on name (source_id_string);
create index Name_Full_Name_Index on name (full_name);
create index Name_author_Index on name (author_id);
create index Name_exAuthor_Index on name (ex_author_id);
create index Name_exBaseAuthor_Index on name (ex_base_author_id);
create index name_second_parent_id_Index on name (second_parent_id);
create index Name_Status_Index on name (name_status_id);
create index Name_Simple_Name_Index on name (simple_name);
create index Name_System_Index on name (source_system);
create index Name_baseAuthor_Index on name (base_author_id);
create index Name_Type_Index on name (name_type_id);
create index name_name_path_Index on name (name_path);
create index name_parent_id_Index on name (parent_id);
alter table if exists name_category add constraint UK_rxqxoenedjdjyd4x7c98s59io unique (name);
alter table if exists name_group add constraint UK_5185nbyw5hkxqyyqgylfn2o6d unique (name);
alter table if exists name_tag add constraint UK_o4su6hi7vh0yqs4c1dw0fsf1e unique (name);
create index Name_Tag_Name_Index on name_tag_name (name_id);
create index Name_Tag_Tag_Index on name_tag_name (tag_id);
alter table if exists namespace add constraint UK_eq2y9mghytirkcofquanv5frf unique (name);
alter table if exists ref_author_role add constraint UK_l95kedbafybjpp3h53x8o9fke unique (name);
alter table if exists ref_type add constraint UK_4fp66uflo7rgx59167ajs0ujv unique (name);
create index Reference_AuthorRole_Index on reference (ref_author_role_id);
create index Ref_Source_Index on reference (namespace_id, source_id, source_system);
create index Ref_Source_String_Index on reference (source_id_string);
create index Reference_Author_Index on reference (author_id);
create index Reference_Type_Index on reference (ref_type_id);
create index Ref_System_Index on reference (source_system);
create index Reference_Parent_Index on reference (parent_id);
alter table if exists reference add constraint UK_kqwpm0crhcq4n9t9uiyfxo2df unique (doi);
alter table if exists shard_config add constraint UK_e6nvv3knohggqpdn247bodpxy unique (name);
alter table if exists tree add constraint UK_92xj3n7tgp4h7abxijoo7skmp unique (name);
create index tree_element_previous_index on tree_element (previous_element_id);
create index tree_simple_name_index on tree_element (simple_name);
create index tree_element_instance_index on tree_element (instance_id);
create index tree_element_name_index on tree_element (name_id);
create index tree_version_element_link_index on tree_version_element (element_link);
create index tree_version_element_taxon_link_index on tree_version_element (taxon_link);
create index tree_version_element_taxon_id_index on tree_version_element (taxon_id);
create index tree_version_element_element_index on tree_version_element (tree_element_id);
create index tree_path_index on tree_version_element (tree_path);
create index tree_name_path_index on tree_version_element (name_path);
create index tree_version_element_version_index on tree_version_element (tree_version_id);
create index tree_version_element_parent_index on tree_version_element (parent_id);
alter table if exists author add constraint FK9b0hq00gn3wnjcdm2f8nc50s7 foreign key (duplicate_of_id) references author;
alter table if exists author add constraint FKo84wd269xaoxcrtdp8lrt44b6 foreign key (namespace_id) references namespace;
alter table if exists comment add constraint FK1jjloo6xwf7kl33cho74gtmi5 foreign key (author_id) references author;
alter table if exists comment add constraint FK3u9gda2xrobccq6x51cq2ce82 foreign key (name_id) references name;
alter table if exists comment add constraint FK6syup6iqowo6sw9k4eitqcjwh foreign key (instance_id) references instance;
alter table if exists comment add constraint FK5khmonmjiihwojlnql2fclhk8 foreign key (reference_id) references reference;
alter table if exists dist_entry add constraint FK4t6cnjnqkmo3gfiamynvx3j4a foreign key (region_id) references dist_region;
alter table if exists dist_entry_dist_status add constraint FKk48e159lcd0rj014cirn9ri3 foreign key (dist_status_id) references dist_status;
alter table if exists dist_entry_dist_status add constraint FK1j0wul4a4l358rxyvgvn1lf1s foreign key (dist_entry_status_id) references dist_entry;
alter table if exists dist_status_dist_status add constraint FKfq8lvxy23dr83dw5v305d79iy foreign key (dist_status_id) references dist_status;
alter table if exists dist_status_dist_status add constraint FKabw62nt00yhmc1h7h4cjhhqpb foreign key (dist_status_combining_status_id) references dist_status;
alter table if exists id_mapper add constraint FKk5mpmddy4bu9at8iyj5l3588j foreign key (namespace_id) references namespace;
alter table if exists instance add constraint FKcemp36igwtqrm8qkcdx5hjvq5 foreign key (namespace_id) references namespace;
alter table if exists instance add constraint FKq4pgk7rq7gm8oma1s9ab4ffls foreign key (cites_id) references instance;
alter table if exists instance add constraint FKmqpjnlhmjn9mop6yvyh9pmjxa foreign key (cited_by_id) references instance;
alter table if exists instance add constraint FKi9rjvhyybfdqqkjawtqdn6vgh foreign key (name_id) references name;
alter table if exists instance add constraint FK84tgbyn5csp47ht5h2efmdw4o foreign key (instance_type_id) references instance_type;
alter table if exists instance add constraint FK5m3b449qs2lo24n6yx7m1hmt8 foreign key (parent_id) references instance;
alter table if exists instance add constraint FKjnyycl6cw6g735jm9sw4g6070 foreign key (reference_id) references reference;
alter table if exists instance_note add constraint FKkye1i1nnvmge7047asc87em0o foreign key (namespace_id) references namespace;
alter table if exists instance_note add constraint FKjshle8hwjkavnc6pqtbnnbwn0 foreign key (instance_note_key_id) references instance_note_key;
alter table if exists instance_note add constraint FK3fpit98cinx5n0u1dhukti5b0 foreign key (instance_id) references instance;
alter table if exists instance_resources add constraint FKd0retp8swqg9r1cobg8803r8f foreign key (instance_id) references instance;
alter table if exists instance_resources add constraint FKaf34bw8h0shwdbme57amud7ca foreign key (resource_id) references resource;
alter table if exists name add constraint FKdtalpdbwhlb1d96ajjf7qtvxv foreign key (family_id) references name;
alter table if exists name add constraint FK2dc7phc3mx5vbtjk1v895ia4e foreign key (duplicate_of_id) references name;
alter table if exists name add constraint FK8sowuvuepistgxb4vrhdl9fi9 foreign key (sanctioning_author_id) references author;
alter table if exists name add constraint FKf8129yfqm6i7nj1eglys78k7v foreign key (namespace_id) references namespace;
alter table if exists name add constraint FKo1ewfcy384g3eipih9ix7g31o foreign key (name_rank_id) references name_rank;
alter table if exists name add constraint FKbt9vwpa492bg9ortwdu7qg9ki foreign key (author_id) references author;
alter table if exists name add constraint FKgvy0vvbhyta6ba5xi618faj4y foreign key (ex_author_id) references author;
alter table if exists name add constraint FKbic5p63d2m5qs37ch2atxl738 foreign key (ex_base_author_id) references author;
alter table if exists name add constraint FKl2k7nw7kjre5xj50sllv59ple foreign key (second_parent_id) references name;
alter table if exists name add constraint FKkmvj4ti1war8v0oa0d0u65b2r foreign key (name_status_id) references name_status;
alter table if exists name add constraint FK7dd4clytuja1mpi7m4bp69tr8 foreign key (base_author_id) references author;
alter table if exists name add constraint FKs6bgm8qxdjuu75m4akt2htnhi foreign key (name_type_id) references name_type;
alter table if exists name add constraint FK6d8l40x3ies10jx70laft58ww foreign key (parent_id) references name;
alter table if exists name_rank add constraint FKlyletq1bg7yfdr9lbfbm6e92j foreign key (name_group_id) references name_group;
alter table if exists name_rank add constraint FKo7aiq7ncbih4ba9lobo1kq760 foreign key (parent_rank_id) references name_rank;
alter table if exists name_resources add constraint FKed0uws76yim98cwseqb42ldst foreign key (name_id) references name;
alter table if exists name_resources add constraint FKnmuu2n0mg52it1rjjcysyrcqj foreign key (resource_id) references resource;
alter table if exists name_status add constraint FKervak5dftos3nnv4uy3s8h4e2 foreign key (name_group_id) references name_group;
alter table if exists name_status add constraint FKch4l1s7y7jdg3rl87xfcsx1qd foreign key (name_status_id) references name_status;
alter table if exists name_tag_name add constraint FKjo146r0r2axga773x4wwb56m2 foreign key (name_id) references name;
alter table if exists name_tag_name add constraint FKae8rvf6p5lg670jmu5cnxxy5y foreign key (tag_id) references name_tag;
alter table if exists name_type add constraint FKbob2tj6aiedx5v8xdr48k53xo foreign key (name_category_id) references name_category;
alter table if exists name_type add constraint FK1quk620nq2otf900mj50vl177 foreign key (name_group_id) references name_group;
alter table if exists ref_type add constraint FK96x5oymq6kavr5ns56w4syump foreign key (parent_id) references ref_type;
alter table if exists reference add constraint FKeotgobxgn1jqdkokwf2qhurwq foreign key (duplicate_of_id) references reference;
alter table if exists reference add constraint FK6pb8cx0ghd9bjtuh5ma47nafw foreign key (ref_author_role_id) references ref_author_role;
alter table if exists reference add constraint FK5ymanxc5t2rdw02q64vbbp2q1 foreign key (namespace_id) references namespace;
alter table if exists reference add constraint FKsb053ig13jhnvh33j6osrn373 foreign key (language_id) references language;
alter table if exists reference add constraint FKr54wh95iw9ueajtq1hg5t9sbd foreign key (author_id) references author;
alter table if exists reference add constraint FKj8h3i02kc0sfjyjn2w85deycv foreign key (ref_type_id) references ref_type;
alter table if exists reference add constraint FK3l0r03hlsl95wq7fewoi2r27q foreign key (parent_id) references reference;
alter table if exists resource add constraint FKbma5417n022ufdra8d99qscxv foreign key (resource_type_id) references resource_type;
alter table if exists resource add constraint FKljh7ccqusw9crs0ia0pbog72x foreign key (site_id) references site;
alter table if exists resource_type add constraint FKlktm0acyftrbx76swnuhyaey6 foreign key (media_icon_id) references media;
alter table if exists tree add constraint FKevwmdnjbrryqh2w39lmf1mgap foreign key (current_tree_version_id) references tree_version;
alter table if exists tree add constraint FKsojbhasi69wky2t75ak2x08cq foreign key (default_draft_tree_version_id) references tree_version;
alter table if exists tree_element add constraint FKsybibf7p563u984r0jy3ryslb foreign key (previous_element_id) references tree_element;
alter table if exists tree_element_distribution_entries add constraint FK2ligrmtx0lsevxakkmw4r782l foreign key (tree_element_id) references tree_element;
alter table if exists tree_element_distribution_entries add constraint FKskod03l7q1b16n01sx6u7s7om foreign key (dist_entry_id) references dist_entry;
alter table if exists tree_version add constraint FKnj28y8aqmyq45vhbwt5xqn28w foreign key (previous_version_id) references tree_version;
alter table if exists tree_version add constraint FKa1nt4892e09kv1mb6r5snofff foreign key (tree_id) references tree;
alter table if exists tree_version_element add constraint FKpahqiiilyjisux0c8y79gcq1s foreign key (tree_element_id) references tree_element;
alter table if exists tree_version_element add constraint FKieebl82akj84ei2hjyj9h7h0y foreign key (tree_version_id) references tree_version;
alter table if exists tree_version_element add constraint FK25amft8ksmj1ic5tmhslmieeu foreign key (parent_id) references tree_version_element;

-- audit.sql
-- An audit history is important on most tables. Provide an audit trigger that logs to
-- a dedicated audit table for the major relations.
--
-- This file should be generic and not depend on application roles or structures,
-- as it's being listed here:
--
--    https://wiki.postgresql.org/wiki/Audit_trigger_91plus
--
-- This trigger was originally based on
--   http://wiki.postgresql.org/wiki/Audit_trigger
-- but has been completely rewritten.
--
-- Should really be converted into a relocatable EXTENSION, with control and upgrade files.

CREATE EXTENSION IF NOT EXISTS hstore;

CREATE SCHEMA if NOT EXISTS audit;

drop table if exists audit.logged_actions cascade;

REVOKE ALL ON SCHEMA audit FROM public;

COMMENT ON SCHEMA audit IS 'Out-of-table audit/history logging tables and trigger functions';

--
-- Audited data. Lots of information is available, it's just a matter of how much
-- you really want to record. See:
--
--   http://www.postgresql.org/docs/9.1/static/functions-info.html
--
-- Remember, every column you add takes up more audit table space and slows audit
-- inserts.
--
-- Every index you add has a big impact too, so avoid adding indexes to the
-- audit table unless you REALLY need them. The hstore GIST indexes are
-- particularly expensive.
--
-- It is sometimes worth copying the audit table, or a coarse subset of it that
-- you're interested in, into a temporary table where you CREATE any useful
-- indexes and do your analysis.
--
CREATE TABLE audit.logged_actions (
  event_id bigserial primary key,
  schema_name text not null,
  table_name text not null,
  relid oid not null,
  session_user_name text,
  action_tstamp_tx TIMESTAMP WITH TIME ZONE NOT NULL,
  action_tstamp_stm TIMESTAMP WITH TIME ZONE NOT NULL,
  action_tstamp_clk TIMESTAMP WITH TIME ZONE NOT NULL,
  transaction_id bigint,
  application_name text,
  client_addr inet,
  client_port integer,
  client_query text,
  action TEXT NOT NULL CHECK (action IN ('I','D','U', 'T')),
  row_data hstore,
  changed_fields hstore,
  statement_only boolean not null,
  id int8
);

REVOKE ALL ON audit.logged_actions FROM public;

COMMENT ON TABLE audit.logged_actions IS 'History of auditable actions on audited tables, from audit.if_modified_func()';
COMMENT ON COLUMN audit.logged_actions.event_id IS 'Unique identifier for each auditable event';
COMMENT ON COLUMN audit.logged_actions.schema_name IS 'Database schema audited table for this event is in';
COMMENT ON COLUMN audit.logged_actions.table_name IS 'Non-schema-qualified table name of table event occured in';
COMMENT ON COLUMN audit.logged_actions.relid IS 'Table OID. Changes with drop/create. Get with ''tablename''::regclass';
COMMENT ON COLUMN audit.logged_actions.session_user_name IS 'Login / session user whose statement caused the audited event';
COMMENT ON COLUMN audit.logged_actions.action_tstamp_tx IS 'Transaction start timestamp for tx in which audited event occurred';
COMMENT ON COLUMN audit.logged_actions.action_tstamp_stm IS 'Statement start timestamp for tx in which audited event occurred';
COMMENT ON COLUMN audit.logged_actions.action_tstamp_clk IS 'Wall clock time at which audited event''s trigger call occurred';
COMMENT ON COLUMN audit.logged_actions.transaction_id IS 'Identifier of transaction that made the change. May wrap, but unique paired with action_tstamp_tx.';
COMMENT ON COLUMN audit.logged_actions.client_addr IS 'IP address of client that issued query. Null for unix domain socket.';
COMMENT ON COLUMN audit.logged_actions.client_port IS 'Remote peer IP port address of client that issued query. Undefined for unix socket.';
COMMENT ON COLUMN audit.logged_actions.client_query IS 'Top-level query that caused this auditable event. May be more than one statement.';
COMMENT ON COLUMN audit.logged_actions.application_name IS 'Application name set when this audit event occurred. Can be changed in-session by client.';
COMMENT ON COLUMN audit.logged_actions.action IS 'Action type; I = insert, D = delete, U = update, T = truncate';
COMMENT ON COLUMN audit.logged_actions.row_data IS 'Record value. Null for statement-level trigger. For INSERT this is the new tuple. For DELETE and UPDATE it is the old tuple.';
COMMENT ON COLUMN audit.logged_actions.changed_fields IS 'New values of fields changed by UPDATE. Null except for row-level UPDATE events.';
COMMENT ON COLUMN audit.logged_actions.statement_only IS '''t'' if audit event is from an FOR EACH STATEMENT trigger, ''f'' for FOR EACH ROW';

CREATE INDEX logged_actions_relid_idx ON audit.logged_actions(relid);
CREATE INDEX logged_actions_action_tstamp_tx_idx ON audit.logged_actions using btree(action_tstamp_tx);
CREATE INDEX logged_actions_action_idx ON audit.logged_actions(action);
CREATE INDEX logged_actions_id_idx ON audit.logged_actions(id);

CREATE OR REPLACE FUNCTION audit.if_modified_func() RETURNS TRIGGER AS $body$
DECLARE
    audit_row audit.logged_actions;
    excluded_cols text[] = ARRAY[]::text[];
    included_cols text[];
    xtra_cols text[];
    monitored_fields hstore;
BEGIN
    IF TG_WHEN <> 'AFTER' THEN
        RAISE EXCEPTION 'audit.if_modified_func() may only run as an AFTER trigger';
    END IF;
    audit_row = ROW(
        nextval('audit.logged_actions_event_id_seq'), -- event_id
        TG_TABLE_SCHEMA::text,                        -- schema_name
        TG_TABLE_NAME::text,                          -- table_name
        TG_RELID,                                     -- relation OID for much quicker searches
        session_user::text,                           -- session_user_name
        current_timestamp,                            -- action_tstamp_tx
        statement_timestamp(),                        -- action_tstamp_stm
        clock_timestamp(),                            -- action_tstamp_clk
        txid_current(),                               -- transaction ID
        current_setting('application_name'),          -- client application
        inet_client_addr(),                           -- client_addr
        inet_client_port(),                           -- client_port
        current_query(),                              -- top-level query or queries (if multistatement) from client
        substring(TG_OP,1,1),                         -- action
        NULL, NULL,                                   -- row_data, changed_fields
        'f',                                           -- statement_only
        NULL                                        -- id of tuple
        );

    IF NOT TG_ARGV[0]::boolean IS DISTINCT FROM 'f'::boolean THEN
        audit_row.client_query = NULL;
    END IF;

    IF TG_LEVEL = 'ROW' THEN
        IF TG_ARGV[1] = 'i' THEN
            included_cols = TG_ARGV[2]::text[];
        ELSIF TG_ARGV[1] = 'e' THEN
            excluded_cols = TG_ARGV[2]::text[];
        END IF;
        xtra_cols = TG_ARGV[3]::text[];
        IF TG_OP = 'UPDATE' THEN
            audit_row.row_data = hstore(OLD.*);
            monitored_fields = (slice(hstore(NEW.*),included_cols) - audit_row.row_data) - excluded_cols;
            audit_row.changed_fields = monitored_fields || slice(hstore(NEW.*),xtra_cols);
            IF monitored_fields = hstore('') THEN
                -- All changed fields are ignored. Skip this update.
                RETURN NULL;
            END IF;
        ELSIF TG_OP = 'DELETE' THEN
            audit_row.row_data = (slice(hstore(OLD.*),included_cols) - excluded_cols) || slice(hstore(OLD.*),xtra_cols);
        ELSIF TG_OP = 'INSERT' THEN
            audit_row.row_data = (slice(hstore(NEW.*),included_cols) - excluded_cols) || slice(hstore(NEW.*),xtra_cols);
        END IF;
    ELSIF (TG_LEVEL = 'STATEMENT' AND TG_OP IN ('INSERT','UPDATE','DELETE','TRUNCATE')) THEN
        audit_row.statement_only = 't';
    ELSE
        RAISE EXCEPTION '[audit.if_modified_func] - Trigger func added as trigger for unhandled case: %, %',TG_OP, TG_LEVEL;
        RETURN NULL;
    END IF;
    INSERT INTO audit.logged_actions VALUES (audit_row.*);
    RETURN NULL;
END;
$body$
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public;

COMMENT ON FUNCTION audit.if_modified_func() IS $body$
Track changes to a table at the statement and/or row level.

Optional parameters to trigger in CREATE TRIGGER call:

param 0: boolean, whether to log the query text. Default 't'.

param 1: text[], columns to ignore in updates. Default [].

         Updates to ignored cols are omitted from changed_fields.

         Updates with only ignored cols changed are not inserted
         into the audit log.

         Almost all the processing work is still done for updates
         that ignored. If you need to save the load, you need to use
         WHEN clause on the trigger instead.

         No warning or error is issued if ignored_cols contains columns
         that do not exist in the target table. This lets you specify
         a standard set of ignored columns.

There is no parameter to disable logging of values. Add this trigger as
a 'FOR EACH STATEMENT' rather than 'FOR EACH ROW' trigger if you do not
want to log row values.

Note that the user name logged is the login role for the session. The audit trigger
cannot obtain the active role because it is reset by the SECURITY DEFINER invocation
of the audit trigger its self.
$body$;



CREATE OR REPLACE FUNCTION audit.if_modified_tree_element() RETURNS TRIGGER AS $body$
DECLARE
    audit_row audit.logged_actions;
    excluded_cols text[] = ARRAY[]::text[];
    included_cols text[];
    xtra_cols text[];
    monitored_fields hstore;
    old_distribution text;
    old_comment text;
    new_distribution text;
    new_comment text;
    updated_at text;
    updated_by text;
    tree record;
BEGIN
    select * from tree into tree;
    IF TG_WHEN <> 'AFTER' THEN
        RAISE EXCEPTION 'audit.if_modified_func() may only run as an AFTER trigger';
    END IF;
    audit_row = ROW(
        nextval('audit.logged_actions_event_id_seq'), -- event_id
        TG_TABLE_SCHEMA::text,                        -- schema_name
        TG_TABLE_NAME::text,                          -- table_name
        TG_RELID,                                     -- relation OID for much quicker searches
                session_user::text,                           -- session_user_name
                current_timestamp,                            -- action_tstamp_tx
        statement_timestamp(),                        -- action_tstamp_stm
        clock_timestamp(),                            -- action_tstamp_clk
        txid_current(),                               -- transaction ID
        current_setting('application_name'),          -- client application
        inet_client_addr(),                           -- client_addr
        inet_client_port(),                           -- client_port
        current_query(),                              -- top-level query or queries (if multistatement) from client
        substring(TG_OP,1,1),                         -- action
        NULL, NULL,                                   -- row_data, changed_fields
        'f',                                           -- statement_only
        NULL                                        -- id of tuple
        );

    IF NOT TG_ARGV[0]::boolean IS DISTINCT FROM 'f'::boolean THEN
        audit_row.client_query = NULL;
    END IF;

    IF TG_LEVEL = 'ROW' THEN
        IF TG_ARGV[1] = 'i' THEN
            included_cols = TG_ARGV[2]::text[];
        ELSIF TG_ARGV[1] = 'e' THEN
            excluded_cols = TG_ARGV[2]::text[];
        END IF;
        xtra_cols = TG_ARGV[3]::text[];
        IF TG_OP = 'UPDATE' THEN
            audit_row.row_data = hstore(OLD.*);
            monitored_fields = (slice(hstore(NEW.*),included_cols) - audit_row.row_data) - excluded_cols;
            new_distribution = NEW.profile -> (tree.config ->> 'distribution_key') ->> 'value';
            new_comment = NEW.profile -> (tree.config ->> 'comment_key') ->> 'value';
            old_distribution = OLD.profile -> (tree.config ->> 'distribution_key') ->> 'value';
            old_comment = OLD.profile -> (tree.config ->> 'comment_key') ->> 'value';
            IF old_distribution <> new_distribution or old_distribution is null or new_distribution is null THEN
                updated_at = NEW.profile -> (tree.config ->> 'distribution_key') ->> 'updated_at';
                updated_at = REPLACE(updated_at, 'T', ' ');
                updated_by = NEW.profile -> (tree.config ->> 'distribution_key') ->> 'updated_by';
                audit_row.changed_fields = hstore(ARRAY['id', NEW.id::text, 'distribution', new_distribution, 'updated_at', updated_at, 'updated_by', updated_by]);
                updated_at = OLD.profile -> (tree.config ->> 'distribution_key') ->> 'updated_at';
                updated_at = REPLACE(updated_at, 'T', ' ');
                updated_by = OLD.profile -> (tree.config ->> 'distribution_key') ->> 'updated_by';
                audit_row.row_data = hstore(ARRAY['id', OLD.id::text, 'distribution', old_distribution, 'updated_at', updated_at, 'updated_by', updated_by]);
                INSERT INTO audit.logged_actions VALUES (audit_row.*);
            END IF;
            IF old_comment <> new_comment or old_comment is null or new_comment is null THEN
                audit_row.event_id = nextval('audit.logged_actions_event_id_seq');
                updated_at = NEW.profile -> (tree.config ->> 'comment_key') ->> 'updated_at';
                updated_at = REPLACE(updated_at, 'T', ' ');
                updated_by = NEW.profile -> (tree.config ->> 'comment_key') ->> 'updated_by';
                audit_row.changed_fields = hstore(ARRAY['id', NEW.id::text, 'comment', new_comment, 'updated_at', updated_at, 'updated_by', updated_by]);
                updated_at = OLD.profile -> (tree.config ->> 'comment_key') ->> 'updated_at';
                updated_at = REPLACE(updated_at, 'T', ' ');
                updated_by = OLD.profile -> (tree.config ->> 'comment_key') ->> 'updated_by';
                audit_row.row_data = hstore(ARRAY['id', OLD.id::text, 'comment', old_comment, 'updated_at', updated_at, 'updated_by', updated_by]);
                INSERT INTO audit.logged_actions VALUES (audit_row.*);
            END IF;
        ELSIF TG_OP = 'DELETE' THEN
        ELSIF TG_OP = 'INSERT' THEN
        END IF;
    ELSIF (TG_LEVEL = 'STATEMENT' AND TG_OP IN ('INSERT','UPDATE','DELETE','TRUNCATE')) THEN
        audit_row.statement_only = 't';
        INSERT INTO audit.logged_actions VALUES (audit_row.*);
    ELSE
        RAISE EXCEPTION '[audit.if_modified_func] - Trigger func added as trigger for unhandled case: %, %',TG_OP, TG_LEVEL;
        RETURN NULL;
    END IF;
    RETURN NULL;
END;
$body$
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET search_path = pg_catalog, public;

COMMENT ON FUNCTION apni.audit.if_modified_tree_element() IS $body$
Track changes to tree_element at the statement and/or row level.
$body$;

CREATE OR REPLACE FUNCTION audit.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean, column_style text, cols text[], xtra_cols text[], audit_func text) RETURNS void AS $body$
DECLARE
    stm_targets text = 'INSERT OR UPDATE OR DELETE OR TRUNCATE';
    _q_txt text;
    _cols_snip text = '';
    _xtra_cols_snip text = '';
    _style text = '';
BEGIN

    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_row ON ' || target_table;
    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_stm ON ' || target_table;
    IF audit_func IS NULL THEN
        audit_func = 'audit.if_modified_func';
    END IF;
    IF audit_rows THEN
        IF array_length(cols,1) > 0 THEN
            _cols_snip = ', ' || quote_literal(cols);
        END IF;
        IF array_length(xtra_cols,1) > 0 THEN
            _xtra_cols_snip = ', ' || quote_literal(xtra_cols);
        END IF;
        IF column_style IS NOT NULL THEN
            _style = ', ' || column_style;
        END IF;
        _q_txt = 'CREATE TRIGGER audit_trigger_row AFTER INSERT OR UPDATE OR DELETE ON ' ||
                 target_table ||
                 ' FOR EACH ROW EXECUTE PROCEDURE ' || audit_func || '(' ||
                 quote_literal(audit_query_text) || _style || _cols_snip || _xtra_cols_snip || ');';
        RAISE NOTICE '%',_q_txt;
        EXECUTE _q_txt;
        stm_targets = 'TRUNCATE';
    END IF;

    _q_txt = 'CREATE TRIGGER audit_trigger_stm AFTER ' || stm_targets || ' ON ' ||
             target_table ||
             ' FOR EACH STATEMENT EXECUTE PROCEDURE ' || audit_func || '('||
             quote_literal(audit_query_text) || ');';
    RAISE NOTICE '%',_q_txt;
    EXECUTE _q_txt;
END;
$body$
language 'plpgsql';

COMMENT ON FUNCTION audit.audit_table(regclass, boolean, boolean, text[]) IS $body$
Add auditing support to a table.

Arguments:
   target_table:     Table name, schema qualified if not on search_path
   audit_rows:       Record each row change, or only audit at a statement level
   audit_query_text: Record the text of the client query that triggered the audit event?
   ignored_cols:     Columns to exclude from update diffs, ignore updates that change only ignored cols.
$body$;

-- Pg doesn't allow variadic calls with 0 params, so provide a wrapper
CREATE OR REPLACE FUNCTION audit.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean) RETURNS void AS $body$
SELECT audit.audit_table($1, $2, $3, NULL, ARRAY[]::text[]);
$body$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION audit.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean, column_style text, cols text[], xtra_cols text[]) RETURNS void AS $body$
SELECT audit.audit_table($1, $2, $3, $4, $5, $6, 'audit.if_modified_func');
$body$ LANGUAGE SQL;

-- And provide a convenience call wrapper for the simplest case
-- of row-level logging with no excluded cols and query logging enabled.
--
CREATE OR REPLACE FUNCTION audit.audit_table(target_table regclass) RETURNS void AS $$
SELECT audit.audit_table($1, BOOLEAN 't', BOOLEAN 't');
$$ LANGUAGE 'sql';

COMMENT ON FUNCTION audit.audit_table(regclass) IS $body$
Add auditing support to the given table. Row-level changes will be logged with full client query text. No cols are ignored.
$body$;

-- set up triggers using the following selects after import
-- select * from information_schema.triggers;
--
-- select audit.audit_table('author');
-- select audit.audit_table('instance');
select audit.audit_table('author', 't', 't', 'i',
                         ARRAY['id', 'abbrev', 'duplicate_of_id', 'full_name', 'name', 'notes', 'ipni_id', 'valid_record']::text[],
                         ARRAY['created_at', 'created_by', 'updated_at', 'updated_by']::text[]);

select audit.audit_table('reference', 't', 't', 'i',
                         ARRAY['id', 'bhl_url', 'doi', 'duplicate_of_id', 'edition', 'isbn', 'iso_publication_date', 'issn',
                             'language_id', 'notes', 'pages', 'parent_id', 'publication_date', 'published', 'published_location',
                             'publisher', 'ref_author_role_id', 'ref_type_id', 'title', 'volume', 'year', 'tl2', 'valid_record',
                             'verbatim_author', 'verbatim_citation', 'verbatim_reference']::text[],
                         ARRAY['created_at', 'created_by', 'updated_at', 'updated_by']::text[]);

select audit.audit_table('name', 't', 't', 'i',
                         ARRAY['id', 'author_id', 'base_author_id', 'duplicate_of_id', 'ex_author_id', 'ex_base_author_id', 'family_id',
                             'full_name', 'name_rank_id', 'name_status_id', 'name_type_id', 'parent_id', 'sanctioning_author_id',
                             'second_parent_id', 'verbatim_name_string', 'orth_var', 'changed_combination',
                             'valid_record', 'published_year']::text[],
                         ARRAY['created_at', 'created_by', 'updated_at', 'updated_by']::text[]);

select audit.audit_table('comment', 't', 't', 'i',
                         ARRAY['id', 'author_id', 'name_id', 'reference_id', 'instance_id', 'text']::text[],
                         ARRAY['created_at', 'created_by', 'updated_at', 'updated_by']::text[]);

select audit.audit_table('instance', 't', 't', 'i',
                         ARRAY['id', 'bhl_url', 'cites_id', 'cited_by_id', 'draft', 'instance_type_id', 'name_id',
                             'page', 'page_qualifier', 'parent_id', 'reference_id',
                             'verbatim_name_string', 'nomenclatural_status', 'valid_record']::text[],
                         ARRAY['created_at', 'created_by', 'updated_at', 'updated_by']::text[]);

select audit.audit_table('instance_note', 't', 't', 'i',
                         ARRAY['id', 'instance_note_key_id', 'value']::text[],
                         ARRAY['created_at', 'created_by', 'updated_at', 'updated_by']::text[]);

select audit.audit_table('public.tree_element', 't', 't', 'i', ARRAY['id']::text[],
        ARRAY[]::text[], 'audit.if_modified_tree_element');

-- export-name-view.sql
DROP MATERIALIZED VIEW IF EXISTS name_view;

-- --- name-view uses these functions
DROP FUNCTION IF EXISTS find_rank(BIGINT, INT);
CREATE FUNCTION find_rank(name_id BIGINT, rank_sort_order INT)
    RETURNS TABLE
            (
                name_element TEXT,
                rank         TEXT,
                sort_order   INT
            )
    LANGUAGE SQL
AS
$$
WITH RECURSIVE walk (parent_id, name_element, rank, sort_order) AS (
    SELECT parent_id,
           n.name_element,
           r.name,
           r.sort_order
    FROM name n
             JOIN name_rank r ON n.name_rank_id = r.id
    WHERE n.id = name_id
      AND r.sort_order >= rank_sort_order
    UNION ALL
    SELECT n.parent_id,
           n.name_element,
           r.name,
           r.sort_order
    FROM walk w,
         name n
             JOIN name_rank r ON n.name_rank_id = r.id
    WHERE n.id = w.parent_id
      AND r.sort_order >= rank_sort_order
)
SELECT w.name_element,
       w.rank,
       w.sort_order
FROM walk w
WHERE w.sort_order >= rank_sort_order
order by w.sort_order asc
limit 1
$$;

drop function if exists inc_status(nameId bigint);
CREATE function inc_status(nameId bigint)
    returns text
    language sql
as
$$
select 'included' :: text
where exists(select 1
             from tree_element te2
             where synonyms @> (select '{"list":[{"name_id":' || nameId || ', "mis":false}]}') :: JSONB)
$$;

drop function if exists excluded_status(nameId bigint);
CREATE function excluded_status(nameId bigint)
    returns text
    language sql
as
$$
select case when te.excluded = true then 'excluded' else 'accepted' end
from tree_element te
         JOIN tree_version_element tve ON te.id = tve.tree_element_id
         JOIN tree ON tve.tree_version_id = tree.current_tree_version_id AND tree.accepted_tree = TRUE
where te.name_id = nameId
$$;

drop function if exists accepted_status(nameId BIGINT);
CREATE FUNCTION accepted_status(nameId BIGINT)
    RETURNS TEXT
    LANGUAGE SQL
AS
$$
select coalesce(excluded_status(nameId), inc_status(nameId), 'unplaced');
$$;

create materialized view name_view as
SELECT n.full_name                                                           AS "scientificName",
       n.full_name_html                                                      AS "scientificNameHTML",
       n.simple_name                                                         AS "canonicalName",
       n.simple_name_html                                                    AS "canonicalNameHTML",
       n.name_element                                                        AS "nameElement",
       ((mapper_host.value)::text || n.uri)                                  AS "scientificNameID",
       nt.name                                                               AS "nameType",
       (SELECT COALESCE((SELECT CASE
                                    WHEN (te.excluded = true) THEN 'excluded'::text
                                    ELSE 'accepted'::text
                                    END AS "case"
                         FROM ((tree_element te
                             JOIN tree_version_element tve ON ((te.id = tve.tree_element_id)))
                                  JOIN tree ON (((tve.tree_version_id = tree.current_tree_version_id) AND
                                                 (tree.accepted_tree = true))))
                         WHERE (te.name_id = n.id)), (SELECT 'included'::text AS text
                                                      WHERE (EXISTS(SELECT 1
                                                                    FROM tree_element te2
                                                                    WHERE (te2.synonyms @>
                                                                           ((SELECT (('{"list":[{"name_id":'::text || n.id) || ', "mis":false}]}'::text)))::jsonb)))),
                        'unplaced'::text) AS "coalesce")                     AS "taxonomicStatus",
       CASE
           WHEN ((ns.name)::text <> ALL
                 (ARRAY [('legitimate'::character varying)::text, ('[default]'::character varying)::text])) THEN ns.name
           ELSE NULL::character varying
           END                                                               AS "nomenclaturalStatus",
       CASE
           WHEN nt.autonym THEN NULL::text
           ELSE regexp_replace("substring"((n.full_name_html)::text, '<authors>(.*)</authors>'::text), '<[^>]*>'::text,
                               ''::text, 'g'::text)
           END                                                               AS "scientificNameAuthorship",
       CASE
           WHEN (nt.cultivar = true) THEN n.name_element
           ELSE NULL::character varying
           END                                                               AS "cultivarEpithet",
       nt.autonym,
       nt.hybrid,
       nt.cultivar,
       nt.formula,
       nt.scientific,
       ns.nom_inval                                                          AS "nomInval",
       ns.nom_illeg                                                          AS "nomIlleg",
       COALESCE(primary_ref.citation, 'unknown')                             AS "namePublishedIn",
       COALESCE(primary_ref.year, 0)                                         AS "namePublishedInYear",
       primary_it.name                                                       AS "nameInstanceType",
       basionym.full_name                                                    AS "originalNameUsage",
       CASE
           WHEN (basionym_inst.id IS NOT NULL) THEN ((mapper_host.value)::text || (SELECT instance.uri
                                                                                   FROM instance
                                                                                   WHERE (instance.id = basionym_inst.cites_id)))
           ELSE
               CASE
                   WHEN (primary_inst.id IS NOT NULL) THEN ((mapper_host.value)::text || primary_inst.uri)
                   ELSE NULL::text
                   END
           END                                                               AS "originalNameUsageID",
       CASE
           WHEN (nt.autonym = true) THEN (parent_name.full_name)::text
           ELSE (SELECT string_agg(regexp_replace((note.value)::text, '[

 ]+'::text, ' '::text, 'g'::text), ' '::text) AS string_agg
                 FROM (instance_note note
                          JOIN instance_note_key key1
                               ON (((key1.id = note.instance_note_key_id) AND ((key1.name)::text = 'Type'::text))))
                 WHERE (note.instance_id = COALESCE(basionym_inst.cites_id, primary_inst.id)))
           END                                                               AS "typeCitation",
       (SELECT find_rank.name_element
        FROM find_rank(n.id, 10) find_rank(name_element, rank, sort_order))  AS kingdom,
       family_name.name_element                                              AS family,
       (SELECT find_rank.name_element
        FROM find_rank(n.id, 120) find_rank(name_element, rank, sort_order)) AS "genericName",
       (SELECT find_rank.name_element
        FROM find_rank(n.id, 190) find_rank(name_element, rank, sort_order)) AS "specificEpithet",
       (SELECT find_rank.name_element
        FROM find_rank(n.id, 191) find_rank(name_element, rank, sort_order)) AS "infraspecificEpithet",
       rank.name                                                             AS "taxonRank",
       rank.sort_order                                                       AS "taxonRankSortOrder",
       rank.abbrev                                                           AS "taxonRankAbbreviation",
       first_hybrid_parent.full_name                                         AS "firstHybridParentName",
       ((mapper_host.value)::text || first_hybrid_parent.uri)                AS "firstHybridParentNameID",
       second_hybrid_parent.full_name                                        AS "secondHybridParentName",
       ((mapper_host.value)::text || second_hybrid_parent.uri)               AS "secondHybridParentNameID",
       n.created_at                                                          AS created,
       n.updated_at                                                          AS modified,
       ((SELECT COALESCE((SELECT shard_config.value
                          FROM shard_config
                          WHERE ((shard_config.name)::text = 'nomenclatural code'::text)),
                         'ICN'::character varying) AS "coalesce"))::text     AS "nomenclaturalCode",
       dataset.value                                                         AS "datasetName",
       'http://creativecommons.org/licenses/by/3.0/'::text                   AS license,
       ((mapper_host.value)::text || n.uri)                                  AS "ccAttributionIRI"
FROM (((((((((((name n
    JOIN name_type nt ON ((n.name_type_id = nt.id)))
    JOIN name_status ns ON ((n.name_status_id = ns.id)))
    JOIN name_rank rank ON ((n.name_rank_id = rank.id)))
    LEFT JOIN name parent_name ON ((n.parent_id = parent_name.id)))
    LEFT JOIN name family_name ON ((n.family_id = family_name.id)))
    LEFT JOIN name first_hybrid_parent ON (((n.parent_id = first_hybrid_parent.id) AND nt.hybrid)))
    LEFT JOIN name second_hybrid_parent ON (((n.second_parent_id = second_hybrid_parent.id) AND nt.hybrid)))
    LEFT JOIN ((instance primary_inst
        JOIN instance_type primary_it ON (((primary_it.id = primary_inst.instance_type_id) AND
                                           (primary_it.primary_instance = true))))
        JOIN reference primary_ref ON ((primary_inst.reference_id = primary_ref.id))) ON ((primary_inst.name_id = n.id)))
    LEFT JOIN ((instance basionym_inst
        JOIN instance_type "bit" ON ((("bit".id = basionym_inst.instance_type_id) AND
                                      (("bit".name)::text = 'basionym'::text))))
        JOIN name basionym ON ((basionym.id = basionym_inst.name_id))) ON ((basionym_inst.cited_by_id = primary_inst.id)))
    LEFT JOIN shard_config mapper_host ON (((mapper_host.name)::text = 'mapper host'::text)))
         LEFT JOIN shard_config dataset ON (((dataset.name)::text = 'name label'::text)))
WHERE (EXISTS(SELECT 1
              FROM instance
              WHERE (instance.name_id = n.id)))
ORDER BY n.sort_name;
-- export-taxon-view.sql
DROP MATERIALIZED VIEW IF EXISTS taxon_view;

-- taxon-view uses this function
DROP FUNCTION IF EXISTS find_tree_rank(TEXT, INT);
-- this function is a little slow, but it works for now.
CREATE FUNCTION find_tree_rank(tve_id TEXT, rank_sort_order INT)
    RETURNS TABLE
            (
                name_element TEXT,
                rank         TEXT,
                sort_order   INT
            )
    LANGUAGE SQL
AS
$$
WITH RECURSIVE walk (parent_id, name_element, rank, sort_order) AS (
    SELECT tve.parent_id,
           n.name_element,
           r.name,
           r.sort_order
    FROM tree_version_element tve
             JOIN tree_element te ON tve.tree_element_id = te.id
             JOIN name n ON te.name_id = n.id
             JOIN name_rank r ON n.name_rank_id = r.id
    WHERE tve.element_link = tve_id
      AND r.sort_order >= rank_sort_order
    UNION ALL
    SELECT tve.parent_id,
           n.name_element,
           r.name,
           r.sort_order
    FROM walk w,
         tree_version_element tve
             JOIN tree_element te ON tve.tree_element_id = te.id
             JOIN name n ON te.name_id = n.id
             JOIN name_rank r ON n.name_rank_id = r.id
    WHERE tve.element_link = w.parent_id
      AND r.sort_order >= rank_sort_order
)
SELECT w.name_element,
       w.rank,
       w.sort_order
FROM walk w
WHERE w.sort_order = rank_sort_order
limit 1
$$;

CREATE MATERIALIZED VIEW taxon_view AS

    -- synonyms bit
(
SELECT (syn ->> 'host') || (syn ->> 'instance_link')                                                   AS "taxonID",
       syn_nt.name                                                                                     AS "nameType",
       tree.host_name || tve.taxon_link                                                                AS "acceptedNameUsageID",
       acc_name.full_name                                                                              AS "acceptedNameUsage",
       CASE
           WHEN acc_ns.name NOT IN ('legitimate', '[default]')
               THEN acc_ns.name
           ELSE NULL END                                                                               AS "nomenclaturalStatus",
       (syn ->> 'type')                                                                                AS "taxonomicStatus",
       (syn ->> 'type' ~ 'parte')                                                                      AS "proParte",
       syn_name.full_name                                                                              AS "scientificName",
       (syn ->> 'host') || (syn ->> 'name_link')                                                       AS "scientificNameID",
       syn_name.simple_name                                                                            AS "canonicalName",
       CASE
           WHEN syn_nt.autonym
               THEN NULL
           ELSE regexp_replace(substring(syn_name.full_name_html FROM '<authors>(.*)</authors>'), '<[^>]*>', '',
                               'g')
           END                                                                                         AS "scientificNameAuthorship",
       -- only in accepted names
       NULL                                                                                            AS "parentNameUsageID",
       syn_rank.name                                                                                   AS "taxonRank",
       syn_rank.sort_order                                                                             AS "taxonRankSortOrder",
       (SELECT name_element
        FROM find_tree_rank(tve.element_link, 10)
        ORDER BY sort_order ASC
        LIMIT 1)                                                                                       AS "kingdom",
       -- the below works but is a little slow
       -- find another efficient way to do it.
       (SELECT name_element FROM find_tree_rank(tve.element_link, 30) ORDER BY sort_order ASC LIMIT 1) AS "class",
       (SELECT name_element
        FROM find_tree_rank(tve.element_link, 40)
        ORDER BY sort_order ASC
        LIMIT 1)                                                                                       AS "subclass",
       (SELECT name_element FROM find_tree_rank(tve.element_link, 80) ORDER BY sort_order ASC LIMIT 1) AS "family",
       syn_name.created_at                                                                             AS "created",
       syn_name.updated_at                                                                             AS "modified",
       tree.name                                                                                       AS "datasetName",
       (syn ->> 'host') || (syn ->> 'concept_link')                                                    AS "taxonConceptID",
       (syn ->> 'cites')                                                                               AS "nameAccordingTo",
       (syn ->> 'host') || (syn ->> 'cites_link')                                                      AS "nameAccordingToID",
       profile -> (tree.config ->> 'comment_key') ->> 'value'                                          AS "taxonRemarks",
       profile -> (tree.config ->> 'distribution_key') ->> 'value'                                     AS "taxonDistribution",
       -- todo check this is ok for synonyms
       regexp_replace(tve.name_path, '/', '|', 'g')                                                    AS "higherClassification",
       CASE
           WHEN firstHybridParent.id IS NOT NULL
               THEN firstHybridParent.full_name
           ELSE NULL END                                                                               AS "firstHybridParentName",
       CASE
           WHEN firstHybridParent.id IS NOT NULL
               THEN tree.host_name || '/' || firstHybridParent.uri
           ELSE NULL END                                                                               AS "firstHybridParentNameID",
       CASE
           WHEN secondHybridParent.id IS NOT NULL
               THEN secondHybridParent.full_name
           ELSE NULL END                                                                               AS "secondHybridParentName",
       CASE
           WHEN secondHybridParent.id IS NOT NULL
               THEN tree.host_name || '/' || secondHybridParent.uri
           ELSE NULL END                                                                               AS "secondHybridParentNameID",
       -- boiler plate stuff at the end of the record
       (select coalesce((SELECT value FROM shard_config WHERE name = 'nomenclatural code'),
                        'ICN')) :: TEXT                                                                AS "nomenclaturalCode",
       'http://creativecommons.org/licenses/by/3.0/' :: TEXT                                           AS "license",
       (syn ->> 'host') || (syn ->> 'instance_link')                                                   AS "ccAttributionIRI"
FROM tree_version_element tve
         JOIN tree ON tve.tree_version_id = tree.current_tree_version_id AND tree.accepted_tree = TRUE
         JOIN tree_element te ON tve.tree_element_id = te.id
         JOIN instance acc_inst ON te.instance_id = acc_inst.id
         JOIN instance_type acc_it ON acc_inst.instance_type_id = acc_it.id
         JOIN reference acc_ref ON acc_inst.reference_id = acc_ref.id
         JOIN NAME acc_name ON te.name_id = acc_name.id
         JOIN name_type acc_nt ON acc_name.name_type_id = acc_nt.id
         JOIN name_status acc_ns ON acc_name.name_status_id = acc_ns.id,
     jsonb_array_elements(synonyms -> 'list') syn
         JOIN NAME syn_name ON syn_name.id = (syn ->> 'name_id') :: NUMERIC :: BIGINT
         JOIN name_rank syn_rank ON syn_name.name_rank_id = syn_rank.id
         JOIN name_type syn_nt ON syn_name.name_type_id = syn_nt.id
         LEFT OUTER JOIN NAME firstHybridParent ON syn_name.parent_id = firstHybridParent.id AND syn_nt.hybrid
         LEFT OUTER JOIN NAME secondHybridParent
                         ON syn_name.second_parent_id = secondHybridParent.id AND syn_nt.hybrid
UNION -- The accepted names bit
SELECT tree.host_name || tve.taxon_link                                                                AS "taxonID",
       acc_nt.name                                                                                     AS "nameType",
       tree.host_name || tve.taxon_link                                                                AS "acceptedNameUsageID",
       acc_name.full_name                                                                              AS "acceptedNameUsage",
       CASE
           WHEN acc_ns.name NOT IN ('legitimate', '[default]')
               THEN acc_ns.name
           ELSE NULL END                                                                               AS "nomenclaturalStatus",
       CASE
           WHEN te.excluded
               THEN 'excluded'
           ELSE 'accepted'
           END                                                                                         AS "taxonomicStatus",
       FALSE                                                                                           AS "proParte",
       acc_name.full_name                                                                              AS "scientificName",
       te.name_link                                                                                    AS "scientificNameID",
       acc_name.simple_name                                                                            AS "canonicalName",
       CASE
           WHEN acc_nt.autonym
               THEN NULL
           ELSE regexp_replace(substring(acc_name.full_name_html FROM '<authors>(.*)</authors>'), '<[^>]*>', '',
                               'g')
           END                                                                                         AS "scientificNameAuthorship",
       tree.host_name || tve.parent_id                                                                 AS "parentNameUsageID",
       te.rank                                                                                         AS "taxonRank",
       acc_rank.sort_order                                                                             AS "taxonRankSortOrder",
       (SELECT name_element
        FROM find_tree_rank(tve.element_link, 10)
        ORDER BY sort_order ASC
        LIMIT 1)                                                                                       AS "kingdom",
       -- the below works but is a little slow
       -- find another efficient way to do it.
       (SELECT name_element FROM find_tree_rank(tve.element_link, 30) ORDER BY sort_order ASC LIMIT 1) AS "class",
       (SELECT name_element
        FROM find_tree_rank(tve.element_link, 40)
        ORDER BY sort_order ASC
        LIMIT 1)                                                                                       AS "subclass",
       (SELECT name_element FROM find_tree_rank(tve.element_link, 80) ORDER BY sort_order ASC LIMIT 1) AS "family",
       acc_name.created_at                                                                             AS "created",
       acc_name.updated_at                                                                             AS "modified",
       tree.name                                                                                       AS "datasetName",
       te.instance_link                                                                                AS "taxonConceptID",
       acc_ref.citation                                                                                AS "nameAccordingTo",
       tree.host_name || '/reference/' || lower(name_space.value) || '/' ||
       acc_ref.id                                                                                      AS "nameAccordingToID",
       profile -> (tree.config ->> 'comment_key') ->> 'value'                                          AS "taxonRemarks",
       profile -> (tree.config ->> 'distribution_key') ->> 'value'                                     AS "taxonDistribution",
       -- todo check this is ok for synonyms
       regexp_replace(tve.name_path, '/', '|', 'g')                                                    AS "higherClassification",
       CASE
           WHEN firstHybridParent.id IS NOT NULL
               THEN firstHybridParent.full_name
           ELSE NULL END                                                                               AS "firstHybridParentName",
       CASE
           WHEN firstHybridParent.id IS NOT NULL
               THEN tree.host_name || '/' || firstHybridParent.uri
           ELSE NULL END                                                                               AS "firstHybridParentNameID",
       CASE
           WHEN secondHybridParent.id IS NOT NULL
               THEN secondHybridParent.full_name
           ELSE NULL END                                                                               AS "secondHybridParentName",
       CASE
           WHEN secondHybridParent.id IS NOT NULL
               THEN tree.host_name || '/' || secondHybridParent.uri
           ELSE NULL END                                                                               AS "secondHybridParentNameID",
       -- boiler plate stuff at the end of the record
       (select coalesce((SELECT value FROM shard_config WHERE name = 'nomenclatural code'),
                        'ICN')) :: TEXT                                                                AS "nomenclaturalCode",
       'http://creativecommons.org/licenses/by/3.0/' :: TEXT                                           AS "license",
       tree.host_name || tve.element_link                                                              AS "ccAttributionIRI"
FROM tree_version_element tve
         JOIN tree ON tve.tree_version_id = tree.current_tree_version_id AND tree.accepted_tree = TRUE
         JOIN tree_element te ON tve.tree_element_id = te.id
         JOIN instance acc_inst ON te.instance_id = acc_inst.id
         JOIN instance_type acc_it ON acc_inst.instance_type_id = acc_it.id
         JOIN reference acc_ref ON acc_inst.reference_id = acc_ref.id
         JOIN NAME acc_name ON te.name_id = acc_name.id
         JOIN name_type acc_nt ON acc_name.name_type_id = acc_nt.id
         JOIN name_status acc_ns ON acc_name.name_status_id = acc_ns.id
         JOIN name_rank acc_rank ON acc_name.name_rank_id = acc_rank.id
         LEFT OUTER JOIN NAME firstHybridParent ON acc_name.parent_id = firstHybridParent.id AND acc_nt.hybrid
         LEFT OUTER JOIN NAME secondHybridParent
                         ON acc_name.second_parent_id = secondHybridParent.id AND acc_nt.hybrid
         LEFT OUTER JOIN shard_config name_space on name_space.name = 'name space'
ORDER BY "higherClassification");

comment on materialized view taxon_view is 'The Taxon View provides a complete list of Names and their synonyms accepted by CHAH in Australia.';
comment on column taxon_view."taxonomicStatus" is 'Is this name accepted, excluded or a synonym of an accepted name.';
comment on column taxon_view."scientificName" is 'The full scientific name including authority.';
comment on column taxon_view."scientificNameID" is 'The identifying URI of the scientific name in this dataset.';
comment on column taxon_view."acceptedNameUsage" is 'The accepted name for this concept in this classification.';
comment on column taxon_view."acceptedNameUsageID" is 'The identifying URI of the accepted name concept.';
comment on column taxon_view."taxonID" is 'The identifying URI of the taxon concept used here. For an accepted name it identifies the taxon concept and what it encloses (subtaxa). For a synonym it identifies the relationship.';
comment on column taxon_view."nameType" is 'A categorisation of the name, e.g. scientific, hybrid, cultivar';
comment on column taxon_view."nomenclaturalStatus" is 'The nomencultural status of this name. http://rs.gbif.org/vocabulary/gbif/nomenclatural_status.xml';
comment on column taxon_view."proParte" is 'A flag that indicates this name is applied to this accepted name in part. If a name is ''pro parte'' then the name will have more than 1 accepted name.';
comment on column taxon_view."canonicalName" is 'The name without authorship.';
comment on column taxon_view."scientificNameAuthorship" is 'Authorship of the name.';
comment on column taxon_view."parentNameUsageID" is 'The identifying URI of the parent taxon for accepted names in the classification.';
comment on column taxon_view."taxonRank" is 'The taxonomic rank of the scientificName.';
comment on column taxon_view."taxonRankSortOrder" is 'A sort order that can be applied to the rank.';
comment on column taxon_view.kingdom is 'The canonical name of the kingdom based on this classification.';
comment on column taxon_view.class is 'The canonical name of the class based on this classification.';
comment on column taxon_view.subclass is 'The canonical name of the subclass based on this classification.';
comment on column taxon_view.family is 'The canonical name of the family based on this classification.';
comment on column taxon_view.created is 'Date the record for this concept was created. Format ISO:86 01';
comment on column taxon_view.modified is 'Date the record for this concept was modified. Format ISO:86 01';
comment on column taxon_view."datasetName" is 'Name of the taxonomy (tree) that contains this concept. e.g. APC, AusMoss';
comment on column taxon_view."taxonConceptID" is 'The identifying URI taxanomic concept this record refers to.';
comment on column taxon_view."nameAccordingTo" is 'The reference citation for this name.';
comment on column taxon_view."nameAccordingToID" is 'The identifying URI for the reference citation for this name.';
comment on column taxon_view."taxonRemarks" is 'Comments made specifically about this name in this classification.';
comment on column taxon_view."taxonDistribution" is 'The State or Territory distribution of the accepted name.';
comment on column taxon_view."higherClassification" is 'A list of names representing the branch down to (and including) this name separated by a "|".';
comment on column taxon_view."firstHybridParentName" is 'The scientificName for the first hybrid parent. For hybrids.';
comment on column taxon_view."firstHybridParentNameID" is 'The identifying URI the scientificName for the first hybrid parent.';
comment on column taxon_view."secondHybridParentName" is 'The scientificName for the second hybrid parent. For hybrids.';
comment on column taxon_view."secondHybridParentNameID" is 'The identifying URI the scientificName for the second hybrid parent.';
comment on column taxon_view."nomenclaturalCode" is 'The nomenclatural code under which this name is constructed.';
comment on column taxon_view.license is 'The license by which this data is being made available.';
comment on column taxon_view."ccAttributionIRI" is 'The attribution to be used when citing this concept.';
-- functions.sql
-- NSL-752 NSL-2894
-- functions to get ordered output as needed by the APNI format

-- find basionym
drop function if exists basionym(bigint);
create function basionym(nameid bigint)
    returns bigint
    language sql
as $$
select coalesce(
               (select coalesce(bas_name.id, primary_inst.name_id)
                from instance primary_inst
                         left join instance bas_inst
                         join name bas_name on bas_inst.name_id = bas_name.id
                         join instance_type bas_it on bas_inst.instance_type_id = bas_it.id and bas_it.name in ('basionym','replaced synonym')
                         join instance cit_inst on bas_inst.cites_id = cit_inst.id
                              on bas_inst.cited_by_id = primary_inst.id
                         join instance_type primary_it on primary_inst.instance_type_id = primary_it.id and primary_it.primary_instance
                where primary_inst.name_id = nameid
                limit 1), nameid);
$$;

drop function if exists ref_parent_date(bigint);
create function ref_parent_date(ref_id BIGINT)
    returns text
    language sql
as
$$
select case
           when rt.use_parent_details = true
               then coalesce(r.iso_publication_date, pr.iso_publication_date)
           else r.iso_publication_date
           end
from reference r
         join ref_type rt on r.ref_type_id = rt.id
         left outer join reference pr on r.parent_id = pr.id
where r.id = ref_id;
$$;

-- ref.year from iso publication date
drop function if exists ref_year(text);
create function ref_year(iso_publication_date text)
    returns integer
    language sql
as
$$
select cast(substring(iso_publication_date from 1 for 4) AS integer)
$$;

-- Find earliest local instance for a name.
drop function if exists first_ref(bigint);
create function first_ref(nameid bigint)
    returns table
            (
                group_id           bigint,
                group_name         text,
                group_iso_pub_date text
            )
    language sql
as
$$
select n.id group_id, n.sort_name group_name, min(r.iso_publication_date)
from name n
         join instance i
         join reference r on i.reference_id = r.id
              on n.id = i.name_id
where n.id = nameid
group by n.id, sort_name
$$;

-- find the name an orth var or alt name is of

drop function if exists orth_or_alt_of(bigint);
create function orth_or_alt_of(nameid bigint)
    returns bigint
    language sql
as $$
select coalesce((select alt_of_inst.name_id
                 from name n
                          join name_status ns on n.name_status_id = ns.id
                          join instance alt_inst on n.id = alt_inst.name_id
                          join instance_type alt_it on alt_inst.instance_type_id = alt_it.id and
                                                       alt_it.name in ('orthographic variant', 'alternative name')
                          join instance alt_of_inst on alt_of_inst.id = alt_inst.cited_by_id
                 where n.id = nameid
                   and ns.name ~ '(orth. var.|nom. alt.)' limit 1), nameid) id
$$;

-- get the synonyms of a name in flora order for apni
drop function if exists apni_ordered_nom_synonymy(bigint);
create function apni_ordered_nom_synonymy(instanceid bigint)
    returns TABLE
            (
                instance_id          bigint,
                instance_uri         text,
                instance_type        text,
                instance_type_id     bigint,
                name_id              bigint,
                name_uri             text,
                full_name            text,
                full_name_html       text,
                name_status          text,
                citation             text,
                citation_html        text,
                year                 int,
                iso_publication_date text,
                page                 text,
                sort_name            text,
                misapplied           boolean,
                ref_id               bigint
            )
    language sql
as
$$
select i.id,
       i.uri,
       it.has_label                     as instance_type,
       it.id                            as instance_type_id,
       n.id                             as name_id,
       n.uri,
       n.full_name,
       n.full_name_html,
       ns.name                          as name_status,
       r.citation,
       r.citation_html,
       ref_year(iso_date) as year,
       coalesce(iso_date, '-'),
       cites.page,
       n.sort_name,
       false,
       r.id
from instance i
         join instance_type it on i.instance_type_id = it.id and it.nomenclatural
         join name n on i.name_id = n.id
         join name_status ns on n.name_status_id = ns.id
         left outer join instance cites on i.cites_id = cites.id
         left outer join reference r on cites.reference_id = r.id
         left outer join ref_parent_date(r.id) iso_date on true
where i.cited_by_id = instanceid
order by (it.sort_order < 20) desc,
         it.nomenclatural desc,
         iso_date,
         n.sort_name,
         it.pro_parte,
         it.doubtful,
         cites.page,
         cites.id;
$$;

drop function if exists apni_ordered_other_synonymy(bigint);
create function apni_ordered_other_synonymy(instanceid bigint)
    returns TABLE
            (
                instance_id          bigint,
                instance_uri         text,
                instance_type        text,
                instance_type_id     bigint,
                name_id              bigint,
                name_uri             text,
                full_name            text,
                full_name_html       text,
                name_status          text,
                citation             text,
                citation_html        text,
                year                 int,
                iso_publication_date text,
                page                 text,
                sort_name            text,
                group_name           text,
                group_head           boolean,
                group_iso_pub_date   text,
                misapplied           boolean,
                ref_id               bigint,
                og_id                bigint,
                og_head              boolean,
                og_name              text,
                og_year              text
            )
    language sql
as
$$
select i.id                                                            as instance_id,
       i.uri                                                           as instance_uri,
       it.has_label                                                    as instance_type,
       it.id                                                           as instance_type_id,
       n.id                                                            as name_id,
       n.uri                                                           as name_uri,
       n.full_name,
       n.full_name_html,
       ns.name                                                         as name_status,
       r.citation,
       r.citation_html,
       ref_year(iso_date)                                as year,
       coalesce(iso_date,'-'),
       cites.page,
       n.sort_name,
       ng.group_name                                                   as group_name,
       ng.group_id = n.id                                              as group_head,
       coalesce(ng.group_iso_pub_date, r.iso_publication_date) :: text as group_iso_pub_date,
       it.misapplied,
       r.id                                                            as ref_id,
       og_id                                                           as og_id,
       og_id = n.id                                                    as og_head,
       coalesce(ogn.sort_name, n.sort_name)                            as og_name,
       coalesce(ogr.iso_publication_date, r.iso_publication_date)      as og_iso_pub_date
from instance i
         join instance_type it on i.instance_type_id = it.id and not it.nomenclatural and it.relationship
         join name n on i.name_id = n.id
         join name_type nt on n.name_type_id = nt.id
         join orth_or_alt_of(case when nt.autonym then n.parent_id else n.id end) og_id on true
         left outer join name ogn on ogn.id = og_id and not og_id = n.id
         left outer join instance ogi
         join reference ogr on ogr.id = ogi.reference_id
              on ogi.name_id = og_id and ogi.id = i.cited_by_id and not og_id = n.id
         left outer join first_ref(basionym(og_id)) ng on true
         join name_status ns on n.name_status_id = ns.id
         left outer join instance cites on i.cites_id = cites.id
         left outer join reference r on cites.reference_id = r.id
         left outer join ref_parent_date(r.id) iso_date on true
where i.cited_by_id = instanceid
order by (it.sort_order < 20) desc,
         it.taxonomic desc,
         group_iso_pub_date,
         group_name,
         group_head desc,
         og_iso_pub_date,
         og_name,
         og_head desc,
         iso_date,
         n.sort_name,
         it.pro_parte,
         it.misapplied desc,
         it.doubtful,
         cites.page,
         cites.id;
$$;

drop function if exists apni_ordered_synonymy(bigint);
create function apni_ordered_synonymy(instanceid bigint)
    returns TABLE
            (
                instance_id          bigint,
                instance_uri         text,
                instance_type        text,
                instance_type_id     bigint,
                name_id              bigint,
                name_uri             text,
                full_name            text,
                full_name_html       text,
                name_status          text,
                citation             text,
                citation_html        text,
                iso_publication_date text,
                page                 text,
                sort_name            text,
                misapplied           boolean,
                ref_id               bigint
            )
    language sql
as
$$

select instance_id,
       instance_uri,
       instance_type,
       instance_type_id,
       name_id,
       name_uri,
       full_name,
       full_name_html,
       name_status,
       citation,
       citation_html,
       iso_publication_date,
       page,
       sort_name,
       misapplied,
       ref_id
from apni_ordered_nom_synonymy(instanceid)
union all
select instance_id,
       instance_uri,
       instance_type,
       instance_type_id,
       name_id,
       name_uri,
       full_name,
       full_name_html,
       name_status,
       citation,
       citation_html,
       iso_publication_date,
       page,
       sort_name,
       misapplied,
       ref_id
from apni_ordered_other_synonymy(instanceid)
$$;

-- apni ordered synonymy as a text output

drop function if exists apni_ordered_synonymy_text(bigint);
create function apni_ordered_synonymy_text(instanceid bigint)
    returns text
    language sql
as $$
select string_agg('  ' ||
                  syn.instance_type ||
                  ': ' ||
                  syn.full_name ||
                  (case
                       when syn.name_status = 'legitimate' then ''
                       when syn.name_status = '[n/a]' then ''
                       else ' ' || syn.name_status end) ||
                  (case
                       when syn.misapplied then syn.citation
                       else '' end), E'\n') || E'\n'
from apni_ordered_synonymy(instanceid) syn;
$$;

-- apni ordered synonymy as a jsonb output
drop function if exists apni_ordered_synonymy_jsonb(bigint);
create function apni_ordered_synonymy_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'instance_id', syn.instance_id,
                       'instance_uri', syn.instance_uri,
                       'instance_type', syn.instance_type,
                       'name_uri', syn.name_uri,
                       'full_name_html', syn.full_name_html,
                       'name_status', syn.name_status,
                       'misapplied', syn.misapplied,
                       'citation_html', syn.citation_html
                   )
           )
from apni_ordered_synonymy(instanceid) syn;
$$;

-- if this is a relationship instance what are we a synonym of
drop function if exists apni_synonym(bigint);
create function apni_synonym(instanceid bigint)
    returns TABLE
            (
                instance_id          bigint,
                instance_uri         text,
                instance_type        text,
                instance_type_id     bigint,
                name_id              bigint,
                name_uri             text,
                full_name            text,
                full_name_html       text,
                name_status          text,
                citation             text,
                citation_html        text,
                year                 int,
                iso_publication_date text,
                page                 text,
                misapplied           boolean,
                sort_name            text
            )
    language sql
as
$$
select i.id,
       i.uri,
       it.of_label as instance_type,
       it.id       as instance_type_id,
       n.id        as name_id,
       n.uri,
       n.full_name,
       n.full_name_html,
       ns.name,
       r.citation,
       r.citation_html,
       ref_year(iso_date),
       iso_date,
       i.page,
       it.misapplied,
       n.sort_name
from instance i
         join instance_type it on i.instance_type_id = it.id
         join instance cites on i.cited_by_id = cites.id
         join name n on cites.name_id = n.id
         join name_status ns on n.name_status_id = ns.id
         join reference r on i.reference_id = r.id
         left outer join ref_parent_date(r.id) iso_date on true
where i.id = instanceid
  and it.relationship;
$$;

-- if this is a relationship instance what are we a synonym of as text
drop function if exists apni_synonym_text(bigint);
create function apni_synonym_text(instanceid bigint)
    returns text
    language sql
as $$
select string_agg('  ' ||
                  syn.instance_type ||
                  ': ' ||
                  syn.full_name ||
                  (case
                       when syn.name_status = 'legitimate' then ''
                       when syn.name_status = '[n/a]' then ''
                       else ' ' || syn.name_status end) ||
                  (case
                       when syn.misapplied
                           then 'by ' || syn.citation
                       else '' end), E'\n') || E'\n'
from apni_synonym(instanceid) syn;
$$;

-- if this is a relationship instance what are we a synonym of as jsonb
drop function if exists apni_synonym_jsonb(bigint);
create function apni_synonym_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'instance_id', syn.instance_id,
                       'instance_uri', syn.instance_uri,
                       'instance_type', syn.instance_type,
                       'name_uri', syn.name_uri,
                       'full_name_html', syn.full_name_html,
                       'name_status', syn.name_status,
                       'misapplied', syn.misapplied,
                       'citation_html', syn.citation_html
                   )
           )
from apni_synonym(instanceid) syn;
$$;

-- apni ordered references for a name
drop function if exists apni_ordered_references(bigint);
create function apni_ordered_references(nameid bigint)
    returns TABLE
            (
                instance_id          bigint,
                instance_uri         text,
                instance_type        text,
                citation             text,
                citation_html        text,
                year                 int,
                iso_publication_date text,
                pages                text,
                page                 text
            )
    language sql
as
$$
select i.id,
       i.uri,
       it.name,
       r.citation,
       r.citation_html,
       ref_year(iso_date),
       iso_date,
       r.pages,
       coalesce(i.page, citedby.page, '-')
from instance i
         join reference r on i.reference_id = r.id
         join instance_type it on i.instance_type_id = it.id
         left outer join instance citedby on i.cited_by_id = citedby.id
         left outer join ref_parent_date(r.id) iso_date on true
where i.name_id = nameid
group by r.id, iso_date, i.id, it.id, citedby.id
order by iso_date, it.protologue, it.primary_instance, r.citation, r.pages, i.page, r.id;
$$;

drop function if exists format_isodate(text);
create function format_isodate(isodate text)
    returns text
    language sql
as
$$
with m(k, v) as (values ('', ''),
                        ('01', 'January'),
                        ('02', 'February'),
                        ('03', 'March'),
                        ('04', 'April'),
                        ('05', 'May'),
                        ('06', 'June'),
                        ('07', 'July'),
                        ('08', 'August'),
                        ('09', 'September'),
                        ('10', 'October'),
                        ('11', 'November'),
                        ('12', 'December'))
select trim(coalesce(day.d, '')  ||
            ' ' || coalesce(m.v, '') ||
            ' ' || year)
from m,
     (select nullif(split_part(isodate, '-', 3),'')::numeric::text d) day,
     split_part(isodate, '-', 2) month,
     split_part(isodate, '-', 1) year
where m.k = month
   or (month = '' and m.k = '00')
$$;

drop function if exists synonym_as_html(bigint);
create function synonym_as_html(instanceid bigint)
    returns TABLE
            (
                html text
            )
    language sql
as
$$
SELECT CASE
           WHEN it.nomenclatural
               THEN '<nom>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                    '</name-status> <year>(' || format_isodate(iso_publication_date) || ')</year> <type>' || instance_type ||
                    '</type></nom>'
           WHEN it.taxonomic
               THEN '<tax>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                    '</name-status> <year>(' || format_isodate(iso_publication_date) || ')</year> <type>' || instance_type ||
                    '</type></tax>'
           WHEN it.misapplied
               THEN '<mis>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                    '</name-status><type>' || instance_type || '</type> by <citation>' ||
                    citation_html || '</citation></mis>'
           WHEN it.synonym
               THEN '<syn>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                    '</name-status> <year>(' || format_isodate(iso_publication_date) || ')</year> <type>' || it.name || '</type></syn>'
           ELSE '<oth>' || full_name_html || '<name-status class="' || name_status || '">, ' || name_status ||
                '</name-status> <type>' || it.name || '</type></oth>'
           END
FROM apni_ordered_synonymy(instanceid)
         join instance_type it on instance_type_id = it.id
$$;

drop function if exists synonyms_as_html(bigint);
create function synonyms_as_html(instance_id bigint) returns text
    language sql
as $$
SELECT '<synonyms>' || string_agg(html, '') || '</synonyms>'
FROM synonym_as_html(instance_id) AS html;
$$
;

-- build JSONB representation of synonyms inside a shard TODO fix links
DROP FUNCTION IF EXISTS synonyms_as_jsonb(BIGINT, TEXT);
CREATE FUNCTION synonyms_as_jsonb(instance_id BIGINT, host TEXT)
    RETURNS JSONB
    LANGUAGE SQL
AS
$$
SELECT jsonb_build_object('list',
                          coalesce(
                                  jsonb_agg(jsonb_build_object(
                                          'host', host,
                                          'instance_id', syn_inst.id,
                                          'instance_link', syn_inst.uri,
                                          'concept_link', coalesce(cites_inst.uri, syn_inst.uri),
                                          'simple_name', synonym.simple_name,
                                          'type', it.name,
                                          'name_id', synonym.id :: BIGINT,
                                          'name_link', synonym.uri,
                                          'full_name_html', synonym.full_name_html,
                                          'nom', it.nomenclatural,
                                          'tax', it.taxonomic,
                                          'mis', it.misapplied,
                                          'cites', coalesce(cites_ref.citation, syn_ref.citation),
                                          'cites_html', coalesce(cites_ref.citation_html, syn_ref.citation_html),
                                          'cites_link', '/reference/'|| lower(conf.value) || '/' || (coalesce(cites_ref.id, syn_ref.id)),
                                          'year', cites_ref.year
                                      )), '[]' :: JSONB)
           )
FROM Instance i,
     Instance syn_inst
         JOIN instance_type it ON syn_inst.instance_type_id = it.id
         JOIN reference syn_ref on syn_inst.reference_id = syn_ref.id
         LEFT JOIN instance cites_inst ON syn_inst.cites_id = cites_inst.id
         LEFT JOIN reference cites_ref ON cites_inst.reference_id = cites_ref.id
        ,
     name synonym,
     shard_config conf
WHERE i.id = instance_id
  AND syn_inst.cited_by_id = i.id
  AND synonym.id = syn_inst.name_id
  AND conf.name = 'name space';
$$;

-- instance notes

drop function if exists type_notes(bigint);
create function type_notes(instanceid bigint)
    returns TABLE(note_key text,
                  note     text)
    language sql
as $$
select k.name, nt.value
from instance_note nt
         join instance_note_key k on nt.instance_note_key_id = k.id
where nt.instance_id = instanceid
  and k.name ilike '%type'
$$;

drop function if exists type_notes_text(bigint);
create function type_notes_text(instanceid bigint)
    returns text
    language sql
as $$
select string_agg('  ' || nt.note_key || ': ' || nt.note || E'\n', E'\n')
from type_notes(instanceid) as nt
$$;

drop function if exists type_notes_jsonb(bigint);
create function type_notes_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'note_key', nt.note_key,
                       'note_value', nt.note
                   )
           )
from type_notes(instanceid) as nt
$$;

drop function if exists non_type_notes(bigint);
create function non_type_notes(instanceid bigint)
    returns TABLE(note_key text,
                  note     text)
    language sql
as $$
select k.name, nt.value
from instance_note nt
         join instance_note_key k on nt.instance_note_key_id = k.id
where nt.instance_id = instanceid
  and k.name not ilike '%type'
$$;

drop function if exists non_type_notes_text(bigint);
create function non_type_notes_text(instanceid bigint)
    returns text
    language sql
as $$
select string_agg('  ' || nt.note_key || ': ' || nt.note || E'\n', E'\n')
from non_type_notes(instanceid) as nt
$$;

drop function if exists non_type_notes_jsonb(bigint);
create function non_type_notes_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'note_key', nt.note_key,
                       'note_value', nt.note
                   )
           )
from non_type_notes(instanceid) as nt
$$;

-- profile stuff
drop function if exists latest_accepted_profile(bigint);
create function latest_accepted_profile(instanceid bigint)
    returns table(comment_key text, comment_value text, dist_key text, dist_value text)
    language sql
as $$
select config ->> 'comment_key'                                 as comment_key,
       (profile -> (config ->> 'comment_key')) ->> 'value'      as comment_value,
       config ->> 'distribution_key'                            as dist_key,
       (profile -> (config ->> 'distribution_key')) ->> 'value' as dist_value
from tree_version_element tve
         join tree_element te on tve.tree_element_id = te.id
         join tree_version tv on tve.tree_version_id = tv.id and tv.published
         join tree t on tv.tree_id = t.id and t.accepted_tree
where te.instance_id = instanceid
order by tv.id desc
limit 1
$$;

drop function if exists latest_accepted_profile_jsonb(bigint);
create function latest_accepted_profile_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_build_object(
               'comment_key', comment_key,
               'comment_value', comment_value,
               'dist_key', dist_key,
               'dist_value', dist_value
           )
from latest_accepted_profile(instanceid)
$$;

drop function if exists latest_accepted_profile_text(bigint);
create function latest_accepted_profile_text(instanceid bigint)
    returns text
    language sql
as $$
select '  ' ||
       case
           when comment_value is not null
               then comment_key || ': ' || comment_value
           else ''
           end ||
       case
           when dist_value is not null
               then dist_key || ': ' || dist_value
           else ''
           end ||
       E'\n'
from latest_accepted_profile(instanceid)
$$;

-- resources

drop function if exists instance_resources(bigint);
create function instance_resources(instanceid bigint)
    returns table(name text, description text, url text, css_icon text, media_icon text)
    language sql
as $$
select rd.name, rd.description, s.url || '/' || r.path, rd.css_icon, 'media/' || m.id
from instance_resources ir
         join resource r on ir.resource_id = r.id
         join site s on r.site_id = s.id
         join resource_type rd on r.resource_type_id = rd.id
         left outer join media m on m.id = rd.media_icon_id
where ir.instance_id = instanceid
$$;

drop function if exists instance_resources_jsonb(bigint);
create function instance_resources_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'type', ir.name,
                       'description', ir.description,
                       'url', ir.url,
                       'css_icon', ir.css_icon,
                       'media_icon', ir.media_icon
                   )
           )
from instance_resources(instanceid) ir
$$;

-- latest tree version this instance has been on
drop function if exists instance_on_accepted_tree(bigint);
create function instance_on_accepted_tree(instanceId bigint)
    returns table(current boolean, excluded boolean, element_link text, tree_name text)
    language sql
as $$
select t.current_tree_version_id = tv.id, te.excluded, tve.element_link, t.name
from tree_element te
         join tree_version_element tve on te.id = tve.tree_element_id
         join tree_version tv on tve.tree_version_id = tv.id
         join tree t on tv.tree_id = t.id and t.accepted_tree
where te.instance_id = instanceId
  and tv.published
order by tve.tree_version_id desc
limit 1;
$$;

drop function if exists instance_on_accepted_tree_jsonb(bigint);
create function instance_on_accepted_tree_jsonb(instanceid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'current', tve.current,
                       'excluded', tve.excluded,
                       'element_link', tve.element_link,
                       'tree_name', tve.tree_name
                   )
           )
from instance_on_accepted_tree(instanceid) tve
$$;


-- apni details as text output
drop function if exists apni_detail_text(bigint);
create function apni_detail_text(nameid bigint)
    returns text
    language sql
as $$
select string_agg(' ' ||
                  refs.citation ||
                  ': ' ||
                  refs.page || E'\n' ||
                  coalesce(type_notes_text(refs.instance_id), '') ||
                  coalesce(apni_ordered_synonymy_text(refs.instance_id), apni_synonym_text(refs.instance_id), '') ||
                  coalesce(non_type_notes_text(refs.instance_id), '') ||
                  coalesce(latest_accepted_profile_text(refs.instance_id), ''),
                  E'\n')
from apni_ordered_references(nameid) refs
$$;

-- apni details as jsonb output
drop function if exists apni_detail_jsonb(bigint);
create function apni_detail_jsonb(nameid bigint)
    returns jsonb
    language sql
as $$
select jsonb_agg(
               jsonb_build_object(
                       'ref_citation_html', refs.citation_html,
                       'ref_citation', refs.citation,
                       'instance_id', refs.instance_id,
                       'instance_uri', refs.instance_uri,
                       'instance_type', refs.instance_type,
                       'page', refs.page,
                       'type_notes', coalesce(type_notes_jsonb(refs.instance_id), '{}' :: jsonb),
                       'synonyms', coalesce(apni_ordered_synonymy_jsonb(refs.instance_id), apni_synonym_jsonb(refs.instance_id), '[]' :: jsonb),
                       'non_type_notes', coalesce(non_type_notes_jsonb(refs.instance_id), '{}' :: jsonb),
                       'profile', coalesce(latest_accepted_profile_jsonb(refs.instance_id), '{}' :: jsonb),
                       'resources', coalesce(instance_resources_jsonb(refs.instance_id), '{}' :: jsonb),
                       'tree', coalesce(instance_on_accepted_tree_jsonb(refs.instance_id), '{}' :: jsonb)
                   )
           )
from apni_ordered_references(nameid) refs
$$;

-- functions to construct display distribution strings
drop function if exists dist_entry_status(BIGINT);
create function dist_entry_status(entry_id BIGINT)
    returns text
    language sql as
$$
with status as (
    SELECT string_agg(ds.name, ' and ') status
    from (
             select ds.name
             FROM dist_entry de
                      join dist_region dr on de.region_id = dr.id
                      join dist_entry_dist_status deds on de.id = deds.dist_entry_status_id
                      join dist_status ds on deds.dist_status_id = ds.id
             where de.id = entry_id
             order by ds.sort_order) ds
)
select case
           when status.status = 'native' then
               ''
           else
                       '(' || status.status || ')'
           end
from status;
$$;

drop function if exists distribution(BIGINT);
create function distribution(element_id BIGINT)
    returns text
    language sql as
$$
select string_agg(e.display, ', ') from
    (select entry.display display
     from dist_entry entry
              join dist_region dr on entry.region_id = dr.id
              join tree_element_distribution_entries tede
                   on tede.dist_entry_id = entry.id and tede.tree_element_id = element_id
     order by dr.sort_order) e
$$;

drop function if exists is_iso8601(varchar);
create or replace function is_iso8601(isoString varchar) returns boolean as $$
DECLARE match boolean;
begin
    match := isoString ~ '^[1,2][0-9]{3}$' or
             isoString ~ '^[1,2][0-9]{3}-(01|02|03|04|05|06|07|08|09|10|11|12)$';
    if match then
        return true;
    end if;
    perform isoString::TIMESTAMP;
    return true;
exception when others then
    return false;
end;
$$ language plpgsql;

-- other-setup.sql
--other setup
ALTER TABLE instance
    ADD CONSTRAINT citescheck CHECK (cites_id IS NULL OR cited_by_id IS NOT NULL);

ALTER TABLE instance
    ADD CONSTRAINT no_duplicate_synonyms UNIQUE (name_id, reference_id, instance_type_id, page, cites_id, cited_by_id);

CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE OR REPLACE FUNCTION f_unaccent(TEXT)
    RETURNS TEXT AS
$func$
SELECT unaccent('unaccent', $1)
$func$ LANGUAGE SQL IMMUTABLE SET search_path = public, pg_temp;

CREATE INDEX name_lower_f_unaccent_full_name_like
    ON name (lower(f_unaccent(full_name)) varchar_pattern_ops);
CREATE INDEX ref_citation_text_index
    ON reference USING GIN (to_tsvector('english' :: REGCONFIG, f_unaccent(
            coalesce((citation) :: TEXT, '' :: TEXT))));

-- add unique constraint on name_rank, name_type and name_status name+nameGroup
-- GORM/Hibernate mapping doesn't set a unique constraint name so it fails in postgresql
alter table name_rank drop constraint if exists nr_unique_name;
alter table name_rank add constraint nr_unique_name unique (name_group_id, name);

alter table name_type drop constraint if exists nt_unique_name;
alter table name_type add constraint nt_unique_name unique (name_group_id, name);

alter table name_status drop constraint if exists ns_unique_name;
alter table name_status add constraint ns_unique_name unique (name_group_id, name);

alter table name add constraint published_year_limits check (published_year > 1700 and published_year < 2500);

-- pg_trgm indexs for like and regex queries NSL-1773
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX name_lower_full_name_gin_trgm
    ON name USING GIN (lower(full_name) gin_trgm_ops);
CREATE INDEX name_lower_simple_name_gin_trgm
    ON name USING GIN (lower(simple_name) gin_trgm_ops);
CREATE INDEX name_lower_unacent_full_name_gin_trgm
    ON name USING GIN (lower(f_unaccent(full_name)) gin_trgm_ops);
CREATE INDEX name_lower_unacent_simple_name_gin_trgm
    ON name USING GIN (lower(f_unaccent(simple_name)) gin_trgm_ops);

-- new tree GIN indexes
DROP INDEX IF EXISTS tree_synonyms_index;
CREATE INDEX tree_synonyms_index
    ON tree_element USING GIN (synonyms);

-- tree make sure the draft is not also the current version.
ALTER TABLE tree
    ADD CONSTRAINT draft_not_current CHECK (current_tree_version_id <> default_draft_tree_version_id);

-- make sure iso_publication_date is a date
alter table reference add constraint check_iso_date check(is_iso8601(iso_publication_date));

create index iso_pub_index on reference (iso_publication_date asc);

-- NSL-3559 make sure reference parent can't be itself.

ALTER TABLE reference add constraint parent_not_self CHECK ( parent_id <> id );

INSERT INTO db_version (id, version) VALUES (1, 37);
-- populate-lookup-tables.sql
-- Populate lookup tables (currently botanical)
--namespace
INSERT INTO public.namespace (id, lock_version, name, description_html, rdf_id) VALUES
(nextval('nsl_global_seq'), 0, 'APNI', '(description of <b>APNI</b>)', 'apni'),
(nextval('nsl_global_seq'), 0, 'ANHSIR', '(description of <b>ANHSIR</b>)', 'anhsir'),
(nextval('nsl_global_seq'), 0, 'AusMoss', '(description of <b>AusMoss</b>)', 'ausmoss'),
(nextval('nsl_global_seq'), 0, 'Algae', '(description of <b>Algae</b>)', 'algae'),
(nextval('nsl_global_seq'), 0, 'Lichen', '(description of <b>Lichen</b>)', 'lichen'),
(nextval('nsl_global_seq'), 0, 'Fungi', '(description of <b>Fungi</b>)', 'fungi');
--language
INSERT INTO public.language (id, lock_version, iso6391code, iso6393code, name) VALUES
(nextval('nsl_global_seq'), 0, null, 'mul', 'Multiple languages'),
(nextval('nsl_global_seq'), 0, null, 'zxx', 'No linguistic content'),
(nextval('nsl_global_seq'), 0, null, 'mis', 'Uncoded languages'),
(nextval('nsl_global_seq'), 0, null, 'und', 'Undetermined'),
(nextval('nsl_global_seq'), 0, 'aa', 'aar', 'Afar'),
(nextval('nsl_global_seq'), 0, 'ab', 'abk', 'Abkhazian'),
(nextval('nsl_global_seq'), 0, null, 'ace', 'Achinese'),
(nextval('nsl_global_seq'), 0, null, 'ach', 'Acoli'),
(nextval('nsl_global_seq'), 0, null, 'ada', 'Adangme'),
(nextval('nsl_global_seq'), 0, null, 'ady', 'Adyghe'),
(nextval('nsl_global_seq'), 0, 'af', 'afr', 'Afrikaans'),
(nextval('nsl_global_seq'), 0, null, 'ain', 'Ainu'),
(nextval('nsl_global_seq'), 0, null, 'ale', 'Aleut'),
(nextval('nsl_global_seq'), 0, null, 'alt', 'Southern Altai'),
(nextval('nsl_global_seq'), 0, 'am', 'amh', 'Amharic'),
(nextval('nsl_global_seq'), 0, null, 'anp', 'Angika'),
(nextval('nsl_global_seq'), 0, 'an', 'arg', 'Aragonese'),
(nextval('nsl_global_seq'), 0, null, 'arn', 'Mapudungun'),
(nextval('nsl_global_seq'), 0, null, 'arp', 'Arapaho'),
(nextval('nsl_global_seq'), 0, null, 'arw', 'Arawak'),
(nextval('nsl_global_seq'), 0, 'as', 'asm', 'Assamese'),
(nextval('nsl_global_seq'), 0, null, 'ast', 'Asturian'),
(nextval('nsl_global_seq'), 0, 'av', 'ava', 'Avaric'),
(nextval('nsl_global_seq'), 0, null, 'awa', 'Awadhi'),
(nextval('nsl_global_seq'), 0, 'ba', 'bak', 'Bashkir'),
(nextval('nsl_global_seq'), 0, 'bm', 'bam', 'Bambara'),
(nextval('nsl_global_seq'), 0, null, 'ban', 'Balinese'),
(nextval('nsl_global_seq'), 0, null, 'bas', 'Basa'),
(nextval('nsl_global_seq'), 0, null, 'bej', 'Beja'),
(nextval('nsl_global_seq'), 0, 'be', 'bel', 'Belarusian'),
(nextval('nsl_global_seq'), 0, null, 'bem', 'Bemba'),
(nextval('nsl_global_seq'), 0, 'bn', 'ben', 'Bengali'),
(nextval('nsl_global_seq'), 0, null, 'bho', 'Bhojpuri'),
(nextval('nsl_global_seq'), 0, null, 'bin', 'Bini'),
(nextval('nsl_global_seq'), 0, 'bi', 'bis', 'Bislama'),
(nextval('nsl_global_seq'), 0, null, 'bla', 'Siksika'),
(nextval('nsl_global_seq'), 0, 'bo', 'bod', 'Tibetan'),
(nextval('nsl_global_seq'), 0, 'bs', 'bos', 'Bosnian'),
(nextval('nsl_global_seq'), 0, null, 'bra', 'Braj'),
(nextval('nsl_global_seq'), 0, 'br', 'bre', 'Breton'),
(nextval('nsl_global_seq'), 0, null, 'bug', 'Buginese'),
(nextval('nsl_global_seq'), 0, 'bg', 'bul', 'Bulgarian'),
(nextval('nsl_global_seq'), 0, null, 'byn', 'Bilin'),
(nextval('nsl_global_seq'), 0, null, 'cad', 'Caddo'),
(nextval('nsl_global_seq'), 0, null, 'car', 'Galibi Carib'),
(nextval('nsl_global_seq'), 0, 'ca', 'cat', 'Catalan'),
(nextval('nsl_global_seq'), 0, null, 'ceb', 'Cebuano'),
(nextval('nsl_global_seq'), 0, 'cs', 'ces', 'Czech'),
(nextval('nsl_global_seq'), 0, 'ch', 'cha', 'Chamorro'),
(nextval('nsl_global_seq'), 0, 'ce', 'che', 'Chechen'),
(nextval('nsl_global_seq'), 0, null, 'chk', 'Chuukese'),
(nextval('nsl_global_seq'), 0, null, 'chn', 'Chinook jargon'),
(nextval('nsl_global_seq'), 0, null, 'cho', 'Choctaw'),
(nextval('nsl_global_seq'), 0, null, 'chp', 'Chipewyan'),
(nextval('nsl_global_seq'), 0, null, 'chr', 'Cherokee'),
(nextval('nsl_global_seq'), 0, 'cv', 'chv', 'Chuvash'),
(nextval('nsl_global_seq'), 0, null, 'chy', 'Cheyenne'),
(nextval('nsl_global_seq'), 0, 'kw', 'cor', 'Cornish'),
(nextval('nsl_global_seq'), 0, 'co', 'cos', 'Corsican'),
(nextval('nsl_global_seq'), 0, null, 'crh', 'Crimean Tatar'),
(nextval('nsl_global_seq'), 0, null, 'csb', 'Kashubian'),
(nextval('nsl_global_seq'), 0, 'cy', 'cym', 'Welsh'),
(nextval('nsl_global_seq'), 0, null, 'dak', 'Dakota'),
(nextval('nsl_global_seq'), 0, 'da', 'dan', 'Danish'),
(nextval('nsl_global_seq'), 0, null, 'dar', 'Dargwa'),
(nextval('nsl_global_seq'), 0, 'de', 'deu', 'German'),
(nextval('nsl_global_seq'), 0, null, 'dgr', 'Dogrib'),
(nextval('nsl_global_seq'), 0, 'dv', 'div', 'Dhivehi'),
(nextval('nsl_global_seq'), 0, null, 'dsb', 'Lower Sorbian'),
(nextval('nsl_global_seq'), 0, null, 'dua', 'Duala'),
(nextval('nsl_global_seq'), 0, null, 'dyu', 'Dyula'),
(nextval('nsl_global_seq'), 0, 'dz', 'dzo', 'Dzongkha'),
(nextval('nsl_global_seq'), 0, null, 'efi', 'Efik'),
(nextval('nsl_global_seq'), 0, null, 'eka', 'Ekajuk'),
(nextval('nsl_global_seq'), 0, 'el', 'ell', 'Greek'),
(nextval('nsl_global_seq'), 0, 'en', 'eng', 'English'),
(nextval('nsl_global_seq'), 0, 'eu', 'eus', 'Basque'),
(nextval('nsl_global_seq'), 0, 'ee', 'ewe', 'Ewe'),
(nextval('nsl_global_seq'), 0, null, 'ewo', 'Ewondo'),
(nextval('nsl_global_seq'), 0, null, 'fan', 'Fang'),
(nextval('nsl_global_seq'), 0, 'fo', 'fao', 'Faroese'),
(nextval('nsl_global_seq'), 0, null, 'fat', 'Fanti'),
(nextval('nsl_global_seq'), 0, 'fj', 'fij', 'Fijian'),
(nextval('nsl_global_seq'), 0, null, 'fil', 'Filipino'),
(nextval('nsl_global_seq'), 0, 'fi', 'fin', 'Finnish'),
(nextval('nsl_global_seq'), 0, null, 'fon', 'Fon'),
(nextval('nsl_global_seq'), 0, 'fr', 'fra', 'French'),
(nextval('nsl_global_seq'), 0, null, 'frr', 'Northern Frisian'),
(nextval('nsl_global_seq'), 0, null, 'frs', 'Eastern Frisian'),
(nextval('nsl_global_seq'), 0, 'fy', 'fry', 'Western Frisian'),
(nextval('nsl_global_seq'), 0, null, 'fur', 'Friulian'),
(nextval('nsl_global_seq'), 0, null, 'gaa', 'Ga'),
(nextval('nsl_global_seq'), 0, null, 'gay', 'Gayo'),
(nextval('nsl_global_seq'), 0, null, 'gil', 'Gilbertese'),
(nextval('nsl_global_seq'), 0, 'gd', 'gla', 'Scottish Gaelic'),
(nextval('nsl_global_seq'), 0, 'ga', 'gle', 'Irish'),
(nextval('nsl_global_seq'), 0, 'gl', 'glg', 'Galician'),
(nextval('nsl_global_seq'), 0, 'gv', 'glv', 'Manx'),
(nextval('nsl_global_seq'), 0, null, 'gor', 'Gorontalo'),
(nextval('nsl_global_seq'), 0, null, 'gsw', 'Swiss German'),
(nextval('nsl_global_seq'), 0, 'gu', 'guj', 'Gujarati'),
(nextval('nsl_global_seq'), 0, null, 'gwi', 'Gwichʼin'),
(nextval('nsl_global_seq'), 0, 'ht', 'hat', 'Haitian'),
(nextval('nsl_global_seq'), 0, 'ha', 'hau', 'Hausa'),
(nextval('nsl_global_seq'), 0, null, 'haw', 'Hawaiian'),
(nextval('nsl_global_seq'), 0, 'he', 'heb', 'Hebrew'),
(nextval('nsl_global_seq'), 0, 'hz', 'her', 'Herero'),
(nextval('nsl_global_seq'), 0, null, 'hil', 'Hiligaynon'),
(nextval('nsl_global_seq'), 0, 'hi', 'hin', 'Hindi'),
(nextval('nsl_global_seq'), 0, 'ho', 'hmo', 'Hiri Motu'),
(nextval('nsl_global_seq'), 0, 'hr', 'hrv', 'Croatian'),
(nextval('nsl_global_seq'), 0, null, 'hsb', 'Upper Sorbian'),
(nextval('nsl_global_seq'), 0, 'hu', 'hun', 'Hungarian'),
(nextval('nsl_global_seq'), 0, null, 'hup', 'Hupa'),
(nextval('nsl_global_seq'), 0, 'hy', 'hye', 'Armenian'),
(nextval('nsl_global_seq'), 0, null, 'iba', 'Iban'),
(nextval('nsl_global_seq'), 0, 'ig', 'ibo', 'Igbo'),
(nextval('nsl_global_seq'), 0, 'ii', 'iii', 'Sichuan Yi'),
(nextval('nsl_global_seq'), 0, null, 'ilo', 'Iloko'),
(nextval('nsl_global_seq'), 0, 'id', 'ind', 'Indonesian'),
(nextval('nsl_global_seq'), 0, null, 'inh', 'Ingush'),
(nextval('nsl_global_seq'), 0, 'is', 'isl', 'Icelandic'),
(nextval('nsl_global_seq'), 0, 'it', 'ita', 'Italian'),
(nextval('nsl_global_seq'), 0, 'jv', 'jav', 'Javanese'),
(nextval('nsl_global_seq'), 0, 'ja', 'jpn', 'Japanese'),
(nextval('nsl_global_seq'), 0, null, 'jpr', 'Judeo-Persian'),
(nextval('nsl_global_seq'), 0, null, 'kaa', 'Kara-Kalpak'),
(nextval('nsl_global_seq'), 0, null, 'kab', 'Kabyle'),
(nextval('nsl_global_seq'), 0, null, 'kac', 'Kachin'),
(nextval('nsl_global_seq'), 0, 'kl', 'kal', 'Kalaallisut'),
(nextval('nsl_global_seq'), 0, null, 'kam', 'Kamba'),
(nextval('nsl_global_seq'), 0, 'kn', 'kan', 'Kannada'),
(nextval('nsl_global_seq'), 0, 'ks', 'kas', 'Kashmiri'),
(nextval('nsl_global_seq'), 0, 'ka', 'kat', 'Georgian'),
(nextval('nsl_global_seq'), 0, 'kk', 'kaz', 'Kazakh'),
(nextval('nsl_global_seq'), 0, null, 'kbd', 'Kabardian'),
(nextval('nsl_global_seq'), 0, null, 'kha', 'Khasi'),
(nextval('nsl_global_seq'), 0, 'km', 'khm', 'Central Khmer'),
(nextval('nsl_global_seq'), 0, 'ki', 'kik', 'Kikuyu'),
(nextval('nsl_global_seq'), 0, 'rw', 'kin', 'Kinyarwanda'),
(nextval('nsl_global_seq'), 0, 'ky', 'kir', 'Kirghiz'),
(nextval('nsl_global_seq'), 0, null, 'kmb', 'Kimbundu'),
(nextval('nsl_global_seq'), 0, 'ko', 'kor', 'Korean'),
(nextval('nsl_global_seq'), 0, null, 'kos', 'Kosraean'),
(nextval('nsl_global_seq'), 0, null, 'krc', 'Karachay-Balkar'),
(nextval('nsl_global_seq'), 0, null, 'krl', 'Karelian'),
(nextval('nsl_global_seq'), 0, null, 'kru', 'Kurukh'),
(nextval('nsl_global_seq'), 0, 'kj', 'kua', 'Kuanyama'),
(nextval('nsl_global_seq'), 0, null, 'kum', 'Kumyk'),
(nextval('nsl_global_seq'), 0, null, 'kut', 'Kutenai'),
(nextval('nsl_global_seq'), 0, null, 'lad', 'Ladino'),
(nextval('nsl_global_seq'), 0, null, 'lam', 'Lamba'),
(nextval('nsl_global_seq'), 0, 'la', 'lat', 'Latin'),
(nextval('nsl_global_seq'), 0, 'lo', 'lao', 'Lao'),
(nextval('nsl_global_seq'), 0, null, 'lez', 'Lezghian'),
(nextval('nsl_global_seq'), 0, 'li', 'lim', 'Limburgan'),
(nextval('nsl_global_seq'), 0, 'ln', 'lin', 'Lingala'),
(nextval('nsl_global_seq'), 0, 'lt', 'lit', 'Lithuanian'),
(nextval('nsl_global_seq'), 0, null, 'lol', 'Mongo'),
(nextval('nsl_global_seq'), 0, null, 'loz', 'Lozi'),
(nextval('nsl_global_seq'), 0, 'lb', 'ltz', 'Luxembourgish'),
(nextval('nsl_global_seq'), 0, null, 'lua', 'Luba-Lulua'),
(nextval('nsl_global_seq'), 0, 'lu', 'lub', 'Luba-Katanga'),
(nextval('nsl_global_seq'), 0, 'lg', 'lug', 'Ganda'),
(nextval('nsl_global_seq'), 0, null, 'lui', 'Luiseno'),
(nextval('nsl_global_seq'), 0, null, 'lun', 'Lunda'),
(nextval('nsl_global_seq'), 0, null, 'luo', 'Luo'),
(nextval('nsl_global_seq'), 0, null, 'lus', 'Lushai'),
(nextval('nsl_global_seq'), 0, null, 'mad', 'Madurese'),
(nextval('nsl_global_seq'), 0, null, 'mag', 'Magahi'),
(nextval('nsl_global_seq'), 0, 'mh', 'mah', 'Marshallese'),
(nextval('nsl_global_seq'), 0, null, 'mai', 'Maithili'),
(nextval('nsl_global_seq'), 0, null, 'mak', 'Makasar'),
(nextval('nsl_global_seq'), 0, 'ml', 'mal', 'Malayalam'),
(nextval('nsl_global_seq'), 0, 'mr', 'mar', 'Marathi'),
(nextval('nsl_global_seq'), 0, null, 'mas', 'Masai'),
(nextval('nsl_global_seq'), 0, null, 'mdf', 'Moksha'),
(nextval('nsl_global_seq'), 0, null, 'mdr', 'Mandar'),
(nextval('nsl_global_seq'), 0, null, 'men', 'Mende'),
(nextval('nsl_global_seq'), 0, null, 'mic', 'Mi''kmaq'),
(nextval('nsl_global_seq'), 0, null, 'min', 'Minangkabau'),
(nextval('nsl_global_seq'), 0, 'mk', 'mkd', 'Macedonian'),
(nextval('nsl_global_seq'), 0, 'mt', 'mlt', 'Maltese'),
(nextval('nsl_global_seq'), 0, null, 'mnc', 'Manchu'),
(nextval('nsl_global_seq'), 0, null, 'mni', 'Manipuri'),
(nextval('nsl_global_seq'), 0, null, 'moh', 'Mohawk'),
(nextval('nsl_global_seq'), 0, null, 'mos', 'Mossi'),
(nextval('nsl_global_seq'), 0, 'mi', 'mri', 'Maori'),
(nextval('nsl_global_seq'), 0, null, 'mus', 'Creek'),
(nextval('nsl_global_seq'), 0, null, 'mwl', 'Mirandese'),
(nextval('nsl_global_seq'), 0, 'my', 'mya', 'Burmese'),
(nextval('nsl_global_seq'), 0, null, 'myv', 'Erzya'),
(nextval('nsl_global_seq'), 0, null, 'nap', 'Neapolitan'),
(nextval('nsl_global_seq'), 0, 'na', 'nau', 'Nauru'),
(nextval('nsl_global_seq'), 0, 'nv', 'nav', 'Navajo'),
(nextval('nsl_global_seq'), 0, 'nr', 'nbl', 'South Ndebele'),
(nextval('nsl_global_seq'), 0, 'nd', 'nde', 'North Ndebele'),
(nextval('nsl_global_seq'), 0, 'ng', 'ndo', 'Ndonga'),
(nextval('nsl_global_seq'), 0, null, 'nds', 'Low German'),
(nextval('nsl_global_seq'), 0, null, 'new', 'Newari'),
(nextval('nsl_global_seq'), 0, null, 'nia', 'Nias'),
(nextval('nsl_global_seq'), 0, null, 'niu', 'Niuean'),
(nextval('nsl_global_seq'), 0, 'nl', 'nld', 'Dutch'),
(nextval('nsl_global_seq'), 0, 'nn', 'nno', 'Norwegian Nynorsk'),
(nextval('nsl_global_seq'), 0, 'nb', 'nob', 'Norwegian Bokmål'),
(nextval('nsl_global_seq'), 0, null, 'nog', 'Nogai'),
(nextval('nsl_global_seq'), 0, null, 'nqo', 'N''Ko'),
(nextval('nsl_global_seq'), 0, null, 'nso', 'Pedi'),
(nextval('nsl_global_seq'), 0, 'ny', 'nya', 'Nyanja'),
(nextval('nsl_global_seq'), 0, null, 'nym', 'Nyamwezi'),
(nextval('nsl_global_seq'), 0, null, 'nyn', 'Nyankole'),
(nextval('nsl_global_seq'), 0, null, 'nyo', 'Nyoro'),
(nextval('nsl_global_seq'), 0, null, 'nzi', 'Nzima'),
(nextval('nsl_global_seq'), 0, 'oc', 'oci', 'Occitan'),
(nextval('nsl_global_seq'), 0, null, 'osa', 'Osage'),
(nextval('nsl_global_seq'), 0, 'os', 'oss', 'Ossetian'),
(nextval('nsl_global_seq'), 0, null, 'pag', 'Pangasinan'),
(nextval('nsl_global_seq'), 0, null, 'pam', 'Pampanga'),
(nextval('nsl_global_seq'), 0, 'pa', 'pan', 'Panjabi'),
(nextval('nsl_global_seq'), 0, null, 'pap', 'Papiamento'),
(nextval('nsl_global_seq'), 0, null, 'pau', 'Palauan'),
(nextval('nsl_global_seq'), 0, 'pl', 'pol', 'Polish'),
(nextval('nsl_global_seq'), 0, null, 'pon', 'Pohnpeian'),
(nextval('nsl_global_seq'), 0, 'pt', 'por', 'Portuguese'),
(nextval('nsl_global_seq'), 0, null, 'rap', 'Rapanui'),
(nextval('nsl_global_seq'), 0, null, 'rar', 'Rarotongan'),
(nextval('nsl_global_seq'), 0, 'rm', 'roh', 'Romansh'),
(nextval('nsl_global_seq'), 0, 'ro', 'ron', 'Romanian'),
(nextval('nsl_global_seq'), 0, 'rn', 'run', 'Rundi'),
(nextval('nsl_global_seq'), 0, null, 'rup', 'Macedo-Romanian'),
(nextval('nsl_global_seq'), 0, 'ru', 'rus', 'Russian'),
(nextval('nsl_global_seq'), 0, null, 'sad', 'Sandawe'),
(nextval('nsl_global_seq'), 0, 'sg', 'sag', 'Sango'),
(nextval('nsl_global_seq'), 0, null, 'sah', 'Yakut'),
(nextval('nsl_global_seq'), 0, null, 'sas', 'Sasak'),
(nextval('nsl_global_seq'), 0, null, 'sat', 'Santali'),
(nextval('nsl_global_seq'), 0, null, 'scn', 'Sicilian'),
(nextval('nsl_global_seq'), 0, null, 'sco', 'Scots'),
(nextval('nsl_global_seq'), 0, null, 'sel', 'Selkup'),
(nextval('nsl_global_seq'), 0, null, 'shn', 'Shan'),
(nextval('nsl_global_seq'), 0, null, 'sid', 'Sidamo'),
(nextval('nsl_global_seq'), 0, 'si', 'sin', 'Sinhala'),
(nextval('nsl_global_seq'), 0, 'sk', 'slk', 'Slovak'),
(nextval('nsl_global_seq'), 0, 'sl', 'slv', 'Slovenian'),
(nextval('nsl_global_seq'), 0, null, 'sma', 'Southern Sami'),
(nextval('nsl_global_seq'), 0, 'se', 'sme', 'Northern Sami'),
(nextval('nsl_global_seq'), 0, null, 'smj', 'Lule Sami'),
(nextval('nsl_global_seq'), 0, null, 'smn', 'Inari Sami'),
(nextval('nsl_global_seq'), 0, 'sm', 'smo', 'Samoan'),
(nextval('nsl_global_seq'), 0, null, 'sms', 'Skolt Sami'),
(nextval('nsl_global_seq'), 0, 'sn', 'sna', 'Shona'),
(nextval('nsl_global_seq'), 0, 'sd', 'snd', 'Sindhi'),
(nextval('nsl_global_seq'), 0, null, 'snk', 'Soninke'),
(nextval('nsl_global_seq'), 0, 'so', 'som', 'Somali'),
(nextval('nsl_global_seq'), 0, 'st', 'sot', 'Southern Sotho'),
(nextval('nsl_global_seq'), 0, 'es', 'spa', 'Spanish'),
(nextval('nsl_global_seq'), 0, null, 'srn', 'Sranan Tongo'),
(nextval('nsl_global_seq'), 0, 'sr', 'srp', 'Serbian'),
(nextval('nsl_global_seq'), 0, null, 'srr', 'Serer'),
(nextval('nsl_global_seq'), 0, 'ss', 'ssw', 'Swati'),
(nextval('nsl_global_seq'), 0, null, 'suk', 'Sukuma'),
(nextval('nsl_global_seq'), 0, 'su', 'sun', 'Sundanese'),
(nextval('nsl_global_seq'), 0, null, 'sus', 'Susu'),
(nextval('nsl_global_seq'), 0, 'sv', 'swe', 'Swedish'),
(nextval('nsl_global_seq'), 0, 'ty', 'tah', 'Tahitian'),
(nextval('nsl_global_seq'), 0, 'ta', 'tam', 'Tamil'),
(nextval('nsl_global_seq'), 0, 'tt', 'tat', 'Tatar'),
(nextval('nsl_global_seq'), 0, 'te', 'tel', 'Telugu'),
(nextval('nsl_global_seq'), 0, null, 'tem', 'Timne'),
(nextval('nsl_global_seq'), 0, null, 'ter', 'Tereno'),
(nextval('nsl_global_seq'), 0, null, 'tet', 'Tetum'),
(nextval('nsl_global_seq'), 0, 'tg', 'tgk', 'Tajik'),
(nextval('nsl_global_seq'), 0, 'tl', 'tgl', 'Tagalog'),
(nextval('nsl_global_seq'), 0, 'th', 'tha', 'Thai'),
(nextval('nsl_global_seq'), 0, null, 'tig', 'Tigre'),
(nextval('nsl_global_seq'), 0, 'ti', 'tir', 'Tigrinya'),
(nextval('nsl_global_seq'), 0, null, 'tiv', 'Tiv'),
(nextval('nsl_global_seq'), 0, null, 'tkl', 'Tokelau'),
(nextval('nsl_global_seq'), 0, null, 'tli', 'Tlingit'),
(nextval('nsl_global_seq'), 0, null, 'tog', 'Tonga (Nyasa)'),
(nextval('nsl_global_seq'), 0, 'to', 'ton', 'Tonga (Tonga Islands)'),
(nextval('nsl_global_seq'), 0, null, 'tpi', 'Tok Pisin'),
(nextval('nsl_global_seq'), 0, null, 'tsi', 'Tsimshian'),
(nextval('nsl_global_seq'), 0, 'tn', 'tsn', 'Tswana'),
(nextval('nsl_global_seq'), 0, 'ts', 'tso', 'Tsonga'),
(nextval('nsl_global_seq'), 0, 'tk', 'tuk', 'Turkmen'),
(nextval('nsl_global_seq'), 0, null, 'tum', 'Tumbuka'),
(nextval('nsl_global_seq'), 0, 'tr', 'tur', 'Turkish'),
(nextval('nsl_global_seq'), 0, null, 'tvl', 'Tuvalu'),
(nextval('nsl_global_seq'), 0, 'tw', 'twi', 'Twi'),
(nextval('nsl_global_seq'), 0, null, 'tyv', 'Tuvinian'),
(nextval('nsl_global_seq'), 0, null, 'udm', 'Udmurt'),
(nextval('nsl_global_seq'), 0, 'ug', 'uig', 'Uighur'),
(nextval('nsl_global_seq'), 0, 'uk', 'ukr', 'Ukrainian'),
(nextval('nsl_global_seq'), 0, null, 'umb', 'Umbundu'),
(nextval('nsl_global_seq'), 0, 'ur', 'urd', 'Urdu'),
(nextval('nsl_global_seq'), 0, null, 'vai', 'Vai'),
(nextval('nsl_global_seq'), 0, 've', 'ven', 'Venda'),
(nextval('nsl_global_seq'), 0, 'vi', 'vie', 'Vietnamese'),
(nextval('nsl_global_seq'), 0, null, 'vot', 'Votic'),
(nextval('nsl_global_seq'), 0, null, 'wal', 'Wolaytta'),
(nextval('nsl_global_seq'), 0, null, 'war', 'Waray'),
(nextval('nsl_global_seq'), 0, null, 'was', 'Washo'),
(nextval('nsl_global_seq'), 0, 'wa', 'wln', 'Walloon'),
(nextval('nsl_global_seq'), 0, 'wo', 'wol', 'Wolof'),
(nextval('nsl_global_seq'), 0, null, 'xal', 'Kalmyk'),
(nextval('nsl_global_seq'), 0, 'xh', 'xho', 'Xhosa'),
(nextval('nsl_global_seq'), 0, null, 'yao', 'Yao'),
(nextval('nsl_global_seq'), 0, null, 'yap', 'Yapese'),
(nextval('nsl_global_seq'), 0, 'yo', 'yor', 'Yoruba'),
(nextval('nsl_global_seq'), 0, null, 'zen', 'Zenaga'),
(nextval('nsl_global_seq'), 0, 'zu', 'zul', 'Zulu'),
(nextval('nsl_global_seq'), 0, null, 'zun', 'Zuni'),
(nextval('nsl_global_seq'), 0, 'ak', 'aka', 'Akan'),
(nextval('nsl_global_seq'), 0, 'ar', 'ara', 'Arabic'),
(nextval('nsl_global_seq'), 0, 'ay', 'aym', 'Aymara'),
(nextval('nsl_global_seq'), 0, 'az', 'aze', 'Azerbaijani'),
(nextval('nsl_global_seq'), 0, null, 'bal', 'Baluchi'),
(nextval('nsl_global_seq'), 0, null, 'bik', 'Bikol'),
(nextval('nsl_global_seq'), 0, null, 'bua', 'Buriat'),
(nextval('nsl_global_seq'), 0, null, 'chm', 'Mari'),
(nextval('nsl_global_seq'), 0, 'cr', 'cre', 'Cree'),
(nextval('nsl_global_seq'), 0, null, 'del', 'Delaware'),
(nextval('nsl_global_seq'), 0, null, 'den', 'Slave'),
(nextval('nsl_global_seq'), 0, null, 'din', 'Dinka'),
(nextval('nsl_global_seq'), 0, null, 'doi', 'Dogri'),
(nextval('nsl_global_seq'), 0, 'et', 'est', 'Estonian'),
(nextval('nsl_global_seq'), 0, 'fa', 'fas', 'Persian'),
(nextval('nsl_global_seq'), 0, 'ff', 'ful', 'Fulah'),
(nextval('nsl_global_seq'), 0, null, 'gba', 'Gbaya'),
(nextval('nsl_global_seq'), 0, null, 'gon', 'Gondi'),
(nextval('nsl_global_seq'), 0, null, 'grb', 'Grebo'),
(nextval('nsl_global_seq'), 0, 'gn', 'grn', 'Guarani'),
(nextval('nsl_global_seq'), 0, null, 'hai', 'Haida'),
(nextval('nsl_global_seq'), 0, null, 'hmn', 'Hmong'),
(nextval('nsl_global_seq'), 0, 'iu', 'iku', 'Inuktitut'),
(nextval('nsl_global_seq'), 0, 'ik', 'ipk', 'Inupiaq'),
(nextval('nsl_global_seq'), 0, null, 'jrb', 'Judeo-Arabic'),
(nextval('nsl_global_seq'), 0, 'kr', 'kau', 'Kanuri'),
(nextval('nsl_global_seq'), 0, null, 'kok', 'Konkani'),
(nextval('nsl_global_seq'), 0, 'kv', 'kom', 'Komi'),
(nextval('nsl_global_seq'), 0, 'kg', 'kon', 'Kongo'),
(nextval('nsl_global_seq'), 0, null, 'kpe', 'Kpelle'),
(nextval('nsl_global_seq'), 0, 'ku', 'kur', 'Kurdish'),
(nextval('nsl_global_seq'), 0, null, 'lah', 'Lahnda'),
(nextval('nsl_global_seq'), 0, 'lv', 'lav', 'Latvian'),
(nextval('nsl_global_seq'), 0, null, 'man', 'Mandingo'),
(nextval('nsl_global_seq'), 0, 'mg', 'mlg', 'Malagasy'),
(nextval('nsl_global_seq'), 0, 'mn', 'mon', 'Mongolian'),
(nextval('nsl_global_seq'), 0, 'ms', 'msa', 'Malay'),
(nextval('nsl_global_seq'), 0, null, 'mwr', 'Marwari'),
(nextval('nsl_global_seq'), 0, 'ne', 'nep', 'Nepali'),
(nextval('nsl_global_seq'), 0, 'no', 'nor', 'Norwegian'),
(nextval('nsl_global_seq'), 0, 'oj', 'oji', 'Ojibwa'),
(nextval('nsl_global_seq'), 0, 'or', 'ori', 'Oriya'),
(nextval('nsl_global_seq'), 0, 'om', 'orm', 'Oromo'),
(nextval('nsl_global_seq'), 0, 'ps', 'pus', 'Pushto'),
(nextval('nsl_global_seq'), 0, 'qu', 'que', 'Quechua'),
(nextval('nsl_global_seq'), 0, null, 'raj', 'Rajasthani'),
(nextval('nsl_global_seq'), 0, null, 'rom', 'Romany'),
(nextval('nsl_global_seq'), 0, 'sq', 'sqi', 'Albanian'),
(nextval('nsl_global_seq'), 0, 'sc', 'srd', 'Sardinian'),
(nextval('nsl_global_seq'), 0, 'sw', 'swa', 'Swahili'),
(nextval('nsl_global_seq'), 0, null, 'syr', 'Syriac'),
(nextval('nsl_global_seq'), 0, null, 'tmh', 'Tamashek'),
(nextval('nsl_global_seq'), 0, 'uz', 'uzb', 'Uzbek'),
(nextval('nsl_global_seq'), 0, 'yi', 'yid', 'Yiddish'),
(nextval('nsl_global_seq'), 0, null, 'zap', 'Zapotec'),
(nextval('nsl_global_seq'), 0, 'za', 'zha', 'Zhuang'),
(nextval('nsl_global_seq'), 0, 'zh', 'zho', 'Chinese'),
(nextval('nsl_global_seq'), 0, null, 'zza', 'Zaza');
-- instance note key
INSERT INTO public.instance_note_key (id, lock_version, deprecated, name, sort_order, description_html, rdf_id) VALUES
(nextval('nsl_global_seq'), 0, false, 'Neotype', 3, '(description of <b>Neotype</b>)', 'neotype'),
(nextval('nsl_global_seq'), 0, true, 'Ex.distribution', 100, '(description of <b>Ex.distribution</b>)', 'ex-distribution'),
(nextval('nsl_global_seq'), 0, false, 'APC Comment', 7, '(description of <b>APC Comment</b>)', 'apc-comment'),
(nextval('nsl_global_seq'), 0, false, 'EPBC Impact', 10, '(description of <b>EPBC Impact</b>)', 'epbc-impact'),
(nextval('nsl_global_seq'), 0, true, 'Status', 100, '(description of <b>Status</b>)', 'status'),
(nextval('nsl_global_seq'), 0, true, 'Under', 100, '(description of <b>Under</b>)', 'under'),
(nextval('nsl_global_seq'), 0, true, 'Distribution', 100, '(description of <b>Distribution</b>)', 'distribution'),
(nextval('nsl_global_seq'), 0, true, 'URL', 100, '(description of <b>URL</b>)', 'url'),
(nextval('nsl_global_seq'), 0, false, 'Lectotype', 2, '(description of <b>Lectotype</b>)', 'lectotype'),
(nextval('nsl_global_seq'), 0, true, 'Context', 100, '(description of <b>Context</b>)', 'context'),
(nextval('nsl_global_seq'), 0, false, 'Vernacular', 100, '(description of <b>Vernacular</b>)', 'vernacular'),
(nextval('nsl_global_seq'), 0, false, 'Text', 4, '(description of <b>Text</b>)', 'text'),
(nextval('nsl_global_seq'), 0, false, 'Comment', 5, '(description of <b>Comment</b>)', 'comment'),
(nextval('nsl_global_seq'), 0, true, 'Synonym', 100, '(description of <b>Synonym</b>)', 'synonym'),
(nextval('nsl_global_seq'), 0, false, 'Type', 1, '(description of <b>Type</b>)', 'type'),
(nextval('nsl_global_seq'), 0, false, 'APC Dist.', 8, '(description of <b>APC Dist.</b>)', 'apc-dist'),
(nextval('nsl_global_seq'), 0, false, 'Etymology', 6, '(description of <b>Etymology</b>)', 'etymology'),
(nextval('nsl_global_seq'), 0, false, 'EPBC Advice', 9, '(description of <b>EPBC Advice</b>)', 'epbc-advice'),
(nextval('nsl_global_seq'), 0, true, 'APNI', 100, '(description of <b>APNI</b>)', 'apni'),
(nextval('nsl_global_seq'), 0, false, 'Type herbarium', 11, '(description of <b>Type herbarium</b>)', 'type-herbarium'),
(nextval('nsl_global_seq'), 0, false, 'AMANI dist.', 16, '(description of <b>AMANI distribution</b>)', 'amani-distribution'),
(nextval('nsl_global_seq'), 0, false, 'AMANI comment', 17, '(description of <b>AMANI comment</b>)', 'amani-comment'),
(nextval('nsl_global_seq'), 0, false, 'Type locality', 12, '(description of <b>Type locality</b>)', 'type-locality'),
(nextval('nsl_global_seq'), 0, false, 'Type specimen', 13, '(description of <b>Type specimen</b>)', 'type-specimen'),
(nextval('nsl_global_seq'), 0, false, 'Culture collection', 100, '(description of <b>Culture collection</b>)', 'culture-collection'),
(nextval('nsl_global_seq'), 0, false, 'Graphic', 100, '(description of <b>Graphic</b>)', 'graphic'),
(nextval('nsl_global_seq'), 0, false, 'Habit', 100, '(description of <b>Habit</b>)', 'habit'),
(nextval('nsl_global_seq'), 0, false, 'Habitat', 100, '(description of <b>Habitat</b>)', 'habitat'),
(nextval('nsl_global_seq'), 0, false, 'Nutrition', 100, '(description of <b>Nutrition</b>)', 'nutrition'),
(nextval('nsl_global_seq'), 0, false, 'Type comment', 14, '(description of <b>Type comment</b>)', 'type-comment'),
(nextval('nsl_global_seq'), 0, false, 'Type illustration', 15, '(description of <b>Type illustration</b>)', 'type-illustration');
-- instance type
INSERT INTO public.instance_type (id, lock_version, citing, deprecated, doubtful, misapplied, name, nomenclatural, primary_instance, pro_parte, protologue, relationship, secondary_instance, sort_order, standalone, synonym, taxonomic, unsourced, description_html, rdf_id, has_label, of_label, bidirectional) VALUES
(nextval('nsl_global_seq'), 0, false, false, false, false, '[default]', false, false, false, false, false, false, 400, false, false, false, false, '(description of <b>[default]</b>)', 'default', '[default]', '[default] of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, '[unknown]', false, false, false, false, false, false, 400, false, false, false, false, '(description of <b>[unknown]</b>)', 'unknown', '[unknown]', '[unknown] of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, '[n/a]', false, false, false, false, false, false, 400, false, false, false, false, '(description of <b>[n/a]</b>)', 'n-a', '[n/a]', '[n/a] of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'primary reference', false, true, false, false, false, false, 400, true, false, false, false, '(description of <b>primary reference</b>)', 'primary-reference', 'primary reference', 'primary reference of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'tax. nov.', false, true, false, true, false, false, 400, true, false, false, false, '(description of <b>tax. nov.</b>)', 'tax-nov', 'tax. nov.', 'tax. nov. of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'nom. nov.', false, true, false, true, false, false, 400, true, false, false, false, '(description of <b>nom. nov.</b>)', 'nom-nov', 'nom. nov.', 'nom. nov. of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'nom. et stat. nov.', false, true, false, true, false, false, 400, true, false, false, false, '(description of <b>nom. et stat. nov.</b>)', 'nom-et-stat-nov', 'nom. et stat. nov.', 'nom. et stat. nov. of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'comb. nov.', false, true, false, true, false, false, 400, true, false, false, false, '(description of <b>comb. nov.</b>)', 'comb-nov', 'comb. nov.', 'comb. nov. of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'comb. et stat. nov.', false, true, false, true, false, false, 400, true, false, false, false, '(description of <b>comb. et stat. nov.</b>)', 'comb-et-stat-nov', 'comb. et stat. nov.', 'comb. et stat. nov. of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'autonym', false, false, false, false, false, false, 400, true, false, false, false, '(description of <b>autonym</b>)', 'autonym', 'autonym', 'autonym of', false),
(nextval('nsl_global_seq'), 0, true, false, false, false, 'orthographic variant', false, false, false, false, true, false, 5, false, true, false, false, '(description of <b>orthographic variant</b>)', 'orthographic-variant', 'orthographic variant', 'orthographic variant of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'implicit autonym', false, false, false, false, false, false, 400, true, false, false, false, '(description of <b>implicit autonym</b>)', 'implicit-autonym', 'implicit autonym', 'implicit autonym of', false),
(nextval('nsl_global_seq'), 0, true, false, false, true, 'misapplied', false, false, false, false, true, false, 400, false, false, false, false, '(description of <b>misapplied</b>)', 'misapplied', 'misapplication', 'misapplied to', false),
(nextval('nsl_global_seq'), 0, true, false, false, true, 'pro parte misapplied', false, false, true, false, true, false, 70, false, false, false, false, '(description of <b>pro parte misapplied</b>)', 'pro-parte-misapplied', 'pro parte misapplication', 'pro parte misapplied to', false),
(nextval('nsl_global_seq'), 0, true, false, true, true, 'doubtful misapplied', false, false, false, false, true, false, 80, false, false, false, false, '(description of <b>doubtful misapplied</b>)', 'doubtful-misapplied', 'doubtful misapplication', 'doubtful misapplied to', false),
(nextval('nsl_global_seq'), 0, true, false, true, true, 'doubtful pro parte misapplied', false, false, false, false, true, false, 90, false, false, false, false, '(description of <b>doubtful pro parte misapplied</b>)', 'doubtful-pro-parte-misapplied', 'doubtful pro parte misapplication', 'doubtful pro parte misapplied to', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'secondary reference', false, false, false, false, false, true, 400, true, false, false, false, '(description of <b>secondary reference</b>)', 'secondary-reference', 'secondary reference', 'secondary reference of', false),
(nextval('nsl_global_seq'), 0, true, false, false, false, 'isonym', false, false, false, false, true, false, 400, false, true, false, false, '(description of <b>isonym</b>)', 'isonym', 'isonym', 'isonym of', false),
(nextval('nsl_global_seq'), 0, true, false, false, false, 'trade name', false, false, false, false, true, false, 400, false, true, false, false, '(description of <b>trade name</b>)', 'trade-name', 'trade name', 'trade name of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'excluded name', false, false, false, false, false, false, 400, false, false, false, false, '(description of <b>excluded name</b>)', 'excluded-name', 'excluded name', 'excluded name of', false),
(nextval('nsl_global_seq'), 0, false, false, true, false, 'doubtful invalid publication', false, false, false, false, false, false, 400, false, false, false, false, '(description of <b>doubtful invalid publication</b>)', 'doubtful-invalid-publication', 'doubtful invalid publication', 'doubtful invalid publication of', false),
(nextval('nsl_global_seq'), 0, true, true, false, false, 'synonym', false, false, false, false, true, false, 140, false, true, false, true, '(description of <b>synonym</b>)', 'synonym', 'synonym', 'synonym of', false),
(nextval('nsl_global_seq'), 0, true, false, false, false, 'nomenclatural synonym', true, false, false, false, true, false, 30, false, true, false, false, '(description of <b>nomenclatural synonym</b>)', 'nomenclatural-synonym', 'nomenclatural synonym', 'nomenclatural synonym of', false),
(nextval('nsl_global_seq'), 0, true, false, false, false, 'taxonomic synonym', false, false, false, false, true, false, 100, false, true, true, false, '(description of <b>taxonomic synonym</b>)', 'taxonomic-synonym', 'taxonomic synonym', 'taxonomic synonym of', false),
(nextval('nsl_global_seq'), 0, true, false, false, false, 'replaced synonym', false, false, false, false, true, false, 10, false, true, false, false, '(description of <b>replaced synonym</b>)', 'replaced-synonym', 'replaced synonym', 'replaced synonym of', false),
(nextval('nsl_global_seq'), 0, true, true, false, false, 'pro parte synonym', false, false, true, false, true, false, 150, false, true, false, false, '(description of <b>pro parte synonym</b>)', 'pro-parte-synonym', 'pro parte synonym', 'pro parte synonym of', false),
(nextval('nsl_global_seq'), 0, true, false, false, false, 'pro parte taxonomic synonym', false, false, true, false, true, false, 110, false, true, true, false, '(description of <b>pro parte taxonomic synonym</b>)', 'pro-parte-taxonomic-synonym', 'pro parte taxonomic synonym', 'pro parte taxonomic synonym of', false),
(nextval('nsl_global_seq'), 0, true, true, true, false, 'doubtful synonym', false, false, false, false, true, false, 160, false, true, false, false, '(description of <b>doubtful synonym</b>)', 'doubtful-synonym', 'doubtful synonym', 'doubtful synonym of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'homonym', false, false, false, false, false, false, 400, true, false, false, false, '(description of <b>homonym</b>)', 'homonym', 'homonym', 'homonym of', false),
(nextval('nsl_global_seq'), 0, false, true, false, false, 'invalid publication', false, false, false, false, false, false, 400, false, false, false, false, '(description of <b>invalid publication</b>)', 'invalid-publication', 'invalid publication', 'invalid publication of', false),
(nextval('nsl_global_seq'), 0, false, true, false, false, 'sens. lat.', false, false, false, false, false, false, 400, false, false, false, false, '(description of <b>sens. lat.</b>)', 'sens-lat', 'sens. lat.', 'sens. lat. of', false),
(nextval('nsl_global_seq'), 0, true, false, false, false, 'common name', false, false, false, false, true, false, 400, false, false, false, true, '(description of <b>common name</b>)', 'common-name', 'common name', 'common name of', false),
(nextval('nsl_global_seq'), 0, true, false, false, false, 'vernacular name', false, false, false, false, true, false, 400, false, false, false, true, '(description of <b>vernacular name</b>)', 'vernacular-name', 'vernacular name', 'vernacular name of', false),
(nextval('nsl_global_seq'), 0, true, false, true, false, 'doubtful taxonomic synonym', false, false, false, false, true, false, 120, false, true, true, false, '(description of <b>doubtful taxonomic synonym</b>)', 'doubtful-taxonomic-synonym', 'doubtful taxonomic synonym', 'doubtful taxonomic synonym of', false),
(nextval('nsl_global_seq'), 0, true, true, true, false, 'doubtful pro parte synonym', false, false, false, false, true, false, 170, false, true, false, false, '(description of <b>doubtful pro parte synonym</b>)', 'doubtful-pro-parte-synonym', 'doubtful pro parte synonym', 'doubtful pro parte synonym of', false),
(nextval('nsl_global_seq'), 0, true, false, true, false, 'doubtful pro parte taxonomic synonym', false, false, false, false, true, false, 130, false, true, true, false, '(description of <b>doubtful pro parte taxonomic synonym</b>)', 'doubtful-pro-parte-taxonomic-synonym', 'doubtful pro parte taxonomic synonym', 'doubtful pro parte taxonomic synonym of', false),
(nextval('nsl_global_seq'), 0, true, false, false, false, 'basionym', true, false, false, false, true, false, 10, false, true, false, false, '(description of <b>basionym</b>)', 'basionym', 'basionym', 'basionym of', false),
(nextval('nsl_global_seq'), 0, false, false, true, false, 'doubtful nomenclatural synonym', true, false, false, false, false, false, 40, false, true, false, false, '(description of <b>doubtful nomenclatural synonym</b>)', 'doubtful-nomenclatural-synonym', 'doubtful nomenclatural synonym', 'doubtful nomenclatural synonym of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'pro parte nomenclatural synonym', true, false, true, false, false, false, 50, false, true, false, false, '(description of <b>pro parte nomenclatural synonym</b>)', 'pro-parte-nomenclatural-synonym', 'pro parte nomenclatural synonym', 'pro parte nomenclatural synonym of', false),
(nextval('nsl_global_seq'), 0, false, false, false, false, 'pro parte replaced synonym', false, false, true, false, false, false, 20, false, true, false, false, '(description of <b>pro parte replaced synonym</b>)', 'pro-parte-replaced-synonym', 'pro parte replaced synonym', 'pro parte replaced synonym of', false),
(nextval('nsl_global_seq'), 0, true, false, false, true, 'unsourced misapplied', false, false, false, false, true, false, 400, false, false, false, true, '(description of <b>unsourced misapplied</b>)', 'unsourced-misapplied', 'misapplication', 'misapplied to', false),
(nextval('nsl_global_seq'), 0, true, false, false, true, 'unsourced pro parte misapplied', false, false, true, false, true, false, 70, false, false, false, true, '(description of <b>unsourced pro parte misapplied</b>)', 'unsourced-pro-parte-misapplied', 'pro parte misapplication', 'pro parte misapplied to', false),
(nextval('nsl_global_seq'), 0, true, false, true, true, 'unsourced doubtful misapplied', false, false, false, false, true, false, 80, false, false, false, true, '(description of <b>unsourced doubtful misapplied</b>)', 'unsourced-doubtful-misapplied', 'doubtful misapplication', 'doubtful misapplied to', false),
(nextval('nsl_global_seq'), 0, true, false, true, true, 'unsourced doubtful pro parte misapplied', false, false, false, false, true, false, 90, false, false, false, true, '(description of <b>unsourced doubtful pro parte misapplied</b>)', 'unsourced-doubtful-pro-parte-misapplied', 'doubtful pro parte misapplication', 'doubtful pro parte misapplied to', false);

-- name category
insert into name_category
(id, lock_version,
 name,
 sort_order,
 description_html,
 rdf_id,
 max_parents_allowed,
 min_parents_required,
 parent_1_help_text,
 parent_2_help_text,
 requires_family,
 requires_higher_ranked_parent,
 requires_name_element,
 takes_author_only,
 takes_authors,
 takes_cultivar_scoped_parent,
 takes_hybrid_scoped_parent,
 takes_name_element,
 takes_verbatim_rank,
 takes_rank)
values
(nextval('nsl_global_seq'), 0,'cultivar', 50, 'names entered and edited as cultivar names', 'cultivar', 1, 1, 'cultivar - genus and below, or unranked if unranked', null, true, false, true, false, false, true, false, true, true, true),
(nextval('nsl_global_seq'), 0,'scientific', 10, 'names entered and edited as scientific names', 'scientific', 1, 1, 'ordinary - restricted by rank, or unranked if unranked', null, true, true, true, false, true, false, false, true, true, true),
(nextval('nsl_global_seq'), 0,'cultivar hybrid', 60, 'names entered and edited as cultivar hybrid names', null, 2, 2, 'cultivar - genus and below, or unranked if unranked', 'cultivar - genus and below, or unranked if unranked', true, false, true, false, false, true, false, true, true, true),
(nextval('nsl_global_seq'), 0,'other', 70, 'names entered and edited as other names', null, 0, 0, 'ordinary - restricted by rank, or unranked if unranked', null, false, false, true, false, false, true, false, true, true, false),
(nextval('nsl_global_seq'), 0,'phrase name', 20, 'names entered and edited as scientific phrase names', null, 1, 1, 'ordinary - restricted by rank, or unranked if unranked', null, true, false, false, true, false, false, false, true, false, true),
(nextval('nsl_global_seq'), 0,'scientific hybrid formula', 30, 'names entered and edited as scientific hybrid formulae', null, 2, 2, 'hybrid - species and below or unranked if unranked', 'hybrid - species and below or unranked if unranked', true, false, false, false, false, false, true, false, true, true),
(nextval('nsl_global_seq'), 0,'scientific hybrid formula unknown 2nd parent', 40, 'names entered and edited as scientific hybrid formulae with unknown 2nd parent', null, 1, 1, 'hybrid - species and below or unranked if unranked', null, true, false, false, false, false, true, true, false, true, true);

-- name group
INSERT INTO public.name_group (id, lock_version, name, description_html, rdf_id) VALUES
(nextval('nsl_global_seq'), 0, '[unknown]', '(description of <b>[unknown]</b>)', 'unknown'),
(nextval('nsl_global_seq'), 0, '[n/a]', '(description of <b>[n/a]</b>)', 'n-a'),
(nextval('nsl_global_seq'), 0, 'botanical', '(description of <b>botanical</b>)', 'botanical'),
(nextval('nsl_global_seq'), 0, 'zoological', '(description of <b>zoological</b>)', 'zoological');

-- name rank
INSERT INTO public.name_rank (id, lock_version, abbrev, deprecated, has_parent, italicize, major, name, name_group_id, parent_rank_id, sort_order, visible_in_name, description_html, rdf_id, use_verbatim_rank, display_name) VALUES
(nextval('nsl_global_seq'), 0, 'regio', false, false, false, true,      'Regio',              (select id from name_group where name = 'botanical'), null, 8, false, '(description of <b>Regio</b>)', 'regio', false, 'Regio'),
(nextval('nsl_global_seq'), 0, 'reg.', false, false, false, true,       'Regnum',             (select id from name_group where name = 'botanical'), null, 10, false, '(description of <b>Regnum</b>)', 'regnum', false, 'Regnum'),
(nextval('nsl_global_seq'), 0, 'div.', false, false, false, true,       'Division',           (select id from name_group where name = 'botanical'), null, 20, false, '(description of <b>Division</b>)', 'division', false, 'Division'),
(nextval('nsl_global_seq'), 0, 'cl.', false, false, false, true,        'Classis',            (select id from name_group where name = 'botanical'), null, 30, false, '(description of <b>Classis</b>)', 'classis', false, 'Classis'),
(nextval('nsl_global_seq'), 0, 'subcl.', false, false, false, false,    'Subclassis',         (select id from name_group where name = 'botanical'), null, 40, false, '(description of <b>Subclassis</b>)', 'subclassis', false, 'Subclassis'),
(nextval('nsl_global_seq'), 0, 'superordo', false, false, false, false, 'Superordo',          (select id from name_group where name = 'botanical'), null, 50, false, '(description of <b>Superordo</b>)', 'superordo', false, 'Superordo'),
(nextval('nsl_global_seq'), 0, 'ordo', false, false, false, true,       'Ordo',               (select id from name_group where name = 'botanical'), null, 60, false, '(description of <b>Ordo</b>)', 'ordo', false, 'Ordo'),
(nextval('nsl_global_seq'), 0, 'subordo', false, false, false, false,   'Subordo',            (select id from name_group where name = 'botanical'), null, 70, false, '(description of <b>Subordo</b>)', 'subordo', false, 'Subordo'),
(nextval('nsl_global_seq'), 0, 'fam.', false, false, false, true,       'Familia',            (select id from name_group where name = 'botanical'), null, 80, false, '(description of <b>Familia</b>)', 'familia', false, 'Familia'),
(nextval('nsl_global_seq'), 0, 'subfam.', false, true, false, false,    'Subfamilia',         (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'fam.'), 90, false, '(description of <b>Subfamilia</b>)', 'subfamilia', false, 'Subfamilia'),
(nextval('nsl_global_seq'), 0, 'trib.', false, true, false, false,      'Tribus',             (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'fam.'), 100, false, '(description of <b>Tribus</b>)', 'tribus', false, 'Tribus'),
(nextval('nsl_global_seq'), 0, 'subtrib.', false, true, false, false,   'Subtribus',          (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'fam.'), 110, false, '(description of <b>Subtribus</b>)', 'subtribus', false, 'Subtribus'),
(nextval('nsl_global_seq'), 0, 'gen.', false, false, false, true,       'Genus',              (select id from name_group where name = 'botanical'), null,                                             120, false, '(description of <b>Genus</b>)', 'genus', false, 'Genus'),
(nextval('nsl_global_seq'), 0, 'subg.', false, true, false, false,      'Subgenus',           (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'gen.'), 130, true, '(description of <b>Subgenus</b>)', 'subgenus', false, 'Subgenus'),
(nextval('nsl_global_seq'), 0, 'sect.', false, true, false, false,      'Sectio',             (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'gen.'), 140, true, '(description of <b>Sectio</b>)', 'sectio', false, 'Sectio'),
(nextval('nsl_global_seq'), 0, 'subsect.', false, true, false, false,   'Subsectio',          (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'gen.'), 150, true, '(description of <b>Subsectio</b>)', 'subsectio', false, 'Subsectio'),
(nextval('nsl_global_seq'), 0, 'ser.', false, true, false, false,       'Series',             (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'gen.'), 160, true, '(description of <b>Series</b>)', 'series', false, 'Series'),
(nextval('nsl_global_seq'), 0, 'subser.', false, true, false, false,    'Subseries',          (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'gen.'), 170, true, '(description of <b>Subseries</b>)', 'subseries', false, 'Subseries'),
(nextval('nsl_global_seq'), 0, 'supersp.', false, true, false, false,   'Superspecies',       (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'gen.'), 180, true, '(description of <b>Superspecies</b>)', 'superspecies', false, 'Superspecies'),
(nextval('nsl_global_seq'), 0, 'sp.', false, true, false, true,         'Species',            (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'gen.'), 190, false, '(description of <b>Species</b>)', 'species', false, 'Species'),
(nextval('nsl_global_seq'), 0, 'subsp.', false, true, false, false,     'Subspecies',         (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'sp.'),  200, true, '(description of <b>Subspecies</b>)', 'subspecies', false, 'Subspecies'),
(nextval('nsl_global_seq'), 0, 'nothovar.', false, true, false, false,  'Nothovarietas',      (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'sp.'),  210, true, '(description of <b>Nothovarietas</b>)', 'nothovarietas', false, 'Nothovarietas'),
(nextval('nsl_global_seq'), 0, 'var.', false, true, false, false,       'Varietas',           (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'sp.'),  210, true, '(description of <b>Varietas</b>)', 'varietas', false, 'Varietas'),
(nextval('nsl_global_seq'), 0, 'subvar.', false, true, false, false,    'Subvarietas',        (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'sp.'),  220, true, '(description of <b>Subvarietas</b>)', 'subvarietas', false, 'Subvarietas'),
(nextval('nsl_global_seq'), 0, 'f.', false, true, false, false,         'Forma',              (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'sp.'),  230, true, '(description of <b>Forma</b>)', 'forma', false, 'Forma'),
(nextval('nsl_global_seq'), 0, 'subf.', false, true, false, false,      'Subforma',           (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'sp.'),  240, true, '(description of <b>Subforma</b>)', 'subforma', false, 'Subforma'),
(nextval('nsl_global_seq'), 0, 'form taxon', true, true, false, false,  'form taxon',         (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'sp.'),  250, false, '(description of <b>form taxon</b>)', 'form-taxon', false, 'form taxon'),
(nextval('nsl_global_seq'), 0, 'morph.', true, true, false, false,      'morphological var.', (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'sp.'),  260, false, '(description of <b>morphological var.</b>)', 'morphological-var', false, 'morphological var.'),
(nextval('nsl_global_seq'), 0, 'nothomorph', true, true, false, false,  'nothomorph.',        (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'sp.'),  270, false, '(description of <b>nothomorph.</b>)', 'nothomorph', false, 'nothomorph.'),
(nextval('nsl_global_seq'), 0, '[n/a]', false, false, false, false,     '[n/a]',              (select id from name_group where name = 'botanical'), null,                                             500, false, '(description of <b>[n/a]</b>)', 'n-a', false, '[n/a]'),
(nextval('nsl_global_seq'), 0, '[infrafamily]', false, true, false, false, '[infrafamily]',   (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'fam.'), 500, true, '(description of <b>[infrafamily]</b>)', 'infrafamily', true, '[infrafamily]'),
(nextval('nsl_global_seq'), 0, '[infragenus]', false, true, false, false, '[infragenus]',     (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'gen.'), 500, true, '(description of <b>[infragenus]</b>)', 'infragenus', true, '[infragenus]'),
(nextval('nsl_global_seq'), 0, '[unknown]', true, false, false, false,  '[unknown]',          (select id from name_group where name = 'botanical'), null,                                             500, false, '(description of <b>[unknown]</b>)', 'unknown', true, '[unknown]'),
(nextval('nsl_global_seq'), 0, '[unranked]', false, true, false, false, '[unranked]',         (select id from name_group where name = 'botanical'), null,                                             500, true, '(description of <b>[unranked]</b>)', 'unranked', true, '[unranked]'),
(nextval('nsl_global_seq'), 0, '[infrasp.]', false, true, false, false, '[infraspecies]',     (select id from name_group where name = 'botanical'), (select id from name_rank where abbrev = 'sp.'),  500, false, '(description of <b>[infraspecies]</b>)', 'infraspecies', true, '[infraspecies]');

--name status
INSERT INTO public.name_status (id, lock_version, display, name, name_group_id, name_status_id, nom_illeg, nom_inval, description_html, rdf_id) VALUES
(nextval('nsl_global_seq'), 0, true, '[default]', (select id from name_group where name = '[n/a]'), null, false, false, '(description of <b>[default]</b>)', 'default'),
(nextval('nsl_global_seq'), 0, true, '[unknown]', (select id from name_group where name = '[n/a]'), null, false, false, '(description of <b>[unknown]</b>)', 'unknown'),
(nextval('nsl_global_seq'), 0, true, '[n/a]', (select id from name_group where name = '[n/a]'), null, false, false, '(description of <b>[n/a]</b>)', 'n-a'),
(nextval('nsl_global_seq'), 0, true, '[deleted]', (select id from name_group where name = '[n/a]'), null, false, false, '(description of <b>[deleted]</b>)', 'deleted'),
(nextval('nsl_global_seq'), 0, true, 'legitimate', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>legitimate</b>)', 'legitimate'),
(nextval('nsl_global_seq'), 0, true, 'nom. inval.', (select id from name_group where name = 'botanical'), null, false, true, '(description of <b>nom. inval.</b>)', 'nom-inval'),
(nextval('nsl_global_seq'), 0, true, 'nom. inval., pro syn.', (select id from name_group where name = 'botanical'), null, false, true, '(description of <b>nom. inval., pro syn.</b>)', 'nom-inval-pro-syn'),
(nextval('nsl_global_seq'), 0, true, 'nom. inval., nom. nud.', (select id from name_group where name = 'botanical'), null, false, true, '(description of <b>nom. inval., nom. nud.</b>)', 'nom-inval-nom-nud'),
(nextval('nsl_global_seq'), 0, true, 'nom. inval., nom. subnud.', (select id from name_group where name = 'botanical'), null, false, true, '(description of <b>nom. inval., nom. subnud.</b>)', 'nom-inval-nom-subnud'),
(nextval('nsl_global_seq'), 0, true, 'nom. inval., nom. ambig.', (select id from name_group where name = 'botanical'), null, false, true, '(description of <b>nom. inval., nom. ambig.</b>)', 'nom-inval-nom-ambig'),
(nextval('nsl_global_seq'), 0, true, 'nom. inval., nom. confus.', (select id from name_group where name = 'botanical'), null, false, true, '(description of <b>nom. inval., nom. confus.</b>)', 'nom-inval-nom-confus'),
(nextval('nsl_global_seq'), 0, true, 'nom. inval., nom. prov.', (select id from name_group where name = 'botanical'), null, false, true, '(description of <b>nom. inval., nom. prov.</b>)', 'nom-inval-nom-prov'),
(nextval('nsl_global_seq'), 0, true, 'nom. inval., nom. alt.', (select id from name_group where name = 'botanical'), null, false, true, '(description of <b>nom. inval., nom. alt.</b>)', 'nom-inval-nom-alt'),
(nextval('nsl_global_seq'), 0, true, 'nom. inval., nom. dub.', (select id from name_group where name = 'botanical'), null, false, true, '(description of <b>nom. inval., nom. dub.</b>)', 'nom-inval-nom-dub'),
(nextval('nsl_global_seq'), 0, true, 'nom. inval., opera utique oppressa', (select id from name_group where name = 'botanical'), null, false, true, '(description of <b>nom. inval., opera utique oppressa</b>)', 'nom-inval-opera-utique-oppressa'),
(nextval('nsl_global_seq'), 0, true, 'nom. inval., tautonym', (select id from name_group where name = 'botanical'), null, false, true, '(description of <b>nom. inval., tautonym</b>)', 'nom-inval-tautonym'),
(nextval('nsl_global_seq'), 0, true, 'nom. illeg.', (select id from name_group where name = 'botanical'), null, true, false, '(description of <b>nom. illeg.</b>)', 'nom-illeg'),
(nextval('nsl_global_seq'), 0, true, 'nom. illeg., nom. superfl.', (select id from name_group where name = 'botanical'), null, true, false, '(description of <b>nom. illeg., nom. superfl.</b>)', 'nom-illeg-nom-superfl'),
(nextval('nsl_global_seq'), 0, true, 'nom. illeg., nom. rej.', (select id from name_group where name = 'botanical'), null, true, false, '(description of <b>nom. illeg., nom. rej.</b>)', 'nom-illeg-nom-rej'),
(nextval('nsl_global_seq'), 0, true, 'isonym', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>isonym</b>)', 'isonym'),
(nextval('nsl_global_seq'), 0, true, 'nom. superfl.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>nom. superfl.</b>)', 'nom-superfl'),
(nextval('nsl_global_seq'), 0, true, 'nom. rej.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>nom. rej.</b>)', 'nom-rej'),
(nextval('nsl_global_seq'), 0, true, 'nom. alt.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>nom. alt.</b>)', 'nom-alt'),
(nextval('nsl_global_seq'), 0, true, 'nom. cult.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>nom. cult.</b>)', 'nom-cult'),
(nextval('nsl_global_seq'), 0, true, 'nom. cons.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>nom. cons.</b>)', 'nom-cons'),
(nextval('nsl_global_seq'), 0, true, 'nom. cons., orth. cons.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>nom. cons., orth. cons.</b>)', 'nom-cons-orth-cons'),
(nextval('nsl_global_seq'), 0, true, 'nom. cons., nom. alt.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>nom. cons., nom. alt.</b>)', 'nom-cons-nom-alt'),
(nextval('nsl_global_seq'), 0, true, 'nom. cult., nom. alt.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>nom. cult., nom. alt.</b>)', 'nom-cult-nom-alt'),
(nextval('nsl_global_seq'), 0, true, 'nom. et typ. cons.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>nom. et typ. cons.</b>)', 'nom-et-typ-cons'),
(nextval('nsl_global_seq'), 0, true, 'nom. et orth. cons.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>nom. et orth. cons.</b>)', 'nom-et-orth-cons'),
(nextval('nsl_global_seq'), 0, true, 'nomina utique rejicienda', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>nomina utique rejicienda</b>)', 'nomina-utique-rejicienda'),
(nextval('nsl_global_seq'), 0, true, 'typ. cons.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>typ. cons.</b>)', 'typ-cons'),
(nextval('nsl_global_seq'), 0, true, 'orth. var.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>orth. var.</b>)', 'orth-var'),
(nextval('nsl_global_seq'), 0, true, 'orth. cons.', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>orth. cons.</b>)', 'orth-cons'),
(nextval('nsl_global_seq'), 0, true, 'manuscript', (select id from name_group where name = 'botanical'), null, false, false, '(description of <b>manuscript</b>)', 'manuscript'),
(nextval('nsl_global_seq'), 0, true, 'nom. alt., nom. illeg', (select id from name_group where name = 'botanical'), null, true, false, '(description of <b>nom. alt., nom. illeg.</b>)', 'nom-alt-nom-illeg');
-- name type                                                                                                                                                                                                                                                                           --name cat name group
INSERT INTO public.name_type (id, lock_version, autonym, connector, cultivar, formula, hybrid, name, name_category_id, name_group_id, scientific, sort_order, description_html, rdf_id, deprecated) VALUES
(nextval('nsl_global_seq'), 0, false, null, false, false, false, '[default]', (select id from name_category where name = 'other'), (select id from name_group where name = '[n/a]'), false, 1, '(description of <b>[default]</b>)', 'default', false),
(nextval('nsl_global_seq'), 0, false, null, false, false, false, '[unknown]', (select id from name_category where name = 'other'), (select id from name_group where name = '[n/a]'), false, 2, '(description of <b>[unknown]</b>)', 'unknown', false),
(nextval('nsl_global_seq'), 0, false, null, false, false, false, '[n/a]', (select id from name_category where name = 'other'), (select id from name_group where name = '[n/a]'), false, 3, '(description of <b>[n/a]</b>)', 'n-a', false),
(nextval('nsl_global_seq'), 0, false, null, false, false, false, 'scientific', (select id from name_category where name = 'scientific'), (select id from name_group where name = 'botanical'), true, 4, '(description of <b>scientific</b>)', 'scientific', false),
(nextval('nsl_global_seq'), 0, false, null, false, false, false, 'sanctioned', (select id from name_category where name = 'scientific'), (select id from name_group where name = 'botanical'), true, 5, '(description of <b>sanctioned</b>)', 'sanctioned', false),
(nextval('nsl_global_seq'), 0, false, null, false, false, false, 'phrase name', (select id from name_category where name = 'scientific'), (select id from name_group where name = 'botanical'), true, 6, '(description of <b>phrase name</b>)', 'phrase-name', false),
(nextval('nsl_global_seq'), 0, false, 'x', false, true, true, 'hybrid formula parents known', (select id from name_category where name = 'scientific'), (select id from name_group where name = 'botanical'), true, 7, '(description of <b>hybrid formula parents known</b>)', 'hybrid-formula-parents-known', false),
(nextval('nsl_global_seq'), 0, false, 'x', false, true, true, 'hybrid formula unknown 2nd parent', (select id from name_category where name = 'scientific'), (select id from name_group where name = 'botanical'), true, 8, '(description of <b>hybrid formula unknown 2nd parent</b>)', 'hybrid-formula-unknown-2nd-parent', false),
(nextval('nsl_global_seq'), 0, false, 'x', false, false, true, 'named hybrid', (select id from name_category where name = 'scientific'), (select id from name_group where name = 'botanical'), true, 9, '(description of <b>named hybrid</b>)', 'named-hybrid', false),
(nextval('nsl_global_seq'), 0, true, 'x', false, false, true, 'named hybrid autonym', (select id from name_category where name = 'scientific'), (select id from name_group where name = 'botanical'), true, 10, '(description of <b>named hybrid autonym</b>)', 'named-hybrid-autonym', false),
(nextval('nsl_global_seq'), 0, true, 'x', false, false, true, 'hybrid autonym', (select id from name_category where name = 'scientific'), (select id from name_group where name = 'botanical'), true, 11, '(description of <b>hybrid autonym</b>)', 'hybrid-autonym', false),
(nextval('nsl_global_seq'), 0, false, '-', false, true, true, 'intergrade', (select id from name_category where name = 'scientific'), (select id from name_group where name = 'botanical'), true, 12, '(description of <b>intergrade</b>)', 'intergrade', false),
(nextval('nsl_global_seq'), 0, true, null, false, false, false, 'autonym', (select id from name_category where name = 'scientific'), (select id from name_group where name = 'botanical'), true, 13, '(description of <b>autonym</b>)', 'autonym', false),
(nextval('nsl_global_seq'), 0, false, null, true, false, false, 'cultivar', (select id from name_category where name = 'cultivar'), (select id from name_group where name = 'botanical'), false, 17, '(description of <b>cultivar</b>)', 'cultivar', false),
(nextval('nsl_global_seq'), 0, false, null, true, false, true, 'cultivar hybrid', (select id from name_category where name = 'cultivar'), (select id from name_group where name = 'botanical'), false, 18, '(description of <b>cultivar hybrid</b>)', 'cultivar-hybrid', false),
(nextval('nsl_global_seq'), 0, false, null, false, false, false, 'informal', (select id from name_category where name = 'other'), (select id from name_group where name = 'botanical'), false, 26, '(description of <b>informal</b>)', 'informal', false),
(nextval('nsl_global_seq'), 0, false, null, false, false, false, 'common', (select id from name_category where name = 'other'), (select id from name_group where name = 'botanical'), false, 15, '(description of <b>common</b>)', 'common', false),
(nextval('nsl_global_seq'), 0, false, null, false, false, false, 'vernacular', (select id from name_category where name = 'other'), (select id from name_group where name = 'botanical'), false, 16, '(description of <b>vernacular</b>)', 'vernacular', false),
(nextval('nsl_global_seq'), 0, false, '+', true, true, false, 'graft/chimera', (select id from name_category where name = 'cultivar'), (select id from name_group where name = 'botanical'), false, 25, '(description of <b>graft / chimera</b>)', 'graft-chimera', false),
(nextval('nsl_global_seq'), 0, false, null, true, false, false, 'acra', (select id from name_category where name = 'cultivar'), (select id from name_group where name = 'botanical'), false, 20, '(description of <b>acra</b>)', 'acra', true),
(nextval('nsl_global_seq'), 0, false, null, true, false, true, 'acra hybrid', (select id from name_category where name = 'cultivar'), (select id from name_group where name = 'botanical'), false, 21, '(description of <b>acra hybrid</b>)', 'acra-hybrid', true),
(nextval('nsl_global_seq'), 0, false, null, true, false, false, 'pbr', (select id from name_category where name = 'cultivar'), (select id from name_group where name = 'botanical'), false, 22, '(description of <b>pbr</b>)', 'pbr', true),
(nextval('nsl_global_seq'), 0, false, null, true, false, true, 'pbr hybrid', (select id from name_category where name = 'cultivar'), (select id from name_group where name = 'botanical'), false, 23, '(description of <b>pbr hybrid</b>)', 'pbr-hybrid', true),
(nextval('nsl_global_seq'), 0, false, null, true, false, false, 'trade', (select id from name_category where name = 'cultivar'), (select id from name_group where name = 'botanical'), false, 24, '(description of <b>trade</b>)', 'trade', true),
(nextval('nsl_global_seq'), 0, false, null, true, false, true, 'trade hybrid', (select id from name_category where name = 'cultivar'), (select id from name_group where name = 'botanical'), false, 25, '(description of <b>trade hybrid</b>)', 'trade-hybrid', true),
(nextval('nsl_global_seq'), 0, false, 'x', true, true, true, 'cultivar hybrid formula', (select id from name_category where name = 'cultivar'), (select id from name_group where name = 'botanical'), false, 19, '(description of <b>cultivar hybrid formula</b>)', 'cultivar-hybrid-formula', false);
-- reference author role
INSERT INTO public.ref_author_role (id, lock_version, name, description_html, rdf_id) VALUES
(nextval('nsl_global_seq'), 0, 'Unknown', '(description of <b>Unknown</b>)', 'unknown'),
(nextval('nsl_global_seq'), 0, 'Compiler', '(description of <b>Compiler</b>)', 'compiler'),
(nextval('nsl_global_seq'), 0, 'Editor', '(description of <b>Editor</b>)', 'editor'),
(nextval('nsl_global_seq'), 0, 'Author', '(description of <b>Author</b>)', 'author');
-- reference type
INSERT INTO public.ref_type (id, lock_version, name, parent_id, parent_optional, description_html, rdf_id, use_parent_details) VALUES
(nextval('nsl_global_seq'), 0, 'Personal Communication', null, false, '(description of <b>Personal Communication</b>)', 'personal-communication', false),
(nextval('nsl_global_seq'), 0, 'Series', null, false, '(description of <b>Series</b>)', 'series', false),
(nextval('nsl_global_seq'), 0, 'Journal', null, false, '(description of <b>Journal</b>)', 'journal', false),
(nextval('nsl_global_seq'), 0, 'Index', null, false, '(description of <b>Index</b>)', 'index', false),
(nextval('nsl_global_seq'), 0, 'Herbarium annotation', null, false, '(description of <b>Herbarium annotation</b>)', 'herbarium-annotation', false),
(nextval('nsl_global_seq'), 0, 'Database', null, false, '(description of <b>Database</b>)', 'database', false),
(nextval('nsl_global_seq'), 0, 'Database Record', (select id from ref_type where name = 'Database'), false, '(description of <b>Database Record</b>)', 'database-record', false),
(nextval('nsl_global_seq'), 0, 'Paper', (select id from ref_type where name = 'Journal'), false, '(description of <b>Paper</b>)', 'paper', false),
(nextval('nsl_global_seq'), 0, 'Book', (select id from ref_type where name = 'Series'), true, '(description of <b>Book</b>)', 'book', false),
(nextval('nsl_global_seq'), 0, 'Section', (select id from ref_type where name = 'Book'), false, '(description of <b>Section</b>)', 'section', false),
(nextval('nsl_global_seq'), 0, 'Chapter', (select id from ref_type where name = 'Book'), false, '(description of <b>Chapter</b>)', 'chapter', false),
(nextval('nsl_global_seq'), 0, 'Part', (select id from ref_type where name = 'Paper'), false, '(description of <b>Part</b>)', 'part', true),
(nextval('nsl_global_seq'), 0, 'Unknown', null, true, '(description of <b>Unknown</b>)', 'unknown', false);
UPDATE public.ref_type SET parent_id = id WHERE name = 'Unknown'; --self parent

-- set up APC regions
INSERT INTO public.dist_region (description_html, def_link, name, sort_order) VALUES
('Western Australia', null, 'WA', 1),
('Cocos (Keeling) Islands', null, 'CoI', 2),
('Christmas Island', null, 'ChI', 3),
('Ashmore Reef', null, 'AR', 4),
('Cartier Island', null, 'CaI', 5),
('Northern Territory', null, 'NT', 6),
('South Australia', null, 'SA', 7),
('Queensland', null, 'Qld', 8),
('Coral Sea Islands', null, 'CSI', 9),
('New South Wales', null, 'NSW', 10),
('Lord Howe Island', null, 'LHI', 11),
('Norfolk Island', null, 'NI', 12),
('Australian Capital Australian Capital Territory excl. Jervis Bay', null, 'ACT', 13),
('Victoria', null, 'Vic', 14),
('Tasmainia', null, 'Tas', 15),
('Heard Island', null, 'HI', 16),
('McDonald Island', null, 'MDI', 17),
('Macquarie Island', null, 'MI', 18);

-- set up APC statuses
INSERT INTO public.dist_status (description_html, def_link, name, sort_order) VALUES
('a native taxon that no longer occurs in the given jurisdiction', null, 'presumed extinct', 4),
('taxa that are represented by one or more naturalised populations in a given jurisdiction, but the extent of naturalisation is uncertain and populations may or may not persist in the longer term.', null, 'doubtfully naturalised', 3),
('non-native or native taxa previously recorded as being naturalised in a given jurisdiction but of which no collections have been made within a defined timeframe.', null, 'formerly naturalised', 2),
('<p>plant taxa in a given jurisdiction where:</p>
<ul>
    <li>a native taxon has become naturalised outside of its natural range within that jurisdiction, or;</li>
    <li>a native or non-native taxon that did not originate in a given jurisdiction but has since arrived and become established there.</li>
</ul>', null, 'naturalised', 1),
('“taxa that have originated in a given area without human involvement or that have arrived there without intentional or unintentional intervention of humans from an area in which they are native” (definition from Pysek et al. (2004)).', null, 'native', 0),
('For some taxa there is uncertainty as to whether the populations present in a given jurisdiction represent native or naturalised plants or a combination of the two former categories. In these cases, the jurisdiction is listed with the parenthetical qualifier “(uncertain origin)”. Comment fields may be added under the APC reference to indicate the nature of this uncertainty.', null, 'uncertain origin', 5);

insert into dist_status_dist_status (dist_status_combining_status_id, dist_status_id)
    (SELECT comb.id, ds.id from dist_status ds, dist_status comb where ds.name = 'naturalised' and comb.name = 'uncertain origin');
insert into dist_status_dist_status (dist_status_combining_status_id, dist_status_id)
    (SELECT comb.id, ds.id from dist_status ds, dist_status comb where ds.name = 'native' and comb.name = 'naturalised');
insert into dist_status_dist_status (dist_status_combining_status_id, dist_status_id)
    (SELECT comb.id, ds.id from dist_status ds, dist_status comb where ds.name = 'native' and comb.name = 'formerly naturalised');
insert into dist_status_dist_status (dist_status_combining_status_id, dist_status_id)
    (SELECT comb.id, ds.id from dist_status ds, dist_status comb where ds.name = 'native' and comb.name = 'doubtfully naturalised');
insert into dist_status_dist_status (dist_status_combining_status_id, dist_status_id)
    (SELECT comb.id, ds.id from dist_status ds, dist_status comb where ds.name = 'native' and comb.name = 'uncertain origin');

drop table if exists temp_comb_status_order;

create table temp_comb_status_order
(
    name             varchar(255)                              not null,
    sort_order       int4    default 0                         not null,
    primary key (name)
);

insert into temp_comb_status_order (name, sort_order) VALUES
('(native)', 0),
('(naturalised)', 1),
('(native and naturalised)', 2),
('(native and doubtfully naturalised)', 3),
('(native and formerly naturalised)', 4),
('(native and uncertain origin)', 5),
('(doubtfully naturalised)', 6),
('(formerly naturalised)', 7),
('(naturalised and uncertain origin)', 8),
('(uncertain origin)', 9),
('(presumed extinct)', 10)
;

-- make all the combinations of distribution entries we can make
drop function if exists make_entries();
create function make_entries() returns integer as
$$
declare
    entry_id    bigint;
    region      record;
    status      record;
    comb_status record;
    display_str text;
    entry_order integer;
begin
    entry_order := 0;
    for region in select * from dist_region order by sort_order
        loop
            for status in select * from dist_status order by sort_order
                loop
                    display_str := region.name || ' (' || status.name || ')';
                    entry_order := region.sort_order * 20 + (select sort_order from temp_comb_status_order where name = '(' || status.name || ')');
                    insert into dist_entry (region_id, display, sort_order)
                    values (region.id, display_str, entry_order) returning id into entry_id;
                    insert into dist_entry_dist_status (dist_entry_status_id, dist_status_id)
                    values (entry_id, status.id);
                    for comb_status in select ds.*
                                       from dist_status_dist_status dsds
                                                join dist_status ds on ds.id = dsds.dist_status_combining_status_id and
                                                                       dsds.dist_status_id = status.id
                                       order by ds.sort_order
                        loop
                            display_str := region.name || ' (' || status.name || ' and ' || comb_status.name || ')';
                            entry_order := region.sort_order * 20 + (select sort_order from temp_comb_status_order where name = '(' || status.name || ' and ' || comb_status.name || ')');
                            insert into dist_entry (region_id, display, sort_order)
                            values (region.id, display_str, entry_order) returning id into entry_id;
                            insert into dist_entry_dist_status (dist_entry_status_id, dist_status_id)
                            values (entry_id, status.id);
                            insert into dist_entry_dist_status (dist_entry_status_id, dist_status_id)
                            values (entry_id, comb_status.id);
                        end loop;
                end loop;
        end loop;
    return (select count(*) from dist_entry);
end;
$$ LANGUAGE plpgsql;

select make_entries();
drop function make_entries();
drop table temp_comb_status_order;

update dist_entry e set display = (select r.name from dist_region r where r.id = e.region_id) where display ~ '\(native\)';

-- populate-top-level-names.sql
INSERT INTO public.author (id, lock_version, abbrev, created_at, created_by, date_range, duplicate_of_id, full_name,
                           ipni_id,
                           name, namespace_id, notes, source_id, source_id_string, source_system, updated_at,
                           updated_by, valid_record)
VALUES (nextval('nsl_global_seq'), 0, 'Whittaker & Margulis', '2012-02-09 06:21:57.000000', 'ghw', null, null, null,
        null,
        'Whittaker & Margulis',
        (select ns.id
         from namespace ns where ns.name ='APNI'),
        null, 20025, '20025', 'AUTHOR_REFERENCE', '2012-02-09 06:21:57.000000', 'ghw', false);

INSERT INTO public.name (id, lock_version,
                         author_id,
                         base_author_id, created_at, created_by, duplicate_of_id,
                         ex_author_id, ex_base_author_id, full_name,
                         full_name_html,
                         name_element,
                         name_rank_id,
                         name_status_id,
                         name_type_id,
                         namespace_id,
                         orth_var,
                         parent_id,
                         sanctioning_author_id,
                         second_parent_id,
                         simple_name,
                         simple_name_html,
                         source_dup_of_id, source_id, source_id_string, source_system, status_summary,
                         updated_at, updated_by, valid_record, verbatim_rank, sort_name,
                         family_id, name_path, uri, changed_combination, published_year, apni_json)
VALUES (nextval('nsl_global_seq'), 0,
        (select id from author where name = 'Whittaker & Margulis'),
        null, '2012-02-09 06:31:34.000000', 'ghw', null,
        null, null, 'Eukaryota Whittaker & Margulis',
        '<scientific><name data-id=''237393''><element>Eukaryota</element> <authors><author data-id=''6349'' title=''Whittaker &amp; Margulis''>Whittaker & Margulis</author></authors></name></scientific>',
        'Eukaryota',
        (select id from name_rank where name = 'Regio'),
        (select id from name_status where name = 'legitimate'),
        (select id from name_type where name = 'scientific'),
        (select ns.id from namespace ns where ns.name ='APNI'),
        false,
        null,
        null,
        null,
        'Eukaryota',
        '<scientific><name data-id=''237393''><element>Eukaryota</element></name></scientific>',
        null, 303548, '303548', 'PLANT_NAME', null,
        '2014-04-04 08:03:27.000000', 'AMONRO', false, 'domain', 'eukaryota',
        null, 'Eukaryota', 'name/apni/237393', false, null, null);

INSERT INTO public.author (id, lock_version, abbrev, created_at, created_by, date_range, duplicate_of_id, full_name,
                           ipni_id,
                           name, namespace_id, notes, source_id, source_id_string, source_system, updated_at,
                           updated_by, valid_record)
VALUES (nextval('nsl_global_seq'), 0, 'Haeckel', '2003-12-16 13:00:00.000000', 'KIRSTENC', null, null, null, null,
        'Haeckel, Ernst Heinrich Philipp August',
        (select ns.id
         from namespace ns where ns.name ='APNI'),
        null, 17385, '17385', 'AUTHOR_REFERENCE', '2003-12-16 13:00:00.000000', 'KIRSTENC', false);

INSERT INTO public.name (id, lock_version,
                         author_id,
                         base_author_id,
                         created_at, created_by, duplicate_of_id, ex_author_id, ex_base_author_id, full_name,
                         full_name_html,
                         name_element,
                         name_rank_id,
                         name_status_id,
                         name_type_id,
                         namespace_id,
                         orth_var,
                         parent_id,
                         sanctioning_author_id, second_parent_id, simple_name,
                         simple_name_html,
                         source_dup_of_id, source_id, source_id_string, source_system, status_summary,
                         updated_at, updated_by, valid_record, verbatim_rank, sort_name,
                         family_id, name_path, uri, changed_combination, published_year, apni_json)
VALUES (nextval('nsl_global_seq'), 0,
        (select id from author where name = 'Haeckel, Ernst Heinrich Philipp August'),
        null,
        '2012-02-10 05:26:54.000000', 'MCOSGROV', null, null, null, 'Plantae Haeckel',
        '<scientific><name data-id=''54717''><element>Plantae</element> <authors><author data-id=''3882'' title=''Haeckel, Ernst Heinrich Philipp August''>Haeckel</author></authors></name></scientific>',
        'Plantae',
        (select id from name_rank where name = 'Regnum'),
        (select id from name_status where name = 'legitimate'),
        (select id from name_type where name = 'scientific'),
        (select ns.id from namespace ns where ns.name ='APNI'),
        false,
        (select id from name where name_element = 'Eukaryota'),
        null, null, 'Plantae',
        '<scientific><name data-id=''54717''><element>Plantae</element></name></scientific>',
        null, -1, '-1', 'PLANT_NAME', null,
        '2012-02-10 05:26:54.000000', 'MCOSGROV', false, null, 'plantae',
        null, 'Eukaryota/Plantae', 'name/apni/54717', false, null, null);

-- search-views.sql
DROP VIEW IF EXISTS public.name_detail_commons_vw;
CREATE VIEW public.name_detail_commons_vw AS
  SELECT
    instance.cited_by_id,
    ((ity.name :: TEXT || ':' :: TEXT) || name.full_name_html :: TEXT) ||
    CASE
    WHEN ns.nom_illeg OR ns.nom_inval
      THEN ns.name
    ELSE '' :: CHARACTER VARYING
    END :: TEXT          AS entry,
    instance.id,
    instance.cites_id,
    ity.name             AS instance_type_name,
    ity.sort_order       AS instance_type_sort_order,
    name.full_name,
    name.full_name_html,
    ns.name,
    instance.name_id,
    instance.id          AS instance_id,
    instance.cited_by_id AS name_detail_id
  FROM instance
    JOIN name ON instance.name_id = name.id
    JOIN instance_type ity ON ity.id = instance.instance_type_id
    JOIN name_status ns ON ns.id = name.name_status_id
  WHERE ity.name :: TEXT = ANY
        (ARRAY ['common name' :: CHARACTER VARYING :: TEXT, 'vernacular name' :: CHARACTER VARYING :: TEXT]);


DROP VIEW IF EXISTS public.name_detail_synonyms_vw;
CREATE VIEW public.name_detail_synonyms_vw AS
  SELECT
    instance.cited_by_id,
    ((((ity.name) :: TEXT || ':' :: TEXT) || (name.full_name_html) :: TEXT) || (
      CASE
      WHEN (ns.nom_illeg OR ns.nom_inval)
        THEN ns.name
      ELSE '' :: CHARACTER VARYING
      END) :: TEXT)      AS entry,
    instance.id,
    instance.cites_id,
    ity.name             AS instance_type_name,
    ity.sort_order       AS instance_type_sort_order,
    name.full_name,
    name.full_name_html,
    ns.name,
    instance.name_id,
    instance.id          AS instance_id,
    instance.cited_by_id AS name_detail_id
  FROM (((instance
    JOIN NAME ON ((instance.name_id = NAME.id)))
    JOIN instance_type ity ON ((ity.id = instance.instance_type_id)))
    JOIN name_status ns ON ((ns.id = name.name_status_id)));

DROP VIEW IF EXISTS public.name_details_vw;
CREATE VIEW public.name_details_vw AS
  SELECT
    n.id,
    n.full_name,
    n.simple_name,
    s.name            AS status_name,
    r.name            AS rank_name,
    r.visible_in_name AS rank_visible_in_name,
    r.sort_order      AS rank_sort_order,
    t.name            AS type_name,
    t.scientific      AS type_scientific,
    t.cultivar        AS type_cultivar,
    i.id              AS instance_id,
    ref.year          AS reference_year,
    ref.id            AS reference_id,
    ref.citation_html AS reference_citation_html,
    ity.name          AS instance_type_name,
    ity.id            AS instance_type_id,
    ity.primary_instance,
    ity.standalone    AS instance_standalone,
    sty.standalone    AS synonym_standalone,
    sty.name          AS synonym_type_name,
    i.page,
    i.page_qualifier,
    i.cited_by_id,
    i.cites_id,
    CASE ity.primary_instance
    WHEN TRUE
      THEN 'A' :: TEXT
    ELSE 'B' :: TEXT
    END               AS primary_instance_first,
    sname.full_name   AS synonym_full_name,
    author.name       AS author_name,
    n.id              AS name_id,
    n.sort_name,
    ((((ref.citation_html) :: TEXT || ': ' :: TEXT) || (COALESCE(i.page, '' :: CHARACTER VARYING)) :: TEXT) ||
     CASE ity.primary_instance
     WHEN TRUE
       THEN ((' [' :: TEXT || (ity.name) :: TEXT) || ']' :: TEXT)
     ELSE '' :: TEXT
     END)             AS entry
  FROM ((((((((((NAME n
    JOIN name_status s ON ((n.name_status_id = s.id)))
    JOIN name_rank r ON ((n.name_rank_id = r.id)))
    JOIN name_type t ON ((n.name_type_id = t.id)))
    JOIN instance i ON ((n.id = i.name_id)))
    JOIN instance_type ity ON ((i.instance_type_id = ity.id)))
    JOIN reference REF ON ((i.reference_id = REF.id)))
    LEFT JOIN author ON ((REF.author_id = author.id)))
    LEFT JOIN instance syn ON ((syn.cited_by_id = i.id)))
    LEFT JOIN instance_type sty ON ((syn.instance_type_id = sty.id)))
    LEFT JOIN name sname ON ((syn.name_id = sname.id)))
  WHERE (n.duplicate_of_id IS NULL);

CREATE OR REPLACE VIEW instance_resource_vw AS
  SELECT
    site.name                 site_name,
    site.description          site_description,
    site.url                  site_url,
    resource.path             resource_path,
    site.url || resource.path url,
    instance_id
  FROM site
    INNER JOIN resource
      ON site.id = resource.site_id
    INNER JOIN instance_resources
      ON resource.id = instance_resources.resource_id
    INNER JOIN instance
      ON instance_resources.instance_id = instance.id;
-- triggers.sql
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
-- z-grants.sql
-- grant to the web user as required
GRANT SELECT, INSERT, UPDATE, DELETE ON id_mapper TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON author TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON delayed_jobs TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON instance TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON instance_type TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON instance_note TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON instance_note_key TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON language TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON name TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON name_category TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON name_group TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON name_rank TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON name_status TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON name_type TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON namespace TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON ref_author_role TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON ref_type TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON reference TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON notification TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON name_tag TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON name_tag_name TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON comment TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON tree TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON tree_version TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON tree_version_element TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON tree_element TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON dist_entry TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON dist_region TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON dist_status TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON dist_status_dist_status TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON dist_entry_dist_status TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON tree_element_distribution_entries TO web;
GRANT SELECT, INSERT, UPDATE, DELETE ON name_resources TO web;

GRANT SELECT, UPDATE ON nsl_global_seq TO web;
GRANT SELECT, UPDATE ON hibernate_sequence TO web;
GRANT SELECT ON shard_config TO web;

GRANT SELECT ON instance_resource_vw TO web;
GRANT SELECT ON name_detail_synonyms_vw TO web;
GRANT SELECT ON name_details_vw TO web;
GRANT SELECT ON name_detail_commons_vw TO web;
GRANT SELECT ON name_view TO web;
GRANT SELECT ON taxon_view TO web;

GRANT SELECT ON id_mapper TO read_only;
GRANT SELECT ON author TO read_only;
GRANT SELECT ON delayed_jobs TO read_only;
GRANT SELECT ON instance TO read_only;
GRANT SELECT ON instance_type TO read_only;
GRANT SELECT ON instance_note TO read_only;
GRANT SELECT ON instance_note_key TO read_only;
GRANT SELECT ON language TO read_only;
GRANT SELECT ON name TO read_only;
GRANT SELECT ON name_category TO read_only;
GRANT SELECT ON name_group TO read_only;
GRANT SELECT ON name_rank TO read_only;
GRANT SELECT ON name_status TO read_only;
GRANT SELECT ON name_type TO read_only;
GRANT SELECT ON namespace TO read_only;
GRANT SELECT ON ref_author_role TO read_only;
GRANT SELECT ON ref_type TO read_only;
GRANT SELECT ON reference TO read_only;
GRANT SELECT ON notification TO read_only;
GRANT SELECT ON name_tag TO read_only;
GRANT SELECT ON name_tag_name TO read_only;
GRANT SELECT ON comment TO read_only;
GRANT SELECT ON shard_config TO read_only;
GRANT SELECT ON tree TO read_only;
GRANT SELECT ON tree_version TO read_only;
GRANT SELECT ON tree_version_element TO read_only;
GRANT SELECT ON tree_element TO read_only;
GRANT SELECT ON tree_element_distribution_entries TO read_only;
GRANT SELECT ON name_resources TO read_only;

GRANT SELECT ON instance_resource_vw TO read_only;
GRANT SELECT ON name_detail_synonyms_vw TO read_only;
GRANT SELECT ON name_details_vw TO read_only;
GRANT SELECT ON name_detail_commons_vw TO read_only;
