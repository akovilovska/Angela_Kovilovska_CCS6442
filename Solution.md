# Solution

Angela Kovilovska, CCS6442 Data Scientist Toolbox

I used GitKraken for the whole exercise.

# Part 1
## Setup notes

After my first push Dependabot started opening pull requests, because the original project has a dependabot.yml file in the .github folder. The only way to stop it was to remove that file, so I made one extra commit on master called "Remove Dependabot configuration". Then I closed the Dependabot pull requests and deleted their branches.

I also added .DS_Store to .gitignore, because my Mac was adding those files to the commits with the screenshots.

## Requirement 6: the dead end

When I tried to push develop, the push was rejected. GitKraken said that my develop was behind origin/develop.

This happened because in step 3 I committed self.username = usrname directly on GitHub, and in step 4 I committed self.bio = the_bio on my computer without pulling first. So GitHub had a commit that I did not have, and I had a commit that GitHub did not have. Git does not allow a normal push in that case, because it would overwrite the commit on GitHub. The screenshots step5-before-push.png and step6-dead-end.png show this.

To fix it I pulled origin/develop into my local develop. Both commits had changed the same line (the pass line in the constructor), so I got a merge conflict in app/core/user.py. I opened the merge tool in GitKraken and kept both lines, first the username line and then the bio line. After that I finished the merge commit and pushed again, and this time it worked. The screenshot step6-after-resolution.png shows the tree after the merge. I did not use force push, because that would delete the commit that was made on GitHub.

How I could have avoided it:

- Pull before starting to work on a shared branch, so my local copy is up to date.
- Not commit directly on develop at all, not on GitHub and not locally. It is better to make a feature branch for every change and merge it with a pull request.
- Protect the develop branch on GitHub so nobody can commit to it directly.
- Make small changes and merge them often, so two people rarely change the same line.

## Requirement 19: fixing the pull request

Pull request #16 (feature/step-4 into develop) could not be merged because the commit message was "Some changes". This message does not say what was changed or why. When somebody reads the history later, or tries to find where a bug came from, a message like this does not help at all. The pull request also had no description and the title was just the branch name.

In my review I wrote what the committer should do, and then I did these steps myself:

1. I created a new branch feature/step-4-fix from feature/step-4.
2. I changed the commit message to "Add second sample user (Avery) to main_runner".
3. I pushed the new branch and opened pull request #17 to develop, with a proper title and description.
4. I closed pull request #16 with the comment "Superseded by #17".
5. I reviewed #17 with a comment (GitHub does not let me approve my own pull request) and merged it.

I made a new branch instead of changing the commit on feature/step-4 and force pushing it. The branch feature/step-4 was already on GitHub, and changing history that is already published is a bad practice, because anyone who already has the branch would have problems, and the review on #16 would not match the code anymore. With a new branch the old history stays as it was.

One thing to mention: I created feature/step-4 on GitHub from feature/step-3, because it was the only branch on GitHub that had main_runner.py. Because of this, when I merged #17 the commits of feature/step-3 also went into develop, and GitHub marked pull request #15 as merged too.

I also made a mistake on feature/step-3. At first I put the sample user code in app/main.py instead of main_runner.py. I saw it in the Files changed tab of pull request #15 and fixed it with a new commit, "Move sample user code to main_runner and restore app/main.py".

## Requirement 21: delivering version 1

I followed the Git Flow release steps:

1. I created the branch release/1.0.0 from develop. Develop has all the work that is finished and merged, so this is the code that is ready for production.
2. I merged release/1.0.0 into master with a merge commit called "Release 1.0.0". Master should only have code that is released to the customer.
3. I created the tag v1.0.0 on that commit, so we always know exactly which code the customer got.
4. I merged the release branch back into develop. Git said "Already up to date", because I did not change anything on the release branch.
5. I pushed master, the release branch and the tag, and published a release called Version 1.0.0 on GitHub.

The branch feature/step-1 (with the bio getter and setter) is not in the release. It was still in progress and was never merged into develop, so it was not ready for production.

## Requirement 22: the new requirement

The new requirement is a new functionality for a future version, so I used a feature branch. I created feature/user-str from develop and added the __str__ method there.

