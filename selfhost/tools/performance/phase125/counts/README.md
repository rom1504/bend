# Phase125 allocation/take counters

Diagnostic-only runtime source builder, initially unexecuted and uncompiled.
`prepare.py` derives fresh source from exact Phase118 runtime-extend01:
SHA256`371f58c5d47db192fc1bbe38e990057af2145a0bccfb733062c08896c9c09f35`.
It authenticates the parent receipt and all three source/header hashes, refuses
existing destinations and proves that reversing the seven recorded substitutions
and removing the reporting suffix recovers every original byte. No original runtime
or installed selection is edited. The builder neither compiles nor executes code.

```sh
python3 selfhost/tools/performance/phase125/counts/prepare.py \
  --out selfhost/build/phase125/count-runtime01
```

The parent should compile the resulting `runtime.c` with the same pinned GCC10
policy (`-O2 -std=gnu11 -ffp-contract=off -c`), under its normal serial resource
guard, and record the resulting object identity separately. Keep instrumented
binaries distinct from all timing products. Constructor macro instrumentation
survives C inlining: it is placed inside the common inline code and sized macro
templates, not only around exported function symbols.

| Counter | Exact scope |
| --- | --- |
| `heap_alloc_calls` | Requests to the common inline allocator, including pool hits; **not** malloc calls, OS pages, peak bytes or exclusively constructor allocations. |
| `constructor_cells` / per-CID `allocated` | `term_ctr` materializations at the ten audited source use sites; each follows one fresh constructor-cell allocation in this exact runtime. Covers generic/sized native constructors, all destination extends, IO and builtin Word/Tuple creation. Packed/nullary terms, closures, reference-count cells and arrays are excluded. |
| `ctr_take_calls` / per-CID `takes` | Common inline consuming constructor extraction, including all generic/sized callers and runtime IO uses. Borrowed views and packed one-field takes bypass it and are intentionally excluded. |
| `ctr_take_fields` | Sum of the requested field counts of those consuming takes; not bytes copied and not proof of unique ownership. |
| `ctr_take_wrapped_calls` | Takes with the reference-count bit set. A wrapped handle can have refcount1, so this does not imply every such call copies or has multiple owners. |
| `extend_generic_calls` / `extend_sized_calls` | Generic destination extend and all seven sized helpers. `extendByPrefix` combines both by prefix width. |
| `extend1_calls` | Calls to the exact sized `p118_rt_extend1` helper, including after C inlining. |

These counters overlap: one extend increments allocation, constructor and extend
counters. Do not add them as disjoint costs. They count whole `p111_rt_main`
execution, including setup, warmups, validation and readback. For the Phase93
wrapper, workload evaluations are `1 + warmups + repetitions`; two equal-input
runs with adjacent repetition counts isolate a per-evaluation difference only
after accounting for argv/time-output digit changes. Prefer constructor-name
rows such as Con over total setup-sensitive allocation counts, and retain raw
counts instead of silently subtracting a guessed baseline.

After original `io_sync`, normal runtime return prints exactly one `P125_COUNTS`
JSON record to stderr and preserves stdout/exit code. Early failures do not create
a successful-looking record. Accept only exit0, exact independent stdout, one
record with status0, the pinned parent identity and `overflowOrInvalid:0`.
The runtime's existing sequential CPU restriction remains; counters are plain
integers and are not a parallel/GPU measurement facility. Missing/duplicate records,
unexpected stderr, invalid indices or overflow invalidate the measurement.

Calibration: first reuse the original frozen
`phase112/profile/counter-control.c`, whose one generic Tuple construction/take
must appear. `counter-control.c` here independently adds one sized Tuple, one
extend1/finish Cons and their consuming takes, while keeping stdout`45\n`.
`control-expectations.json` pins the expected explicit counters and CID rows before
execution. The extra pure result/state metadata is unchanged from Phase112.
Unexpected setup rows require explanation, not updating the oracle from output.

The term_ctr inventory is valid only for the pinned runtime. If another runtime
overlay introduces retagging or additional constructors, audit it explicitly and
record a new identity; do not treat source-name counting as a universal allocator
profiler. Generated QBE operations that bypass these C helpers are outside each
helper counter's scope. Instrumented runtime clocks are never benchmark results.
