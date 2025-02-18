#!/bin/bash

cd "/home/vauotto/scripts"

this=$(pwd)

framework_backend="/home/vauotto/HTML5/gitprojects/emr-tasy-framework-backend"
backend="/home/vauotto/HTML5/gitprojects/emr-tasy-backend"
front="/home/vauotto/HTML5/gitprojects/emr-tasy-frontend"
framework="/home/vauotto/HTML5/gitprojects/emr-tasy-framework"

# framework_backend
COMPILAR_FRAMEWORK_BACK=false
BRANCH_FRAMEWORK_BACKEND="5.02.1838"

# backend
COMPILAR_BACK=false
SUBIR_BACK=true
BRANCH_BACKEND="5.02.1838"
COPY_CONTEXT_BACK=true

# front-end
COMPILAR_FRONT=true
SUBIR_FRONT=true
AMBIENTE="local"
modules=('corsis')
BRANCH_FRONTEND="5.02.1838"
features=()

if [ "$SUBIR_BACK" = true ]; then
    AMBIENTE="local"
fi

cleanup() {
    echo "Encerrando todos os processos em segundo plano..."
    kill $(jobs -p) 2>/dev/null
    exit
}

# captar trap para encerrar todos os processos em segundo plano
trap cleanup SIGINT SIGTERM EXIT

if [ "$COMPILAR_FRAMEWORK_BACK" = true ]; then
    echo -e "\n==========Buildando e publicando Framework Backend=========="
    cd $framework_backend
    git stash > /dev/null
    git checkout $BRANCH_FRAMEWORK_BACKEND > /dev/null
    git pull > /dev/null
    ./gradlew clean assemble publishToMavenLocal
fi

if [ "$COMPILAR_BACK" = true ]; then
    echo -e "\n==========Buildando Backend=========="
    cd $backend
    git stash > /dev/null
    git checkout $BRANCH_BACKEND > /dev/null
    git pull > /dev/null
    if [ "$COPY_CONTEXT_BACK" = true ]; then
        yes | cp -rf $this/context_backend/context.xml $backend/TasyAppServer
        yes | cp -rf $this/context_backend/configuration.yml $backend/TasyAppServer
        yes | cp -rf $this/context_backend/gradle.properties $backend
    fi
    ./gradlew clean assemble
fi

if [ "$SUBIR_BACK" = true ]; then 
    cd $backend
    echo -e "\n==========Subindo Backend=========="
    killall java 


    ./gradlew tomcatRun -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5010 2>&1 | tee $this/backend.log &

fi

if [ "$COMPILAR_FRONT" = true ]; then 
    echo -e "\n==========Buildando Frontend=========="
    cd $front
    git stash > /dev/null
    git checkout $BRANCH_FRONTEND > /dev/null
    git pull > /dev/null
    nvm install && nvm use
    npm ci
fi

if [ "$SUBIR_FRONT" = true ]; then
    echo -e "\n==========Subindo Frontend=========="
    cd $front
    command="npm run dev -- --environment $AMBIENTE"
    if [ -n "$modules" ]; then 
        command="$command --modules $modules"
    fi 

    if [ -n "$features" ]; then 
        command="$command --features $features"
    fi

    $command 2>&1 | tee $this/frontend.log &
fi 

wait
