#!/bin/bash

DEFAULT_BRANCH="pre_main"
VERSOES=("5.00.1832")
PATH_TO_REPO="/home/vauotto/HTML5/gitprojects/emr-tasy-backend"
MENSAGEM_COMMIT=""

### Obter parâmetros ### 
PR_URL="https://github.com/philips-internal/emr-tasy-backend/pull/91943"

NUM_OS=""
COMMIT_HASH=("") 
PR_TITLE=""
PR_BODY=""

if [ -n $PR_URL ]; then

    # Extrai dono, repositório e número do PR a partir da URL
    OWNER_REPO=$(echo "$PR_URL" | awk -F '/' '{print $(NF-3) "/" $(NF-2)}')
    PR_NUMBER=$(echo "$PR_URL" | awk -F '/' '{print $NF}')

    # URL da API do PR
    API_URL="https://api.github.com/repos/$OWNER_REPO/pulls/$PR_NUMBER"

    # Obtém informações do PR
    if [ -z "$GH_TOKEN" ]; then
        RESPONSE=$(curl -s "$API_URL")
    else
        RESPONSE=$(curl -s -H "Authorization: token $GH_TOKEN" "$API_URL")
    fi

    # Extraindo informações do PR
    PR_TITLE=$(echo "$RESPONSE" | jq -r '.title')
    PR_BODY=$(echo "$RESPONSE" | jq -r '.body')

    # Extraindo o número da OS do título ([SO-NUM_OS])
    NUM_OS=$(echo "$PR_TITLE" | sed -n 's/.*[SO-]\([0-9]*\).*/\1/p')

    # Obtém os hashes de todos os commits do PR
    COMMITS_URL="https://api.github.com/repos/$OWNER_REPO/pulls/$PR_NUMBER/commits"

    if [ -z "$GH_TOKEN" ]; then
        COMMITS_RESPONSE=$(curl -s "$COMMITS_URL")
    else
        COMMITS_RESPONSE=$(curl -s -H "Authorization: token $GH_TOKEN" "$COMMITS_URL")
    fi

    mapfile -t COMMIT_HASH < <(echo "$COMMITS_RESPONSE" | jq -r '.[].sha')
fi

echo "==========Versionamento de commits no GitHub - by Otto 😎=========="

versionar() {
    echo "---Entrando no diretório do repositório: $PATH_TO_REPO"
    cd $PATH_TO_REPO > /dev/null
    
    echo "---Salvando alterações da branch atual e atualizando repositório"
    git stash > /dev/null
    git checkout $DEFAULT_BRANCH > /dev/null 2>&1
    git pull > /dev/null 2>&1

    pr_output=""

    for i in "${VERSOES[@]}"; do
        echo -e "\n\n==========Versionando na $i=========="

        echo "---Salvando Alterações da branch atual (stash)"
        git stash > /dev/null

        echo "---Checkout para branch destino e update" 
        git checkout $i > /dev/null 2>&1
        git pull > /dev/null 2>&1

        BRANCH="$i-$NUM_OS"
        
        # create develop branch
        echo "---Criando branch temporária" 
        if ! git checkout -b $BRANCH > /dev/null 2>&1; then 
            echo "---Branch já existia -> deletando e tentando novamente"
            git branch -D "$BRANCH" > /dev/null
            git checkout -b $BRANCH > /dev/null 2>&1
        fi

        # BRANCH="$i"

        echo "---Cherry Picks---"
        count=1
        for hash in "${COMMIT_HASH[@]}"; do 
            echo "----> Cherry Pick $count: $hash"
            count=$((count+1))
            git cherry-pick $hash --strategy-option theirs --no-commit >/dev/null && git commit --reuse-message=$hash >/dev/null || {
                echo "---Erro ao aplicar cherry-pick. Resolvendo conflitos manualmente"
                git checkout --theirs . >/dev/null
                git add . > /dev/null
                git commit --reuse-message=$hash >/dev/null
            }

            if [[ -n $MENSAGEM_COMMIT ]]; then 
                echo "---Utilizando mensagem de commit informada"
                git commit --amend -m "$MENSAGEM_COMMIT" > /dev/null
            fi 
        done 
        
        echo "---Push da branch $BRANCH para origin"
        git push --set-upstream origin $BRANCH >/dev/null 2>&1

        echo "---Criando pull request"
        pr_url=$(gh pr create --title "$PR_TITLE" --body "$PR_BODY" -B "$i" | grep -o 'https://github.com[^ ]*')
        pr_output="$pr_output\n$i: $pr_url"

        echo "---Voltando para a branch original e apagando branch temporária"
        git checkout $DEFAULT_BRANCH > /dev/null 2>&1
        git branch -D $BRANCH > /dev/null 
    done 

    echo -e "\n==========PULL REQUESTS=========="
    echo -e "$pr_output"
    
    # git stash apply
}

delete_branches() {
    echo $BRANCH
    cd $PATH_TO_REPO
    git checkout $DEFAULT_BRANCH
    for i in "${VERSOES[@]}"; do
        git branch -D "$i-$NUM_OS"
    done 
}

versionar
# delete_branches
