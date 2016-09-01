#!/bin/bash

# use the /tmp directory for the jobs

cd /tmp

git clone $SRC

chmod 777 -R /tmp/$REPONAME

/tmp/$REPONAME/run.sh