# Lexer manual component handoff

Selected corrected manual controls pass; saved-output timing measured. Compiler-source integration deferred; no installed lexer improvement.
[Prospective design](../../design/phase40/lexer.md).

Native String already uses JS strings, and Sigma uses native arrays. The
prototype leaves line generation and batch unchanged, retains complete strings,
constructs Cls/Mode objects and Sigma arrays per step, and directly executes
classification/step/lex only within a manually audited diagnostic benchmark
scope. It does not widen JPure or open regionProof. Public exports run their
original generic path outside that scope.

`lexer-derive.mjs` pins exact unchanged installed lexer bytes. It emits six roles:
original/noise have byte-identical complete modules; guard isolates manual entry
cost; class and step replace only their own saturated call sites; complete uses
private lex and step. Thus class/step contributions and added guard cost are
separate from the complete component. Timings use `privateBench`, explicitly a
saved-output mechanism experiment.

`lexer-controls.mjs` uses BigInt arithmetic independently of the candidate's
Math.imul expressions. It checks351 Mode/payload/character/accumulator transitions
and complete materialized tuples,12 full Unicode/mixed/deep traces with a
separate token-fold oracle,12 generated-line batch oracles and actual admission
counts. Dependency metadata mutations/getters, reentry, throws, String methods
and marker hooks, Object and Array hooks, live delayed Mode/accumulator error
ordering and100000-character explicit loop execution are retained. These are
selected controls, not broad compiler conformance.

Root alone executes, with fresh output names:

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 30 \
 selfhost/build/phase40/lexer-derive-run01 -- taskset -c 3 "$NODE" \
 --max-old-space-size=1024 selfhost/tools/performance/phase40/lexer-derive.mjs \
 selfhost/build/phase39/historical-final01/modules/lexer.mjs \
 selfhost/build/phase37/typescript01/modules/lexer.mjs \
 selfhost/build/phase40/lexer-prototype01
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 120 \
 selfhost/build/phase40/lexer-control-run01 -- taskset -c 3 "$NODE" \
 --max-old-space-size=1024 selfhost/tools/performance/phase40/lexer-controls.mjs \
 selfhost/build/phase40/lexer-prototype01 selfhost/build/phase40/lexer-controls01
python3 selfhost/tools/performance/phase35/compare.py \
 selfhost/build/phase40/lexer-prototype01/compare.json \
 selfhost/build/phase40/lexer-screen01 --node "$NODE" --cpu 3 --budget 60
