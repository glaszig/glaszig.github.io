---
layout: blog_post
title: "su: pam_start: System error (FreeBSD 14)"
date: 2025-03-17 18:05:19
tags:
  - freebsd
  - pam
  - jail
---

After upgrading a FreeBSD system or jail to version 14-RELEASE it may happen
that any command involving PAM will fail with the following error:

    su: pam_start: System error

It will even fail silently when using `ezjail-admin console <jail-name>` and
just not open a jail console.

## Problem

The reason probably is that your system or jail has the OPIE plugin
configured in its PAM config in `/etc/pam.d/system` (or any other file in `/etc/pam.d`):

```
# ...
auth          sufficient      pam_opie.so             no_warn no_fake_prompts
auth          requisite       pam_opieaccess.so       no_warn allow_local
# ...
```

[OPIE][opie] means One Password In Everything and implements an OTP mechanism.
In FreeBSD 14 this PAM plugin was [deprecated][deprecated] and eventually
[has been][review] [removed][list].

## Solution

Dependending on your requirements you can do the following:

- If you don't explicitly need OPIE, completely remove the plugin by removing
  the respective lines from `/etc/pam.d/system`
- If you depend on OPIE, you can install the plugin from ports via
      
      make -C /usr/ports/security/opie install clean

[opie]: https://rho.cc/Linux/opie.html
[deprecated]: https://wiki.freebsd.org/DeprecationPlan#FreeBSD_14
[review]: https://reviews.freebsd.org/D36592
[list]: https://lists.freebsd.org/archives/freebsd-security/2022-September/000081.html
[forum]: https://forums.freebsd.org/threads/pam-broken-in-jails-after-update-to-14-0-release.92314/
