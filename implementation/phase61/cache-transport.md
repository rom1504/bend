# Cache transport and private driver integration

[Source identities and placement](../../selfhost/tools/performance/phase61/cache/source01.json) ·
[Driver patch](../../selfhost/tools/performance/phase61/cache/frame01.patch) ·
[Design and boundaries](../../design/phase61/cache-transport.md).

The initial frame01 proposal below is retained as lineage. Root initially staged `typed-driver-frame01.mjs` as a
private project's `tools/typed-driver.mjs`; its framing helpers are inline so no
new host dependency or snapshot copy-list change is needed. Keep the remaining tool dependencies and compiler configuration exactly copied.
The framed writer only runs through normal `prepareBase`; no fake prepared book or
checked cache stamp is introduced. Any future checked-state payload is a separate
source-proved schema owned by the validation agent.

```sh
node selfhost/tools/performance/phase61/cache/controls01.mjs \
  selfhost/build/phase61/cache-io-controls01
```

Root supplies the process-tree guard/CPU3. This is a tiny JSON/filesystem controller;
initial 20-second/256 MiB heap limits are sufficient hypotheses, not measured costs.
The author ran Node syntax checking only on CPU0. Full request equivalence and the
50 ms cold-reader hypothesis remain untested. Preserve this first draft and create
versioned successors if actual controls reveal an error; do not edit consumed files.

## Private combined integration

[Combined driver](../../selfhost/tools/performance/phase61/cache/typed-driver-combined01.mjs)
and [patch](../../selfhost/tools/performance/phase61/cache/combined01.patch) add the
two compact-index positional ABI tags and the five-field `KBasePrefixState` tag.
The framing decoder is exported inline for new maintained/private consumers;
there is no production helper import or snapshot copy-list expansion.

Optional state is generated only through the actual `base_prefix_prepare` API on
loaded Base, after normal Base checking. Its schema/producer marker, state digest,
ready flag, bounded integer/list shape and patch source spans are checked within
the existing API/Base/path-bound cache. Absent or invalid state is omitted and the
ordinary ABI2 checker remains selected; a missing bridge also keeps that path.
Book and optional state are recursively frozen before persistent memo permission.
This is the existing trusted-local artifact model with identity-bound integrity,
not a cryptographic certificate against malicious coordinated file/digest rewriting.
The public checker and caller-object validators are unchanged.

`controls02.mjs NEW_OUT` retains framing/public-validator IO obligations and adds
11 synthetic optional-state shape/fallback cases plus recursive freeze. Synthetic
state controls establish host predicates only; the actual Bend resume proof and
checked-state differential gates belong to the state owner. Both combined driver
and controller pass Node syntax checking. Host composition received independent
static PASS conditional on that source proof; execution/measurement are pending.
The [source follow-up note](../../selfhost/tools/performance/phase61/cache/combined01-state-source-note.json)
separates the initial state-source checkpoint from the owner's later replay change.

See the [consumer audit](cache-consumers.md): workflow validation, private compiler
batch cache decoding and a versioned latency setup successor must be handled before
maintained integration. Historical methods and protected tests remain untouched.

## Loader successor

Root authorized [combined02](../../selfhost/tools/performance/phase61/cache/typed-driver-combined02.mjs)
([incremental patch](../../selfhost/tools/performance/phase61/cache/combined02.patch))
after preserving combined01. It adds real `f_fresh_prefix_prepare` publication of
`FFreshPrefixState{next,ready}` and a separately hashed schema/producer marker.
The driver validates U32 shape/readiness and freezes the state with the memo book;
it never computes a max-ID or guessed counter. The optional final loader call uses
`f_graph_trace_from_prefix(completed,supplied,seed.book,state)` only after an actual
Base seed path/text/interval match and a module-private ordinary-inspection token.
Raw public `discoverSources(...,{seed})` does not obtain this new entry permission.
Missing/old/unusable state or absent API preserves the original trace path.

