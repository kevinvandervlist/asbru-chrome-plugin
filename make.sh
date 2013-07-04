#!/bin/bash
kill -SIGUSR1 $(cat /tmp/__watcher.pid)
