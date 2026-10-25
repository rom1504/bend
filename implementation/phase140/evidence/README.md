# Phase140 compact evidence

Use [components02/index.json](components02/index.json) and its
[metadata archive](components02/metadata.tar.gz) for the initial completed
component and integrated hosted screen. The index preserves original absolute
identities and maps them to relative archive members; every archived member was
roundtrip-checked byte for byte. [costs.json](components02/costs.json) sums outer
guards without adding nested API times again.

Large compiler-source/API/QBE/executable payloads are not included. Their exact
recorded identities and whether the current workspace matched are explicit.
Frozen small module/method copies preserve earlier versions when working tool
paths changed. This is evidence retention, not a new qualification certificate.

`components01` is superseded metadata from the first archiver: a relative versus
absolute path spelling caused identical contents to be labeled mismatched.
`archive-v02.py` fixes content comparison and maps all actual earlier versions to
matching frozen archived members. No target was rerun to fix the inventory.

Later native results should be a fresh additive archive, using the script's
`--root` / `--no-default-roots` options. Do not mutate these completed snapshots.

[Native preflight01](native-preflight01/index.json) adds source/API01–03 and the
33 successful runner/framing/source-cut controls. It deliberately excludes the
still-running native acquisition. Its three API guards are additional to the
components02 ledger; none are added twice there.
