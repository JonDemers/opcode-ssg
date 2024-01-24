---
layout: post
title: "Script to automate VM creation on Proxmox VE"
permalink: /tech/script-to-automate-vm-creation-on-proxmox-ve/
modified_date: 2023-10-15
---

This script will create a VM on Proxmox VE without requiring any user interation. Upon completion, you'll be able to ssh to the VM with your ssh key, just like you'd do with a VM hosted on a major cloud provider like AWS.

You'll need an OS *cloud image* for this, it will install the OS without any user interaction. We'll use Debian cloud image, but you can use a cloud image of any distro.

```bash
wget https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2
```

It has 2GB disk space by default, but you can [Increase disk size of cloud image](/tech/increase-disk-size-of-debian-cloud-image/) before running the script.

## Step 1. The Script

We'll copy-paste this script in a file `create-vm.sh`. You can read comments in the script for more details.

```bash
#!/bin/bash

# Exit on error
set -e

if [ "$#" -ne 7 ]; then
  echo "Usage: $0 <id> <name> <memory> <cores> <image> <ciuser> <sshkey>"
  exit 1
fi

id=$1
name=$2
memory=$3
cores=$4
image=$5
ciuser=$6
sshkey=$7

echo Creating VM using parameters:
echo id=$id
echo name=$name
echo memory=$memory
echo cores=$cores
echo image=$image
echo ciuser=$ciuser
echo sshkey=$sshkey

# Print commands that are executed (facilitates debugging)
set -x

# Destroy the VM if it exists
qm stop $id || true
qm destroy $id -purge 1 || true

# Create the VM
qm create $id
qm set $id --name $name
qm set $id --memory $memory
qm set $id --cores $cores
qm set $id --net0 virtio,bridge=vmbr0
qm importdisk $id $image local-lvm
qm set $id --scsihw virtio-scsi-pci
qm set $id --scsi0 local-lvm:vm-$id-disk-0
qm set $id --ide2 local-lvm:cloudinit
qm set $id --ciuser $ciuser
qm set $id --sshkey $sshkey
qm set $id --serial0 socket --vga serial0

# Start the VM for the first time, this will install the OS from the cloud image
qm start $id

# Reboot for a clean start
sleep 60
qm reboot $id
```

We make the script executable

```bash
chmod +x create-vm.sh
```

## Step 2. Run the Script

```bash
./create-vm.sh 999 debian-999 4096 2 debian-11-genericcloud-amd64.qcow2 jdemers jdemers.id_rsa.pub
```

## Step 3. SSH to your VM

```bash
ssh debian-999
```

## Step 4. Automate VM setup with ansible...

Not in scope of this article

*Author: [Jonathan Demers](https://www.linkedin.com/in/jonathan-demers-ing/ "Jonathan Demers")*

