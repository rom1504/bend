# Compatibility matrix

This report measures the typed Bend compiler against the complete pinned upstream
corpus. **Strict full-suite verdict: incomplete.**
There are 1378 source fixtures in 24 namespaces:
919 positive and 459
with an `Error:` expectation. No namespace is removed. GPU hardware gates and
negative rejection differences remain visible; they never count as successful tests.

Pinned upstream: `6018e28ecc67cf1fffc0c20c64b11023474c2df8`.
Run: 2026-09-20T23:58:32.606Z–2026-09-21T00:31:55.321Z; v24.19.0, linux/x64;
6 workers, 300000 ms per isolated probe.
Requested lanes: `parse,check,interpreter,js,native,metal,cuda`. Missing lanes are not inferred from others.
Evidence: [full JSON](../tests/conformance/typed-release-a6f.json).
These counts apply to the recorded artifact hashes. Later source changes need
separate validation; they do not retroactively change this run's verdicts.
The earlier unchecked compiler is recorded separately in [PROTOTYPE-BASELINE.md](PROTOTYPE-BASELINE.md).

## Exact fixture comparisons

| Lane | Total | Pass | Fail | Timeout | Crash | Exempt | Unsupported | Hardware gate | Observation |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| parse | 1378 | 919 | 0 | 0 | 0 | 0 | 0 | 0 | 459 |
| check | 1378 | 1001 | 377 | 0 | 0 | 0 | 0 | 0 | 0 |
| interpreter | 1254 | 977 | 277 | 0 | 0 | 0 | 0 | 0 | 0 |
| js | 999 | 672 | 206 | 0 | 0 | 121 | 0 | 0 | 0 |
| native | 982 | 656 | 205 | 0 | 0 | 121 | 0 | 0 | 0 |
| metal | 14 | 0 | 0 | 0 | 0 | 0 | 0 | 14 | 0 |
| cuda | 14 | 0 | 0 | 0 | 0 | 0 | 0 | 14 | 0 |

A pass requires the expected output and exit behavior. Parse observations for
negative sources do not prove a checking rule. Compiled exemptions use the pinned
upstream's exact refusal to print a function, Type, or erased/dependent field.
Hardware execution requires a real device, a forced device run, and adapter evidence;
CPU fallback is never a GPU pass.

## Checking versus diagnostics

The real checker accepted **919/919 positive programs**.
No positive checker rejection, timeout, or crash was observed.

| Error-expectation check observation | Count |
|---|---:|
| Rejected during check | 298 |
| Rejected during parse | 152 |
| Rejected during compile | 1 |
| Rejected during load | 6 |
| Accepted by checker; exact later rejection confirmed | 2 |
| Accepted; expected later rejection not established | 0 |
| Timeout or crash | 0 |

There are **265 exact checker-rejection comparisons** across
all lanes, **0 exact frontend rejections**, and
**10 exact compile/runtime rejections**.
A generic or unrelated rejection is not an exact conformance pass. An
`Error:` fixture can describe a runtime/emission error; check-only acceptance of
such a fixture is not by itself a checker defect. Supplemental negative execution
lanes preserve their actual rejection phase for that distinction.

The [negative-test audit](NEGATIVE-COMPATIBILITY.md) separately examines the
recorded a6f release. It distinguishes presentation evidence, different rejection
rules/phases, and cases whose intended-rule coverage remains unproven.

Correctly deferred errors: `io/main_foreign.bend` (compile; interpreter, js, native), `reg/array_open_element.bend` (compile; interpreter, js, native).


## Positive programs by namespace

Cells show exact passes/probes. Exempt compiled outputs remain in the denominator
and are listed separately. The check column measures actual validated acceptance,
so declaration-report text mismatches do not conceal successful checking.

