# legi-docker [![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges)

Containers [docker](https://fr.wikipedia.org/wiki/Docker_(logiciel)) pour [legilibre/legi.py](https://github.com/Legilibre/legi.py) :

 - télécharges et maintient la base LEGI depuis journal-officiel.gouv.fr (~2Go en tgz)
 - crée un fichier SQLite, [normalise, consolide et corrige](https://github.com/Legilibre/legi.py#fonctionnalit%C3%A9s) les sources brutes (~2h sur un MBP pour le premier fichier)
 - convertit et expose une base PostgreSQL via [pgloader](http://pgloader.io/) (~7mins sur un MBP)

Le dossier par défaut de stockage est `./tarballs`.

## Usage

```sh
# créer les containers
docker-compose up -d

# télécharger et mettre à jour la base legilibre LEGI
docker-compose exec legi.py /usr/bin/update

# créer une base dans le container postgres
docker-compose exec postgres createdb -U user legi

# lancer la conversion sqlite -> postgres
docker-compose run pgloader pgloader -v /scripts/legi.load
```

:bulb: Le script [./start.sh](./start.sh) lance toutes ces commandes pour vous

### Mise à jour automatique

Ajouter dans un cron sur la machine hôte pour mettre à jour la DB périodiquement :

`0 7 * * * root /home/use/legi-docker/update.sh`


### Serveur PostgreSQL

L'instance PostgreSQL est exposée sur :

 - le port 5444
 - compte master : à définir dans `docker-compose.override.yml`
 - compte readonly : legi/legi


