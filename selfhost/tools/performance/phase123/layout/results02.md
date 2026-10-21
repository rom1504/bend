# Result: narrow Sigma rule does not activate; stop this avenue

The root checked the version02 compiler module and ran the diagnostic only:
`selfhost/build/phase111/p123-layout-api02/report.json` and
`selfhost/build/phase123/layout-query02/report.json`. No target emission or runtime
measurement was performed for this layout candidate. Nothing is integrated.

Observed signatures for original `rle` and `rle.step` have arities2 and5, but both
their result shape and argument-signature value are `Absent`. There is no admitted
flat entry. `unwrap123` and `inspect123` likewise remain opaque (arity1), consistent
with the recursive and dependent refusal requirements. These are signature
observations, not generated-program correctness checks or exhaustive refusal
proofs.

The actual checked type diagnostic retains the surface product aliases:

```text
rle:
  xs : List<&2,U32>
  st : Pair(U32, Pair(U32, List<&2,P2>))
  -> List<&2,P2>
rle.step:
  cur:U32 -> h:U32 -> n:U32 -> acc:List<&2,P2> -> e:Bool
  -> Pair(U32, Pair(U32, List<&2,P2>))
```

The pinned Base defines `Pair(A,B) = Sigma<&1,&1,A,_=>B>` at line136. Existing
`nq_layout_type` resolves a type's **head**, not every child. Consequently resolving
the outer owner produces a Sigma whose constant family's body still contains the
inner `Pair` application. Resolving the corresponding field produces the inner
**Sigma**. That resolved field is not an exact syntactic subterm of the owner's
unresolved child syntax, so the proposed sufficient condition is too narrow for
this ordinary spelling. This explanation follows the captured KTerms and source
normalizer; the query did not instrument an exclusive refusal branch, so other
admission restrictions are not ruled out.

The nested-state positive control never reached admission. Its line24 destructures
the computed result of `advance123(...)`; Bend requires a parameter or field
scrutinee. The receipt records this parse error and `allSourcesChecked:false`.
The fixture and expected values remain preserved as a rejected attempt. Do not
count it as a runtime failure, passing lifetime control or accepted layout.

Decision: retain this negative result and defer further alias/layout machinery.
The separate source-level ceilings removed both state shells for only roughly
10–14% runtime reduction, whereas this narrow rule activates neither original
signature. More type analysis and recursive layout changes are not justified by
that ceiling in this cycle. Version01's eager-Boolean guard flaw and version02's
nonactivation are separate findings; no production or installed selection changes.
