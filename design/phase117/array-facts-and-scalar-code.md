# Phase117 — preserve facts in QBE's hot loops

2026-10-21, parent `6703ff7`, authorized optimization window 1–2 hours.

Phase116 measures repeated array checks/decoding in fold and edit distance,
shared ownership in map/tree/text, and unnecessary scalar arithmetic in numeric
loops. Start with arrays: this is a measured hot path with an existing checked
scalar/unshared certificate. The certificate does not automatically establish
raw/dynamic representation, so retain every check not independently justified.

## Bounded sequence

1. Independently audit the certificate against runtime representation. Try the
   smallest structured-Bend change that removes redundant scalar checks and
   exposes invariant array metadata. Preserve original admission and final IR
   verification, wrapped indexing, static/shared fallbacks, ownership and ordering.
2. Acquire a checked hosted API from exact qualified Phase114 source02 plus an
   explicit declaration overlay. Emit and build fold128 and edit distance under
   the existing resource guard. Compare complete output to the frozen independent
   Phase112 oracle; compare runtimes in alternating serial rounds with upstream
   and unchanged Phase114 products. Inspect actual machine shape.
3. If profitable, extend array transfer coverage and unrelated controls. Try
   hoisting or coherent scalar lifetime specialization only if the first result
   identifies a concrete next cost. A separate small general arithmetic identity
   can be investigated concurrently by source review, with target runs serialized.
4. Record rejected attempts and exact source/toolchain/runtime identities. Retain
   only demonstrated transformations; broaden qualification only for survivors.
   Full native self-reproduction is justified only after meaningful transfer and
   available disk. Installed selection stays unchanged without its own qualification.

## Ambition and stopping rules

The immediate aim is eliminating repeated proof work, not policy search. A larger
extension would keep base/mask/layout facts across loop iterations; the long-term
extension unifies typed array allocation/access/destruction. These are alternative
scopes, not promised speedups. Preserve the 64-bit Term ABI until all affected
creation, clone, fallback and drop operations have a coherent replacement.

Two agents may perform bounded source/proof audits while the root owns one CPU3
execution lane. Use 2GiB RSS / 16GiB available memory floor / 64MiB file caps and
existing guards. Disk is tight (~330MiB), so reuse exact frozen products and avoid
full compiler images unless warranted. No PR comments. Account for compilation,
execution, qualification, research time and added compiler complexity separately.
