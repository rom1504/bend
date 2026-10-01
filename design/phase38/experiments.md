# Prospective fast experiments after the research phase

No experiment below has run in Phase38. These cards are proposals for a future
implementation phase. Each surviving idea gets its own immutable plan, exact
inputs, attempts and report under that phase. Use fresh output directories;
Phase35/36/37 evidence remains closed.

## Shared protocol

- Baseline: Phase37 checked03 and the preserved pinned TS output, with hashes.
- First inspect code and counts; then change exactly one mechanism in saved JS.
- Keep instrumented counters/profiles separate from counter-free timing.
- Run complete-value semantic controls before interpreting checksum timings.
- 20-second selected execution screen, then 60 seconds with a second input and
  canary; 300/600-second selections only after a stable candidate. These are
  ceilings, not guarantees that every chosen case finishes or reaches steady state.
- Builds/acquisition happen once per compiler candidate and are outside those
  execution ceilings. Full 45-point acceptance currently needs about 17.6 minutes.
- Root executes heavy jobs serially: CPU3, Node24.18, heap <=1024 MiB,
  process-tree RSS <=2048 MiB, available-memory floor 2048 MiB, explicit deadline.
  Agents inspect/author independent files. Avoid nested supervisors/lock waits.
- No win if the intended code did not execute. Retain failed rounds, refusals,
  first calls, ranges and paired direction. Do not pool unrelated denominators.

## E01 — scalar private countdown

**Hypothesis:** the existing Number-counter proof can admit the numeric recurrence
without changing its public Nat representation. Compare unchanged output with
only the private counter changed; leave casts, constants and entry guards alone.

**Controls:** zero/one, ordinary bounds, values at/around the admitted 48-bit edge,
invalid/raw/partial/overapplied calls, escaping counter, mutation of conversion
dependencies and error reentry. Verify identical rounding/U32 results at every
step on small instances, not just the final hash. Near-48-bit controls must use
bounded-step/early-exit fixtures or isolated boundary checks with an explicit
trip cap; never attempt a complete 2^48-step countdown to test a bound.

**Mechanism:** count BigInt decrements and private entries in a separate variant;
sample allocation separately. **Stop:** escaping use, changed demand/error,
no stable timing improvement, or guard overhead dominates. First result in
1–3 engineering hours; runtime screens 20/60 seconds.

## E02 — one larger guard scope

**Hypothesis:** repeated entry validation dominates a ray helper chain that can
remain inside one synchronous closed proof. First count current root entries,
successful/failed guards and callback opportunities; do not remove validation.

**Variants:** unchanged; one proved enclosing boundary; separately, a diagnostics-
only guard-disabled upper bound clearly marked semantically inadmissible. Never
promote the latter or describe its speed as a compiler result.

**Controls:** changed descriptors, prototypes, Math/Number/DataView hooks,
instance method changes, callback/error reentry, unknown helpers, nested scopes,
and deliberate refusal. **Stop:** any observable hook is skipped or moved;
larger scope requires admitting unknown callbacks; scope setup exceeds savings.
First result 2–4 hours. Required upper-bound sanity check: guard-only forecasts
must fit the roughly 42% sampled ray share, not the entire TS gap.

## E03 — recursive component with unchanged data

**Hypothesis:** saturated direct calls through a complete tree component remove
substantial dispatch/forcing without a representation rewrite. Rebase the old
handwritten experiment onto final installed output; do not reuse its old timing
denominator. Keep constructors, arithmetic, algorithm and inputs identical.

**Controls:** complete structural output, child identity/sharing, asymmetric and
skewed trees, left/right demand order, every constructor, 30,000-step tail cycles,
raw entry, partial/extra arguments, host mutation and fallback. Distinguish tail
SCCs from recursive non-tail work; direct JS recursion is not a general solution.

**Mechanism:** known-edge call counts, generic transitions and allocation per call.
**Transfer:** one separately chosen map/lexer/list component, without assuming the
tree gain. **Stop:** gains require algorithm changes or benchmark names; proof
needs a new runtime; a second shape exposes incompatible abstractions. Half-day
prototype; 3–7 days for a general admitted rule is a planning estimate.

## E04 — known callback, then fusion

**Hypothesis A:** a callback with fixed identity and environment can become a
specialized direct worker argument. Keep the list materialization unchanged.
Cap clones and preserve unknown-callback fallback. This isolates higher-order
dispatch from allocation.

**Controls:** multiple captures, changing callback identity, selected/unselected
branches, empty/short lists, errors, reused closure, partial calls, exact field
values and call order. Add non-cycle lengths and varying filter selectivity in
a new catalog; old 128/512 points rotate complete 16-value cycles.

**Hypothesis B, only after A:** a nonescaping producer/consumer chain with total,
non-hooking scalar operations over proved bounds can eliminate intermediate
lists. Alternatively prove that the actual demand schedule is preserved;
purity alone does not permit interleaving an eager map with a filter that may
fail. Compare against direct unfused A. Validate full
results and callback traces; do not move deferred work or evaluate unused tails.
**Stop:** A has no win, allocation no longer matters, or B's demand proof becomes
the dominant new concept. Half–one day per discriminator; no additive forecast.

## E05 — recover compiler analysis cost

**Hypothesis:** the same context-independent dependency/signature question is
recomputed during emission. Count visits/normalizations and classify cache keys
before modifying source. Use tree plus unrelated local/numeric source requests.

**Variant:** request-local fact reuse with unchanged emitted bytes. Include book,
type/substitution context and source identity where required; discard on request
completion. No global cache across mutable inputs. Track peak memory and entries.

**Stop:** no repeated identical query; context cannot be keyed cheaply; compile
time saved is smaller than memory/complexity cost. The 0–6% recovery target is
speculative. Only after the byte-preserving refactor should eligibility change.

## E06 — private representation and allocation

Profile again after E03/E04. Select one surviving hot container. Compare unchanged
tagged direct worker, destination emission, and only then bounded local reuse.
Each is a separate variant. Test sharing, input preservation, reentry, failures,
deep shapes and retained-memory growth; no global scratch object or assumed
JS reference count. Stop if ownership cannot be proved locally or allocation
falls without execution benefit. This is conditional, not an initial rewrite.

## Promotion checklist and fresh holdouts

A future production candidate must report: exact source/API/module identities;
owner semantic controls; clean paired timing; instrumented mechanism evidence;
checked-request costs; emitted/source size; memory; rejection/fallback rates;
and retained regressions. Broader conformance is a separate release gate.

Previously heldout BST/expression/record families are now exposed. Reserve new
families or distributions before selecting a candidate. Useful missing axes
include deep skew, shared subtrees, heterogeneous closures and longer-lived
heap pressure. Do not profile those holdouts until the candidate is frozen.

Combine only independently surviving mechanisms, then measure the combination
afresh. If a general component succeeds on two families, use that evidence to
justify the [staged consolidation](architecture.md). Otherwise keep the winning
rule narrow and report the null architectural result.
