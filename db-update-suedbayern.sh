#! /usr/bin/env bash
# Downloads fresh OSM data and imports (parts of) it into the local database

BASEDIR="~/osm"
OSM_DL_URL="http://download.geofabrik.de/europe/germany/bayern-latest.osm.pbf"
MMLFILE="${BASEDIR}/openstreetmap-carto/project.mml"
XMLFILE="${BASEDIR}/openstreetmap-carto/project.xml"
STYLEFILE="${BASEDIR}/openstreetmap-carto/openstreetmap-carto.style"
OSM2PGSQL_PROCS="2"
OSM2PGSQL_CACHE="1300"
OSM2PGSQL_BBOX="--bbox 11.838,47.436,13.03,49.407"


#echo "## Starting osm.pbf download and XML file generation in parallel and wait for both to finish"
#carto ${MMLFILE} > ${XMLFILE} &
#PID_CARTO = $!
echo "## Downloading from ${OSM_DL_URL}"
aria2c -q -d ${BASEDIR} ${OSM_DL_URL}
#wait PID_CARTO
#[[ $? -eq 0 ]] || echo "ERROR: carto failed with exit code $?"

echo "## Starting DB import"
${BASEDIR}/osm2pgsql/osm2pgsql -s -k -U osm --number-processes ${OSM2PGSQL_PROCS} \
    --multi-geometry -S ${STYLEFILE} -C ${OSM2PGSQL_CACHE} ${OSM2PGSQL_BBOX} \
    "${BASEDIR}/$(basename ${OSM_DL_URL})"


