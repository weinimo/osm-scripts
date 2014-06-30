#! /usr/bin/env bash
# Downloads fresh OSM data and imports (parts of) it into the local database

BASEDIR="${HOME}/osm"
OSM_DL_URL="http://download.geofabrik.de/europe/germany/bayern-latest.osm.pbf"
MMLFILE="${BASEDIR}/openstreetmap-carto/project.mml"
XMLFILE="${BASEDIR}/openstreetmap-carto/project.xml"
STYLEFILE="${BASEDIR}/openstreetmap-carto/openstreetmap-carto.style"
OSM2PGSQL_PROCS="4"
OSM2PGSQL_CACHE="2300"
OSM2PGSQL_BBOX="--bbox 11.838,47.436,13.03,49.407"



function usage {
echo "Script for downloading new OSM data and importing it in the local database
usage: $(basename ${0}) [OPTION]
	-c 	- Run carto and generate a new XML file for mapnik
	-d	- Download a new .osm.pbf file
	-h 	- Show this help text"
}

while getopts "dch" options; do
  case $options in
    d ) DOWNLOAD="1";;
    c ) CARTO="1";;
    h ) usage
        exit 0
        ;;
  esac
done

if [[ -n ${CARTO} ]] ; then
    echo "## Starting XML file generation with carto in background"
    carto ${MMLFILE} > ${XMLFILE} &
fi
if [[ -n ${DOWNLOAD} ]] ; then
    echo "## Downloading from ${OSM_DL_URL}"
    aria2c --summary-interval=0 -d ${BASEDIR} ${OSM_DL_URL}
fi
wait	# Wait for carto to finish
[[ $? -eq 0 ]] || echo "ERROR: carto failed with exit code $?"

echo "## Starting DB import (using a new screen session)"
echo "## Detach using <C-a> d; Reattach using \"screen -r\""
echo "## You will find a logfile in the current directory: screenlog.0"
screen -L -m -S osm2pgsql ${BASEDIR}/osm2pgsql/osm2pgsql -s -k -U osm --number-processes ${OSM2PGSQL_PROCS} \
    --multi-geometry -S ${STYLEFILE} -C ${OSM2PGSQL_CACHE} ${OSM2PGSQL_BBOX} \
    "${BASEDIR}/$(basename ${OSM_DL_URL})"


