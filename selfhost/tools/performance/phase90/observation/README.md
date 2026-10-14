# Definition-header observation falsifier

Status: **offline preparation only; no source checking, execution or speed result**.
The first failed gate stops the candidate. The default source, installed compiler,
upstream source and current native image remain unchanged.

## Mechanism and exact scope

Current `selfhost/src/core/term.bend:184` projects `dn` from a nine-field `KDef`.
`selfhost/src/front/declarations.bend:242` retains each candidate while calling
that projection and shared String equality. A direct fused pattern still takes
all nine shared fields; it is not a convincing fix for this mechanism.

This candidate uses the same lookup, ordering and comparison algorithms but gives
normal definitions a two-field outer header:

```bend
type P90Payload<-D: Data> is Data:
  P90Payload{+kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2,D>, +native: Bool, +unsafe: Bool}
type KDef is Data:
  KDef{+name: String, +payload: P90Payload<KDef>}
  # The existing two index variants remain unchanged.
```

`dn` matches `KDef{name, payload}` and returns `name`. Other constructor uses and
patterns wrap their existing eight fields in `P90Payload{...}`. The erased Data
parameter avoids a mutually forward-declared payload type; the checked tiny
program must establish that this recursive instantiation is accepted.

Expected C mechanism: shared `dn` takes two fields and drops one payload root,
rather than taking nine fields and dropping eight. It does **not** borrow roots,
remove shared String comparison or change the asymptotic list scan. It adds an
allocation per normal definition, one pointer indirection for non-name fields,
and an extra object to retain/free. Those costs may erase or reverse the win.

The manifest has 103 textual `KDef{` occurrences across 29 production modules;
these are not 103 distinct algorithms. The exact frozen native source derivative
rewrites 102 constructor/match sites, adds the payload declaration, simplifies
the name projection and grows by **3 physical lines / 1,349 bytes**. This adds
one generic Data type and constructor; the low line delta is not a simplification
claim. Generated source:
`fixtures01/compiler-header.bend`, SHA256
`fad67544d2f0208908bd4dbc4f0ac25c5067e75fdbe71fd5cfee5d3988a754c3`.
This source is an unqualified candidate, not a runnable image.

The Phase89 unqualified self-prefix attributed 9.40% of samples to ownership
under `dn`. That is a lead and an upper-bound intuition for that observed prefix,
not a full-request budget or a predicted speed gain. A name-only improvement
cannot plausibly remove the separate 30.42% shared-String ownership samples.
No numeric speed estimate is warranted before the small C-shape check.

## Root-run first gates

`prepare.py` executed offline with Python 3.9 and produced `fixtures01/manifest.json`.
It pins the old actual `dn`, `f_find`, `f_find_next`, native consuming equality,
control method and exact frozen compiler source. Strings/comments and non-layout
compiler bytes are retained by lexical constructor transport. No parser, checker,
lookup or compiler algorithm is implemented in the Python transport.

The 56 control cases include empty books, first and later duplicates, missing
names, equal-prefix misses, Unicode, an empty named definition before/after an
index leaf, and an index node before a real definition. Every returned field is
compared: terms of all three variants, source ranges, removed names, booleans,
arities, templates and recursive constructor/index products. Every case also
returns its entire retained input book; these controls therefore test observation
with another live use, not just ownership of a freshly disposable scalar result.

Run serially under the existing resource guard; use fresh output directories:

```sh
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase90/header-flat-acquire01 --seconds 60 -- \
  /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase88/component.mjs \
  selfhost/tools/performance/phase90/observation/fixtures01/flat.bend \
  selfhost/build/phase90/header-flat01
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase90/header-split-acquire01 --seconds 60 -- \
  /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase88/component.mjs \
  selfhost/tools/performance/phase90/observation/fixtures01/header.bend \
  selfhost/build/phase90/header-split01
```

After both source gates succeed, inspect the actual generated `dn` C paths before
a compiler image build. The split path must skip `P90Payload` decomposition. If it
still decomposes nine logical fields, there is no demonstrated mechanism: stop.
Then root builds both `program.c` files with the same existing Clang flags and
executes both native programs with `--threads 1 --gpu off`, and both `program.cjs`
files with the pinned Node executable, each through `phase86/guard.py`.

```sh
python3 -B selfhost/tools/performance/phase90/observation/compare.py \
  selfhost/tools/performance/phase90/observation/fixtures01/manifest.json \
  FLAT_JS_STDOUT FLAT_NATIVE_STDOUT HEADER_JS_STDOUT HEADER_NATIVE_STDOUT \
  NEW_COMPARISON_REPORT.json
```

This requires **four byte-identical complete stdout files**, then independently
checks every product against the ordered first-match oracle. A mismatch, parser
rejection, native runtime diagnostic, unexpected stdout or missing case is a
failure. It does not permit ignoring a branch or weakening input admission.
The small correctness program's duration is not a compiler performance result.

If these gates pass, the next small workload should retain a book across repeated
lookups, separate hits from misses and vary size 64/256/1,024. Use short disjoint
names and long shared prefixes separately so String comparison cannot disguise
the projection effect. Record allocation/release counts alongside request time.
Only a useful gain there justifies an image acquisition and exact-C compiler
controls. Broad total requests must include construction/checking: a prebuilt
header microbenchmark excludes the candidate's extra payload allocation cost.

## Integration and safety boundaries

* This is a **native compiler profile** experiment. Changing `KDef` changes the
  internal JS Data product ABI; an existing host that directly constructs or
  inspects `.kind`, `.typ`, etc. is not compatible. Do not install this in the
  ordinary JS workflow or silently reinterpret an old API cache.
* The native P88 transport constructs typed definitions in Bend. Its `KDef{...}`
  constructor is included in the derivative, so the wire schema can remain the
  same logical nine fields; this is only a source fact. Actual cache-vs-fresh
  whole-product gates and consumer-image binding must pass before cache reuse.
* The existing parser final-definition index cannot replace every `f_find`:
  `f_decl_local` deliberately scans on index hits to retain first-event selection.
  This candidate leaves those scans and the exact `Missing` product untouched.
* `has_name` still performs a list scan and shared String comparison. Adding a
  hash per query while recomputing hashes for every list element would introduce
  another shared traversal. Stable interned IDs or a retained ordered index are
  larger changes requiring a separately measured workload and identity contract.
* The current own-C observer permission is coupled to `ns_definitions` in
  `back/native/scalar-array.bend:44`; it admits only scalar arrays and the audited
  `IO.args`/`IO.print`/`IO.now` foreign catalog. The compiler's generic decoder
  arrays and nine file effects prevent that certificate. Splitting immutable
  observation permission from scalar-array permission deserves a separate proof
  and test matrix; merely broadening that whitelist is unsafe. More fundamentally,
  changing our emitted observer C does not accelerate the present **upstream-built
  B1**. It helps a future native B2 only after self-emission succeeds.
* The rejected Phase89 False-before-String comparator is not retried. True borrowed
  String traversal remains a lowering/representation question, not an argument
  order trick. The old source-check failure and ownership limits still apply.

No benchmarks, compiler acquisition, Clang invocation or target execution were
performed in this offline lane. Root owns the serial validation and any promotion.
