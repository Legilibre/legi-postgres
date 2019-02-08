# legi-postgres [![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges)

Containers [docker](<https://fr.wikipedia.org/wiki/Docker_(logiciel)>) pour [legilibre/legi.py](https://github.com/Legilibre/legi.py) :

- télécharge incrémentalement la [base LEGI](https://www.data.gouv.fr/fr/datasets/legi-codes-lois-et-reglements-consolides/) depuis echanges.dila.gouv.fr (~3Go en tgz)
- crée un fichier SQLite, [normalise, consolide et corrige](https://github.com/Legilibre/legi.py#fonctionnalit%C3%A9s) les sources brutes (~2h sur un MBP pour le premier fichier)
- convertit via [pgloader](http://pgloader.io/) et expose une base PostgreSQL (~7mins sur un MBP)

Le dossier par défaut de stockage est `./tarballs`.

La base LEGI contient le texte intégral consolidé de la législation et de la réglementation nationale soit 73 codes officiels en vigueur consolidés (et les autres 29 abrogés) depuis 1945.

From scratch, le process complet de récupération, consolidation et conversion peut durer jusqu'à 2h. Une fois la base créée, le process de mise à jour quotidien dure environ 10 minutes.

## Usage

Un script Python permet de lancer toutes ces commandes à la suite : `python start.py`.

Le script `run.py` propose plusieurs options :

- `--base` permet de choisir pour quelle base exécuter les opérations, KALI ou LEGI
- `--skip-download` permet de sauter la partie téléchargement des dumps depuis le FTP. Utile si vous les avez déjà téléchargés.
- `--force-recreate` supprime la base Postgres si elle existe déjà, ainsi que la base SQLite intermédiaire

Voici une liste non exhaustive d'opérations individuelles que vous pouvez exécuter manuellement :

Lancer (après avoir créé si nécessaire) les containers en background :

```sh
docker-compose up -d
```

Télécharger les nouveaux fichiers de dump depuis le FTP de la DILA

```sh
docker-compose run --rm legi.py python -m legi.download /tarballs --base LEGI
```

Importer les dumps dans la base SQLite :

```sh
docker-compose run --rm legi.py python -m legi.tar2sqlite /tarballs/LEGI.sqlite /tarballs --base LEGI
```

Créer la base Postgres :

```sh
docker-compose exec postgres createdb -U user legi
```

Lancer l'import depuis SQLite vers Postgres

```sh
docker-compose run --rm pgloader pgloader -v /scripts/legi.load
```

### Développement local

Pour simplifier le développement, vous pouvez rajouter ce volume au container `legi.py` dans le fichier `docker-compose.yml` :

```
- ../legi.py:/usr/src/app/legi.py
```

Cela vous permettra d'itérer sur le code de [legi.py](https://github.com/Legilibre/legi.py/) et que les changements soient pris en compte tout de suite dans votre container.

### Mise à jour automatique

Ajouter dans un cron sur la machine hôte avec `crontab -e` pour mettre à jour la DB périodiquement :

`0 7 * * * root /usr/bin/python /home/user/legi-postgres/run.py`

### Serveur PostgreSQL

L'instance PostgreSQL est exposée sur :

- le port 5444
- compte master : à définir dans `docker-compose.override.yml`
- compte readonly : legi/legi

### Télécharger les dumps manuellement depuis le FTP

Il arrive fréquemment que le script n'arrive pas à télécharger les fichiers depuis le FTP de la DILA.
Si vous souhaitez les télécharger manuellement en avance, vous pouvez exécuter ces commandes :

```sh
cd tarballs
wget -m -t0 -nH -nd ftp://echanges.dila.gouv.fr/LEGI
```

https://explainshell.com/explain?cmd=wget+-m+ftp%3A%2F%2Fechanges.dila.gouv.fr%2FLEGI+-t0+-nH
