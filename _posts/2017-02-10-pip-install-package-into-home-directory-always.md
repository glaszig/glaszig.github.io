---
layout: blog_post
title: "pip: install package into home directory - always"
date: 2017-02-10 01:31:04 +0100
tags:
  - python
  - pip
  - config
---

> **TL;DR**  
> Don't use `sudo pip install <package-name>` like everybody on the internet
> tells you to. Use `pip install --user <package-name>`. To omit `--user`,
> create a `pip.conf` as outlined below.

We Rubyists generally don't install packages via `sudo`. We're not crazy enough
to spill things all over the directories managed by the OS' vendor.

So, while the Python community will spend 3 more years [getting their shit
together][gh-issue] and make it the default, here's a the trick to make it so.

Create a [pip][pip] [config file][docs] `~/.pip/pip.conf` with the following content:

{% highlight ini %}
[install]
user = true
{% endhighlight %}

Or set the environment variable `PIP_USER=y`.

From now on `pip install <package-name>` will always install packages into your
home (that's `~/Library/Python` on macOS) and you can throw shit away easily.

[gh-issue]: https://github.com/pypa/pip/issues/1668
[pip]: https://pip.pypa.io/en/stable/
[docs]: https://pip.pypa.io/en/stable/user_guide/#config-file
