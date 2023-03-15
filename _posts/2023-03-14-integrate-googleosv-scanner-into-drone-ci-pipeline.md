---
layout: blog_post
title: integrate google/osv-scanner into drone ci pipeline
date: 2023-03-14 22:51:21 -0300
tags: [ tech, docker, drone, owasp, security, google ]
---

in my [drone ci][drone.io] pipeline i use the following step to run
[google's osv-scanner][osv-scanner] and send an email if vulnerabilities
have been found.

```yaml
steps:

  # ....
  
  - name: vulnerability scan
    failure: ignore
    image: anmalkov/osv-scanner
    commands:
      - osv=$(/root/osv-scanner --skip-git .) || status=$?
      - |
        test -z "$status" || sendmail -t -i -f $MAIL_FROM <<MAIL
        From: $MAIL_FROM
        To: $MAIL_RECIPIENTS
        Subject: $MAIL_SUBJECT

        $osv
        MAIL
      - echo "$osv"
    environment:
      SMTPHOST: "12.34.45.56:25"
      MAIL_FROM: ci@example.com
      MAIL_RECIPIENTS: security@example.com
      MAIL_SUBJECT: "[ALERT] vulnerabilities in ${DRONE_REPO}"
  
  #...
```

what this does:

- pull the [anmalkov/osv-scanner][anmalkov] container
- run `osv-scanner` and save the output or, on failure, save the return code
- if the return code is not empty, thus vulnerablities have been found,
  send the output to the email addresses in `$MAIL_RECIPIENTS`
- echo the output

you'll need to configure a proper `SMTPHOST` and adjust the the other
environment variables.

> **note**: the step configuration above will _only_ notify you via email.
> to stop the pipeline you'll need to make on of the commands produce a
> non-zero return code and remove the `failure: ignore` option.

[drone.io]: https://www.drone.io
[osv-scanner]: https://github.com/google/osv-scanner
[anmalkov]: https://hub.docker.com/r/anmalkov/osv-scanner/
