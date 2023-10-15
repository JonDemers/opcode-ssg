---
layout: post
title: "Remote Debugging in Java"
permalink: /tech/remote-debugging-in-java/
---

One thing people ask me from time to time is how to debug a remote Java application. This can be very useful when you experience problems at customer site, but cannot reproduce them in a development environment. We all know logs files do not always contain all information required to solve the issues. In such case, remote debugging can be very useful.

To start remote debugging, one simply needs to add extra VM arguments to the Java command line:

```bash
-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000
```

Then, you can use the remote feature of your IDE to connect to the Java process in using the port specified above (8000). For Instance, in eclipse, you would do:

```
Run -> Debug Configurations… -> Remote Java Applications -> Create new
```

In the Host field, you enter the host name or IP of the machine running the Java application. In the Port field, you enter the port specified above (8000).

Note that remote debugging also works nicely with SSH tunnels.

*Author: [Jonathan Demers](https://www.linkedin.com/in/jonathan-demers-ing/ "Jonathan Demers")*