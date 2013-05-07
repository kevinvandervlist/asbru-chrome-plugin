#!/bin/bash
CWD=$(pwd)
DIR=/export/scratch1/src/extension

function bake_cake {
		cd ${DIR}
		cake build
		echo "Cake done at $(date)"
}

function trapHUP {
		echo "Caught HUP -- Baking..."
		bake_cake
}

function info {
		echo ""
		echo "SIGINT to quit"
		echo "SIGUSR1 to bake cake"
		echo "Example:"
		echo "kill -SIGUSR1 $$"
		echo ""
}

function _exit {
		echo "Exit hook"
		exit 0
}

trap trapHUP SIGUSR1
trap _exit SIGINT

bake_cake

info

while true; do
  sleep 1
done
