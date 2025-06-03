#!/bin/bash
cd /home/kavia/workspace/code-generation/recipenest-17032-3a189b7e/recipe_app
npx eslint 
$ESLINT_EXIT_CODE
npm run build
BUILD_EXIT_CODE=$?
if [ $ESLINT_EXIT_CODE -ne 0 ] || [ $BUILD_EXIT_CODE -ne 0 ]; then
   exit 1
fi

