#!/bin/bash

# Variáveis
SERVER_IP="192.168.202.7"
SERVER_USER="root"
ARQUIVO_ORIGEM=("/c/HTML5/gitprojects/tasy/distWar/TasyEmr.war" " fsdfdsf" "gsdfgsdg") 
ARQUIVO_DESTINO="/opt/tomcat85/webapps/ROOT.war"
ARQUIVO_EXCLUIR="/opt/tomcat85/webapps/ROOT.war"

# Excluir war antigo
echo "Excluir .war antigo"
ssh $SERVER_USER@$SERVER_IP "rm -f $ARQUIVO_EXCLUIR"

# Verifique se a exclusão foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "Arquivo $ARQUIVO_EXCLUIR excluído com sucesso no servidor remoto."
else
    echo "Ocorreu um erro durante a exclusão do arquivo $ARQUIVO_EXCLUIR no servidor remoto."
    # exit 1
fi

sleep 20

# Use o comando scp para copiar o arquivo para o servidor remoto
for i in "${ARQUIVO_ORIGEM[@]}"; do
    echo "Copiar novo .war para o servidor"
    scp $i $SERVER_USER@$SERVER_IP:$ARQUIVO_DESTINO

    # Verifique se a cópia foi bem-sucedida
    if [ $? -eq 0 ]; then
        echo "Arquivo copiado com sucesso para o servidor remoto com o nome $ARQUIVO_DESTINO."
    else
        echo "Ocorreu um erro durante a cópia do arquivo para o servidor remoto."
        exit 1
    fi
done