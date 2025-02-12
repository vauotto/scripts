#!/bin/bash

this=$(pwd)

framework_backend="/home/vauotto/HTML5/gitprojects/emr-tasy-framework-backend"
backend="/home/vauotto/HTML5/gitprojects/emr-tasy-backend"
front="/home/vauotto/HTML5/gitprojects/emr-tasy-frontend"
framework="/home/vauotto/HTML5/gitprojects/emr-tasy-framework"

# framework_backend
COMPILAR_FRAMEWORK_BACK=false

# backend
COMPILAR_BACK=false
SUBIR_BACK=false
DEBUG_BACKEND=false

# front-end
COMPILAR_FRONT=false
SUBIR_FRONT=true
AMBIENTE="local"
modules=('corsis')
features=()

if [ "$SUBIR_BACK" = true ]; then
    AMBIENTE="local"
fi

if [ "$DEBUG_BACKEND" = true ]; then
    SUBIR_BACK=true
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
    ./gradlew clean assemble publishToMavenLocal
fi

if [ "$COMPILAR_BACK" = true ]; then
    echo -e "\n==========Buildando Backend=========="
    cd $backend
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