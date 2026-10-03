# P41-003 — Lexer String host ownership

- Status: feasibility falsifier passed; full compiler integration deferred from this campaign. No lexer optimization or speed gain is claimed.
- Baseline: Phase40 checked06 lexer output and API; upstream pin unchanged.
- Design: [lexer proof contract](../../design/phase41/lexer.md). Current evidence: [lexer feasibility record](../../implementation/phase41/lexer.md).

**Hypothesis.** Existing numeric/scalar ownership checks are insufficient to admit a private String lexer region safely. A narrow contract would have to own String globals/statics/prototype hooks as well as preserve native String, Char, Sigma and Bool behavior, Unicode splitting, callback-free execution, and exact fallback semantics.

**Cheapest disproof.** Replace `String.prototype.codePointAt` or `String.fromCodePoint` with a callback while the existing scalar guard remains true. If either hook runs inside the proposed owned region, reject the unchanged guard as insufficient. Do not infer safety from scalar input types or the prior manual benchmark.

**Observed checkpoint.** [`lexer-counterexample01`](../../selfhost/build/phase41/lexer-string-host-counterexample01/report.json) completed: the original scalar guard returned true with an overridden `codePointAt` called twice and overridden `fromCodePoint` called once, while Unicode values remained complete. The case falsifies reusing that guard as a String host-ownership proof. The full exact-ABI/compiler proof spans multiple independent gates and is deferred; no source patch or timing is authorized by this experiment card.
