# Supervised native compiler → QBE stdin

`build-v02.py` builds an ordinary Bend source without writing a complete textual QBE
file. It runs an existing checked native compiler, relays its stdout into pinned
QBE 1.3, retains assembly, and uses the unchanged Phase123 aligned assembler and
linker commands. It changes no Bend compiler, runtime, verification rule or
installed selection.

The relay has one 65,536-byte buffer. It hashes the original bytes and finishes
sending each buffer before reading another, so downstream backpressure bounds
transport memory. QBE processes stdin using `-`; the compiler still performs its
normal admission and final verification. Source and runtime identities, carrier
receipt, executable tools, commands, stderr, child statuses and product hashes
are recorded. A whole-pipeline deadline kills/reaps child process groups on
failure. Run it inside the existing resource guard: this transport bound is not
a memory bound on the compiler, QBE, assembly or executable.

Example, from the repository root, with a fresh output directory:

```sh
python3 selfhost/tools/performance/phase134/pipe/build-v02.py \
  --image selfhost/build/phase111/p134-no-copy-n1/program \
  --source selfhost/build/phase88/broad-fixtures03/lexer.bend \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --out selfhost/build/phase134/my-pipe-build --seconds 60
```

An ordinary new source does not need a preexisting QBE file. Its report says
`comparedToReference: false`; successful compiler verification is not a claim of
byte equality with another compiler. Add `--expected-qbe PATH` for a strict
independent digest comparison, `--expected-stdout PATH` for exact ordinary output,
and `--retain-ir` only when qualification explicitly requires a textual IR copy.
Assembly remains materialized because the established aligned build consumes it.

## Evidence and limits

The three strict builds passed using the retained no-copy N1. Each stream matched
the qualified Phase131 reference exactly; assembly and the complete object were
byte-identical to a fresh unchanged Phase123 build. All loaded ELF sections and
ELF/program headers were identical except the GNU build-ID payload; native
outputs matched exactly. No textual IR artifact was created.

| Request | Stream bytes | Largest relay read |
|---|---:|---:|
| lexer | 577,297 | 41,481 |
| coverage-closures-256 | 99,537 | 9,137 |
| coverage-map-churn-128 | 1,028,294 | 65,536 |

The whole guarded validation took 9.10 seconds with 79.9 MB sampled process-tree
RSS. These are diagnostic validation costs, not a clean speed comparison against
file-based emission. A fresh ordinary newline fixture also passed without an IR
reference. Supplying another program's digest rejected an otherwise successful
compiler/QBE stream before assembly. Timeout, killed-producer and broken-consumer
fault injection were not performed; supervision of those paths is source-reviewed.
The later full compiler stream described below measures transport at compiler scale; native session qualification remains separate.

The first harness demanded byte-identical complete ELF files and failed. The
assembler output and objects were already identical: GNU ld retains the absolute
object path in nonloaded `.strtab`, which also changes the build-ID digest. The
revised harness preserves the exact object requirement, independently compares
all allocated sections except that digest payload, compares ELF/program headers,
and executes both binaries. It does not mask machine instructions, data,
relocations, addresses or section sizes. This negative result is retained.

Receipts:

- `selfhost/build/phase134/pipe-test02/report.json`: three strict cases, ordinary
  nonreference case, actual wrong-digest refusal.
- `selfhost/build/phase134/pipe-test-guard02/process.json`: resource envelope.
- `selfhost/build/phase134/pipe-test01/report.json`: original overstrict ELF failure.
- `pipe-evidence.tar.xz` and `evidence.json`: small immutable receipts and consumed
  method snapshots; regenerable assembly, objects, executables and IR are excluded.

Reproduce the strict campaign using `test-v02.py --out FRESH_PHASE134_DIRECTORY`
inside the normal guard. Its Phase111 reference output names are deliberately
fresh-only; use new names for another run. `test.py` is the preserved failed
harness, not the current entry point.


## Full compiler stream and reviewed machine-build continuation

The native session compiler source04 was emitted by qualified core N2 directly
through this pipe: 108,111,638 bytes, SHA256
`950dd99b2eb977e3352e56ae78466ea734ff60c3ff468c0ccc58be730321392b`.
Compiler and QBE both exited zero after 399.72 seconds combined. No textual QBE
file was retained; the existing 78,489,700-byte assembly file and object remained.
This is evidence that bounded transport works at full compiler scale, not a
file-versus-pipe speedup claim.

The original `build.py` then refused four assembler diagnostics even though
assembly exited zero. That stderr policy was stricter than the established
Phase123 builder. All four were intentional QBE split-immediate stores: a
`movl $VALUE, OFFSET(%rbp)` lower-word store immediately followed by
`movl $VALUE>>32, 4+OFFSET(%rbp)`. The reported truncation equals the lower32 bits,
and the adjacent store preserves the upper32 bits. The same four function/stack
locations occur in qualified core N2: `f_path_scan`, two in `f_path_parts`, and
`book_put_many_cache_valid`. The last immediate differs with static-image layout;
no semantic literal equivalence is inferred from that fact.

`review-warnings-v01.py` checked every diagnostic, the adjacent instruction pairs
and matching parent sites, preserving exact receipt/input identities in
`selfhost/build/phase134/session-native-warning01.json`. `finish-v01.py` consumes
that review, reassembles the preserved assembly, requires the entire object and
all diagnostic bytes to match the already produced object, then links with the
unchanged runtime and flags. It neither reruns compiler/QBE nor rewrites the
failed original receipt. The separate root-owned result is
`selfhost/build/phase134/session-native-finish01/report.json`.

`build-v02.py` is the current ordinary entry. Its only behavioral change from
`build.py` is accepting assembler/linker stderr when the subprocess exits zero,
matching Phase123; diagnostics remain retained in the report. Compiler, QBE and
ordinary execution still require their existing successful statuses and clean
stderr. One additional report field documents this policy. The inverse source
delta is checked in `warning-policy.json`. No fresh full compiler emission using
v02 has been run: the reviewed continuation preserves the expensive successful
first emission instead. The original small-program v01 controls and original
failed full-stream receipt remain unchanged.

The separate continuation completed successfully in 6.28 seconds (5.19 seconds
assembly/link commands). Reassembled object and all four diagnostic bytes match
exactly. The experimental session executable is 17,315,888 bytes, SHA256
`60e7f2547a85fba90c0634a3bb833eed198fcca89d372c2e6e0e1bd23394c38b`.
This completion establishes a linked image; correctness/performance of its new
session mode belong to the independent session supervisor's receipts.
