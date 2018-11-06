# Variables to set during docker run
LIQUIBASE_CHANGELOG="./db/changelog/schema-FR_FRT_TL_AUTO_11121_OWN/changelog-master.yaml"
LIQUIBASE_SQLPLUSPATH="@./db/changelog/schema-FR_FRT_TL_AUTO_11121_OWN"
LIQUIBASE_ACTION="status"
PACKAGE_INFO="5.1.13-SNAPSHOT"
LIQUIBASE_CONTEXT="dev, init, sqlplus"
LIQUIBASE_URL="jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=137.74.197.63)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=ORCLCDB)))"
LIQUIBASE_SQLPLUSCONN="c##CodeAPMyAPPown/MyAPPownpwd@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=137.74.197.63)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=ORCLCDB)))"
LIQUIBASE_USR="c##CodeAPMyAPPown"
LIQUIBASE_PWD="MyAPPownpwd"

# Be in real folder
cd /liquibase/data

# BEGIN - To Delete #
# Get test package
mv /liquibase/templates/samplepim3-db-5.1.13-SNAPSHOT.zip .
unzip samplepim3-db-5.1.13-SNAPSHOT.zip -o -q
rm samplepim3-db-5.1.13-SNAPSHOT.zip -f
# END - To Delete

# Command line to execute
java \
-DsqlPlusConn=${LIQUIBASE_SQLPLUSCONN} -DsqlPlusPath=${LIQUIBASE_SQLPLUSPATH} \
-DpackageInfo=${PACKAGE_INFO} \
-cp "/liquibase/tools/liquibase-core-3.5.5.jar:/liquibase/tools/snakeyaml-1.17.jar:/liquibase/tools/ojdbc8-12.2.0.1.jar" liquibase.integration.commandline.Main \
--driver=oracle.jdbc.OracleDriver \
--logFile=/liquibase/logs/liquibase.log --logLevel=debug \
--changeLogFile=${LIQUIBASE_CHANGELOG} \
--url=${LIQUIBASE_URL} --username=${LIQUIBASE_USR} --password=${LIQUIBASE_PWD} \
--contexts=${LIQUIBASE_CONTEXT} \
${LIQUIBASE_ACTION} --verbose
