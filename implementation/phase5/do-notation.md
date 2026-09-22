# Do-notation: grammar, empty parameters and source attribution

The first integrated candidate repairs **20 demonstrated frontend discrepancies**
in 36 focused programs: six invalid programs previously accepted, eleven valid
programs previously rejected, and three rejections at the wrong phase. All 36
now agree with live pinned TypeScript on their declared acceptance/phase oracle.
Seventeen exact diagnostic differences remain. This is a selected gate, not a
claim of complete do-notation or language conformance.

The same candidate passes **34 paired interpreter/JavaScript probes**, with
exact output agreement. These include empty and nonempty parameter lists,
nested do blocks, multiple bindings, explicit type steps, pure assignments,
marked binders and legal multiline headers.

## Change and boundary

The lexer can emit adjacent `<>` as one token. The previous do parser assumed
separate delimiters, and its bind desugaring always supplied a result type even
when the type list was empty. The new path recognizes both empty spellings and
omits that argument, matching the pinned grammar. Nonempty lists retain their
existing leading parameters and result type.

Typed statements now require an actual plain-name binder and `=` or `<-`.
Previously the parser could consume an arbitrary token as the separator, or
discard the shape of a call, constructor or literal used as a binder. Header
whitespace has a small newline-only helper: statement semicolons must not be
silently consumed there. Existing parsing errors survive parameter/annotation
handling. Generated `bind` and `pure` references retain the actual statement's
lexer position, allowing missing-definition errors to show their source line.

This change is in `src/front/sugar.bend`. It does not modify the core term ABI,
checker acceptance rules, generic lexer whitespace policy, or pinned reference.

## Attempts and counterexamples

| Attempt | Result | Decision |
| --- | --- | --- |
| Unmodified Phase 4 B1, final 36-case selection | 20 semantic and 30 exact differences | Baseline retained |
| Candidate 1, initial 11 cases | All acceptance/phase oracles pass | Expand boundary controls |
| Candidate 1, 29 boundary cases | Three legal newline headers rejected; a forbidden semicolon accepted | Correct before promotion |
| Candidate 2, six binder probes | Three malformed binder forms accepted; one proposed oracle was wrong | Correct shape validation and oracle in a new manifest |
| Candidate 3, 36 confirmed cases | Zero semantic differences; 17 exact differences | Selected correctness gate passes |
| Candidate 3, 34 execution probes | All expected values and live reference outputs agree | Selected execution gate passes |

The disputed bare constructor *name* is accepted by upstream in a do binder;
constructor patterns in ordinary local bindings have different rules. Its first
incorrect proposed oracle remains in `binding-cases.json` and the failed report.
`confirmed-cases.json` contains the corrected oracle; no historical report was
rewritten. A fresh baseline on the final manifest confirms that accepting the
semicolon case was also a preexisting bug, not introduced by candidate 1.

Independent frontend-owner review identified header newline/semicolon handling
and error propagation, then two remaining follow-ons: pure do assignments with
a constructor-named binder, and semicolons later in nonempty parameter lists.
These are outside the claimed repaired selection and need their own fresh
witnesses. Likewise the separate bare-reference-followed-by-braces parser
ambiguity remains recorded by the binding/scope investigation.

## Checked builds and reproduction

Each candidate uses an isolated copy of source and the ordinary host tools,
then runs the genuine pinned TypeScript bootstrap with a 120-second external
deadline. Its `.bootstrap.json` identifies the assembled source, all modules,
upstream compiler, host tools and generated API. The canonical distribution
is unchanged. Correctness probes used CPU0 with bounded workers while other
independent correctness tasks used other cores; these are not timing samples.

After integration, the maintained command can select these fixtures:

```json
{
  "upstream": ".bootstrap/upstream",
  "selection": "tests/frontend/phase5-do/confirmed-cases.json"
}
```

Run that configuration from `selfhost/` through
`node tools/development/workflow.mjs run CONFIG.json NEW_ATTEMPT`.
Reuse the verified attempt with `confirmed-execution-cases.json` for the
interpreter/JavaScript gate. The workflow chooses isolated execution workers.

The [evidence manifest](do-evidence/manifest.json) preserves original and
candidate source/API/provenance, complete paired reports, attempted oracles,
frozen harnesses, selected fixtures and emitted programs as hash-verified gzip
objects. Original absolute paths are historical identities, not relocation
claims. Each object decompresses to the recorded SHA256. Node and the pinned
upstream checkout remain external reproduction prerequisites.

The combined full-corpus frontend gate and final self-reproduction are tracked
in the [campaign report](report.md); these selected results do not substitute
for them.
