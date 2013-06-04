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

# Compile plugin - background process
coffee simple-coffee-dependencies.coffee -I "${SRC_DIR}/scripts/background/" -I "${UTIL}" -F "${SRC_DIR}/scripts/background/Main.coffee" > "${DEST_DIR}/scripts/background.coffee"
coffee -o "${DEST_DIR}/scripts/" -c "${DEST_DIR}/scripts/background.coffee"

# Compile plugin - view scripts
coffee simple-coffee-dependencies.coffee -I "${SRC_DIR}/scripts/views/" -I "${UTIL}" -F "${SRC_DIR}/scripts/views/Main.coffee" > "${DEST_DIR}/scripts/views.coffee"
coffee -o "${DEST_DIR}/scripts/" -c "${DEST_DIR}/scripts/views.coffee"

# Setup test env
coffee -j "${DEST_DIR}/tests/background.tests.js" -c "${UTIL}" "${SRC_DIR}/scripts/background/" "${SRC_DIR}/tests/background/" "${SRC_DIR}/tests/util/"

coffee -j "${DEST_DIR}/tests/views.tests.js" -c "${UTIL}" "${SRC_DIR}/scripts/views/" "${SRC_DIR}/tests/views/" "${SRC_DIR}/tests/util/"

# Clean up old coffee files
#find ${DEST_DIR} -type f -name "*.coffee" -exec rm -f {} \;
