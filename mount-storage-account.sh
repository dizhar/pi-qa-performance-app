
#!/bin/bash
set -e

# mount_smbfs: server connection failed: No route to host
# mount_smbfs //<storage-account-name>@<storage-account-name>.file.core.windows.net/<share-name> <desired-mount-point>

USER="piqaautomationstorage"
KEY="Y3b5Fe6epxcI+m8vvnKLVA4CmX/dAZmwke5bNKiqJNkFAnWs0nf+1WWbJVixAc74+c2D7yAWtHDdsnx2II36rQ=="

#:
# mount_smbfs -d 777 -f 777 "//${USER}:${KEY}@piqaautomationstorage.file.core.windows.net" "performance"

mount_smbfs -d 777 -f 777 "//${USER}@piqaautomationstorage.file.core.windows.net" "performance"