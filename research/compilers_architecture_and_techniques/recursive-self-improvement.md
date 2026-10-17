# Recursive compiler improvement: prior work and a Bend research opportunity

Primary-source review, 2026-10-17. This note separates demonstrated external
capabilities, our repository evidence, and proposed experiments. It is not an
exhaustive novelty search. External speedups are not forecasts for Bend.

The interesting hypothesis is that improving our compiler increases the rate
of discovering further independently validated improvements. Ordinary
self-compilation, a better compiler executable, and a more capable research
process are distinct results. Relevant foundations already exist across all
three; a credible contribution requires controlled evidence connecting them.

## Bootstrapping and profile feedback

**GCC supplies the fixed-point baseline.** Its native build normally performs
three stages and compares stage2 with stage3. Its separate `profiledbootstrap`
builds an instrumented compiler, trains it through compilation, then rebuilds
using the resulting profile. This distinguishes bootstrap consistency from
optimization using additional empirical state. Neither procedure implies
unbounded improvement from repeatedly compiling unchanged source.
[GCC build documentation](https://gcc.gnu.org/install/build.html)

For Bend, candidate04 already has a complete emitted-C/diagnostic fixed point.
The public Phase103 CLI instead uses a temporary bridge because its own OS
provider exceeds the final public foreign-policy boundary. Start generational
measurements with the qualified core; do not describe the bridge as an
unrestricted same-source self-hosting result.
[Candidate04 qualification](../../implementation/phase102/default-promotion.md),
[CLI scope](../../implementation/phase103/README.md)

**LLVM demonstrates practical compiler PGO.** Its guide describes collecting
profiles from tests and self-builds, and stresses representative training
workloads. It reports user-observed compiler improvements, not a guaranteed
gain for another compiler or evidence of accelerating discovery.
[LLVM PGO guide](https://llvm.org/docs/HowToBuildWithPGO.html)

We can instrument the existing Bend-generated compiler C with Clang, execute a
training corpus, merge profiles, and rebuild that same C using feedback.
**A new Bend-to-LLVM backend is unnecessary for this experiment.** Clang's
documented instrumentation workflow already supports the required operations.
Keep self-source training, external-program training and untouched evaluation
separate; charge instrumented builds and training to the improvement cost.
[Clang PGO workflow](https://clang.llvm.org/docs/UsersManual.html#profiling-with-instrumentation)

## Discovering transformations and choosing among them

**Souper automates local optimization discovery.** Its authors report
optimizations subsequently implemented in LLVM and Microsoft Visual C++, and
a smaller Clang executable when Souper is used automatically. This is direct
precedent for machine-discovered transformations improving a compiler program;
it does not establish that the improved compiler discovers optimizations faster.
For Bend, propose small pure word/tag transformations with explicit semantics,
then test whether their callers are important before paying for a native image.
[Souper](https://arxiv.org/abs/1711.04422)

**Equality saturation changes how alternatives are retained.** `egg` uses
e-graphs, rebuilding and e-class analyses to support efficient exploration of
equivalent expressions. Its search mechanism does not supply valid Bend
equations automatically. A bounded pure scalar sublanguage is a plausible
starting point; ownership, observable effects and runtime traps require explicit
conditions. Runtime, emitted size and downstream build cost should influence
extraction. Replacing the complete IR with an e-graph would obscure the first
experiment and expand its correctness obligations.
[egg](https://arxiv.org/abs/2004.03082)

**CompilerGym makes experimentation an explicit interface.** It exposes
optimization tasks as environments with actions and observations and evaluates
the infrastructure's efficiency and reproducibility. The useful transfer is a
small Bend environment with pinned input, legal actions, resource limits,
repeatable rewards and resettable state. We can implement that boundary around
existing lowering choices without adopting its implementation or training an
RL agent first. Faster environments are evidence about experiment throughput;
more valuable discoveries require a separate measurement.
[CompilerGym](https://arxiv.org/abs/2109.08267)

**MLGO separates legality from profitability.** LLVM's interface leaves
correctness constraints in compiler code while models advise decisions such as
inlining and register eviction. Features describe the decision context;
training and inference are distinct operations. This closely fits Bend's
existing forced-inline policy: retain admission and ownership checks, and
experiment with a cheap advisor for safe choices. Start with a simple fitted
rule before a neural policy. Features should include dependency expansion,
call frequency and projected allocation removal; reward must penalize image
build time as well as execution cost.
[LLVM MLGO](https://llvm.org/docs/MLGO.html)

**AlphaDev demonstrates constrained algorithm discovery.** It discovered
small sorting routines using reinforcement learning, and resulting algorithms
entered LLVM's C++ standard library. This motivates searching bounded hot
helpers with strong oracles; it does not imply comparable whole-compiler gains
or justify an assembly backend. Bend's more expensive ownership and scheduler
boundaries may dominate any improvement to a tiny arithmetic routine.
[AlphaDev](https://www.nature.com/articles/s41586-023-06004-9)

## Autonomous research and the limits of novelty

**autoresearch provides a compact operational template.** Its agent edits
training code, executes a fixed-duration experiment, evaluates it and retains
or rejects the change. Data preparation and evaluation utilities are separated
from the mutable training file. The README describes a practical autonomous
loop, not a controlled demonstration that improvement accelerates subsequent
discovery. For Bend, retain the narrow edit surface and external evaluator,
but count startup, compilation and qualification in total research cost even
when an inner workload has its own time budget.
[autoresearch](https://github.com/karpathy/autoresearch)

**The Darwin Gödel Machine is closer to self-research.** Its agents modify
their own implementation, maintain an archive of alternatives and improve
coding-benchmark performance relative to reported baselines. This establishes
relevant precedent for changing the machinery that makes later changes.
It does not settle our specific question about compiler-throughput-mediated
research yield per unit of total cost. Bend should preserve useful alternative
candidates and failed experiments, while keeping the evaluator outside the
agent's edit authority.
[Darwin Gödel Machine](https://arxiv.org/abs/2505.22954)

**AlphaEvolve connects code search to computational infrastructure.** Its
authors report evaluator-guided evolutionary program improvement across
algorithms and infrastructure, including accelerating training of the LLM
underlying AlphaEvolve. Therefore, improving one's own computational substrate
is already demonstrated in relevant prior work. The reported capability is not
by itself a measurement of sustained acceleration in future discoveries. Our
experiment must isolate that additional causal claim rather than rename an
existing optimization loop.
[AlphaEvolve](https://arxiv.org/abs/2506.13131)

## Less obvious connections worth testing

**Proof-carrying rewrites can reduce repeated validation work.** Alive2 provides
LLVM refinement checking and translation-validation tools; its documentation
explicitly excludes interprocedural transformations. It cannot directly prove
Bend ownership or a whole Bend-to-C pipeline. The transferable design is to
search broadly, admit narrowly, and independently check each proposed rewrite
or its certificate. For Bend, connect a small law to the actual production
implementation and preserve aliasing, effects and exceptional behavior. A proof
about a detached model is insufficient.
[Alive2](https://github.com/AliveToolkit/alive2)

**Specialization offers improvement without source invention.** Partial
evaluation generates a specialized program from a general program and known
inputs; self-application connects this to compiler generation. This is
established theory, not an automatic speed amplifier. A Bend experiment could
specialize a compiler for a fixed backend or immutable prelude while preserving
arbitrary user inputs. Compare a residual executable against an ordinary cache
to distinguish eliminated computation from merely remembered results. Hash
the assumptions and retain a general fallback.
[Jones, Gomard and Sestoft](https://studwww.itu.dk/people/sestoft/pebook/)

**Budget-aware search can turn optimization into an anytime process.** This is
our proposed synthesis: retain a valid baseline, allocate extra search to hot
regions with plausible payoff, and preserve the best validated candidate when
the budget expires. Start with a finite grid of safe policies and a fixed work
budget. A stronger searcher must repay its own cost; faster compilation is
useful only when saved time funds valuable additional exploration. A learned
policy should predict this marginal value, not merely recognize benchmark names.

## What Bend can establish next

Our existing evidence suggests a credible feedback path: general constructor,
observer and direct-worker improvements help applications and can also help
the compiler that evaluates future candidates. But the native self-image
envelope includes roughly 151 seconds of Bend emission and 374 seconds of
Clang work. Eliminating the former alone would improve that envelope by only
about 1.40 times, before other overhead. This is an Amdahl calculation from
one recorded chain, not a repeated build-speed result.
[Promotion measurements](../../implementation/phase102/default-promotion.md)

A useful contribution would combine three results: measured bootstrap
stability; a controlled relationship between infrastructure speed and experiment
throughput; and replicated evidence that updating the research toolchain
improves held-out quality per total time or compute compared with a frozen
toolchain. Charge failed proposals, agent use, rebuilds and final validation.
Record profiles and policies as evolving state, not hidden constants.

Start with identical candidate streams to isolate latency effects. Then use
independent adaptive campaigns to test discovery yield, keeping model, evaluator,
hardware and budget comparable. Timing repetitions are not independent research
campaigns. A rising sequence of selected best results does not demonstrate
acceleration, and repeatedly consulted benchmarks are not held out.

This combination may be a useful research contribution; no first-ever claim
is justified by this survey. A well-supported negative result would also matter:
if compiler execution barely changes research yield, prioritize cheaper builds,
better candidate selection and stronger inexpensive validation before attempting
more recursive generations.
