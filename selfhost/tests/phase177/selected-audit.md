# Phase177 selected source audit

Verdict: **no blocking semantic or integration finding** in the selected
substitution and exact declaration-carry changes. This is a bounded source
audit supported by existing finite receipts, not an equivalence proof or an
installed-promotion decision. The auditor ran no compiler or benchmark target
and changed no production file.

## Identity and integration

Reviewed the Phase175 parent (`a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04`)
against [selected full-source01](../../build/phase177/full-source01/compiler.bend)
(`1a359a4c94c8293fec12b8722793a5beafae1896dc2a8307bf5359a7f367532f`,
3,174,925 bytes), the [owner map](selected-owners.json), the integration
script, and [proposal receipt](../../build/phase177/integration-proposal01/report.json).
The proposal is complete and unapplied. It changes only `subst`, `subst_node`,
and `p140p_def_header`, adding 16 helper definitions, ten forward signatures,
and one datatype. These signatures are not mathematical proofs.

The inverse source comparison is exact. Original declaration order, signatures,
main, and all 112 protected declarations survive. Owners place substitution
helpers in `src/core/term.bend` and parser helpers in
`src/front/compact-parser.bend`; the recipe accounts for the new declarations.
The proposed maintained assembly reproduces all five selected entry profiles
exactly (QBE, native-C, JS API, QBE policy, QBE policy test). This checks source
integration, not execution qualification of every backend. After applying the
proposal, canonical assembly must still reproduce the selected hash; the
unapplied receipt alone does not certify the subsequently edited working tree.

## Semantic review

Reused the existing [substitution review](substitution/README.md) and
[declaration review](parser/decl-reuse.md), then checked their key claims against
the selected implementations and original continuations.

The substitution state machine preserves the important distinctions: a root
Var hit returns its replacement untouched, a miss preserves even unusual stored
children, and direct `subst_node` still traverses a Var's children. Child order
is restored before reconstruction. Every App child is processed before extra
children are discarded; missing operands use the original Absent fallback.
Stuck Apps receive the same canonical metadata and original span. Both lambda
representations beta-reduce, and the beta frame restores the enclosing
substitution before processing its next sibling. Literals stay opaque;
annotations are not forced; KLambda quantity presence survives. No occurrence
or binder-shadow shortcut was introduced. The selected overlay differs from
the controlled overlay only by the `subst_node` parameter's alpha-renaming
to preserve its original signature spelling.

The parser carries two distinct values: the exact raw local `KDef` and the
local-or-prior result. Its outer book, name, and scope remain unchanged until
publication, including while nested token contexts evolve. Consequently reuse
does not depend on scope-index coherence: the original local lookup, prior/ctor
fallback, and two duplicate-index probes retain their meanings. Alias,
duplicate, template, parameter, type, and body errors retain their ordering.
Signature construction, template count, foreign dispatch, and final publication
match the originals. No index entry is substituted for a raw local declaration.

## Existing evidence and remaining limits

| Receipt | Observed result |
| --- | --- |
| [Substitution complete values](../../build/phase177/subst-values01/report.json) | 264 exact rows, including independent literal expectations and retained aliases |
| [Declaration complete values](../../build/phase177/decl-values01/report.json) | 565 exact rows, including cut states and inconsistent book/scope combinations |
| [Combined frontend values](../../build/phase177/combined-values01/report.json) | 14 fixtures, 28 parse/request observations, exact |
| [Selected full source check](../../build/phase177/full-source-check01/report.json) | Type accepted, zero unresolved holes, unchanged inputs |
| [Native N1 qualification](../../build/phase177/native64-n1/report.json) | 64 passed, zero failed/unsupported, unchanged inputs |
| [Timed products versus Phase175](../../build/phase177/timed-products45-v175/report.json) | 45 complete source/QBE byte comparisons, exact |

The main maintenance risk is the six private parser continuation copies:
future semantic fixes must update them together with their original public
counterparts. The state machine and retained local declaration also change
allocation/lifetime behavior; finite value controls do not prove unrestricted
depth or memory bounds. Existing native qualification supports the selected
image, while kernel proof, other backend execution, self-reproduction, and
installed promotion remain separate claims. No additional blocking control is
identified by this audit.
