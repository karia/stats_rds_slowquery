#!/bin/bash

set -eu

INSTANCE_IDENTIFIER=$1
SLOW_LOG=mysqlslow_${INSTANCE_IDENTIFIER}_`date +%Y-%m-%d`_raw.txt
DUMP_TXT=mysqlslow_${INSTANCE_IDENTIFIER}_`date +%Y-%m-%d`.txt

TIMESTAMP=`expr $(date --date '24 hours ago' +%s%N) / 1000000`
FILELIST=`aws rds describe-db-log-files --db-instance-identifier ${INSTANCE_IDENTIFIER} --filename-contains slowquery/mysql-slowquery.log. --no-paginate --file-last-written ${TIMESTAMP} --query 'DescribeDBLogFiles[].LogFileName' --output text`

cd `dirname $0`
cat /dev/null > ${SLOW_LOG}

for FILENAME_SLOWLOG in ${FILELIST}
do
  aws rds download-db-log-file-portion --db-instance-identifier ${INSTANCE_IDENTIFIER} --log-file-name ${FILENAME_SLOWLOG} --output text --starting-token 0 | grep -v "# Time" >> ${SLOW_LOG}
done
mysqldumpslow -t 20 -s t ${SLOW_LOG} > ${DUMP_TXT}

curl -sS -F file=@${DUMP_TXT} -F channels=${SLACK_CHANNEL} -F token=${SLACK_TOKEN} https://slack.com/api/files.upload
rm ${SLOW_LOG} ${DUMP_TXT}
