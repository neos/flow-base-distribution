#!/bin/bash

echo "If you have read the README and are sure you need this script, remove the next line!";
exit 0;


realpath() {
	local p=$1
	if [ "$(echo $p | sed -e 's/^\(.\).*$/\1/')" != "/" ]; then
		p="$(pwd -P)/$p"
	fi
	echo $p | sed -e 's#/[^/]\+/\.\.##g' -e 's#\./##g';
}

show_option() {
	local varname=$1
	local vardesc=$2
	if [ "$(eval echo \$$varname)" != "" ]; then
		echo "$vardesc: $(eval echo \$$varname)"
	else
		echo "$vardesc ($varname) not set"
	fi
}

show_existing_config() {
	echo "Config for host $CONFIG_HOSTNAME"
	echo

	show_option CONFIG_WEBSERVER_USER "Webserver user"
	show_option CONFIG_WEBSERVER_GROUP "Webserver group"
	show_option CONFIG_WEB_TYPO3_PUBLIC "URL for FLOW3 Public directory"

	echo
	echo "Production database:"
	show_option CONFIG_PRODUCTION_DB_TYPE "Production database type"

	if [ "$CONFIG_PRODUCTION_DB_TYPE" = "sqlite" ]; then
		show_option CONFIG_PRODUCTION_DB_PATH "Sqlite database path"
	else
		show_option CONFIG_PRODUCTION_DB_NAME "Production database name"
		show_option CONFIG_PRODUCTION_DB_USER "Production database user"
		show_option CONFIG_PRODUCTION_DB_PASS "Production database password"
	fi

	show_option CONFIG_LUCENE_INDEX_LOCATION "Lucene index location"

	echo
	echo "Test databases:"
	echo
	if [ "$CONFIG_TEST_DB_TYPES" != "" ]; then
		for dbtype in $CONFIG_TEST_DB_TYPES
		do
		case $dbtype in
			"mysql")
			echo "MySQL test db:";
			show_option CONFIG_TEST_MYSQL_DB_NAME "MySQL test database name"
			show_option CONFIG_TEST_MYSQL_DB_USER "MySQL test database user"
			show_option CONFIG_TEST_MYSQL_DB_PASS "MySQL test database password";;
			"postgres")
			echo "PostgreSQL test db:";
			show_option CONFIG_TEST_POSTGRES_DB_NAME "PostgreSQL test database name"
			show_option CONFIG_TEST_POSTGRES_DB_USER "PostgreSQL test database user"
			show_option CONFIG_TEST_POSTGRES_DB_PASS "PostgreSQL test database password";;
		esac
		done
	else
		echo "Only sqlite test db configured (sqlite needs no configuration for tests)"
	fi

	echo

	show_option CONFIG_BIN_SQLITE3 "sqlite3 binary"
	show_option CONFIG_BIN_MYSQL "mysql binary"
	show_option CONFIG_BIN_MYSQLDUMP "mysqldump binary"
	show_option CONFIG_BIN_PSQL "psql binary"
	show_option CONFIG_BIN_PG_DUMP "pg_dump binary"
}

reconfigure_text_option() {
	local varname=$1
	local prompt=$2
	local default=$3
	if [ -z "$(eval echo \$$varname)" -a ! -z "$default" ]; then
		eval $varname=\$default
	fi
	local inputvalue=""
	echo -n "$prompt [$(eval echo \$$varname)]: "
	read inputvalue
	while [ "$inputvalue" = "" -a "$(eval echo \$$varname)" = "" ]
	do
		echo -n "$prompt [$(eval echo \$$varname)]: "
		read inputvalue
	done
	if [ "$inputvalue" != "" ]; then
		eval $varname=\$inputvalue
	fi
}

reconfigure_binary_file_option() {
	local varname=$1
	local binname=$2
	local prompt="$binname binary"
	local default=$(which $binname 2>/dev/null)
	if [ ! -x "$(eval echo \$$varname)" -a -x "$default" ]; then
		eval $varname=\$default
	fi
	local inputvalue=""
	echo -n "$prompt [$(eval echo \$$varname)]: "
	read inputvalue
	while [ ! -x "$inputvalue" -a ! -x "$(eval echo \$$varname)" ]
	do
		echo -n "$prompt [$(eval echo \$$varname)]: "
		read inputvalue
		echo
		if [ ! -z "$inputvalue" ]; then
			if [ ! -e "$inputvalue" ]; then
			echo "$inputvalue does not exist"
			else
			if [ ! -x "$inputvalue" ]; then
				echo "$inputvalue is not executable"
			fi
			fi
		fi
	done
	if [ "$inputvalue" != "" ]; then
		eval $varname=\$inputvalue
	fi
}

