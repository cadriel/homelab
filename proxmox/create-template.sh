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

USERNAME=sysadmin
SSH_KEY_FILE=/root/id_default.pub

MEM=2048
CORES=2
DISK_SIZE=32G
NET_BRIDGE=vmbr0
DISK_STOR=data

function create_template() {
    # Print config
    echo "Creating template ${VM_NAME} (${VM_ID}) from ${FILE_NAME} (${FILE_URL})"
    echo "VM_ID:           ${VM_ID}"
    echo "VM_NAME:         ${VM_NAME}"
    echo "FILE_URL:        ${FILE_URL}"
    echo "FILE_NAME:       ${FILE_NAME}"
    echo "USERNAME:        ${USERNAME}"
    echo "SSH_KEY_FILE:    ${SSH_KEY_FILE}"
    echo "MEM:             ${MEM}"
    echo "CORES:           ${CORES}"
    echo "DISK_SIZE:       ${DISK_SIZE}"
    echo "NET_BRIDGE:      ${NET_BRIDGE}"
    echo "DISK_STOR:       ${DISK_STOR}"

    # Download the image, renaming it to the intended img name (qcow2)
    wget -O ${FILE_NAME} ${FILE_URL}

    # Ubuntu cloud img doesn't include qemu-guest-agent required for packer to get IP details from proxmox
    # Add any additional packages you want installed in the template
    #virt-customize --install qemu-guest-agent -a ${IMG_NAME}

    # Create the new VM
    # qm create $1 --name $2 --ostype l26
    #qm create $1 --name $2 --memory ${MEM} --net0 virtio,bridge=${NET_BRIDGE}

    # Set cores and CPU type
    #qm set $1 --cores ${CORES} --cpu host

    # Set display to serial
    #qm set $1 --serial0 socket --vga serial0

    # Set boot device to new file
    #qm set $1 --scsi0 ${DISK_STOR}:0,import-from="$(pwd)/$3",discard=on

    # Set scsi hardware as default boot disk using virtio scsi single
    #qm set $1 --boot order=scsi0 --scsihw virtio-scsi-single

    # Enable Qemu guest agent
    #qm set $1 --agent enabled=1,fstrim_cloned_disks=1

    # Add cloud-init device
    #qm set $1 --ide2 ${DISK_STOR}:cloudinit

    # Set ip config
    #qm set $1 --ipconfig0 "ip6=auto,ip=dhcp"

    # Import the ssh keyfile
    #qm set $1 --sshkeys ${SSH_KEY_FILE}

    # Add the user
    #qm set $1 --ciuser ${USERNAME}

    # Resize the disk
    #qm disk resize $1 scsi0 ${DISK_SIZE}

    # Convert to Template
    #qm template $1

    #Remove file when done
    #rm $3
}

# Example Usage

## Ubuntu
# 20.04 (Focal Fossa)
# create_template 8000 "ubuntu-server-focal-cloud" "ubuntu-20.04-server-cloudimg-amd64.img" "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"

# 22.04 (Jammy Jellyfish)
# create_template 8001 "ubuntu-server-jammy-cloud" "ubuntu-22.04-server-cloudimg-amd64.img" "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"

## Debian
# Buster (10)
# create_template 8002 "debian-server-buster-cloud" "debian-10-genericcloud-amd64.qcow2" "https://cloud.debian.org/images/cloud/buster/latest/debian-10-genericcloud-amd64.qcow2"

# Bullseye (11)
# wget "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
# create_template 8003 "debian-server-bullseye-cloud" "debian-11-genericcloud-amd64.qcow2" "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
