# Wider borrowed records: bounded compiler-query falsifier

Frozen final Phase131 source `1bc5930e…` remains unchanged. This experiment
copies it and raises exactly four field-count bounds from8 to16: `nol_fields`,
`nol_ctor_fields`, `p131rg_width`, and the derived-import contract in
`p118b_project_borrow`. All91 protected verifier declarations are byte-identical.
Runtime, native calling conventions, buffer verification and the late inline
field template remain unchanged. Wider field reads use the existing runtime
helper, which checks the actual constructor and exact field count.

The width audit established that8 was an admission limit, not a physical ABI
limit: the existing scratch buffer holds2,048 bytes and16 fields require128.
Constructor-count, parameter-count, continuation and packed single-field limits
are separate and are not widened. See
`selfhost/tools/performance/phase131/regions/identity-width-audit.md`.

Two small programs share independent ordinary controls. The first copies the
actual selected KTerm/KDef representation and `dn`/`da` declarations, then asks
the whole scalar query `String.eq(dn(record),key)`. KDef's main constructor has
nine fields; its index constructors remain present. The second uses an unrelated
nine-field record with opaque lists and a KTerm payload. A sixteen-field record
is an additional ordinary positive control. Timed queries retain the records,
perform one name hit and one miss, and return one per iteration. Ordinary
controls also check retained arity, opaque list length, empty-name index leaves,
separately spelled equal names and Unicode. Expected outputs are derived from
the fixture constructors rather than target outputs.

The initial finite test accidentally used **emitter** constructor IDs as the
independent verifier catalogue. Even its existing eight-field positive failed,
revealing the test mistake before native execution. The failed API/finite
receipts and `controls.bend` are retained. `controls-v02.bend` uses the actual
`p111v_put` verifier metadata; compiler overrides did not change. It passes all17
predicates, including8/9/16 acceptance,17 and packed refusal, mismatched/unknown
constructor refusal, state/result type refusal, insufficient/unknown buffer
refusal,128-byte buffer acceptance, and continued refusal of the wider late
inline template. Malformed/dependent telescope rules remain unchanged; this is
not an exhaustive proof over all possible record declarations.

Candidate source `5b889d04…` checks through the independent upstream-built API
in14.87 guarded seconds, peak2.20GB. Baseline and candidate both emit the two
programs with original parent verification and final independent verification.
All four aligned native products pass the same11-line ordinary oracle; their
combined build/output check takes0.96 seconds. Exact receipts:

- `selfhost/build/phase111/p131-wide-api02/report.json`
- `selfhost/build/phase131/wide-finite02/report.json`
- `selfhost/build/phase118/p131-wide-{baseline,candidate}-emit01/report.json`
- `selfhost/build/phase131/wide-builds01/report.json`

Actual candidate QBE contains new borrowed readers for all three scalar queries.
The KDef reader has292 lines with five static fallback read sites covering its
constructor branches; the unrelated nine-field reader has48 lines/one import,
and the sixteen-field reader62 lines/one import. These readers contain no root
sinks or destructive takes. Their public adapters retain the original guarded
owning fallback and two root sinks. The timed caller still calls the selected
public query directly, so this experiment does not suffer the earlier inlining
bypass. The compiler-kdef QBE grows567,614→593,474 bytes; code size is a cost.

Root-owned timing is prepared in `selfhost/build/phase131/wide-timing01/jobs.json`:
five rotating paired rounds, two families,262,143 iterations. No speedup or
whole-compiler benefit is implied until those measurements complete. In
particular, merely supporting KDef layout does not remove the owned-result
boundary in `p111v_get`/`index_find`; a complete scalar lookup consumer remains a
separate hypothesis.
