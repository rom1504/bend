# Phase188: one typed x86 machine boundary

User-authorized refactor, 2026-11-09. Parent dffc12d (Phase187).

Phase187's optional object route still selects assembly text, parses it back,
then encodes it. Its full same-source acquisition was 315.348s versus199.112s
for assembly, with no reliable generated-runtime difference. The refactor
removes that redundant representation conversion, not another backend.

## Architecture

Keep checked native IR, admission rules, frame allocation and all selected
Phase185/186 optimizations. Selection now produces a per-function sequence
of typed instructions, numeric registers with widths, exact immediate bits,
memory operands, symbols, labels and structured data/directives. Two final
consumers render AT&T assembly or encode bytes and ELF relocations. Sequence
concatenation is constant time; explicit traversal stacks avoid host recursion.
The program cursor continues releasing functions/data slices incrementally.

The strict assembly parser remains a diagnostic compatibility facility and
must disappear from the selected production source closure. Machine opcodes
remain finite selected mnemonics; no register/operand/immediate strings are
parsed on the production route. A broad universal IR rewrite is unnecessary.

Investigate resolving local branches before ELF and omitting nonescaping local
symbols; preserve address-taken/exported locals, relocation bounds and independent
checks. Make byte validation tail-recursive. Full byte-buffer streaming is a
separate possible improvement, not a prerequisite to the shared boundary.

## Gates and cost discipline

1. Checked source and focused literal machine/ELF controls; preserve failures.
2. Compare generated assembly against parent, permitting only documented spelling
   normalization (indentation and explicit zero displacement). Independently
   assemble and compare section bytes/relocation semantics to catch real changes.
3. Frozen ownership/alias/parallel-move/F32/control-flow fixtures plus program
   catalog correctness for both output consumers. No weakening final native IR
   verification or changing benchmark definitions.
4. Acquire one native compiler only after cheap checks pass. Compare both output
   modes with the same new producer, identical source/runtime/Base/toolchain,
   and compare against Phase187 using exact identities. Report compiler process,
   assembler, linking, full acquisition, peak RSS and artifact sizes separately.
5. Qualified image/corpus tests and a bounded balanced runtime screen. Preserve
   installed Phase183 until separate promotion gates justify changing it.

One resource-intensive lane, bounded RAM/disk, retained baseline executables and
oracles. Bounded agents own disjoint selector modules, object integration and
independent tests. Measure rather than promise build-time gains; if typed nodes
add overhead or ELF materialization dominates, report that directly.
