#!/usr/bin/env python3
"""Stage documentation only; preserve exact before/after bytes and no release claim."""
from pathlib import Path
import difflib, hashlib, json, os, re

assert os.sched_getaffinity(0) == {0}
OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[4]
before, after = {}, {}

def edit(name, old, new):
    if name not in before:
        before[name] = (ROOT / name).read_text()
        after[name] = before[name]
    assert after[name].count(old) == 1, (name, old[:80])
    after[name] = after[name].replace(old, new)

def prepend(name, text):
    title = (ROOT / name).read_text().splitlines()[0] + '\n\n'
    edit(name, title, title + text + '\n\n')

pin = '059266225b77c8ca256ac6b25ee5c21449bab151'
oldpin = '018751270e800bc222a93dad7f257083ee53a5f7'

name = 'selfhost/README.md'
prepend(name, f'''The active source targets upstream `{pin}`.
The [Phase66 report](../implementation/phase66/README.md) records migration,
the selected compiler images, installed status and five separate metrics.
Use `npm run verify:release` to verify the installed package; a successful
candidate build alone does not qualify or install that candidate.

Phase66 changes namespace display, the Base/effect ABI and composite host
marshalling. The new Base needs fresh prepared artifacts. Optional annotation
products require their own exact-content qualification; see the
[Base contract](../implementation/phase66/base-host.md). The
[direct JavaScript guide](docs/direct-javascript.md) distinguishes direct
providers from the narrower legacy Node effect support.

## Historical Phase65 installed baseline''')
edit(name, '**Phase65 State10 is installed and verified.**', '**Phase65 State10 was installed and verified at that checkpoint.**')
edit(name, 'The current release combines\n', 'That release combines\n')
edit(name, 'Current installed-release\nmeasurements and qualification are in the\n[Phase65 State10 report](../implementation/phase65/state10-results.md).', 'Current migration and installed-image\nqualification are in the [Phase66 report](../implementation/phase66/README.md).')
edit(name, '[Phase64 results](../implementation/phase64/state09-results.md) for the\ninstalled image;', '[Phase66 report](../implementation/phase66/README.md) for current image status;')
edit(name, f'The pin remains `{oldpin}`, after Bend 2.0.34.', f'The active pin is `{pin}`; dated campaigns retain their original pins.')

name = 'selfhost/CONFORMANCE.md'
prepend(name, f'''## Phase66 migration qualification

The active target is `{pin}`. The
[Phase66 report](../implementation/phase66/README.md) is the current gate index;
the historical results below retain their original source, image and reference
identities. Full qualification requires checked B1, a genuine emitted B2,
own-source acceptance, reproduction and installed-interface gates separately.

The new reference inventory has 1,587 fixtures (83 added, 38 modified, 9 removed
versus the old 1,513), including 1,170 JS-eligible fixtures. Static eligibility
does not imply a passing execution. Parse, check, declaration trust, backend
execution, explicit unsupported operations and timeouts retain separate outcomes.
See the [inventory and controls](../implementation/phase66/controls.md).

The migrated legacy Node runtime passed 34 focused controls: runtime-unit,
mocked-network and three real loopback cases remain separately classified in
[the backend report](../implementation/phase66/backend.md). This does not replace
Bend-source emission controls or the full backend inventory. Four timed sends
(`TCP.try_send`, `TCP.try_send_bytes`, `UDP.try_send_to`,
`UDP.try_send_bytes_to`) explicitly refuse before sending; asynchronous TCP
write errors also refuse when the exact unsent suffix is unknowable.

Compiler latency, emitted-program runtime and source complexity are separate
from conformance. Old TypeScript ratios below are not new-reference results.''')
edit(name, '## Current Phase65 qualification', '## Historical Phase65 qualification')
edit(name, 'frame4 decoder. It is installed and verified.', 'frame4 decoder. It was installed and verified at that checkpoint.')
edit(name, 'The current compiler targets upstream\n', 'The compiler at that historical checkpoint targets upstream\n')

