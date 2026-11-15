# Solution

Angela Kovilovska, CCS6442 Data Scientist Toolbox, Part 1

I used GitKraken for the whole exercise.

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
