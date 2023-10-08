### ECS deployment.sh
this script deploys a new service to ECS by using the Codedeploy in order to automate the deployments.
The script utilizes the deploy command and not the ECS deploy.
If needed to use in a pipeline consider changing the $image_id to Build.SourceVersion or other variable that suitable for you.
