# legi.py docker

Container [docker](https://fr.wikipedia.org/wiki/Docker_(logiciel)) pour [legi.py](https://github.com/Legilibre/legi.py) :

 - télécharges la base LEGI depuis journal-officiel.gouv.fr (>1.7Go en tgz)
 - crée un SQLite, [normalise, consolide et corrige](https://github.com/Legilibre/legi.py#fonctionnalit%C3%A9s) les sources brutes (~2h sur un MBP pour le premier fichier)

Vous devez monter un dossier local vers `/tarballs`; Il sera rempli avec les archives LEGI et la base SQLlite.

## Usage

```sh
# Build the container
docker build .

# Run a daemon container with ./tarballs mounted to /tarballs
docker run -t -d --rm --name legilibre -v $PWD/tarballs:/tarballs CONTAINER_ID

# download and update the sqlite database
docker exec -it legilibre update
```



