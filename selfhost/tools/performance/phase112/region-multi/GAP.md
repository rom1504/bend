# Optional pure statements between frame and call arguments

The qualified multi-wide ray output retains an ordinary blocked pattern in
`$direct.isect.t`: frame with two captures, numeric copies of 1 and 1000, argument
stores, then a call to the already private `$direct.fl`. The original exact
target matcher expects the argument stores immediately after the frame.
`$direct.sx` has the same form. These are source/read-only observations from the
existing output, not a measured gain from this extension.

Append `gap-model.bend` and `gap.bend`, then override only `p112c_try_frame` using
`gap-entry.bend`. `gap-modules01.json` pins this optional profile and its frozen
base/wide dependencies. No qualified base source is modified.

The wrapper splits at most 32 numeric `N111Set` or `N111Bin` statements from the
start of the frame's suffix. Both output types must be U32/U64; values must be
locals or constants. State, canonical scratch and all eight possible generated
scratch names are rejected as either destinations or operand locals. The
original verifier remains responsible for the full local type environment.
Calls, memory access, pointer instructions and further frames do not enter the
gap. The unchanged wide target gate must still accept the entire remaining
ordered-store/jump suffix and the original continuation.

On success, the existing pinned fusion helper first builds its usual result.
The original gap statements are inserted after the capture snapshots and zero
frame-result assignment, and before all argument snapshots. In execution order:

1. Save every capture value at its original capture point.
2. Preserve the frame operation's observable zero result.
3. Execute the original pure gap in its original order.
4. Snapshot call arguments, call the private callee, and bind the continuation.

Thus a gap may redefine a captured scalar local without changing the captured
value, and may read the zero frame result. No owning helper is moved or removed.
The splice refuses an unexpectedly short generated prefix. The prefix-length
argument depends on the exact pinned `p112f_fused` declaration and must not be
transferred to an arbitrary replacement helper.

Global limits remain eight sites, 128 statements per copied continuation and
six immutable ranks, with the optional 32 captures/arguments. Unsupported outer
frames remain generic even when a later inner frame can fuse. In particular,
`nearest` has an outer frame followed by `keep` and another frame; this extension
does not justify admitting that outer sequence or the whole function.

Independent controls are prepared by the ABI agent. `diagnose.mjs` is a separate
authenticated host report using checked Bend preparation, lowering, verification
and planner predicates. It reports actual first admission ranks and clearly
separates hypothetical probes against the final ready set. It neither emits a
native program nor changes the optimization. Run it only in the coordinator's
guarded target lane with the listed read-only exports.
