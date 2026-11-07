# Remove unreachable parser continuations

Baseline: `296f288`. The maintained change deletes six unreachable legacy
continuation definitions and their three forward laws from
`selfhost/src/front/compact-parser.bend`. It adds no functions, facts, cache,
wrappers or transport branches. All surviving declaration bodies and the entire
selected `p177dr_*` fast chain remain textually identical to the frozen baseline.
The module shrinks from 927 to 819 lines and from 45,905 to 39,123 bytes.

Removed definitions:

```text
p140p_def_context_header
p140p_def_header_prior
p140p_def_prior
p140p_def_base
p140p_def_type
p140p_def_body
```

The removed laws belong to `p140p_def_prior`, `p140p_def_type` and
`p140p_def_body`. The original call graph was an isolated chain from
`context_header` through `header_prior`, `prior`, `base` and `type` to `body`.
The real definition entry, `p140p_def_header`, already invokes `p177dr_resolve`.
There is no production call into the old chain.

These names were source-inventory entries, not promised public APIs. They occur
in the baseline compiler manifest's declaration `order`, but not its entry
profiles or protected declarations. No maintained API documentation, build or
conformance interface, or installed manifest exports them. Test tooling can
export arbitrary internal functions; that capability does not make every
internal declaration an external compatibility contract.

## Source evidence and validation

`compact-parser-before.bend` preserves the exact original module.
`deletion-evidence.json` records all nine deletions, exact equality of retained
declarations, the original internal call edges, absence of incoming production
calls, and the public/profile/protection audit. Recheck without compiler work:

```sh
python3 selfhost/tests/phase178/parser/audit-deletion.py
```

Root owns compiler execution and manifest reconciliation. Remove the nine
corresponding declaration-order entries from `selfhost/src/compiler.json`.
No profile, protected declaration or actual compiler entrypoint changes.

Use the unchanged Phase177 565-observation whole-parser controls with independently
checked baseline and candidate APIs. Their seven exports and setup are documented
in `../../phase177/parser/decl-reuse.md`; their fixture module is unchanged.
With actual receipt/output paths assigned, run under the normal root disk guard:

```sh
node selfhost/tests/phase177/parser/decl-reuse-controls.mjs --baseline "$BASELINE_REPORT" --candidate "$CANDIDATE_REPORT" --out "$OUT_177"
```

`audit-profiles.py` reuses the maintained assembler and existing conservative
identifier-closure extractor against commit `296f288`. The final audit includes
root's additional removal of the orphaned `f_def_signature` law/definition and
`f_decl_find` definition from `front/declarations.bend`: twelve declarations in
total (eight definitions, four laws). Its result is retained in
`profile-closure-final.json` and can be rechecked without running a target:

```sh
python3 selfhost/tests/phase178/parser/audit-profiles.py
```

All five maintained profile closures have identical declaration order and
normalized executable text: qbe 5,197 declarations; native-c 3,263; js-api 6,810;
qbe-policy 5,252; qbe-policy-test 5,289. The four executable profiles start at
`main`; js-api omits main and uses the union of the unchanged `hosted-exports.json`
and `js-c-exports.json` public roots. The eight removed names occur in none of those
closures. Every surviving assembled declaration also normalizes identically,
and manifest order equals the baseline order minus exactly twelve entries.
The final qbe source hash is
`8fd5043cd47361474ab9da6713687a2fd0825d8a7f0885192e5f70f67d7994db`.

The earlier nine-deletion `profile-closure-evidence.json` and parser-specific
`deletion-evidence.json` are unchanged. `audit-profiles-v1.py` preserves the exact
original profile audit script; use it with the original nine-deletion source
snapshot, not the final twelve-deletion tree. The parser-only audit still checks
its own unchanged nine-declaration scope.

Normalization removes comment/blank lines and trailing whitespace. Core term
comment cleanup therefore does not count as an executable change. This is
lexical source evidence, not a target lowerer or generated-byte comparison:
full-book numbering, source positions, dead-code emission or serialization can
still change build artifacts. Arbitrary experimental exports of the deleted
internals fall outside the maintained public-root contract. Deletion is cleanup;
these audits claim no runtime gain, equivalence theorem or completed compiler
qualification. Root's independent checks remain separate.

## Preserved, obsolete compatibility experiment

`compact-parser-compatibility-obsolete.bend` preserves the first proposal. It
shared the two chains using a carried `Maybe<KDef>` and six compatibility
wrappers. It was superseded after the API audit established that the old chain
was unreachable and had no promised interface. Keeping that machinery would
add normal-path transport cost solely to preserve unused internal functions.
It is not the maintained implementation.

`boundary-controls.bend` and `boundary-controls.mjs` retain the proposed direct
helper experiment. They exercise arbitrary internal entry points, including
caller-supplied `old` values that disagree with book/scope. They are not required
gates for the deletion and must not be included in the candidate API: the six
internal targets intentionally no longer exist. The original invalid match
placement is preserved in `boundary-controls-rejected-v1.bend`; the corrected
adapter moves dispatch to a match-first helper. No successful execution of that
superseded boundary adapter is claimed.
