# Phase192: remove complete machine-level work categories

Start: `aa7cfa4`, 2026-11-13 19:56 UTC. Direct-object native45 runtime is
2.736569× our mature C target; 37/44 timed cases exceed 2×. The goal is a
substantial transferable improvement, not another favorable instruction count.
All compiler transformations remain Bend. Keep the installed release and the
qualified Phase191 N2 available. Root owns one guarded CPU3 execution lane;
bounded Astra high agents own disjoint proposals and independent audits.

## Competing hypotheses and ambition

1. **Composed numeric value regions.** The final profile attributes 35.37% of
   numeric CPU samples to a known conversion runtime helper. That call also
   marks the shared argument buffer escaping, blocking dead-store pruning and
   XMM placement for already inline arithmetic. Extend exact unary operation
   admission through value facts, memory footprints and emission. Reuse existing
   passes; do not create a second escape analysis. A large numeric gain is
   plausible, but helper leaf time is not entirely removable.
2. **Predicates retained through control composition.** Lexer and Map still
   materialize comparisons, copy 0/1 through diamonds, then compare and branch
   again. Normalize pure, certified Boolean computations before allocation.
   Preserve every observable write, width, mutation, evaluation order and
   fallback. Test lexer plus unrelated branch-heavy programs.
3. **Shared address computations.** Phase191 requires one use; fold uses one
   scaled index for load and store. A bounded def/use certificate can retain
   ordered accesses while eliminating shared address temporaries and improving
   placement. Test aliasing, intervening mutation and unrelated array code.

The ordinary ambition is profitable conversion/address capabilities. The 10×
research ambition is composing them so whole staging buffers, call barriers and
Boolean control diamonds disappear. The 100× research ambition is a durable
typed computation region spanning loop state, effects and placement, enabling
regional allocation without duplicated analyses. These are scope levels, not
claimed performance factors. Pursue the larger region only if the cheap slices
show an obstruction and a credible broad benefit. Do not replace the backend.

## Experiment ladder and decision rules

- Freeze C and Phase191 N2 products, same sources/oracles, prepared Base/runtime,
  toolchain and a nine-development/36-held-out split before candidate timing.
- Inspect actual checked IR and machine witnesses. Source-check the smallest
  exported Bend transformation/encoding controls. Independent C observers cover
  floating edge bits and MXCSR state, widths, aliases and mutation; rendered
  assembly and direct objects exercise the shared typed path.
- Emit only affected development programs, authenticate exact output, and use
  balanced runtime rounds. Ablate conversion and buffer-pruning composition
  where useful. Reject weak results quickly; preserve failures. No benchmark
  names or expected values may appear in optimization admission.
- Integrate only useful capabilities, then freeze before all45 outputs and
  broad timing. Report geometric mean, positive-log deficit, equal-family score,
  fixed-work time, threshold counts, regressions and dispersion.
- Pay for full native acquisition/reproduction and native64/runtime10 only
  after transfer is credible. Exact N1/N2 products can transfer timing without
  rerunning it. Independent source checking, finite behavior, native fixed point
  and mathematical proof remain separate. No new BendTT theorem is assumed.
- Measure selected compiler acquisition/request cost and source growth. Preserve
  other target source profiles and the installed selection unless separately
  qualified. Record predictions versus results, including negative findings.

The primary falsifier is unchanged dynamic work or weak whole-program runtime
despite fewer instructions. Do not spend the campaign tuning layout offsets or
retrying the rejected Phase191 call-move scheduler. Archive verified cold files
before pruning; maintain the 5 GiB reserve and the shared lock inode.
