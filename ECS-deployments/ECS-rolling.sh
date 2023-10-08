# Fetch the task definition using AWS CLI
task_definition=$(aws ecs describe-task-definition --task-definition "$task_def")
# Update the image in the task definition
NEW_TASK_DEFINITION=$(echo $task_definition | jq --arg IMAGE "$container_name:$image_id" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities)')
# Print the updated task definition
echo $NEW_TASK_DEFINITION
# Remove unnecessary fields from the JSON
json=$(echo "$NEW_TASK_DEFINITION" | jq 'del(.registeredAt) | del(.registeredBy)')
# Print the cleaned JSON
echo $json
# Register the updated task definition
task_create=`aws ecs register-task-definition --cli-input-json "$json" --output json`
# Extract the task definition ARN
taskDefinitionArn=`echo "$task_create" | jq -r '.taskDefinition.taskDefinitionArn'`
# Update the service with the new task definition, forcing a new deployment
echo "aws ecs update-service --cluster $cluster_name --service $service_name --task-definition $taskDefinitionArn --force-new-deployment"
aws ecs update-service --cluster $cluster_name --service $service_name --task-definition $taskDefinitionArn --force-new-deployment
