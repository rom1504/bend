# Constructor adjacency and parallel values

The parser-only candidate repairs five freshly reproduced acceptance gaps and
restores the intended first binder error. All110 selected observations pass:
96 paired check acceptance/phase oracles and14 exact interpreter/JavaScript
observations. This is not a full frontend, native, or self-reproduction gate.
No performance comparison was run.

Pinned TypeScript recognizes a constructor only when `{` immediately follows
the raw identifier. The port previously grew any Ref followed by a brace into
a constructor, even across spaces or after parentheses. Consequently
`a b = x {3 : U32}` consumed the second value as fields of `x`; conversely
`(Ctor){42}` and `Ctor {42}` were incorrectly accepted as constructors.

The candidate moves constructor recognition to `f_atom_name`, requiring the
same token line and exactly adjacent columns. `f_atom_constructor` preserves
constructor metadata and argument errors. General expression growth handles
calls and family arguments, with no brace suffix. Numeric atoms, whitespace
calls and existing constructor argument parsing retain their original routes.
Only `src/front/parser.bend` changes. Root independently reviewed the diff;
root approved promotion after the completed selected gates; the exact parser was copied
to production only after its original bytes matched the frozen baseline.

## Evidence and limits

The baseline is the genuine first integrated Phase5 normal bootstrap:
API `a17d909d9c481784545b5ca36c9f1dba73960eaa98cee2ac089362321674b9a4`,
source `40c05814bd338e1d2270061b85f1567bad742b79b0625bca583b5d0cbcf363de`.
The candidate was built through the maintained development workflow from a
copied frozen project, with only its parser changed:
API `f58a828127b51ab70ba69b8f9e6e591134ffe27ab40913f9e6707a3e032d00b5`,
source `221eea4b11529aff1375a2339dade5c7bdc513a08191ff92a82a8bd525bc6e5c`.
Both have genuine upstream-bootstrap reports, canonical Base, and unchanged
runtime. Node24 used CPU1,4MiB stack and4GiB heap; other correctness work ran
concurrently, so elapsed times do not support performance claims.

- `regression-v1`:92 paired checks, including all70 preceding frontend controls
  and22 adjacency cases;44 exact diagnostic differences remain.
- `execution-v1`:seven programs, each interpreted and compiled/executed as JS;
  all14 outputs agree exactly, including duplicate outer scope, whitespace calls,
  constructor destructuring through a parameter and multiline parallel values.
- `review-boundary-v2`:four paired checks, covering qualified names, a non-BMP
  string preceding a constructor, and unsupported Unicode identifiers; two
  exact diagnostic differences remain.
- The invalid parallel binder now reaches the constructor-pattern rule before
  its invalid value. Generic parse rejection alone was insufficient evidence.

[The selected audit](frontend-adjacency-evidence/final-audit.json) verifies these
counts, five before/after acceptance repairs, the intended binder rule and the
actual bootstrap source/API/module/input hashes. Full source/configuration,
failed attempts, worker histories and tools are preserved in the
[archive manifest](frontend-adjacency-evidence/manifest.json).

Two initial positive fixtures tried to destructure an already-known constructor;
upstream correctly rejects them. Their original `#|42` oracles remain unchanged,
and an attempted acceptance-metadata correction correctly failed to override
those inline oracles. A new manifest excludes these disproven controls and adds
valid constructor cases. The first Unicode-prefix control omitted the annotation
required to infer a constructor in a parallel value; both compilers rejected it.
A separate annotated fixture supplies the positive control. No failed observation
was erased or relabeled.

The current focused selection is `tests/frontend/phase5-adjacency/cases-v3.json`,
with the four review-boundary cases recorded separately in the archive. From
`selfhost/`, the recorded build used:

```sh
node tools/development/workflow.mjs run \
  build/phase5/adjacency/candidate-v1-final.config.json \
  build/phase5/adjacency/candidate-v1
node tools/development/workflow.mjs validate \
  build/phase5/adjacency/candidate-v1 \
  build/phase5/adjacency/regression-cases.json \
  build/phase5/adjacency/regression-v1
python3 tests/frontend/phase5-adjacency-audit.py \
  build/phase5/adjacency build/phase5/adjacency/final-audit.json
```

Recorded destinations already exist; replay requires restored inputs and new
output directories. The archive does not rewrite historical paths or constitute
a new bootstrap. Generic argument semicolon handling remains a separately
preregistered follow-up rather than an untested extension of this patch.
