#!/bin/sh

fromver=$1
ver=$2
input=cdb_geocoder--${ver}.sql
output=cdb_geocoder--${fromver}--${ver}.sql

cat ${input} | grep -v 'duplicated extension$' > ${output}