reconfigure_multiple_choice_option() {
	local varname=$1
	local prompt=$2
	local havedefault="no"
	shift 2
	while true
	do
		echo "$prompt:"
		i=1
		for opt in "$@"
		do
			local optvalue=$(echo $opt | awk '{print $1}')
			local optdesc=$(echo $opt | awk '{print $2}')
			if [ "$(eval echo \$$varname)" = "$optvalue" ]; then
				echo "$i $optdesc (*)"
				local havedefault="yes"
			else
				echo "$i $optdesc"
			fi
			(( i=i+1 ))
		done
		read -n 1 -s choice
		echo Chose $choice
		if [ "$havedefault" = "yes" -a "$choice" == "" ]; then
			break
		fi
		i=1
		for opt in "$@"
		do
			if [ "$i" = "$choice" ]; then
				local optvalue=$(echo $opt | awk '{print $1}')
				eval $varname=\$optvalue
				break 2
			fi
			(( i=i+1 ))
		done
		echo "Invalid choice"
	done
}

reconfigure_option_flag () {
	local varname=$1
	local flagname=$2
	local prompt=$3
	local default
	if eval echo \$$varname | grep "\b$flagname\b" > /dev/null; then
		default="y"
	else
		default="n"
	fi
	local inputvalue="a"
	while [ "$inputvalue" != "y" -a "$inputvalue" != "" -a "$inputvalue" != "n" ]
	do
		if [ "$default" = "y" ]; then
			echo -n "$prompt [Y/n]: "
		else
			echo -n "$prompt [y/N]: "
		fi
		read -n 1 inputvalue
		echo
	done
	if [ "$inputvalue" = "" ]; then
		inputvalue=$default
	fi
	local newvalue="$(eval echo \$$varname | sed -e "s/$flagname//g")"
	if [ "$inputvalue" = "y" ]; then
		newvalue="$newvalue $flagname"
	fi
	eval $varname=\$newvalue
}

