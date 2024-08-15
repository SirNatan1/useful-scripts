import json
import boto3
import subprocess
from datetime import datetime, timedelta, timezone

# def the number of months
months = 15

# AWS CLI to get all snapshots and save to all_snapshots.json
subprocess.run(
    [
        "aws", "ec2", "describe-snapshots",
        "--owner-ids", "self",
        "--query", "Snapshots[*].[SnapshotId,StartTime,VolumeId]",
        "--output", "json"
    ],
    stdout=open('all_snapshots.json', 'w')
)

# load the snapshots from file
with open('all_snapshots.json', 'r') as file:
    all_snapshots = json.load(file)

# calc the date N months ago
n_months_ago = datetime.now(timezone.utc) - timedelta(days=months*30)

# filter snapshots older than N months
old_snapshots = [snapshot for snapshot in all_snapshots if datetime.fromisoformat(snapshot[1]) < n_months_ago]

# save the old snapshots to a file
with open('old_snapshots.json', 'w') as file:
    json.dump(old_snapshots, file, indent=4)

# load the old snapshots
with open('old_snapshots.json', 'r') as file:
    old_snapshots = json.load(file)

# a dict to store the newest snapshot date for each volume
newest_snapshots = {}

# fill the dict
for snapshot in all_snapshots:
    volume_id = snapshot[2]
    snapshot_date = datetime.fromisoformat(snapshot[1])
    if volume_id not in newest_snapshots or snapshot_date > newest_snapshots[volume_id]:
        newest_snapshots[volume_id] = snapshot_date

# filter old snapshots with newer versions
old_snapshots_with_newer = [snapshot for snapshot in old_snapshots if newest_snapshots[snapshot[2]] > datetime.fromisoformat(snapshot[1])]

# save the filtered snapshots to a file
with open('old_snapshots_with_newer.json', 'w') as file:
    json.dump(old_snapshots_with_newer, file, indent=4)

# init EC2
ec2_client = boto3.client('ec2')

# list all IDs
response = ec2_client.describe_volumes()
all_volume_ids = {volume['VolumeId'] for volume in response['Volumes']}

# filter snapshots for non-existing volumes
non_existing_volume_snapshots = [snapshot for snapshot in old_snapshots_with_newer if snapshot[2] not in all_volume_ids]

# save non-existing volume snapshots to a file
with open('non_existing_volume_snapshots.json', 'w') as file:
    json.dump(non_existing_volume_snapshots, file, indent=4)
