# Phase121: remove work before adding another optimization pass

Start: `e384668`, qualified Phase118 compiler/runtime; Phase120 remains an
experimental numeric candidate. The user requests a more efficient, ambitious
cycle after a 3.76% runtime gain accompanied by 17.95% hosted compiler cost.

## Decision and experiment order

The measured list pipeline materializes producer, filter and map lists before
folding. Phase119 attributes 59.5% of that workload's samples to destination
fill, take2 and extend1. This identifies an opportunity, not a removable fraction.
The existing JS backend already has name-independent, total-U32 fusion admission
in `selfhost/src/back/js/region.bend`. Reuse its semantic reasoning if possible;
do not create a new general analysis before demonstrating value.

1. Freeze ordinary diagnostic variants of the exact benchmark program: map/fold
   fusion and complete producer/filter/map/fold fusion. Preserve input schedule,
   wrapping, fold order, independent expected outputs and timing protocol.
   These source variants establish attainable code shape, **not compiler gains**.
2. Measure those variants against original QBE and upstream on unchanged inputs.
   Stop weak mechanisms early. Inspect whether construction/calls actually vanish.
3. If the ceiling is substantial, implement name-independent fusion in Bend,
   reusing admission predicates and existing structured native lowering. Keep
   original source verification and transformed IR verification. Preserve source
   owners, totality, evaluation behavior, ABI and stack bounds.
4. Check transformed activation, finite independent scalar laws, changed names/
   arithmetic, wraparound, empty cases and conservative refusal. Measure complete
   compilation cost on a small set before any broad campaign.
5. Seek transfer to a different algorithm family (for example ordered map digest)
   and to compiler workloads. Distinguish a diagnostic ceiling from an implemented
   general capability. Run original45 once only if integration warrants it.

## Ambition ladder

- **1x scope:** a decisive ceiling experiment plus one general, verified native
  fusion rule, with compilation cost measured early.
- **10x scope:** shared backend-independent producer/consumer descriptions,
  eliminating whole private pipelines across JS/native; retain neutral/refused
  functions without repeated analysis. Broaden only after measured transfer.
- **100x scope:** compositional deforestation/scalar replacement across recursive
  ADTs, carrying ownership and ordered effects through the optimizer; use compiler
  analyses as workloads. This is a research direction, not a speedup promise or
  authorization to skip proof obligations.

## Constraints and reporting

One root-owned CPU3 target lane; ordinary guards: 2GiB RSS, 16GiB available floor,
64MiB per-file limit. One offline agent traces semantics and prepares diagnostic
sources. Disk has only ~1.4GiB free: no new full compiler image without compelling
evidence and adequate space. Reuse exact cached runtime, QBE and object files.
No frozen artifact mutation or PR comments. No installed selection change.

Record source/tool/runtime identity, each rejection, whole-request cost and
runtime separately. A useful gate is large whole-workload headroom (roughly 2x
on a pilot) with low analysis overhead; it is not a claim of suite-wide parity.
Reproducible observations outrank successful-looking isolated pass timings.