reconfigure() {
	echo "Reconfiguring (just press return to accept default in [])"
	echo

	if [ "$(uname)" = "Darwin" ]; then
		reconfigure_text_option CONFIG_WEBSERVER_USER "Name of your webserver user" "_www"
		reconfigure_text_option CONFIG_WEBSERVER_GROUP "Name of your webserver group" "_www"
	else
		reconfigure_text_option CONFIG_WEBSERVER_USER "Name of your webserver user" "apache"
		reconfigure_text_option CONFIG_WEBSERVER_GROUP "Name of your webserver group" "apache"
	fi
	reconfigure_text_option CONFIG_WEB_TYPO3_PUBLIC "URL to the FLOW3 Public directory"

	reconfigure_multiple_choice_option CONFIG_PRODUCTION_DB_TYPE "Production database type" "sqlite sqlite" "postgres PostgreSQL" "mysql MySQL"

	if [ "$CONFIG_PRODUCTION_DB_TYPE" = "sqlite" ]; then
		reconfigure_text_option CONFIG_PRODUCTION_DB_PATH "Path for your sqlite database" "$T3BASEDIR/Data/Persistent/TYPO3CR.db"
		if [ "$CONFIG_PRODUCTION_DB_PATH" != "" ]; then
			if [ ! -e "$(dirname $CONFIG_PRODUCTION_DB_PATH)" ]; then
				wantcreate="a"
				while [ "$wantcreate" != "y" -a "$wantcreate" != "" -a "$wantcreate" != "n" ]
				do
					echo -n "Path $CONFIG_PRODUCTION_DB_PATH does not exist, do you want to create it [Y/n] "
					read -n 1 wantcreate
					echo
				done
				if [ "$wantcreate" != "n" ]; then
					mkdir -p $CONFIG_PRODUCTION_DB_PATH
					CONFIG_PRODUCTION_DB_PATH=$(realpath $CONFIG_PRODUCTION_DB_PATH)
				else
					echo "Using path $CONFIG_PRODUCTION_DB_PATH as it is, please create it yourself, this fact prevents path canonization so this path might be relative to the current directory"
				fi
			else
				CONFIG_PRODUCTION_DB_PATH="$(realpath $(dirname $CONFIG_PRODUCTION_DB_PATH))/$(basename $CONFIG_PRODUCTION_DB_PATH)"
			fi
		fi
	else
		reconfigure_text_option CONFIG_PRODUCTION_DB_NAME "Production database name"
		reconfigure_text_option CONFIG_PRODUCTION_DB_USER "Production database user"
		reconfigure_text_option CONFIG_PRODUCTION_DB_PASS "Production database password"
	fi

	reconfigure_text_option CONFIG_LUCENE_INDEX_LOCATION "Path for your lucene index" "$(realpath $T3BASEDIR/Data/Persistent/Index/)"

	reconfigure_option_flag CONFIG_TEST_DB_TYPES postgres "Use PostgreSQL test database for unit tests"
	if echo $CONFIG_TEST_DB_TYPES | grep "\bpostgres\b" > /dev/null; then
		reconfigure_text_option CONFIG_TEST_POSTGRES_DB_NAME "PostgreSQL test database name"
		reconfigure_text_option CONFIG_TEST_POSTGRES_DB_USER "PostgreSQL test database user"
		reconfigure_text_option CONFIG_TEST_POSTGRES_DB_PASS "PostgreSQL test database password"
	fi
	reconfigure_option_flag CONFIG_TEST_DB_TYPES mysql "Use MySQL test database for unit tests"
	if echo $CONFIG_TEST_DB_TYPES | grep "\bmysql\b" > /dev/null; then
		reconfigure_text_option CONFIG_TEST_MYSQL_DB_NAME "MySQL test database name"
		reconfigure_text_option CONFIG_TEST_MYSQL_DB_USER "MySQL test database user"
		reconfigure_text_option CONFIG_TEST_MYSQL_DB_PASS "MySQL test database password"
	fi

	reconfigure_binary_file_option CONFIG_BIN_SQLITE3 "sqlite3"

	if echo $CONFIG_TEST_DB_TYPES | grep "\bpostgres\b" > /dev/null || [ "$CONFIG_PRODUCTION_DB_TYPE" = "postgres" ]; then
		reconfigure_binary_file_option CONFIG_BIN_PSQL "psql"
		reconfigure_binary_file_option CONFIG_BIN_PG_DUMP "pg_dump"
	fi

	if echo $CONFIG_TEST_DB_TYPES | grep "\bmysql\b" > /dev/null || [ "$CONFIG_PRODUCTION_DB_TYPE" = "mysql" ]; then
		reconfigure_binary_file_option CONFIG_BIN_MYSQL "mysql"
		reconfigure_binary_file_option CONFIG_BIN_MYSQLDUMP "mysqldump"
	fi

	CONFIG_HOSTNAME=$(hostname)

	write_config
}

