#!/bin/bash
#
# bootstrap geolab database
#




# postgres server superadmin postres password
#
read -s -p "postgres password: " postgres_pass


# geolab database initialization user passwords
#
geolab_pass="geolab"
osgav_pass="osgav"
qgis_pass="qgis"


# geolab database initialization custom .pgpass file passfile
#
touch geolab_init.$$
echo "#hostname:port:database:username:password"  >> geolab_init.$$
echo "localhost:5432:*:postgres:${postgres_pass}" >> geolab_init.$$
echo "localhost:5432:*:geolab:${geolab_pass}"     >> geolab_init.$$
echo "localhost:5432:*:osgav:${osgav_pass}"       >> geolab_init.$$
echo "localhost:5432:*:qgis:${qgis_pass}"         >> geolab_init.$$
chmod 600 geolab_init.$$


# psql connection strings
#
connect_as_postgres="           postgresql://postgres@localhost:5432/postgres?passfile=geolab_init.$$"
connect_as_geolab_to_postgres=" postgresql://geolab@localhost:5432/postgres?passfile=geolab_init.$$"
connect_as_geolab_to_geolab="   postgresql://geolab@localhost:5432/geolab?passfile=geolab_init.$$"
connect_as_osgav_to_geolab="    postgresql://osgav@localhost:5432/geolab?passfile=geolab_init.$$"


# create user roles
#
psql ${connect_as_postgres} -c "CREATE ROLE geolab WITH PASSWORD '${geolab_pass}' LOGIN CREATEDB;"
psql ${connect_as_postgres} -c "CREATE ROLE osgav  WITH PASSWORD '${osgav_pass}'  LOGIN;"
psql ${connect_as_postgres} -c "CREATE ROLE qgis   WITH PASSWORD '${qgis_pass}'   LOGIN;"


# create geolab database
#
psql ${connect_as_geolab_to_postgres} -c "CREATE DATABASE geolab;"
psql ${connect_as_geolab_to_geolab}   -c "CREATE EXTENSION postgis;"


# configure read/write access
#
psql ${connect_as_postgres}         -f sql/create-access-roles.sql
psql ${connect_as_geolab_to_geolab} -f sql/alter-default-privileges-geolab.sql
psql ${connect_as_osgav_to_geolab}  -f sql/alter-default-privileges-osgav.sql
psql ${connect_as_postgres}         -f sql/grant-access-roles.sql


# cleanup temporary .pgpass file
#
rm geolab_init.$$

