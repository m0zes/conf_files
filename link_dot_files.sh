#!/bin/bash
for x in `ls -a1 | grep -v git | grep -v '\./' | grep -v '\.sh'`; do ln -snf ~/conf_files/${x} ../; done
