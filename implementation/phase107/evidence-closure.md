# Phase107 evidence publication

The capsule contains16,155 files and passed creation-time streaming checks and
a separate `--verify-only` run. All three published files total41,831,963 bytes
(41.83MB), below the100MB bound. The compressed archive is22,374,689 bytes, SHA256
`70afb53218a3dd365de741fe6412501f2da2b9d60ffb0334788bbe1a983bc11a`.

[Manifest](evidence/manifest.json) · [Archive](evidence/observations.tar.gz) ·
[Checksums](evidence/FILES.sha256) · [Closure receipt](evidence-closure.json) ·
[Restoration policy](manifest-policy.md).

The manifest explicitly inventories219 exclusions,1,802 unmatched reference
occurrences and26 preserved malformed JSON controls. Unmatched references include
external tools, historical versions and intentionally invalid control pins; they
are not all missing prerequisites. This is a preserved experiment snapshot, not a
hermetic toolchain or a new compiler qualification. The selected native image04
is retained; other large rebuildable products keep identities and recorded recipes.

The first preparation failed before creating an output directory because repeated
content-match lists exceeded the metadata budget. The corrected packer interns
2,915 distinct match keys across21,057 reference occurrences, preserving their
original receipt paths, JSON locations and declared identities. The original
method and failure note are inside `selfhost/build/phase107/archive-attempt01`.

Successful archive preparation took36.118s under a separate CPU0 guard, with
155,840,512 bytes sampled peak process-tree RSS. This publication activity follows
the compiler-target cutoff in [accounting](accounting.md) and is not added to its
148 target/control receipts. No compiler or generated program ran during packing.
This closure file is outside the capsule so it can bind the finished manifest and
archive without circular hashes. No PR comment was posted.
