FROM anapsix/alpine-java:8_jdk
LABEL maintainer="pierre.costa@capgemini.com"

# Set liquibase variables
ARG liquibase_version=3.5.5
ARG snakeyaml_version=1.17
ARG ojdbc_name=ojdbc8
ARG ojdbc_version=12.2.0.1

ARG liquibase_download_url=http://central.maven.org/maven2/org/liquibase/liquibase-core/${liquibase_version}/liquibase-core-${liquibase_version}.jar
ARG snakeyaml_download_url=http://central.maven.org/maven2/org/yaml/snakeyaml/${snakeyaml_version}/snakeyaml-${snakeyaml_version}.jar
ARG ojdbc_download_url=http://central.maven.org/maven2/com/github/noraui/${ojdbc_name}/${ojdbc_version}/${ojdbc_name}-${ojdbc_version}.jar

# Create directories for liquibase
RUN mkdir /liquibase/tools;\
	mkdir /liquibase/data;\
	mkdir /liquibase/logs;\
	mkdir /liquibase/templates;\
	mkdir /liquibase/results;

# Retrieve Launcher
COPY templates/* /liquibase/templates/

# Retrieve Liquibase package
RUN cd /liquibase/tools;\
	curl -SOLs ${liquibase_download_url};\
	curl -SOLs ${snakeyaml_download_url};\
	curl -SOLs ${ojdbc_download_url};

# Unpack the distribution
ENV LIQUIBASE_CLASSPATH=/liquibase/tools/iquibase-core-${liquibase_version}.jar:/liquibase/tools/snakeyaml-${snakeyaml_version}.jar:/liquibase/tools/${ojdbc_name}-${ojdbc_version}.jar
ENV LIQUIBASE_JAVAFILE=liquibase.integration.commandline.Main
ENV LIQUIBASE_DRIVER=oracle.jdbc.OracleDriver
ENV LIQUIBASE_LOG=/liquibase/logs/liquibase.log
ENV LIQUIBASE_LOGLEVEL=debug

WORKDIR /liquibase/data
ONBUILD VOLUME /liquibase/data
CMD ['/bin/sh', '-i']


# *** RUN ***
# Set below variables when run
# ENV LIQUIBASE_CHANGELOG=${LIQUIBASE_CHANGELOG}
# ENV LIQUIBASE_HOST=${LIQUIBASE_HOST}
# ENV LIQUIBASE_PORT=${LIQUIBASE_PORT}
# ENV LIQUIBASE_INSTANCE=${LIQUIBASE_INSTANCE}
# ENV LIQUIBASE_USERNAME=${LIQUIBASE_USERNAME}
# ENV LIQUIBASE_PASSWORD=${LIQUIBASE_PASSWORD}
# ENV LIQUIBASE_ACTION=${LIQUIBASE_ACTION}

# Retrieve git source in same package (set when mount the volume) -> Mount in /liquibase/data

# Variables set automatically
# ENV LIQUIBASE_DATABASE=jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=${LIQUIBASE_HOST})(PORT=${LIQUIBASE_PORT})))(CONNECT_DATA=(SERVICE_NAME=${LIQUIBASE_INSTANCE})))
# ENV LIQUIBASE_SQLPLUS=${LIQUIBASE_USERNAME}/${LIQUIBASE_PASSWORD}@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=${LIQUIBASE_HOST})(PORT=${LIQUIBASE_PORT})))(CONNECT_DATA=(SERVICE_NAME=${LIQUIBASE_INSTANCE})))

# Command line to execute
# java -cp ${LIQUIBASE_CLASSPATH} ${LIQUIBASE_JAVAFILE} --logFile=${LOG_FILE} --changeLogFile=${LIQUIBASE_CHANGELOG} ${LIQUIBASE_ACTION} --verbose

# Sources Docker File
#		https://github.com/sequenceiq/docker-liquibase/blob/master/Dockerfile
#		https://github.com/kilna/liquibase-docker