check_current_config() {
	echo "Checking current config"

	local failed="no"

	test -z "$CONFIG_WEBSERVER_USER" && echo "Webserver user not set " && failed="yes"
	test -z "$CONFIG_WEBSERVER_GROUP" && echo "Webserver group not set " && failed="yes"

	test -z "$CONFIG_WEB_TYPO3_PUBLIC" && echo "URL to FLOW3 Public directory not set " && fialed="yes"

	test -z "$CONFIG_PRODUCTION_DB_TYPE" && echo "Production database type not set " && failed="yes"
	if [ "$CONFIG_PRODUCTION_DB_TYPE" = "sqlite" ]; then
		test -z "$CONFIG_PRODUCTION_DB_PATH" && echo "Production database path not set " && failed="yes"
	else
		test -z "$CONFIG_PRODUCTION_DB_NAME" && echo "Production database name not set " && failed="yes"
		test -z "$CONFIG_PRODUCTION_DB_USER" && echo "Production database username not set " && failed="yes"
		test -z "$CONFIG_PRODUCTION_DB_PASS" && echo "Production database password not set " && failed="yes"
	fi

	test -z "$CONFIG_LUCENE_INDEX_LOCATION" && echo "Lucene index location not set " && failed="yes"

	for testdbtype in $(echo $CONFIG_TEST_DB_TYPES)
	do
		case $testdbtype in
		"postgres")
			test -z "$CONFIG_TEST_POSTGRES_DB_NAME" && echo "PostgreSQL test database name not set " && failed="yes"
			test -z "$CONFIG_TEST_POSTGRES_DB_USER" && echo "PostgreSQL test database username not set " && failed="yes"
			test -z "$CONFIG_TEST_POSTGRES_DB_PASS" && echo "PostgreSQL test database password not set " && failed="yes";;
		"mysql")
			test -z "$CONFIG_TEST_MYSQL_DB_NAME" && echo "MySQL test database name not set " && failed="yes"
			test -z "$CONFIG_TEST_MYSQL_DB_USER" && echo "MySQL test database username not set " && failed="yes"
			test -z "$CONFIG_TEST_MYSQL_DB_PASS" && echo "MySQL test database password not set " && failed="yes";;
		  *)
			echo "Unknown test database type $testdbtype "
			failed="yes";;
		esac
	done

	test -z "$CONFIG_BIN_SQLITE3" && echo "sqlite3 binary not set" && failed="yes"
	test ! -e "$CONFIG_BIN_SQLITE3" && echo "Specified sqlite3 binary does not exist" && failed="yes"
	test ! -x "$CONFIG_BIN_SQLITE3" && echo "Specified sqlite3 binary is not executable" && failed="yes"

	if echo $CONFIG_TEST_DB_TYPES | grep "\bpostgres\b" > /dev/null || [ "$CONFIG_PRODUCTION_DB_TYPE" = "postgres" ]; then
		test -z "$CONFIG_BIN_PSQL" && echo "psql binary not set" && failed="yes"
		test ! -e "$CONFIG_BIN_PSQL" && echo "Specified psql binary does not exist" && failed="yes"
		test ! -x "$CONFIG_BIN_PSQL" && echo "Specified psql binary is not executable" && failed="yes"

		test -z "$CONFIG_BIN_PG_DUMP" && echo "pg_dump binary not set" && failed="yes"
		test ! -e "$CONFIG_BIN_PG_DUMP" && echo "Specified pg_dump binary does not exist" && failed="yes"
		test ! -x "$CONFIG_BIN_PG_DUMP" && echo "Specified pg_dump binary is not executable" && failed="yes"
	fi

	if echo $CONFIG_TEST_DB_TYPES | grep "\bmysql\b" > /dev/null || [ "$CONFIG_PRODUCTION_DB_TYPE" = "mysql" ]; then
		test -z "$CONFIG_BIN_MYSQL" && echo "mysql binary not set" && failed="yes"
		test ! -e "$CONFIG_BIN_MYSQL" && echo "Specified mysql binary does not exist" && failed="yes"
		test ! -x "$CONFIG_BIN_MYSQL" && echo "Specified mysql binary is not executable" && failed="yes"

		test -z "$CONFIG_BIN_MYSQLDUMP" && echo "mysqldump binary not set" && failed="yes"
		test ! -e "$CONFIG_BIN_MYSQLDUMP" && echo "Specified mysqldump binary does not exist" && failed="yes"
		test ! -x "$CONFIG_BIN_MYSQLDUMP" && echo "Specified mysqldump binary is not executable" && failed="yes"
	fi

	if [ "$failed" = "yes" ]; then
		return 1
	else
		return 0
	fi
}

use_existing_config() {
	echo "Using existing config"
	setup_typo3
}

write_config() {
	echo "Writing config to $T3INSTALLCONF"
	echo > $T3INSTALLCONF
	(cat <<EOF
CONFIG_HOSTNAME="$CONFIG_HOSTNAME"

CONFIG_BIN_SQLITE3="$CONFIG_BIN_SQLITE3"
CONFIG_BIN_MYSQL="$CONFIG_BIN_MYSQL"
CONFIG_BIN_MYSQLDUMP="$CONFIG_BIN_MYSQLDUMP"
CONFIG_BIN_PSQL="$CONFIG_BIN_PSQL"
CONFIG_BIN_PG_DUMP="$CONFIG_BIN_PG_DUMP"

CONFIG_WEBSERVER_USER="$CONFIG_WEBSERVER_USER"
CONFIG_WEBSERVER_GROUP="$CONFIG_WEBSERVER_GROUP"
CONFIG_WEB_TYPO3_PUBLIC="$CONFIG_WEB_TYPO3_PUBLIC"

CONFIG_PRODUCTION_DB_TYPE="$CONFIG_PRODUCTION_DB_TYPE"
CONFIG_PRODUCTION_DB_PATH="$CONFIG_PRODUCTION_DB_PATH"
CONFIG_PRODUCTION_DB_NAME="$CONFIG_PRODUCTION_DB_NAME"
CONFIG_PRODUCTION_DB_USER="$CONFIG_PRODUCTION_DB_USER"
CONFIG_PRODUCTION_DB_PASS="$CONFIG_PRODUCTION_DB_PASS"

CONFIG_LUCENE_INDEX_LOCATION="$CONFIG_LUCENE_INDEX_LOCATION"

CONFIG_TEST_DB_TYPES="$CONFIG_TEST_DB_TYPES"

CONFIG_TEST_POSTGRES_DB_NAME="$CONFIG_TEST_POSTGRES_DB_NAME"
CONFIG_TEST_POSTGRES_DB_USER="$CONFIG_TEST_POSTGRES_DB_USER"
CONFIG_TEST_POSTGRES_DB_PASS="$CONFIG_TEST_POSTGRES_DB_PASS"

CONFIG_TEST_MYSQL_DB_NAME="$CONFIG_TEST_MYSQL_DB_NAME"
CONFIG_TEST_MYSQL_DB_USER="$CONFIG_TEST_MYSQL_DB_USER"
CONFIG_TEST_MYSQL_DB_PASS="$CONFIG_TEST_MYSQL_DB_PASS"

EOF
	) > $T3INSTALLCONF
	HAVE_CONFIG="yes"
}

