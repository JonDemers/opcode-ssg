---
layout: post
title: "Increase disk size of Debian cloud image"
permalink: /tech/increase-disk-size-of-debian-cloud-image/
last_modified_at: 2024-01-27
---

Generic Debian cloud images come with small disk size by default: **2GB**. We can resize/increase the disk storage after the VM is created, but this is not convenient because we'd have to do this for each VM we create.

A better solution is to convert the could image to have bigger disk size by default. In this article we'll create an Debian cloud image with **32GB** of storage.

## Step 1. Get the Generic Debian cloud image

Get the image

```
# wget https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2
```

Validate the checksum, checksum are here: [https://cloud.debian.org/images/cloud/bullseye/latest/SHA512SUMS](https://cloud.debian.org/images/cloud/bullseye/latest/SHA512SUMS)

```
# sha512sum debian-11-genericcloud-amd64.qcow2

71f1c376e585a87299f751e076689d7ebe2a897649b65071878eb5694be76b771f37c21d7a88630214f4650dec5307e9f73d597ec326f99bd3451e23f607e5b8  debian-11-genericcloud-amd64.qcow2
```

Current image size is **2GB**

```
# qemu-img info debian-11-genericcloud-amd64.qcow2

image: debian-11-genericcloud-amd64.qcow2
file format: qcow2
virtual size: 2 GiB (2147483648 bytes)
disk size: 236 MiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    compression type: zlib
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
    extended l2: false
```


## Step 2. Increase image size

Use qemu-img to resize the image

```
# qemu-img resize debian-11-genericcloud-amd64.qcow2 32G

Image resized.
```

## Step 3. Increase partition size to match image size

Mount partition with nbd

```
# modprobe nbd max_part=10
# qemu-nbd -c /dev/nbd0 debian-11-genericcloud-amd64.qcow2
```

Install parted

```
# apt -y install parted
```

Print and fix partition with parted. Press **F** to Fix the warning

```
# parted /dev/nbd0 print free

Warning: Not all of the space available to /dev/nbd0 appears to be used, you can fix the GPT to use all of the space (an extra 62914560 blocks) or continue with the current setting?
Fix/Ignore? F
Model: Unknown (unknown)
Disk /dev/nbd0: 34.4GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name  Flags
        17.4kB  1049kB  1031kB  Free Space
14      1049kB  4194kB  3146kB                     bios_grub
15      4194kB  134MB   130MB   fat16              boot, esp
 1      134MB   2147MB  2013MB  ext4
        2147MB  34.4GB  32.2GB  Free Space
```

Resize partition and print its new size

```
# parted -s /dev/nbd0 "resizepart 1 100%" quit
# parted /dev/nbd0 print free

Model: Unknown (unknown)
Disk /dev/nbd0: 34.4GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name  Flags
        17.4kB  1049kB  1031kB  Free Space
14      1049kB  4194kB  3146kB                     bios_grub
15      4194kB  134MB   130MB   fat16              boot, esp
 1      134MB   34.4GB  34.2GB  ext4
```

## Step 4. Increase filesystem to match partition size

Use resize2fs to resize filesystem

```
# resize2fs /dev/nbd0p1

resize2fs 1.46.5 (30-Dec-2021)
Resizing the filesystem on /dev/nbd0p1 to 8355835 (4k) blocks.
The filesystem on /dev/nbd0p1 is now 8355835 (4k) blocks long.
```

Unmount nbd

```
# qemu-nbd -d /dev/nbd0

/dev/nbd0 disconnected
```

## Step 5. Verify new cloud image size is 32GB

New image size is 32GB

```
# qemu-img info debian-11-genericcloud-amd64.qcow2

image: debian-11-genericcloud-amd64.qcow2
file format: qcow2
virtual size: 32 GiB (34359738368 bytes)
disk size: 240 MiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    compression type: zlib
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
    extended l2: false
```

*Author: [Jonathan Demers](https://jonathandemers.ca/ "Jonathan Demers"). See on [LinkedIn](https://www.linkedin.com/in/jonathan-demers-ing/ "Jonathan Demers on LinkedIn").*

