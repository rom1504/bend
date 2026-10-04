# P43-005 implementation packet

Tools: `selfhost/tools/performance/phase43/guards/derive.py`, `runtime.patch`,
`oracle.mjs`. Root owns execution, measurement and production integration.

Run from repository root:

```sh
python3 selfhost/tools/performance/phase43/guards/derive.py --out selfhost/build/phase43/guards01
/home/ai/.nvm/versions/node/v24.18.0/bin/node selfhost/tools/performance/phase43/guards/oracle.mjs selfhost/build/phase43/guards01 > selfhost/build/phase43/guards01/oracle.json
```

Derivation reads the preserved Phase42 current archive and manifest and checks
its exact SHA256. Default input is the list512 point's saved module, shared with
list128 (`661f268bef195c0fecb034697f09818229e1bcbe953caf97a481769084b38d1c`).
It refuses a runtime mismatch. It writes an unmodified control, a clean candidate,
identical instrumentation copies, source runtime patch and SHA256 manifest.
One actual list root entry clause changes from localGuard to
localGuardAfterHost after host guard and canonical U32 tests. The saved source
root body and public ABI remain unchanged.

The oracle compares control and candidate in isolated serial child processes:
canonical result/activation, G binding replacement/getter, code replacement/getter,
arity/env/bound accessors, bound length, code.call, wrapper io, primitive/Object/
Array markers, Array.every/iterator/numeric setter, every captured numeric host
hook and every protocol descriptor, F32 view own method and Error reentry.
It records entire traces, result/errors, restored-entry result, host refusal and
proof cleanup. Error hook reentry must see no borrowed proof, then unwind to its
previous proof. Instrumentation counts actual fusion body entry. Clean timing
modules contain neither counters nor extra oracle exports.

Syntax checks passed on the Python derivation and Node24 oracle/candidate. No
semantic or throughput run performed by this owner; root queues them. The first
runnable derivation was produced within fifteen minutes. Reviewer was asked to
check exact host dominance and preserved proof lifetime.

Integration must add the runtime helpers and make the corresponding compiler
emitter decision for each host-guarded clause, retaining the old local guard when
host guard is absent. A saved-module regex is an experiment, not a source proof.
Existing shared host guard semantic owners are still mandatory before promotion.

Initial root oracle receipt `selfhost/build/phase43/run-guards-oracle01` is a
harness failure (empty child stdout, JSON parse error), not a semantic pass or
counterexample. The successor preserves v1 and emits complete child diagnostics.
Re-derive after tool updates; guard packet identity must come from the selected
run, not an earlier guards01 folder.

P43-005b independent domain tools are versioned `derive-u32-v1.py`,
`oracle-u32-v1.mjs`, `runtime-u32-v1.patch` and `source-hook-u32-v1.patch`.
The source hook is an unbuilt proposal in the owned tool directory; it does not
edit production source. It threads the same successful complete fusion body into
host guard choice and the actual body, retaining canonical checks, dependency
checks and proof try/finally. Other regions/workers retain their old guard. A
future compiler-cost follow-up can avoid rechecking failed fusion in the fallback
flat planner; this packet does not claim a compiler cost gain.

Frozen equivalents of the latest exact-guard tools are `derive-v2.py` and
`oracle-v2.mjs`. U32 domain derivation invokes this frozen v2. Root's guards03
oracle failed before execution because sandbox child spawning returned EPERM on
canonical control; that is a harness/environment blocker, not a counterexample.
Root reruns with the same resource caps outside that sandbox.

Exact AfterHost root semantic run passed all 76 cases:
`selfhost/build/phase43/run-guards-oracle04/stdout.log`. Canonical fusion executes
once and returns118; Error observation reentry sees coverage false, returns0,
restores the previous proof during unwind and leaves no proof after close.
All host/dependency/protocol mutation result/error/traces agree with the exact
unmodified control. This is the listed semantic scope, not a universal proof or
measurement. Earlier sandbox failures remain preserved.

Optional frozen `oracle-u32-v2.mjs` extends v1 with24 canonical U32/grid cases
including zero and U32max seed, checked against an independent BigInt recurrence.
It compares complete public producer/filter/map lists and sum, confirms producer
fresh root allocation and unchanged source. v1 is retained. v2 syntax passed;
root must execute the selected version and bind its identity before qualification.
