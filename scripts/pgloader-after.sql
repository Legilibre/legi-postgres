DO $$
BEGIN
    CREATE INDEX textes_versions_cid_idx ON "public".textes_versions (cid);
    CREATE INDEX textes_versions_date_debut_idx ON "public".textes_versions (date_debut);
    CREATE INDEX textes_versions_date_fin_idx ON "public".textes_versions (date_fin);
    CREATE INDEX sommaires_debut_idx ON "public".sommaires (debut);
    CREATE INDEX sommaires_fin_idx ON "public".sommaires (fin);
    CREATE INDEX sommaires_parent_idx ON "public".sommaires (parent);
    CREATE INDEX sommaires_etat_idx ON "public".sommaires (etat);
    CREATE INDEX sommaires_element_idx ON "public".sommaires ("element");
    CREATE INDEX articles_id_idx ON "public".articles (id);
    CREATE INDEX articles_cid_idx ON "public".articles (cid);
    CREATE INDEX articles_date_debut_idx ON "public".articles (date_debut);
    CREATE INDEX articles_date_fin_idx ON "public".articles (date_fin);
    CREATE INDEX articles_section_idx ON "public".articles (section);
    CREATE INDEX articles_num_idx ON "public".articles (num);
    CREATE INDEX liens_src_id_idx ON "public".liens (src_id);

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'readaccess') THEN
      CREATE ROLE readaccess;
      GRANT USAGE ON SCHEMA public TO readaccess;
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO readaccess;
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readaccess;
      CREATE USER legi WITH PASSWORD 'legi';
      GRANT readaccess TO legi;
    END IF;
END
$$;

COMMIT;