#!/bin/bash
CWD=$(pwd)
source ${CWD}/.settings

if [ -d ${DEST_DIR} ]; then
		rm -r ${DEST_DIR}
fi

# Prepare output env
cp -r ${SRC_DIR} ${DEST_DIR}
find ${DEST_DIR} -type f -name "*.coffee" -exec rm -f {} \;

# Compile plugin
coffee -j "${DEST_DIR}/scripts/background.js" -c "${SRC_DIR}/scripts/background/"
coffee -j "${DEST_DIR}/scripts/views.js" -c "${SRC_DIR}/scripts/views/"

# Setup test env
coffee -j "${DEST_DIR}/scripts/background.js" -c "${SRC_DIR}/tests/background/" "${SRC_DIR}/scripts/background/"

coffee -j "${DEST_DIR}/tests/views.tests.js" -c "${SRC_DIR}/tests/views/" "${SRC_DIR}/scripts/views/"
