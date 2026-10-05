# Direct JavaScript: maintained source regression gate

This gate reuses the JavaScript portion of the maintained backend census:
**26 rows**, comprising four compile-boundary cases and 22 namespace-selected
positive programs. Their historical verdicts are 22 passes and four N/A.
The 81-row census also includes interpreter, native and check observations;
those are outside this new JavaScript backend's scope.

Coverage includes arithmetic, higher-order recursion, erased types, imports,
foreign character marshalling, effects, mock graphics, sharing, partial
functions, printing and type-valued mains. Selection, fixture oracles and
judging are unchanged. The independent Phase52 semantic scenarios and the
45 performance points remain separate gates.

Run only against a fresh checked full-stage attempt. Root schedules execution:

```sh
python3 selfhost/tools/performance/phase52/direct-conformance.py \
  selfhost/build/phase52/checked-direct04 \
  selfhost/build/phase52/direct-conformance04
```

`--plan-only` prepares a separate fresh output directory without running any
compiler or generated program. A later execution needs another fresh directory.

The controller uses the attempt's frozen conformance harness and typed driver,
with a small adapter explicitly selecting `backend: 'direct'`. It freezes the
selected attempt path into that adapter so retained replay commands do not
depend on an unrecorded environment variable. The pinned TypeScript reference
is executed through the existing reference adapter.

Execution is serial on CPU 3, with 30-second case deadlines, 1 GiB worker heaps,
a 2 GiB process-tree RSS guard, 4 GiB available-memory floor and a 900-second
outer deadline. The selected attempt, producer, sources and report inputs are
hashed and rechecked. It does not install or promote a compiler.

`pass` requires completion, all 26 semantic observations agreeing, and both
sides satisfying the existing fixture judge. Exact diagnostic agreement is
reported separately. N/A does not become an execution pass. Failures preserve
their generated programs, process logs and replay records. This is source
regression coverage, not a timing result or full-conformance claim.
