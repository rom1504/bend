# Phase61 — select primitive metadata without rebuilding its table

Status: independently reviewed Bend source candidate, applied by root authorization;
focused primitive/seed controls passed; no speed or release claim. The installed
Phase58 last01 compiler remains the baseline. Root owns all checked builds and targets.

## Claim and falsification

`jd_native_known` and `jd_primitive_candidate_emit` each construct the complete
90-row `JDPrimitive` list before selecting one row. Phase59 diagnostic counts
observed 711/2595 table constructions on Lexer/Evening; those counts identify
source opportunities, not physical V8 allocations or a promised speedup.
A compiler-private exact-name selector can construct only the selected row.
The hypothesis fails on any metadata, native-admission, template or emitted-output
difference, material source-check latency regression, or negligible measured gain.

## Candidate and unchanged proof

[Source and patch](../../selfhost/tools/performance/phase61/primitive/) retain the
canonical table and linear lookup APIs unchanged for differential probes. Nine
bounded selector helpers contain ten rows each. Lazy `kc` alternatives test the
same names in the same order and return the same empty row on a miss. No persistent
cache or runtime dispatch is added. Only the two production table lookup sites
change. Every template and placeholder substitution remains byte-identical.

The selector supplies metadata, never native authority. Existing checked Def kind,
native flag, zero templates, non-Foreign body, exact name, bounded live telescope,
erased-binder treatment and supplied argument count remain in admission. Same-named
user definitions stay ordinary. The deliberate call-site refusal of `String.eq`
is unchanged. This is general compiler metadata selection, not a program selector.

## Gates

`controls02.mjs BASELINE_ATTEMPT CANDIDATE_ATTEMPT NEW_OUT` verifies genuine checked
attempts and snapshot source identities, appends private diagnostic exports to
exact API copies and compares the candidate selector against the real baseline table plus pinned
source rows; dead canonical helpers are not required in the candidate image. It
checks all 90 rows, unknown/near-miss names, seven admission
variants per row, wrong supplied argument counts and String.eq refusal. Synthetic
KDefs test predicates only; they are not evidence of checked-source acceptance.
Follow with ordinary checked-source conformance, exact compiler emission equality,
and a small clean/warmed compiler comparison selected by root. The source report
pins both primitive files. Runtime and host files are unchanged.

## String transport avenue remains separate

Native String match currently computes a head using `codePointAt`/index/slice and
a tail using `codePointAt`/slice. Replacing a proved `SCon{head,tail}` reconstruction
with its original immutable string appears attractive, but an overridden `slice`
can return a different tail. Merely preserving extraction calls does not establish
value identity. A metadata origin fact alone is insufficient under that host domain.
A future transformation needs an explicit accepted intrinsic domain or a sound
conservative boundary; it must cover astral characters, lone surrogates, mixed
origins, retained aliases, branch scopes, and demanded extraction errors. Constructor
and pattern changes are owned by the lowering agent and are not part of this patch.

Canonical `String.contains`/`starts_with` are ordinary recursive Base definitions,
not existing primitive rows. Substituting JavaScript includes/startsWith also
changes Unicode-codepoint boundary and observable method behavior. That broader
proposal is not silently included in the allocation experiment.

## Separate loader equality counterfactual

`src/load/seed.bend:f_seed_text_equal` compares every SCon head pair and recurses
on both tails. `f_seed_matches` additionally checks the exact source name and path.
Using ordinary `String.eq(a,b)` preserves complete source equality, including NUL,
astral characters and lone surrogates: decoding a UTF-16 sequence to scalar values
plus isolated surrogate values is injective. No normalization or prefix/hash equality
is justified. This differs from substring replacement, where UTF-16 boundary splits
can create false matches.

Direct `jd_definition_native` already gives native String.eq its exact equality
template; call-site emission keeps its named call. Therefore replacing only this
loader helper's body may avoid a long tail scan in direct compiler images without
new native authority. Root owns this source and any application. The other compiler
image roles must establish actual native String.eq behavior and long-input stack
safety separately; mutated legacy G hooks cannot be assumed irrelevant. Test equal
long Base text, early/middle/final mismatch, empty text, Unicode/surrogate differences,
NUL, and mismatching seed paths before a loader reuse claim.
