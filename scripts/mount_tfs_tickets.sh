#!/bin/bash
if [ -z "$TICKET_SERVER" ]
then
    echo "No server in variable TICKET_SERVER";
    exit 1;
fi

echo -n "Mounting TFS Ticket server $TFS_SERVER"
echo -n

sudo mount -t cifs //$TICKET_SERVER/TFStickets ~/mnt/tfstickets -o username=mliden,domain=iv
