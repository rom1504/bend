# P145-001 — semantic work versus execution cost

Hypothesis: repeated representation/analysis work and backend-specific execution
cost can be separated through same-source JS/QBE execution and a distinct pinned
upstream implementation comparison. The resulting operation/cost matrix should
identify a higher-leverage architectural boundary than another isolated helper.

Status: completed information campaign. See the
[design](../../design/phase145/README.md),
[report](../../implementation/phase145/README.md), and
[architecture conclusions](../../research/phase145/architecture-decision.md).

Thirty exact-QBE clean observations show the same Bend compiler running roughly
6.2–7.1× faster natively than as generated JS on four requests. Warm JS does not
close the Lexer gap. This is not an upstream TypeScript speed ratio. Upstream
retains checked runtime bodies and useful backend facts but also executes two
to five fact-discovery/emission rounds. Full-source load/parse is 2.583s, a useful
scope-qualified contrast with the retained 31.175s native parser experiment.

A strict Lexer witness confirms the same unchanged raw/static object is checked
twice. Source/counter evidence supports private checked-context reuse and compact
numeric local environments as bounded next experiments. Neither is implemented
or assigned a measured whole-build gain here. Fixed Base cost is about 0.23s,
so its large small-request allocation share cannot explain full-build latency.

32 guarded jobs total 306.58s, including two failed observers/preparations in
8.17s; peak process-tree RSS 500.09 MB, no OOM. Failed attempts, dependency pins,
methods and evidence are preserved. Production compiler/runtime, final verifiers,
proof contracts, qualification and installed selection remain unchanged.