name = 'selfhost/docs/ARCHITECTURE.md'
a = '**Current overview:** Phase65 State10 is installed and verified.'
b = f'''**Current source target:** `{pin}`.
The [Phase66 report](../../implementation/phase66/README.md) identifies selected
and installed images and closed qualification gates. Source architecture alone
does not establish release readiness.'''
edit(name, a, b)
edit(name, '[qualified results](../../implementation/phase65/state10-results.md) for the', '[migration results](../../implementation/phase66/README.md) for the')
edit(name, '## Phase65 installed integration', '''## Phase66 boundary changes

Internal book keys, term identities and native function/constructor IDs retain
raw `namespace:name` spelling. External export/effect names, constructor tags
and diagnostics use `name_key`, replacing only the first colon with a dot.
Display text is not a unique structural identity or lookup key.

Direct host converters share a LIFO work queue for composite ADT/Array values.
Arrays are updated in place; ADTs with converted fields are copied; unchanged
ADTs retain identity. Immediate scalar/function conversion order and bounded
type planning remain explicit contracts. Pure-main display embeds constructor
names in its mixed numeric/string descriptor.

Direct IO requests carry an effect tag, arguments and continuation. Missing
registrations fail when the request executes; IO.OP matching rejects requests
as runtime fail-stop. The exact new Base maps to 35 vendored JS providers.
Legacy Node effects use their separate runtime and explicitly refuse four timed
sends and ambiguous TCP write failures. The [host report](../../implementation/phase66/host-runtime.md)
and [backend report](../../implementation/phase66/backend.md) bind the distinct
candidate and execution scopes. Normal compilation still runs Bend algorithms.

## Historical Phase65 installed integration''')
edit(name, 'Phase65 State10 passes the [compiler qualification]', 'Phase65 State10 passed the [compiler qualification]')
edit(name, 'The compiler targets upstream\n', 'At the historical Phase48 checkpoint, the compiler targeted upstream\n')
edit(name, 'The development `equality` profile is a compatibility name for an explicit\nchecked-B1 derivative. Version6 binds the new Base equality dependency chain,', '''The development `checked` profile preserves the upstream-produced checked API.
An `equality` image is a separately identified derivative and is admitted only
by a profile matching its exact runtime, Base dependency bodies and export ABI.
The new upstream uses unary deferred closure calls. The historical array-tail
rewrite cannot be reused by merely refreshing hashes. Use the actual selected
profile and controls recorded in [the maintained workflow](../../docs/PHASE5_DEVELOPMENT.md)
and [Phase66 bootstrap report](../../implementation/phase66/bootstrap.md).
Raw checked, selected derivative and genuine self-emitted images remain distinct.
Phase66 profile7 retains reviewed native String equality and literal choices,
and disables the historical array-tail branch rewrite for the new unary
closure protocol. Its focused profile controls do not replace full conformance.

The historical version6 profile binds its old Base equality dependency chain,''')

name = 'selfhost/docs/direct-javascript.md'
start = after.get(name, (ROOT/name).read_text()).index('## Choose the JavaScript contract')
old = (ROOT/name).read_text()[len('# Direct JavaScript output\n\n'):start]
edit(name, old, f'''Direct JavaScript is the default for emitted programs, callable libraries and
`--run`. `--legacy-js` retains the mutable descriptor interface. The active
reference is `{pin}`; current image identities,
qualification and measurements are in the [Phase66 report](../../implementation/phase66/README.md).
Historical [Phase55 results](../../implementation/phase55/README.md) and
[Phase53 timings](../../implementation/phase53/results.md) apply only to their
recorded images and emitted bytes. They are not current speed or coverage claims.

''')
edit(name, f'[`{oldpin}`](https://github.com/rom1504/bend/tree/{oldpin})', f'[`{pin}`](https://github.com/bendlang/bend/tree/{pin})')
edit(name, 'Export names are resolved source names in the loading book.', 'Export names use `name_key`: the first internal namespace colon becomes a dot.\nInternal book lookups retain their raw names.')
edit(name, 'and definitions whose original whole type is `IO<A>`.', 'and definitions whose original whole type normalizes to an IO-headed type.')
edit(name, '''Foreign JavaScript sources register typed `$FFI` operations with arguments and a
continuation. Registry reads, argument evaluation, conversions, mutations,
failures, and callback order remain observable parts of this contract. Missing
sources, invalid source identifiers, and missing registrations fail explicitly;
there is no delegation to legacy execution or the TypeScript implementation.

The 37 pinned Base JS effect sources are''', '''Foreign JavaScript sources register an effect tag with its run function.
Requests carry `{ $: effectName, args, kont }`; there is no `$FFI` wrapper or
registration-time `need` callback. Missing registration fails when a request
executes, after any earlier IO output; duplicate registration is refused.
Argument evaluation, conversion, mutation and callback order remain observable.
Missing sources and invalid source identifiers fail explicitly, with no legacy
or TypeScript fallback. Matching an IO.OP request as an ordinary Emit/Halt value
fails at runtime.

The 35 pinned Base JS effect sources are''')
edit(name, 'Foreign source code must be trusted by the caller.\n', '''Foreign source code must be trusted by the caller.

Legacy Node effects are a separate compatibility implementation. Channels return
the new Result/Maybe shapes and `try_` operations wrap results in Poll. TCP
receive returns `Done{Some{data}}` or `Done{None{}}` at peer EOF; UDP returns a
datagram, including empty payloads. Legacy timed sends `TCP.try_send`,
`TCP.try_send_bytes`, `UDP.try_send_to` and `UDP.try_send_bytes_to` refuse before
host writes because queued Node writes cannot be cancelled safely. Asynchronous
TCP write errors refuse when Node cannot recover the exact unsent suffix.
Use the [backend report](../../implementation/phase66/backend.md) for the
34-control scope and remaining source-level coverage; direct and legacy effect
coverage are not interchangeable.
''')
edit(name, 'Constructors use resolved tags and named fields.', 'Constructors use displayed `name_key` tags and named fields.')
edit(name, '''error timing matter alongside complete final values. Some non-tail recursion and
branching host conversions still consume native JS stack space.''', '''error timing matter alongside complete final values. Composite ADT/Array value
conversion uses one shared LIFO work queue instead of recursive composite calls.
Converted ADTs are copied and unchanged ADTs retain identity; scalar and function
work follows the pinned order. Type planning still has the explicit bounds below.
See [converter qualification](../../implementation/phase66/host-runtime.md).''')
edit(name, 'Installed Phase55 host02 retains the following bounds;', 'The retained analysis limits are the following;')
edit(name, 'Current host02 identities and fresh qualification are in the\n[Phase55 report](../../implementation/phase55/README.md).', 'Current image identities and qualification are in the\n[Phase66 report](../../implementation/phase66/README.md).')
edit(name, 'This is a checked B1 release, not a new self-emitted fixed point.', 'Installed checked B1 and separately qualified genuine B2/B3 have distinct\nlineages; consult the current report for completed gates.')

