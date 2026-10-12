# P70-006: do not rebuild occurrence-set entries already present

Registered before proposal construction or target execution. Owner:
`/root/phase69_closures`; independent reviewer: `/root/phase69_review`.
Compiler01 (`ee8463a`) is the current checked checkpoint. Production is untouched
by this source lane. Parent investigation: P70-003.

## Falsifiable claim

`nc_uses` collects variable IDs into a set with one constant KDef payload.
Its current generic `index_set` reconstructs a persistent trie path even when
the same complete U32 ID has already been inserted. Specialize this private
insertion: compute the existing tip/split bit once, return the old set on exact
ID equality, otherwise use the unchanged `index_insert` path. Do not add a
separate membership lookup followed by another full lookup on novel IDs.

Invariant: the collector begins at `missing()` and only inserts its same
`$native.occurrence` marker. Every summary node is produced by the existing
index helpers; no caller imports an arbitrary use-index payload into `nc_uses`.
Full U32 bits are keys, not a lossy hash, and there are no marker-name collisions.
Replacing an entry with the same payload changes neither the exact summary
value nor any ordered live/drop/share output. Traversal, Var-as-leaf behavior,
environment order/duplicates, raw-term handling and fresh/error order remain.

This is different from P68-009 Uses08 (one summary instead of per-environment
term scans), P68-012 Reuse11 (reuse a summary across same-body consumers), and
Facts23 (native fact/admission fallback). It changes neither which term is
scanned nor how often a caller asks for a summary. The global `index_set` remains
unchanged because ordinary indexes must replace varying payloads.

## Budget and fastest disproof

The saved Phase69 B2 profiles attribute 120.7/133.2/135.0 ms to collector stacks
and 52.7–80.9 ms within those stacks to index work. These are overlapping sampled
unions, not clean clocks. The broader methods census includes membership queries
and therefore has a larger 138–151 ms `nc_uses*` budget. B1 attribution is obscured
by trampolines; observed collector stacks are 343.3 ms, not a reliable split of
that time into insertion versus traversal.

If a material fraction of inserted variable occurrences repeats existing IDs,
the expected screen is roughly 1–3% less complete B2 C request time, with no
claim of a larger B1 gain until measured. Duplicate fraction is unmeasured.
Reject this direction if actual insertion counters show few duplicate entries,
the guard costs more on unique-ID trees, or a balanced request screen regresses.

## Gates

1. Independent source review of constant-payload and exact-tip invariants.
2. Checked B1 helper comparison of **entire summary indexes**, all queried IDs,
   ordered partitions and sharing strings. Include repeated/all-unique IDs,
   all U32 boundaries, deep tries, duplicate environments, malformed Var kids,
   branch-heavy terms, unused binders and empty environments. Record actual
   baseline/candidate insert calls separately from uninstrumented clocks.
3. Exact complete C for numeric/array/held-out lexer; preserve diagnostic and
   raw error gates. Existing generated-program evidence can be inherited only
   when all C bytes agree.
4. Root-owned paired checked B1 request screen, then genuine B2 only after a
   surviving small screen. Counter instrumentation earns no speed credit.

Proposal and data-only profile census go under
`selfhost/tools/performance/phase70/compiler-work/`. No new cache, IR, persistent
format, host compiler algorithm or generated-program policy is introduced.

## Prospective occurrence-only diagnostic ablation (2026-10-12)

Registered before this ablation executes; preserve the original hypothesis above.
The selected checked compiler02 includes this change and the rest of Phase70.
Its saved profile collector unions increased from baseline69 B2 Numeric/Array/
Lexer 133.159/120.708/135.031 ms to 153.049/153.291/147.820 ms; B1 Numeric
343.348 to 375.392 ms. Index work under the collectors is roughly flat. These
are different whole compiler images and single sampled observations, so this
comparison neither establishes the insertion change as a cause nor proves a
regression. B1 generated code gives one concrete overhead mechanism to test:
the nonempty path adds an `nc_uses_put_mask` call with a `run_tail` choice.

