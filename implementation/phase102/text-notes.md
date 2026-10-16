# Phase102 text lane: iterative append on linked Strings

The first ablation removes canonical append's scheduler/reconstruction
continuations while retaining the original native linked String ABI. It changes
neither IO decoding, constructors elsewhere, borrowed observers, array layout,
runtime ownership helpers nor the task protocol. It therefore tests whether the
renderer benefit can be recovered without Phase101's global chunk representation
and graph regression.

This document initially records offline preparation and reasoning only. Root
owns serial guarded compiler/program executions and the resulting qualification
and performance decisions. No target was executed by the text-lane agent.

## Prepared experiment

Files under `selfhost/tools/performance/phase102/text/`:

- `linked-append.c`: consuming iterative append using existing runtime primitives.
- `prepare.py`: `transform(source, reuse=True)` returns transformed C plus counts;
  its CLI records source/helper/method/output pins and method snapshots.

Example preparation, which itself executes no compiler/program:

```sh
python3 -B selfhost/tools/performance/phase102/text/prepare.py \
  --source selfhost/build/phase100/image-acquire01/image-render/b2.1.c \
  --out selfhost/build/phase102/NEW
```

Use `--copy` or `transform(source, reuse=False)` for a separate ablation that frees
and reallocates even exclusive heap cells. This distinguishes the iterative
control-flow benefit from explicit cell reuse; the allocator may immediately
return the same physical cell, but the copy variant still performs its ordinary
free/allocation operations.

The transform refuses Phase101 tags/helpers and a prior Phase102 transformation,
expects exactly one canonical `$direct.String.append` scheduler entry, records
the replaced worker hash and inserts one helper at a pinned runtime boundary.
Incoming `r0`/`r1` arguments are captured before `WL_OPEN`, avoiding the Phase101
register-shadowing defect. Device/CUDA/Metal host builds are explicitly refused.
This is a saved-C mechanism intervention, not production name-only admission.

Offline preparation succeeds on all three original Phase100 B2 application C
products, with exactly one worker replacement for each reuse/copy variant:

| Application | Reuse candidate SHA256 | Copy candidate SHA256 |
| --- | --- | --- |
| Source index | `6a5a9c97008ac8ed2b5f18ba8e77820c7fe4bd03620f5c56d2b641b72ea8a033` | `6dfa6aff9bc2b4fbe2d5f0244812f733e8847bf9bdc10fdefee33a77b4094031` |
| Image renderer | `0c53c8ee559cb4b66f9f54e8f97899b8259ab1ac4372da049c51f04f802f5cab` | `39ea1e2b1d5a23b05dc86dba58631896071f09e8b0a849a1a401e5889125358e` |
| Dependency planner | `8e273eb6d40766a88938bb869574310f5db8221a3d8f85c2e825e230d3c1984d` | `95628b84d1a1cd64a258b083b93da1346b01334cf9f24fc2a2804c608fc0e785` |

These are transformation results, not compilation or runtime passes.

## Ownership and semantic argument

The helper takes two owned String values. It repeatedly calls existing
`ctr_take(e, left, 2, fields)`, which returns owned head/tail fields. On a unique
heap node it returns the cell for reuse. On a shared node it retains the fields,
consumes the root reference and returns no reusable cell. A static location is
below `HEAP_OFF`; it must be copied even if `ctr_take` returns it.

After splitting, the helper moves the tail into its next `left` variable and
creates a result node containing the complete original Char word. It fills
forward links while the result remains private. Child storage uses the exact
ordinary SCon cold/hot sealing condition; an RFC wrapper is added only where that
existing representation requires it. Every unfinished result ends in SNil, so
cleanup remains structurally valid. The right argument is attached only once,
after the entire left sequence is consumed.

Aliasing the right operand with the left root or a suffix prevents destructive
reuse of every actually shared node: the original `ctr_take` reference-count
protocol handles that case. An exclusive prefix may be reused safely before a
shared suffix is copied. The helper never mutates a static node. Parallel task
arguments retain their existing owned capture protocol; no atomics are weakened.

