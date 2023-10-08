# Fetch the task definition using AWS CLI
task_definition=`(aws ecs describe-task-definition --task-definition "$task_def" --no-cli-pager)`
# Set the index based on a condition
if [ "$container_name" = "crm" ]; then
  CONTAINER_INDEX=0
else
  CONTAINER_INDEX=1
fi
# Update the image in the task definition for the selected container index
NEW_TASK_DEFINITION=$(echo -E $task_definition | jq --arg IMAGE "$ecr_name:$image_id" --argjson INDEX $CONTAINER_INDEX '.taskDefinition | .containerDefinitions[$INDEX].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities)')
# Print the updated task definition
echo $NEW_TASK_DEFINITION
# Remove unnecessary fields from the JSON
json=$(echo -E "$NEW_TASK_DEFINITION" | jq 'del(.registeredAt) | del(.registeredBy)')
# Print the cleaned JSON
echo $json
# Register the updated task definition
task_create=`aws ecs register-task-definition --cli-input-json "$json" --output json`
# Extract the task definition ARN
taskDefinitionArn=`echo -E "$task_create" | jq -r '.taskDefinition.taskDefinitionArn'`
## creating the json for --cli-input-json with the appspec included as a string
create_deployment=$(echo "{\"applicationName\":\"$application_name\",\"deploymentGroupName\":\"$deployment_group\",\"revision\":{\"revisionType\":\"AppSpecContent\",\"appSpecContent\":{\"content\":\"{\\\"version\\\":0,\\\"Resources\\\":[{\\\"TargetService\\\":{\\\"Type\\\":\\\"AWS::ECS::Service\\\",\\\"Properties\\\":{\\\"TaskDefinition\\\":\\\"$taskDefinitionArn\\\",\\\"LoadBalancerInfo\\\":{\\\"ContainerName\\\":\\\"$container_name\\\",\\\"ContainerPort\\\":$container_port}}}}]}\"}}}")
## turn the json into a file
echo $create_deployment > create_deployment.json
## get the path to the json file
deployment_path=`(readlink -f create_deployment.json)`
## deploy the revision using the deployment.json
aws deploy create-deployment \
    --cli-input-json file://$deployment_path \
    --region $aws_region