name = 'docs/BEND-IN-BEND.md'
edit(name, '[Phase65 State10](../implementation/phase65/state10-results.md) is installed and\nverified.', f'''The active source targets upstream `{pin}`.
Use the [Phase66 report](../implementation/phase66/README.md) for selected and
installed images, five-metric results and open gates. The current direct/legacy
effect differences are in the [direct guide](../selfhost/docs/direct-javascript.md).
Optional products for the updated Base require independent qualification; old
prepared data or benchmark ratios do not transfer by changing a pin.

## Historical release results: Phase65

[Phase65 State10](../implementation/phase65/state10-results.md) was installed and
verified at that checkpoint.''')
edit(name, 'not the installed Phase65 release.', 'not current migration measurements.')
edit(name, f'git clone https://github.com/bendlang/bend.git .bootstrap/upstream-phase23\ngit -C .bootstrap/upstream-phase23 checkout --detach {oldpin}', f'git clone https://github.com/bendlang/bend.git .bootstrap/upstream-phase66\ngit -C .bootstrap/upstream-phase66 checkout --detach {pin}')
edit(name, '[Phase61 results](../implementation/phase61/state08-results.md) record current\nqualification and installation status.', '[Phase66 report](../implementation/phase66/README.md) records current\nqualification and installation status.')
a = 'The equality\nprofile recognizes the reviewed current and historical contracts'
i = after[name].index(a); j = after[name].index('\n\nThe [release manifest]', i)
edit(name, after[name][i:j], '''The equality
profile is a separately identified checked-image derivative. It must match the
actual upstream runtime, dependency bodies and export ABI; see the selected
profile and its controls in [the workflow guide](PHASE5_DEVELOPMENT.md).
The new unary deferred-call protocol uses profile7 native String equality
and literal choices without the historical array-tail branch rewrite. Historical profiles and their original evidence remain
replayable; an old profile number is not a migration qualification.''')
edit(name, 'BEND_BASE="$PWD/.bootstrap/upstream-phase23/bend2/base.bend"', 'BEND_BASE="$PWD/.bootstrap/upstream-phase66/bend2/base.bend"')
edit(name, '## Current release boundary\n\nUse the [Phase61 results]', '''## Current release boundary

Use the [Phase66 report](../implementation/phase66/README.md),
[current conformance record](../selfhost/CONFORMANCE.md) and installed
`dist/release.json` for current image identities and qualification. Run
`npm run verify:release` from `selfhost/` to check the installed closure.

### Historical Phase61 release boundary

The [Phase61 results]''')
edit(name, 'for installed state08\'s\nidentities and qualification.', 'record state08\'s\nidentities and qualification.')

