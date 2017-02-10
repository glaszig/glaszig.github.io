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

So, while the Python community will spend 3 more years [figuring shit
out][gh-issue] set the environment variable `PIP_USER=y` or create a [pip][pip]
[config file][docs] `~/.pip/pip.conf` with the following content:

{% highlight ini %}
[install]
user = true
{% endhighlight %}

From now on `pip install <package-name>` will always install packages into your
home (that's `~/Library/Python` on macOS) and you can throw shit away easily.

While this should be enough for the occasional python developer consider using
[virtualenv][virtualenv] (which is equivalent to [bundler's `--path`
option][bundler-path]) for more complex setups.  
And when your OS's Python version is not enough use [pyenv][pyenv] (which is 
the equivalent to the Ruby version manager [rbenv][rbenv]) to run multiple
Pythons without conflicts.

## Further reading

- [Ubuntu 14.04 Python 3.4.2 Setup using pyenv and pyvenv][tut-1]
- [Better Python version and environment management with pyenv][tut-2]

[gh-issue]: https://github.com/pypa/pip/issues/1668
[pip]: https://pip.pypa.io/en/stable/
[docs]: https://pip.pypa.io/en/stable/user_guide/#config-file
[virtualenv]: https://virtualenv.pypa.io
[bundler-path]: http://bundler.io/v1.14/man/bundle-install.1.html
[pyenv]: https://github.com/yyuu/pyenv
[rbenv]: https://github.com/rbenv/rbenv
[tut-1]: http://fgimian.github.io/blog/2014/04/20/better-python-version-and-environment-management-with-pyenv/
[tut-2]: https://gist.github.com/softwaredoug/a871647f53a0810c55ac
