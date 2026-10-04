# P45-002: scalar storage for exact-entry permission

Status: **deferred after the first screen; no production change**. The design
below preceded derivation and execution. The measured candidate remains an
isolated saved-runtime prototype, not a checked compiler candidate.

## Hypothesis

The runtime allocates `{code,args,used:false}` every time `invokeExact` grants
entry to a registered exact wrapper. No generated program can legitimately
observe this private object. Three lexical state slots, with their previous
values saved on the JavaScript stack, may remove allocation and property work
without changing the dispatch protocol. This applies to every admitted exact
call, independent of source names or algorithm families.

Phase43 profiles identify wrapper/dispatch costs, but do not isolate this token's
cost. The Phase44 known-call experiment changed invocation sites without removing
dispatch and was rejected. This experiment removes one specific private object;
no substantial gain is assumed, and a flat result ends the experiment promptly.

## Frozen intervention

The input compiler is Phase44 checked04, API
`0d3325425139c59ac81c4f1bca19fa09e9f977062aa3b202c0ef1c8c7b56b0ea`.
The unchanged runtime SHA-256 is
`e62cf92d8b600fdc2eb44029b1945f288c81bf878931f883a1b6f4fb5774aaeb`;
the core fragment is
`2276c6cf4be648421839a11e887913a1ac7fce7801e0ba9af86dc1b44fabd384`.

The [producer](../../selfhost/tools/performance/phase45/exact-state-v1.py) checks
both hashes and three unique exact text anchors. It changes only the private
state declaration, token consumption and installation/restoration. It emits a
new runtime and replaces the exact runtime prefix of each selected saved module.
Program suffixes remain byte-identical. It rejects name collisions and source
references to the old private token, rechecks consumed inputs, records hashes,
and refuses existing output directories. It never executes generated code.

The three slots represent either no permission (`code === null`) or the same
code identity, argument-vector identity and consumed bit as the original object.
Nested entries save and restore all three values; each nested invocation has
independent local saved values. The token is consumed before the inner callback
can read any argument. The unused-looking `code.call` read remains before
`f.env`; installation remains after both return. `finally` restores previous
state even when the inner call throws. No descriptor/host check, wrapper
signature, public argument copy, saturation branch, forcing operation or
trampoline behavior changes.

This experiment does not establish ownership of public argument or bounce
vectors, eliminate exact-entry checks, or authorize private direct calls.

## Derivation and protocol

From the repository root, use fresh directories:

```sh
python3 selfhost/tools/performance/phase45/exact-state-v1.py \
  --manifest selfhost/build/phase44/full-preparation04/manifest.json \
  --out selfhost/build/phase45/exact-state-derive01
```

The input must have extracted modules. `prototype-args.json` supplies `--from`
and all `--replace` arguments for the maintained `programs/prototype.py`; add the
Phase37 catalog and a fresh `--out` directory. This gives an explicitly unchecked
candidate bundle. The same-run baseline must contain unchanged checked04 modules
and the retained pinned TypeScript modules. Do not use Phase43 as the incremental
denominator. The standalone `runtime.mjs` also supports focused runtime controls.

Root serializes all qualification and execution under the maintained 1 GiB Node
heap / 2 GiB RSS policy. First syntax-check the derived runtime and modules, then
compare independent boundary traces with the unchanged runtime:

- Exact and nested exact calls, nullary calls and exceptions.
- An `env` getter that reenters before permission installation.
- An argument getter that reenters the same code with the same argument vector;
  it must not reuse consumed permission.
- Inner failure followed by another call; previous active/inactive/consumed
  states must be restored exactly.
- Own and prototype `.call` hooks, `.code`/`.env` getters, and mutable host hooks.
- Raw `.code`, `Reflect.apply`, constructor invocation, forged extra arguments,
  partial application and oversaturation; none acquires new permission.
- Public argument isolation and delayed constructor order in `test-apply.mjs`.

Retain actual exact-entry activation evidence separately from clean timing.
After semantic agreement, run one 60-second screen over lexer, Map128, BST64,
list512, records256 and closures256 with fresh checked04/prototype/TypeScript
rotations. Record all cases and failures; incomplete coverage supplies no gain.
If broadly flat or regressing, reject without full-corpus qualification. If
promising, confirm on additional varied inputs and inspect allocation separately;
only then consider a production runtime change and broader conformance.

## Decision and evidence

No timings or qualification results exist at design time. Promotion requires a
useful repeatable improvement with unchanged observable traces, not an isolated
best median. Preserve derivation receipts, unchanged inputs, failed controls and
clean timing. Report execution results in `implementation/phase45/`; compiler
speed, universal parity and arbitrary host-stack introspection are not measured
by this experiment.

## Recorded first screen and decision

The ordinary argument/trampoline `test-apply.mjs` checks and all **34 exact-entry
boundary observations** passed. The six-case screen completed **54 successful
samples** in **46.331 seconds**, using three fresh rounds per role under the
60-second protocol. The incremental baseline was unchanged Phase44 checked04;
the candidate replaced only its saved runtime prefix. Pinned TypeScript ran in
the same comparison.

| Point | Checked04 time / prototype time |
| --- | ---: |
| Lexer | 1.030890× |
| Map128 | 1.010409× |
| BST64 | 1.010679× |
| List512 | 0.999619× |
| Records256 | 1.008612× |
| Closures256 | 0.999574× |

A ratio above one favors the prototype. The observed movement is modest or flat,
with the largest median improvement in lexer. This short screen establishes
neither statistical significance nor a broad compiler-speed gain. No full-corpus
run or production qualification is justified at this point.

**Decision: defer.** Preserve the prototype and successful controls, keep the
production runtime unchanged, and prioritize the continuation backend, which
can remove whole private dispatch/continuation paths. This result does not prove
token allocation is free or rule out revisiting it after larger costs disappear.

Raw screen: `selfhost/build/phase45/runtime-exact01/report.json`, SHA-256
`35c934a7f4fa3d4f19882ed739d81817c0080305efc968f379a6375be1bd5eb4`.
Boundary controls: `selfhost/build/phase45/exact-controls01/report.json`.
Argument/trampoline checks: `selfhost/build/phase45/run-exact-apply01/`.
