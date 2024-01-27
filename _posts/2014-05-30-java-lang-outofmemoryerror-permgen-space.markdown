---
layout: post
title: "How to fix java.lang.OutOfMemoryError: PermGen space"
permalink: /tech/java-lang-outofmemoryerror-permgen-space/
last_modified_at: 2024-01-27
---

When you get an `OutOfMemoryError` with the message **"PermGen space"** (not to be confused with message "[Java heap space](/tech/solve-java-lang-outofmemoryerror-java-heap-space/)"), this means the memory used for **class definition** is exhausted. Fortunately, most of the time, this is easy to fix.

## Solution 1. (your best bet). Increase the size of PermGen space

If you have a Java process that uses a lot of classes (lots of jars) or if you have many applications deployed to your application container (Tomcat), you can allocate more memory to that "PermGen space" using the `-XX:MaxPermSize` VM argument. For instance, to allocate 1024 MB of RAM to PermGen space, use:

```bash
java -XX:MaxPermSize=1024M ...
```

## Solution 2. Restart your application container

You can get this error if you redeploy an application (webapp) several time without restarting your application container (like Tomcat). Most application containers support hot-redeployment, but class-loading is complex and sometimes old class definitions remain in memory. In that case, your best option is to get used to <u>always restart your application container (Tomcat) after you deploy an application to it</u>. This is easy and it fixes many problems.

## Solution 3. Fix your class-loader leak

If none of the above works, you are in trouble 🙁 Seriously, unless you hacked the class-loading of the JVM or application container, you should not have that problem. Or maybe it is a bug in a library you are using or in your application container. You can try to upgrade to latest versions. If you hacked the class-loaders yourself, you may want to reconsider it. Why did you do that? Unless you are developing a JVM or an application container, you should not have to do that.

*Author: [Jonathan Demers](https://www.linkedin.com/in/jonathan-demers-ing/ "Jonathan Demers")*