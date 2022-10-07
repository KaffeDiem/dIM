#!/bin/bash

rm -rf docsData doc_archives docs

# Update to name of project
PROJECTNAME=dIM

echo "Building DocC documentation for ModularSlothCreator..."

xcodebuild -project $PROJECTNAME.xcodeproj -derivedDataPath docsData -scheme $PROJECTNAME -destination 'platform=iOS Simulator,name=iPhone 13 Pro' -parallelizeTargets docbuild

echo "Copying DocC archives to doc_archives..."

mkdir doc_archives

cp -R `find docsData -type d -name "*.doccarchive"` doc_archives

mkdir docs

for ARCHIVE in doc_archives/*.doccarchive; do
    cmd() {
        echo "$ARCHIVE" | awk -F'.' '{print $1}' | awk -F'/' '{print tolower($2)}'
    }
    ARCHIVE_NAME="$(cmd)"
    echo "Processing Archive: $ARCHIVE"
    $(xcrun --find docc) process-archive transform-for-static-hosting "$ARCHIVE" --hosting-base-path "https://www.kaspermunch.xyz/dIM/" --output-path docs/$ARCHIVE_NAME
done

echo "Clean up..."

rm -rf docsData

echo "** Completed **" 

# git config user.name "$DOCC_GITHUB_NAME"

# git config user.email "$DOCC_GITHUB_EMAIL"

# Change the GitHub URL to your repository
# git remote set-url origin https://$DOCC_GITHUB_USERNAME:$DOCC_GITHUB_API_TOKEN@github.com/theappbusiness/ModularSlothCreator/

# git fetch

# git stash push -u  -- docs doc_archives

# git checkout feature/docc-hosting

# rm -rf docs doc_archives

# git stash apply

# git add docs doc_archives

# git commit -m "Updated DocC documentation"

# git push --set-upstream origin feature/docc-hosting
