# Phase51 preserved evidence

[selected-qualification.json](selected-qualification.json) joins the installed
compiler/runtime, semantic resolution, full comparison and portable replay.
The original failed semantic queue is preserved; the native retry is an explicit
resolution, not a relabeled first-run success. The
[phase report](../../../../../implementation/phase51/README.md) explains scope.

- [Installed release](installed-release.json): focused checked attempt, maintained
  eight suites, installation/verification, 42 ordinary/relocated CLI checks.
- [Semantic resolution](semantic-qualification.json): 60 accepted outcomes plus
  21 fresh native outcomes; 69 execution passes, eight N/A, four shared failures.
- [Full results](runtime-summary.json): all 45 points / 669 samples, exact module
  and protocol identities, all medians and regressions.
- [Static counts](accounting.json) and [time use](time-use.json): separate source
  complexity proxies and process occupancy, with their method limits.
- [Portable bundles](../bundles/publication.json): exact generated modules,
  unchanged compiler-role provenance and reopened archive verification.
- [Protected files](protected-final.json): all 103 pre-existing files unchanged.

The [closed raw capsule](raw/raw-campaign.tar.gz) contains **6,765 files**, including
failed attempts, complete observations, prototypes, checked-source snapshots,
V8 traces, allocation profiles and benchmark samples. Its
[manifest](raw/archive.json) records every member and the verified reopening.
Archive SHA256: `e5963eb689dab80f629d74d9a920266f7b1f4258a5b597be1971eac9dac0cc5c`.
Compressed size: 30,408,739 bytes; uncompressed: 135,669,723 bytes.

Raw writers closed at 08:18:41 UTC on 2026-10-05; see
[writers-closed.json](writers-closed.json). Do not append later observations to
this phase's raw directory. Restore the capsule into a fresh empty directory;
its member names are relative to `selfhost/build/phase51`. Receipts retain the
original absolute workspace paths and external toolchain/parent-artifact pins.
Rebuilding historical qualifications additionally needs those pinned prerequisites;
the capsule does not bundle Node, Clang or every earlier phase.

For routine performance replay, use the [portable guide](../README.md): it needs
the tracked bundles/catalog, Python and pinned Node, without unpacking historical
acquisition directories. Later runs belong in fresh `selfhost/build/phase51-live`
directories. Instrumented derivatives are diagnostics, not clean timing inputs.
