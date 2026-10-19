# Phase112 source size and implementation scope

The selected `word-source02` candidate increases the **assembled compiler source
by 2,485 physical lines (+6.05%) and 110,781 bytes (+5.89%)** relative to Phase111
`full-source05`. This phase has added optimization capabilities; it has not
reduced compiler-source complexity. These measurements cover the exact complete
source inputs passed to the compiler, including their inherited library, laws
and historical implementations. They are **not repository totals, a count of
reachable executable functions, or changes to the installed default**.

| Exact assembled input | Phase111 baseline | Phase112 word | Change |
|---|---:|---:|---:|
| Physical LF lines | 41,103 | 43,588 | +2,485 (+6.05%) |
| Nonblank lines | 35,417 | 37,240 | +1,823 (+5.15%) |
| UTF-8 bytes | 1,879,953 | 1,990,734 | +110,781 (+5.89%) |
| Top-level declarations | 5,142 | 5,467 | +325 (+6.32%) |
| `def` | 4,296 | 4,596 | +300 |
| `type` | 183 | 205 | +22 |
| `law` | 663 | 666 | +3 |

Baseline SHA256: `825cb03276c30a944ef1b1e8ed0624531253d2f39a502b0fcbfbfea3f3bb3f44`.
Candidate SHA256: `efac7e31641c32af5e6baf636ee3216210f7cd574ac9412a6cfb20e7d2975128`.
Both match the immutable composition manifest. Declaration counts recognize
column-zero `def`, `type` and `law`; they are syntactic, not an estimate of the
number of independent concepts. Blank/comment lines remain in physical counts.

The candidate composition consumes **48 frozen Bend module snapshots**. Their
gross totals below are not additive to the assembled delta: composition replaces
23 declarations and appends 325, successive overrides can replace earlier module
declarations, and the assembler inserts blank separators.

| Phase112 Bend-source group | Files | Lines | Nonblank | Declarations | Bytes |
|---|---:|---:|---:|---:|---:|
| Selected implementation snapshots | 46 | 2,274 | 1,981 | 332 | 120,589 |
| Selected embedded control snapshots | 2 | 115 | 101 | 16 | 8,922 |
| Experimental/superseded implementation, not selected | 18 | 550 | 480 | 87 | 33,093 |
| Other external controls and fixtures | 24 | 1,612 | 1,501 | 90 | 40,611 |

The two embedded control modules are `static/controls.bend` and
`float/controls.bend`. They remain in the actual candidate source and therefore
are included in the first table; excluding them there would understate its size.
`accessors/special-tests.bend` is actual special-constructor predicate emission,
despite its filename, and belongs to implementation rather than test fixtures.

The selected additions fall into six useful conceptual families: backward
continuation liveness; direct scalar and accessor operations; private workers
with ownership/call admission and local loops; verified static images; bounded
continuation fusion with renaming; and reuse of mature selector/Word-pattern
recognition. This is an explanatory grouping, not a formal complexity metric.
The generic segment IR, runtime ABI and fallback paths remain necessary. New
runtime exposure and more admission boundaries are a real maintenance cost even
where they remove generated instructions and allocation.

The unselected implementation consists of `regions/` and `region-multi/`, the
earlier `uses.bend` prototype, `workers/entry.bend`, and the alternative accessor
entry modules. Their experiments are retained as evidence, but they do not enter
this selected assembled source. Host harnesses, runtime C headers, JSON fixtures,
documentation and generated machine code are outside this Bend-source inventory.

An eventual cleanup can separate the two embedded control modules from image
composition and consolidate superseded entry overrides. That is a modest,
concrete opportunity; no such deletion or semantic reachability proof is claimed
here. The larger reuse gain is architectural: selector and Word recognition use
the mature compiler machinery instead of introducing a second independent
source optimizer. Broad simplification should follow stable qualification.

Reproduce the offline inventory, using a fresh output name:

```sh
python3 -B selfhost/tools/performance/phase112/source-complexity.py \
  --manifest selfhost/build/phase112/word-source02/manifest.json \
  --out selfhost/build/phase112/complexity02/report.json
```

The original `complexity01/report.json` authenticates both assembled sources and
all module snapshots and records every grouped file. It is included by the final
evidence sealer. The other Phase112 files are an inventory snapshot, so later
experiments can legitimately change those external-file counts.

## Authenticated ELF comparison

The older `first-self-elf01.json` identified binaries only by pathname. A new
[`compare-elf.py`](../../selfhost/tools/performance/phase112/compare-elf.py)
requires completed build receipts and verifies each entire binary's size/SHA256
before inspecting it. It compares section payloads and memory metadata, including
`.bss` size, plus ELF entry/header fields and complete program headers. It launches
no executable or external tool.

`first-self-elf-authenticated01/report.json` confirms the core N1/N2 pair has
identical allocated sections except `.note.gnu.build-id`, and identical checked
headers/program headers. Only build-id, `.symtab` and `.strtab` differ. Both `.bss`
sections have 1,148,424 memory bytes; their zero file payload does not imply a
zero-size memory section. Whole-file equality is false and remains explicitly
false. This is machine-product evidence, not an independent semantic proof.

Once the word self-build receipt is complete, its separate comparison is:

```sh
python3 -B selfhost/tools/performance/phase112/compare-elf.py \
  --left-receipt selfhost/build/phase111/p112-word-full-native01/report.json \
  --right-receipt selfhost/build/phase111/p112-word-self01/build/report.json \
  --out selfhost/build/phase112/word-self-elf-authenticated01/report.json
```

The tool refuses unfinished receipts or image-pin mismatches. The word result is
not implied by the completed core comparison; it must be measured separately.
