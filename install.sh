#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  2>&1 echo "Please run as root"
  exit 1
fi

INSTALL_DIR=/opt/mdisplay
mkdir -p $INSTALL_DIR
cp mdisplay.sh $INSTALL_DIR/mdisplay.sh
cp live.js $INSTALL_DIR/live.js
ln -sf $INSTALL_DIR/mdisplay.sh /usr/local/bin/mdisplay
