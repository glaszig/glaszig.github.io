---
layout: blog_post
title: "FactoryGirl? FactoryBot? The Gender War Is On."
date: 2017-10-23 17:00:03 +0200
tags: [ tech, gender, ruby, gem ]
---

[FactoryGirl][factory_girl] was a ruby gem to help test automation. It followed
the [SemVer][semver] approach to release versioning and scheduling. At least
until version 4.8.2 in which they replaced all occurrences of `[Gg]irl` with
`[Bb]ot`. They then yanked version 4.8.2 off of rubygems and renamed the entire
library to `factory_bot`.

This chain of disorganized, hectic decissions led to [quite a few][broken-1]
[software builds][broken-2] [breaking][broken-3] because version 4.8.2 could not
be found anymore. While that is a five-minute-problem to fix the basis for this
entire ordeal was that [someone on the internet][gh-issue] felt disturbed in
their safe space by a utility which solved a real problem _for years_; [the name
of which][naming] was inspired by a [symbol for feminism][rosie] in american culture.

I, and I'm sure many others, always enjoyed working in software because the
inherent scientifically defined approaches didn't care much about some abstract
socio-political nonsense. But gender equality (which is code for "feminism
ftw for the sake of it" and spreads like wild fire into the realms of diversity)
has infiltrated the open source community.

Not only that, it takes the form of politicising non-issues and even going so
far as becoming recursive, fighting its own means as demonstrated by this very
instance, enforcing their newspeak by way of eradicating any subjective and
objective differentiation of men, woman, bot and whatever onto just another part
of society. You really cannot hide on the internet.

All of this wouldn't be as bad as it has become if certian people would have
the guts and spine to stand up to this madness. But they are happy to throw
proven processes over board just to appease the Gods of Gender, the Lords of
Diversity, the Spirits of Micro-Aggressions.

If I ever happen to maintain a project with the words "girl", "man" or
"undefined" as parts of its name or code _and_ you give **sane** and **reasonable**
explanations why those are a real problems and should be replaced, I'll do so.

Until then, go fix a real issue. Go get a life.

[semver]: https://robots.thoughtbot.com/maintaining-open-source-projects-versioning
[broken-1]: https://github.com/thoughtbot/factory_bot/issues/1055
[broken-2]: https://github.com/EBWiki/EBWiki/issues/1072
[broken-3]: https://github.com/theforeman/foreman/pull/4935
[naming]: https://robots.thoughtbot.com/waiting-for-a-factory-girl
[factory_girl]: https://github.com/thoughtbot/factory_girl
[gh-issue]: https://github.com/thoughtbot/factory_bot/issues/921
[rosie]: https://en.wikipedia.org/wiki/Rosie_the_Riveter
