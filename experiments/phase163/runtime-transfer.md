# Direct-first runtime and native-compiler transfer

These are additive experimental sources. No maintained source or protected
declaration is replaced. Parent owns compiler checking and guarded native runs.

## Complete-result runtime witnesses

Assemble `direct-workloads.bend`, `direct-runtime.bend` and exactly one of
`reverse-runtime-1000-main.bend`, `reverse-runtime-10000-main.bend`,
`lookup-runtime-1000-main.bend`, or `lookup-runtime-10000-main.bend` from
`selfhost/tests/phase163/` with the actual maintained compiler declarations they
reference. Both compiler variants must receive identical assembled input bytes.

The original reverse/lookup workloads still construct their complete result
lists. `p163r_digest` then visits every KDef/KTerm variant and field, every Unicode
character, nested child/removed/constructor list and structural terminator. It
uses an explicit work list and tail recursion. Only `[definition_count, hash1,
hash2]` is printed. The result list, allocations, traversal and destruction remain
charged; this is not a target-only lookup/reverse microbenchmark. Consumer cost
can dilute or amplify a compiler difference and should be identified separately.

`p163r_reverse_expected` and `p163r_lookup_expected` use the independent literal
expected builders from `direct-workloads.bend`, never the target algorithms.
`runtime-oracle.py` is an additional independent Python encoding of the fixture
rows and digest. It does not invoke any compiler or produced executable. Examples:

```sh
python3 -B experiments/phase163/runtime-oracle.py reverse 10000
python3 -B experiments/phase163/runtime-oracle.py lookup 10000
```

| Workload | Repeats | Expected three words |
| --- | ---: | --- |
| reverse | 1,000 | `[4000,3360609098,2569657664]` |
| reverse | 10,000 | `[40000,68119626,2704152912]` |
| lookup | 1,000 | `[10000,3337541578,1966810400]` |
| lookup | 10,000 | `[100000,1121157706,304046608]` |

The checksums are bounded supplemental guards, not collision-free equality
proofs. Keep the complete-output n=0/1/2 comparisons already used for semantic
qualification. Root should first compare the Bend expected builders and this
independent oracle at small n. Repeat counts are fixed source inputs; no expected
answer constants appear in the Bend programs. Confirm the produced program still
contains the workload loop and runtime result construction/consumption before
calling it an execution benchmark. Choose 1,000 or 10,000 only after calibration;
no duration or speed result was measured in this source-only lane.

## Narrow native compiler CLI

`selfhost/tests/phase163/direct-native-entry.bend` adds a new `p163n_*` request
chain and a private main. It deliberately does **not** replace the protected
`p111_emit_plan`. It retains the ordinary six-string protocol:

```text
phase163-direct ABS_INPUT ABS_BASE live|cache ABS_CARRIER STAMP
```

It uses the same `p86_plan`, cached/live Base preparation and
`p111_runtime_admission`, refuses effectful main, and then calls
`p163d_executable`. Output is printed through the original chunk writer. Planned
production emissions are refused, as are session/batch command arities. This is
not public CLI parity and is not a self-hosting compiler image: the direct-first
backend currently only accepts closed admitted pure workloads.

The narrower entry is necessary because stock `p111_native_args` retains batch
and session compiler paths. Also, current `p111_native_request` dispatches through
`p134e_compile_source`; merely overriding the older `p111_emit_plan` would not
have changed that route. The private chain makes the actual selected backend
explicit and leaves all maintained declarations untouched. Parent must extract
the real main closure and record its size; no sub-megabyte size claim is made
before that extraction.
