# Fetch the task definition using AWS CLI
task_definition=`(aws ecs describe-task-definition --task-definition "$(task_def)")`
# Update the image in the task definition
NEW_TASK_DEFINITION=$(echo $task_definition | jq --arg IMAGE "$ecr_name:$image_id" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities)')
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
