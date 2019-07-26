INSERT INTO public.author (id, lock_version, abbrev, created_at, created_by, date_range, duplicate_of_id, full_name, ipni_id,
                           name, namespace_id, notes, source_id, source_id_string, source_system, trash, updated_at, updated_by, valid_record)
VALUES
  (nextval('nsl_global_seq'), 0, 'Whittaker & Margulis', '2012-02-09 06:21:57.000000', 'ghw', null, null, null, null,
                              'Whittaker & Margulis',
                              (select ns.id
                               from namespace ns
                                 join shard_config sc on ns.name = sc.value
                               where sc.name =
                                     'name space'),
   null, 20025, '20025', 'AUTHOR_REFERENCE', false, '2012-02-09 06:21:57.000000', 'ghw', false);

INSERT INTO public.name (id, lock_version, author_id, base_author_id, created_at, created_by, duplicate_of_id, ex_author_id, ex_base_author_id,
                         full_name, full_name_html, name_element, name_rank_id, name_status_id, name_type_id, namespace_id,
                         orth_var, parent_id, sanctioning_author_id, second_parent_id, simple_name, simple_name_html, source_dup_of_id,
                         source_id, source_id_string, source_system, status_summary, trash, updated_at, updated_by, valid_record,
                         why_is_this_here_id, verbatim_rank, sort_name, family_id, name_path)
VALUES (nextval('nsl_global_seq'),
  0,
  (select id
   from author
   where name = 'Whittaker & Margulis'),
  null, '2012-02-09 06:31:34.000000', 'ghw', null, null, null, 'Eukaryota Whittaker & Margulis',
  '<scientific><name data-id=''237393''><element>Eukaryota</element> <authors><author data-id=''6349'' title=''Whittaker &amp; Margulis''>Whittaker & Margulis</author></authors></name></scientific>',
  'Eukaryota',
  (select id
   from name_rank
   where name = 'Regio'),
  (select id
   from name_status
   where name = 'legitimate'),
  (select id
   from name_type
   where name = 'scientific'),
  (select ns.id
   from namespace ns
     join shard_config sc on ns.name = sc.value
   where sc.name = 'name space'),
  false, null, null, null, 'Eukaryota',
  '<scientific><name data-id=''237393''><element>Eukaryota</element></name></scientific>',
  null, 303548, '303548', 'PLANT_NAME', null, false, '2014-04-04 08:03:27.000000', 'AMONRO', false,
        null, 'domain', 'eukaryota', null, 'Eukaryota'
);

INSERT INTO public.author (id, lock_version, abbrev, created_at, created_by, date_range, duplicate_of_id, full_name, ipni_id,
                           name, namespace_id, notes, source_id, source_id_string, source_system, trash, updated_at, updated_by, valid_record)
VALUES (nextval('nsl_global_seq'), 0, 'Haeckel', '2003-12-16 13:00:00.000000', 'KIRSTENC', null, null, null, null,
                                   'Haeckel, Ernst Heinrich Philipp August',
                                   (select ns.id
                                    from namespace ns
                                      join shard_config sc
                                        on ns.name = sc.value
                                    where sc.name =
                                          'name space'),
        null, 17385, '17385', 'AUTHOR_REFERENCE', false, '2003-12-16 13:00:00.000000', 'KIRSTENC', false);

INSERT INTO public.name (id, lock_version, author_id, base_author_id, created_at, created_by, duplicate_of_id, ex_author_id,
                         ex_base_author_id, full_name, full_name_html, name_element, name_rank_id, name_status_id, name_type_id,
                         namespace_id, orth_var, parent_id, sanctioning_author_id, second_parent_id, simple_name, simple_name_html,
                         source_dup_of_id, source_id, source_id_string, source_system, status_summary, trash, updated_at,
                         updated_by, valid_record, why_is_this_here_id, verbatim_rank, sort_name, family_id, name_path)
VALUES (nextval('nsl_global_seq'), 6,
                                   (select id
                                    from author
                                    where name = 'Haeckel, Ernst Heinrich Philipp August'),
                                   null, '2012-02-10 05:26:54.000000', 'MCOSGROV', null, null, null, 'Plantae Haeckel',
                                   '<scientific><name data-id=''54717''><element>Plantae</element> <authors><author data-id=''3882'' title=''Haeckel, Ernst Heinrich Philipp August''>Haeckel</author></authors></name></scientific>',
  'Plantae',
  (select id
   from name_rank
   where name = 'Regnum'),
  (select id
   from name_status
   where name = 'legitimate'),
  (select id
   from name_type
   where name = 'scientific'),
  (select ns.id
   from namespace ns
     join shard_config sc on ns.name = sc.value
   where sc.name = 'name space'),
  false,
  (select id
   from name
   where name_element = 'Eukaryota'),
  null, null, 'Plantae',
  '<scientific><name data-id=''54717''><element>Plantae</element></name></scientific>', null, -1, '-1', 'PLANT_NAME',
  null, false, '2012-02-10 05:26:54.000000', 'MCOSGROV', false, null, null, 'plantae', null, 'Eukaryota/Plantae');

