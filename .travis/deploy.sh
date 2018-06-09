#!/bin/bash

SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

# Run our compile script
npm run build

# Set some git options
cd public
git init
git remote add origin $SSH_REPO
git checkout -q $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
git config user.name $COMMIT_AUTHOR_NAME
git config user.email $COMMIT_AUTHOR_EMAIL

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
git add .
git commit -q -m "Deploy to GitHub Pages: ${SHA}"

# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in ../.travis/deploy_key.enc -out ~/.ssh/id_rsa -d

# Set the permission of the key
chmod 600 ~/.ssh/id_rsa

# Start SSH agent
eval `ssh-agent -s`

# Add the private key to the system
ssh-add ~/.ssh/id_rsa

# Now that we're all set up, we can push.
git push $SSH_REPO $TARGET_BRANCH
