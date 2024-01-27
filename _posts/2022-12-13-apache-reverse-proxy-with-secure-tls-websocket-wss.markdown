---
layout: post
title: "Apache Reverse Proxy with Secure TLS WebSocket (wss://)"
permalink: /tech/apache-reverse-proxy-with-secure-tls-websocket-wss/
last_modified_at: 2024-01-27
---

Configuring Apache reverse proxy with WebSocket can be tricky. It is even trickier if the WebSocket is secured with TLS (wss://). Here is how to do it.

## Step 1. Enable required apache modules

```bash
sudo a2enmod ssl
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_wstunnel
sudo a2enmod rewrite
```

## Step 2. Apache configuration

```apache

  # Depending on the proxied-host, you may need some or all of this
  SSLProxyEngine on
  # SSLProxyVerify none 
  # SSLProxyCheckPeerCN off
  # SSLProxyCheckPeerName off
  # SSLProxyCheckPeerExpire off

  # This is for secure TLS WebSocket reverse proxy (wss://)
  RewriteEngine On
  RewriteCond %{HTTP:Upgrade} =websocket [NC]
  RewriteRule /(.*) wss://proxied-host:port/$1 [P,L]

  # This is for regular HTTPS reverse proxy
  ProxyRequests Off
  ProxyPreserveHost On
  ProxyPass / https://proxied-host:port/
  ProxyPassReverse / https://proxied-host:port/

```

## If the WebSocket is *not* Secure (ws://)

It is simpler if the WebSocket is *not* secure:

```apache

  # This is for WebSocket reverse proxy (ws://)
  RewriteEngine On
  RewriteCond %{HTTP:Upgrade} =websocket [NC]
  RewriteRule /(.*) ws://proxied-host:port/$1 [P,L]

  # This is for regular HTTP reverse proxy
  ProxyRequests Off
  ProxyPreserveHost On
  ProxyPass / http://proxied-host:port/
  ProxyPassReverse / http://proxied-host:port/

```

*Author: [Jonathan Demers](https://www.linkedin.com/in/jonathan-demers-ing/ "Jonathan Demers")*
