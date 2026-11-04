# Independent audit of the Phase160 C02/QBE request comparison

The current frozen artifacts support a **same Bend compiler implementation,
different generated executable/runtime** interpretation. I found no source or
request-mode mismatch invalidating Map02. This does not isolate Clang, QBE,
allocation policy, or any one compiler optimization, and it is not default
bendc performance or a generally qualified replacement compiler.

## The compared work is the complete original request

`experiments/phase160/tools/boxed-requests.py` starts fresh processes with the
same working directory, Base file, workload file, `old` mode, one Bend thread,
GPU off and a fresh absolute output path. It clears inherited `BEND_*`,
`LD_PRELOAD` and `LD_AUDIT`. `execute` in `selfhost/tools/profiler/run.py:76`
sets native argv0 through `Popen(executable=...)`; it does not execute a different
wrapper implementation. C receives argv0 `transfer` plus the four remaining
arguments; QBE receives the extra positional `transfer` because its IO provider
omits argv0. Both produce the same five-element Bend argument list.

The exact request source is Phase156's checked 1,565,433-byte closure, SHA256
`6020f680fd96e59b5a629e3ba898aacfc7f85895e9b2b22f3f1426084f656ce3`.
The compatible C source input differs only at the audited lambda-layout sites,
SHA256 `d5df3c605d616f138ec1898884d6bf21e83c48a35dddedc6432c0b5d08c49d5b`.
`parser-equivalence02/report.json` records 4,890 exact spanless structural rows,
including Base, types, bodies, constructor tables and declaration order.
The original independently checked receipt and QBE build bind the original
hash. The C emission binds the compatible hash. This is a recorded source
equivalence bridge, not identical source bytes or a claim that parsing alone
constitutes fresh source checking.

Phase156's preparation preserves original ancestors by whole-identifier
renaming to `p156o_*` and checks inverse rewriting against original bytes.
The three candidate replacements are `p113pl_bind_flat`,
`p143cp_seed_ready`, and `p143cb_resume_state`; affected ancestors are cloned.
The driver selects the **original** branch in both executables:

- `p156h_request` reads Base and input and calls live `p86_prepare`.
- `p156h_plan("old",...)` calls `p156o_p86_plan`, retaining the original
  load/parse/check/publication and request-admission path.
- `p156h_emission("old",...)` calls `p156o_p134e_plan`, retaining lowering,
  scalar/observer optimization, final independent verification and emission.
- `p156h_write` drains the maintained planned-emission cursor
  (`p134e_begin`/`p134w_drain`), or writes every legacy chunk with its newline.
  Source errors, invalid modes, empty emissions and write failures do not count
  as successful requests.

The source contains the original `p113d_passes`, `p113e_verify_original`,
`p146c_verify` and all their dependencies. No request-side optimizer or checker
disable is selected. `--no-check` was a flag of bendc while **building the C
executable**; it is absent from its measured request arguments. The unrelated
Phase160 `closure-prepare01`/`closure-check01` source is not either measured
executable's source and should not be substituted into this provenance.

The QBE executable was acquired in cache mode, but that only describes its
construction. Its measured driver explicitly calls live `p86_prepare`; neither
measured role receives the prepared Base carrier or precomputed source IR.

## Identity, output and timing boundaries

I independently rehashed the two executables, original/normalized sources and
emitted C predecessor, and checked their actual receipt chain:

| Artifact | SHA256 |
| --- | --- |
| C02 executable, 5,163,600 B | `d202c5c3e3973d4f08c10315a04058d43e8efff2b7b4e8ded814918f671da95f` |
| Phase156 QBE executable, 17,334,192 B | `3d6c7ec0acf162bc5872358c9ccdbad42af3d9ada45a4dc59ceb1b3bf36ad7f9` |
| C02 adapted C, 6,012,086 B | `9d90a1c2e28d9b58f61ea6aa39b779e02de2657cc055aea59b36f0e03384fb89` |
| Common Base, 75,064 B | `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf` |

`execute` starts its wall clock before process creation and stops after
`wait4` reports child termination. Thus input IO, initialization, all reached
compiler work, full output-file writes/close and process teardown are included.
CPU and RSS are child `wait4` statistics. Output hashing, complete-byte oracle
comparison and hardlink deduplication happen **after** the timed child exits.
Each output is initially fresh, so deduplication does not let a target reuse the
oracle. It preserves the already verified bytes after measurement.

