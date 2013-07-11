#!/bin/bash
CWD=$(pwd)
source ${CWD}/.settings

function bake_cake {
		cd ${EXT_DIR}
		./compile.sh
		echo "Build finished at $(date)"
		# This transient stuff does not leave a trailing notification.
		notify-send --hint=int:transient:1 "Build finished at $(date +'%H:%M:%S (%s)')"
}

function trapHUP {
		echo "Caught HUP -- Baking..."
		bake_cake
}

function info {
		echo "Build helper. Usage:"
		echo -e "\t* SIGINT to quit"
		echo -e "\t* SIGUSR1 to bake cake"
		echo -e "\t* PID can be found in /tmp/__watcher.pid"
		echo "Example usage:"
		echo -e "\t* kill -SIGUSR1 $$ to compile"
		echo -e "\t* kill $$ to quit"
		echo ""
}

function _exit {
		echo "Exit hook"
		rm /tmp/__watcher.pid
		exit 0
}

trap trapHUP SIGUSR1
trap _exit SIGINT

if [ ! -f ${CWD}/.settings ]; then
  echo "Settings file not found."
  echo "cp .settings.example .settings"
  echo "and configure"
	exit 1
fi

echo $$ > /tmp/__watcher.pid

info 

bake_cake

while true; do
  sleep 1
done
