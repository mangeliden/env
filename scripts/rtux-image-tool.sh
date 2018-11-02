#!/bin/bash

if [ $# -ne 2 ]
then
    echo "Usage: $0 <image file> <gRPC server archive>"
    exit 1
fi

IMAGE=$1
ARCHIVE=$2

if [ ! -f "${IMAGE}" ]
then
    >&2 echo "Image file '${IMAGE}' not found, exitting!"
    exit 1
fi

if [ ! -f "${ARCHIVE}" ]
then
    >&2 echo "gRPC server archive '${ARCHIVE}' not found, exitting!"
    exit 1
fi

echo "Root permissions required for kpartx, you will be prompted for root password ..."

KPARTX=$(sudo which kpartx)

if [ -z ${KPARTX} ]
then
    >&2 echo "kpartx is not installed, please install it and run script again!"
    exit 1
fi

echo "Adding partition mapping ..."
ADDED=$(sudo kpartx -a -s -v "${IMAGE}")

PATTERN='add map (loop[0-9]+p[0-9]+) .*'
if [[ ${ADDED} =~ ${PATTERN} ]]
then
    MAPPED=${BASH_REMATCH[1]}
else
    echo "Mapping failed, kpartx output is:\n${ADDED}"

    sudo kpartx -d ${IMAGE}
    exit
fi

echo "Partition mapped as '${MAPPED}'"

MNTDIR=$(mktemp -d)

echo "Mounting filesystem to '${MNTDIR}' ..."
sudo mount /dev/mapper/${MAPPED} ${MNTDIR}

TARDIR=$(mktemp -d)

echo "Unpacking archive to '${TARDIR}' ..."
tar xzf "${ARCHIVE}" -C "${TARDIR}"

# Find out version contained in the image
if [ -f "${MNTDIR}/opt/temsremote/active/constants.py" ]
then
    OLDVER=v$(grep "VERSION_" "${MNTDIR}/opt/temsremote/active/constants.py" | awk -F '= ' '{print $2}' | sed ':a;N;$!ba;s/\n/./g')
else
    OLDVER="[none]"
fi

# Find out version contained in the archive
NEWVER=v$(grep "VERSION_" "${TARDIR}/infovista-rtux-grpc/temsremote/constants.py" | awk -F '= ' '{print $2}' | sed ':a;N;$!ba;s/\n/./g')

echo "Replacing gRPC server in the image (${OLDVER} -> ${NEWVER}) ..."
if [ -d "${MNTDIR}/opt/temsremote/active" ]
then
    sudo rm -r "${MNTDIR}/opt/temsremote/active"
fi

sudo mv "${TARDIR}/infovista-rtux-grpc/temsremote" "${MNTDIR}/opt/temsremote/active"

echo "Writing changes to disk (syncing) ..."
sudo sync

echo "Unmounting filesystem from '${MNTDIR}' ..."
sudo umount ${MNTDIR}

echo "Deleting partition mapping ..."
sudo kpartx -d ${IMAGE}

echo "Cleaning up temporary files ..."
rm -r ${TARDIR}
rm -r ${MNTDIR}
