#!/bin/sh -x
################################################################################
#  Task runner for launch a linux command
#  run it just like this:
#  /yourpath/yourapp/batch_exec.sh batch_id
################################################################################

export NORMAL_END=0
export CONF_ERR=1
export PROC_ERR=2

# arguments
if [ $# -lt 1 ]; then
    echo "usage: $0 batch_id [others]"
    exit ${NORMAL_END}
fi

# root path
export BATCH_ROOT=$(cd $(dirname $0); pwd)

# public settings
if [ -r ${BATCH_ROOT}/env/settings.env ]; then
    . ${BATCH_ROOT}/env/settings.env
else
    echo "create a settings.env file under this path (${BATCH_ROOT}/env/)"
    exit ${CONF_ERR}
fi

# define log file
BATCH_ID=$1
BATCH_LOG_FILE=${LOGS_DIR}/${BATCH_ID}_`date "+%Y%m%d_%H%M%S"`.log

# private settings
if [ -r ${BATCH_ROOT}/env/${BATCH_ID}.env ]; then
    . ${BATCH_ROOT}/env/${BATCH_ID}.env
fi

if [ ! -r ${BATCH_LIST} ]; then
    echo "create a ${BATCH_LIST} file under this path (${BATCH_ROOT}/env/)" >> ${BATCH_LOG_FILE}
    exit ${CONF_ERR}
fi

# check the define of batch
EXEC_FILE=`awk -F:: '$1 == "'${BATCH_ID}'" {print $2}' ${BATCH_LIST}`
if [ ! -n "${EXEC_FILE}" ]; then
    echo "executable file not be defined (batch_id: ${BATCH_ID})" >> ${BATCH_LOG_FILE}
    exit ${CONF_ERR}
fi

# check this executable file
if [ ! -r ${BATCH_ROOT}/${EXEC_FILE} ]; then
    echo "executable file not exist (${BATCH_ROOT}/${EXEC_FILE})" >> ${BATCH_LOG_FILE}
    exit ${CONF_ERR}
fi

echo "`date "+%Y/%m/%d %H:%M:%S"` ${BATCH_ID} start..." >> ${BATCH_LOG_FILE}

# execute it!
${BATCH_ROOT}/${EXEC_FILE} ${BATCH_ID} >> ${BATCH_LOG_FILE} 2>&1
ret=$?

if [ ${ret} -ne ${NORMAL_END} ]; then
    echo "`date "+%Y/%m/%d %H:%M:%S"` ${BATCH_ID} error end...(return_code:${ret})" >> ${BATCH_LOG_FILE}
    exit ${PROC_ERR}
else
    echo "`date "+%Y/%m/%d %H:%M:%S"` ${BATCH_ID} normal end..." >> ${BATCH_LOG_FILE}
    exit ${NORMAL_END}
fi

