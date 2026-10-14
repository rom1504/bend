# Native ownership samples by phase and physical caller

Root owns all builds and executions. This derivative of the Phase68 all-thread
sampler profiles an **unchanged** native compiler executable. It does not build
another compiler image or relax ownership guards.

`sample-ownership.c` adds two observations to the existing bounded sampler:

- Every delivered sample includes monotonic time and its interrupted PC.
- For `term_drop`, `span_fade` and `rfc_wrap`, precomputed `.eh_frame` rules recover
  up to three physical return addresses. Only `rsp + constant` CFA rules and
  CFA-relative return slots are accepted. Reads stay inside cached pthread stack
  bounds. There is no speculative stack scan, signal-time allocator, or general
  unwinder.

The preload also intercepts `clock_gettime` calls made directly from the existing
`io_now_run` effect. Calls from the sampler and other runtime functions are
ignored. The Phase86 entry produces two marks for Base, two for runtime transport,
and two per request. `analyze.py` validates their integer-millisecond differences
exactly against the entry's stderr. Output writing stays outside request phases.

## Bind and build

Generate a fresh table for the exact executable; this is offline ELF inspection:

```sh
python3 -B selfhost/tools/performance/phase88/ownership/make-table.py \
  --binary selfhost/build/phase87/compiler-linear-o2 \
  --out selfhost/build/phase88/ownership-table-NEW
```

The checked-in `table-linear/` is bound to the Phase87 linear candidate SHA256
`0c93d7c5cc24f0b86662573c9ba47cbe5cb854c7e72ad4f747d9ba24ca83c98f`.
It contains 55 accepted unwind rows. It is unusable with any other executable.
Generate a new table after the observer repair or another compiler change.

Under the existing serial execution guard, compile only the small preload:

```text
clang [pinned include options] -std=c11 -O2 -Wall -Wextra -Werror \
  -fPIC -shared -I TABLE_DIRECTORY \
  selfhost/tools/performance/phase88/ownership/sample-ownership.c \
  -o NEW_SAMPLE_SO -pthread -ldl -lrt
```

Before launching, verify `table.json.binary_sha256` against the executable and
record the table/header/preload/source identities. The analyzer rejects a
different full executable hash. The C sampler trusts the table selected at
build time; never launch a mismatched library/image pair.

## Root-owned execution

Use CPU3, `--threads 1 --gpu off`, the Phase86 authenticated input/Base/runtime
chunk/effect arguments, and the usual fresh output paths and RSS/time guard.
Set these variables only on the native target:

```text
LD_PRELOAD=/absolute/NEW_SAMPLE_SO
BEND_SAMPLE_OUT=/absolute/FRESH.samples
BEND_SAMPLE_PERIOD_US=4000
```

Start with Small COUNT1 (~3.2 s of historical uninstrumented work). Then use
Lexer COUNT5 on the linear image; its phase-specific evidence separates the
~3 s Base bill from the much shorter requests. After the correctness repair,
regenerate the table and profile Map separately. Every emitted C file must pass
the same independent exact-output oracle. Sampler clocks are diagnostics, not
speed comparisons.

## Offline analysis

```sh
python3 -B selfhost/tools/performance/phase88/ownership/analyze.py \
  --samples FRESH.samples --binary EXACT_BINARY \
  --table TABLE_DIRECTORY/table.json --stderr TARGET_GUARD/stderr.log \
  --out FRESH.analysis.json
```

The output includes coverage, phase clocks, leaf shares, ownership caller shares
and exact ELF return sites. It records Base, runtime transport, each request and
outside-phase samples separately. Retain both raw files and the table. Require
zero drops/overruns, an intact handler, complete thread lifecycle, near-complete
process CPU coverage and enough samples. Request phases under 200 samples are
labelled low precision even when the whole-process profile is large.

Physical callers are not a reconstructed Bend call tree. The runtime's musttail
transfers erase many semantic frames; inline ownership operations have no
standalone runtime leaf. A recovered generated segment identifies the nearest
remaining physical ownership site. Use its address with the exact generated C
and disassembly before assigning it to a compiler pass. No cache-miss,
instruction-count or reference-count-value measurements are provided here.

## Checked Base reuse controls

The source-only Phase88 entry reuses the first `DChecking` for ordinary
diagnostics and existing prefix-state construction. To compare its complete
preparation products with the previous entry, root runs:

```text
node --max-old-space-size=1024 --stack-size=4096 \
  --require selfhost/tools/performance/phase86/node-files.cjs \
  selfhost/tools/performance/phase88/ownership/base-products.mjs \
  BEFORE_CHECKED_JS_SIBLING AFTER_CHECKED_JS_SIBLING PINNED_BASE FRESH_OUT
```

Use the existing, separately identified primitive-equality compatibility images
for both sides. Each image must come from its successful checked acquisition;
record those receipts alongside this control. The harness never invokes IO main:
it removes the exact common footer and exports only the existing pure
`p86_prepare`. Both derived evaluation-source hashes are recorded. It compares
all Data fields with a shared-DAG-aware traversal and checks the prepared
prefix/book alias. Six cases cover full Base, empty and polymorphic prefixes,
parse errors, checking errors and missing bodies. Diagnostics must be exact.
This validates preparation products; it is not a native timing or native
correctness substitute. Root must still compile the candidate and compare
complete C outputs under the native entry.