Characters are copied as full Terms (the canonical native Char is an immediate
U32), preserving NUL, surrogates and values outside Unicode. No UTF-8 conversion
is introduced. Empty left returns right unchanged. Processing preserves character
order while eliminating the per-character append continuation and reconstruction
call. Input expressions are already evaluated at the saturated worker boundary.

This argument assumes admitted finite canonical Strings and the existing
`ctr_take`/sealing contracts. Raw forged Terms, arbitrary foreign consumers and
resource-failure ordering are not separately established. Production integration
must prove/check the exact Base String.append body and native constructor/type
identity rather than recognizing its name alone.

## First validation requests

Reuse the independent Phase101 controls: dynamically constructed overlapping
suffixes in both append orders, retained original roots, static/dynamic mixtures,
empty/single/multi-node Strings, full-U32 characters, replicated arrays, and
shared parallel task output. These already exercise the lifetime obligations
most likely to expose a destructive-append bug.

Then compare complete renderer, source-index and dependency-planner results using
saved fixtures. Keep one/four-worker renderer timings and graph latency separate.
The key decision is whether original-storage iterative append captures a large
fraction of Phase101's renderer gain while leaving the graph/source paths neutral.
If so, it is a smaller integration candidate; it does not disprove the remaining
memory/locality benefits of a future chunk representation.

## Isolated structural integration

The text lane now includes `append.bend`, `integrate.py`, `prepare-bend.py`,
`integration.patch`, `helper-provenance.json`, and offline fixture preparation.
The complete method and root-owned commands are in
[`text/README.md`](../../selfhost/tools/performance/phase102/text/README.md).

The actual pinned Base AST was inspected by decoding its authenticated saved
cache, without importing or executing a compiler. Its body is the anticipated
SNil/SCon matcher with linear head/tail/right binders. Admission checks the exact
body, quantities and binder identities in addition to the existing canonical
String/Char/U32 signature facts. The checked scoped observer permission supplies
the authority; a raw caller receives no rewrite. This is not a name-only
intrinsic. Safe same-shape user functions are not yet generalized.

The candidate edits only `nf_finish_ready`: it computes permission once, wraps
the admitted direct segment after observer routing, and prepends the derived
host helper to worker declarations. `nc_helpers`, the runtime source/template,
foreign providers, and device implementation remain unchanged. Parameter kinds
were corrected from the first draft's `N_Box` to the actual `N_W64` emitted by
`nc_binding`; otherwise the optimization would silently remain inactive. Saved
parameter names are bound before `WL_OPEN` and remain valid after its register
bank shadows incoming `r0`/`r1`.

A reversible Phase98 derivative is prepared at
`selfhost/build/phase102/append-bend-source01/changes.json`; its compiler source is
SHA256 `b933def117b814baeb4317fc47d471e5ed840a03f6707b9f536082f9c79802af`,
143 lines / 6,432 bytes larger than the bound installed source. The derived
helper String round-trips to the mechanically transformed C bytes. These are
**offline construction checks**, not evidence of compiler admission or execution.
Root owns the pending checked API, route activation and behavior qualification.

The fixture set in `selfhost/build/phase102/append-admission-fixtures01` has two
positive body cases and fourteen mutation refusals. `check-admission.mjs` also
checks owner/type/signature permission, raw/unsafe entry refusal, direct-frame
and parameter-kind restrictions, metadata/device fallback, and helper bytes.
That runner is prepared for root execution and was only syntax-checked here.

## Preliminary root-owned measurements

Root reported the first four-round saved-C screen as follows: renderer time was
0.736× own baseline at one worker (0.958× upstream), and 0.777× at four workers
(1.164× upstream). DAG800 was 0.987× own baseline (0.342× upstream). Renderer RSS
fell from about 81 to 52 MiB. The copy-only append ablation took 0.781×/0.806×
baseline, so both continuation elimination and exclusive-cell reuse contribute.
These are preliminary observations communicated by root; final receipts and
qualification decisions belong in the main Phase102 report. No new measurement
was executed by this lane.

