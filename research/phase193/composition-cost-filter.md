# Phase193 composition economics: bounded consumer proposal

The newly built complete N2 exposes a cost missed by the small extracted kernel:
most growth is copied public continuation code. Root separately reports useful
same-request N2 improvements and4.67% suite runtime improvement; those gains do
not make the build/storage cost disappear. No candidate was executed here and
no maintained or frozen source was changed.

Read-only nm size census over Phase192/Phase193 native-self01/program, with
[exact ELF identities and bounded witness counts](composition-cost-evidence.json):

| Function class | Phase192 bytes | Phase193 bytes | Delta |
|---|---:|---:|---:|
| p111 public bodies | 16,143,825 | 19,133,183 | +2,989,358 |
| p113d private bodies | 2,234,270 | 2,247,439 | +13,169 |
| p114r recursive regions | 295,165 | 298,569 | +3,404 |
| p112w forwarders | 6,190 | 6,270 | +80 |
| runtime and WL | 53,833 | 53,833 | 0 |
| Sum of text-symbol sizes | 18,733,283 | 21,739,294 | +3,006,011 |

Public bodies account for99.45% of this symbol-byte delta. This count excludes
inter-symbol alignment and non-code sections. Compiler source changed, so it is
not an exact isolated size ablation. However, the largest matched named public
owners directly exhibit extensive continuation copying:

| Public owner | Bytes before → after | Instructions before → after | Ready calls after | Native frame before → after |
|---|---:|---:|---:|---:|
| p113l_base_binary | 1,326 → 7,871 | 277 → 1,552 | 8 | 2,544 → 15,776 |
| sk_other | 399 → 6,309 | 84 → 1,202 | 8 | 2,368 → 15,744 |
| noa_eval_step | 587 → 6,399 | 123 → 1,238 | 8 | 2,400 → 15,664 |
| norm_match | 587 → 6,087 | 123 → 1,182 | 8 | 2,400 → 15,536 |

For example p113l_base_binary grows from6 to61 static sink calls. A plain
ready-tail ABI adapter does not introduce those ownership operations; copied
continuation bodies do. The original fusion planner intentionally permits up
to8 copied sites and admits bounded continuations individually. That semantic
limit is not a whole-consumer code-size profitability budget. Ready-call counts
are not asserted to equal exact planner fusion counts; the latter were not
executed/measured by this audit.

## Cheap decisions before another complete build

1. Root's independent tail-only and fusion-only kernel ablations distinguish
   benefit attributable to the two mechanisms. Their runtime and emitted sizes
   remain useful screens, but cannot alone predict complete compiler bloat.
2. Screen the optional consumer below on the same named compiler-owner witnesses
   and unchanged ordinary programs. Capture original/fused IR statement counts,
   plan count, eligibility and actual emitted bytes. Do not infer IR counts from
   the machine ratios in this note.
3. Require retained compiler/user gains and a materially smaller complete emitted
   compiler object before another expensive reproduction gate. The consumer
   should be rejected if its added scans cost more than avoided emission work.

## Optional consumer implementation

Files: `selfhost/tests/phase193/public-fusion-budget-experimental.bend` and
`public-fusion-budget-integration.patch`. Append the module to an experimental
canonical source inventory and apply the one-call hook. No maintained edit has
been made. Root owns versioning, checking and execution.

The proposed policy uses existing `p112f_size` exactly twice, only when the
original fusion plan reports a nonzero site count. Accept when

```
fused_statement_count <= 2 * original_statement_count + 16
```

A precondition prevents arithmetic overflow. Both nested If arms count exactly
as in the existing helper. There is no new graph analysis, name heuristic,
benchmark condition or per-node nested scan: added work is O(original+fused)
per successfully fused public body. It does not avoid the original planning
cost because filtering occurs after its complete plan is constructed. It aims
to save downstream selection, allocation, byte emission and machine construction.

On refusal, call `x193f_tail(original,ready,tail_enabled)`. Thus an expansive
fusion cannot suppress the independent cheap ready-tail opportunity. There is
no partial fusion prefix or relaxed semantic admission. The original H/direct
precedence, verifier, namespace/symbol-availability checks and original fallback
remain intact. The seven finite policy boundary rows are authored but unrun.

The2×+16 policy is a testable initial threshold, not a calibrated optimum. It
should reject the gross6–16× machine expansions above while potentially retaining
the four hot witnesses' approximately1.0–1.4× machine growth. **That retention is
not established until their actual IR counts and emitted objects are observed.**
The proposal imposes no separate fusion-count cap because p111v_put needs three
ready calls and a count-only cutoff would discard its small successful body
without accounting for actual copying cost. A large but relatively stable body
can still pass; a separate absolute budget is deferred until evidence requires it.
