# Private worker lexical capture correction

The first private whole-source compilation failed after about 602 seconds with
`F is not defined`. It is a failed correctness gate, not a successful performance
observation. The original image and failure records remain in
[private-scope-evidence](private-scope-evidence/manifest.json).

The transform identified positive-arity global functions by their source lines
and moved worker bodies to module scope. Two actual functions,
`nb_fork_close` and `j_escape_char_on`, were inside emitter-created blocks and
captured a local split-matcher helper table `F`. Hoisting lost that binding.
Two other raw text matches contained only emitted strings and were unaffected.

The correction proves lexical depth in the emitter-owned suffix after the
reviewed runtime boundary. Only module-level definitions are hoisted. Any
block-contained function keeps its original closure and generic application.
Quoted strings and comments do not affect depth; unsupported template/regex
syntax, unbalanced delimiters and duplicate global definitions fail closed.
Duplicate detection covers mixed eligible/ineligible definitions, preventing a
stale positional worker from bypassing a later binding. Public runtime and
compiler source remain unchanged.

Evidence:

- A retained tiny F-capture regression fails before the patch. The corrected
  package passes all 25 named tests, including another block-local binding name,
  ordinary/tail paths, quoted braces and unsupported/mixed-scope cases.
- Independent review approves the emitted-grammar scope and separately passes
  nine transform tests plus 14 actual checked-H worker observations. These cover
  escaping, Unicode and `nb_fork_close` through real generated callers.
- The real Bend escaped-string fixture now compiles successfully. Its 41,155
  emitted bytes equal the ordinary public H output, SHA
  `3f72bbdda80725b2ef31adc6bc8598ab725206de35976bae13150ae63ad3ab9b`.
- The corrected private image is
  `61e7d94c19bbda2de2a55037d5e2b992868a145ab6f29d557f4bc0885e759cb1`.
  Its manifest records the two excluded globals and 1,123 retained positional
  workers. The build itself took 1,049 ms, excluding Node/shell startup.

The corrected full-source gate is a separate root-owned run and was pending
when this focused report was written. Earlier selected-case observations remain
preserved with their original scope; they do not establish whole-image
correctness. Boolean/stability combinations must be regenerated from the fixed
transform before further promotion decisions.

The exact patch, tests, independent observations, build manifest and successful
fixture result are archived with hashes in
[fix-manifest.json](private-scope-evidence/fix-manifest.json). Run focused tests
with `node --test --test-isolation=none tools/private-compiler/transform.test.mjs
tools/private-compiler/boundary.test.mjs tools/private-compiler/overflow.test.mjs`
from `selfhost/`. The independent actual-worker probe is
`tools/performance/phase4/private-scope-review.mjs`.
