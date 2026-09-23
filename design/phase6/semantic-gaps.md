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


## Authorized marked-name spike — 2026-09-23 02:59 UTC

Root authorizes at most15minutes, CPU1 correctness, all compiler jobs stopped
by03:12UTC. No source/default promotion. Use a fresh final05 snapshot (do not
silently combine the erased-name patch). Two-module candidate: marked non-ADT
value references that are locally bound or syntactically unqualified become
private FUnboundVar nodes; global freshening consumes them into fresh Var IDs,
advancing next without an environment mapping. Qualified nonlocal references
retain the existing quantified-datatype rejection. ADT branches are untouched.
The resulting ordinary core Var is deliberately unbound. No U32 sentinel or
permanent core tag, checker bypass, diagnostic-string rewrite or signed-ID change.

First gate: actual two pinned cases must parse successfully and fail checking as
unbound variables. Their strict diagnostic oracles stay intact; fresh positive,
global/qualified, datatype, nested/imported and competing-error controls run live
against pinned TypeScript. Exact text may retain a different printed fresh ID;
that is not an exact conformance fix. An explicit post-loader shape check must
prove marker elimination and no free-variable ID capture by any binder, with
seeded/unseeded comparison. Valid neighbors must retain exact core graphs.
Stop on a new acceptance regression, capture/overflow, marker escape at the
ordinary checked loader boundary, or architectural work beyond this capsule.

### Marked-name spike outcome — 2026-09-23 03:06 UTC

The isolated scope-only marker is rejected for promotion. Selected classification
agreement improves8→18 of19, and ten allocation/noncapture controls pass, but
`+f(1)` introduces a new parse/check phase mismatch while `(+f)(1)` needs the
opposite phase. The next coherent attempt must preserve prefix operand precedence
before marking; it cannot simply widen the scoper's accepted references. The
existing `+U32` false acceptance and template_arg_done diagnostic collapse are
separate pre-existing issues. The [result note](../../implementation/phase6/marked-name-analysis.md)
retains the genuine build, baseline comparisons, original failed oracles and
uncompleted gates. Production/default source is unchanged.