disable_persistence() {
	echo "Disabling persistence layer to setup database..."
	sed -i -e 's/  enable: yes/  enable: no/' Configuration/FLOW3.yaml
}

enable_persistence() {
	echo "Enabling persistence layer..."
	sed -i -e 's/  enable: no/  enable: yes/' Configuration/FLOW3.yaml
}

setup_sqlite_production_db() {
	echo "Setting up sqlite production database.."
	disable_persistence
	if [ ! -d "$(dirname $CONFIG_PRODUCTION_DB_PATH)" ]; then
		echo "Database directory does not exist, creating it..."
		mkdir -p "$(dirname $CONFIG_PRODUCTION_DB_PATH)"
	fi
	if [ -e "$CONFIG_PRODUCTION_DB_PATH" ]; then
		BACKUP_FILE=$(mktemp "$CONFIG_PRODUCTION_DB_PATH".XXXXXXXX)
		echo "Database exists...moving it to backup $BACKUP_FILE"
		mv "$CONFIG_PRODUCTION_DB_PATH" "$BACKUP_FILE"
	fi
	sudo php Public/index.php typo3cr admin setup setup --dsn="sqlite:$CONFIG_PRODUCTION_DB_PATH" --indexlocation="$CONFIG_LUCENE_INDEX_LOCATION"
	echo
	enable_persistence
	echo "Writing Configuration/Settings.yaml..."
	(cat <<EOF
TYPO3CR:
  # The storage backend configuration
  storage:
    backend: 'F3\TYPO3CR\Storage\Backend\PDO'
    backendOptions:
      dataSourceName: 'sqlite:$CONFIG_PRODUCTION_DB_PATH'
      username: 
      password: 

  # The indexing/search backend configuration
  search:
    backend: 'F3\TYPO3CR\Storage\Search\Lucene'
    backendOptions:
      indexLocation: '$CONFIG_LUCENE_INDEX_LOCATION'
EOF
	) >> Configuration/Settings.yaml
}

