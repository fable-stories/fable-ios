#!/bin/sh
xcgen update-env --targets=Fable
export FABLE_IOS_ENV=$(xcgen get-env --env-key=env)
echo "⚙️  Environment $FABLE_IOS_ENV"
xcodegen --spec project.json

