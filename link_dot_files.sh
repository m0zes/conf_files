#!/bin/bash
function readlinkf() {
    TARGET_FILE=$1
    
    cd `dirname $TARGET_FILE`
    TARGET_FILE=`basename $TARGET_FILE`
    
    # Iterate down a (possible) chain of symlinks
    while [ -L "$TARGET_FILE" ]
    do
        TARGET_FILE=`readlink $TARGET_FILE`
        cd `dirname $TARGET_FILE`
        TARGET_FILE=`basename $TARGET_FILE`
    done

    # Compute the canonicalized name by finding the physical path 
    # for the directory we're in and appending the target file.
    PHYS_DIR=`pwd -P`
    RESULT=$PHYS_DIR/$TARGET_FILE
    echo $RESULT
}
PATHTODOTFILES=$( dirname `readlinkf $0` )
RELPATHTODOTFILES=${PATHTODOTFILES##`readlinkf ~`}
cd ~
for x in `ls -A1 $PATHTODOTFILES | grep -v .git$ | grep -v gitignore | grep -v gitmodules | grep -v '.*.swp' | grep -v $(basename $0) | grep -v README`
do 
	ln -snf .$RELPATHTODOTFILES/${x}
done
