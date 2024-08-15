## Description:
check-duplicate-exec-role.py - checks lambda functions for sharing the same IAM execution role and prints out any shared roles along with associated functions.

ami-assess.py - assess all the AMIs in the account by days it was created or last used, will print the ids to a file

ami-delete.py - delete all the AMIs assessed in the file

snapshot-assess.py - filter and identify outdated snapshots, find newer versions, and detect snapshots linked to non-existing volumes to a file

snapshot-delete.py - delete all snapshots assessed in the file