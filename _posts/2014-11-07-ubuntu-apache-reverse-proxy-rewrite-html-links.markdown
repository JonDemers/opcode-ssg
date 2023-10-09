---
layout: post
title: "Ubuntu Apache Reverse Proxy Rewrite HTML Links"
permalink: /tech/ubuntu-apache-reverse-proxy-rewrite-html-links/
---

I just wasted few hours on this, so I will share a few tips. If you want to setup a reverse proxy and **rewrite links in html** pages, you can use Apache module [mod_proxy_html](https://httpd.apache.org/docs/current/mod/mod_proxy_html.html).

## Step 1. Install and enable Apache mod_proxy

```bash
$ sudo apt-get install libapache2-mod-proxy-html libxml2-dev
$ sudo a2enmod proxy
$ sudo a2enmod proxy_http
$ sudo a2enmod proxy_html
$ sudo a2enmod xml2enc
```

## Step 2. Apache configuration

In **Ubuntu 14.04 LTS**, it does not work "out of the box", because some standard config is missing when enabling mod_proxy_html. More specifically, the [ProxyHTMLLinks](https://httpd.apache.org/docs/current/mod/mod_proxy_html.html#proxyhtmllinks) directives are missing in Ubuntu 14.04. I say "missing", because those directives are included by default in earlier releases and in other distros (in a file called proxy_html.conf). Also, pay particular attention to the directives [ProxyHTMLEnable](https://httpd.apache.org/docs/current/mod/mod_proxy_html.html#proxyhtmlenable), [ProxyHTMLExtended](https://httpd.apache.org/docs/current/mod/mod_proxy_html.html#proxyhtmlextended) and [SetOutputFilter](https://httpd.apache.org/docs/current/mod/core.html#setoutputfilter).

So, let’s say you want to have your apache server at `http://host1.example.com/path1` to serve (proxy) the content of the server at `http://host2.example.com/path2` and **rewrite HTML links**. Here is the config that works for me on Ubuntu 14.04 LTS.

```apache
<VirtualHost *:80>
    ServerName host1.example.com
    ProxyRequests Off
    <Location /path1>
        ProxyHTMLLinks a href
        ProxyHTMLLinks area href
        ProxyHTMLLinks link href
        ProxyHTMLLinks img src longdesc usemap
        ProxyHTMLLinks object classid codebase data usemap
        ProxyHTMLLinks q cite
        ProxyHTMLLinks blockquote cite
        ProxyHTMLLinks ins cite
        ProxyHTMLLinks del cite
        ProxyHTMLLinks form action
        ProxyHTMLLinks input src usemap
        ProxyHTMLLinks head profile
        ProxyHTMLLinks base href
        ProxyHTMLLinks script src for

        ProxyHTMLEvents onclick ondblclick onmousedown onmouseup \
            onmouseover onmousemove onmouseout onkeypress \
            onkeydown onkeyup onfocus onblur onload \
            onunload onsubmit onreset onselect onchange

        ProxyPreserveHost On
        ProxyPass http://host2.example.com/path2
        ProxyPassReverse http://host2.example.com/path2
        ProxyHTMLEnable On
        ProxyHTMLExtended On
        SetOutputFilter INFLATE;proxy-html;DEFLATE;
        ProxyHTMLURLMap http://host2.example.com/path2 /path1
    </Location>
</VirtualHost>
```

*Author: [Jonathan Demers](https://www.linkedin.com/in/jonathan-demers-ing "Jonathan Demers")*