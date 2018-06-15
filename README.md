# nextstrain.org/zika

**This is currently a preliminary example of moving pathogen builds to
independent repositories.  It is not currently used for the live site.**

This is the [Nextstrain][] build for Zika, visible at
<https://nextstrain.org/zika>.

The build encompasses fetching data, preparing it for analysis, doing quality
control, performing analyses, and saving the results in a format suitable for
visualization (with [auspice][]).  This involves running components of
Nextstrain such as [fauna][] and [augur][].

All Zika-specific steps and functionality for the Nextstrain pipeline should be
housed in this repository.


[Nextstrain]: https://nextstrain.org
[fauna]: https://github.com/nextstrain/fauna
[augur]: https://github.com/nextstrain/augur
[auspice]: https://github.com/nextstrain/auspice
