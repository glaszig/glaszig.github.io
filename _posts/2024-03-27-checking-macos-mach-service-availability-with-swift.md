---
layout: blog_post
title: "Checking (macOS) Mach Service Availability with Swift"
date: 2024-03-27 19:10:43 -0300
tags: [macos, swift, xcode]
---

Testing for mach ports is useful if you have an app that talks to an XPC service,
agent or daemon and you'd like to check for availability of the endpoint before
pulling out an entire `NSXPCConnection`. This would, for example, allow you
to show a progress indicator while the app waits to pull data over XPC into the UI.

Looking for a way to check if a mach service is reachable (or rather,
[launchd][launchd] knows about it), you'll [find][l1] [lots][l2] of C or
Objective-C code.

Swift lets you call C functions but the trouble with Swift is that "complex macros"
are not available but `task_get_bootstrap_port` and `mach_task_self()` 
are defined as such:

```c
#define task_get_bootstrap_port(task, port)     \
          (task_get_special_port((task), TASK_BOOTSTRAP_PORT, (port)))
```
[source][task_get_bootstrap_port_source]

```c
#define mach_task_self() mach_task_self_
```
[source][mach_task_self_source]

Both are "complex macros" and therefore not callable from Swift. Yikes.

## Option 1

Write your own C helpers. Beware that they cannot have the name of the originals
because there already are macros with the same name. You'll also need a bridging
header (which Xcode takes care of for you when you add a C file to your project).

```c
// mach_compat.h

#include <mach/mach.h>
mach_port_t
mach_task_current(void);

kern_return_t
task_get_bs_port(task_inspect_t task, mach_port_t *special_port);
```

```c
// mach_compat.c

#include "mach_compat.h"

mach_port_t
mach_task_current() {
    return mach_task_self();
}

kern_return_t
task_get_bs_port(task_inspect_t task, mach_port_t *special_port) {
    return task_get_special_port(task, TASK_BOOTSTRAP_PORT, special_port);
}
```

And use them like this:

```c
mach_port_t service_port = MACH_PORT_NULL;
task_get_bs_port(mach_task_current(), &service_port)
```

## Option 2

Simply do what the macros do.

The slightly trickier part was `mach_task_self()`. XNU's version gives you
`mach_task_self_` which mach initializes with the return value of `task_self_trap()`.
Using `mach_task_self_` directly is possible but ugly.

So I came up with the following:

```swift
func machServiceAvailable(_ endpoint: String) -> Bool {
    var srv_port = mach_port_t(MACH_PORT_NULL)
    var bs_port = mach_port_t(MACH_PORT_NULL)
    task_get_special_port(task_self_trap(), TASK_BOOTSTRAP_PORT, &bs_port)
    let result = bootstrap_look_up(bs_port, endpoint, &srv_port)
    return KERN_SUCCESS == result
}
```

## Option 3

Do none of the above.

XNU actually stores the current tasks bootstrap port in `bootstrap_port`:


```swift
func machServiceAvailable(_ endpoint: String) -> Bool {
    var srv_port = mach_port_t(MACH_PORT_NULL)
    let result = bootstrap_look_up(bootstrap_port, endpoint, &srv_port)
    return KERN_SUCCESS == result
}
```

See the PoC for CVE-2018-4280 for a [neat implementaion of almost the same][l3].

For a deeper understanding of those things I recommend [Technical Note 2083][tn2083].


[launchd]: https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html#//apple_ref/doc/uid/10000172i-SW7-BCIEDDBJ
[l1]: https://stackoverflow.com/a/64630840/683728
[l2]: https://fdiv.net/2019/08/17/making-mach-server
[l3]: https://github.com/bazad/blanket/blob/22d670d25b8ab5ad569c3f8f4de108ae8e0b6e0a/blanket/launchd/launchd_service.c
[task_get_bootstrap_port_source]: https://github.com/apple-oss-distributions/xnu/blob/1031c584a5e37aff177559b9f69dbd3c8c3fd30a/osfmk/mach/task_special_ports.h#L116
[mach_task_self_source]: https://github.com/apple-oss-distributions/xnu/blob/1031c584a5e37aff177559b9f69dbd3c8c3fd30a/libsyscall/mach/mach/mach_init.h#L83
[task_self_trap_source]: https://github.com/apple-oss-distributions/xnu/blob/1031c584a5e37aff177559b9f69dbd3c8c3fd30a/libsyscall/mach/mach_init.c#L135
[tn2083]: https://developer.apple.com/library/archive/technotes/tn2083/_index.html#//apple_ref/doc/uid/DTS10003794-CH1-SUBSECTION10
