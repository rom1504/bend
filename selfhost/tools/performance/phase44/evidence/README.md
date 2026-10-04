# Phase44 release evidence

[The index](selected-release.json) binds the installed checked04 API, fresh named
qualification, runtime and compiler-cost summaries, protected inputs and the
[closed raw archive](raw/archive.json). The qualification receipt predates
installation and intentionally says `installed: false`; the separate
[installed checks](installed-release.json) bind the subsequent normal install,
release verification and 42 CLI checks to the same API.

The archive is streamed, reopened and checked against all original file hashes.
It preserves every regular file below `selfhost/build/phase44`, including failed
attempts, raw timing samples, profiles and the rejected JavaScript experiment.
No writes to that raw root are authorized after writer closure. The reusable
[baseline](../baseline/manifest.json) and [current](../current/manifest.json)
program bundles are separate portable artifacts.

To inspect the complete campaign from the repository root, extract into a fresh
directory (never over an existing campaign):

```sh
mkdir -p selfhost/build/phase44-recovered-NEW
tar -xzf selfhost/tools/performance/phase44/evidence/raw/raw-campaign.tar.gz \
  -C selfhost/build/phase44-recovered-NEW
```

Raw receipts retain original absolute execution paths; archive member names are
relative to the campaign root. Recovered paths do not authorize rewriting those
receipts. Use the portable bundle guide for new measurements.

The [report](../../../../../implementation/phase44/README.md) gives the measured
outcome and limits. Eight maintained semantic suites and the current frontend,
backend, composition and timing gates are freshly bound; Phase43's separate
34-owner/41-group historical campaigns are not claimed as new Phase44 runs.
