#! /usr/bin/env bash

BASEDIR="${HOME}/osm"
TILESDIR="${BASEDIR}/tiles"
MAPNIKDIR="${BASEDIR}/mapnik"
XMLFILE="${BASEDIR}/openstreetmap-carto/project.xml"

function usage {
echo "Script for generating new tiles and uploading them to the tile server
usage: $(basename ${0}) [OPTION]
	-u 	- Upload tiles of the Pasinger Stadtpark to the tiles server
	-a 	- Upload full tiles directory to the tile server (implies -u)
	-h 	- Show this help text"
}

while getopts "uah" options; do
  case $options in
    u ) SCPSOURCE="${TILESDIR}/16/34852"
        SCPTARGET="n36l:/var/www/osm/tiles/16/"
        ;;
    a ) SCPSOURCE="${TILESDIR}/*"
        SCPTARGET="n36l:/var/www/osm/tiles/"
        ;;
    h ) usage
        exit 0
        ;;
  esac
done

echo "## Generating tiles"
${MAPNIKDIR}/polytiles.py -u osm --bbox 11.4479 48.13509 11.44923 48.13024 \
    -z 16 16 -t ${TILESDIR} -s ${XMLFILE} || ( echo "Mapnik failed"; exit 1 )

if [[ ( -n ${SCPSOURCE} ) -a ( -n ${SCPTARGET} ) ]] ; then
    echo "## Uploading tiles to the tiles server"
    scp -r ${SCPSOURCE} ${SCPTARGET}
fi