The broad benchmark lane is independently investigating general recursion
modulo a final constructor field. That could cover canonical append and other
builders without function-name specialization, but must prove a larger set of
ownership, evaluation-order and partial-result obligations. Keep its experimental
admission separate from the narrower earned append implementation until measured.

## Independent review of the combined local-call plan

Root requested a second offline review of typed02 before native-image building.
The reviewed combined source was
`selfhost/build/phase102/combined-bend-source01/compiler.bend` (the first combined
candidate, not necessarily the final selected revision).

One concrete device-emission defect was found and reported immediately. The new
`nf_scheduler_emitted` emits a bare `NF_*` C call inside ordinary scheduler code,
while those NF definitions exist only under `#if !DEVICE`. For example,
`typed-emission02/source-index/emitted/program.c:21182` contains the new
`NF_Char.to_u32` call inside the device `#else` of `remove_bom`. The no-reachable-
bangs condition prevents offloading, but an unreachable C call still needs a
declaration when compiling a device translation unit. This does not invalidate
the CPU timings; it blocks a claim that this candidate preserves valid device
emission. Root and the typed lane are handling the repair. Original bodies for
bang-bearing requests already retain the old path.

An appropriate bounded fix is to mark affected scheduler segments host-only
under that same no-bangs permission. A literal per-call fallback through
`nc_let_cut` would duplicate the remaining body, continuation segments and fresh
names, and can multiply code generation. Preserving complete original device
bodies instead requires a deliberately separate lowering or a dual-body IR. This
review recommends fixing the authority/host boundary explicitly rather than
adding an ad hoc evaluator inside the local call.

The rest of the scoped design passed this static review, subject to execution
qualification:

- `nf_scheduler_selected` reads only admitted ordinary NF workers. Product routes
  are excluded, so its one-word `Term result[1]` agrees with their boxed ABI.
  Worker dependency closure already excludes unresolved callees and non-tail
  recursion that the ordinary NF path cannot implement.
- `nd_bind_value` evaluates arguments in source order, introducing separate
  owned variables. `nc_let_emitted` then applies the existing retain-for-rest,
  result-binding and dead-result-drop rules. This preserves aliased arguments
  and children escaping an owned result without introducing a second ownership
  protocol.
- `NativeLocalPlan` fails the older `nf_host_payload` predicate deliberately.
  Consequently it cannot omit factories or authorize the stronger host-plan
  transformations; escaped/partial function values retain their existing ABI.
- `nf_scheduler_attach_index` preserves the original source index and the exact
  `ns_context` containing static words, erased bodies and constructor facts.
  The checked preparation path creates these facts afresh after clearing caller
  metadata; the new private marker does not become source authority.
- Weak authenticated File-provider permission keeps `sharing=false` when passing
  into `nf_plan_scoped` and `nh_macros`. It does not turn on checked product-demand
  relaxation, packed arrays, cold constructors or scalar narrowing.

This is an inspection result, not a general ownership theorem. Dynamic behavior,
source admission, actual generated-route activation and later device repair
remain the root's qualification obligations.

## Activation failure and corrected structural admission

The first checked combined compiler API built successfully and its v1 admission
suite passed 39 observations, but actual renderer C was byte-identical to the
baseline. That was an **inactive optimization**, not a speed regression.
Offline inspection found why: the parser carries `App` metadata quantity 1, while
checking/annotation reconstructs applications through `app(...)`, whose quantity
is 0 (`core/term.bend:171`, `check/annotate.bend:215`). The saved Base cache's
`world.checked` contains that exact difference. Binder/variable quantities and
ownership signature remain one. The initial body fixture used the parsed Base
form and therefore missed the integration input.

The corrected `append-v2.bend` accepts only these two canonical App metadata
forms. Its eighteen body fixtures include the actual checked Base as an extra
positive and an invalid App quantity as an extra refusal. All binder, type,
constructor and recursive-call checks remain. Root must still establish actual
route activation and runtime results for the corrected emitter.

