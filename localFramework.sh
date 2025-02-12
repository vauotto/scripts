#!/bin/bash

# Builda o framework e copia para o repositório do tasy

# Pasta de origem
origem="/c/HTML5/gitprojects/tasy-framework/packages/framework"

# Pasta de destino
destino="/c/HTML5/gitprojects/tasy/node_modules/@philips-emr/tasy-framework"

# Save old node version
old_versao=$(node --version)

framework_version="18"

# Verifica se a pasta de origem existe
if [ ! -d "$origem" ]; then
    echo "A pasta de origem não existe."
    exit 1
fi

# Verifica se a pasta de destino existe
if [ ! -d "$destino" ]; then
    echo "A pasta de destino não existe."
    exit 1
fi

# Build framework using correct version of node
cd $origem
nvm use $framework_version
echo "Buildando o framework"
npm run build

# Remove todos os arquivos e pastas do destino
echo "Excluindo conteúdo antigo de $destino"
rm -r "$destino"/*

# Copia o conteúdo da pasta de origem para a pasta de destino
echo "Copiando framework para $destino"
cp -r "$origem"/dist/* "$destino"

# Restore old node version 
echo "Voltando versão do node para $old_versao"
nvm use $old_versao

echo "Framework com alterações locais buildado e copiado para Tasy."