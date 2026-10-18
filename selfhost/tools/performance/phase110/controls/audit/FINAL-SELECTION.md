# Final follow-up selection and heldouts

These scripts leave the existing `search.py`, `relink.py`, completed searches,
and frozen oracles unchanged. Preparation did not execute either new script or
any compiler/worker. Parent owns all selection execution and target runs.

`final-selection.py --protocol PROTOCOL --training TRAIN_REPORT --build BUILD_REPORT --out FRESH_SELECTION_JSON`
authenticates the protocol, training and compare-build receipts and recomputes
medians from the full five-round/seven-case matrix. Each challenger compares
with its original backend incumbent. Eligibility requires aggregate ratio
at most 0.97 and strictly lower equal-weight geometric mean in every round.
The lowest aggregate qualifying challenger wins; otherwise the incumbent
remains. Clang's selected winner then compares with QBE's selected winner under
the same gate, with QBE retained when inconclusive. The existing search's
winner fields do not decide this selection. Protocol input lists are general
enough for a separately frozen next version with additional candidates.

The output pins all training binaries and the selected worker objects,
origin receipts and runtime objects. Each runtime path is recovered from that
worker's recorded successful origin link command. Original build receipts did
not hash runtime.o, so the new runtime pin explicitly records current bytes
at selection time; it does not invent a historical object hash.

`final-heldout.py plan --selection SELECTION_JSON --prepared PREPARED_CONTROLS --out FRESH_PLAN_JSON --run-dir FRESH_RUN_DIRECTORY`
writes an inspectable command plan without executing it. Use the fresh
`selfhost/build/phase110/controls-final-heldout01` prepared corpus. Only the
reference, selected QBE winner, and selected global winner are included.
Commands compile one unchanged harness, link each cached worker object with
its own origin runtime.o, check complete semantics, and run the frozen eleven
cases for three alternating-order rounds with two repetitions per case.

`final-heldout.py run --plan PLAN_JSON` executes that exact plan in its fresh
run directory. Root should invoke it under the normal CPU3 execution guard.
It checks the complete oracle for every observation and retains stdout,
stderr, process clocks, worker clocks and all input/binary pins. It reports
equal-weight median worker ratios and every individual regression. Acceptance
requires semantic success plus aggregate reference ratio at most 1.03. It
never reranks, changes, or replaces the frozen winners based on heldouts.

All paths are structured argument arrays; neither script generates shell
algorithms or compiles source-function behavior. `plan` and selection are
read/hash/data processing only; `run` is the explicit execution boundary.
