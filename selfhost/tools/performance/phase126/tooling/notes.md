# Tooling boundary and disk budget

The baseline is `implementation/phase125/candidate.json`: checked hosted source
SHA256 `d1399234ad28a3d03ee06fdad436a1585278bcbaea127425a226b5ceb79029b2`
and its independently qualified N1/N2 checkpoint. New overlays preserve original
request-bound admission and verifier bodies. Name inventories are a composition
guard, not a proof of new transformations: each prototype still needs checked
Bend, its own semantic review and ordinary output controls.

The prepared manifest follows the established Phase118 exact source replay
contract. Only actual overlay files appear as additional `.bend` inputs; the
verifier authority pin has its own field so replay does not treat it as a module.
Explicit replacements include private emitters. No host code selects arithmetic,
rewrites generated C, transforms semantic IR or supplies ownership certificates.

Before deduplication the volume had about399MiB free. The authorized scoped
byte/hash audit replaced43 duplicate paths with hardlinks, reclaiming13,447,168
allocated bytes. The93MB native SSA pair,69MB assembly pair and20MB object pair
were already hardlinked, so they reclaim zero additional bytes. There is no
200MiB deduplication opportunity in the audited Phase125 scope. Exact path,
hash, inode, byte comparison and replacement records are in `tooling-dedup01`.

Use the64MiB per-file limit for small acquisition/emission/screens: guard startup
requires more than288MiB free. The128MiB limit requires more than416MiB, above
the roughly409MiB remaining after this bounded cleanup. Each attempt retains
its source/API/SSA/assembly/object/binary and small failed receipts; watch actual
headroom and do not start a full native image from this budget. A full checkpoint
would separately need the established6GiB RSS/16GiB available-memory limits and
128MiB file cap, justified by the earlier5.159GiB image acquisition.