setup_postgres_production_db() {
	echo "Setting up PostgreSQL production database..."

	pgsqlrootpw=""
	echo -n "Please enter your PostgreSQL postgres user password (no * or anything else is echoed): "
	read -s pgsqlrootpw
	while ! PGPASSWORD="$pgsqlrootpw" $CONFIG_BIN_PSQL -U postgres -c "\dt" > /dev/null
	do
		echo "No working PostgreSQL postgres user password known..."
		echo -n "Please enter your PostgreSQL postgres user password (no * or anything else is echoed): "
		read -s pgsqlrootpw
	done
	echo

	if PGPASSWORD="$pgsqlrootpw" $CONFIG_BIN_PSQL -U postgres -c '\du' | grep "\b$CONFIG_PRODUCTION_DB_USER\b" > /dev/null; then
		echo "PostgreSQL user $CONFIG_PRODUCTION_DB_USER does exist, won't try to create it"
		PGPASSWORD="$pgsqlrootpw" $CONFIG_BIN_PSQL -U postgres -c "ALTER ROLE $CONFIG_PRODUCTION_DB_USER CREATEDB LOGIN;"
	else
		echo "Creating PostgreSQL user $CONFIG_PRODUCTION_DB_USER..."
		PGPASSWORD="$pgsqlrootpw" $CONFIG_BIN_PSQL -U postgres -c "CREATE ROLE $CONFIG_PRODUCTION_DB_USER PASSWORD '$CONFIG_PRODUCTION_DB_PASS' CREATEDB LOGIN;"
	fi

	if PGPASSWORD="$pgsqlrootpw" $CONFIG_BIN_PSQL -U postgres -c '\l' | grep "\b$CONFIG_PRODUCTION_DB_NAME\b" > /dev/null; then
		echo "PostgreSQL database $CONFIG_PRODUCTION_DB_NAME does exist, won't try to create it"
		if PGPASSWORD="$CONFIG_PRODUCTION_DB_PASS" $CONFIG_BIN_PSQL -U "$CONFIG_PRODUCTION_DB_USER" -d "$CONFIG_PRODUCTION_DB_NAME" -c '\dt' | grep "No relations found" > /dev/null; then
		echo "Database $CONFIG_PRODUCTION_DB_NAME is empty, skipping backup..."
		else
		echo "Database $CONFIG_PRODUCTION_DB_NAME already contains some tables..."
		BACKUP_FILE=$(realpath $(mktemp "postgresql_${CONFIG_PRODUCTION_DB_NAME}_dump.XXXXXXXX"))
		echo "Dumping backup to $BACKUP_FILE..."
		PGPASSWORD="$pgsqlrootpw" $CONFIG_BIN_PG_DUMP -U postgres > $BACKUP_FILE || exit 2
		fi
	fi
	echo "Dropping database $CONFIG_PRODUCTION_DB_NAME..."
	PGPASSWORD="$pgsqlrootpw" $CONFIG_BIN_PSQL -U postgres -d template1 -c "DROP DATABASE $CONFIG_PRODUCTION_DB_NAME;"
	echo "Creating PostgreSQL database $CONFIG_PRODUCTION_DB_NAME..."
	PGPASSWORD="$CONFIG_PRODUCTION_DB_PASS" $CONFIG_BIN_PSQL -U "$CONFIG_PRODUCTION_DB_USER" -d template1 -c "CREATE DATABASE $CONFIG_PRODUCTION_DB_NAME;"

	disable_persistence
	php Public/index.php typo3cr admin setup setup --dsn="pgsql:dbname=$CONFIG_PRODUCTION_DB_NAME" --userid="$CONFIG_PRODUCTION_DB_USER" --password="$CONFIG_PRODUCTION_DB_PASS" --indexlocation="$CONFIG_LUCENE_INDEX_LOCATION"
	echo
	enable_persistence
	echo "Writing Configuration/Settings.yaml..."
	(cat <<EOF
TYPO3CR:
  # The storage backend configuration
  storage:
    backend: 'F3\TYPO3CR\Storage\Backend\PDO'
    backendOptions:
      dataSourceName: 'pgsql:dbname=$CONFIG_PRODUCTION_DB_NAME'
      username: '$CONFIG_PRODUCTION_DB_USER'
      password: '$CONFIG_PRODUCTION_DB_PASS'

  # The indexing/search backend configuration
  search:
    backend: 'F3\TYPO3CR\Storage\Search\Lucene'
    backendOptions:
      indexLocation: '$CONFIG_LUCENE_INDEX_LOCATION'
EOF
	) >> Configuration/Settings.yaml
}

