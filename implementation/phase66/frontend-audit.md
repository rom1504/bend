# Phase66 frontend and identity audit

The focused frontend migration passes **19 parser cases and 54 naming checks**
in the [root-executed receipt](../../selfhost/build/phase66/frontend-controls01/report.json)
(`a50ad4ec919aca4be0d3eb7ed0943fa0ac4a69520a76385a0f67208397849067`).
This establishes the finite source/display cases, not complete migration or
release qualification. The [candidate and control guide](../../selfhost/tools/performance/phase66/frontend/README.md)
records the original patch, exact source hashes and control scope.

The additional source audit compared the old and new pinned `bend.ts`, relevant
`main.ts`/`comp.ts` changes, new fixtures, and the current Bend consumers of
`name_key`, `kp_show`, `kp_name` and `kp_go`. It identified two gaps outside the
focused parser control boundary. No production source was edited by this audit.

## ADT kind dependencies in the reference trust adapter

New upstream `main.ts` walks an ADT's own telescope/type in addition to its
constructors when collecting unsafe dependencies. The own type contains its
kind and parameter domains; an empty ADT has no constructor through which to
discover them. The copied reference adapter still used only the constructor
list, so it could misreport the reference verdict and create a false disagreement
with the Bend compiler.

The Bend implementation already visits `dt(d)` in `kr_dependencies`, reached
from `dr_relies_def`. No Bend trust algorithm change is needed. The independently
reviewed [one-line adapter patch](../../selfhost/tools/performance/phase66/controls/verdict-kind-v1/candidate.patch)
adds the ADT itself to the inspected list. Its SHA256 is
`036e61a89c377d409c6c621f601f4ac9fd2143b5cdd6c0d3aedf006bd56dcc87`.
The cheapest real witnesses are the new upstream `check/unsafe_kind.bend` and
`check/unsafe_kind_def.bend`: check-only verdicts, without backend emission.
Execution/promotion evidence belongs to the qualification report.

## Display names used as printability identities

`j_printable_adt` used `kp_show(ty)` in its recursion-visited set. After the new
namespace separation, internal `child:Box` and a root declaration `child.Box`
are distinct types but both display as `child.Box`. If one contains the other,
the printability walk could stop too early and miss an unprintable field. The
54 display checks cannot detect this: equal display is intentional.

Upstream `comp.ts` uses `term_key` for this visited identity. The existing Bend
`term_key` writes raw `nm(t)` through `sk_quote`, including the colon, and also
retains type arguments. The backend owner prepared a
[two-use replacement](../../selfhost/tools/performance/phase66/backend/printable-key-v1.patch)
and [two-file witness](../../selfhost/tools/performance/phase66/backend/printable-key-controls-v1/main.bend).
The root dotted type wraps the imported type, whose field is a function. Both
should typecheck, and compilation should reject the unprintable main type.
Testing `j_compile_error` directly distinguishes the guard from any later
backend refusal. The patch leaves the human diagnostic on `kp_show`.

## Other boundaries checked

- Template instance keys remain raw structural `term_key` values. Template
  names and memo lookup names remain raw strings; upstream's Record-to-Map
  implementation change does not require a corresponding representation change
  in the Bend list-based memo.
- The new checker diagnostic patch only wraps nine displayed name expressions.
  Removing those wrappers recovers its three baseline files byte-for-byte.
  Lookups, family selection, removal lists and comparison keys are unchanged.
- The harness closure patch adds the decoder helper to frozen host inputs and
  converts only displayed verdict lines. Both implementations retain raw names
  in `unsafeDefinitions`; those identities must not be round-tripped through
  the display spelling.
- Other `kp_show`/`kp_go` consumers found in this source scan render terms or
  diagnostics. The printability visited set was the semantic-key exception.
- Upstream `safe.ts` and BendTT have substantial changes, but this compiler's
  adapter still explicitly reports `proofKernel: false` and
  `kernelChecked: false`. Ordinary checking and unsafe-dependency reporting do
  not establish independent kernel validation. Migration reports must retain
  that distinction even when new proof fixtures pass ordinary checking.

All audit commands were CPU0 source/data reads; compiler targets remained with
the root agent. Historical raw trees were not changed.
