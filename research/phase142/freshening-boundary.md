# Missing user-prefix reuse at the freshening boundary

2026-10-26. Source-only audit of Phase141 integrated-source02, SHA256
`f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`.
No target runs, source changes, or measured freshener savings accompany this note.

**The opportunity exists structurally:** parser reuse retains a raw user prefix,
but the successful loader still freshens the entire current user book. A small
producer-owned freshening checkpoint can reuse the already freshened prefix and
resume the suffix from the exact retained counter. This is distinct from the
existing prepared Base cache. Measure the freshening boundary before implementing
or extrapolating to the roughly31s historical native frontend floor.

## Actual data flow

`P86Seed.fresh : FFreshPrefixState{next,ready}` describes the fixed Base prefix.
`f_fresh_prefix_prepare` freshens Base once and checks exact equality to the
admitted Base definitions (source15345–15354). The starting counter for user code
is therefore known without rewalking Base.

`P140PCache` instead retains the original source, initial scope, source origin,
checkpoint/lookbehind tokens, parser context, reversed raw declaration accumulator,
imports, unsafe marker and parser scope. It retains **no freshened user prefix**
and no global freshening counter at that cut.

A parser hit checks the initial scope, byte-identical source prefix and the exact
first resumed token. `p140p_resume_lexed` resumes `f_top` with the saved raw book.
`f_result` reverses that book; `f_context_result` lowers contextual declaration
information. Completion then fills imported laws, qualifies names/paths and
validates current names before freshening:

```text
p140pl_parsed
  f_graph_finish_indexed(current parsed result, Base graph, aliases, paths)
p140pl_indexed
  f_prefix_ready_source_completed(...)
p140pl_completed
  f_prefix_graph_trace(current carrier, sources, seed.fresh)
    f_prefix_ready_validate(current user suffix, Base name index)
    f_prefix_trace_validated
      f_fresh_defs(ENTIRE current user suffix, seed.fresh.next)
    f_prefix_trace_fresh
```

The decisive selected-source locations are `p140p_resume_lexed`58760,
`f_prefix_graph_trace`15533, `f_prefix_trace_validated`15561 and
`f_prefix_trace_fresh`15570. Here "suffix" means everything after fixed Base,
not everything after the user parser checkpoint. Thus a late edit can skip
parsing nearly all compiler text while still renaming and reconstructing all its
completed terms. The source being several megabytes is not itself a timing claim.

## The freshener has a small exact continuation

`f_fresh_defs`14137 delegates to the stack-safe `f_fresh_book_stack`14076.
Its `ffd_walk/type/value/frame` functions process, in this order:

1. A complete top-level definition's type, starting with an empty rename environment.
2. Its value, with an empty environment and the resulting global `next` counter.
3. All its child constructor definitions, in order.
4. The following top-level definition.

Term-local `ffw_*` worklists handle All, Lam, Let and nested syntax. The bound
variable environment is local to a type/value. At a boundary **after a complete
top-level definition including its children**, no rename environment or unfinished
frame crosses into the next definition; the only computational state is `next`.
Output definitions must retain their complete field values and source spans.

Consequently this compositional equation follows from the current algorithm:

```text
fresh(P ++ S, n0)
  = let (FP, n1) = fresh(P, n0)
    let (FS, n2) = fresh(S, n1)
    (FP ++ FS, n2)
```

This is a source-derived property to test, not a completed formal proof. It does
not justify a cut inside a definition/constructor list or binder environment.
A suffix edit may add/delete binders: resume from the retained `n1` and freshen
the entire new suffix, allowing later IDs and final bounds to change exactly as
before. Do not preserve stale IDs after the edited region. Existing downstream
fresh-bound/header invalidations remain authoritative.

## Small safe splice

Extend the private successful parser/completion capability with:

```text
same seed/producer and logical source context
existing admitted parser cut and completed event count
actual completed prefix P at that cut
actual freshened prefix FP and nextAtCut n1
```

The completed prefix matters: `P140PCache.book` is reversed raw parser state,
not the representation consumed by `f_fresh_defs`. Derive the cut count from the
saved accumulator, then split the **actual successful completed user fragment**
at that many top-level events. Context lowering, imported-law filling and path
qualification preserve event count, but must be covered by a finite/differential
bridge rather than assumed from an arbitrary caller-supplied count.

