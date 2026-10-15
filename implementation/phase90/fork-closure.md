# Full-source flag propagation: attribution and indexed candidate

The completed `native01-late-self03` diagnostic passes the normal/stopped Map
controls, exact input identities and zero-loss gates. Its stopped full-source
capture has11,249 samples at16ms over180s. This is an intentionally incomplete
compiler invocation, not a successful self-compilation. Growing-prefix append
has disappeared from the late window after the five table-builder changes.
The remaining late native sites are string-equality ownership and `nb_contains`.
Native tail calls erase the outer logical caller, so those physical samples
alone cannot identify which membership pass owns the work.

An independent timed V8 capture of genuine JS B2 `87346402…` compiling frozen
source `74b390d3…` supplies that missing caller. `js-profile-self02` retains the
24,930,850-byte CPU profile, SHA256
`5661f6c7aea8972c6cdbde81b12a0e7bab0f5c9799901ee2898e711d4f194123`.
The profiler worker stops and flushes while the compiler's main thread is busy;
the controlled busy-loop test proves this happens before main-thread completion.
The real target is deliberately terminated only after the profile is saved.
It is not a completed C emission. Window summaries weight actual `timeDeltas`,
not sample count multiplied by the requested interval.

At about47s the visible caller chain becomes `nb_emit → nb_fork_close →
nb_fork_step → nb_reaches → nb_contains`. In45–60s, `nb_contains` accounts for
84.03% of sampled time and GC11.97%. Deep recursive membership truncates many
ancestor stacks: the profile does not establish that every membership sample
belongs to fork closure. Each late second nevertheless has almost continuous
membership execution, with the fork-closure chain periodically visible.

The pass propagates possible parallel execution through the call graph. Variable
applications conservatively seed this property even without explicit parallel
syntax. Repeated linear searches of the growing root list are therefore relevant
to compiler self-compilation as well as explicitly parallel programs.

The isolated candidate reuses the existing exact-name KDef trie as a membership
index. It preserves the ordered root list separately, including initial duplicate
roots, same-pass updates, root-count convergence, finite fuel, and every emitted
flag bit. Hash collisions still require exact string equality. It adds57 Bend
lines and no datatype. An independent source audit found no typed semantic
mismatch. Whole-program rescans and repeated call lists remain; this is not yet
a worklist algorithm or a claim of linear total closure cost.

The46 controls retain complete roots, flags, prefixed output, original segments
and inputs, including cycles, duplicate names, empty/Unicode names, fuel limits,
forward/reverse chains and the FNV collision `costarring`/`liquid`. Two fixture
acquisitions failed upstream C emission with `an arity over247`. Both failures
remain under `fork-controls01` and `fork-controls02`; the compiler algorithm was
not changed to accommodate them. The second fixture still constructed46 ten-word
products in one expression, exposing upstream's flattened continuation limit.
The replacement fixture bounds that construction rather than weakening tests.

`fork-controls03` passes all46 cases: legacy and indexed functions produce the
same complete stdout in both JS and native execution, and every field matches
the independent Python oracle. Checked acquisition/build/run of both controls
takes about17s. This validates full products, not merely final root counts.

Source candidate `d8a94ce9…` has a replayable13-edit forward/inverse derivation
back to original source `4584cf08…`. Full upstream load/check/JS-and-C emission
passes in88.178s, with zero holes and1,238,601,728 bytes peak RSS. Its raw JS
sibling passes live/cached Small and Map against all four complete-C oracles.
The raw sibling's self-source request hits120.082s without C, at841,760,768 bytes
RSS. Its ordinary Map request is also much slower than genuine JS B2, so it is
not used as the principal full-source fast loop.

The experimental canonical integration uses descriptive `nb_*` names and ordinary
`String.eq`, retaining all existing APIs (+81 lines, no datatype). Checked
compiler05 passes36 frontend witnesses and emits a genuine B2; its eight driver
comparisons pass. This is still a candidate, not an installed release.

The timed `js-profile-self03` diagnostic establishes that this B2 progresses past
fork closure:45–50s is indexed propagation,50–55s reaches flag emission, and
55–60s reaches line formatting. Linear `nb_contains` is no longer the late stall.
GC occupies85.82% of55–60s under the1GiB heap cap. This capture stops intentionally
at about60s; it proves progress, not completed self-emission or a clean speedup.
The trace has17 negative sampling deltas totaling143 microseconds. The initial
analysis rejects those; the retained v2 analysis clamps cumulative timestamps
monotonically, attributing no time twice. Raw samples remain unchanged.

A separate source-demand audit finds eager Bend Boolean arguments. The frozen
fixture's optional Python comparison counts assumed short circuiting; those
counts do not model target work and are explicitly corrected separately. The
46 full expected products remain valid. An unexecuted lazy indexed variant uses
explicit choices to avoid reference searches for known roots and stop after a
matching reference. It is not part of compiler05 or any claimed result.

Raw paths are under `selfhost/build/phase90/`; methods are in
`selfhost/tools/performance/phase90/{profiling,observation,js-sibling}`. These
newer results are not in the earlier evidence01 capsule and must be sealed in a
subsequent capsule before removing any raw files.
