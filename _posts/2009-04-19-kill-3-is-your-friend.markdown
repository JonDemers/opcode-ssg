---
layout: post
title: "kill -3 is your friend"
permalink: /tech/kill-3-is-your-friend/
last_modified_at: 2025-09-23
---

One nice feature of Java runtime is when you send the QUIT signal to a Java process, it outputs the full thread dump to stdout. To send the that signal, just open a terminal and type:

```bash
kill -QUIT <pid>
```

or

```bash
kill -3 <pid>
```

Where `<pid>` is the process Id. This does not terminate the process; all threads will continue doing what they were doing.

That feature can be very useful when the application seems to freeze or when you have a very intermittent issue (intermittent deadlock). With the full thread dump, you can see what every thread was doing at that particular moment. So in case of a deadlock, you will be able to see what monitors and what threads are involved.

This can also be helpful to diagnose performance bottlenecks. Suppose you are load testing an application and it does not deliver the expected throughput, but the CPU usage is not the problem. For instance, with kill -3 you will notice right away that the size of the jdbc connection pool is not big enough and all threads are waiting on it for a connection to free.

*Author: [Jonathan Demers](https://jonathandemers.ca/ "Jonathan Demers"). See on [LinkedIn](https://www.linkedin.com/in/jonathan-demers-ing/ "Jonathan Demers on LinkedIn").*