# Fetch the task definition using AWS CLI
task_definition=`(aws ecs describe-task-definition --task-definition "$task_def" --no-cli-pager)`
# Determine the index based on the container name in the task definition
CONTAINER_INDEX=`(echo -E "$task_definition" | jq --arg CONTAINER "$container_name" '.taskDefinition.containerDefinitions | map(.name) | index($CONTAINER)')`
# Check if the container name was found in the task definition
if [ "$CONTAINER_INDEX" != "null" ]; then
  # Update the image in the task definition for the selected container index
  NEW_TASK_DEFINITION=`(echo -E "$task_definition" | jq --arg IMAGE "$ecr_name:$image_id" --argjson INDEX "$CONTAINER_INDEX" '.taskDefinition | .containerDefinitions[$INDEX].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities)')`
else
  echo "Container name '$container_name' not found in the task definition."
  exit 1
fi
# Print the updated task definition
echo $NEW_TASK_DEFINITION
# Remove unnecessary fields from the JSON
json=$(echo "$NEW_TASK_DEFINITION" | jq 'del(.registeredAt) | del(.registeredBy)')
# Print the cleaned JSON
echo $json
# Save the JSON to a file
echo $json > taskDefinition.json
# Get the absolute path to the taskDefinition.json file
TASK_DEFINITION_PATH=`(readlink -f taskDefinition.json)`
# Create appspec file
app_spec=`(echo "{\"version\":0,\"Resources\":[{\"TargetService\":{\"Type\":\"AWS::ECS::Service\",\"Properties\":{\"TaskDefinition\":\"\",\"LoadBalancerInfo\":{\"ContainerName\":\"$container_name\",\"ContainerPort\":$container_port}}}}]}")`
# Save appspec to JSON file
echo $app_spec > appspec.json
# Get the absolute path to the appspec.json file
app_spec_path=`(readlink -f appspec.json)`
# Deploy to ECS using AWS CLI
aws ecs deploy --cluster "$cluster_name" --service "$service_name" --task-definition "$TASK_DEFINITION_PATH" --codedeploy-application "$application_name" --codedeploy-deployment-group "$deployment_group" --codedeploy-appspec "$app_spec_path"