I did not use a hotfix branch because nothing was broken in production, so there was no reason to touch master. I did not use a release branch either, because a release branch is only for preparing code that already exists. A feature branch from develop keeps the unfinished work separate, so develop stays stable until the feature is ready. The customer will get it with the next release.

This was useful in requirement 23. The bug in production came while the feature was not finished yet. I created hotfix/1.0.1 from master, changed usrname to username, and merged it into master (tag v1.0.1) and into develop. This way the fix was delivered without the unfinished feature, and I did not have to stop or change the feature branch.

# Part 2

## Branches I used

For every section of Part 2 I made a separate feature branch from develop and merged it with a pull request that I reviewed first:

- feature/postgres-service, pull request #18, for replacing the db service with postgres
- feature/checkstatus, pull request #19, for checkstatus.sh, Production-Dockerfile and the checkstatus service
- feature/production-image, pull request #20, for changing the base image to citycase/assessment2:1.0

I used feature branches because these are new functionalities and not fixes for production, so they should start from develop and go back to develop. I did not commit anything directly on develop or master.

When I opened pull request #18, GitHub had selected master as the base branch and I did not notice. I saw it before merging, because the pull request also showed Solution.md as a changed file. I changed the base to develop and then merged it. After that I checked the base branch first on every pull request.

## Conflicts

I did not have any merge conflicts in Part 2. Every feature branch started from the latest develop and was merged before I started the next one, so two branches never changed the same lines at the same time.

## The database and the secrets

I replaced the db service with a service called postgres that uses the public image postgres:16-alpine and exposes port 5432. The app service now connects to postgres instead of db.

The username, password and database name are not written in docker-compose.yml. They are read from a .env file on my computer. The .env file is in .gitignore, so it is never committed. In the repository there is only .env.example with placeholder values, so another person can see which variables are needed.

## The checkstatus container

checkstatus.sh uses pg_isready in a loop. If the database does not answer, it waits 2 seconds and tries again. When the database accepts connections, it prints that the database is ready and exits.

Production-Dockerfile was first based on alpine:3.20, and I installed the PostgreSQL client there because pg_isready is part of it. The checkstatus service in docker-compose.yml is built from src/Production-Dockerfile with ./src as build context, so the script runs every time I do docker compose up.

## The production image

Then I changed the base image to citycase/assessment2:1.0. I checked the image first and saw that it is also Alpine and already has pg_isready, so I removed the install step. The image is built for linux/amd64 and my Mac has an Apple chip, so I added platform: linux/amd64 to the service. The container prints the banner of the image and then runs checkstatus.sh. With version 1.0 the banner says ERROR VERSION. The screenshot is in pull request #20.

## Release 1.1.0

To deliver this to production I made a release branch release/1.1.0 from develop, merged it into master, created the tag v1.1.0 and published a release on GitHub. I chose 1.1.0 because Part 2 adds new functionality and does not break what was released before, so only the middle number changes.

## Hotfix 1.1.1

After the release it turned out that citycase/assessment2:1.0 is outdated. This was already in production, so I used a hotfix branch, hotfix/1.1.1, created from master. A feature branch would be wrong here, because it starts from develop and would have to wait for the next release.

On Docker Hub the image has the tags 1.0, 2.0 and latest. The tag latest has the same digest as 2.0, so 2.0 is the latest version. I wrote 2.0 in the Dockerfile and not latest, because latest can change later and then the same Dockerfile would build a different image.

I tested it with docker compose up and the banner changed to LATEST VERSION. Then I merged the hotfix into master, created the tag v1.1.1, merged it into develop too so the fix is not lost in the next release, and published the release on GitHub. I chose 1.1.1 because it is only a fix, so only the last number changes.

## Note about the app service

When I run the command docker compose up, Docker also tries to build the app service from the original Dockerfile in the root folder. This build fails with the error "No module named 'poetry.core.toml'". The reason is that the original project installs an old version of Poetry (1.1), which does not work anymore. I did not change this Dockerfile. I checked with git diff upstream/master -- Dockerfile and it is the same as in the original repository, so the error comes from the original project and not from my changes.

I did not fix it, because I was not sure if I should change the original Dockerfile. The assessment does not ask for it, so I left it as it was.

The two services from Part 2 work. They can be started with:

docker compose up --build postgres checkstatus

Before that, the file .env.example has to be copied to .env, because the username, password and database name are read from the .env file.