| Namespace | Positive | Parse | Checked acceptance | Interpreter | JavaScript | Native |
|---|---:|---|---|---|---|---|
| base | 23 | 23/23 | 23/23 | 23/23 | 23/23 | 23/23 |
| check | 75 | 75/75 | 75/75 | 72/72 | 61/65 (4 exempt) | 61/65 (4 exempt) |
| compile | 95 | 95/95 | 95/95 | 95/95 | 95/95 | 95/95 |
| comptime | 28 | 28/28 | 28/28 | 28/28 | 28/28 | 28/28 |
| cost | 4 | 4/4 | 4/4 | 4/4 | 4/4 | 4/4 |
| eval | 35 | 35/35 | 35/35 | 34/34 | 17/34 (17 exempt) | 17/34 (17 exempt) |
| flatten | 186 | 186/186 | 186/186 | 186/186 | 11/57 (46 exempt) | 11/57 (46 exempt) |
| gfx | 4 | 4/4 | 4/4 | 4/4 | 4/4 | 4/4 |
| grade | 2 | 2/2 | 2/2 | 2/2 | 1/1 | 1/1 |
| halt | 9 | 9/9 | 9/9 | 9/9 | 9/9 | 9/9 |
| import | 14 | 14/14 | 14/14 | 11/11 | 10/10 | 10/10 |
| io | 93 | 93/93 | 93/93 | 91/91 | 89/90 (1 exempt) | 73/74 (1 exempt) |
| page | 4 | 4/4 | 4/4 | 2/2 | 2/2 | 2/2 |
| parse | 81 | 81/81 | 81/81 | 81/81 | 46/65 (19 exempt) | 46/65 (19 exempt) |
| printer | 7 | 7/7 | 7/7 | 7/7 | 0/7 (7 exempt) | 0/7 (7 exempt) |
| proof | 45 | 45/45 | 45/45 | 39/39 | 33/34 (1 exempt) | 33/34 (1 exempt) |
| reg | 88 | 88/88 | 88/88 | 88/88 | 86/87 (1 exempt) | 86/87 (1 exempt) |
| rfc | 9 | 9/9 | 9/9 | 9/9 | 9/9 | 9/9 |
| run | 69 | 69/69 | 69/69 | 69/69 | 65/69 (4 exempt) | 65/69 (4 exempt) |
| show | 8 | 8/8 | 8/8 | 8/8 | 5/7 (2 exempt) | 5/7 (2 exempt) |
| spec | 2 | 2/2 | 2/2 | 2/2 | 2/2 | 2/2 |
| state | 8 | 8/8 | 8/8 | 6/6 | 0/3 (3 exempt) | 0/3 (3 exempt) |
| stats | 5 | 5/5 | 5/5 | 5/5 | 5/5 | 5/5 |
| stuck | 25 | 25/25 | 25/25 | 25/25 | 9/25 (16 exempt) | 9/25 (16 exempt) |

## Remaining positive checking failures

No positive checker rejection, timeout, or crash was observed in this run.

## Remaining positive execution failures

No positive execution failure, timeout, crash, or unsupported result was observed in the requested lanes.

## Scope and implementation

The generated Bend API performs parsing, import loading, elaboration, checking,
specialization, normalization, annotation, and JS/native emission. The JavaScript
shell supplies file IO, ABI conversion, runtime loading, and host toolchain steps.
The upstream compiler is used to bootstrap an API, not to process ordinary programs.
Base reuse is bound to compiler/source hashes and canonical path, verified against
source text by the Bend loader and against the complete core prefix by the checker.

Separate component evidence is in [component-report.json](../dist/component-report.json).
Primary self-hosting evidence is in [seed-verification/report.json](../dist/selfhost/seed-verification/report.json).
[Earlier failed attempts](../dist/selfhost/release/report.json) are retained separately.
The direct verification report records a completed 49-minute checked rebuild
whose output is byte-identical to the self-emitted seed. This fixed point is
separate from upstream conformance and is tied to the recorded source/Base paths.

The inventory records all upstream compiler exports and function names, 80
effect source files, and 30 non-Bend support fixtures. Benchmarks,
demos, hub/publishing behavior, installation/release parity, and the Lean
formalization are not established by these fixture results.

| Upstream source | Lines | Exported declarations |
|---|---:|---:|
| bend2/bend.ts | 3870 | 188 |
| bend2/comp.ts | 6494 | 8 |
| bend2/main.ts | 681 | 1 |
| bend2/base.bend | 2908 | 0 |
| bend2/bend.lean | 20981 | 0 |
| gates/test.ts | 228 | 0 |

## Reproduce

Use the pinned checkout and artifact hashes below. See
[the harness protocol](../tools/conformance/README.md) for frozen host adapters,
process deadlines, exact diagnostics, progress files, and GPU gating.

`node tools/conformance/run.mjs --adapter tools/conformance/adapters/typed.mjs --jobs 6 --timeout 300000`

- compiler SHA-256: `a6f99fc20820d59a622e5a08deb5e631a3c1c1d7fd82f66e00010a0bd9d27f6d`
- base SHA-256: `b8c2734d45ec6b4ce70fee70ff06ef35e08fce885af8852d8eb77dbff020e946`
- runtime SHA-256: `a90a169e47fc28ddb93491e7c69eb6ecba188cf44ba153ad1daa77adce4b13e4`
- driver SHA-256: `84516e5d0a5b4dc899bf977ce5c8c0538e5ba6ec82bd55c8493d88a0edf5c1aa`
- nativeRuntime SHA-256: `400606bb7e351041c9658e818aa78696e00ec96fbb35ff8bbb890996bf9fdd91`
