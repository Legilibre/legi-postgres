# legi-postgres [![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges)

Containers [docker](<https://fr.wikipedia.org/wiki/Docker_(logiciel)>) pour [legilibre/legi.py](https://github.com/Legilibre/legi.py) :

- télécharges et maintient la [base LEGI](https://www.data.gouv.fr/fr/datasets/legi-codes-lois-et-reglements-consolides/) depuis echanges.dila.gouv.fr (~3Go en tgz)
- crée un fichier SQLite, [normalise, consolide et corrige](https://github.com/Legilibre/legi.py#fonctionnalit%C3%A9s) les sources brutes (~2h sur un MBP pour le premier fichier)
- convertit via [pgloader](http://pgloader.io/) et expose une base PostgreSQL (~7mins sur un MBP)

Le dossier par défaut de stockage est `./tarballs`.

La base LEGI contient le texte intégral consolidé de la législation et de la réglementation nationale soit 73 codes officiels en vigueur consolidés (et les autres 29 abrogés) depuis 1945.

From scratch, le process complet de récupération, consolidation et conversion peut durer jusqu'à 2h. Une fois la base créée, le process de mise à jour quotidien dure environ 10 minutes.

## Usage

```sh
# créer les containers
docker-compose up -d

# télécharger et mettre à jour la base legilibre LEGI
docker-compose run legi.py /usr/bin/update

# créer une base dans le container postgres
docker-compose exec postgres createdb -U user legi

# lancer la conversion sqlite -> postgres
docker-compose run pgloader pgloader -v /scripts/legi.load
```

:bulb: Le script [./start.sh](./start.sh) lance toutes ces commandes pour vous.

### Mise à jour automatique

Ajouter dans un cron sur la machine hôte avec `crontab -e` pour mettre à jour la DB périodiquement :

`0 7 * * * root /home/user/legi-postgres/update.sh`

### Serveur PostgreSQL

L'instance PostgreSQL est exposée sur :

- le port 5444
- compte master : à définir dans `docker-compose.override.yml`
- compte readonly : legi/legi

### Maj des données LEGI depuis le FTP DILA

Le script [./update.sh](./update.sh) lance cette étape automatiquement.

Sinon :

```sh
cd tarballs
wget -m -t0 -nH ftp://echanges.dila.gouv.fr/LEGI
```

https://explainshell.com/explain?cmd=wget+-m+ftp%3A%2F%2Fechanges.dila.gouv.fr%2FLEGI+-t0+-nH
