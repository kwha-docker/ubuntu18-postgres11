#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
FROM ubuntu:18.04

RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive
RUN  dpkg-divert --local --rename --add /sbin/initctl

RUN apt-get -y update; apt-get -y install gnupg2 wget ca-certificates rpl pwgen

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -


# Specify volume to save data to here
VOLUME /var/lib/postgresql/11/main

#-------------Application Specific Stuff ----------------------------------------------------

# We add postgis as well to prevent build errors (that we dont see on local builds)
# on docker hub e.g.
# The following packages have unmet dependencies:
RUN apt-get update

RUN apt-get install -y postgresql-client-11 
RUN apt-get install -y postgresql-common postgresql-11
RUN apt-get install -y postgresql-11-postgis-2.5 
RUN apt-get install -y postgresql-11-pgrouting 
RUN apt-get install -y netcat
RUN apt-get install -y libpq-dev

# Open port 5432 so linked containers can see them
EXPOSE 5432


# Run any additional tasks here that are too tedious to put in
# this dockerfile directly.
ADD env-data.sh /env-data.sh
ADD setup.sh /setup.sh
RUN chmod +x /setup.sh
RUN /setup.sh

# We will run any commands in this when the container starts
ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD setup-conf.sh /
ADD setup-database.sh /
ADD setup-pg_hba.sh /
ADD setup-replication.sh /
ADD setup-ssl.sh /
ADD setup-user.sh /
RUN chmod +x /docker-entrypoint.sh

# Heliostats specific commands
# copied from https://github.com/kwha-docker/postgis-marvin/blob/master/Dockerfile
RUN apt-get install -y build-essential libssl-dev libffi-dev python-dev python-pip \
    python-tk libncurses5-dev bash s3cmd jq git lftp curl virtualenv


ADD . /postgis-public

ENTRYPOINT /docker-entrypoint.sh