setup_mysql_production_db() {
	echo "Setting up MySQL production database..."

	mysqlrootpw=""
	echo -n "Please enter your MySQL root password (no * or anything else is echoed): "
	read -s mysqlrootpw
	while ! $CONFIG_BIN_MYSQL -u root -p"$mysqlrootpw" -e "show databases;" > /dev/null
	do
		echo "No working mysql root password known..."
		echo -n "Please enter your MySQL root password (no * or anything else is echoed): "
		read -s mysqlrootpw
	done
	echo

	usercheckoutput=$($CONFIG_BIN_MYSQL -u root -p"$mysqlrootpw" -D mysql -e "SELECT user FROM user WHERE user = '$CONFIG_PRODUCTION_DB_USER';")
	if echo $usercheckoutput | grep "$CONFIG_PRODUCTION_DB_USER" > /dev/null; then
		echo "Database user $CONFIG_PRODUCTION_DB_USER exists, won't try to create it"
	else
		echo "Creating MySQL user $CONFIG_PRODUCTION_DB_USER..."
		$CONFIG_BIN_MYSQL -u root -p"$mysqlrootpw" -e "CREATE USER '$CONFIG_PRODUCTION_DB_USER'@'localhost' IDENTIFIED BY '$CONFIG_PRODUCTION_DB_PASS';"
	fi


	dbcheckoutput=$($CONFIG_BIN_MYSQL -u root -p"$mysqlrootpw" -D mysql -e "SHOW DATABASES;")
	if echo $dbcheckoutput | grep "\b$CONFIG_PRODUCTION_DB_NAME\b" > /dev/null; then
		echo "Database $CONFIG_PRODUCTION_DB_NAME already exists..."
		tablecheckoutput=$($CONFIG_BIN_MYSQL -u root -p"$mysqlrootpw" -D "$CONFIG_PRODUCTION_DB_NAME" -e "SHOW TABLES;")
		if echo $tablecheckoutput | grep "^.*$" > /dev/null; then
		echo "Database $CONFIG_PRODUCTION_DB_NAME is not empty..."
		BACKUP_FILE=$(realpath $(mktemp "mysql_${CONFIG_PRODUCTION_DB_NAME}_dump.XXXXXXXX"))
		echo "Dumping backup to $BACKUP_FILE..."
		$CONFIG_BIN_MYSQLDUMP -u root -p"$mysqlrootpw" $CONFIG_PRODUCTION_DB_NAME > $BACKUP_FILE
		echo "Dropping database $CONFIG_PRODUCTION_DB_NAME..."
		$CONFIG_BIN_MYSQL -u root -p"$mysqlrootpw" -e "DROP DATABASE $CONFIG_PRODUCTION_DB_NAME;";
		echo "Re-creating database $CONFIG_PRODUCTION_DB_NAME..."
		$CONFIG_BIN_MYSQL -u root -p"$mysqlrootpw" -e "CREATE DATABASE $CONFIG_PRODUCTION_DB_NAME;"
		else
		echo "Database $CONFIG_PRODUCTION_DB_NAME is empty, continuing..."
		fi
	else
		echo "Database $CONFIG_PRODUCTION_DB_NAME does not exist, creating it..."
		$CONFIG_BIN_MYSQL -u root -p"$mysqlrootpw" -e "CREATE DATABASE $CONFIG_PRODUCTION_DB_NAME;"
	fi

	echo "Granting rights on production database $CONFIG_PRODUCTION_DB_NAME to database user $CONFIG_PRODUCTION_DB_USER..."
	$CONFIG_BIN_MYSQL -u root -p"$mysqlrootpw" -e "GRANT ALL PRIVILEGES ON $CONFIG_PRODUCTION_DB_NAME.* TO '$CONFIG_PRODUCTION_DB_USER'@'localhost';"

	disable_persistence
	php Public/index.php typo3cr admin setup setup --dsn="mysql:dbname=$CONFIG_PRODUCTION_DB_NAME" --userid="$CONFIG_PRODUCTION_DB_USER" --password="$CONFIG_PRODUCTION_DB_PASS" --indexlocation="$CONFIG_LUCENE_INDEX_LOCATION"
	echo
	enable_persistence
	echo "Writing Configuration/Settings.yaml..."
	(cat <<EOF
TYPO3CR:
  # The storage backend configuration
  storage:
    backend: 'F3\TYPO3CR\Storage\Backend\PDO'
    backendOptions:
      dataSourceName: 'mysql:dbname=$CONFIG_PRODUCTION_DB_NAME'
      username: '$CONFIG_PRODUCTION_DB_USER'
      password: '$CONFIG_PRODUCTION_DB_PASS'

  # The indexing/search backend configuration
  search:
    backend: 'F3\TYPO3CR\Storage\Search\Lucene'
    backendOptions:
      indexLocation: '$CONFIG_LUCENE_INDEX_LOCATION'
EOF
	) >> Configuration/Settings.yaml
}

fix_permissions() {
	echo "Fixing permissions..."
	echo "Using sudo to allow for changes in both files owned by you and the webserver user..."
	sudo ./fixpermissions.sh "$CONFIG_WEBSERVER_USER" "$CONFIG_WEBSERVER_GROUP"
}

