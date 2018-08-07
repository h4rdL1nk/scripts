#!/bin/env bash

function usage(){
	echo -e "Usage: $(basename $0) db_host[s] db_name backlog_name start_date end_date \
\n\n\tExample: $(basename $0) host1:port,host2:port test-db test-collection 2018-08-06T00:00:00.000Z 2018-08-06T23:59:59.999Z\n"
}

if [ $# -ne 5 ]
then
	usage
	exit 1
fi

DATE_REGEX="^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}Z$"

DB_HOST=$1
DB_NAME=$2
BACKLOG_NAME=$3
START_DATE=$4
END_DATE=$5

if [[ ! ${START_DATE} =~ ${DATE_REGEX} ]] || [[ ! ${END_DATE} =~ ${DATE_REGEX} ]]
then
	echo "Error in dates format. It must match regex '${DATE_REGEX}'"
	exit 2
fi

OUT_FILE="${DB_NAME}-${BACKLOG_NAME}-$(date '+%Y%m%d%H%M%S').out"

mongo --quiet \
    --host  ${DB_HOST} \
    --eval "var Backlog = '${BACKLOG_NAME}';var Database = '${DB_NAME}';var SDate = '${START_DATE}';var EDate = '${END_DATE}'" \
    dump.js | egrep -v "${DATE_REGEX}" >${OUT_FILE}
