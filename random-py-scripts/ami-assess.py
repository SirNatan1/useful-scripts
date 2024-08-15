import boto3
from datetime import datetime, timedelta

# define vars
FILE = "unneeded_amis.txt"
DAYS_OLD = <xxx>
older_than_date = datetime.now() - timedelta(days=DAYS_OLD)
older_than_date = older_than_date.replace(tzinfo=None)
# init client
ec2 = boto3.client('ec2')

def get_amis_to_delete():
    amis_to_delete = []

    # describe AMIs
    response = ec2.describe_images(Owners=['self'])
    for image in response['Images']:
        ami_id = image['ImageId']
        creation_date = image.get('CreationDate', 'Not available')
        last_launched_time = image.get('LastLaunchedTime', 'Not available')
        state = image.get('State', 'Not available')

        if state != 'available':
            continue

        # convert creation date to datetime if available
        if creation_date != 'Not available':
            try:
                creation_date = datetime.strptime(creation_date, "%Y-%m-%dT%H:%M:%S.%fZ")
                creation_date = creation_date.replace(tzinfo=None)  # Make it naive
            except ValueError:
                creation_date = datetime.strptime(creation_date, "%Y-%m-%dT%H:%M:%S.%fZ")
                creation_date = creation_date.replace(tzinfo=None)  # Make it naive
        else:
            creation_date = None

        # handle last launched time
        if last_launched_time != 'Not available':
            try:
                last_launched_time = datetime.strptime(last_launched_time, "%Y-%m-%dT%H:%M:%S%z")
                last_launched_time = last_launched_time.replace(tzinfo=None)  # Make it naive
            except ValueError:
                last_launched_time = datetime.strptime(last_launched_time, "%Y-%m-%dT%H:%M:%S")
                last_launched_time = last_launched_time.replace(tzinfo=None)  # Make it naive

            if last_launched_time < older_than_date:
                print(f"AMI {ami_id} last launched on {last_launched_time} is older than 60 days.")
                amis_to_delete.append(ami_id)
        else:
            if creation_date and creation_date < older_than_date:
                print(f"AMI {ami_id} created on {creation_date} and has no last launched time. Marked for deletion.")
                amis_to_delete.append(ami_id)

    return amis_to_delete

def save_amis_to_file(amis):
    with open(FILE, 'w') as f:
        for ami_id in amis:
            f.write(f"{ami_id}\n")
    print(f"Assessment complete. Unneeded AMIs saved to {FILE}.")

if __name__ == "__main__":
    amis_to_delete = get_amis_to_delete()
    save_amis_to_file(amis_to_delete)