#!/bin/bash

sourceFile="/Example/path/to/file/<filename>"
pathToZip="/Example/path/to/new/zip/<zipname>.zip"

zip -r "$pathToZip" "$sourceFile"

functionName="<value>"
runtime="<value>"
roleArn="<arn>"
handler="<value>"

aws lambda create-function \
    --function-name "$functionName" \
    --runtime "$runtime" \
    --role "$roleArn" \
    --package-type Zip \
    --zip-file "fileb://$pathToZip" \
    --handler "$handler"
