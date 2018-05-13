#!/bin/bash

set -eu

lisp_install() {
	case "$LISP" in
		ccl)
			ccl_checksum='08e885e8c2bb6e4abd42b8e8e2b60f257c6929eb34b8ec87ca1ecf848fac6d70'
			ccl_version='1.11'

			remote_file "/tmp/ccl-${ccl_version}.tgz" "https://github.com/Clozure/ccl/releases/download/v${ccl_version}/ccl-${ccl_version}-linuxx86.tar.gz" "$ccl_checksum"
			tar --file  "/tmp/ccl-${ccl_version}.tgz" --extract --exclude='.svn' --directory '/tmp'
			sudo mv --no-target-directory '/tmp/ccl'    '/usr/local/src/ccl'
			sudo ln --no-dereference --force --symbolic "/usr/local/src/ccl/scripts/ccl64" '/usr/local/bin/ccl'
			;;

		sbcl)
			sbcl_checksum='eb44d9efb4389f71c05af0327bab7cd18f8bb221fb13a6e458477a9194853958'
			sbcl_version='1.3.18'

			remote_file "/tmp/sbcl-${sbcl_version}.tgz" "http://prdownloads.sourceforge.net/sbcl/sbcl-${sbcl_version}-x86-64-linux-binary.tar.bz2" "$sbcl_checksum"
			tar --file  "/tmp/sbcl-${sbcl_version}.tgz" --extract --directory '/tmp'
			( cd "/tmp/sbcl-${sbcl_version}-x86-64-linux" && sudo ./install.sh )
			;;

		*)
			echo "Unrecognized Lisp: '$LISP'"
			exit 1
			;;
	esac
}

pgdg_repositories() {
	local sourcelist='sources.list.d/pgdg.list'

	sudo tee "/etc/apt/$sourcelist" <<-repositories
		deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main
		deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg-testing main 10
	repositories

	sudo apt-key adv --keyserver 'hkp://ha.pool.sks-keyservers.net' --recv-keys 'ACCC4CF8'
	sudo apt-get -o Dir::Etc::sourcelist="$sourcelist" -o Dir::Etc::sourceparts='-' -o APT::Get::List-Cleanup='0' update
}

postgresql_install() {
	if [ -z "${PGVERSION:-}" ]; then
		PGVERSION="$( psql -d postgres -XAtc "select regexp_replace(current_setting('server_version'), '[.][0-9]+$', '')" )"
	else
		sudo service postgresql stop
		xargs sudo apt-get -y --purge remove <<-packages
			libpq-dev
			libpq5
			postgresql
			postgresql-client-common
			postgresql-common
		packages
		sudo rm -rf /var/lib/postgresql
	fi

	xargs sudo apt-get -y install <<-packages
		postgresql-${PGVERSION}
		postgresql-${PGVERSION}-ip4r
	packages

	sudo tee /etc/postgresql/${PGVERSION}/main/pg_hba.conf > /dev/null <<-config
		local  all  all                trust
		host   all  all  127.0.0.1/32  trust
	config

	sudo service postgresql restart
}

remote_file() {
	local target="$1" origin="$2" sum="$3"
	local check="shasum --algorithm $(( 4 * ${#sum} )) --check"
	local filesum="$sum  $target"

	curl --location --output "$target" "$origin" && $check <<< "$filesum"
}

$1
