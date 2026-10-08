# Phase66 frontend migration candidate

This directory contains a source-only candidate against upstream
`059266225b77c8ca256ac6b25ee5c21449bab151`. The old pinned TypeScript checkout
and production Bend modules remain unchanged while integration is pending.

`make-patch-v1.py` created `candidate-v1/`: exact before/after files, a unified
patch and hash manifest. It refuses to replace an existing candidate. Do not
rerun it after applying the patch or overwrite these inputs after a target run.

The candidate changes eight Bend modules, adds 57 physical lines and eight
definitions, and introduces no data type. Most new lines carry original source
spelling into match diagnostics. No successful compilation receives a new
source traversal or term representation.

- `core/term.bend` owns the shared `name_key` operation: replace only the first
  colon with a dot for display or external keys. Internal lookup keys remain
  unchanged. The backend and checker lanes consume this helper.
- `load/modules.bend` qualifies declarations with `namespace:name`; alias
  resolution converts only the alias boundary. Ordinary member dots stay dots.
- `core/pretty.bend` compares complete namespace identities when selecting an
  own-file or import-alias spelling, matching upstream `name_show`.
- The statement parser passes its original begin cursor into the existing
  array-write recognizer. Only a variable at that cursor receives implicit
  rebinding; an explicit `Array.set(...)` call does not.
- Frontend diagnostics display qualified names through `name_key`. Match
  errors carry a rejection-only `ParseMatch` payload until the existing source
  owner can recover the exact UTF16 source slice. The parent error keeps the
  upstream-selected location; the scrutinee spelling keeps its own span.

The focused root-only control is:

```sh
node selfhost/tools/performance/phase66/frontend/controls-v1.mjs CHECKED_ATTEMPT NEW_PHASE66_OUT
```

Run under the existing serial target guard. `NEW_PHASE66_OUT` must be a fresh
directory under `selfhost/build/phase66`. The controller verifies the checked
attempt and candidate source hashes, imports the unmodified new upstream
reference, and appends diagnostic exports without modifying existing compiler
code. It performs 54 name conversion/display checks and 19 real parser cases.
Accepted cases compare internal definition/constructor identities and rendered
type/body trees; rejected cases compare complete upstream diagnostic text.
It does not check program execution, proof soundness or compiler speed.

Cases include a dotted root declaration alongside a module-qualified name,
relative imports, alias ambiguity, imported law fill, imported constructor
errors, indexed writes versus explicit calls, and match spelling after
substitution, grouping and a non-BMP comment. All expectations come from the
new TypeScript parser, not from guessed acceptance labels. Controls have not
been executed by the source-only frontend lane.
