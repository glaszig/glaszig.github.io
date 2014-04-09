---
layout: blog_post
title: Reverse-proxy a Rails app with Apache
tags: [rails, proxy, apache]
comments: true
permalink: /2013/10/25/reverse-proxy-a-rails-app.html
---

Recently I had to make one part of a Rails app available via a path of another Apache vhost.  
The Rails app is running at `http://app.example.com/engine-name` and has to be accessible at `http://www.example.com/app`.

After spending some time figuring out `mod_proxy` and `mod_proxy_html` I came up with the following:

```apache
<VirtualHost *:80>
  ServerName www.example.com

  ProxyPreserveHost Off

  RewriteEngine On
  RewriteRule   ^(?:/app)?/assets/swf/(.*) http://app.example.com/assets/swf/$1 [P]

  RedirectMatch /engine-name(.*) http://www.example.com/app$1

  <Location /app>
    ProxyPass        http://app.example.com/engine-name
    ProxyPassReverse http://app.example.com/engine-name
    SetOutputFilter  proxy-html
    ProxyHTMLDocType "<!DOCTYPE html>"
    ProxyHTMLURLMap  ^/assets http://app.example.com/assets R
    ProxyHTMLURLMap  ^/system http://app.example.com/system R
    ProxyHTMLURLMap  /engine-name/ /app/
    RequestHeader    unset Accept-Encoding
    Order            allow,deny
    Allow            from all
  </Location>
</VirtualHost>
```

### Devil of Details

    ProxyPreserveHost Off

Disables forwarding of the original request's `Host` header to the backend server. This is important, for example, when the backend server is a name based virtual host.


    RewriteEngine On
    RewriteRule   ^(?:/app)?/assets/swf/(.*) http://app.example.com/assets/swf/$1 [P]

Rewrites all incoming requests to assets, e.g. `/assets/swf/soundmanager2.swf`, to the proxied backend.


    ProxyPass        http://app.example.com/engine-name
    ProxyPassReverse http://app.example.com/engine-name

Proxies all requests to the given argument. The `ProxyPassReverse` directive should cause redirects contained in the response from the backend server to be rewritten.  
Since this somehow did not work I worked around the issue using the `RedirectMatch` directive.


    SetOutputFilter  proxy-html

This puts all incoming HTML-type responses through `mod_proxy_html`'s HTML filter.


    ProxyHTMLDocType "<!DOCTYPE html>"

The `mod_proxy_html` module scraps doc types. This adds the HTML5 doc type.


    ProxyHTMLURLMap  ^/assets http://app.example.com/assets R
    ProxyHTMLURLMap  ^/system http://app.example.com/system R

This rewrites all references to assets and `/public/system` files to absolute URLs which go directly to the backend server. Just have look at the resulting HTML.


    ProxyHTMLURLMap  /engine-name/ /app/

Finally, replace all references to the backend server's path to the proxy path.


    RequestHeader    unset Accept-Encoding

Browsers might have difficulties displaying/decoding the response. To handle this, I reset the `Accept-Encoding` header.
