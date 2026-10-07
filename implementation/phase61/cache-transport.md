# Cache transport draft

[Source identities and placement](../../selfhost/tools/performance/phase61/cache/source01.json) ·
[Driver patch](../../selfhost/tools/performance/phase61/cache/frame01.patch) ·
[Design and boundaries](../../design/phase61/cache-transport.md).

The maintained driver is untouched. Root may stage `typed-driver-frame01.mjs` as a
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
