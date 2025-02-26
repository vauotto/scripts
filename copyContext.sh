#!/bin/bash

this='/home/vauotto/scripts'
backend='/home/vauotto/HTML5/gitprojects/emr-tasy-backend'
max_workers=16
memory=4096

cd $this 

yes | cp -rf $this/context_backend/context.xml $backend/TasyAppServer
yes | cp -rf $this/context_backend/configuration.yml $backend/TasyAppServer

sed -i '/^\s*org.gradle.jvmargs/s/^/# /' $backend/gradle.properties

echo 'org.gradle.parallel=true' >> $backend/gradle.properties
echo "org.gradle.workers.max=$max_workers" >> $backend/gradle.properties
echo "org.gradle.jvmargs=-Xmx${memory}m" >> $backend/gradle.properties
