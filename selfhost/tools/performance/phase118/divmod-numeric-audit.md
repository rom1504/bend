# Numeric recurrence: offline divmod screen audit

Read-only source/SSA/assembly/disassembly review; no compilation or execution.
Inputs are `phase117/broad-emit01/coverage-numeric-recurrence-1024.ssa` and
`phase118/divmod-emit01/coverage-numeric-recurrence-1024.ssa`, with the corresponding
`phase111/p117-broad01-…-build` and `phase111/p118-divmod01-…-build` assembly and
ELF files. Candidate QBE SHA-256:
`955cb69d7880087aae451947eacb6cb50b07033b364f4b1b2aaad30a02f72d26`.
Baseline/candidate ELF SHA-256 respectively:
`ed9c358cf35ea8e988424b3f34d65f89ae26833e605b8259f078325b740290f2`,
`886336a0b6325574b8a17b444857be7a7bbde7454f6705b89757145eb782000b`.

The hot `$direct.p37.numeric` body is byte-identical QBE (135 lines). Its
70-line assembly differs only in `.Lbb` label numbers: same 2048-byte scratch,
four saved callee registers, ten frame-pointer memory references and one
`p111_rt_op(op=58, count=1)` call per recurrence step. No integer division was
introduced into this loop. That surviving call is `F32.to_u32`, not div/mod.
Read-only ELF jump-table inspection locates its runtime arm at baseline
`0x416f58` and candidate `0x417468`; both execute the same arity test, float range
checks, `cvttss2si`, zero extension and common return sequence, with relocated
addresses/constants. No extra dispatch instruction or spill was found on that
path. This does not assert equal cache/layout behavior.

The source computes `seed % 97` only to initialize each 1024-step recurrence.
The template changes that operation in `bench`, `p93.value`, and the inlined
initialization in `$direct.p93.loop`:

| Outer repetition loop | Phase117 | Divmod candidate |
| --- | ---: | ---: |
| Assembly lines | 98 | 93 |
| Explicit frame allocation | 40 bytes | 24 bytes |
| Frame-pointer memory references | 10 | 7 |
| Calls | 3 | 2 |
| Direct `divl` instructions | 0 | 1 |

The removed call is `p111_rt_op(op=19)`; the candidate directly divides by97
and takes the remainder. The other calls are U32-to-Nat conversion (op24) and
the unchanged recurrence. Thus there is no observed spill-growth mechanism
supporting a hot-loop divmod regression.

The existing screen's numeric samples overlap: candidate124/142/136ms versus
baseline124/125/138ms, all with correct outputs. The medians136 versus125ms
are a recorded screen difference, not isolated causation. Candidate also links
the newer runtime-u32/bank/cold runtime and has different code placement.
The planned transport-only numeric comparison is the appropriate next ordinary
ablation. If needed, relinking the same candidate object against an earlier
compatible runtime isolates runtime/layout effects without changing the emitted
loop. No speedup, noise dismissal or confirmed regression cause is claimed here.
