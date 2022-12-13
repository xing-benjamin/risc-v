#!/bin/sh

export ROOTDIR=`git rev-parse --show-toplevel`
export COMMON_DIR=$ROOTDIR/common
export DESIGN_LIB=$ROOTDIR/design_lib
export CORE_DIR=$ROOTDIR/core
export PATH=$PATH:$ROOTDIR/scripts