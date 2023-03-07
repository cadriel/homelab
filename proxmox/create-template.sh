#!/bin/bash

# This assumes the use of a cloud init based image, and that libguestfs-tools is installed.

# args:
#  vm_id
#  vm_name
#  file_url

# defaults:
VM_ID=$1
VM_NAME=$2
FILE_URL=$3
FILE_NAME=$(basename "$3")
NEW_FILE_NAME=${FILE_NAME%.*}.qcow2

USERNAME=sysadmin
SSH_KEY_FILE=/root/.ssh/id_default.pub

MEM=2048
CORES=2
DISK_SIZE=32G
NET_BRIDGE=vmbr0
DISK_STOR=data

# Print config
echo "Creating template ${VM_NAME} (${VM_ID}) from ${FILE_NAME} (${FILE_URL})"
echo "VM_ID:           ${VM_ID}"
echo "VM_NAME:         ${VM_NAME}"
echo "FILE_URL:        ${FILE_URL}"
echo "FILE_NAME:       ${FILE_NAME}"
echo "NEW_FILE_NAME:   ${NEW_FILE_NAME}"
echo "USERNAME:        ${USERNAME}"
echo "SSH_KEY_FILE:    ${SSH_KEY_FILE}"
echo "MEM:             ${MEM}"
echo "CORES:           ${CORES}"
echo "DISK_SIZE:       ${DISK_SIZE}"
echo "NET_BRIDGE:      ${NET_BRIDGE}"
echo "DISK_STOR:       ${DISK_STOR}"

# Download the image, renaming it to the intended img name (qcow2)
wget -O ${NEW_FILE_NAME} ${FILE_URL}

# Add any additional packages you want installed in the template
# This won't work because it'll set the machineId and random seed, of which
# we don't want for a template.
# virt-customize --install qemu-guest-agent -a ${NEW_FILE_NAME}

# Create the new VM
qm create $VM_ID --name $VM_NAME --ostype l26 --memory ${MEM} --net0 virtio,bridge=${NET_BRIDGE}

# Set cores and CPU type
qm set $VM_ID --cores ${CORES} --cpu host

# Set display to serial
qm set $VM_ID --serial0 socket --vga serial0

# Set boot device to new file
qm set $VM_ID --scsi0 ${DISK_STOR}:0,import-from="$(pwd)/$NEW_FILE_NAME",discard=on

# Set scsi hardware as default boot disk using virtio scsi single
qm set $VM_ID --boot order=scsi0 --scsihw virtio-scsi-single

# Enable Qemu guest agent
qm set $VM_ID --agent enabled=1,fstrim_cloned_disks=1

# Add cloud-init device
qm set $VM_ID --ide2 ${DISK_STOR}:cloudinit

# Set ip config
qm set $VM_ID --ipconfig0 "ip6=auto,ip=dhcp"

# Import the ssh keyfile
qm set $VM_ID --sshkeys ${SSH_KEY_FILE}

# Add the user
qm set $VM_ID --ciuser ${USERNAME}

# Resize the disk
qm disk resize $VM_ID scsi0 ${DISK_SIZE}

# Convert to Template
qm template $VM_ID

#Remove file when done
rm $NEW_FILE_NAME

# Example Usage

## Ubuntu
# 20.04 (Focal Fossa)
# ./create-template.sh 8000 "ubuntu-server-focal-cloud" "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"

# 22.04 (Jammy Jellyfish)
# ./create-template.sh 8001 "ubuntu-server-jammy-cloud" "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"

## Debian
# Buster (10)
# ./create-template.sh 8002 "debian-server-buster-cloud" "https://cloud.debian.org/images/cloud/buster/latest/debian-10-genericcloud-amd64.qcow2"

# Bullseye (11)
# wget 
# ./create-template.sh 8003 "debian-server-bullseye-cloud" "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
