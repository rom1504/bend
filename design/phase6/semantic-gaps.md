# Next semantic-gap experiment (proposed, isolated only)

Preregistered 2026-09-23 before the first new build. Production Phase5 remains
frozen. Owner: lexer_analysis; root reviews and controls resources.

First hypothesis: validate the erased-let name before constructing its raw Ref.
Pinned parse_body calls parse_name after a leading minus. f_erased_local currently
accepts any token, so -5 parses and later fails checking. A private overlay adds
one shared name guard after newline-only whitespace normalization; valid names
retain the previous continuation. A valid erased local, typed local or law body
must preserve its result. Numeric/string/braced/semicolon/EOF heads must fail in
parse before any later malformed body. Reserved/trailing-dot error cursor parity
is not assumed. This does not yet implement the separate mandatory '=' rule for
a lone -x, or general erased parallel-let grammar.

Root authorized one fresh genuine checked B1 build and focused paired gate on
CPU1, overlapping broad correctness. Bound five minutes, finish by03:15UTC;
no timing or production-promotion claim. Preserve original baseline failures,
actual exact diagnostics, source/tool hashes and all failed build/fixture attempts.
Require normal bootstrap, unchanged input verification, valid positive controls,
the original prefix_operator_dead fixture and selected first-error neighbors.
Unknown failure or positive regression blocks promotion.

The two +name gaps are separate. Pinned parsing produces an intentionally unbound
Var(name,-1), while the port emits Error before checking. Do not resolve it to
the existing local or use U32_MAX: the latter feeds norm_max+1 and can wrap.
A later isolated alternative is a private frontend marker consumed by global
freshening, allocating a Var identity without adding a binder mapping. First
prove marker elimination and noncapture through flattening, templates, seeded
loading and nested shadowing. Exact -1 diagnostic presentation is a separate
obligation; no marker implementation/build is authorized by the erased-name gate.
Detailed root-cause analysis and observed results are in
[the implementation note](../../implementation/phase6/semantic-gap-analysis.md).
