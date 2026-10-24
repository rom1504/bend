# Bounded object reuse experiment

Object reuse works in this bounded experiment, but the prototype does **not**
improve end-to-end compilation. Rebuilding the edited image reused 55 of 65 units
and took 5.98s versus 19.85s for an independent cold partitioned build. Preparing
the edited partition alone took 22.84s, and full frontend/emission still took
368.98s. All 15 output gates passed. No production compiler or selected image
was changed.

This experiment caches **QBE-to-object compilation**, after the complete frontend
and QBE emission have already run. It does not cache parsed Bend modules, checked
terms, optimizations, or emitted QBE. On the qualified Phase131 final source,
the retained native request takes about379.23s and machine building about13.82s;
object reuse alone therefore has a roughly3.5% ceiling on that full rebuild,
before partitioning, hashing, cache lookup, relinking and qualification costs.

## Initial contract

`selfhost/tools/performance/phase132/incremental/objects.py` reuses the existing
Phase132 lexical global-token recognizer. It recognizes complete emitted
function/data/type declarations, rejects other non-comment top-level bytes,
and preserves every declaration byte except an explicit export prefix.
Standalone local `@` labels and `%` temporaries remain inside their functions.
Quoted strings and comments cannot create false global references.

The prototype groups contiguous sets of1,000 functions into units, in their
original order. All data declarations retain their original order in one data
unit; type declarations are copied unchanged into every unit. Only originally
private definitions actually referenced from another unit gain `export`.
Existing exports, symbol spellings, function signatures, static initializers,
numeric FIDs/CIDs/pool indices and instructions remain unchanged. There is no
SCC rewriting, function elimination or name compaction in this experiment.

This is an explicit **closed-image experimental ABI policy**, not a compatible
library transformation. The same cached runtime object is linked after the
ordered unit objects. GNU assembler local `.L` labels are private to each
object. QBE uses `amd64_sysv`; assembly preserves the established branch-alignment
flag; linking uses `-no-pie` and disables the build-ID note so identity metadata
cannot obscure the strict allocated-section comparison. Both cached and fresh
partitioned references use this exact policy.

A cache key includes the complete transformed unit IR, its referenced cross-unit
symbol kind/header/export bindings, method/lexer identities, runtime object,
QBE/assembler/linker identities, target and flags. It deliberately does not hash
only a Bend source declaration. Global numeric IDs and continuation names can
change far beyond an edited source function; actual emitted-byte changes then
invalidate affected units. A changed data initializer always changes its own
unit key. Cached objects are rehashed on reuse. Cache entries are immutable and
require a complete receipt; the cache has one writer at a time.

## Gates and accounting

1. Partition the qualified original QBE and build every unit into a fresh cache.
   Qualify this partitioned executable against the original monolithic image's
   complete output oracles before treating it as a usable baseline.
2. Acquire the real edited source's complete QBE with the **same qualified native
   producer**. Charge this unchanged frontend/emission boundary separately.
3. Partition the new QBE, validate all keys, rebuild only missing units and link
   a fresh executable. Preserve old cache entries and raw child outputs.
4. Independently build every new unit in another empty cache. The compare command
   requires both changed builds to consume the same exact plan and compares every
   allocated ELF section's type, flags, address, size, alignment and bytes,
   including BSS size. No ELF symbol-string equality is substituted for this.
5. Run the independent complete-output program/compiler gates on the resulting
   images. Allocated-section identity is a separate gate and does not claim
   frontend, language, runtime or whole-compiler correctness by itself.

The preparation receipt records token scanning and total host preparation time;
build receipts expose cache lookup/hash time, each QBE/assembly child, link time,
counts of reused/rebuilt units, and total host build time. Root's outer guard
must charge process startup, final receipt serialization, verification and
qualification as well. Affinity is recorded; development metadata preparation
on another CPU is not a clean timing comparison. Initial cache construction and
full reference acquisition are retained costs, never hidden as a warm-cache win.

The intended one-function edit changes two local output spellings in
`p111q_main` from `%result` to `%answer`. It deliberately changes emitted QBE spelling while preserving the generated
program’s intended behavior, and can change static strings/pool identity. Actual full emission must establish the
reuse rate; there is no assumed one-function/one-object invalidation count.

## Observed real edit

The independently checked one-declaration edit was emitted by the same qualified
Phase131 N2 producer. Full QBE grew from 107,059,385 to 107,059,557 bytes (+172).
Of 63,239 function and 575 data declarations, 476 function bodies and two data
declarations changed; none were added or removed. The data changes are
`p111_program` and `p111_static_image`. This invalidated the data unit and nine
function units. All 65 units retained the same referenced binding hashes.
The partition promoted 1,898 originally private cross-unit definitions.

| Step | Host elapsed seconds | Reused / rebuilt units |
| --- | ---: | ---: |
| Original partition preparation, CPU1 | 21.349 | — |
| Original cold build, CPU3 | 19.837 | 0 / 65 |
| Edited partition preparation, CPU1 | 22.841 | — |
| Edited cached build, CPU3 | 5.985 | 55 / 10 |
| Edited independent cold build, CPU3 | 19.855 | 0 / 65 |

These are single acquisition observations, not rotated performance estimates.
The 69.9% reduction applies only to the two edited **partitioned backend builds**.
Preparation scans, hashing, lookup, relinking, cold cache construction, source
checking, full QBE emission and qualification remain real costs. The prototype's
preparation plus cached build is already slower than the retained 13.82s
monolithic machine stage. Different preparation/build affinities also prevent
treating their sum as a controlled timing comparison.

A bounded lexical audit found that 377 changed functions differ only in decimal
`=l copy` operands; all 1,732 recognized operand changes are +12. This is evidence
for static-pool position churn beyond the edited declaration. It does **not**
prove valid pool references or equal decoded graph values, and the other changed
lines remain unclassified. No literal-offset normalization was used in cache
keys. Stable pool identities are a possible future experiment, not an established
fix from this result.

## Qualification and reusable evidence

The cached and independent cold edited images have identical allocated ELF
sections, including addresses, bytes and BSS sizes, and identical ELF type,
machine, entry point and program headers. Both consume the same authenticated
current plan; the cold reference uses a distinct empty cache. This proves reuse
against the same partitioning method, so independent monolithic oracles remain
necessary to validate that method.

All 15 root-executed gates passed: nine complete QBE outputs from three compiler
images over lexer, closures and Map inputs, plus six ordinary native program
outputs for the original and edited reference images. The edited QBE expectations
change only the independently authenticated main-function local spelling;
ordinary output expectations stay unchanged. Exact cached/reference QBE equality
transfers those program outputs to the cached image. These are finite correctness
gates, not generated-program speed measurements or universal conformance.

Five lexical/span controls and independent source review also passed. Five actual
cache admission negatives reject corrupted objects, receipts, current IR,
bindings and runtime identities before any child process starts. They establish
the tested integrity checks, not semantic dependency completeness.

The [evidence capsule](incremental-evidence/README.md) publishes plans, preparation
and build timings, child logs, all output oracles and gates, exact declaration
census, ELF comparison and cache refusals. Large regenerable compiler IR,
assembly and binaries are excluded with explicit identities. The
[tool commands](../../selfhost/tools/performance/phase132/incremental/README.md)
retain the prototype and supplemental comparison/gate entry points.
