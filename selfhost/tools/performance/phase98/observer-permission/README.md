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
