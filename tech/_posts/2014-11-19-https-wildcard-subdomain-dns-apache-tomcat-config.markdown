---
layout: post
title: "HTTPS Wildcard Subdomain: DNS + Apache + Tomcat Config"
permalink: /https-wildcard-subdomain-dns-apache-tomcat-config/
---

I recently had to configure HTTPS on a wildcard subdomain with Apache HTTP server as reverse proxy to a Tomcat backend. I had few more requirements:

1. Redirect all **http** traffic to **https** and preserve the subdomain (hostname). For instance:
  - http://**sub1**.example.com/ -> redirect to -> http**s**://**sub1**.example.com/
  - http://**sub2**.example.com/ -> redirect to -> http**s**://**sub2**.example.com/
  - etc.
1. I want to have a **PHP** wiki on the subdirectory `/wiki` and I want to send the rest of the traffic to Tomcat.
1. **Tomcat** needs to know the subdomain (hostname) and will serve content accordingly.
1. I don’t know the subdomains in advance because they are **chosen by users**, just like *.wordpress.com

Few parts were not trivial, so I will share my setup.

## DNS Wildcard Subdomain Configuration

DNS is probably the easiest part. Nowadays, most domain registrar offer good DNS support for free with your domain. If that is not the case of your registrar, you may want to consider namecheap. Their [DNS also support wildcard entries](https://www.namecheap.com/support/knowledgebase/article.aspx/597/10/how-can-i-set-up-a-catchall-wildcard-subdomain). Otherwise, you can use the popular **Bind DNS server**. Here is how to configure a wildcard entry in BIND. Change 55.55.55.55 with your IP address.

```
*    IN    A    55.55.55.55
```

## Apache Wildcard Subdomain Configuration

This was trickier. The Apache HTTP server configuration has 2 main parts.

1. **HTTP (port 80)**: We use mod_rewrite to redirect all traffic for *.example.com to https (port 443) and we preserve the hostname with the %{HTTP_HOST} variable.
2. **HTTPS (port 443)**: Except for the PHP subdirectory (/wiki), we reverse proxy all traffic to Tomcat, which listen on port 9090 of localhost.

```apache
# Allow non-SNI clients
SSLStrictSNIVHostCheck off

# HTTP configuration
<VirtualHost *:80>

    ServerName example.com

    # Wildcard subdomain
    ServerAlias *.example.com

    ServerAdmin info@example.com

    # Permanent redirect (301) to HTTPS and preserve
    # hostname (but do not preserve path)
    RewriteEngine On
    RewriteRule .* https://%{HTTP_HOST}/? [R=301,L]
</VirtualHost>

# HTTPS configuration
<VirtualHost *:443>

    ServerName example.com

    # Wildcard subdomain
    ServerAlias *.example.com

    ServerAdmin info@example.com

    # PHP Wiki on path /wiki
    Alias /wiki /opt/example.com/php/wiki
    <Directory /opt/example.com/php/wiki>
        AllowOverride All
        Require all granted
    </Directory>

    # Reverse proxy everything to Tomcat except for /wiki
    ProxyRequests Off
    ProxyPass /wiki !
    ProxyPass / http://localhost:9090/
    ProxyPassReverse / http://localhost:9090/

    # Logs
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    # Wildcard SSL/TLS Certificate files
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/STAR_example_com.crt
    SSLCertificateKeyFile /etc/ssl/private/example.key
    SSLCertificateChainFile /etc/ssl/certs/example.ca-bundle

    # Standard script config
    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>

    # Standard config for Internet Explorer
    BrowserMatch "MSIE [2-6]" \
        nokeepalive ssl-unclean-shutdown \
        downgrade-1.0 force-response-1.0

    BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

</VirtualHost>
```

## Tomcat Wildcard Subdomain Configuration

Below you’ll find the configuration of Tomcat (in server.xml), which is quite standard. Actually, we do not need to define any *"wildcard"*, we just define a `defaultHost` in the `Engine` element. Then we deploy a `ROOT.war` in the webapps directory (`/opt/example.com/tomcat7/webapps`) to serve all content at the root context path.

```xml
<Service name="example">
    <Connector port="9090" protocol="HTTP/1.1" connectionTimeout="20000"
            URIEncoding="UTF-8" />
    <Engine name="example" defaultHost="localhost">
        <Host name="localhost" appBase="/opt/example.com/tomcat7/webapps"
                unpackWARs="true" autoDeploy="true">
            <Valve className="org.apache.catalina.valves.AccessLogValve"
                    directory="logs" prefix="example.com_access_log."
                    suffix=".txt" pattern="%h %l %u %t &quot;%r&quot; %s %b" />
        </Host>
    </Engine>
</Service>
```

## How does Tomcat Know the Subdomain?

With this configuration, all content will be sent to Tomcat with "localhost" as the hostname. Fortunately, the [Apache reverse proxy will send extra request headers](https://httpd.apache.org/docs/current/mod/mod_proxy.html#x-headers) to Tomcat, namely:

- `X-Forwarded-For`: The IP address of the client.
- **`X-Forwarded-Host`: The original host requested by the client in the Host HTTP request header.**
- `X-Forwarded-Server`: The hostname of the proxy server.

So in Tomcat (or any other servlet container), just use the Java code below to get the value of that header `X-Forwarded-Host` and you’ll know the subdomain.

```java
String subdomain = request.getHeader("X-Forwarded-Host");
```

Alternatively, you may also use the [ProxyPreserveHost](https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypreservehost) On directive in Apache configuration and you should be able to get the hostname (subdomain) normally in Tomcat. *NOTE: I haven’t tested that setup.*

```java
String subdomain = request.getServerName();
```

## Bonus: Wildcard SSL Certificate

Of course you’ll need a wildcard SSL certificate. Those are usually very expensive, but [Namecheap resells Comodo wildcard certificate at very good price](https://www.namecheap.com/security/ssl-certificates/comodo/positivessl-wildcard.aspx). No, I do not have any interest in namecheap, they just happen to be very good at what they do 🙂

*Author: [Jonathan Demers](https://www.linkedin.com/in/jonathan-demers-ing "Jonathan Demers")*