Use `integrate-v2.py`, `prepare-bend-v2.py`, `admission-fixtures-v2.mjs` and
`check-admission-v2.mjs`. The bound successor is
`selfhost/build/phase102/append-bend-source03/changes.json` with compiler SHA256
`9820bb4c4ca4b121ecb5651ca936eb5c92d2b3fde95fd7b219759aabf2aa8594`,
149 extra lines. Fixtures are `append-admission-fixtures03`. Earlier source02 and
fixtures02 were offline preparations using the same corrected semantics before
method names were versioned; source03 records the stable v2 paths.

The consumed v1 methods were restored byte-for-byte against the old admission,
composition and fixture hashes. `text-method-archive01/recovery.json` records
that verification and preserves both consumed and interim corrected bytes.
No prior execution receipt was changed or reinterpreted as a v2 pass. This was a
method-versioning repair after edits overlapped root's execution queue; future
changes to consumed methods must use new filenames.

The typed lane's successor uses existing segment host metadata for requests with
an exact internal `NativeHostPlan` or `NativeLocalPlan`. Static review confirms
the runtime only enters GPU execution from `corpus_eval` when `fid_bangs(...)`
is true; its ordinary parallel branch runs CPU workers. Thus the proven no-bangs
request cannot execute omitted device user cases. Numeric FID tables remain;
CPU dispatch still contains the segments. The revised scope is explicit: valid
host-only omission for these requests, with original lowering for bang-bearing
requests, rather than literal preservation of unused device bodies.

## Further composability opportunity: reuse owning observer adapters

The typed lane's dependency inspection found `String.eq -> String.order ->
String.cmp <-> String.cmp.fin` preventing the entire indexing loop from becoming
an ordinary NF worker. Inlining `cmp.fin` alone cannot make this a tail loop: its
equal branch still calls `String.cmp.rec` after the recursive comparison, to
reconstruct both owned strings.

A smaller general opportunity is already present in the generated source. The
saved typed02 indexing C contains both `$observer.String.cmp` and its owning
`$observer.adapter.String.cmp`, admitted by the existing observer proof. Feed
that proven implementation into ordinary NF dependency admission: replace the
unready boxed owner worker with a forwarding worker that returns the existing
owning adapter's result, then rerun `nf_admit`. This removes the implementation
cycle seen by the caller without permitting mutual C recursion or weakening the
scalar observer rule. The typed lane owns the prototype and execution remains
root-owned.

The reviewed scope is limited to existing unready ordinary candidates with
error-free lowering, no emitted continuation segments, positive matching arity
at most four, and one boxed result. Existing observer schema, residual checking,
private-name freshness and pair admission still apply. The bridge consumes the
same owned parameters and returns the adapter's original owned result. It must
replace the old owner, carry an explicit dependency on the adapter, and retain
all admitted observer/adapter workers.

If early planning omits the old late observer metadata, the effect on
`nh_observer_macros` is conservative: it loses optional removal of hot sealing
for user-defined root types. It does not authorize cold stores. String is a Base
root and is excluded from that particular cold-macro optimization, so this
omission does not affect the String.cmp mechanism. Generic user-root performance
should still be checked before treating omitted metadata as harmless globally.


The concrete `typed/observer-forward.bend` prototype was independently inspected
against `observer-integration.bend`, `observer-adapter.bend`, `flat.bend` and the
prepared source. Its helper SHA256 is `0a3f66ddc91add5bf23d8f1547a4b6617eda300a402d5e9b6976f39f41698007`. Static review found no new
ownership or admission blocker: original owners are replaced only after both
private workers admit; the forwarding call records the adapter dependency;
rerunning ordinary admission opens only the resulting dependency closure. The
scalar gate still rejects unready scalar owners, and the generated observer
macro comes from the same request permission. Positive matching arity and absent
product shape preserve the one-Term result ABI. This is not an execution result.
