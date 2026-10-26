# Predicate composition result

The sole `p131i_insert` source change removes `Bool.not` from a chooser condition
and swaps two literal lambda arms. Both original and candidate passed the existing
336 complete Patricia-tree comparisons and 11,088 independent full-payload lookup
checks, then independent ordinary native output gates. All seven prepared jobs
completed successfully. This is one compiler-derived workload family, not broad
program qualification.

| Actual compiler-name subset | Original median | Positive median | Median paired candidate/original |
| --- | ---: | ---: | ---: |
| 64 names, 1,000 repeats | 296 ms | 268 ms | 0.9054 |
| 256 names, 181 repeats | 248 ms | 222 ms | 0.8907 |

Each row has five alternating pairs with identical repeat counts and two warmups.
All timed samples exceeded 220 ms. The geometric paired ratios are 0.8984 and
0.8929. These are the program's `IO.now` millisecond observations. Whole child
wall time is also retained, but its approximately 50 ms process-poll granularity
makes it a poor discriminator here. There is no measured full-compiler gain yet.

Actual machine inspection supports the intended explanation. The original
generic entry has one 64-byte continuation-stack push immediately before its
ready `Bool.not` call, followed by `p111_rt_return`. All three disappear in the
candidate. The downstream consumer is incorporated into the entry, so entry
size **increases** from 425 to 590 QBE lines and 393 to 595 x86 instructions;
those counts include cold/error branches. The complete proxy loses one QBE
function (1,060 → 1,059), and its executable shrinks by 80 bytes. The supported
claim is elimination of this scheduler boundary, not fewer entry instructions.

Reproduce the metadata inspection with `analyze-v01.py`; it never executes a
compiler or benchmark. Exact receipts and extracted machine code are in
`selfhost/build/phase144/predicate-machine-audit01/report.json` and the timing
receipt is `selfhost/build/phase144/predicate-proxy-timing01/report.json`.

## Broader candidate, not selected

`canonicalize-v01.py` tokenizes names, literals, comments, arrows and paired
parentheses/brackets/braces/type angles. It splits actual arguments rather than
matching source text with a substitution regex. It requires the exact current
`kc`, `nt_choose`, `f_choose` and imported `Bool.not` definitions. Only a complete
`Bool.not(condition)` second argument and two literal lambda arms are eligible;
indentation-sensitive `match`/`do` lambda bodies and possible local shadowing
are refused. The predicate remains evaluated once. The proof scope for supplied
thunk values does not authorize swapping arbitrary thunk-producing expressions.

On integrated source02 (`6319c70f…`), the parser finds 92 complete negated chooser
conditions; the earlier simple regex census found 87 because it omitted complex
type arguments. It rewrites 69 conditions in 63 definitions, refusing 14 sites
in protected/proof declarations and nine in definitions with attached laws.
All 101 protected and 11 proof declarations remain byte-identical, as do all
declaration names/kinds/order and all other bodies. The prepared source is
`selfhost/build/phase144/predicate-canonical-source01/compiler.bend`
(`31e1b13a…`). The separate `predicate-hot-source01` applies just the one measured
`p131i_insert` change. Neither is installed or selected.

Independent source review found no blocker for that exact candidate. Replay
hardening in `canonicalize-v02.py` explicitly refuses a local `Bool.not` binder
and recursively handles candidates in the erased first/type argument too.
Neither situation occurs in the frozen 69-site inventory; five nested sites
occur in lambda arms. V02 reproduces **identical compiler source bytes** in
`predicate-canonical-source02`, with the same `31e1b13a…` hash. Its 14 host controls
also exercise those two additional cases. Prefer V02 for subsequent source
preparation while retaining V01's completed receipt.

Twelve independent host lexer/rewrite controls passed, including nested calls,
commas and delimiters inside strings/chars, generic type arguments, local
shadowing, non-lambda and protected refusals. A complete-source token multiset
check confirms that only 69 `Bool.not` names and 69 parenthesis pairs disappear;
all remaining token multiplicities are preserved. These are transformer checks,
not Bend typechecking, optimizer correctness proofs, or native qualification.
Before its source-only freeze, the first lexer scan exposed the need to recognize
`<-` IO binding as an arrow rather than a generic-type delimiter; the token rule
was corrected. No compiler target ran on an intermediate transformer version.

The admitted owners account for 521/10,083 samples (5.17%) in the older qualified
Phase143 profile. All 87 original census owners together accounted for 622
samples (6.17%). This is whole-owner exposure, including useful computation and
helper execution under those owners; it is neither predicate-exclusive cost nor
a current candidate speedup bound. Even the proxy's approximately 10% gain does
not imply a large full-compiler gain. The strongest justified next gate is
checked source plus exact compiler-request output, then a same-input native
compiler comparison if the broader source change remains economical.

Independent admission diagnostics also explain why this is separate from
product-signature retry: original `p131i_insert` still fails non-tail self-call
and transitive helper admission, while `index_leaf` depends on the unavailable
`index_remove`/`index_remove_step` worker chain. The measured source rewrite
benefits the existing generic path without solving that larger boundary.
