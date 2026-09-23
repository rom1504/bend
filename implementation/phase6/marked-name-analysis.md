# Isolated marked-name experiment — 2026-09-23

**Rejected for promotion.** The two-module transient-marker candidate repairs the selected `+name` parse/check phases without capturing local binders, but introduces a concrete call-precedence regression. Production modules and the Phase5 default release are unchanged. Compiler jobs ended by03:05UTC, before the03:12 cutoff; observations overlapped broad correctness work and are not timings.

The genuine checked candidate API is `a6ee7560ffc8dc48b0b93734f7e40044a1aca60ab5d9dcd7bc49598b0bd88cb3`, assembled source `7d414d0455112293d026340e4cb115df7df37e34679f1b9457b2d3bb9fb76ba3`. It starts from final05, without the separate erased-name patch. Only `front/families.bend` and `front/fresh_work.bend` change. [Patch](marked-name-candidate.patch), [file-only audit](marked-name-audit.json), [preregistered scope](../../design/phase6/semantic-gaps.md), and [retained evidence](marked-name-evidence/manifest.json) distinguish actual results from the failed stronger gate.

The candidate represents locally bound or unqualified marked value names as temporary `FUnboundVar` nodes. Global freshening consumes each into a newly allocated ordinary `Var` without adding a binder mapping. Qualified nonlocal references keep the existing rejection; datatype handling remains unchanged. There is no U32_MAX sentinel or permanent core constructor.

| Fresh live-reference gate | Final05 | Candidate |
|---|---:|---:|
| Original19 selected observations, classification agreement |8|18|
| Same19, exact agreement |7|9|
| Additional3 call controls, classification agreement |1|2|

Both actual pinned `comptime/err_plus_term.bend` and `parse/plus_binder_term.bend` now parse successfully and reject during checking. Their strict check diagnostic oracles still fail. Ten direct/loader controls pass: fresh allocation under ordinary and U32_MAX raw IDs, nested shadowing, refusal to follow an existing binder map, and six actual loaded graphs including imports, seeded/unseeded comparison and valid marked binders. No temporary marker escapes these loader results; affected free IDs differ from every collected binder ID. These controls do not establish arbitrary ID exhaustion safety or exact accepted core graphs against the original compiler; the planned latter gate was not completed after the decisive regression.

The decisive counterexample is:

```bend
import Base
def bad(f: U32 -> U32) -> U32:
  +f(1)
def main() -> U32:
  42
```

Pinned TypeScript and final05 reject during parsing. The candidate instead parses it and rejects during checking. In contrast, `(+f)(1)` should parse and fail checking, which the candidate does. The upstream prefix operand absorbs the application before validating `+`; the port marks `f_atom` before application growth. By the time the new scope-only guard runs, the distinction needed here is lost. A future repair must address prefix operand precedence and preserve grouped-call behavior; changing checker/template rules cannot fix this cause.

Two other findings must remain separate. First, `+U32` already falsely passes checking in final05 while TypeScript rejects during parsing. The candidate retains this defect: it is not a new regression. Second, the generic template diagnostic in `err_plus_term` comes from existing `template_arg_done`, which replaces any inner failed check with “template argument is open or ill-typed.” An early suggested causal explanation involving positive fresh IDs was retracted after inspecting this code. The experiment does not prove such an ID-induced semantic change. Matching TypeScript's more precise distinction would require retaining the actual inner failure and its context, outside this capsule.

The additional `+value()` control initially had a mistaken parse-rejection oracle: live TypeScript actually rejects during checking, as does the candidate; final05 rejects during parsing. The original failed oracle/report is retained, not silently corrected or counted as a passed strict gate. All22 reference observations are identical between baseline and candidate runs, with no resource failures or changed consumed inputs. The initial19-row gate and3-row falsifier both remain failed strict gates. No broad integration, generated-program execution or self-host proof was run for this candidate.