name = 'docs/self_hosted/prepared-base-artifacts.md'
prepend(name, '''## Phase66 Base migration

The active Base has SHA256
`99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`.
Mandatory prepared state binds these exact bytes and the selected compiler;
an old Base frame is not relabeled. The initial migration keeps optional
annotations disabled for this Base. Their permission may change only after
fresh complete-product, whole-module, owned-route and custom-Base controls;
the [Phase66 Base report](../../implementation/phase66/base-host.md) records
that separate qualification and the actual selected permission.

From the repository root, explicit preparation is
`node selfhost/tools/typed-driver.mjs --prepare-base` with the intended image
and Base. Ordinary inspection uses `backendProducts:false` on a cache miss and
does not implicitly create an optional sidecar. While new-Base permission is
absent, explicit preparation also uses ordinary annotation.

## Historical Phase65 baseline''')
edit(name, '**Phase65 State10 is installed and verified.**', '**Phase65 State10 was installed and verified at that checkpoint.**')
edit(name, '## Phase65 installed integration', '## Historical Phase65 installed integration')
edit(name, '**State10 combines H2 and H6 and is installed and verified.**', '**State10 combined H2 and H6 and was installed and verified.**')

name = 'docs/self_hosted/compiler-image-generation.md'
edit(name, 'Installed **Phase61 state08** uses a checked B1 API.', '''The [Phase66 report](../../implementation/phase66/README.md) identifies the
actual checked parent, selected derivative, genuine emitted B2 and installed
package independently. New-upstream generation needs the exact new Base/runtime
and its qualified image profile. A raw checked build is not a self-emission or
release result; failed/interrupted receipts retain their original identities.

## Historical Phase61 image qualification

Installed **Phase61 state08** used a checked B1 API.''')
edit(name, '## Current changes: Phase61', '## Retained changes: Phase61')
edit(name, '## Current qualification: Phase61', '## Historical qualification: Phase61')
edit(name, 'The [State08 results](../../implementation/phase61/state08-results.md) identify\nthe current generation, reproduction and fresh-check receipts.', 'The [Phase66 report](../../implementation/phase66/README.md) identifies current\ngeneration, reproduction and fresh-check receipts as they close.')
edit(name, '## Current compiler-request measurements', '## Historical compiler-request measurements: Phase61')
edit(name, 'types, but reports `proofTrust: failed` and `kernelChecked: false`: all 3,192\ndefinitions in the selected source remain explicitly unsafe.', 'types while declaration trust remains a separate verdict. Phase61 reported\n`proofTrust: failed` and `kernelChecked: false` for all 3,192 explicitly unsafe\ndefinitions; each later source needs its own counted and checked result.')

name = 'docs/self_hosted/compiler-request-pipeline.md'
prepend(name, '''## Phase66 migration boundary

The [Phase66 report](../../implementation/phase66/README.md) owns current image
qualification and five separate metrics. The existing prepared world, lowering
plan and frame4 transport remain distinct from the changed namespace/effect ABI.
New-Base mandatory state uses fresh identities; optional annotations require
their own content permission and qualification. See the
[artifact contract](prepared-base-artifacts.md#phase66-base-migration).

## Historical Phase65 result''')
edit(name, '**Phase65 State10 is installed and verified.**', '**Phase65 State10 was installed and verified at that checkpoint.**')
a = '**One field conversion plan.'
i = after[name].index(a); j = after[name].index('\n## ', i)
old = after[name][i:j]
edit(name, old, '''**One field conversion plan.** In
[host.bend](../../selfhost/src/back/js/direct/host.bend), each constructor's live
field converter is computed once. Phase64 used the immutable `JDHostFields`
plan for tail selection and field emission. Phase66 uses the same plan to decide
whether to copy an ADT and emit scalar assignments or queued composite work.
The last-self-recursive-field selection and its helpers are removed. Erased
fields remain erased; bounded type planning and exhausted-telescope refusals
remain explicit. Composite ADT/Array value traversal shares a LIFO work queue.
See the [Phase66 host report](../../implementation/phase66/host-runtime.md) for
order, aliasing and qualification boundaries. Phase64's 11-line reduction
against State06 remains a dated source result, separate from Phase66 counts.
''')

edit(name, 'Select the final self-recursive field and produce field output from the same plan.', 'Decide ADT copying and emit immediate scalar/function conversion or queued composite work from the same plan.')

