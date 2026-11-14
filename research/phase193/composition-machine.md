# Phase193 actual public-composition machine witness

The candidate places the expected ready-helper calls inside all four compiler
owners. It removes the scheduler visit to those helpers and resumes their
continuations locally. The complete owner bodies generally become larger:
static call totals are therefore not a measure of the removed dynamic work.
This is an offline machine witness, not another timing or compiler build.

## Products and method

[Audit script](composition-machine-evidence/audit.py),
[exact metrics and identities](composition-machine-evidence/metrics.json), and
three compressed bounded disassemblies preserve the evidence. The audit executes
only nm and objdump; it never runs the inspected products, a compiler, linker,
assembler, benchmark or sampler. No compiler/test source was edited.

Roles:

- Qualified Phase192 complete compiler N2: `selfhost/build/phase192/native-self01/program`.
- Kernel baseline: `selfhost/build/phase193/compiler-hot-baseline-machine01/program`.
- Kernel candidate: `selfhost/build/phase193/compiler-hot-candidate-machine01/program`.

The baseline/candidate emission and machine receipts are complete and their
binary, source-object, kernel-source, API, compiler-source and runtime identities
were reopened and checked. Both kernel roles consume the same17,803-byte source,
SHA256 `78ea3e0d626fc770db1810ab07f90eed9f6bc4cc2505f39f6d7de97f5436b8c8`,
and the same runtime object `67141c4505a0355901d857c4ba81dfc17559329e536818a843ce68615384d13e`.
The source manifest identifies unchanged declarations extracted from the
qualified compiler source and a separate workload exercising persistent index
updates, retained earlier aliases, hash collision keys and Unicode keys.
The baseline uses Phase192 selected-api01; the candidate uses Phase193
candidate-api02. These kernel products are checked-hosted emissions, not a new
native candidate compiler lineage.

Only seven named public symbols per ELF were disassembled. The complete compiler
lacks the kernel-specific entry/loop owners, as expected. Counts include static
padding instructions and cold paths; frame-memory counts are syntactic references,
not dynamic loads, spill counts or memory-stall measurements. State.next targets
were decoded against each ELF's actual p111_segments table, not guessed from FID
numbers. The source ABI parks state in r12 in the inspected owner prologues.

## Compiler-owner transfer

For each of these four owners, the qualified complete compiler and extracted
baseline kernel have the same function byte size, instruction count and listed
runtime/ready-call inventory. This is a concrete structural transfer witness;
it does not assert byte identity across different programs, constructor IDs,
FID tables or relocation addresses.

All names below mean their public `p111_FID_$direct.<name>` entries. The new
ready calls target their existing `p112w_FID_$direct.<target>` forwarders.

| Owner | Compiler N2 / baseline instructions | Candidate instructions | Baseline → candidate bytes | Newly direct ready calls |
|---|---:|---:|---:|---|
| index_leaf | 82 | 84 | 383 → 386 | dn ×1 |
| index_remove | 201 | 202 | 933 → 929 | dn ×1 |
| p111v_put | 102 | 137 | 482 → 677 | atom ×2; index_hash ×1 |
| p131i_insert | 999 | 1,162 | 5,102 → 5,961 | index_split_bit ×2 |

The selector's emitted state.next stores show which scheduler transfer remains:

| Owner | Baseline next target at replaced boundary | Candidate remaining next target |
|---|---|---|
| index_leaf | dn | index_remove |
| index_remove | dn | p88_string_eq |
| p111v_put | atom | index_set |
| p131i_insert, two helper boundaries | index_split_bit | index_leaf/index_join paths after local continuation work |

This shows removal of the intermediate helper/continuation transitions while
retaining the required subsequent transfer. It is **not** correct to claim that
all jump calls disappeared from these functions. The static p111_rt_jump calls
are1→1,1→1,1→1 and6→7 respectively. Calls to p111_rt_frame are absent in both
roles because the original selector already expands these frames into stores.
The relevant machine evidence is the changed target and removed inline frame
setup, not an absent frame-helper call.

## One complete physical boundary

Baseline kernel index_leaf starts at0x416e34. It retains a parent frame with
three words at0x416e9f–0x416ece, then pushes a second two-word continuation frame
at0x416ee0–0x416f00. It publishes dn as state.next at0x416f60 (or takes the exact
rt_jump fallback at0x416f97).

Candidate index_leaf starts at0x4191bf. It retains the first parent frame at
0x41921d–0x41924c. The second frame push is absent; the code directly calls the
existing dn forwarder at0x41926d, receives its scalar result, stores that result
alongside the captured value, and publishes index_remove at0x4192ee (fallback
call0x419325). The existing runtime parent continuation remains authoritative.
Thus this boundary removes one runtime frame push plus the scheduler visit to
dn and its resumption segment; it does not remove dn's required computation or
the later index_remove computation.

The same direct-call construction is visible at candidate addresses0x419a96
(index_remove→dn),0x41462f/0x41464a/0x41472a (p111v_put→atom/atom/index_hash), and
0x415cec/0x416c4a (p131i_insert→index_split_bit).

## Costs remain visible

| Owner | Stores to state.SP, baseline → candidate | Native stack subtraction bytes, baseline → candidate |
|---|---:|---:|
| index_leaf | 2 → 1 | 2,384 → 4,432 |
| index_remove | 5 → 4 | 2,512 → 4,576 |
| p111v_put | 1 → 0 | 2,384 → 6,528 |
| p131i_insert | 10 → 9 | 2,976 → 7,248 |

SP-store counts include all static control paths and adjustments, not only pushes.
The additional native space comes with copied continuation scratch and local
homes; the adapter does not turn recursion into unbounded native recursion.
Those larger fixed frames and larger code are real costs that a runtime win must
cover. The owner-level instruction increases also include required operations
previously located in separate continuation bodies. No instruction-cache cause,
branch prediction effect or dynamic total-instruction reduction is established.

## Kernel entry control and scope

The kernel's public main, `$direct.p193t_run` and `$direct.p193t_go` retain their
40/53/129 instruction counts and identical instruction streams after narrowly
normalizing symbolic branch/call addresses and RIP-relative symbol displacements.
Exact raw byte hashes differ due to relocation targets. Their frame subtractions
stay2,320/2,336/2,480 bytes and their state.next targets stay
p193t_run/p193t_go/p193t_values respectively. The observed owner changes are not
an alternate kernel entry or removed workload loop.

This report establishes that the intended general composition reaches real
compiler source owners and removes specific runtime boundaries. It does not
establish their dynamic invocation counts, coverage of complete compiler work,
a complete-compiler speedup, or which share of the separately observed kernel
runtime change comes from these four owners. Native45 correctness/timing and
compiler-request timing remain separate root-owned evidence. No inference from
the small kernel to the whole compiler is made here.
