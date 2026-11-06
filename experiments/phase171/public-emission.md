# Fuse public worker conversion with its emitter

Experimental source only. The maintained compiler, runtime, private-worker
renderer, registry and final verifier are unchanged. The candidate replaces
**only `p112w_public_segment`**, plus nine private helpers in
[public-emission.bend](../../selfhost/tests/phase171/public-emission.bend)
(86 lines; SHA256 `20abf38ffaf1d8c55b767db8152b6094dab56635e828d458e640538dbd400940`).

The original public path constructs `p112w_public(body,name,ready)`, a complete
`List<P112WorkerStmt>`, then immediately consumes it with
`p112w_stmts(...,[],True,ids,code)`. Every ordinary node wraps an `N111Stmt` only
for the consumer to unwrap it. Branches construct another full worker tree.
The new path executes their composition directly, without this intermediate.
This is separate from the pending original-body hygiene experiment and performs
no registry dependency caching.

## Equivalence boundary

The private emitter implements exactly:

```
p171pe_stmts(body,owner,ready,ids,code)
  = p112w_stmts(p112w_public(body,owner,ready),[],True,ids,code)
```

- Empty bodies return the same code, including its existing terminal/error state.
- A nonempty body with an existing error returns the same code; a nonempty body
  after transfer constructs exactly `statement follows private worker transfer`.
  Skipping unused pure worker-tree construction changes no observation.
- The tail-call test is unchanged: original target discovery, ready lookup,
  owner inequality and complete `p112t_tail` predicate. On success, the same
  first `arity` scalar nodes are emitted, followed by the original `p112w_call`
  with `public=True`, including its argument snapshots and runtime return.
- Ordinary scalar instructions still use `p111q_stmt`. Only the temporary
  `P112WorkerScalar` wrapper/list cell disappears.
- Branches reserve the same three labels, emit yes then no in the same order,
  retain terminal-dependent jumps, and finish through the unchanged
  `p111q_if_done`. Fresh label state and prior errors are threaded identically.

The actual public producer emits only scalar, branch and call variants.
This is not a replacement for arbitrary `p112w_stmts`: its private-worker
`Again`/`Result` modes and nonempty parameter lists remain untouched. The outer
`p112t_plan` shortcut, result/flags fallback, alloca discovery, function header
and `p144e_body_tail` error/fallthrough strings also remain exactly as before.

## Source checking and complete-output controls

Use the existing Phase171 source preparer. Candidate additions are
[public-emission-laws.bend](../../selfhost/tests/phase171/public-emission-laws.bend)
as `--prelude`, the candidate module as `--module`, and
`--replace p112w_public_segment`. The two forward laws use the tested `for`
syntax; `@unsafe` marks definitions only. No nested earlier-binder matches occur.

Both baseline and candidate include unchanged `lazy-admission-controls.bend`,
[public-emission-controls-v2.bend](../../selfhost/tests/phase171/public-emission-controls-v2.bend),
and export `p171pe_case`. Start from the same combined four-overlay source,
without adding the neutral live-environment shortcut or other unmeasured changes.

The v2 fixture differs from retained v1 only in mode45: it uses an explicit
valid pure self-tail loop to establish that the unchanged specialized-tail
dispatch is positively exercised. No compiler algorithm changed in that fixture
revision. The other 47 cases are identical.

```sh
selfhost/.assets/bin/bun selfhost/tests/phase171/public-emission-controls-v2.mjs \
  --baseline BASELINE_API_REPORT --candidate CANDIDATE_API_REPORT --out FRESH_OUT
```

The runner compares **48 complete public function strings**, retaining both
outputs and authenticating API/source/method pins before and after observation.
Cases include nonempty recursive code on the fused public path, nonempty direct
calls with zero and one argument, missing/wrong-kind/wrong-arity workers,
self-call exclusion, malformed argument offsets, nested branches, one or two
terminal arms, statements/branches after transfer, empty-body fallthrough and
the unchanged raw/tail-specialized dispatches. Explicit expected path and error
markers prevent empty-output agreement from passing. Constructed malformed IR
is not executed as a runtime program.

Source inventory and delimiter checks pass offline. The root execution lane
then source-checked both APIs, passed all 48 complete-output controls, and
compiled the actual verifier source to the exact retained QBE product.

## Performance decision

After semantic gates, compile the same retained actual verifier source and
require byte-identical complete QBE. Compare the complete request and render
interval against the existing combined candidate. Stop after a neutral result;
do not pay for a standalone full native acquisition without a material signal.

The 30.454-second current diagnostic render/output interval is only a generous
scope ceiling. The frequency and allocation cost of this particular intermediate
have not been measured. Added helper dispatch, changed lifetimes and recursive
execution can offset the removed products. There is no speedup forecast or
native/generated-program qualification claim yet.

## Actual result: correct, neutral; no native acquisition

| Fresh hosted observation | Baseline | Candidate |
| --- | ---: | ---: |
| Complete request |28.937044s|28.843105s|
| Lowering and verification |13.512123s|13.511179s|
| Rendering and writing |2.739727s|2.819887s|

The complete-request difference is about 0.3%, while the target render interval
is slower in this pair. These single observations establish no useful gain.
Stop this subset here: it does not justify a standalone native acquisition or
another small emitter variation. The broader representation/retry ceiling
remains unmeasured; this result cannot be credited as progress against it.

All receipts below are under `selfhost/build/phase171/`:

- Checked baseline: `public-baseline-api01/report.json`, SHA256
  `235a6da2909f7f512cb448c04ac150716cad72e3c046a77cf6bec96653c3188b`.
- Checked candidate: `public-candidate-api01/report.json`, SHA256
  `44d1d726fa3bba9e15d5bd86a6c6f64b1ab3b14c6e2e67b222fda493965e0cde`.
- Complete controls: `public-controls01/report.json`, SHA256
  `a1329237160b1f1e1e695034228caeade62237eb78ff5397541698b6fea208c0`.
- Request baseline: `public-verifier-baseline01/report.json`, SHA256
  `1b1658464fd59b892a92b1f9a9e670589a7ddae1e5ebed72e61b95b4239c5639`.
- Request candidate: `public-verifier-candidate01/report.json`, SHA256
  `4bea6b73789e7f41455ad7fa2b1e4e680a8b653fa9e3978be8ef96e3f2d6f312`.

Both outputs are 2,309,376 bytes, SHA256
`8be3a072b84dfc8bb85ddb9478c00d05179f7de89c8d4079af9ca3a5190bfbfb`,
from the identical 39,333-byte verifier source, SHA256
`ff6b4083aa2f3e034f3b4f8e43dfb25d93a4f524685934e0ee13845278033ef3`.

## Measured decision

Both checked APIs acquired successfully. All48 complete-output controls pass
(`public-controls01/report.json`). On the actual retained verifier request,
`public-verifier-baseline01` takes28.937044s and
`public-verifier-candidate01` takes28.843105s. Render/write is2.739727→2.819887s;
lower/verify is13.512123→13.511179s. These fresh hosted single observations
establish **no meaningful request-time gain**. Both emit exactly2,309,376QBE
bytes, SHA256 `8be3a072b84dfc8bb85ddb9478c00d05179f7de89c8d4079af9ca3a5190bfbfb`.

Removing the intermediate worker list is source-confirmed, but this subset does
not justify a full native compiler acquisition or integration. Keep the bounded
experiment off the selected path. The broader registry/render interval remains
substantial; its full duration is not a forecast for this particular change.
