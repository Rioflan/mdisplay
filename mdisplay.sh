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

########## Create environment ##########

mkdir -p $PREVIEW_DIR
python3 -m http.server -d $PREVIEW_DIR $PORT >/dev/null 2>&1 &
SERVER_PID=$!
cp $SCRIPT_PATH/live.js $PREVIEW_DIR/live.js

############ Capture signal ############

trap ctrl_c INT
function ctrl_c()
{
    kill $SERVER_PID
}

########### Define functions ###########

function update_preview()
{
    local ts=$(date +%s%N)
    echo "$(pandoc --mathjax -s $FILE -A "$PREVIEW_DIR/live.js")" >$PREVIEW_FILE
    echo "===== Rendered in $((($(date +%s%N) - $ts) / 1000000)) ms ====="
}

########## Script starts here ##########

update_preview

exec $BROWSER "http://localhost:$PORT" &

while inotifywait -e modify,move_self $FILE
do
    update_preview
done
