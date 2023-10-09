---
layout: post
title: "Programmatically Configure Hibernate (JPA) with DBCP"
permalink: /programmatically-configure-hibernate-jpa-with-dbcp/
---

I recently had deadlock issues with c3p0 and statement caching. Long story short, after investigating c3p0 code, I decided to switch to [DBCP](https://commons.apache.org/proper/commons-dbcp/) (maybe I’ll write a post with the long story).

I am not a big fan of Spring (here again, maybe I’ll write a post about that). If you are like me, here is how to programmatically configure [Hibernate](https://hibernate.org/) (JPA) to use DBCP, without Spring and without JNDI.

```java
package com.opcodesolutions.demo;

import java.util.HashMap;
import java.util.Map;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.TypedQuery;

import org.apache.commons.dbcp2.BasicDataSource;
import org.hibernate.cfg.AvailableSettings;

import com.opcodesolutions.generic.jpa.entity.User;

public class HibernateJPAWithDBCP {

    public static void main(String[] args) {

        // Create and configure DBCP DataSource
        BasicDataSource dbcpDataSource = new BasicDataSource();
        dbcpDataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dbcpDataSource.setUrl("jdbc:mysql://localhost:3306/database");
        dbcpDataSource.setUsername("user");
        dbcpDataSource.setPassword("************");

        // Enable statement caching (Optional)
        dbcpDataSource.setPoolPreparedStatements(true);
        dbcpDataSource.setMaxOpenPreparedStatements(50);

        // JPA properties
        Map<String, Object> properties = new HashMap<>();

        // This line will tell hibernate (JPA) to use DBCP
        properties.put(AvailableSettings.DATASOURCE, dbcpDataSource);

        // Create the EntityManagerFactory with JPA properties
        EntityManagerFactory factory =
            Persistence.createEntityManagerFactory("User", properties);

        // Test with simple query
        EntityManager entityManager = factory.createEntityManager();
        TypedQuery<User> query =
            entityManager.createQuery("select u from User u", User.class);
        for (User user : query.getResultList()) {
            System.out.println(user.getFullName());
        }

    }
}
```

With DBCP, all my deadlock issues disappeared. Thank you [ASF](https://www.apache.org/).

*Author: [Jonathan Demers](https://www.linkedin.com/in/jonathan-demers-ing "Jonathan Demers")*