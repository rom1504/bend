# Optimized native machine code: what survives Clang

Read-only follow-up, 2026-10-11. This lane disassembled existing executables on
CPU0; it did not compile or execute a program. It inspected closure and Map
hotspots selected by the root-owned `parity-survey23-samples03` campaign.

[Compact evidence](../../implementation/phase68/evidence/c23-machine-code.json)
records binary and disassembly hashes, static counts and exact profile inputs.
Full disassemblies and instruction tables are in
`selfhost/build/phase68/parity-survey23-assembly01/`; regenerate using
`taskset -c 0 python3 selfhost/tools/performance/phase68/parity-survey/machine-code.py`.
The input debug binaries were built with the same Clang22 `-O3` recipe plus
`-g`; root's `parity-survey23-debug01/report.json` verifies their complete
`.text` sections match the previously qualified executables. The script checks
those receipts and binary hashes. This is actual optimized x86-64 code, not
unoptimized C intuition.

Instruction counts below cover complete symbol bodies, including cold/error
branches and padding; they are not executed-instruction counts or speed ratios.
Sampling periods were1000/1307µs with substantial overruns, so sampled shares
are diagnostic, not precision cycle accounting. The closure/Map profiles cover
the active main thread; baseline tree/lexer profiles require the separate
all-thread investigation because of the discovered scheduler-mode mismatch.

## Closures: nearly the same dispatcher, invoked too often

| Symbol | Candidate instructions / conditional branches | Upstream |
|---|---:|---:|
| Closure dispatcher |75 /9|76 /9|
| Captured scalar addition body |7 /0|7 /0|
| Chain construction entry |95 /7|80 /7|
| `rfc_wrap` |44 /3|44 /3|

Candidate `WL_BEND_CLO_APPLY` at ELF0x16d60 and upstream `WL_FID_CLO_APPLY`
at0x9c70 perform essentially the same sequence: extract closure location/FID,
load arity, load captures, return captured storage to the allocator freelist,
move argument registers through an arity jump table, then jump indirectly
through `wl_tab`. Upstream additionally computes a three-byte metadata-table
index where ours reads a separate arity array. There is no large per-dispatch
implementation disadvantage visible in this comparison.

The dispatcher accounts for71.5–72.2% of candidate samples and61.7–66.3% of
upstream samples across the two periods. Both have samples on freelist updates,
arity moves and indirect dispatch: for example candidate0x16dd8/0x16df1/
0x16e37 and upstream0x9ceb/0x9d38/0x9d4a. These percentages have different
denominators and do not alone measure relative dispatch cost. The existing
dynamic counters establish that our program invokes the dispatcher more often.

The actual candidate addition closure at0xdfc0 is just:

```asm
add    %edx,%esi
mov    -0x8(%r14),%eax
add    $-8,%r14
lea    wl_tab(%rip),%rcx
mov    (%rcx,%rax,8),%rax
mov    $1,%edi
jmpq   *%rax
```

Addresses/displacements are shortened above; the exact text is preserved.
Upstream has the same seven-instruction shape. Generic Term variables in C
therefore do **not** imply generic arithmetic or persistent ownership overhead
on this path. Clang removed that abstraction.

However, candidate chain construction retains the generic `term_keep` decision
for a value originating as Nat decrement. ELF0xdc08–0xdc26 performs tag/static
range tests; cold alternatives include a `rfc_wrap` call at0xdc36 and a
`lock xadd` at0xdc73. The valid scalar benchmark follows the trivial-value
branch: the retained atomic instruction is not evidence that scalar values
actually execute atomic increments. A trustworthy scalar fact could remove
these tests, but the much larger target is unnecessary construction/application
of curried closures. Upstream itself still spends much time in generic closure
dispatch, making proven known-target/capture specialization a plausible route
beyond parity on higher-order programs. That benefit is unmeasured here.

## Map: product transport remains in the hot machine code

Candidate `$direct.Map.bit.go.rec` at ELF0x20f00 has203 instructions and20
conditional branches; the corresponding upstream continuation
`WL_FID_MAP_BIT_GO_K51` at0xde60 has44 instructions and2 conditional branches.
They serve the recursive String-reconstruction step but have different ABI
boundaries, so this is a structural comparison, not a5× runtime claim.

Candidate code retains:

- Tuple-tag validation at0x20f0b–0x20f25 and owned/shared destructuring paths.
- Constructor allocation freelist traffic at0x20ffc–0x21011.
- A second product allocation at0x21062–0x21077, followed by generic tag tests.
- Four static call sites for `rfc_wrap`, at0x210f8,0x21113,0x21151,0x21177.
- Return of one boxed Term rather than separate result words.

The upstream continuation allocates the necessary String node, seals its tail
when required, and returns the String plus scalar flag in two registers. It has
one `rfc_wrap` call site. The candidate's extra return-product allocation and
subsequent re-destruction have survived Clang; this is not merely unattractive
C that the optimizer later removes. Candidate profile samples include
0x21073 (allocation bookkeeping) and0x210c4 (return dispatch); its helper takes
11.9–13.1% of leaf samples. Upstream's corresponding continuation takes
13.0–16.1%, with less total work per benchmark iteration; these relative shares
must not be treated as directly comparable elapsed costs.

The full `Map.bit.go` symbols are403 candidate versus351 upstream instructions.
Both preserve generic shared-String access, allocation slow paths and recursion.
The effect of multiword results is clearest in the smaller return helper, not
in an arbitrary whole-function size ratio.

## Shared runtime operations: frequency matters more than rewriting helpers

`rfc_wrap` is44 instructions in both binaries with the same main sequence:
validate tag, allocate redirect cell, store count/location, construct marked
Term, return. Relative addresses differ, but no material algorithmic difference
is visible. It takes13.1–13.5% of candidate Map samples and10.9–16.3% upstream.
The preceding dynamic counts, rather than sample percentages alone, identify
excess wrapper production as the gap.

The outlined Map `term_keep` is30 instructions in both compilers. Its shared
branch contains an actual `lock xadd`; its unshared nontrivial branch calls
`rfc_wrap`. `term_drop` also retains an atomic path. Generic ownership operations
on unknown heap Terms survive optimization because their tag/refcount semantics
are real. This differs from known scalar arithmetic, whose abstraction can
vanish completely.

The immediate implication is to **avoid unnecessary products and ownership
transitions**, using validated kinds/layouts across calls, rather than expect
large gains from replacing the already-similar allocator/dispatcher helper
implementations. Candidate Map's stronger evidence supports multiword scheduler
results; closure evidence supports known partial applications and direct known
closure targets. Both require preserved evaluation/ownership semantics, and
neither is a measured optimization yet.
