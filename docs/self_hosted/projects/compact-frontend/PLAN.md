# Bounded canonical application migration

The objective is to remove real allocation and traversal work from the compiler
while preserving language semantics, diagnostics, ownership, generated output
and all maintained targets. This is the first self-contained architectural
project, not a commitment to migrate every AST variant.

## Selected representation and scope

Add `KApply{function,argument,originBegin,originEnd}` for exact canonical Apps:
tag App, empty name/removed, id0, quantity0 and exactly two children. Keep generic
KTerm for other language forms and raw/noncanonical Apps. Initial producers are
`app`, canonical application/beta rebuilding and successful application checking.
The raw parser's quantity1 Apps remain unchanged in this project.

Consumers in scope: core observation and rebuilding; substitution/beta traversal;
span/pattern rewriting; exact prepared-state observation; checker application
results; native closed-match variant observation where required. Every exhaustive
KTerm match must handle the new variant. Generic child-list access remains an
explicit compatibility boundary; direct child consumers must not route through it.

The performance hypothesis is that one fixed-arity object replaces a wide term
plus two list cells, and fixed-arity traversal avoids intermediate child lists.
The generated Phase177 `direct.app` contains two ctor2 calls and a general
eight-field constructor, so this is actual native work, not only hosted counting.

## Gates and stop conditions

1. **Representation:** independent projection to the old representation agrees
   completely, including spans, errors, names, quantity and unusual public data.
   Check constructor/accessor/rebuild/roundtrip laws as finite executable controls;
   distinguish those from universal BendTT proofs.
2. **Complete computation:** compare substitution, beta, parsing/checking and
   prepared native requests against an unchanged source snapshot. Normalize only
   the explicit new representation, with an independently written projection.
3. **Native feasibility:** acquire extracted baseline/candidate using the same
   qualified producer/runtime/toolchain. Inspect actual constructor calls and
   direct-worker admission. Count compatibility reboxing separately if useful;
   instrumentation clocks are not performance evidence.
4. **Transfer decision:** balanced isolated medium complete-frontend requests must
   improve at least5%, with preserved complete-value controls and no material
   regression on a second unrelated real input. If below that threshold or if
   extra reconstruction dominates, stop broad migration and report the obstruction.
   A fast synthetic constructor benchmark alone cannot authorize integration.
5. **Integration:** only after transfer, replace the selected production paths,
   retire redundant canonical constructors/adapters and run justified source,
   JS/C/QBE output, native reproduction and generated-program gates. Use identical
   input/source policy for performance pairs. Investigate any compiled-program
   regression above3%; byte-identical ordinary output avoids a needless full
   timing campaign. Final qualification remains separate from installation.

The thresholds are project decisions, not predicted gains. A negative result
closes an approach honestly; it does not authorize endless additional passes.

## Session and cost discipline

Each session begins at STATUS.md and finishes with updated receipts and next
action. Keep one maintained source tree; experiments contain small deltas, controls
and recipes, while Git preserves old implementations. No broad compiler rebuild
before the native transfer gate. One controlled resource-intensive lane; bounded
agents may audit semantics and machine code or implement disjoint experiment
files. Reuse existing source extraction, acquisition, profiler, guard and oracle
tools. Track target acquisition, execution, validation and failures separately;
do not invent agent quota data.

Completion means selected producers and consumers are integrated, obsolete paths
retired, required gates pass and measured benefits/limitations are reported. The
alternative successful research outcome is an explicit rejection with sufficient
evidence to avoid repeating it. Broader typed terms and backend interface changes
are separate future decisions.
