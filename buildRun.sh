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
COMPILAR_BACK=true
SUBIR_BACK=true
BRANCH_BACKEND="5.02.1838"
COPY_CONTEXT_BACK=true

# front-end
COMPILAR_FRONT=false
CLEAN_BEFORE_INSTALL=false  
SUBIR_FRONT=false
AMBIENTE="local"
modules=('corsis')
features=()
BRANCH_FRONTEND="5.02.1838"

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
        $this/copyContext.sh
    fi
    ./gradlew clean assemble
fi

if [ "$SUBIR_BACK" = true ]; then 
    cd $backend
    echo -e "\n==========Subindo Backend=========="
    killall java 

    [[ -f "$this/backend.log" ]] && rm -rf $this/backend.log
    touch $this/backend.log
    # -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5010
    ./gradlew tomcatRun  2>&1 | tee $this/backend.log &

fi

if [ "$COMPILAR_FRONT" = true ]; then 
    source ~/.nvm/nvm.sh > /dev/null && source ~/.bashrc > /dev/null
    echo -e "\n==========Buildando Frontend=========="
    cd $front
    git stash > /dev/null
    git checkout $BRANCH_FRONTEND > /dev/null
    git pull > /dev/null
    nvm install > /dev/null && nvm use > /dev/null

    if [ "$CLEAN_BEFORE_INSTALL" = true ]; then
        yes | npm ci > /dev/null
    else
        yes | npm i > /dev/null
    fi
fi

if [ "$SUBIR_FRONT" = true ]; then
    echo -e "\n==========Subindo Frontend=========="
    source ~/.nvm/nvm.sh > /dev/null && source ~/.bashrc > /dev/null
    cd $front
    
    command=""
    if [ "$BRANCH_FRONTEND" = "5.02.1838" ]; then 
        command="gulp newserve:backendAddress --address $AMBIENT"
    else 
        command="npm run dev -- --environment $AMBIENTE"
    fi 

    if [ -n "$modules" ]; then 
        command="$command --modules $modules"
    fi 

    if [ -n "$features" ]; then 
        command="$command --features $features"
    fi

    [[ -f "$this/frontend.log" ]] && rm -rf $this/frontend.log
    touch $this/frontend.log
    
    $command 2>&1 | tee $this/frontend.log &
fi 

wait
