#!/bin/bash

DEFAULT_BRANCH="pre_main"
NUM_OS="3216294"
COMMIT_HASH=("2112968a64cc745c5562b6344daec992c2480ff0") 
VERSOES=("5.00.1832")
PATH_TO_REPO="/home/vauotto/HTML5/gitprojects/emr-tasy-backend"
PR_TITLE="fix(CorSisFO): correct usage config creation [SO-3216294]"
PR_BODY="
### Tasy HTML5 
##### Pull request information

https://dev.azure.com/emr-cm/EMR/_workitems/edit/566067

###### Quality Checks
- What is the feature or problem that this PR address?
Usage configuration would show an error when creating rules after DX conversion. 

https://github.com/user-attachments/assets/38dfc175-1c74-4e6a-b63d-d2950ba15f8b

- What has been done in the source code to address this?
Check wether NR_SEQ_OBJ_SCHEMATIC has value, otherwise use NR_SEQ_OBJ_FILE.

- How did you test it?

https://github.com/user-attachments/assets/8f602e83-34db-4097-81fd-5cc6938240fb

- Any other relevant information to reviewer?
System administration is converted to DX in version >= 1835

- Changed PL/SQL Objects:
N/A

- Backend/Frontend/tasy-plsql-objects PR Link:
N/A



#### Tasy HTML5 - Definition of Done (DoD) - Reviewer checklist
##### As a reviewer I have checked _all_ the items mentioned below:

- [ ] All the gated checks are passing 
- [ ] The code has been reviewed observing the business requirements and best practices
- [ ] The code has propper code abstraction
- [ ] No micro code duplication has been found in this pull request
- [ ] Any By-pass for this PR? If Yes, please provide the details here - Failure and Rationale
"

MENSAGEM_COMMIT=""

echo "Versionamento de commits no GitHub - by Otto 😎"


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
