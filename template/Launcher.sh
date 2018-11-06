#!/bin/bash
# Variables to set during docker run
LIQUIBASE_SCHEMA='FR_FRT_TL_AUTO_11121_OWN'
LIQUIBASE_ACTION='status'
LIQUIBASE_CONTEXT='dev,init,sqlplus'

LIQUIBASE_HOST='137.74.197.63'
LIQUIBASE_INSTANCE='ORCLCDB'
LIQUIBASE_PORT='1521'

LIQUIBASE_USR='c##CodeAPMyAPPown'
LIQUIBASE_PWD='MyAPPownpwd'

# *** BEGIN - Automatic settings *** #
	# Set thanks to input
LIQUIBASE_SQLPLUSPATH="@./db/changelog/schema-$LIQUIBASE_SCHEMA"
LIQUIBASE_CHANGELOG="./db/changelog/schema-$LIQUIBASE_SCHEMA/changelog-master.yaml"
LIQUIBASE_URL="jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$LIQUIBASE_HOST)(PORT=$LIQUIBASE_PORT)))(CONNECT_DATA=(SERVICE_NAME=$LIQUIBASE_INSTANCE)))"
LIQUIBASE_SQLPLUSCONN="$LIQUIBASE_USR/$LIQUIBASE_PWD@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$LIQUIBASE_HOST)(PORT=$LIQUIBASE_PORT)))(CONNECT_DATA=(SERVICE_NAME=$LIQUIBASE_INSTANCE)))"
	#Read the manifest to get package info
PACKAGE_INFO=$(cat /liquibase/data/META-INF/MANIFEST.MF | grep 'Implementation-Version:' | cut -d ' ' -f 2 | cut -d '_' -f 1)
# *** END - Automatic settings *** #

# Be in real folder
cd /liquibase/data

# Command line to execute
CMD=$(echo \
-DsqlPlusConn="$LIQUIBASE_SQLPLUSCONN" -DsqlPlusPath="$LIQUIBASE_SQLPLUSPATH" \
-DpackageInfo="$PACKAGE_INFO" \
liquibase.integration.commandline.Main \
--driver="$ORACLE_DRIVER" \
--logFile="$LIQUIBASE_LOG" --logLevel=debug \
--changeLogFile="$LIQUIBASE_CHANGELOG" \
--url="$LIQUIBASE_URL" --username="$LIQUIBASE_USR" --password="$LIQUIBASE_PWD" \
--contexts="$LIQUIBASE_CONTEXT" \
"$LIQUIBASE_ACTION" --verbose)

# Print the command line
echo "$CMD"

# Execute the command line
java "$CMD"