```

First rejection screen should select only the smallest existing catalog lexer
point in a new config and use20seconds. All listed depth points could exceed60s;
retain incomplete attempts and split rather than reducing input/warmup. Derive
expected<1second/<100MiB; controls expected<30seconds/<500MiB; comparison estimated
20–60seconds with heap1GiB. RSS2GiB/free2GiB remain mandatory. The comparer owns
the execution lock; do not nest it inside bounded-run.

A positive result would justify a separate narrow compiler proposal for owned
String/Char/Sigma continuation provenance. This manual closure snapshot cannot
be promoted as a source purity proof. Existing String own-property/prototype,
Unicode, host mutation, public argument demand and escaped result requirements
need explicit compiler admission checks and independent Bend fixtures.

## 2026-10-03 static guard correction

The original manual scope omitted `String.fromCodePoint`, which generic gen uses
inside ctor(SCon). Its replacement could invoke mutation/reentry after admission,
invalidating owned-input assumptions. Preserve prior attempts and use
`lexer-derive-v2.mjs`, which also checks the global String binding and String
constructor prototype/own descriptors. `lexer-controls-v3.mjs` retains root's v2
control corrections and adds fromCodePoint wrapper/getter/throw/mutation/reentry
plus global String getter/wrapper controls. No compiler JPure change follows.

### Corrected manual prototype screen (completed; no source admission)

Root runs corrected derive-v2/control-v3: controls pass in4.123seconds, with376
oracle rows,109 boundary groups and4 admission observations reported. The [20second screen](../../selfhost/build/phase40/lexer-screen01/report.json)
passes in10.144seconds on fixed variation lexer depth6,seed17, three rotating
paired rounds per role. Its modules use the diagnostic privateBench export,
with manual dependency/host/String scope admission. Original/noise complete
module bytes are identical; they estimate same-run noise.

| Role | Median ms | Range ms | Original / role |
|---|---:|---:|---:|
| original |50.7664|50.6695–50.9616|1.000×|
| unchanged noise |50.9723|50.5548–51.9328|0.996×|
| guard only |52.1610|51.5187–52.2871|0.973×|
| class only |41.4241|41.0680–42.3096|1.225×|
| step only |30.8235|30.6759–34.4096|1.647×|
| lex+step |26.9008|25.6021–31.0343|1.887×|

The complete range is broad and this is a rejection screen. No TypeScript or
ordinary-public-export ratio is claimed here. The300second confirmation below remains
separate; compile costs and compiler-source ownership are not measured.

### Narrow source feasibility; defer integration for this campaign

A direct step emitter is only part of the missing proof. Current `j_pure_type`
rejects native String/Char, parameterized Sigma and native container fields;
`j_pure_eligible` and scalarCapture reject zero-arity tpl():String; native Bool.and
is absent from j_pure_native's residual whitelist. Adding these broadly would
change admission across programs and runtime descriptor ownership.

A future scoped design could prove primitive String/Char ABI plus a fully
specialized two-field Sigma whose fields already pass purity, preserve native
strings and tuples, and gate ownership under a scalar root. It must separately
handle literal nullary functions and residual Bool.and, and retain String global,
constructor/static/prototype methods, Unicode, markers, mutation/reentry and
public demand/error contracts. This needs multiple source/runtime owners and
independent Bend fixtures, so it is deferred while Nat/list source gates proceed.
No blanket native-container purity or public String entry guard is proposed.

## Corrected manual confirmation (separate from screen)

[lexer-confirm01](../../selfhost/build/phase40/lexer-confirm01/report.json)
completes in227.097seconds under its300second ceiling:3fixed points ×6roles
×5rounds =90samples, one-second warmup floor and300ms timed-block target.
Exact result/checksum observations pass. Clean roles use privateBench; the
TypeScript module is retained provenance and is not a timed role.

| Fixed point | Original median [min–max] ms | Complete median [min–max] ms | Original / complete | Same-byte noise ratio |
|---|---:|---:|---:|---:|
| lexer | 171.953 [171.828–176.474] | 80.506 [79.700–81.265] | 2.136× | 0.994× |
| variation-lexer-6-17 | 40.762 [40.477–41.616] | 20.711 [20.688–20.828] | 1.968× | 0.996× |
| variation-lexer-10-123 | 639.900 [637.134–712.617] | 304.500 [303.602–418.137] | 2.101× | 1.003× |

Large-input complete range304–418ms retains visible drift/outlier uncertainty;
all samples remain in the report. The manual complete mechanism is promising,
but the observed2.14×/1.97×/2.10× gains are not delivered compiler improvements
or ordinary public-export/TypeScript parity claims. Guard-only and class/step
ablations remain separately available in the same report. Original/noise modules
are identical to each other with added helpers, not byte-identical to untouched
installed Phase39 source. No timing is pooled with the first screen.

Final corrected controls are
[lexer-controls02](../../selfhost/build/phase40/lexer-controls02/report.json),
produced by lexer-controls-v3.mjs with SHA256
`d8caf3bb6c62fa28ed033f81fe199e3f09272d5b14184204ad4f8cc32fc3ccee`.
Their376oracle/109boundary/4admission scope includes the global String/static
fromCodePoint correction and complete deferred mode/accumulator error order.
Prior omitted-host controls and failed/superseded prototypes remain preserved.

## Corrected manual confirmation (completed; deferred source integration)

[Confirmation](../../selfhost/build/phase40/lexer-confirm01/report.json) passes
three frozen lexer points and90 samples in227.097seconds under a300second
ceiling: five rotating rounds ×six roles ×three points. Its preset has1second
warmup floor and300ms measurement target. This is a separate deeper comparison;
no screen samples or old denominators are pooled.

| Fixed input | Original ms | Complete ms | Original / complete | Complete range ms |
|---|---:|---:|---:|---:|
| depth6,seed17 |40.76235|20.71090|1.968×|20.68801–20.82832|
| depth8,seed0 |171.95348|80.50583|2.136×|79.70041–81.26489|
| depth10,seed123 |639.89956|304.49971|2.102×|303.60183–418.13726|

Original/noise complete module bytes remain identical. Their medians differ
about−0.44%,−0.59%,+0.33% at depths6/8/10 respectively; these shifts are noise,
not effects of compiler changes. Guard-only ranges overlap original at depth8
and slow at the other two points. Class-only ratios are1.16–1.23×, step-only
1.59–1.66×. Do not add these contributions or compare the hotter confirmation
medians directly with the shallower screen. Depth10's complete outlier and
shared role variation remain visible; the run does not prove full JIT stability.

Correctness remains selected manual saved-output controls, measurement valid for
these fixed inputs, decision retain evidence/defer compiler-source proof. The
scope is direct materialized lex/step under a manual privateBench guard. Nothing
is installed, no fusion is retained, and ordinary public/compiler-throughput or
TypeScript-parity claims follow. The concrete guard correction and broad native
String/Char/Sigma/nullary-helper obligations above remain the next design work.
