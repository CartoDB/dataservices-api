#!/bin/bash

TARGET_DB=$1
PGUSER=${2:-postgres}
PYTHON_LIBRARY_NAME='cartodb_services'

function usage {
  echo "Usage: ${0} <dbname> [dbuser]"
}

[[ -z $TARGET_DB ]] && echo "Missing DB parameter" && usage && exit 1

python -c "import ${PYTHON_LIBRARY_NAME}"
if [[ $? != 0 ]]
then
  echo "Missing ${PYTHON_LIBRARY_NAME} python library"
  echo "Trying to install.."
  cd server/lib/python/cartodb_services && sudo python setup.py install
  python -c "import ${PYTHON_LIBRARY_NAME}" 2> /dev/null
  if [[ $? != 0 ]]
  then
    echo "There are some problems with python library. Debug manually"
    exit 1
  fi
fi

CREATE_EXTENSION_COMMAND="CREATE EXTENSION IF NOT EXISTS"

CDB_GEOCODER_EXTENSION_CREATE="${CREATE_EXTENSION_COMMAND} cdb_geocoder"
CDB_DATASERVICES_SERVER_CREATE="${CREATE_EXTENSION_COMMAND} cdb_dataservices_server"

echo "* Creating extension cdb_geocoder"
psql -U ${PGUSER} -d ${TARGET_DB} -c "${CDB_GEOCODER_EXTENSION_CREATE}"
echo "* Creating extension cdb_dataservices_server"
psql -U ${PGUSER} -d ${TARGET_DB} -c "${CDB_DATASERVICES_SERVER_CREATE}"
