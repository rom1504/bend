# Applied Efq admission correction

The first native source06 controls passed, but most relevant functions remained
on the generic fallback. Scalar-region admitted only three unrelated comparison
functions. This was not evidence of a complete direct loop.

The actual checked-request diagnostic07 then recorded28 residual dynamic-call
refusals with head tag `Efq`, including `b2u`, `sel.go` and `mit`. The separate
Var-head refusal remains unsupported. Receipt:
`selfhost/build/phase111/p113-diagnostic-inspect07/report.json`, source SHA256
`0f14318aacaada64b0a17a07599b4fa6ae3f0a393133d9007ea4474ea84fecda`.

Checked matchers represent their final impossible miss as an application whose
head is Efq. The generic `p111_app` delegates this to `p111_slow_app`, which binds
and evaluates the callee before the argument. Its Efq evaluation invokes
`p111_rt_fail(state,4)`. Under the already-selected CPU runtime04 fail-stop
contract, `err_post` reaches `err_fail` and `_exit(1)` before any arguments run.

The optional application adapter recognizes exactly this residual head and
delegates to the existing direct Efq lowering. It retains the same failure call
and syntactic unreachable result, without evaluating arguments first. Every
other application uses the diagnostic original fallback unchanged. It neither
admits actual dynamic callees nor changes the device execution scope.

Compose `app-original.bend` and override `overrides-app-efq.bend`; the older
source06 and diagnostic-only method remain preserved. This fixes admission;
native semantic and structural gates still must demonstrate the intended path.
