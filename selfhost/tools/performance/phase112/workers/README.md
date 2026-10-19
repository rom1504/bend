# Structured self-tail workers

This bounded candidate reuses the mature NF self-tail criterion: exact callee
identity, terminal position, matching arity, and simultaneous argument transfer.
The precedent is `nf_call_local` plus `nf_self_temps`/`nf_self_moves` in the selected
Phase102 compiler. It consumes the already checked structured Phase111 graph;
it does not invoke, parse, or rewrite the mature C-producing NF/NQ planner.

Append `model.bend`, `plan.bend`, and `emit.bend`, then replace the exact
`p111q_segment_chunks` declaration using `entry.bend` (also in `overrides.json`).
This changes one function-emission call. The public `p111q_chunks` signature,
metadata, original scalar emitter and mandatory `p111_verify_program` gate remain
unchanged. Unsupported segments return byte-identical original function text.

The private plan accepts direct entries with flags zero, no incoming continuation,
one result, and an exact scratch allocation/ordered register-parameter prelude.
Duplicate parameter names are rejected. Body register reads, state memory access,
extra allocations, pointer aliases, frame manipulation, dynamic apply and explicit
fail transitions refuse the whole worker. All ordinary exits must retain an exact
terminal runtime jump/return followed by the corresponding machine return.

An exact terminal sequence of ordered scratch stores, self jump, and return is
replaced by an internal loop edge. The stores remain. Every scratch argument is
loaded into a private temporary before any parameter changes; then all parameter
locals are rebound and the loop repeats. QBE constructs SSA from these mutable
temporaries. Initial getters and allocation run once. There are no direct C calls
between workers in this first experiment.

Keep/sink, constructor/take, primitive operations and their order are unchanged.
The runtime register bank contains transport words, not independently scanned
owners; an eliminated overwrite did not release owners. No frame operation is
admitted, so an internal iteration cannot accumulate continuation frames. Direct
entry starts with rn=0; no admitted nonterminal helper changes rn or next. The
dispatcher resets next to STOP before entry; a later retained terminal transition
sets it normally. The selected one-worker runtime dispatcher has no per-transition
scheduler poll; bang/continuation workers fall back. This is a source argument,
not a formal ownership proof, and depends on the checked lowerer/runtime boundary.

Private machine names `%p112_arg_N`, `%p112_at_N`, and `@p112_again` are separate
from ordinary `%v_*`, `%t_*` and `@b_*` namespaces. The plan never trusts a name
substring to identify a source algorithm.

Coordinator-only gates:

1. Check the composed compiler source, exporting `p112t_plan`, `p112t_admitted`,
   `p112t_program_counts`, and `p112q_segment` in addition to the old API.
2. Run `controls.mjs API.mjs FRESH_OUTPUT` under the serial guard. It checks the
   actual Bend admission/emitter, exact fallbacks, original-verifier refusal,
   argument ordering and preservation of keep/sink calls. Build its baseline and
   candidate QBE against the same runtime04; both must print `2211`.
3. Compile/run `swap-owners.bend` and the frozen reverse/alias corpus through the
   normal checked source entry. Count admitted full compiler loops from the same
   checked IR using `p112t_program_counts`; no source-name estimate substitutes for
   that count. Measure only after correctness and machine inspection.

No target was run during source preparation. No shared Phase111 source or Bend
language implementation was changed. The exact original API remains the fallback.