clean_temporary_data() {
	echo "Cleaning temporary data..."
	echo "Using sudo to allow for access to files owned by you and the webserver user..."
	sudo rm -rf Data/Temporary/*
}

setup_typo3() {
	echo "Setting up typo3v5"
	echo "Using config:"
	show_existing_config
	echo

	pushd $T3BASEDIR
	echo "Now in typo3 base directory: $T3BASEDIR"
	clean_temporary_data
	echo

	if [ -e "$CONFIG_LUCENE_INDEX_LOCATION" ]; then
		echo "Lucene index location exists..."
		if ls -l "$CONFIG_LUCENE_INDEX_LOCATION" | grep "^.*$" > /dev/null; then
		BACKUP_DIR=$(mktemp -d "$(echo "$CONFIG_LUCENE_INDEX_LOCATION" | sed -e 's#/\{0,1\} *$#.XXXXXXXX#')")
		rmdir $BACKUP_DIR
		echo "Backing up lucene index in $BACKUP_DIR..."
		mv "$CONFIG_LUCENE_INDEX_LOCATION" "$BACKUP_DIR"
		echo "Creating lucene index location..."
		mkdir -p "$CONFIG_LUCENE_INDEX_LOCATION"
		else
		echo "Lucene index location is empty, skipping backup..."
		fi
	else
		echo "Creating lucene index location..."
		mkdir -p "$CONFIG_LUCENE_INDEX_LOCATION"
	fi

	echo "Setting up production database..."
	case $CONFIG_PRODUCTION_DB_TYPE in
		"sqlite")
		setup_sqlite_production_db;;
		"postgres")
		setup_postgres_production_db;;
		"mysql")
		setup_mysql_production_db;;
	esac

	echo "Setting up test databases..."
	TESTDB=$T3BASEDIR/Packages/TYPO3CR/Tests/Fixtures/testdb.sh
	TESTDBCONF=$T3BASEDIR/Packages/TYPO3CR/Tests/Fixtures/testdb.conf
	chmod +x "$TESTDB"
	chmod 660 "$TESTDBCONF"
	sudo chown :$CONFIG_WEBSERVER_GROUP "$TESTDBCONF"
	echo "Writing testdb.sh config file $TESTDBCONF"
	(cat <<EOF
SQLITE3="$CONFIG_BIN_SQLITE3"
SQLITE3_DBFILE="$T3BASEDIR/Packages/TYPO3CR/Tests/Fixtures/TYPO3CR.db"
EOF
	) > $TESTDBCONF
	for testdbtype in $(echo $CONFIG_TEST_DB_TYPES)
	do
		case $testdbtype in
		"mysql")
	(cat <<EOF

MYSQL="$CONFIG_BIN_MYSQL"
MYSQL_USER="$CONFIG_TEST_MYSQL_DB_USER"
MYSQL_PASS="$CONFIG_TEST_MYSQL_DB_PASS"
MYSQL_DB="$CONFIG_TEST_MYSQL_DB_NAME"
EOF
	) >> $TESTDBCONF;;
		"postgres")
	(cat <<EOF

PSQL="$CONFIG_BIN_PSQL"
PGSQL_USER="$CONFIG_TEST_POSTGRES_DB_USER"
PGSQL_PASS="$CONFIG_TEST_POSTGRES_DB_PASS"
PGSQL_DB="$CONFIG_TEST_POSTGRES_DB_NAME"
EOF
	) >> $TESTDBCONF;;
		esac
	done

	$TESTDB sqlite setup
	for testdbtype in $(echo $CONFIG_TEST_DB_TYPES)
	do
		case $testdbtype in
		"postgres")
			echo "Setting up PostgreSQL test database"
			$TESTDB postgres setup "$pgsqlrootpw";;
		"mysql")
			echo "Setting up MySQL test database"
			$TESTDB mysql setup "$mysqlrootpw";;
		esac
	done

	fix_permissions

	echo "FLOW3 Setup complete..."
}

T3BASEDIR=$(dirname $(realpath $0))

T3INSTALLCONF="$T3BASEDIR"/install.conf

if [ -e $T3INSTALLCONF ]; then
	source $T3INSTALLCONF
	HAVE_CONFIG="yes"
fi

while true
do
	echo "Looking for config file in $T3BASEDIR"

	if [ "$CONFIG_HOSTNAME" = "$(hostname)" ]; then
		CONFIG_CORRECT_HOST="yes"
	fi

	if check_current_config; then
		CONFIG_VALID="yes"
	fi

	echo "1 Reconfigure"
	if [ "$HAVE_CONFIG" = "yes" ]; then
		echo "2 Show current config"
		if [ "$CONFIG_CORRECT_HOST" = "yes" ]; then
			if [ "$CONFIG_VALID" = "yes" ]; then
				echo "3 Use current config"
			else
				echo "  Existing config invalid (problems listed above this menu)"
			fi
		else
			echo "  Existing config created for a different host"
			if [ "$CONFIG_VALID" = "yes" ]; then
				echo "4 Force CONFIG_HOSTNAME to current hostname"
			else
				echo "  and some options are missing anyway, forcing use of existing config impossible"
			fi
		fi
	else
		echo "  Existing config not found"
	fi
	echo "0 Abort"
	read -s -n 1 opt
	echo
	case $opt in
		1)
		reconfigure;;
		2)
		echo Existing config
		show_existing_config
		echo;;
		3)
		setup_typo3
		exit 0;;
		4)
		CONFIG_HOSTNAME=$(hostname)
		write_config
		echo "Hostname updated to $CONFIG_HOSTNAME";;
		0)
		exit 1;;
		*)
		echo "Invalid option";;
	esac
done
