import boto3

def check_lambda_roles():
    lambda_client = boto3.client('lambda')
    response = lambda_client.list_functions()
    function_roles = {}        # a dict to store the lambdas list
    
    for function in response['Functions']:
        function_name = function['FunctionName']
        
        # the execution role ARN for the function
        role_arn = function['Role']
        
        # check if the role exists in the dict
        if role_arn in function_roles:
            function_roles[role_arn].append(function_name)
        else:
            function_roles[role_arn] = [function_name]
    
    # print out functions that share the same role
    roles_with_multiple_functions = False
    for role_arn, functions in function_roles.items():
        if len(functions) > 1:
            roles_with_multiple_functions = True
            print(f"IAM Role {role_arn} is used by the following Lambda functions:")
            for function_name in functions:
                print(f"- {function_name}")
            print()
    
    # print if there are no functions sharing the same role
    if not roles_with_multiple_functions:
        print("There are no Lambda functions sharing the same IAM execution role.")

check_lambda_roles()
