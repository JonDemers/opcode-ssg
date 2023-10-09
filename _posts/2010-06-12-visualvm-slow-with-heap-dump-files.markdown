---
layout: post
title: "VisualVM slow with heap dump files"
permalink: /visualvm-slow-with-heap-dump-files/
---

One great feature of [VisualVM](https://visualvm.dev.java.net/) is that it can read heap dump files. Heap dumps are useful to diagnose memory leaks. See this post for more details about [memory leaks and how to solve them](/tech/solve-java-lang-outofmemoryerror-java-heap-space/).

## Why VisualVM is slow with heap dump

Another great feature of VisualVM is that you can read a huge heap dump file and VisualVm will consume a minimal amount of memory to do so. For instance, you will be able to read a 8 Gigabytes heap dump file with VisualVM running on a development workstation having only 2 Gigabytes of RAM. In order to achieve that, VisualVM will parse the heap dump file and will create a work file on disk in the default system temp folder (/tmp by default on Linux). In theory that’s great, but in practice, VisualVM becomes painfully slow because it constantly have to do disk I/O’s to process the information.

This behavior is even more frustrating if you happen to have a server with 12 Gigabytes of RAM available for you. A simple solution for that is to create a ramdisk and tell VisualVM to use that ramdisk as the tmp folder.

## The solution: use a RAMDisk

First, create the RAMDisk (tmpfs). Here I am on a linux development server and I create a tmp folder in my home. Then I create (mount) the ramdisk in the tmp folder I just created:

```bash
$ mkdir /tmp/ramdisk
$ sudo mount -t tmpfs none /tmp/ramdisk
```

Then I launch VisualVM and I modify the java.io.tmpdir VM arg that tells VisualVM where the system tmp folder is.

```bash
$ jvisualvm -J-Djava.io.tmpdir=/tmp/ramdisk
```

Now VisualVM is much much faster and I can investigate and find the root cause of that memory leak much faster.

*Author: [Jonathan Demers](https://www.linkedin.com/in/jonathan-demers-ing "Jonathan Demers")*