Derive diagnostic B1 and B2 images from the exact checked compiler02 images,
changing **only the call in `nc_uses_term`** back to the previous
`index_set(uses, mark, ix(term), 32)`. All other bytes, including now-unused
private helper definitions, remain unchanged. Record exact replacements,
original/derived hashes and reversible source diffs. These are diagnostic
images, not checked Bend builds or shipping compiler candidates.

Use the existing clean request worker and the Numeric fixture with the proper
prepared base for each selected image: three rounds, alternating the order of
current versus reverted insertion within each B1/B2 role, twelve requests in
all. Preserve one serial guarded CPU3 lane; collect ordinary request clocks,
not counters or CPU profiles. Each output must match the complete compiler02
Numeric C oracle byte for byte. Preparation and process startup remain outside
the request clock, and their elapsed cost must be reported. Expected bounded
wall cost is around one minute using the existing method, not another full
bootstrap or broad native qualification.

Predeclared decision: retain the ten lines only if exact C passes, the current
insertion improves the geometric mean of the B1/B2 request medians by at least
1%, neither role regresses by more than 1%, and its favorable direction repeats
in at least two of three per-role paired rounds. Treat a smaller or unstable
effect as insufficient evidence and prefer deleting ten lines for simplicity.
A clear stage tradeoff is reported rather than silently averaged away. If the
simpler path wins, root must remove it in Bend and make a new checked candidate
before promotion; the diagnostic image itself cannot qualify for shipping.

### Factorial extension, registered before target execution

Root expanded the same bounded acquisition before it ran: four arms (current,
occurrence rollback, ordinary-ready observer skip, both) by B1/B2 and three
rounds, 24 requests. Reuse lane owns the observer change and its C-delta oracle;
methods lane owns serial execution and balanced ordering. This avoids collecting
duplicate current baselines in separate investigations. Expected elapsed becomes
about 90–120 seconds including setup; request medians remain the measured unit.

Compare occurrence enabled versus disabled **within each observer state**;
report B1 and B2 separately and any interaction. Apply the above keep threshold
to the observer state actually chosen for the checked successor. The unmodified
observer pair must preserve all compiler02 C bytes. The observer-skip pair has
its independently reviewed expected C change, but occurrence on/off within it
must again be byte-identical. Neither a generated-image ablation nor an apparent
factorial speedup waives the checked-source and correctness gates for shipping.

### Method amendment and outcome (2026-10-12)

The three-round/twelve-request and three-round/24-request descriptions above
record earlier plans. Before target execution, root upgraded the factorial to
**four complete position rotations per stage: eight independent Base
preparations and 32 clean requests, forty jobs total**. The frozen executed
plan is `selfhost/build/phase70/compiler02-factorial01/plan.json`, SHA-256
`747edf83b39f5a56ede3d717bcb62a587de06024a2866a3ee818aca1ca069070`.
Every arm occupies every within-stage position once; B1/B2 stage order
alternates. The favorable-round condition becomes a majority of at least
three of four rounds per stage. This amendment preserves the original wording
and identifies the actual acquisition rather than rewriting its history.

All **32/32** requests emitted exact compiler02 Numeric C. The occurrence
shortcut nevertheless fails retention on the unchanged observer route:
occurrence-on B2 has median **1562.592 ms**, versus **1528.654 ms** without it,
and is slower in **4/4 paired rounds**. Its 2.22% B2 regression independently
fails the maximum 1% per-stage regression rule. B1 medians are 2404.650 ms on
and 2523.401 ms off, but on wins only 2/4 pairs and the samples include uneven
slow observations. Do not claim a B1 speedup from removing the shortcut.

Decision: **remove P70-006**, retaining the semantic controls as evidence of a
correct but unhelpful experiment. Compiler03 deletes both private helpers and
restores the historical `index_set(..., 32)` call; its complete `bridge.bend`
matches the Phase69 source byte for byte. P70-008 is separately rejected and
unapplied. No edited diagnostic API is installed. The checked successor must
pass its own final gates before promotion.

The [full factorial outcome](../../implementation/phase70/compiler-factorial.md)
reports every sample, both compiler stages, the observer-state comparison and
the elapsed acquisition cost. The
[independent compiler03 source review](../../implementation/phase70/compiler03-correctness.md)
keeps this selection decision separate from target qualification.
