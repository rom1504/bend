# Phase131 legacy registry identity-scan probe

Unexecuted candidate against Phase130 source SHA256
`995d6b4bf14963debb9a810de2ed941c3cd30a71fc34a156d96b1adbd1b06bdd`.
No production selection or verifier change.

Compose `plan.bend` by replacing exactly `p112c_add` and adding the two new
`p131rg_` declarations. Append `controls.bend`; export `p131rg_controls` for the
existing checked API and execute it only in root's guarded target lane. No
performance or successful checking is claimed by writing these sources.

The original `p112c_scan` can transform a body only after `p112c_frame` finds an
exact `N111Call` of `p111_rt_frame`. If no such call occurs at any depth,
`p112c_scan(body,index,ready,site)` is structurally
`P112FusionBody{body,0,site}`. Induction uses `p112f_prepend` and
`p112f_scan_rest`; no readiness, index, arity or input-validity assumption is
needed for that implication. A symbolic near-match is not a frame. A malformed
exact frame conservatively takes the original path.

The candidate replaces only this identity scan. The registry's candidate
filter, round count, immutable previous-ready set, fusion plan, worker scan,
admission, ranks, insertion order, symbols, forwarding and final verifier are
unchanged. It does **not** assume a ready direct function authorizes skipping
legacy admission.

Fourteen finite controls exercise the classifier, nested branches, tail frames,
site metadata and emitter observations. Emitter observations are not full
structural equality: the integration gate must compare entire emitted QBE on
ordinary compiler requests, including a real successful-fusion workload.

Cost risk: the guard adds one traversal to bodies containing frames, and is
repeated on each still-unready candidate/round. Reject on neutral/regressed total
registry cost. If the discriminator wins, the next implementation should carry
the fact out of the existing cleanliness/candidate walk rather than add another
general cache. This is a cost probe; profile coverage does not support a parity
claim. See `research/phase131/strategy.md` for measured historical context.
