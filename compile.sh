#!/bin/bash
CWD=$(pwd)
source ${CWD}/.settings

if [ -d ${DEST_DIR} ]; then
		rm -r ${DEST_DIR}
fi

# Utilities should always be included
UTIL="${SRC_DIR}/scripts/util/"

# Prepare output env
cp -r ${SRC_DIR} ${DEST_DIR}
find ${DEST_DIR} -type f -name "*.coffee" -exec rm -f {} \;

# Compile plugin
coffee -j "${DEST_DIR}/scripts/background.js" -c "${SRC_DIR}/scripts/background/" "${UTIL}"
coffee -j "${DEST_DIR}/scripts/views.js" -c "${SRC_DIR}/scripts/views/" "${UTIL}"

# Setup test env
coffee -j "${DEST_DIR}/scripts/background.js" -c "${SRC_DIR}/tests/background/" "${SRC_DIR}/tests/util/" "${SRC_DIR}/scripts/background/" "${UTIL}"

coffee -j "${DEST_DIR}/tests/views.tests.js" -c "${SRC_DIR}/tests/views/" "${SRC_DIR}/tests/util/" "${SRC_DIR}/scripts/views/" "${UTIL}"
