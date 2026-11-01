# Phase152 native compiler code census

The retained N2 QBE contains **zero** instances of the strict nullary-constructor
to sink pattern, compared with **13,600 sites in 4,466 generated functions** in
N1. Every affected function remains present. Total QBE call instructions fall
by **27,032 (10.830%)**, and the executable is **651,264 bytes smaller (3.323%)**.

These are static code observations. This census does not measure execution
frequency, compiler speed, generated-program speed, semantic equivalence, or
N2→N3 reproduction. In particular, the reduction in static call sites is not a
prediction of a 10.830% speedup.

## Compared artifacts and provenance

Both complete build receipts bind the same Phase152 composite source:

- Source: `selfhost/build/phase152/composite01/compiler.bend`, 3,085,157 bytes,
  SHA256 `027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`.
- N1: [receipt](../../selfhost/build/phase152/native-n1/report.json),
  [QBE](../../selfhost/build/phase152/native-n1/program.ssa). Its producer is
  Phase147 `integrated-sequel02/n2/program`, 19,499,168 bytes, SHA256
  `ab5662a17690f6814834074442905fec2f061a67203e66c3008d51d48727ca32`.
- N2: [receipt](../../selfhost/build/phase152/native-n2/report.json),
  [QBE](../../selfhost/build/phase152/native-n2/program.ssa). Its producer is
  this Phase152 N1 executable, whose exact identity appears below.

The two generations therefore compare the same compiler source compiled by
different compiler implementations. This is a composite integration comparison,
not a separate causal ablation of each Phase152 change.

The small receipt files were hashed afresh. Large artifact SHA256 values below
are taken from those receipts; no large file was rehashed during the active N3
build. All eight artifact lengths match their receipt. Each SSA file's length
and modification time remained unchanged across its streaming scan. This
records receipt-bound identities and size/stability checks, not a fresh
cryptographic authentication of every artifact byte.

| Receipt | Bytes | Fresh SHA256 |
| --- | ---: | --- |
| N1 `report.json` | 18,270 | `6b03b7d23ff82e71d8291d2e262dfeaa47e0478cdc9df50dde3e58ff1822d559` |
| N2 `report.json` | 18,120 | `6647423619c286d8ff3b170009b2d26673f1f9ca0f2c25446c4e0bee1645205a` |

| Artifact | Receipt SHA256 |
| --- | --- |
| N1 retainedIR | `c829be90e8971198e2181709b3458ed598e21effd0d7792eceffc0aaa4c698f8` |
| N2 retainedIR | `1032c6a6495ca86bb26ad2bcd7ae639ed49dc987765dfe567dce7ac6224bf7bb` |
| N1 assembly | `06de12c5456a812feede91326048155ef8b4c7ba898db160a09e01f886c7180b` |
| N2 assembly | `88803353068a14f35a1430dea9c70477a2624bd321a52883183659f26b4f0792` |
| N1 object | `c56a9ff751a766fb8edfc1b1ccf78012c1c26d9c819ad1de0507525c1318568a` |
| N2 object | `896a04ccd67d0159871ec3b3d46907404b5fa73c2e5ae88b6a787463558e66eb` |
| N1 binary | `7da0e44af5729c587c0d04d78d9b2a6707aa2574531e07dc79313798ed8ab09d` |
| N2 binary | `d62712958b53ecdbe19998ca54c9184f895b556acc661ad014dae89754b952bd` |

Both receipts use the same Base (`99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`),
prepared carrier (`984fad041a0ba855ea0aaedd384485afa2153da644655c00882eb50ace33817f`),
and linked runtime (`2d07832382a11d7e993124ecc70452e4e1a3b7f753cf429343e1183cd8e493a3`).
Both machine builds target `amd64_sysv`, assemble with
`-mbranches-within-32B-boundaries`, and link with `-no-pie -pthread -lm`.
Their build requests use cache mode, one runtime thread and GPU off.

## Strict site grammar and census

