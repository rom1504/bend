# Final review witnesses

These eight paired check-lane cases retain the final read-only phase 2 review.
The four declaration-order cases agree on acceptance/phase. The other four
record known frozen-v2 gaps: unsafe-before-law, parallel constructor binders,
and typed/untyped semicolons inside a list operator RHS. Expected results follow
the live pinned TypeScript parser; this matrix intentionally does not fully pass
on frozen v2. It is a replay/repair queue, not a new required release gate.

From `selfhost/`, create a new configuration such as `build/review-config.json`:

```json
{
  "upstream": "../.bootstrap/upstream",
  "api": "phase2/grammar-v2/checked/api.mjs",
  "runtime": "../src/runtime.mjs",
  "bootstrapReport": "phase2/grammar-v2/checked/api.mjs.bootstrap.json",
  "selection": "../tests/frontend/phase2-review/cases.json",
  "cpu": 2,
  "timeoutMs": 60000,
  "stackKb": 4096,
  "heapMb": 4096,
  "retain": "all"
}
```

Paths resolve relative to the configuration. Select an available CPU and the
explicit checked API under review, then run:

```sh
node tools/conformance/target.mjs build/review-config.json build/review-result
```

Use a fresh output directory. Acceptance/phase oracles and exact diagnostic
agreement are reported separately. See the
[review findings](../../../../implementation/phase2/frontend-final-review.md).
