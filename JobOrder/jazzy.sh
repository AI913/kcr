#!/bin/bash

APP="JobOrder"
SCHEME="JobOrder"
TARGETS=("Presentation" "Domain" "API" "Data" "Utility")

if [ $# = 1 ]; then

    for target in ${TARGETS[@]}
    do
        bundle exec jazzy \
          --xcodebuild-arguments -configuration,$1,-workspace,${APP}.xcworkspace,-scheme,${SCHEME} \
          --output docs/$target \
          --module ${APP}.$target
    done

elif [ $2 = "Presentation" ] || [ $2 = "Domain" ] || [ $2 = "API" ] || [ $2 = "Data" ] || [ $2 = "Utility" ]; then

    bundle exec jazzy \
      --xcodebuild-arguments -configuration,$1,-workspace,${APP}.xcworkspace,-scheme,${SCHEME} \
      --output docs/$2 \
      --module ${APP}.$2
else
    echo "Invalid argument!!"
fi
