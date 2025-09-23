---
layout: post
title: "How to Migrate 3 MySQL Databases to Amazon RDS in 5 Minutes"
permalink: /tech/how-to-migrate-3-mysql-databases-to-amazon-rds-in-5-minutes/
last_modified_at: 2025-09-23
---

I had a LAMT (Linux-Apache-MySQL-Tomcat) on [Amazon EC2](https://aws.amazon.com/ec2/) and I wanted to move all remaining MySQL databases (3) to an existing [Amazon RDS](https://aws.amazon.com/rds/) instance. This would allow me to shutdown the MySQL instance on EC2, freeing RAM for Tomcat and leveraging RDS automated backups for those 3 databases in case of a disaster. The databases to migrate only contain low volume TEST data, but I already have that RDS instance, so why not use it?

I also have a SLA with my clients that allows me to perform *"Standard daily maintenance"*. Basically, the *"Standard daily maintenance"* must be performed outside business hours and must last **at most 15 minutes**.

The key to the success of this migration was to **prepare**, **prepare** and **prepare** before the actual migration. So here is what I did before the migration:

- Create 3 empty databases and users on the RDS instance
- Prepare new configuration files with the new JDBC url pointing to the RDS instance
- Prepare all the commands that must be executed
- Review and test the commands as needed

Now that I am prepared I just need to wait for the *"Standard daily maintenance"* time. Then, I just copy and paste the commands in a terminal. I prefer to copy/paste the commands one by one, so if any command fails (for any reason), it can be fixed right away before running the next commands. Here is a summary of the commands:

1. Shutdown Tomcat
1. [MySQL dump/restore](https://www.thegeekstuff.com/2008/09/backup-and-restore-mysql-database-using-mysqldump/) from EC2 to RDS (3 databases)
1. Copy the configuration files with JDBC url pointing to RDS (3 files)
1. [Prevent MySQL from starting during boot](https://askubuntu.com/questions/40072/how-to-stop-apache2-mysql-from-starting-automatically-as-computer-starts): echo manual > /etc/init/mysql.override
1. sudo reboot (I want to verify that MySQL on EC2 won't start after a reboot)

Everything went fine. After reboot, the MySQL instance on EC2 was not started, as expected. The Tomcat webapps were fine as well and there is more free RAM for Tomcat.

For those webapps, I have [uptime monitoring at one minute interval with Pingdom](https://www.pingdom.com/). I receive emails when a webapp go down and up again. Here is the "UP" email from Pingdom, showing **5 minutes of downtime** for that migration:

*OpCode is UP again at 12/22/2014 08:25:36PM, after **5m of downtime**.*

*Author: [Jonathan Demers](https://jonathandemers.ca/ "Jonathan Demers"). See on [LinkedIn](https://www.linkedin.com/in/jonathan-demers-ing/ "Jonathan Demers on LinkedIn").*