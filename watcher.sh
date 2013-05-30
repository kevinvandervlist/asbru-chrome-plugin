#!/bin/bash
CWD=$(pwd)
source ${CWD}/.settings

function bake_cake {
		cd ${EXT_DIR}
		./compile.sh
		echo "Cake done at $(date)"
}

function trapHUP {
		echo "Caught HUP -- Baking..."
		bake_cake
}

function info {
		echo "Build helper. Usage:"
		echo -e "\t* SIGINT to quit"
		echo -e "\t* SIGUSR1 to bake cake"
		echo "Example usage:"
		echo -e "\t* kill -SIGUSR1 $$ to compile"
		echo -e "\t* kill $$ to quit"
		echo ""
}

function _exit {
		echo "Exit hook"
		exit 0
}

trap trapHUP SIGUSR1
trap _exit SIGINT

if [ ! -f ${CWD}/.settings ]; then
  echo "Settings file not found."
  echo "cp .settings.example .settings"
  echo "and configure"
fi

info 

bake_cake

while true; do
  sleep 1
done