name = 'docs/self_hosted/README.md'
prepend(name, f'''The active source targets upstream `{pin}`.
The [Phase66 report](../../implementation/phase66/README.md) is the current
status and five-metric index. Read [the compiler guide](../BEND-IN-BEND.md) for
usage, the [direct guide](../../selfhost/docs/direct-javascript.md) for the
new namespace/effect interfaces, and [prepared Base artifacts](prepared-base-artifacts.md)
for new-Base invalidation and optional-product qualification.

## Historical Phase64 installed baseline''')
edit(name, '**Phase64 State09 is installed and verified.**', '**Phase64 State09 was installed and verified at that checkpoint.**')

name = 'docs/self_hosted/backend-boundaries.md'
edit(name, 'Phase56 string01 is installed, retaining the direct JavaScript default introduced\nin Phase53. Explicit legacy JavaScript and native targets remain available.', '''The [Phase66 report](../../implementation/phase66/README.md) records current
qualification and installed-image status. Direct JavaScript remains the default;
explicit legacy JavaScript and native targets retain separate contracts.
Internal namespace identities remain raw; public names use first-colon dotted
display. The direct effect providers and legacy Node effects have different
capability boundaries, including explicit legacy timed-send refusals.''')
edit(name, '[Phase56 report](../../implementation/phase56/README.md) for interfaces and tested\nscope.', '[Phase66 backend report](../../implementation/phase66/backend.md) for interfaces\nand tested scope.')
edit(name, 'Phase54\'s shared-helper extraction', 'Historically, Phase54\'s shared-helper extraction')

name = 'docs/self_hosted/compiler-allocation.md'
i = (ROOT/name).read_text().index('Host conversion clones')
text = (ROOT/name).read_text(); j = text.index('\n\n', i)
edit(name, text[i:j], '''At the Phase58 checkpoint, host conversion clones used
`jd_host_marshal_field` with `last=false`, retaining quoted keys except
`__proto__`. That historical allocation result does not describe Phase66
conversion emission. The current
[host converter](../../selfhost/src/back/js/direct/host.bend) copies an ADT
with converted fields using `{...v}`, then assigns scalar conversions or queues
composite work. An unchanged ADT retains identity. These assignments do not use
the constructor-literal field-key rule above; see
[Phase66 converter qualification](../../implementation/phase66/host-runtime.md).''')

sha = lambda data: hashlib.sha256(data).hexdigest()
rows, patch = [], []
for name in sorted(after):
    a, b = before[name].encode(), after[name].encode()
    assert a != b
    for prefix, value in [('before-v1', a), ('candidate-v1', b)]:
        path = OUT / prefix / name
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open('xb') as stream: stream.write(value)
    outside = []; fenced = False
    for line in after[name].splitlines():
        if line.startswith('```'): fenced = not fenced; continue
        if not fenced: outside.append(line)
    links = re.findall(r'\]\(([^)]+)\)', '\n'.join(outside))
    for link in links:
        if link.startswith(('http:', 'https:', '#')) or ' ' in link: continue
        file = link.split('#', 1)[0]
        assert not file or (ROOT / name).parent.joinpath(file).exists(), (name, link)
    rows.append({'path': name, 'beforeSha256': sha(a), 'afterSha256': sha(b),
                 'beforeBytes': len(a), 'afterBytes': len(b),
                 'candidate': str((OUT/'candidate-v1'/name).relative_to(ROOT))})
    patch += list(difflib.unified_diff(before[name].splitlines(True), after[name].splitlines(True),
                                     fromfile='a/'+name, tofile='b/'+name))
raw = ''.join(patch).encode()
with (OUT/'documentation-v1.patch').open('xb') as f: f.write(raw)
manifest = {'kind': 'phase66-active-documentation-migration', 'version': 1,
    'status': 'staged-not-applied', 'upstream': pin, 'patchSha256': sha(raw), 'files': rows,
    'producerSha256': sha(Path(__file__).read_bytes()),
    'scope': 'Active source contract and current-report pointers; historical pins and ratios remain dated.',
    'releaseClaim': False, 'excludedOwnedFile': 'docs/PHASE5_DEVELOPMENT.md',
    'pending': ['Final selected image qualification (profile7 focused controls have passed)', 'New-Base optional product permission result',
                'Final five-metric reports and release verification', 'Final source simplicity census']}
with (OUT/'documentation-v1.json').open('x') as f: json.dump(manifest, f, indent=2); f.write('\n')
print(json.dumps({'files':len(rows),'patchSha256':sha(raw),'status':manifest['status']}))
