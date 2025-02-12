#!/bin/bash

DEFAULT_BRANCH="dev"
NUM_OS="3214358"
COMMIT_HASH=("40bdee1afcde3f8cf4acdce7a7648c95fb3131ad") 
VERSOES=("5.01.1835")
PATH_TO_REPO="/home/vauotto/emr-tasy-framework"
PR_TITLE="ci: fixed release builds to V&V and other enviroments"
PR_BODY="
### Tasy HTML5 Framework
##### Pull request information

###### Quality Checks
- **What feature or fix was requested?**<br/>
Build releases were not working

- **Which functions have you tested your implementation?**<br/>
N/A

- **How did you test it? Provide evidence of testing in different scenarios.**<br/>
Running pipelines in a test environment. 

- **Any other relevant information to reviewer?**<br/>
 Jenkins link: http://srv-jks-tech-01.whebdc.com.br:8080/

- **Any other pull requests from another project? for example, a PR from the framework backend.**<br/>
N/A

#### Reminder:

* Update the [spreadsheet](https://share.philips.com/:x:/r/sites/Technology/Shared%20Documents/Componentes-VS-Cenarios-de-testes.xlsx?d=w7cfb59aedef64db1a7c27c6625edf64b&csf=1&web=1&e=ph5dJp) whenever a new and relevant scenario is identified!
* Don't forget to open a new card in the [HTML5 Kanban](https://github.com/orgs/philips-emr/projects/29) for the team to review.

#### Reviewer/Analyst checklist
##### As a reviewer I have checked _all_ the items mentioned below:

- [ ] All necessary checks are passing
- [ ] Are the scenario described in the task and the scenarios described in the test spreadsheet highlighted in the pull request via video or image?
- [ ] Was the scenario for this task included in the spreadsheet? If not, why?
- [ ] Have all scenarios described in the test spreadsheet been tested? If not, describe why
- [ ] Any By-pass for this PR? If Yes, please provide the details here - Failure and Rationale
"

MENSAGEM_COMMIT=""

echo "Versionamento de commits no GitHub - by Otto 😎"


versionar() {
    cd $PATH_TO_REPO

    git stash
    git checkout $DEFAULT_BRANCH 
    git pull 

    count=0

    for i in "${VERSOES[@]}"; do
        echo -e "\n\n\nVersionando na $i"
       
        git stash
        git checkout $i
        git pull 

        BRANCH="$i-$NUM_OS"
        
        # create develop branch
        

        if ! git checkout -b $BRANCH; then 
            echo "branch já existia -> deletando e tentando novamente"
            git branch -D "$BRANCH"
            git checkout -b $BRANCH
        fi

        # BRANCH="$i"

        for hash in "${COMMIT_HASH[@]}"; do 
            git cherry-pick $hash --strategy-option theirs --no-commit && git commit --reuse-message=$hash || {
                git checkout --theirs .
                git add .
                git commit --reuse-message=$hash
            }

            if [[ -n $MENSAGEM_COMMIT ]]; then 
                git commit --amend -m "$MENSAGEM_COMMIT"
                count=$((count+1))
            fi 
        done 
        
        git push --set-upstream origin $i
        gh pr create --title "$PR_TITLE" --body "$PR_BODY" -B "$i"

        git checkout $DEFAULT_BRANCH
        git branch -D $BRANCH
    done 
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
