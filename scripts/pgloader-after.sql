CREATE INDEX textes_versions_cid_idx ON "public".textes_versions (cid) ;
CREATE INDEX textes_versions_date_debut_idx ON "public".textes_versions (date_debut) ;
CREATE INDEX textes_versions_date_fin_idx ON "public".textes_versions (date_fin) ;

CREATE INDEX sommaires_debut_idx ON "public".sommaires (debut) ;
CREATE INDEX sommaires_fin_idx ON "public".sommaires (fin) ;

CREATE INDEX articles_id_idx ON "public".articles (id) ;
CREATE INDEX articles_cid_idx ON "public".articles (cid) ;
CREATE INDEX articles_date_debut_idx ON "public".articles (date_debut) ;
CREATE INDEX articles_date_fin_idx ON "public".articles (date_fin) ;
