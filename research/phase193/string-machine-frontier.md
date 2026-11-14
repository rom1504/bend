# Phase193 borrowed-string machine frontier

Read-only inspection of retained ELF/disassembly, profiles and maintained source.
No compiler, benchmark or sampler was run; no production source changed. This
note proposes a small secondary experiment, not an implemented speedup. The
campaign's shared fused/tail-lowering coverage investigation remains higher
priority than adding a general expression/path-fact pass for these strings.

## Exact evidence and size of the problem

The same-source compiler request evidence is
`selfhost/build/phase193/compiler-profile01/{comparison.json,summary.md}`.
The compiler source is Phase192 `301435947ae813b64eebaf30610d2be4aa3be5b7ddd772bd0e68f1b6aac48c20`.
The compared ELF files are:

* QBE N1: `selfhost/build/phase192/native-image01/program`, SHA-256
  `4060b6b71d857d8eed473c80d3584f5b621faf7275eeb1ee74d765bb3418db65`.
* Direct x86 N2: `selfhost/build/phase192/native-self01/program`, SHA-256
  `8065c04b7005e0d942653ffe330fb5e7a3ac396227dd38f02160dea631685b01`.

Clean request CPU is 4.0933→5.6607 seconds. Approximate clean CPU attributed to
`$p118borrow.read.p88_string_eq_go` is 0.1997→0.3312 seconds, and to
`$p118borrow.read.String.order.go` is 0.1598→0.2601 seconds. These are physical
leaf estimates, not inclusive compiler-stage costs or removable-time promises.
The exact function disassemblies are already retained in the same directory as
`{qbe_n1,x86_n2}-{eq,order}.asm`.

| Function | QBE instructions / bytes | x86 instructions / bytes | RBP operand references QBE→x86 |
| --- | ---: | ---: | ---: |
| borrowed equality | 218 / 897 | 531 / 2515 | 24→142 |
| borrowed order | 220 / 893 | 452 / 2154 | 28→129 |

These counts include every disassembly instruction row, including QBE alignment
NOPs and all cold/error paths. RBP references include address formation; they
are neither executed memory-operation counts nor cache-miss estimates. Entry
frame reservations are QBE 0x828 bytes for both, versus x86 0xbb0/0xb70 bytes.

## Concrete avoidable work: reflexive integer tests

Both functions contain special scalar pattern matches whose condition is
literally an integer word compared with itself. In equality, each continuing
character reaches these two sequences:

```
4074ed: mov %r14,%rdi
4074f0: cmp %r14,%rdi
4074f3: sete %dil
4074f7: movzbl %dil,%edi
4074fb: mov %rdi,%r10
4074fe: test %r10d,%r10d
407501: je 4075ba              # impossible error arm
407507: mov %rsi,%rdi
40750a: cmp %rsi,%rdi
40750d: sete %dil
407511: movzbl %dil,%edi
407515: mov %rdi,%r10
407518: test %r10d,%r10d
40751b: je 40757e              # impossible error arm
```

Order already uses adjacent compare/branch selection, but preserves the same
tautologies: `cmp %r13,%r13; jne` at 0x40869d/0x4086a0 and
`cmp %rsi,%rsi; jne` at 0x408902/0x408905. QBE removes these tests. Thus the
missing optimization is earlier than merely selecting cmp/jcc instead of
materialized Boolean values.

The source cause is explicit:
`selfhost/src/back/qbe/region-admission.bend:p112_special_selected` emits
`N111Bin{"match_condition",N111U64{},"eq",word,word}` for special kinds 5–7.
`back/qbe/lower.bend:p111_special` maps those kinds to Chr, U32 and F32. Even
the F32 constructor's test here is integer equality on its representation word;
this does not authorize floating-point `x == x` folding in the presence of NaN.
This is general scalar-pattern lowering, not a String-specific instruction.

Current `back/x86/predicate-normalization.bend:x192_p_binary` recognizes exact
Boolean eq/ne with 0/1, but not equal integer operands. The existing word-fact
wrapper `back/x86/regalloc.bend:x185_fact_body` deliberately refuses bodies
containing scalar Return: its shared p113k implementation does not model Return
termination. Do not remove that guard to obtain this small optimization.

## Small bounded experiment

Extend an existing preallocation walk, after existing copy canonicalization,
with integer reflexivity and immediate constant-branch simplification. Start
with U32/U64 `eq(x,x)` and `ne(x,x)` only; produce an exact U32 1/0. Other
unsigned/signed reflexive comparisons can wait. Use exact operand identity,
not guessed type/constructor names, value ranges or physical-register identity.

