#!/bin/bash

########### Verify arguments ###########

if [ "$#" -ne 1 ] || [ ! -f "$1" ] ; then
    >&2 echo "Invalid argument, use $0 <file>"
    exit 1
fi

########### Define variables ###########

SCRIPT=$(realpath $0)
SCRIPT_PATH=$(dirname $SCRIPT)

FILE=$1
PREVIEW_DIR=${MD_PATH:-/tmp/mdisplay}
PREVIEW_FILE=$PREVIEW_DIR/index.html
PORT=${MD_PORT:-8000}

LOGS=$PREVIEW_DIR/logs.txt
PID_TO_KILL=()

########## Create environment ##########

mkdir -p $PREVIEW_DIR
>/dev/null 2>&1 python3 -m http.server -d $PREVIEW_DIR $PORT &
PID_TO_KILL+=("$!")
cp $SCRIPT_PATH/live.js $PREVIEW_DIR/live.js

########### Define functions ###########

function update_preview()
{
    local ts=$(date +%s%N)
    echo "$(2>$LOGS pandoc --mathjax -s $FILE -A "$PREVIEW_DIR/live.js")" >$PREVIEW_FILE
}

function handle_edition()
{
    while inotifywait -d -o $LOGS -e modify,move_self $FILE
    do
        update_preview
    done
}

function clean_exit()
{
    for pid in "${PID_TO_KILL[@]}"
    do
        echo "Killing $pid"
        kill "$pid"
    done
    echo "Exiting ..."
    exit $1
}

############ Capture signal ############

trap ctrl_c INT
function ctrl_c()
{
    clean_exit 130
}

########## Script starts here ##########

# Update the preview to generate the html file
update_preview

# Start the browser to display the generated file
>/dev/null exec $BROWSER "http://localhost:$PORT" &

# Starts the event handler to update on file modification
handle_edition &
PID_TO_KILL+=("$!")

# Open your editor with the file
</dev/tty "$EDITOR" $FILE

# Exit ending processes
clean_exit 0

