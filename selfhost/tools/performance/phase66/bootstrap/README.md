# Phase66 checked bootstrap compatibility

This proposal targets upstream `059266225b77c8ca256ac6b25ee5c21449bab151`.
`candidate.json` binds each before/after source and the isolated patch. No old
bootstrap snapshot, reference checkout, or equality profile is rewritten.

The upstream JavaScript emitter stopped exporting `io_base`. Its semantic query
is small: make canonical Base `IO` opaque while weak-head normalizing the type,
then inspect its application head. The bootstrap now expresses that exact query
using public language operations. It still excludes all IO-headed types,
including zero or multiple arguments, as well as Base, template, unfilled, and
foreign definitions. `js_lib` initializes its own private `FL` context; the
bootstrap neither constructs nor mutates that context.

Only active checked workflow and component defaults move to the new reference.
Historical untyped bootstrap tools retain their original recipes. Installed
release verification admits 35 effect files for this exact new pin and retains
37 for older releases. Provider bytes, manifest, and driver resolution belong
to the separate Base/effect migration proposal.

## Preserved first checked build

After the four-file proposal and other reviewed migration patches are applied,
run the following commands through the root's serial resource guard (Node24,
CPU3, stack4096 KiB, heap1024 MiB; no overlapping target work):

```sh
node --stack-size=4096 --max-old-space-size=1024 tools/performance/phase66/bootstrap/io-controls.mjs .bootstrap/upstream-phase66 tools/stage0-library.mjs build/phase66/bootstrap-io-controls01
node --stack-size=4096 --max-old-space-size=1024 tools/development/workflow.mjs run tools/performance/phase66/bootstrap/checked-b1-config.json build/phase66/checked-b1-01
```

Commands use `selfhost/` as the working directory. The configuration explicitly
selects `profile: "checked"`. The workflow freezes production sources and host
tools, bootstraps from the exact upstream reference, verifies all provenance,
then runs the maintained default focused selection in strict mode. A later
frontend failure does not erase the genuine checked API or its bootstrap report;
inspect build and validation outcomes separately. The initial configuration
uses the existing phase2 focused selection unless the root supplies a reviewed
migration selection. Full conformance is a later integration gate.

The first command checks the source-bound local IO query against both real
upstream normalization and the exact private upstream query, with independent
expected results and unchanged-book checks. It is a semantic operation control,
not a claim that the synthetic books were parsed or type-checked.

## Qualified equality adapter

Current development recipes explicitly select `profile: "equality"` after the
profile 7 controls and ordinary host controls passed. Profiles 1–6 remain
unchanged. The new
upstream runtime represents deferred closure calls with a unary argument
(`r.f(r.x)`); the older leaf-choice derivative emits argument arrays and assumes
spread invocation. Merely substituting new hashes into that derivative is
incorrect. Actual raw B1 overflowed while comparing source text, and a bounded
trace retained the original `String.cmp` / `String.cmp.fin` stack. Profile 7
retains the guarded primitive equality shortcut and literal-choice transform;
it excludes the older leaf-tail transform. All six historical profiles replay
exactly. The 151,084 primitive pairs, fallback/choice/refusal controls and the
previously failing ordinary load are recorded in the
[implementation report](../../../../../implementation/phase66/bootstrap.md).
This qualification does not substitute for fresh B2 or full conformance gates.

## Later genuine B2

The Phase66 successor in `prepare-bootstrap.py` consumes the
new closed checked attempt and its actual bootstrap report. It exposes
only source-declared compiler roots, emit a distinct image with the selected
compiler, compare complete emitted modules against the exact checked B1, and
run the ordinary driver against that image. Source qualification, compiler ABI,
new Base cache identity, and the self-hosted JavaScript runtime must all agree.
The Phase65 controller is historical and cannot be replayed with replacement
pins or substituted image hashes. Concrete B2 commands depend on the qualified
B1 attempt and the measurement owner's Phase66 preparation plan.
