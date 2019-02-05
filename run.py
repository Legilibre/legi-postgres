from argparse import ArgumentParser
import os

def main():
    p = ArgumentParser()
    p.add_argument(
        '--base',
        default="LEGI",
        choices=["LEGI", "KALI"],
        help="the database published by the DILA that you want to import"
    )
    args = p.parse_args()

    print("> Creating and starting containers as daemons ...")
    os.system("docker-compose up -d")
    print("> done creating and starting containers !\n")

    print("> downloading new dump files for the '%s' db ..." % args.base)
    os.system(
      "docker-compose run --rm legi.py python -m legi.download /tarballs --base %s" %
      (args.base)
    )
    print("> done downloading !\n")

    sqlite_path = "/tarballs/%s.sqlite" % args.base
    print("> importing the dumps into %s ..." % sqlite_path)
    os.system(
      "docker-compose run --rm legi.py python -m legi.tar2sqlite %s /tarballs --base %s %s" %
      (sqlite_path, args.base, "--raw" if args.base != "LEGI" else "")
    )
    print("> done importing the dumps into %s !\n" % sqlite_path)

    postgres_db_name = args.base.lower()
    print("> creating the Postgres DB '%s' if necessary ..." % postgres_db_name)
    os.system("docker-compose exec postgres createdb -U user %s" % postgres_db_name)
    print("> done creating !\n")

    print("> loading into the Postgres DB '%s' from %s" % (postgres_db_name, sqlite_path))
    os.system("docker-compose run --rm pgloader pgloader -v /scripts/%s.load" % args.base.lower())
    print("> done loading into the Postgres DB '%s' from %s !\n" % (postgres_db_name, sqlite_path))

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
