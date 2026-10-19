# Phase112 source size and implementation scope

The fully qualified `word-source02` checkpoint increases the **assembled compiler source
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

The word composition consumes **48 frozen Bend module snapshots**. Their
gross totals below are not additive to the assembled delta: composition replaces
23 declarations and appends 325, successive overrides can replace earlier module
declarations, and the assembler inserts blank separators.

| Phase112 Bend-source group, original `complexity01` snapshot | Files | Lines | Nonblank | Declarations | Bytes |
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

## Later facts probe, kept separate from qualification

Offline recounting in `complexity-word02/report.json` confirms that the qualified
word source and all its assembled counts above remain unchanged. The later
`facts-source01` composition has a different source identity and qualification
status. Its size is measured here without promoting it or borrowing word's
self-hosting/performance results:

| Assembled source measure | Qualified word | Facts probe | Facts minus word |
|---|---:|---:|---:|
| Physical LF lines | 43,588 | 44,389 | +801 |
| Nonblank lines | 37,240 | 37,812 | +572 |
| UTF-8 bytes | 1,990,734 | 2,028,063 | +37,329 |
| Top-level declarations | 5,467 | 5,578 | +111 |
| `def` | 4,596 | 4,703 | +107 |
| `type` | 205 | 209 | +4 |
| `law` | 666 | 666 | 0 |

Facts source SHA256:
`1df2df372cb3614f7cb4d70f5d81741112b7b15943a4eba204407ef7c3232c71`.
Relative to the original Phase111 assembled baseline, this is +8.00% physical
lines and +7.88% bytes. The manifest composes 70 module snapshots, including
region/gap composition and typed ownership facts. These are implementation
dimensions beyond the qualified word profile, not demonstrated simplification.

`complexity-facts01/report.json` records the authenticated assembled counts and
all snapshots. Its automatic module-group labels retain the original word-era
vocabulary: for example `typed-ownership/controls.bend` is not recognized as a
control module there. **Only the authenticated assembled counts and individual
file counts are used for this facts comparison.** Do not interpret the old
automatic grouping as a reviewed facts implementation/test split, or newer
experimental files as part of the frozen word compiler. No counting-tool change
or source modification was made to obtain these results.

```sh
python3 -B selfhost/tools/performance/phase112/source-complexity.py \
  --manifest selfhost/build/phase112/facts-source01/manifest.json \
  --out selfhost/build/phase112/complexity-facts02/report.json
```

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

The separate completed word comparison also confirms matching checked headers,
program headers and allocated sections except build-id, while whole-file equality
remains false. Its authenticated receipt is
`word-self-elf-authenticated01/report.json`; it does not inherit the core result.
To repeat that offline comparison, use a fresh output name:

```sh
python3 -B selfhost/tools/performance/phase112/compare-elf.py \
  --left-receipt selfhost/build/phase111/p112-word-full-native01/report.json \
  --right-receipt selfhost/build/phase111/p112-word-self01/build/report.json \
  --out selfhost/build/phase112/word-self-elf-authenticated02/report.json
```

The tool refuses unfinished receipts or image-pin mismatches. The later facts
probe is not covered by either completed comparison.
