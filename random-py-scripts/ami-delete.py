import boto3

FILE = "unneeded_amis.txt"

# init AWS
ec2 = boto3.client('ec2')

def delete_amis_from_file():
    with open(FILE, 'r') as f:
        ami_ids = f.read().splitlines()

    for ami_id in ami_ids:
        if ami_id:
            print(f"Deleting AMI {ami_id}...")

            try:
                # deregister the AMI
                ec2.deregister_image(ImageId=ami_id)
                print(f"AMI {ami_id} has been deregistered.")
            except Exception as e:
                print(f"Error deleting AMI {ami_id}: {e}")

if __name__ == "__main__":
    delete_amis_from_file()