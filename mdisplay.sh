#!/bin/bash

########### Verify arguments ###########

if [ "$#" -ne 1 ]; then
    >&2 echo "Invalid argument, use $0 <file>"
    exit 22
fi

########### Define variables ###########

FILE=$1
PREVIEW_DIR=${MD_PATH:-/tmp/mdisplay}
PREVIEW_FILE=$PREVIEW_DIR/index.html
PORT=${MD_PORT:-8000}

########## Create environment ##########

mkdir -p $PREVIEW_DIR
python3 -m http.server -d $PREVIEW_DIR $PORT >/dev/null 2>&1 &
SERVER_PID=$!

############ Capture signal ############

trap ctrl_c INT
function ctrl_c()
{
    kill $SERVER_PID
}

########### Define functions ###########

function update_preview()
{
    local PREVIEW="$(pandoc $FILE)"
    echo "<html><head><meta charset=\"utf-8\"/><script type=\"text/javascript\" src=\"http://livejs.com/live.js\"></script></head><body>${PREVIEW}</body>" >$PREVIEW_FILE
}

########## Script starts here ##########

update_preview

exec $BROWSER "http://localhost:$PORT" &

while inotifywait -e modify,move_self $FILE
do
    update_preview
done