For an immediately consumed condition, splice only the reachable arm. Preserve
the comparison result assignment whenever another read can observe it; the
existing dead-write cleanup can remove a truly unused result. Account for
Return, Result and Again before appending the enclosing continuation. The
existing `x190_branch_terminal` and `x190_branch_append` already encode this
termination distinction, including both scalar and structured If forms. Reuse
that contract rather than duplicating a private-only simplifier. Start with no
cross-branch state, no new expression table, no load facts and no loop facts.

A smaller lowering-side alternative is to emit an explicit true condition for
the already established scalar constructor matches, then perform the same
constant-arm simplification. Merely replacing `eq(word,word)` with `Set(1)` is
insufficient: current fallback branch emission still materializes and tests
constant conditions. The general integer rule additionally covers unrelated
IR producers without introducing a semantic-name recognizer.

Required first falsifier: the four exact checks above and their impossible
failure bodies must disappear in actual newly emitted compiler functions, and
the valid tail/return paths must remain. This is a finite development check,
not a reason to raise allocator bounds or rebuild an entire compiler before
observing the machine effect. Correctness controls should cover scalar and
structured branch forms, high-bit U64 values, low32 U32 behavior, condition
reuse/overwrite, terminal selected arms, nonterminal continuation, distinct
operands, and floating predicates remaining untouched. Use ordinary numeric
and scalar-destructuring computations as unrelated controls.

## Why this is secondary, and larger unresolved work

Pooling all four retained x86 sample captures by `samples * period_us`, with
all samples in the denominator, yields 22,701,000 weighted sample microseconds.
The two borrowed functions receive 1,328,000 and 1,043,000 respectively. PCs in
the four reflexive-test windows above receive only 45,000, about 0.198% of the
total. Attribution is sparse and PCs can reflect earlier work; this is not a
causal ceiling. It nevertheless gives no basis to promise a major compiler
speedup from these checks. Removing error branches may also change allocation
and layout, which requires an actual experiment.

Other needless work is real but requires a different, larger mechanism:

* Equality reconstructs the same raw-or-boxed Boolean predicate at
  0x407400–0x407451 and again at 0x40749c–0x4074e7. QBE reuses predicate pieces.
  Its second construction is redundant on the continuing edge, but proving that
  requires path facts or the already proposed shared semantic lowering coverage.
* Successful outer constructor matching is followed by CID extraction/comparison
  inside `p128bf_guard`; x86 equality's right-side guard at 0x407258–0x4072dd
  executes 25 static instructions, many stack transports. QBE precomputes those
  pieces and reaches a two-instruction test/branch at 0x40b0d7. That two-instruction
  comparison excludes QBE's earlier setup, so 25→2 is not a valid work-savings
  claim. `borrowed-regions.bend:p128bf_guard` is the shared producer, and the
  constructor tag check still matters even when CID is established.
* Both backends copy borrowed fields through scratch. Direct x86 additionally
  spills many guard/address/field temporaries. This is visible in frequently
  sampled PCs near 0x407100 and 0x407388, but the load/store count alone does not
  establish avoidable ownership work. Existing private-memory/scalar forwarding
  and bounded liveness must be accounted for before another pass is proposed.

The Phase192 path-fact prototype already investigated repeated CID and Boolean
expressions (`research/phase192/larger-frontier.md`); it is not a new discovery
or a selected implementation. Do not rebrand its 96-entry expression table as a
tiny reflexivity fold. If the small fold fails to improve complete requests and
unrelated scalar workloads, retain the negative evidence and return to the
campaign's larger shared semantic lowering coverage frontier.

## Offline reproduction

Disassemble either exact function with `objdump -d --no-show-raw-insn
--disassemble=SYMBOL ELF`; the retained assembly headers give the full FID symbol.
For profile aggregation, read each
`compiler-profile01/*ROLE/analysis.json`, sum `header.samples * header.period_us`,
then select `pcs[].decoded` equal to the two `$p118borrow.read` names. Select
reflexivity PCs by half-open ELF intervals [0x4074ed,0x407521),
[0x40869d,0x4086a6), [0x408902,0x40890b). Weight each PC by its capture's period.
The profile comparator's clean-scaled cost remains the appropriate reported
request estimate; the pooled diagnostic microseconds above are not clean time.