On a certified parser hit under the same Base, initial scope/import aliases,
namespace and logical source path, the raw prefix and its completion context are
unchanged. Reuse its actual completed/freshened product; freshen only the current
completed tail at `nextAtCut`. Join the retained fresh prefix and fresh tail, and
pass the result to unchanged `f_prefix_trace_fresh`. The existing full validation
and duplicate-name checks stay in place initially. No external unchanged token,
source-name-only identity, sampled hash or full deep equality on every hit.

Keep original error order and fallback: a parser miss, changed context/path,
invalid completion, mismatched cut, or absent capability takes the original full
freshening route. A failed request does not publish a replacement checkpoint.
The fixed Base certificate remains unchanged. Reusing the prefix does not avoid
all validation, contextual completion, source-prefix comparison, list joins,
checking or owner analysis; these remain separate floors.

## Cheapest falsifier before native acquisition

Expose existing checked roots, obtain the actual completed user fragment before
freshening, and replay them in the hosted observer. Useful additional roots:

```text
p140pl_parse f_graph_aliases f_header_imports f_path_dir f_source_begin
f_graph_finish_indexed f_prefix_ready_source_completed f_prefix_ready_validate
f_fresh_defs f_prefix_trace_fresh p140cp_split norm_defs_join
```

Existing Base-completion/source-location/header exports supply the other inputs.
Construct the same parser scope from the actual Base carrier; call the original
parser, indexed completion and validation functions. The observer then times:

- Full `f_fresh_defs(completedUser,seed.fresh.next)`.
- On cold A, `f_fresh_defs(prefix,seed.fresh.next)` to acquire the retained result.
- On B, only `f_fresh_defs(tail,nextAtCut)` plus exact output assembly.

Compare **the entire `FFreshDefs`, including final next**, and the complete
`FPrefixLoad` with the original loader. Keep acquisition and splice/assembly cost
separate. Do not profile `f_fresh_defs` over already freshened input as though it
were the same workload: FName/FGlobal transformations have already disappeared.

Start with a generated moderate real-declaration workload containing a long
unchanged prefix and a late small edit; then use a compiler-source prefix or
retained compiler fragment. Small Lexer/Map edits occur early and leave most
of their user definitions outside the reusable prefix, so poor gains there do not refute a
late-compiler-edit opportunity. Conversely, a late synthetic edit cannot support
a claim for arbitrary edit positions. Report early/middle/late cut sizes.

Required inexpensive cases include Lam/All/Let and nested constructors, foreign
paths, imported-law fill, template declarations, source spans, prefix edits,
changed imports/initial scope, suffix binder-count changes, invalid suffix and
recovery. Preserve full error text and current global fresh-ID numbering.

If measured full freshening is small, stop. If large, this splice removes term
reconstruction instead of merely accelerating a comparator, and merits a bounded
Bend prototype before another full native compiler build. Retained native samples
cannot currently settle the issue: they lack caller context, and shared tag,
ownership and allocation helpers obscure inclusive freshener work.

## Prepared probe (no executions by this investigator)

[`freshening-probe.mjs`](../../selfhost/tools/performance/phase142/freshening-probe.mjs)
now implements that observer. It starts with frozen Lexer/Map sanity cases and
literal128/512/1024-declaration prefixes of selected Phase137 compiler source,
with a unique appended function edited from314159 to314160. The compiler slices
contain24,002/81,542/192,456 original prefix bytes. They are successful frontend
workload candidates, not claims of complete typechecked runnable compilers.

```sh
selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase142/freshening-probe.mjs \
  CHECKED_API_REPORT.json \
  selfhost/build/phase142/freshening01 \
  128,512,1024
```

Use `none` instead of sizes for only Lexer/Map, or128,512 for the first bounded
scale. The coordinator should use its90s/3GiB guard; the new probe's duration has
not been measured. It prepares actual pre-fresh products through the original
checked functions and compares with an independent original `p140pl_load` call.
The original selected compiler source, derived fixtures, API and Base identities
are retained in the receipt.

Most importantly, the guarded splice **pays exact completed-prefix equality**.
A parser hit alone is not used as authority for completed-prefix reuse in this
probe. The unchecked splice is separately labeled an optimistic ceiling; it
cannot justify removing the guard without the completion-dependency argument.
Each comparison includes every output definition, final fresh counter and complete
loader graph. Component timings are nested diagnostic replays, not additive
exclusive shares. The script has been syntax-checked only.
