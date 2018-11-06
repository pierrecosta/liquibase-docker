FROM anapsix/alpine-java:8_jdk
LABEL maintainer="pierre.costa@capgemini.com"

# Add curl and libaio to alpine
RUN apk add --update curl && \
    rm -rf /var/cache/apk/*;\
	apk add --update libaio && \
    rm -rf /var/cache/apk/*;

# Set liquibase variables
ARG liquibase_version=3.5.5
ARG snakeyaml_version=1.17
ARG ojdbc_name=ojdbc8

ARG liquibase_download_url=http://central.maven.org/maven2/org/liquibase/liquibase-core/${liquibase_version}/liquibase-core-${liquibase_version}.jar
ARG snakeyaml_download_url=http://central.maven.org/maven2/org/yaml/snakeyaml/${snakeyaml_version}/snakeyaml-${snakeyaml_version}.jar

# Create directories for liquibase
RUN mkdir /liquibase;\
	mkdir /liquibase/tools;\
	mkdir /liquibase/data;\
	mkdir /liquibase/logs;\
	mkdir /liquibase/templates;\
	mkdir /liquibase/results;

# Retrieve Launcher and add exec permission to launcher
COPY ./template/* /liquibase/templates/
RUN /bin/bash -c 'chmod +x /liquibase/templates/Launcher.sh';

# Retrieve SQLPLUS package and add exec permission
COPY ./liquibase/tools/* /liquibase/tools/

# Unzip SQLPLUS, update permission, create synonym, add lib path and clean source package
RUN cd /liquibase/tools;\
	unzip instantclient-basic-linux.x64-12.2.0.1.0.zip -o -q;\
	unzip instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -o -q;\
	/bin/bash -c 'chmod +x /liquibase/tools/instantclient_12_2/sqlplus';\
	ln -s /liquibase/tools/instantclient_12_2/libclntsh.so.12.1 /liquibase/tools/instantclient_12_2/libclntsh.so;\
	ln -s /liquibase/tools/instantclient_12_2/libocci.so.12.1 /liquibase/tools/instantclient_12_2/libocci.so;\
	rm /liquibase/tools/instantclient-basic-linux.x64-12.2.0.1.0.zip -f;\
	rm /liquibase/tools/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -f;

ENV LD_LIBRARY_PATH=/liquibase/tools/instantclient_12_2:${LD_LIBRARY_PATH}
ENV PATH=/liquibase/tools/instantclient_12_2:${PATH}

# Retrieve Liquibase package
RUN cd /liquibase/tools;\
	curl -SOLs ${liquibase_download_url};\
	curl -SOLs ${snakeyaml_download_url};\

# Delete curl from image
RUN apk del curl && \
    rm -rf /var/cache/apk/*

# Unpack the distribution
ENV CLASSPATH=/liquibase/tools/liquibase-core-${liquibase_version}.jar:/liquibase/tools/snakeyaml-${snakeyaml_version}.jar:/liquibase/tools/instantclient_12_2/${ojdbc_name}.jar
ENV ORACLE_DRIVER=oracle.jdbc.OracleDriver
ENV LIQUIBASE_LOG=/liquibase/logs/liquibase.log

WORKDIR /liquibase/data

# To launch docker image
# docker run -it -v $(pwd)/data:/liquibase/data -v ${pwd}/logs:/liquibase/logs docker-liquibase
# 	where $(pwd)/data is the directory inside the package

# *** RUN ***


# Retrieve git source in same package (set when mount the volume) -> Mount in /liquibase/data

# Variables set automatically
# ENV LIQUIBASE_DATABASE=jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=${LIQUIBASE_HOST})(PORT=${LIQUIBASE_PORT})))(CONNECT_DATA=(SERVICE_NAME=${LIQUIBASE_INSTANCE})))
# ENV #LIQUIBASE_SQLPLUS=${LIQUIBASE_USERNAME}/${LIQUIBASE_PASSWORD}@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=${LIQUIBASE_HOST})(PORT=${LIQUIBASE_PORT})))(CONNECT_DATA=(SERVICE_NAME=${LIQUIBASE_INSTANCE})))

# Command line to execute
# java -cp ${LIQUIBASE_CLASSPATH} ${LIQUIBASE_JAVAFILE} --logFile=${LOG_FILE} --changeLogFile=${LIQUIBASE_CHANGELOG} ${LIQUIBASE_ACTION} --verbose

# Sources Docker File
#		https://github.com/sequenceiq/docker-liquibase/blob/master/Dockerfile
#		https://github.com/kilna/liquibase-docker
