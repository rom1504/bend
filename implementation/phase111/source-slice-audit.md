# Phase111 source slice candidate

`prepare.py --slice` prepared `selfhost/build/phase111/sliced-source01` without
running a compiler or target. The full native entry and every Phase111 module
are retained; all module pins match `full-source05` exactly. The selected mature
source is still the authenticated Phase102 projection-cost source. The detailed
source-only comparison and input pins are in `sliced-source01/analysis.json`.

| Source property | Full-source05 | Sliced-source01 |
| --- | ---: | ---: |
| Bytes | 1,879,953 | 650,720 |
| Definitions | 4,296 | 1,804 |
| Types | 183 | 101 |
| Laws | 663 | 523 |
| Physical lines | 41,103 | 19,826 |

The slice contains 1,672 selected declaration names and all 233 Phase111 added
declarations. It retains both live and cached frontend preparation, checked
planning/erasure, native validation, and finite primitive classification. It
removes the legacy `nc_lower`, `nr_compile_prepared`, `ne_program_runtime`,
`nf_plan`, old CLI, and renamed previous main. Nine `nq_` helpers remain because
the generic port reuses their semantic substitution/layout utilities.

This is a candidate for reducing the full self-source frontend workload, not a
proved compiler transformation. The method follows lexical identifier tokens,
including comments and string literals, and constructor aliases. Thus it can
retain unnecessary declarations and does not prove all implicit language
references are present. It preserves whole declaration bodies and all laws
associated with a selected name, but groups each name at its first original
occurrence, which changes declaration order. Actual Bend checking is required.

The preparer's `sourceInverseExact` flag checks the old-main rename before
slicing; it does not mean the full compiler can be reconstructed from the slice
alone. The pinned selected source and dependency list preserve the preparation
recipe. The tool explicitly labels slicing as preparation for module checking,
not qualified native acquisition. Using this full-entry slice as a compiler
input would require fresh source, focused, native, and self-host qualification.
Its changed source spans/binder IDs can change generated text; comparison to
full-source05 QBE should not be assumed byte identical.

No production source changed, and the running full-emission02 input was not
modified. Byte and definition reduction are measured; no frontend timing or
runtime speedup is claimed before a matched execution.

An independent block comparison reconstructs the exact slice and confirms that
all 2,190 retained selected declaration blocks match their selected-source bytes
(after the preparer's removal of outer trailing whitespace): 1,595 definitions,
77 types, and 518 laws. The retained prefix is 559,728 bytes. The complete
Phase111 module addition is byte identical to full-source05. This is unchanged
body selection, but **not literal deletion-only file editing**: law/definition
grouping changes 2,024 block positions, module-marker comments are dropped, and
a fresh `import Base` header is supplied. `analysis.json` records this distinction
rather than claiming declaration-order preservation.

Proposed qualification after the unchanged full-source baseline finishes:

1. Check the sliced full-entry source with the pinned TypeScript frontend/API
   acquisition, preserving its own source/API receipt and the current runtime
   capability sealing. Run the focused positive programs and source refusals.
2. Use the qualified direct-QBE B1 to compile the exact sliced source with the
   same pinned Base/cache/assets. Preserve complete QBE and diagnostic output,
   the source path, and metadata/capacity/verification results.
3. Assemble and link that unchanged QBE with the same cached runtime to acquire
   B2. Run the independent semantic corpus and refusal controls through B2,
   covering live and cached preparation.
4. Have B2 compile the identical sliced input under the identical request
   identity; require complete QBE agreement with B1's slice emission. Rebuild
   from that agreed text if needed to close the native fixed-point chain.
5. Record separately the B1/B2 acquisition and self-compilation times, source
   checking/metadata stages where available, RSS, and output sizes. Compare
   functional products to the full-source baseline without claiming that source
   trimming itself has preserved speed or every public diagnostic ordering.

A checker failure, missing implicit dependency, changed capability admission, or
semantic mismatch is a failed slice candidate and must retain its receipt. It is
not a reason to weaken the existing request/runtime boundaries.
