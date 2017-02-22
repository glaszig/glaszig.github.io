---
layout: blog_post
title: 'FreeBSD: /usr/local/lib/libpkg.so.3: Undefined symbol "utimensat"'
date: 2017-02-18 19:00:41 +0100
tags:
  - tech
  - FreeBSD
  - pkgng
---

> **TL;DR**  
> Fix your pkgng repo url to prevent pkg from installing incompatible binaries,
> e.g. `http://pkg.FreeBSD.org/${ABI}/release_2` for x.2.

When installing a binary package on FreeBSD 10.2 I got the following error.

{% highlight sh %}
# sudo pkg install -y tmux
Updating FreeBSD repository catalogue...
FreeBSD repository is up-to-date.
All repositories are up-to-date.
Checking integrity... done (0 conflicting)
The following 2 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
  tmux: 2.3_1
  libevent2: 2.1.8

Number of packages to be installed: 2

The process will require 3 MiB more space.
[1/2] Installing libevent2-2.1.8...
[1/2] Extracting libevent2-2.1.8:   0%/usr/local/lib/libpkg.so.3: Undefined symbol "utimensat"
{% endhighlight %}

The internet will tell you that, of course, [10.2 is EOL][10.2-eol], that packages
are being [built for 10.3][built-for-10.3] by now and to [better upgrade to the latest version][upgrade-to-latest]
of FreeBSD.

While all of this is true and running the latest versions is generally
good advise, in most cases it is unfeasible to do an entire OS upgrade just to
be able to install a package.

## The Real Story

You probably have a FreeBSD package repo which points to the `latest` branch
in the packages repo:

{% highlight sh %}
# cat /usr/local/etc/pkg/repos/FreeBSD.conf
FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest",
  enabled: yes
}
{% endhighlight %}

Note the `ABI` variable which is resolved to the [**A**pplication **B**inary
**I**nterface][abi] version of your OS at run-time:

{% highlight sh %}
# pkg config abi
FreeBSD:10:amd64
{% endhighlight %}

This means the repo url ends up being
`http://pkg.FreeBSD.org/FreeBSD:10:amd64/latest`.  
Now, if you have 10.2 installed and 10.3 is the current latest FreeBSD version,
this url will point to packages built for 10.3 resulting in the problem that,
when running `pkg upgrade pkg` it'll go ahead and install the latest version
of `pkg` build for 10.3 onto your 10.2 system.

{% highlight sh %}
# pkg --version
1.9.4
{% endhighlight %}

Yikes! FreeBSD 10.3 and pkgng broke the ABI by introducing new symbols,
like `utimensat`.

## The Real Solution

Have a look at the actual repo url [`http://pkg.FreeBSD.org/FreeBSD:10:amd64`][10-repo-url]... there's repo's for each release!

Instead of going through the tedious process of upgrading FreeBSD you just need to

**Use a repo url that fits your FreeBSD release:**  
{% highlight json %}
FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/${ABI}/release_2",
  enabled: yes
}
{% endhighlight %}

**Update the package cache:**  
{% highlight sh %}
# pkg update
{% endhighlight %}

**Downgrade pkgng (in case you accidentally upgraded it already)**  
{% highlight sh %}
# pkg --version
1.9.4
{% endhighlight %}

{% highlight sh %}
# pkg delete -f pkg
Checking integrity... done (0 conflicting)
Deinstallation has been requested for the following 1 packages (of 0 packages in the universe):

Installed packages to be REMOVED:
  pkg-1.9.4_1

Number of packages to be removed: 1

The operation will free 10 MiB.

Proceed with deinstalling packages? [y/N]: y
[1/1] Deinstalling pkg-1.9.4_1...
[1/1] Deleting files for pkg-1.9.4_1: 100%
{% endhighlight %}

{% highlight sh %}
# pkg install -y pkg
The package management tool is not yet installed on your system.
Do you want to fetch and install it now? [y/N]: y
Bootstrapping pkg from pkg+http://pkg.eu.FreeBSD.org/FreeBSD:10:amd64/release_2, please wait...
pkg-static: warning: database version 33 is newer than libpkg(3) version 31, but still compatible
Installing pkg-1.5.4...
Extracting pkg-1.5.4: 100%
Message for pkg-1.5.4:
If you are upgrading from the old package format, first run:

  # pkg2ng
Updating FreeBSD repository catalogue...
pkg: Unable to downgrade "FreeBSD" repo schema version 2013 (target version 2011) -- change not found
pkg: need to re-create repo FreeBSD to upgrade schema version
Fetching meta.txz: 100%    944 B   0.9kB/s    00:01
Fetching packagesite.txz: 100%    5 MiB 892.0kB/s    00:06
Processing entries: 100%
FreeBSD repository update completed. 24162 packages processed.
pkg: warning: database version 33 is newer than libpkg(3) version 31, but still compatible
Updating database digests format: 100%
Checking integrity... done (0 conflicting)
The most recent version of packages are already installed
{% endhighlight %}

{% highlight sh %}
# pkg --version
1.5.4
{% endhighlight %}

**Install your package**  
{% highlight sh %}
# pkg install -y tmux
Updating FreeBSD repository catalogue...
FreeBSD repository is up-to-date.
All repositories are up-to-date.
pkg: warning: database version 33 is newer than libpkg(3) version 31, but still compatible
Checking integrity... done (0 conflicting)
The following 2 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
  tmux: 2.0
  libevent2: 2.0.22_1

The process will require 2 MiB more space.
[1/2] Installing libevent2-2.0.22_1...
[1/2] Extracting libevent2-2.0.22_1: 100%
[2/2] Installing tmux-2.0...
[2/2] Extracting tmux-2.0: 100%
{% endhighlight %}

There you go. Don't fret. But upgrade your OS soon ;)

[abi]: https://en.m.wikipedia.org/wiki/Application_binary_interface
[10.2-eol]: https://github.com/bapt/indexinfo/issues/8
[built-for-10.3]: https://github.com/freebsd/pkg/issues/1451#issuecomment-275868439
[upgrade-to-latest]: https://github.com/freebsd/pkg/issues/1526
[10-repo-url]: http://pkg.FreeBSD.org/FreeBSD:10:amd64
