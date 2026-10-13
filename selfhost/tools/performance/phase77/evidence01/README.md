# Phase77 evidence capsule

Sealed after all compiler target writers completed. The manifest contains7,117
file records and2,720 unique SHA256 objects:343,427,948 uncompressed bytes,
37,617,054 compressed bytes in two parts. Every object and original file was
rehashed; original file modes were checked and recorded. No target source or
measurement was modified during sealing.

The archive SHA256 is
`a781f5dc45fe709c06553e39469a049b923e0db65f4fd2618d8502b7307ca6ce`.
The manifest SHA256 is
`5649c783a6ed8e6cefaa7125f574511719a8a1824eaa0c208966e99a51873443`.
See [verification.json](verification.json) for split-part hashes and sizes.

Use the parent [restore instructions](../README.md#evidence-restore). Outputs,
failed attempts, exact candidate source snapshots, profiles and method bytes
are included. Private usage files and Python bytecode caches are excluded;
older phase baselines, upstream and toolchains remain external dependencies.
The alias-refusal test's temporary symlink was removed after the control passed;
`selfhost/build/phase77/pre-seal.json` records its target and unchanged source hash.

The selected compiler release and report are commit `60bb45f`. The installed
release's local lineage verification does not require unpacking this archive.
