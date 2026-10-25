# Independent review: static comparator family

Source-only review of `phase141/static-family/core-v01.bend`, its contract,
caller inventory, controls and README, plus the assembled
`selfhost/build/phase141/integrated-source01/compiler.bend`. No target was run and
no implementation was edited by this review.

**No source-semantic blocker found.** The change removes a duplicated comparator
family and replaces runtime list callbacks with the existing closed-template
mechanism. This is narrower than a generic IR walker. Source checking, integrated
native behavior and full-request cost remain separate gates.

## Independent source checks

I independently loaded the actual Phase140 source18 and integrated candidate
declarations, then applied only the contract's canonical-name/list-call mapping
to the old bodies. Whitespace/comments were normalized for semantic comparison.

| Check | Result |
|---|---|
| Deleted structured comparators versus retained canonical bodies |12/12 exact after the declared substitutions |
| Overridden callers excluding template declaration and redesigned matrix controls |24/24 otherwise unchanged |
| Published typed-driver roots |108/108 byte-identical declarations |
| Contract-protected verifier, entry and proof declarations |227/227 byte-identical declarations |
| Definitions declared deleted by static-family contract |All40 absent |
| Static `p134v_list` calls |73 occurrences;13 concrete named pairs plus its own `A/eq` template recursion |

The source comparisons corroborate, rather than merely repeat, the contract's
normalized-body hash claims. The227 protected definitions are a broader inventory
than the composer's smaller explicitly protected set; both cover the final
verification boundary. No retained public root changes signature or body.

## Field, order and quantity contract

The canonical family preserves all five `N111Value` variants, all three
`N111Type` variants, all four word-kind variants, argument and binding fields,
all nine `N111Stmt` variants, and all five `P113DStmt` variants. The substitutions
preserve field comparison order, constructor mismatch returning false, and the
existing `&&` structure. High/low constant words remain separate comparisons.

Direct-function headers deliberately ignore the body; full function equality
still compares it. Raw-segment headers deliberately ignore their body but retain
name, arity, result count, incoming count and flags. Constructor equality retains
name, arity and hot flag. No new alpha-equivalence or approximate cache identity
is introduced.

The list traversal still compares matching heads in order and then the tails,
returns true only for two empty lists, and returns false for a shape mismatch.
Both list parameters remain `List<&2,A>`; element comparator arguments retain
their original quantities. The intentional interface change is confined to
`p134v_list`: erased type plus runtime reusable callback become leading `~A`
and `~eq` template parameters. Runtime values passed after instantiation are
only the two lists.

All concrete template arguments are names of closed types and functions, such
as `~N111Stmt,~p134v_scalar` or `~NO_Spec,~p140l_spec`. The only abstract
`~A,~eq` list call is its own template recursion. The new test matrix similarly
passes its own template arguments through recursively, with closed names at its
outer call sites. No environment-capturing lambda is supplied as a template
argument in this candidate.

`p134v_list` is intentionally no longer a runtime-callable helper. It is absent
from the108 published roots and the selected API export list. Exporting that
private helper directly as a runtime function would require an explicit wrapper;
do not silently describe this internal interface as unchanged.

## The replacement controls are not tautological

The original duplicated-family controls compared old and new implementations.
Redirecting both sides to the canonical function would destroy that oracle.
The replacement instead uses a fixed truth table based on fixture indices.

I inspected the actual retained fixtures. Their nine matrix sizes are
8,4,6,11,7,5,5,7,4, giving
`64+16+36+121+49+25+25+49+16 = 501` ordered pairs. All matrices are diagonal
except these intentional symmetric header equivalences:

* Direct function fixtures0 and4 differ only in their ignored body.
* Raw segment fixtures0 and6 differ only in their ignored body.

`p141sf_expected` supplies precisely those extra pairs. It does not invoke the
comparator under test. Its result is compared using the unchanged Boolean
comparison. The19 historical row names remain, with additional list checks for
empty/unequal-length cases and explicit String/U32 mismatches.

These are meaningful finite controls, not comprehensive field mutation tests or
a proof of equality correctness. They cover variant distinctions, nested branch
differences, header exclusions and representative fields. The exact source-body
comparison supplies additional evidence for fields not individually mutated.
Preserve the independently frozen Phase140 API for real request comparisons;
the new candidate must not become both sides of that test.

## Remaining gates and limitations

The coordinator reports a separate static-list native microprobe matching the
handwritten typed traversal across three sizes, while the original runtime
callback is slower. This review did not rerun or independently time that probe.
It supports the specialization mechanism, not a full compiler performance claim.

The recursive statement comparators introduce mutually recursive concrete
specializations. An integrated check must establish that existing specialization
memoization handles them, that their native lowering remains stack-safe under
the supported runtime contract, and that specialization does not substantially
increase compiler acquisition time or generated code size. One maintained
source traversal can still generate several concrete machine functions.

Preserve the existing final verifier and fallback invocations. Equality remains
a prerequisite for the existing immutable-reuse judgment, not new authority to
skip a required check. The prior genuine-boundary/fixed-producer cache premises
are unchanged. Full source checking, all focused controls, independent fresh/
cached complete products, and a bounded native request screen are the next
appropriate gates; no broad campaign is justified solely by this source audit.
