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