Map02 records one pair: C 1.156837 s, QBE 2.953365 s; both produce all
1,028,598 oracle QBE bytes exactly, SHA256
`eba759e043db9d1dcb5883e51c2120d99e103cac70e334fa327da1458d7f7fda`.
RSS is 233,768 versus 34,180 **KiB** (about 228.3 versus 33.4 MiB), not those
same numbers in MB. This is a first observation, not a balanced distribution;
the short fixed-order pair has process/cache/IO costs and cannot project the
full-source speed ratio. Keep checker/full-source results separate when they
arrive, and require their complete independent oracles.

The runner verifies pinned files but does not itself assert every transitive
relationship among the C build, normalization report, original checked report
and QBE build. For example it pins the QBE build report without asserting that
its binary entry equals the selected image. I checked the current concrete
links and they match. This is a future tool-hardening opportunity, not evidence
that the present frozen comparison selected the wrong image. Likewise the C
build receipt's wording “ordinary output oracle remains pending” describes
acquisition; Map02 is the subsequent successful output gate.

The C policy is `BEND_NO_FREE=1`, `BEND_RC=0`, `BEND_AUTO_PAR=0`,
`BEND_UNBOX=0`, otherwise current bendc default optimization, built with pinned
Clang `-O2`, strict nine-effect ABI bridge and private Phase159 bounded-search
GC runtime. QBE uses the qualified explicit ownership runtime. The C policy
can defer garbage reclamation and retain substantially more memory. Both
process times include their actual runtime costs; they do not impose an equal
memory/collection policy. `BEND_UNBOX=0` disables the defective argument/result
unboxing path, not every representation optimization: word leaves/headerless
eligibility remain controlled by the default `w`/`h` flags. The earlier default
unboxing image failed Map and supplies no valid timing comparator.

## Three concrete code-generation differences worth profiling

These are static mechanisms present in the compared images, **not measured
attribution or claims that every listed variant is hot**. QBE has multiple
original/direct/borrowed/product variants, so dynamic attribution must identify
which worker is actually called. QBE IR copies and scratch allocations also
must not be counted as surviving machine instructions without assembly review.

1. **Direct native calls versus continuation transport.** C02's
   `F_p128raw__session__finish` (`program.c:133143`) calls
   `F_p114s__open__lowered` directly and then composes the following stages as
   ordinary C expressions. The corresponding emitted QBE
   `$direct.p128raw_session_finish` (`program.ssa:2380445`) loads arguments from
   the state register array, writes continuation captures and continuation IDs
   to the runtime stack, and invokes `p111_rt_jump`. This is a concrete possible
   cost of the general scheduling/return protocol, separate from the Bend
   algorithm. It is not proof that this one entry contributes materially to
   the whole timing.
2. **Character/scalar representation and field access.** C02's `index_hash`
   loop (`program.c:34006`, wrapper `:34025`) reads string head/tail with `FLD`,
   uses the character directly as a scalar and keeps the accumulator as
   `uint32_t`. The QBE owned borrowed-worker variant
   `$p128borrow.owned.index_hash` (`program.ssa:2298`) calls `p125_rt_take2`
   for the string node and `p111_rt_special_take` for its character before the
   xor/multiply. A distinct read-only borrowed variant also exists at `:2379`,
   so attributing all hash calls to the owning path would overstate the cost.
   The C path presents less representation work to Clang even with general
   parameter unboxing disabled.
3. **Local ownership/reclamation versus tracing.** C02
   `F_p88__string__eq__go` (`program.c:25661`) is a direct tail loop over
   `FLD` values with no local take/keep/sink calls. Its QBE owned worker
   (`program.ssa:2498`) uses `p125_rt_take2` and has `p111_rt_sink` calls on
   discarded tails. The C runtime instead pays allocation/collection costs
   elsewhere and may carry the discarded graph until collection/process exit.
   Map02's higher C RSS is consistent with this tradeoff but does not establish
   how much execution time it explains. The existing source-rooted profiler is
   needed to connect these mechanisms to actual work.

The earlier wrong error projection is absent in the inspected C02 boundary:
`F_p128raw__session__finish` passes the whole outer lowered record to
`F_p114s__open__lowered`; that callee (`:140650`) tests and returns
`FLD(outer,1)` as the error string. This independently matches the source and
supports the successful Map oracle; it is not a general proof of bendc codegen.

No compiler/build/benchmark job or production edit was performed for this audit.
