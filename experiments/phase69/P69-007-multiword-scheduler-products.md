# P69-007: activate product workers across recursive scheduler returns

Status: prospective; registered before generated-C derivation or measurement.

Map's emitted private product workers for `Map.bit.chr`, `Map.bit.go.chr` and
`Map.bit.go.rec` are already present but unused. Their ordinary scheduler callers
retain one-word Tuple results at every recursion layer. Upstream uses two result
registers across this recursive island and calls its local product workers.

Hypothesis: a private two-word scheduler island for `Map.bit.go`, invoking the
existing product helpers and boxing once at its ordinary boundary, removes a
material fraction of Map time. It avoids both temporary Tuple shells and the
RFC wrappers introduced when an owned String is sealed inside each temporary
Tuple. This is distinct from scalar-field loop transport in P69-004.

The diagnostic retains the ordinary entry and device body, changes the host entry
to a wrapper, clones the existing matching/error paths into a private three-argument
scheduler entry, and adds a two-result recursive continuation plus boundary box
continuation. It uses the existing scheduler stack, task protocol and product
workers. No unbounded C recursion, borrowing inference, omitted String traversal,
runtime helper rewrite or benchmark algorithm substitution is permitted.

Input is the exact compiler23 Map C pinned by Phase68. The source-only producer
must retain reversible edits and metadata updates: function IDs, arity, result
widths, register save/restore maximum, dispatch tables and host/device routing.
The root alone compiles or executes. Primary discrimination: independent output
oracle, one/four-thread controls, lower allocation/wrapper counts, and balanced
clean time against unchanged23 and upstream. Larger gain remains a hypothesis.

Production direction: plan a private result layout before scheduler lowering;
retain generic boxed adapters; propagate result width through continuations and
recursive SCCs; admit existing product workers at their actual call sites.
No production patch is authorized by this experiment alone without raw/effect/
ownership and another unrelated recursive-product control.
