# Scoped observer permission experiment

This is an offline source derivative, not an installed optimization. The root
agent owns all compiler, checker and native-program executions.

`prepare.py --out selfhost/build/phase98/FRESH` authenticates D04, creates the
candidate and five reversible exact source edits, and writes an unapplied patch
for the three maintained modules. The frozen first output is
`selfhost/build/phase98/observer-permission-source01/changes.json`.

The new certificate accepts only the nine authenticated Base providers already
supported by the native host. It does not authorize arrays, scalar narrowing,
constructor-cold annotations or foreign calls inside an observer. Existing raw
and legacy entry signatures remain. The native host's external byte checks are
still required; this internal Bool argument is not a security boundary.

First run `qualification.json`'s cheap admission controls and inspect actual
emitted observer calls with typed scalars and packed arrays still disabled.
Use the existing held I/O control and existing comparison corpus before any
full compiler image. A separate shared-string/generic-array control below
checks that unrelated generic arrays do not disable string borrowing. Preserve
every first attempt and source admission failure; no target has run here.

`permission-cases.json` contains direct finite API expressions for the exact
new helper. These are admission tests, not a proof of provider authenticity or
native lifetime. `qualification.json` lists the additional raw/schema/provider
boundaries; it is a plan, not an execution receipt.

The report is [observer-permission.md](../../../../../../implementation/phase98/observer-permission.md).

Root's bounded executable qualifier is now frozen:

```sh
python3 -B selfhost/tools/performance/phase98/observer-permission/qualify-v2.py \
  --recipe selfhost/build/phase98/observer-permission-source01/changes.json \
  --out selfhost/build/phase98/observer-permission-qualify01
```

It checks two upstream-generated JS testing APIs from exact baseline/candidate
source,18 exact helper cases, both checked entries, false/raw permissions,
changed/unknown providers, old raw negatives, emitted policies/borrowed routes,
then builds and executes seven small C programs serially. The full compiler
Clang build is unnecessary. The API check guards allow4GiB RSS and require16GiB
available; small native targets use lower limits. No concurrency. Full-output
checks are exact; one API-emission timing per role is diagnostic only.

The first `--prepare-only` attempt stopped because PATH lacked Node; no target
ran. V1 and its failure remain. V2 names and pins Node explicitly, and successful
data-only preparation is at `observer-permission-qualifier-plan02`. Its methods
are pinned by `qualifier-v2-freeze.json`. The executable uses
`generic-array-string-v2.bend`, which exposes the known recursive equality
walker explicitly; original source and original qualification plan remain.
The12-group plan additionally includes existing laws/lifetime corpus, profiling
and real-image measurements; this small qualifier does not claim those are done.
