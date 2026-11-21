# Static token-fold specialization: measured source and staged-frontend results

The source-level candidate meets the 0.5× mature-C target in this focused screen.
The later name-independent staged frontend accepts the untouched lexer and
produces exactly the same Bend bytes as that measured candidate. It also accepts
an authored transfer fixture with renamed functions/types/constructors, a direct
alternate template and different FNV/checksum algebra. This is a guarded Python
frontend emitting checked Bend, **not an installed/native compiler pass**.

| Original catalog point | Candidate / Phase199 native | Candidate / mature C | Balanced rounds |
| --- | ---: | ---: | ---: |
| lexer 8/0 | 0.08215 | 0.19801 | 6 |
| lexer 6/17 | 0.07092 | 0.18747 | 3 |
| lexer 10/123 | 0.07758 | 0.20022 | 3 |

The primary medians are 87.19µs candidate, 1061.29µs incumbent and 440.32µs C per
complete 256-line invocation. All three roles drifted between early and late
samples; no observations were removed. All accepted samples exceed 100ms.
The smaller variation also contains slow observations. These are ratios of
fresh role medians, not confidence intervals. Three sizes of one catalog family
are not three independent workload families or a full-catalog performance gain.

Twenty-five native old-versus-specialized comparisons passed for five templates
and five seeds: ordinary, alternate punctuation/adjacent mixed classes, Unicode,
empty, and refused adjacent equal classes. Seven complete-program input points
passed against unchanged C, the actual Phase199 incumbent and an independent
integer/character interpreter, including zero depth and U32 seed wrap. The
renamed/modified-algebra transfer then passed four complete-program inputs and
ran at 0.09419× its freshly built original algorithm in two balanced rounds.
There is no mature-C comparison for that changed algorithm. The transfer was
authored during this investigation; it is not a blind holdout.

[stage.py](stage.py) discovers an entire producer/consumer call graph from its
closed equations, with a bijection for input function/type/constructor names and
per-definition local names. It authenticates 22 definitions, their primitive
operations, classifier ranges, state transitions and scalar types. The immutable
[schema](schema.json) supplies internal role names; input filenames and workload
names never decide admission. The static template can be a literal or the body
of a zero-argument function. Its class-boundary certificate then derives ordered
scalar token payloads. Pure arithmetic coefficients may differ in the discovered
FNV and checksum helpers; emitted code calls those actual helpers. Changes to
classification, producer lengths or token ordering refuse and return the exact
original source. Five such negative controls passed.

The rule is deliberately narrow: `import Base` only, no attributes or shadowed
primitives/base constructors, one entire U32 return expression, a raw literal
without escapes, no fresh-namespace collision, and the certified graph. It is
not a general parser, effect analysis or arbitrary producer/consumer fusion
pass. Native source checking remains mandatory after staging. The actual census
is 3/45 admitted (the lexer family), 42/45 byte-identical refusals. Reproduce the
offline checks with `python3 -B research/phase200/lex/stage-check.py`;
[admission.json](admission.json) pins every original source and derived result.

Actual ELF inspection confirms the optimized identifier and number loops have
no calls or relocations. The plan calls only scalar helpers, with no runtime
constructor/take/operation helpers. The benchmark repetition worker still
transfers to `p93.value` on every positive iteration; it has not hoisted or
memoized complete results. [machine.json](machine.json) retains the exact
instructions and object hash; [audit.py](audit.py) regenerates this read-only
observation. Semantic counts in [PLAN.md](PLAN.md) are distinct from these actual
machine observations and are not hardware counters.

The initial source attempt failed checking in 0.52s because its zero accumulator
needed an explicit U32 ascription. A control-only IO.pure type argument was also
corrected offline before the next launch. v2 was never executed. lex-token03
completed all controls, two builds and timings in 7.78s under a 2 MiB guard, using
876,544 allocated artifact bytes. lex-stage01 completed four further builds,
transfer/variation checks and timings in 11.63s under its 12 s / 3 MiB cap, using
1,335,296 allocated bytes. No retry followed it. Every run used the original
5 GiB reserve and coordinated CPU3 lane. [evidence.json](evidence.json) pins the
successes, source refusal, exact methods and closed retention receipts;
[archive.json](archive.json) describes the verified local binary capsule.

The remaining integration work is explicit: either integrate this guarded stage
into an authorized checked frontend with equivalent Base identity and namespace
rules, or port its equation certificate/plan derivation into the native Bend
compiler IR. No maintained compiler or source fixture was edited, no selector
was installed, and the large lexer improvement is not included in the Phase200
native compiler's all45 result.