Independent static review passed the exact combined02 driver. `controls03.mjs`
pins it and adds ten fresh-state host predicates, freeze, and two public-host mock
groups while retaining prior IO obligations. These mocks test permission routing,
not Bend alpha-renaming correctness; the actual source/source-API controls remain
the loader owner's gate. Node syntax checking passed; no author target execution.
Four source API additions relative to the installed 77-root bootstrap are
`base_prefix_prepare`, `check_program_diagnostic_seed`, `f_fresh_prefix_prepare`, and
`f_graph_trace_from_prefix`. A real bootstrap must use its actual 81-root list.

## Bootstrap inventory correction

Combined02 omitted registering the four new source methods as explicit bootstrap
exports. The resulting state02 build passed selected36 but exported only 77 roots,
so reachability removed the unused helpers and no optional prepared states existed.
That build/controller refusal is preserved; host-only IO predicates were insufficient
to demonstrate actual source activation.

Root's [combined03](../../selfhost/tools/performance/phase61/cache/typed-driver-combined03.mjs)
adds exactly two manifest-conditional export statements, retaining combined02's
remaining bytes exactly. Its [delta receipt](../../selfhost/tools/performance/phase61/cache/combined03.json)
pins the live fix. Rebuild/actual 81-root activation remains a separate gate.
`controls04.mjs` preserves the IO obligations and adds a pre-import static inventory:
both source modules must be in the manifest, all four exact export branches must
exist, and their actual Bend definitions must be present. This prevents the same
source-wiring omission before a target, but does not substitute for a real checked
bootstrap receipt and actual prepared-state controls. No performance claim follows.

## Current reviewed source: segmented frame2 and native carrier

Root authorized exact application of [combined04](../../selfhost/tools/performance/phase61/cache/combined04.json)
to maintained `tools/typed-driver.mjs` after focused controls. Its five additional
source exports bring the intended bootstrap inventory to86. The new carrier is
returned/updated by actual Bend loader methods; JavaScript only threads its opaque
value. Caller-supplied `inspect({api})` and raw `discoverSources` calls cannot obtain
the distinct private token. A persistent inspector owns its API explicitly.

Frame2 stores separate raw book/checked-state/fresh-state JSON segments, with exact
lengths and byte hashes checked before parsing. Optional digest or JSON failure
omits that state and keeps the independently valid book/full-check fallback.
Private admission reuses the raw state digest. Its span walker is only for freshly
parsed, privately held acyclic JSON trees; it checks the same literal/Lambda/spans
and all extra own children without WeakSet/Object.values. Both public validators
remain byte-identical. Memo freezing and file-change/deletion invalidation remain.

Root's [controls08 report](../../selfhost/build/phase61/cache-frame2-controls08/report.json)
passed56 host groups in0.905647s. [Controls09](../../selfhost/build/phase61/cache-carrier-controls09/report.json)
passed57 groups in1.0066s, retaining those obligations and adding caller-supplied API
carrier refusal with a ready synthetic cache. These are host IO/permission tests,
not a proof of Bend checkpoint reuse. Actual86-root bootstrap, source differential
qualification and representative throughput remain the separate root-owned gates.
No standalone frame2 speedup or installation is claimed.

Preserved failures: controls06 tried to expose an encoder absent from its old
baseline; controls07 sealed an extra-child fixture before mutating it. Both failed
in the harness, not candidate semantics. Successors correct those exact issues.
Independent review also required optional malformed JSON to preserve the valid
book; frame03 supplies that correction. All predecessors remain unchanged.

The [synchronous workflow successor](../../selfhost/tools/performance/phase61/cache/workflow-sync02/proposal.json)
is prepared but unapplied. It prefers frame2, then frame1, then the legacy filename;
a present malformed frame never falls through. Canonical workflow application must
wait for source/driver winner selection and completion of older pinned attempts.
