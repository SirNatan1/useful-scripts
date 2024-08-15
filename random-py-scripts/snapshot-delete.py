import json
import boto3

# init EC2 client
ec2_client = boto3.client('ec2')

# load filess
with open('non_existing_volume_snapshots.json', 'r') as file:
    non_existing_volume_snapshots = json.load(file)

# delete
for snapshot in non_existing_volume_snapshots:
    snapshot_id = snapshot[0]
    try:
        ec2_client.delete_snapshot(SnapshotId=snapshot_id)
        print(f"Deleted snapshot: {snapshot_id}")
    except Exception as e:
        print(f"Error deleting snapshot {snapshot_id}: {e}")