Recognition is the same conservative lexical grammar as the
[Phase147 opportunity census](fast-loop.md#addendum-nullary-prepared-facts-in-the-actual-phase147-compiler):

1. Start at an assigned `=l call $p111_rt_ctor(l STATE, w CID, l SCRATCH, w 0)`.
   The final `w 0` is arity, independently of the constructor ID.
2. Accept only zero or more `DEST =l copy SOURCE` instructions whose source
   carries that constructor result. Track the copied aliases.
3. Count one site only when the next non-copy instruction is an assigned
   `=l call $p111_rt_sink(l STATE, l ALIAS)` for that result.
4. Any other instruction, label, function boundary, blank line, or comment
   ends recognition. There is no cross-block dataflow inference.

The exact call/copy forms were full-line matched after stripping whitespace.
A function's stable generated symbol, including its entry/worker variant,
is the comparison key. All **73,926 function symbols** are shared between N1
and N2; neither file adds or removes a function symbol. All 4,466 functions
with recognized N1 sites have zero such sites in N2, with no increases elsewhere.

| Static quantity | N1 | N2 | N2 − N1 |
| --- | ---: | ---: | ---: |
| Recognized ctor→copies→sink sites | 13,600 | 0 | −13,600 |
| Functions containing recognized sites | 4,466 | 0 | −4,466 |
| All arity-zero `p111_rt_ctor` calls | 13,607 | 7 | −13,600 |
| Functions containing any arity-zero ctor | 4,469 | 3 | −4,466 |
| Copy instructions inside recognized sequences | 16,262 | 0 | −16,262 |
| Generated function definitions | 73,926 | 73,926 | 0 |

Every recognized N1 site uses constructor ID 0. N2 has no arity-zero call for
that ID. Its seven surviving nullary constructor calls have the same counts
as N1's seven unmatched calls: ID 3 twice, ID 4 once, ID 5 twice, and ID 309
twice. Thus the recognized sites do not merely become unrecognized copies
of the same nullary call: the corresponding constructor-call population
disappears completely.

The sequence-copy row describes copies **inside matching sequences**, not
copies eliminated from the program. Total QBE copies actually increase by 581.
The compiler can retain copies of immediate values after removing helper calls.

The following exact worker observations include the earlier hot-owner examples
and the two Phase151 selector examples. Names decode the numeric `FID_`
encoding; N1 line numbers identify the first constructor in a counted sequence.
Call counts include every call in that worker, not just matched pairs.

| Generated worker | Recognized pairs, N1 → N2 | All calls, N1 → N2 | First N1 ctor line |
| --- | ---: | ---: | ---: |
| `p111_FID_$direct.nc_uses_term` | 2 → 0 | 13 → 9 | 1764703 |
| `p111_FID_$direct.p134e_next` | 2 → 0 | 45 → 41 | 2948689 |
| `p113d_FID_$direct.lookup` | 4 → 0 | 34 → 26 | 298698 |
| `p113d_FID_$direct.ns_body` | 4 → 0 | 51 → 43 | 297179 |
| `p113d_FID_$direct.p111q_memory` | 10 → 0 | 89 → 69 | 434328 |
| `p113d_FID_$direct.p111v_contract` | 22 → 0 | 160 → 116 | 386735 |
| `p113d_FID_$direct.p111_op_id` | 170 → 0 | 762 → 422 | 380532 |
| `p113d_FID_$direct.p112fp_binary` | 20 → 0 | 40 → 0 | 56050 |
| `p113d_FID_$direct.p144e_body_tail` | 4 → 0 | 20 → 12 | 411405 |
| `p113d_FID_$direct.p88_roles` | 22 → 0 | 44 → 0 | 5054 |

The largest reductions are `p113d_FID_$direct.p111_op_id` (170 pairs) and
`p113d_FID_$direct.ni_template` (140 pairs; first N1 ctor line 196289).
These static worker observations establish broad transfer inside the actual
compiler. They do not determine whether or how often each variant executes.

## Instruction and call counts

An instruction is one nonempty, non-comment line inside a QBE function,
excluding function delimiters and block labels. These are QBE instructions,
not final machine instructions. There are 4,471 shared functions with different
instruction counts. Block labels increase from 161,177 to 161,326 (+149).

| Static quantity | N1 | N2 | N2 − N1 |
| --- | ---: | ---: | ---: |
| All QBE instruction lines | 2,611,115 | 2,585,076 | −26,039 (−0.997%) |
| All `call` instructions | 249,613 | 222,581 | −27,032 (−10.830%) |
| `p111_rt_ctor`, all arities | 15,183 | 1,565 | −13,618 |
| `p111_rt_sink` | 56,839 | 43,368 | −13,471 |
| `p111_rt_keep` | 19,827 | 19,848 | +21 |
| `p111_rt_special_ctor` | 402 | 402 | 0 |
| `p125_rt_ctor2` | 6,246 | 6,225 | −21 |
| `copy` | 523,585 | 524,166 | +581 |
| `alloc8` | 90,431 | 90,333 | −98 |
| `loadl` | 394,512 | 394,608 | +96 |
| `storel` | 410,967 | 410,904 | −63 |
| `jmp` | 36,700 | 36,778 | +78 |
| `jnz` | 30,480 | 30,535 | +55 |
| `ret` | 93,997 | 94,013 | +16 |

Global deltas include other emission changes: the sink decrease is 129 smaller
than the recognized pair count, constructor calls decrease by another 18 beyond
the nullary sites, and non-call instructions increase by 993 overall.
Consequently, the whole artifact is not an exact textual deletion of 13,600
isolated call pairs. The strict census establishes disappearance of those
patterns; it does not attribute every changed instruction to one rule.

The runtime meaning remains the same limitation as in the Phase147 analysis:
a nullary constructor returns a packed value without heap allocation, and a
sink of that trivial value does not traverse a heap object. The removed sites
represent helper calls, checks and related transport; they do not establish
13,600 eliminated allocations or any corresponding dynamic reclamation budget.

## Artifact sizes

| Artifact | N1 bytes | N2 bytes | N2 − N1 bytes | Change |
| --- | ---: | ---: | ---: | ---: |
| QBE (`program.ssa`) | 120,027,859 | 118,227,421 | −1,800,438 | -1.500% |
| Assembly text (`program.s`) | 88,907,610 | 86,088,424 | −2,819,186 | -3.171% |
| Object (`program.o`) | 26,113,272 | 24,811,328 | −1,301,944 | -4.986% |
| Executable (`program`) | 19,596,488 | 18,945,224 | −651,264 | -3.323% |

These are complete file lengths. Assembly text size is not a machine instruction
count; object and executable lengths also include data, symbols and other file
content. No disassembly, object-section census or machine-code dump was made.

## Investigation cost and limits

The census ran one streaming read of each complete SSA file, serially, in a
temporary inline Python process at nice 19 on CPU 0. The two scans and count
comparison took approximately 23.9 seconds; this is investigation overhead,
not compiler or benchmark time. The active target lane remained root-owned
CPU 3. Small receipt and source excerpts were read separately; assembly,
object and executable files were only statted.

No compiler, generated target, benchmark, or disassembler was run. No compiler
source, host tool, build output, installed selection, or qualification result
was changed. The N2→N3 cold reproduction and fresh generated-program regression
screen remain separate evidence owned by the parent task.

