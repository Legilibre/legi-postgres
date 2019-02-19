from argparse import ArgumentParser
import os
DIRPATH = os.path.dirname(__file__)


def main():
    p = ArgumentParser()
    p.add_argument(
        '--base',
        default="LEGI",
        choices=["LEGI", "KALI"],
        help="the database published by the DILA that you want to import"
    )
    p.add_argument(
        '--skip-download',
        action='store_true',
        help="will not try to download the dumps from DILA's FTP"
    )
    p.add_argument(
        '--force-recreate',
        action='store_true',
        help='drops the existing SQLite and Postgres databases, if any'
    )
    args = p.parse_args()

    print("> Creating and starting containers as daemons ...")
    os.system("docker-compose up -d")
    print("> done creating and starting containers !\n")

    if not args.skip_download:
        print("> downloading new dump files for the '%s' db ..." % args.base)
        os.system(
        "docker-compose run --rm legi.py python -m legi.download /tarballs --base %s" %
        (args.base)
        )
        print("> done downloading !\n")

    postgres_db_name = args.base.lower()

    if args.force_recreate:
        host_sqlite_path = 'tarballs/%s.sqlite' % os.path.join(DIRPATH, args.base)
        print("> dropping %s ..." % host_sqlite_path)
        os.system("rm %s" % host_sqlite_path)
        print("> dropping the existing %s Postgres db ..." % postgres_db_name)
        # this seems to fail if you up -d before, maybe we'd rather start it individually
        os.system("docker-compose exec postgres dropdb -U user %s" % postgres_db_name)

    container_sqlite_path = "/tarballs/%s.sqlite" % args.base
    print("> importing the dumps into %s ..." % container_sqlite_path)
    os.system(
      "docker-compose run --rm legi.py python -m legi.tar2sqlite %s /tarballs --base %s %s" %
      (container_sqlite_path, args.base, "--raw" if args.base != "LEGI" else "")
    )
    print("> done importing the dumps into %s !\n" % container_sqlite_path)

    print("> creating the Postgres DB '%s' if necessary ..." % postgres_db_name)
    os.system("docker-compose exec postgres createdb -U user %s" % postgres_db_name)
    print("> done creating !\n")

    print("> loading into the Postgres DB '%s' from %s" % (postgres_db_name, container_sqlite_path))
    os.system("docker-compose run --rm pgloader pgloader -v /scripts/%s.load" % args.base.lower())
    print("> done loading into the Postgres DB '%s' from %s !\n" % (postgres_db_name, container_sqlite_path))

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
