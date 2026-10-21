# Phase118: dead register-tail clearing audit

Offline review of selected Phase117 source/runtime at `c6a0564`. No targets run
and no runtime changes made by this audit. This is a conditional optimization
proposal, not a demonstrated improvement or proof for arbitrary accepted IR.

## Narrow candidate

Keep `p111_set_regs`'s bounded `memmove` of the live prefix, but omit its `memset`
of `[count, p111_transport_words)`. Leave all `WL_*` clears/copies, initial state
initialization, `rn`, next-FID, source alias behavior and physical layout intact.
This removes work proportional to the maximum arity in the whole program from
each generic jump/return/apply. It needs no new generated-code instructions and
can be isolated by relinking exactly the same object files.

The mechanism can matter especially when a program has one wide function but
most dynamic transitions carry one or two words. Static transition count alone
does not establish the share of execution time or an expected measured gain.

## All runtime register paths

References are to `selfhost/build/phase117/runtime01/runtime.c`.

| Path | Actual read/write contract |
| --- | --- |
| `work_loop`,1388–1410 | `WlState state={0}` initializes all256 physical slots; stores entry task in slot0. Only construction site found. Each dispatcher call receives that same local state. |
| `p111_set_regs`,3933–3937 | Bounded memmove writes exactly `count`; current memset clears the rest of logical width. Called only by jump, return and apply. |
| `p111_rt_jump`,3939 | Requires count equal to target FID arity; sets rn0 and nextFID. |
| `p111_rt_return`,3947 | Writes explicit count, sets rn=count, pops continuation FID. Current factory uses count1. |
| `p111_rt_apply`,3955 | Writes exactly closure and argument; next is built-in closure application. |
| `p111_rt_reg_get`,3968 | Runtime checks logical maximum only; original IR verifier supplies tighter input arity/incoming bound. |
| `WL_CASE`/`WL_OPEN`/`WL_JMP`,133–143 | Builtins copy the whole initialized logical bank into local storage; clear local bank; write it back. This first candidate does not change those operations. |
| `FID_ENTER`,1417 | Reads only r0 entry task; loads target arity, or only continuation incoming words, into fresh local bank. Remaining parameters go on stack. |
| `FID_IO_EMIT`,1439 | Reads r0; writes r0 with one result. |
| `BEND_CLO_APPLY`,1449 | Reads r0/r1; writes closure captures followed by argument, exactly callee arity. |
| `FID_EXIT`,1466 | Saves initialized bank, but semantically consumes only rn words. Continuation forwarding restores saved bank; task delivery copies only n words. |
| `task_deliver`,1318; `root_take`,1372 | Copy explicit n values, never inspect inactive register slots. |

Stale inactive words are transport bits, not GC roots: the runtime explicitly
documents this at lines451–453. No traversal or sink scans the register bank.
Leaving a stale owned-looking word in an inactive slot does not retain its node
or add a later ownership release. Full-bank memcpy remains defined because the
initial state and all existing builtin local-bank initialization remain intact.

Effect callbacks have signature `Effect(Env, Term* fields, IoWork*)`, not a
`P111State*`. `io_exec` consumes a request constructor into a local field array;
it does not inspect the native register bank. NativeHost providers follow this
same interface. The source language does not expose the register bank.

## Generated reads and the necessary proof boundary

`phase111/segment/lower-helpers.bend:p111_segment` sets result width1 for every
factory-produced generic segment. Every selected-source call to this factory
passes incoming0 or1. `p111_params` reads held values from the stack and exactly
the remaining live inputs from registers. `p111v_contract` checks reg_get indices
against incoming width for continuations, otherwise function arity. Static jumps
are admitted only to non-continuations with exactly matching argument counts.
Frame capture count plus incoming width must equal continuation arity.

Selected inline register access is Phase112's `p112a_expand`, retained in the
Phase114 renderer chain. It replaces an already verified literal-index reg_get
with a full-width load at `state + 40 + 8*index`; it does not add more reads.
Phase114 frame/pop/get templates access the continuation stack and `state->sp`,
not the register tail. Public direct wrappers read exact original arity; direct
workers receive C-ABI arguments and do not semantically inspect scheduler slots.
Recursive descent/unwind likewise loads known original inputs and result slot0.

There are two reasons **generic structural verification alone is insufficient**:

1. `p111v_segment` seeds `state` with2088-byte capacity, and generic N111Load /
   Store / Offset may address that state. Raw reflected IR could observe a dead
   register directly even if all its reg_get calls are correctly bounded.
2. The verifier checks each frame's declared incoming width and each segment's
   own return width, but is not a whole-program dynamic-return type proof. An
   arbitrary verified multi-result graph is broader than the current source
   factory, which always returns one word and uses incoming0/1.

Therefore this is defensible as a source-provenance-scoped ablation, not an
unconditional promise of identical runtime ABI behavior. A compact reusable
certificate could require result1/incoming<=1 throughout original segments;
reject arbitrary state memory accesses, pointer aliases and state pointer escape
other than exact known runtime-import positions; then preserve the existing
verifier. Authenticated final templates add only the documented live register
reads. Keep the old clearing path when the certificate is absent. No malformed
target or stale-register probing is needed to test ordinary source behavior.

## Cheapest falsification and scope discipline

Relink frozen Phase117 objects with only the tail-clear omission under recorded
source/runtime identities. Reuse ordinary closure/capture, recursive return,
argument-permutation, shared ownership, IO and wide/narrow-call fixtures. Check
complete outputs and repetition counts, then pair short timings on a few
transition-heavy workloads. A positive result justifies the small certificate
and wider qualification; a flat result should end this branch quickly.

Do not simultaneously shrink banks, remove initial zeroing, alter `WL_OPEN`,
replace memmove with unchecked scalar copying, or change rn/FID handling. Those
would add independent lifetime, C initialization and alias obligations and make
the first measurement harder to interpret.

## Isolated certificate implementation

`transport-certificate.bend` implements `p118z_eligible(P113AProgram)` as an
additional necessary predicate after successful existing verification. It scans
all original generic segments, including fallback, and every final direct worker
before private templates. It rejects raw state memory access and all pointer
aliasing operations; normal verified local allocas remain permitted. Its finite
runtime whitelist includes the reviewed destination and borrowed-field helpers,
which do not inspect register slots. Unknown future imports refuse.

One extra obligation emerged during implementation: a verified register getter
could read its *current segment's* wider inputs after an outgoing narrower
transfer if arbitrary reflected IR put more operations after the transition.
The certificate therefore requires each jump/return/apply call to be immediately
followed by its matching machine return. Direct workers cannot use register
getters or scheduler transitions at all. Pure controls exercise these refusals
without executing the constructed IR.

The parent may attach descriptor capability4 only when both this predicate and
the existing full verifier succeed for the same final program. Capability1/3
then retains exact old clearing behavior, while5/7 opts into dead-tail omission.
No capability emission or runtime clear removal is implemented by this audit.
