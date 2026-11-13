# Scoped frame API acquisition without production edits

The new `scoped-frames-hook.bend` contains exactly the four replacement
definitions from the integration patch. Supply it only at API preparation:

```text
--module selfhost/tests/phase192/scoped-frames-hook.bend
--replace x185_function_setup
--replace x185_late_stmts
--replace x185_late_yes
--replace x185_late_no
```

The parent canonical inventory must retain the following new dependency
modules/roots before extracting the x86 source closure (paths below are
relative to `selfhost`, as required by `prepare-experiment.py`):

```text
--module tests/phase192/scoped-frames-experimental.bend
--module tests/phase192/scoped-frames-controls.bend
--root-symbol x192hf_function_setup
--root-symbol p192hf_controls
```

Include the chosen H module version and its `x192h_public` root as usual.
Keep the canonical originals in that inventory; the four replacements are
applied later by `prepare-api.py --replace`. Do not add the hook as a normal
inventory module or apply the production patch as well.

For sentinel acquisition, append the immutable Phase186 stacked-frame fixture
and `recursive-worker-controls-v2.bend` instead of the original worker fixture.
Export `p192hc_controls`, `p192hc_emit` and `p192hf_controls` along with the
normal typed-machine consumers. The v2 fixture invokes
`x192hf_function_setup(...,ids,x192hf_case_buffers(cases,0))` directly while
preserving both original test symbols and the C observer ABI.

Coverage limit: the inherited mode0/mode1 fixtures push frames only from the
owner's ordinary scratch buffer. Their continuation bodies only perform
arithmetic and return. They therefore test scoped-worker integration and
sentinel preservation, but do not by themselves establish that a case-buffer
frame expansion executed. Require an additional admitted case that pushes a
frame before reentering the owner, and confirm an actual scoped site in its
emitted code, before claiming that additional runtime boundary covered.

No compiler/target jobs were run when preparing these files. Existing fixtures
and the frozen original H module remain unchanged.
