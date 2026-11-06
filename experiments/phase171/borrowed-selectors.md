# Root-held descendant selectors: bounded direct-IR prototype

This experiment is closed without integration or full compiler acquisition.
Source15 achieves99.535% observed promotion coverage on the real verifier, but
four balanced pairs improve its complete execution only1.25%; lookup is neutral.
This does not justify a full image or establish progress toward the100-second
self-build target. The useful finding is that this traversal's ownership cost is
small once evaluated inside a complete compiler computation.

The compiler experiment remains written in Bend and changes neither maintained
source nor runtime C. It targets complete aggregate results of read-only queries,
not only scalar consumers. The retained root `borrowed-selectors*.bend` files are
Source11; the final source is `selfhost/tests/phase171/descendant-v15`. Exact
intermediate source deltas, verified reconstruction and guarded replay commands
are in [the reproduction package](descendant-history/README.md). Root owned every
compiler/native target; the preparation/audit lane ran only source/data work.

The real native `index_find`, `index_bucket`, `lookup` and getter bodies already
use private direct workers. Removing generic scheduler frames is therefore not
the mechanism for this slice. It removes owning extraction/duplication/drop
inside a traversal while keeping the caller's original roots alive. Phase166's
3.46× complete lookup gap is motivation, not its attainable speedup: the fixture
also contains digest consumers. The earlier selected-field projection runtime
experiment is different and its small gain does not measure this capability.

## Concrete source-to-output route

`p171d_request(request, owner)` invokes maintained `p168_request_mode(1, request)`
and the unchanged actual generic/static/adapter/private gate `p167ob_final`.
It constructs the real callable view with `p168v_functions` and independently
runs `p118b_verify_functions` on that view. Candidate selection looks up the
actual source definition and its actual direct function. An owner string only
selects a candidate; no supplied body or certificate is accepted as authority.
The first intended owner is `index_bucket`; `dn` is discovered from its actual
call instruction rather than recognized by name.

The transducer tracks word aliases and paths below held roots. It uses actual
constructor IDs/widths from the verified original program. A take is converted
to existing `p118_rt_borrow_fields` only under a dominating exact constructor
tag comparison, for an admitted 2–16-field ordinary constructor. Scratch loads
must refer to that most recent view with aligned, in-range offsets. `keep`
becomes a local alias; final Source14/15 suppress decrements while preserving
their exact zero-valued result assignments. Scalar
arithmetic remains in the original order. The only retained runtime operations
are read-only tags/tests/guards and immediate Succ/Chr extraction; mutable array
and allocating U32/F32 unpacking operations are excluded.

A direct callee is read from the same verified table and recursively transformed
with its actual argument lineage. A private reader returns two words:
`accepted` and `rawResult`. Unsupported allocation, unknown call, store or read
returns declined before doing that operation. The enclosing reader propagates
refusal. Self-tail `Again` remains a loop. Named recursive call expansion is
refused, depth is at most12 and the shared visited-statement budget is8192,
including both branch arms. No unrestricted C recursion or runtime interpreter
is added. Static accepted/declined counts are not dynamic hit rates.

The original complete owning function is preserved. The wrapper first checks
its one or two non-scalar roots using the unchanged runtime borrowed-scalar
guard. It runs the reader only while those owned roots remain live. On success
it applies that same guard to the returned word, retains it once, then drops
the owned roots. Any refusal calls the original complete owning function with
untouched inputs. The separately defined emission adapter `p171d_plan` renames
the original to a private fallback, inserts real reader bodies in dependency
order and replaces only the original callable body. It then runs maintained
`p169s_lowered`, preserving the full final checks, original generic/static
program, adapter map and source-derived emission capabilities.

All proposed functions additionally pass the unchanged borrowed-import
projection and direct structural checker before treatment emission. That
structural gate does not independently prove source equivalence or lifetime:
the new producer and its source provenance remain trusted compiler code. This
prototype is not a BendTT theorem and must not be advertised as one.

## Two important conservative boundaries

`term_keep(rawChild)` alone is unsafe for an unsealed nontrivial descendant:
it creates a wrapper without updating the parent's stored raw child, and a
later parent drop can free the child. The existing guard authorizes only trivial
results or already-RFC results with count greater than one. RFC-count-one
promotion could be safe with a different audited guard, but remains refused
here. Cold/unsealed descendants therefore fall back. Traversal followed by
fallback may be slower; actual guard hit fractions must be measured before
claiming a useful speedup.

