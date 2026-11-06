# Early-route constructor metadata audit

The missing cold-constructor derivation does **not** remove an optimization from
the qualified full compiler: its actual695 constructor entries are all hot,
and its capability word is5, with cold-publication bit8 disabled. The same
observation for the verifier slice was therefore representative on this narrow
question. This conclusion is static artifact/source evidence, not an execution
quality result for the new compiler.

[Exact input hashes and counts](constructor-cold-audit.json) bind the qualified
118,227,421-byte Phase152 N2 QBE (`1032c6a6…`) and Phase169 verifier stream. The
full compiler's effect table contains File.write, File.close, File.read,
File.size and File.open, in addition to IO.print/now/args. Those File entries
are sufficient to explain the conservative permission refusal:

- `p118c_plan` (`selfhost/src/back/qbe/ownership.bend:350`) requires
  `ns_definitions(book,names)` before deriving sharing/cold facts.
- `ns_definitions` (`selfhost/src/back/native/scalar-array.bend:51`) accepts
  filled foreign providers only from IO.args, IO.print and IO.now. The native
  compiler's reachable File effects fail this older scalar/ownership permission.
- The broader observer permission `p118i_permission` is a distinct contract.
  Its permission to read retained roots does not authorize skipping constructor
  publication/sealing or enabling scalar array representations.

There **is** a general code-quality omission for other eligible programs.
`p168_request_mode` (`selfhost/tests/phase168/early-scalars.bend:179`) constructs
the default catalogue and enters `p168_catalogued` directly. It bypasses the
`p167l_start` route that, for its mode1, applies
`p167l_cold(constructors,p118c_plan(request))` before static preparation. The
Phase168 mode number describes scalar preparation, so it must not silently
inherit the unrelated Phase167 mode interpretation.

If restoration becomes relevant, the smallest legal route is to rederive
`p118c_plan` from **the same immutable checked request**, apply its constructor
list only when `valid && error==""`, then pass the selected catalogue into the
existing static/candidate/adaptor pipeline. Existing emission already calls
`p118c_tables`, which enables bit8 iff a real zero hot byte is emitted. Do not
set bit8 directly, supply caller-chosen cold names, replace `ns_definitions` by
the broader observer permission, or treat final structural verification as
proof of the ownership analysis.

The cheapest existing semantic gate is the preserved Phase118 pair:

- `selfhost/tools/performance/phase118/cold-controls.bend`, SHA256
  `6ffb8c0a25e7d839aa5ad80af1be7bacf9667424ff3823f481a60d9b4babe16b`;
  literal full oracle `cold-transitive.expected.json`.
- `selfhost/tools/performance/phase118/observer-control-v2.bend`, SHA256
  `1707367d4630350275e1cc6dbf7a15e997df9ae51e4d75842a4719cc817cce2c`;
  literal full oracle `observer-v2.expected.json`.

The original complete receipts remain under
`selfhost/build/phase118/cold-controls-{emit,run}01/report.json`. The transitive
case distinguishes shared nested trees/containers from a genuinely cold
envelope; the observer case combines retained roots with cold List constructors.
Reuse only the authenticated sources/oracles with the current API/guard; their
historical executable or compiler is not evidence for a new candidate. Add a
current real-File request as a refusal control: the rederived plan must remain
invalid/all-hot/cap5. Then compare complete emitted metadata and native stdout.

No new target or production patch was made for this audit. Do not delay the
current full-native transfer solely for cold restoration: the exact baseline
cannot lose cold flags it did not have. Other execution-quality differences
still require the planned real compiler request screens.
