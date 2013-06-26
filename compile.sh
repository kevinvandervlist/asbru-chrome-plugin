#!/bin/bash
CWD=$(pwd)

if [ ! -f ${CWD}/.settings ]; then
		echo "ERROR: Create a .settings file."
		exit 1
fi

source ${CWD}/.settings

if [ -d ${DEST_DIR} ]; then
		rm -r ${DEST_DIR}
fi

# Utilities should always be included
UTIL="${SRC_DIR}/scripts/util/"
UTILTEST="${SRC_DIR}/tests/util/"

# Prepare output env
cp -r ${SRC_DIR} ${DEST_DIR}

# Compile plugin - background process
coffee simple-coffee-dependencies.coffee -I "${SRC_DIR}/scripts/background/" -I "${UTIL}" -F "${SRC_DIR}/scripts/background/Main.coffee" > "${DEST_DIR}/scripts/background.coffee"
coffee -o "${DEST_DIR}/scripts/" -c "${DEST_DIR}/scripts/background.coffee"

# Compile plugin - view scripts
coffee simple-coffee-dependencies.coffee -I "${SRC_DIR}/view/app/coffee/" -I "${UTIL}" -F "${SRC_DIR}/view/app/coffee/app.coffee" > "${DEST_DIR}/view/app/coffee/app.coffee"
coffee -o "${DEST_DIR}/view/app/" -c "${DEST_DIR}/view/app/coffee/app.coffee"

# Setup test env
coffee simple-coffee-dependencies.coffee -I "${SRC_DIR}/scripts/background/" -I "${UTIL}" -I "${UTILTEST}" -F "${SRC_DIR}/tests/background/Main.tests.coffee" -F > "${DEST_DIR}/tests/background.tests.coffee"
coffee -o "${DEST_DIR}/tests/" -c "${DEST_DIR}/tests/background.tests.coffee"

coffee simple-coffee-dependencies.coffee -I "${SRC_DIR}/scripts/views/" -I "${UTIL}" -I "${UTILTEST}" -F "${SRC_DIR}/tests/views/Main.tests.coffee" -F > "${DEST_DIR}/tests/views.tests.coffee"
coffee -o "${DEST_DIR}/tests/" -c "${DEST_DIR}/tests/views.tests.coffee"

# Clean up old coffee files
#find ${DEST_DIR} -type f -name "*.coffee" -exec rm -f {} \;
