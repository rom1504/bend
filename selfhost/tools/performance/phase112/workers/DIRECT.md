# Bounded direct workers

Append the frozen loop modules, then `direct-model.bend`, `direct-plan.bend`, and
`direct-emit.bend`. Replace `p111q_segment_chunks` with `direct-entry.bend` using
the composer's explicit `--override` flag. This is a separate experiment from
the first loop snapshot. Public `p111q_chunks`, metadata, constructors and runtime
remain unchanged. The original `p111_verify_program` gate is still mandatory.
Append `runtime-safe.bend` and override `p112t_scalar_safe` using
`runtime-safe-entry.bend` for every worker profile. Every runtime pointer argument
after the leading state must be the exact scratch buffer. The original verifier
only bounds such pointers and otherwise permits the state itself as a buffer;
this additional restriction closes that private-admission gap.

Three immutable admission passes mirror the mature NF dependency criterion.
Pass one admits leaves and self-tail workers; later passes admit workers whose
non-self terminal targets were admitted in an earlier pass. Non-self cycles and
deeper dependency chains fall back. The exact-name trie records the first rank.
Admission requires one result, no incoming continuation, flags zero, at most
eight owned arguments, and the exact scratch/register prelude. The eight-word
bound is an experimental scope limit, not an ABI claim about all programs.

A private worker takes `state` plus its owning Terms and returns one owning Term.
It retains constructor, closure, keep/sink, take and primitive operations. It
cannot push or pop frames, access the state or register bank, dynamically apply,
or fail. A failure returns runtime Reply and therefore cannot become a Term
return. The exact terminal result store/return becomes a machine Term return;
terminal calls go only to admitted private workers. Self calls snapshot every
scratch argument before rebinding any parameter and then jump locally.

Original public functions remain. A private copy is emitted only for an admitted
worker found as a non-self terminal target in the original graph. Untargeted
leaves have no extra call or copy. Public terminal calls may call the private
target, store its result and invoke the original runtime return operation. This
preserves a pending continuation frame. Existing public functions admitted by
the loop planner continue through that unchanged loop emitter. A conservative
target scan may emit an unused private copy for an edge in such a function; it
does not insert an additional public call. Function tables reference only the
public symbols.

The state register bank holds transport words, not independently scanned owners.
Private helpers use the same environment, and no admitted worker inspects or
changes `rn`, `next` or the continuation stack. Private calls form a bounded DAG;
only self cycles exist, and those use local jumps. Thus neither native call stack
depth nor continuation stack depth grows with a self-tail iteration. This is an
audited lowering/runtime argument, not a new formal ownership theorem.

Coordinator-only gates:

1. Export `p112w_index`, `p112w_plan`, `p112w_admitted`,
   `p112w_program_counts`, and `p112w_segment_chunks` in the checked API.
2. Run `direct-controls.mjs API FRESH_OUT`. It executes actual Bend admission and
   emission, with 15 controls and four frozen independent scalar expectations.
3. Build both emitted variants against the same runtime: ordered chain `2211`,
   owning helper case `22`, pending continuation `142`, and eight-argument
   positional witness `87654321`. The latter passes state plus eight words and
   crosses the six-register SysV boundary.
4. Run `direct-owners.bend` through the actual checked source entry. It shares a
   dynamic Unicode String through two ordinary calls and drops the other owner;
   the independently expected value is `"α😀"`.
5. Count admitted workers/private targets using `p112w_program_counts` on the
   same full checked IR before native image acquisition. Include the three-pass
   compile cost and any code growth in the comparison.

`direct-loop-controls.mjs API FRESH_OUT` separately prepares four owning private
self-loop witnesses: odd/even swaps of two different dynamic Unicode Strings and
two release orders with all loop inputs sharing a retained external alias. The
last pair keeps the alias in an ordinary continuation frame, then drops either
the returned owner or held alias first before observing the survivor. Every
fixture asserts that the private loop is actually admitted and contains no
runtime register getter, jump or return. These are synthetic verified-IR ABI
tests; the source fixture remains a separate actual-lowering check.

The separate terminal-failure side-exit extension appends `side-exit.bend` and
overrides both `p112t_scan` and `p112t_scan_next` with `side-exit-entry.bend`.
It recognizes a complete terminal failure suffix once per block and copies it
unchanged. A frame is permitted only in that suffix, which cannot reach a loop
edge. Frames before a loop or branch remain refused. Run its nine controls with
`side-exit-controls.mjs API FRESH_OUT`. Private direct workers still refuse such
paths because their return protocol differs.

Run `runtime-safe-controls.mjs API FRESH_OUT` for eight independent buffer controls
(four helpers, state refusal and scratch acceptance), covering loop and failure
side-exit admission. It also checks direct workers when that API is exported.
Malformed state-buffer graphs pass the original structural verifier but are
never executed; they must fail the private gate.

All files were prepared without target execution or shared Phase111 edits.

## Optional exact CPU fail-stop profile

Append `direct-failstop.bend`, then override `p112w_scan` and `p112w_scan_next`
with `direct-failstop-entry.bend`. This changes only the complete failure side
exit: its original scalar statements, frame, fail call and raw machine return
remain verbatim. In the exact selected CPU runtime04, `p111_rt_fail` calls
`err_post`, which calls `err_fail`, prints its diagnostic and invokes `_exit(1)`.
Thus the raw return and caller's Term-result handling are unreachable. No Reply
value is converted into a Term on an execution that returns. The DEVICE branch
has different semantics and is excluded.

Before execution, bind the composed compiler and exact runtime source/object:

```sh
python3 selfhost/tools/performance/phase112/workers/admit-failstop.py \
  --runtime-source selfhost/build/phase111/runtime-source04/runtime.c \
  --runtime-object selfhost/build/phase111/runtime-source04/runtime.o \
  --compiler COMPOSED/compiler.bend --out FRESH_ADMISSION
```

The data-only tool compares all final worker declarations (including the actual
emission hook) and original verifier declarations against the exact module set,
then pins compiler/runtime bytes. Full-line comments and blank lines are ignored
only for declaration-boundary comparison. The runtime source/object hashes are
fixed to the selected CPU object; runs must use one CPU worker and GPU off and
must require this receipt's actual compiler/object hashes.

Run `direct-failstop-controls.mjs API FRESH_OUT` for eight source controls and
three native observations. Both baseline and candidate must print `7` on the
successful branch, and must match independent exit status1, empty stdout and
exact diagnostics on reachable framed and unframed failure branches. The
original direct control's failure refusal is intentionally superseded only in
this separately bound optional profile; all other admission restrictions remain.
