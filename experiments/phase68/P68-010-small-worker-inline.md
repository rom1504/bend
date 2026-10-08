# P68-010: one local size cutoff for private C worker inlining

Registered before source application or target execution. This is a follow-on
candidate to P68-008; the broad diagnostic's result is not this policy's result.

Hypothesis: explicitly request inlining for admitted host C workers whose emitted
body has at most 4096 characters. Leave larger workers with ordinary INLINE.
The existing admission closure already excludes non-self recursion cycles and
lowers admitted self-tail calls to gotos. Change only the spelling of worker
prototypes/definitions, with no change to eligibility, ABI, evaluation, ownership,
runtime or device paths.

4096 is a round source-size budget, not an instruction-count model or a measured
optimum. Exact flat06 nc_body sizes: array cell1513, step2039, loop2320, bench1918;
numeric recurrence3664. It therefore includes the small numerical/container
worker chains that motivated the experiment. It excludes p46.loop4401/4407 and
Nat.read.trim265696. No names or benchmark families enter the policy.

This bounds the local body selected by the explicit inline request. It does not
bound transitive DAG expansion or whole-program machine bytes; shared callees
can be duplicated at many callers. Larger callers can contain eligible smaller
calls. Retain the bounded Clang qualification and inspect binary/C size and
compile time. A stronger transitive cost model is a separate change if needed.

First qualification: strict checked compiler equality, relevant ownership/error
controls, emitted attribute inventory, and same-plan numeric/array comparison
against exact flat06 and the broad diagnostic. Inspect the object to verify the
intended hot calls disappear, including at one/four threads as appropriate to
the parent's correctness plan. Broader families and native compiler build
workloads follow before production selection. No correctness or speedup claim
is attached to this registered source proposal.
