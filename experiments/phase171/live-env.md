# Reuse the already filtered value environment

This experiment removes a redundant liveness traversal at five private-lowering
call sites. It does not change the liveness representation, cache ASTs, bypass
the actual final verifier, or broaden direct-call admission. The source change
is five calls from `*_lower` to `*_live`, on environments those callers have
already filtered for the exact same immutable value.

## Exact scope and equivalence argument

The candidate is [fail-fast-live-env.bend](../../selfhost/tests/phase171/fail-fast-live-env.bend).
It replaces the frozen [fail-fast.bend](../../selfhost/tests/phase171/fail-fast.bend)
module in an otherwise identical candidate. Its nine replacement declarations
and two forward laws remain the same as that module. Only five bodies differ:

| Declaration | Already established fact | Changed first-value call |
| --- | --- | --- |
| `p113d_let` | `value_env = nc_live_env(env, value)` | `p113d_lower` → `p113d_live` |
| `p113dl_let` | Same | `p113d_lower` → `p113d_live` |
| `p113pl_bind_flat` | Same | `p113pl_lower` → `p113pl_live` |
| `p113pl_bind_boxed` | Same | `p113pl_lower` → `p113pl_live` |
| `p113px_boxed` | Same | `p113pl_lower` → `p113pl_live` |

`nc_live_env` retains precisely the input bindings whose IDs occur in the
value. It preserves binding order, duplicate IDs, widths and names. The lowerer
then partitions that same environment by uses of that same value. Every binding
is already live, so the partition's drop list is empty and its live list has
the same ordered contents. Calling the live entry directly removes the second
uses scan and empty partition, while preserving the code, error, calls and fresh
counter produced by lowering.

For `Let` and `NSeqLet`, the live entry still builds and consumes the existing
`P112Liveness` plan. The plan's use memberships agree with `nc_uses`: an original
raw binding head is scanned whole, and a raw `Var` remains a leaf even if it has
malformed children. This detail is necessary; a generic recursive walk over all
children would not justify the substitution. The generic lowerer already uses
the same filtered-environment-to-live-entry pattern in `p112_liveness_cut`.

The initial `nc_live_env` must remain. Passing the full environment would allow
the value lowerer to drop bindings still needed by its continuation. The fact is
also tied to this exact value root: it cannot be reused after substitution,
sequence conversion, or argument reconstruction without a separate proof.

[The source audit](../../selfhost/tests/phase171/live-env-originals.json) pins
the parent and successor. Applying the inverse of the five call substitutions
recovers the complete parent overlay byte for byte; no other declaration or
fail-fast condition changes. Candidate SHA256 is
`393586feadf21be6629e4240c3207ac4655168ac0a5d00a65db5063a8d78425e`.

## Why existing reuse does not remove this work

`P112Liveness` already removes repeated traversal of shrinking continuation
suffixes. It retains suffix-union uses, not a separate use set for every bound
value. A suffix union cannot recover the value's use set by subtraction, because
the value and continuation may share variables. This experiment reuses the
filtered environment already present at the immediate consumer, requiring no
new set, union, lookup or annotation.

This is separate from the older negative findings:

- [Phase166's prepared-body census](../phase166/backend-census.md) found 76
  compact-definition queries but zero recorded `nc_compact` entries in Map's
  private production. That reuse already worked; another prepared-body cache
  was not justified.
- [Phase164's hybrid result](../../implementation/phase164/README.md) measured
  201.931s versus 201.271s for complete image acquisition. Rearranging selection
  while retaining downstream work did not establish a material gain.
- [Phase163's direct-ABI audit](../phase163/direct-abi-audit.md) examined how
  `nc_uses_term/list` execute, including their recursive sibling state. This
  experiment removes an entire redundant invocation instead of changing those
  primitives or claiming recursion is statically bounded.

## Executed semantic gates and next decision

The root execution lane acquired two separately checked APIs and ran all **44
full-record differential controls successfully**. Both failed and successful
`P113DCode` records match exactly, including body, calls, fresh state and error.
Inputs cover empty environments, duplicate IDs with different widths/names,
malformed Var children, malformed sequence heads, nested/empty lets, product
values, and outer drop order. Unlike the earlier fail-fast test, this experiment
does not permit differences in partial records on refusal.

Exact receipts are under `selfhost/build/phase171/`:
`live-baseline-api01/report.json`, `live-candidate-api01/report.json`, and
`live-controls01/report.json`. The runner is
[live-env-controls.mjs](../../selfhost/tests/phase171/live-env-controls.mjs),
with [Bend fixtures](../../selfhost/tests/phase171/live-env-controls.bend).
It authenticates both API/source receipts before and after observation and
persists the complete records. No native or complete-request speed gain has yet
been established by this gate.

The actual verifier-source request subsequently passed exact complete QBE and
the same final verification, but established **no performance gain**:

| Hosted observation | Combined candidate | With live-environment shortcut |
| --- | ---: | ---: |
| Complete request |29.031967s|29.513512s|
| Frontend |8.051557s|8.301016s|
| Lowering and verification |13.918687s|14.151341s|

These are single, unbalanced observations. The unrelated frontend also slowed;
the result is compatible with noise and does not demonstrate a semantic or
performance defect in the shortcut. It does fail the gate for paying for a
standalone full native acquisition. The overlay remains available for a later
combined native candidate, with no expected-gain credit.

The 39,333-byte input has SHA256
`ff6b4083aa2f3e034f3b4f8e43dfb25d93a4f524685934e0ee13845278033ef3`.
Both 2,309,376-byte outputs have SHA256
`8be3a072b84dfc8bb85ddb9478c00d05179f7de89c8d4079af9ca3a5190bfbfb`.
Receipt `combined-verifier01/report.json` has SHA256
`9b253f3218485911152364c8c7c0ec039180f01f167ddae9cf27da61af50ec64`;
`live-verifier01/report.json` has SHA256
`04b5e03f356d35449936b7243f3163425e7279904d4bfa9b1c53be207a76be50`.
Both are under `selfhost/build/phase171/`, complete and exact-output. They do not
claim execution of the generated program's independent runtime oracle.

The current combined diagnostic raw-private-candidate interval is **24.985s**,
and demanded generic fallback is **8.508s**; these are separate disjoint clocks,
not clean performance timings ([profile](candidate-profile.md)). This change
affects a subset of private-candidate work; it does not remove the fallback
interval. The earlier 1–5s speculative envelope is withdrawn: neither invocation
frequency nor native savings have been measured. The raw-candidate clock bounds the
benefit available inside that region; other invocations must be attributed
separately. An empty filtered environment already skips the ordinary use scan,
and sequence-valued inputs still construct their liveness plan. Treat it as a
cheap work-elimination test, not a credible
standalone route from approximately 181s to 100s.

## Whole-request screen

The root's `live-verifier01/report.json` completes with byte-identical QBE to
`combined-verifier01/report.json`. Its hosted whole request is29.513512s versus
29.031967s in the earlier combined observation; lowering/verification is
14.151341s versus13.918687s. Frontend time also differs8.301016s versus8.051557s.
This single unbalanced screen establishes no speed gain and does not isolate
regression from timing variation. It does not justify a standalone full native
compiler acquisition. The five source substitutions and44 exact controls remain
useful evidence of equivalence, not a demonstrated optimization win.