Roots and returned aggregates must have instantiated `Data` universe
(`Typ(Qua2)`, including the compiler's `Data` spelling). Merely recognizing an
ADT is insufficient: shared `Type` wrappers can contain raw mutable arrays, and
reading past them could bypass a refusal of the original owning runtime.
Scalar parameters use the existing `nol_scalar` classifier. This is a
conservative source-type restriction, not a blanket new permission flag.

The lineage information is a held-root union, not a theorem identifying the
exact parameter containing every result. Constants and original scalar
operations remain scalar words; field descendants retain root provenance.
Runtime resource exhaustion/refcount-overflow equivalence is not newly proved;
the scope is the same valid ordinary-state boundary used by existing readonly
observers. No malformed or failure-runtime probe is authorized.

## Frozen preparation and checks

Use the existing `selfhost/tests/phase171/prepare-api.py` with, in order:
`borrowed-selectors-types.bend`, `borrowed-selectors.bend`,
`borrowed-selectors-entry.bend`, `borrowed-selectors-controls.bend`, and
`borrowed-selectors-emission.bend`; add `borrowed-selectors-laws.bend` as a
`--prelude`. Export `p171d_request`, `p171d_summary`, `p171d_controls` and
`p171d_plan`. This adds declarations and performs no maintained replacements.
The emitted `P169Prepared` uses the normal `p134e_next` cursor.

The first real-owner preparation was `selfhost/build/phase171/descendant-source09`:
1,575,741 bytes, SHA256
`9992b60efdb0d18957959f5b66e697a70c3a0674367faedf190b0dad0c7d77dd`.
Its manifest pins every source/tool/base input. Source01/02/04/05/06/07 acquisition
attempts failed and remain recorded. The causes were forward-law fill syntax,
a missing delimiter, an earlier-binder match, an affine finite-control label,
an unannotated finite-control list, and a shared emission-list tail. Source03 was an unexecuted preparation
with a separately caught delimiter defect. Exact consumed module revisions are
under `selfhost/build/phase171/method-history/descendant-v*`; no receipt was
rewritten into a pass. Source08 and Source09 passed checked B1 acquisition; Source09 adds explicit U32 comparison results for every new conditional guard. The Source09 finite run passed all10 controls. The first real `index_bucket` query was refused before transduction with `source parameter/result shape`; this is not an optimization success. Source10 adds only a read-only actual-type diagnostic, leaving Source09 admission unchanged. That preserved diagnostic established the ordinary List/Data shape; later preparations below record the resulting admission change.

Ten finite compiler-data controls cover exact field-reader output, retained
aliases, root return, unknown values/callees/runtime operations, missing
constructor dominance, wrong width, and unaligned/out-of-range loads/stores.
They establish no native behavior on their own. The unrelated list fixture's
full expected value is `["left","right","","left"]`; a separately retained
first entry is read after the queries. Needed next gates are actual source
admission for both selectors, unchanged original full-value oracles on native
execution, and emitted-code inspection confirming the accepted reader has no
ownership or allocation calls. Only then measure matched full lookup execution
and guard profitability. No current compilation or runtime gain is claimed.

## Actual emitted-code feasibility audit

The exact installed final N2 QBE confirms that the borrowed `p88_string_eq`
reader calls `p111_rt_special_ctor(kind=2,count=0)` to create True. Source09
currently treats it as an unknown operation and declines. Runtime lines4410–4422
show that kinds1/2/3 with count0 return0/1 without allocation or ownership. This
is a concrete narrow next admission fix, pending observation of the current
refusal; it does not authorize Succ, Chr, U32/F32, arrays or arbitrary constructor
allocation. Existing owned String equality fallback also has renamed private
scratch buffers, which the initial transducer conservatively refuses. Even after
constant admission, actual guard/branch hit rates remain an open question.

## Source11: correct complete outputs, no execution gain

Source10's actual-type observation shows `List<&2,KDef>` has ordinary Data
universe and `nc_native_def=False`, despite its builtin `db` marker. Source11
removes that blanket marker refusal while retaining actual Data/native checks.
It admits exactly the allocation-free primitive constants (`special_ctor`
kinds1–3/count0) observed in real scalar readers. Its source SHA is
`5a20587cdd658751db5f1b181b3dd3333a23ce5a334e24b2498c9e7ef532ec23`.
Checked B1 acquisition and all10 original +5 separate constant controls pass.

Actual `index_bucket` yields15 functions/2 static accepted returns/5 declines;
`index_find` yields14/1/7. Both pass native complete-digest and independent
18-record KDef-output checks. The literal record producer uses the preserved
Phase166 independent oracle, not the compiler or digest to calculate expected
records. Four balanced process pairs establish no material gain:

| Selected owner | Baseline median | Treatment median | Treatment/baseline |
|---|---:|---:|---:|
| `index_bucket` |0.557837s|0.562667s|1.008660|
| `index_find` |0.558366s|0.555876s|0.995541|

Exact receipts are `descendant-lookup-pair11/report.json` and
`descendant-find-pair11/report.json` under `selfhost/build/phase171`. The unrelated
list fixture is refused with `no actual direct owner`; its owner appears to have
been removed by ordinary composition. It is a preserved negative, not a native
selector pass. A separate actual verifier fixture now returns all three complete
diagnostic strings, paired with a literal expected program; it is prepared at
`descendant-verifier-values01` and has not yet established a runtime result.

## Dynamic coverage explains the neutral bucket experiment

The link-only counter method in `tools/descendant-guard-counts.c` interposes the
existing guard and returns its unchanged result. It uses the identical QBE
program object and runtime object; the separate diagnostic executable is never
used for timing. Parent-run evidence is in
`descendant-bucket-guard-plan01/execution/{report,counts}.json`; call-site mapping
is retained in that plan's `wrapper-disassembly.txt`.

All40,000 outer root checks pass. The wrapper's result-guard site is never
executed: all40,000 reader attempts decline. Two inner equality guard sites each
run40,000 times and always choose their existing owning fallback. Zero samples
are unrecorded and every guard result is0/1; complete stdout remains exact.
Therefore the outer root restriction is not this experiment's bottleneck, and
there is no evidence here for weakening either guard.

Source/actual-QBE inspection locates the blocked fallback: the transformed
`$p128borrow.owned.p88_string_eq_go` reaches the two character argument moves and
returns declined. The original emits a private `p113i_0_local_scratch` stack
buffer (8 bytes), followed by `special_take(kind5)` and loads. The maintained
inliner inserts an `N111Alloca` before those argument copies; machine emission
hoists it to entry. The first reader rejects that allocation, and even accepting
it alone would leave the subsequent noncanonical buffer identity unsupported.
The program does not reach the final promotion decision, so RFC-result
profitability remains unmeasured.

## Source12/13: coverage successors, pending native benefit

Frozen source12 adds scalar `N111If` by reusing existing P113DIf branch walks,
retaining each arm's complete continuation and environment. Its7 exact finite
controls pass. The actual index_find proposal grows14→128 functions, with17
static accepted returns/50 declines. This exposes another cost boundary:
duplicating a suffix at every Boolean comparison is wasteful even though the
visited-statement budget bounds it.

Source13 (SHA
`f00d922f946db5b529f17898ab2ba1ec854e66ed778bafc0002c64f930e10364`)
is an isolated snapshot at `selfhost/tests/phase171/descendant-v13`, leaving all
Source11/12 input files unchanged. It preserves the original scalar conditional
for the exact same-local/type integer-constant assignment pattern and inspects
its continuation once. Other conditionals retain bounded conservative branching.
It also preserves original static stack allocations with capacity≤2048 and
alignment8/16, tracks allocation identity/capacity and exact pointer aliases,
and records which buffer holds the most recent verified read. New allocation
or helper calls invalidate the view; repeated allocation names, uninitialized
loads, wrong buffers and bounds refuse. Pointers cannot escape as results or
ordinary helper arguments. Arbitrary stores/offsets and heap allocation remain
unsupported. Root and result guards are unchanged.

The13 added buffer/join controls include full transformed bodies for Chr/Succ
reads through pointer aliases, complete compact true/false joins, and explicit
wrong-pointer/capacity/alignment, reallocation, pointer-result and allocating-kind
refusals. Source checking and actual native coverage/benefit are still required;
this is a compiler implementation experiment, not a new formal proof or promotion.

## Source13 coverage and independent review

Source13 passes checked B1 acquisition and35 finite controls. Actual index_find
produces50 functions (versus128 in Source12), with6 static accepted returns and18
declines. The compact-join change reduces the full proposal from1,044,431 to
465,334 JSON bytes. A data-only audit at `descendant-buffer-audit13/report.json`
pins the exact sources/proposals and confirms all49 reader functions have zero
keep/sink or heap-allocating imports; four pure Chr/Succ special-take sites now
survive. The runtime entry/guards are byte-identical to Source11.

Actual full lookup remains neutral:0.559469→0.564684 seconds median,1.009321×,
with complete outputs preserved. The separate diagnostic now sees60,000 wrapper
entries:20,000 root refusals,20,000 reader refusals,20,000 result refusals and zero
promotions. Thus some traversal now succeeds, but no result bypasses the owning
fallback. The first-result RFC-bit classification is a separate link-only
successor at `descendant-find-guard-plan14`; no heap headers are read and no guard
is changed. It must establish whether final refusals are RFC-count-one versus
non-RFC children before proposing a different promotion permission.

An independent source audit found a genuine general transducer gap: removing
`p111_rt_sink` also removed its zero-valued destination binding. The actual
runtime returns0; a valid IR local reuse (`x=1; x=sink(root); return x`) must not
retain1. The current compiler-shaped fixtures passing does not repair this
contract. This is a private prototype issue, not an identified production defect.
Source13 therefore cannot be promoted. Buffer identity, alias capacity, reserved
scratch, branch isolation and compact scalar joins had no second concrete
blocker in the bounded review; this is not an exhaustive proof.

Source14 is frozen separately, SHA
`ccc1d20bed18fb0c8426cfdd9523ab95474eb125e49384d5a6384ff916fcd66b`.
It suppresses only the decrement while preserving `N111Set{name,typ,0}` and the
corresponding scalar fact. Two exact new controls cover fresh and reused sink
destinations, and the old field-reader control now explicitly requires that
assignment. All other Source13 mechanisms and both runtime guards remain exact.
Checking and native gates are pending; no performance benefit or promotion is
claimed for this revision.

## Source14 correction and measured result representation

Checked B1 Source14 passes, as do the10 updated original controls and both new
sink-destination controls. The unchanged other control groups are consolidated
into the next candidate's single47-row request; no repeated startup is needed.

The v2 link-only counter completes with exact stdout and classifies all20,000
failing result words as RFC-wrapped. It does not read counts or heap headers.
Together with the actual unchanged one-root result guard and valid live ordinary
states, rejection of an RFC value implies count1. This is an inference from the
pinned guard definition plus observed tag bits, not a direct refcount sample.
Raw non-RFC escape remains excluded and is not justified by this workload.

Source15, SHA
`c8757db2040349c18628192a56aa05f039d68394ea2ab72eec31c800c13b6d9f`,
adds only a result permission: `oldResultGuard || RFC_BIT`. The original guard
call and arguments remain; four Bend-generated scalar operations use the exact
pinned RFC mask `(lo=0, hi=2147483648)`. No runtime helper, verifier permission or
root/helper-guard change is introduced. Original old-true behavior remains, and
newly admitted count1 changes to2 before any held root is released, adding no new
overflow state. Malformed heaps, zero counts and failure-state equivalence are
outside this existing valid-state contract. An independent bounded audit agreed
with this specific semantic argument; final source-delta review and native
checks remain required before measuring a benefit.

The combined control export binds the actual emitted scalar operations to nine
literal64-bit boundary outcomes using the maintained exact scalar evaluator,
plus complete literal wrapper equality requiring unchanged root guard, result
call, keep-before-both-drops and all three fallback paths. These are finite
compiler-data controls, not artificial words sent into the runtime. Complete
native values and actual verifier diagnostics are the next execution gates.

## Final decision and complete evidence

Source15 passes independent checked B1 acquisition and all47 finite controls.
Native complete18-record outputs match the independent literal KDef oracle.
The real final verifier returns the independent `768\n` result. Its three full
diagnostic strings also match the independent literal program:81 stdout bytes,
SHA256 `1dce08770f8c064aa57132debbda9b8b986f88659b1a9d203c3d75ec89a80425`.
The tiny diagnostic-string run is unresolved for timing and is only a correctness
gate (`descendant-verifier-values-native15/report.json`).

| Complete native workload | Baseline median | Source15 median | Ratio |
|---|---:|---:|---:|
| Lookup with complete digest |0.557612s|0.557376s|0.999576|
| Actual nonempty final verifier |0.421140s|0.415858s|0.987457|

Both are four balanced process pairs with exact stdout and clean stderr,
including setup/teardown. Exact receipts are `descendant-find-pair15/report.json`
and `descendant-verifier-pair15/report.json`. Neither is a new upstream comparison
or a full native compiler self-compilation measurement.

The separate real-verifier diagnostic records165,120 entries, zero root
refusals,768 reader refusals, zero result refusals and164,352 promotions
(**99.534884%**). Of those promotions,65,280 satisfy the original result guard and
99,072 use the independently reviewed RFC-count-one extension. Counts are derived
from exact call-site observations plus the validated CFG/predicate, not from
sample timing. See [the authenticated coverage report](guard-coverage-verifier15.md)
and [independent result-delta audit](result-guard-delta-audit.md).

Coverage is no longer an explanation for the small gain. The prototype changes
a real hot query successfully, but its avoided ownership work is a small part of
the complete verifier. Do not extrapolate Phase166's3.46× aggregate gap into a
speedup for this particular mechanism, or multiply the1.25% slice improvement
into the complete compiler. There is **no integration, installed-image change,
full image acquisition or general performance claim**. The finite tests and
bounded independent ownership audit remain distinct from a universal proof.

All consumed intermediate sources, failed acquisitions, neutral measurements,
ABI assumptions and the discovered/fixed sink-binding defect remain reproducible.
The source-history materializer was validated entirely in memory against the30
original intermediate files, including their exact controls and derivations;
none of those local files or their pinned receipts was modified. Keep only the
root Source11 modules and final v15 directory as full source at HEAD; reconstruct
v12/v13/v14 from the authenticated deltas when reproducing their receipts.
