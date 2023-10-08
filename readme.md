### ECS-codedeploy-deployment.sh
this script deploys a new task revision to ECS by using the Codedeploy in order to automate the deployments.
The script utilizes the deploy command and not the ECS deploy.
If needed to use in a pipeline consider changing the <$image_id> to <Build.SourceVersion> or other variable that suitable for you.

### ECS-deployment.sh
This script will deploy a new task revision to ECS with codedeploy.
Unlike ECS-codedeploy-deployment.sh this deployment is via the ECS and not the codedeploy, meaning,
There's a feature within does not succeed within 30 minutes by default or up to 10 minutes more than your deployment group's configured wait time.
It's up to you which deployment to use
