# Development entry points

Compiler development uses the maintained [workflow](../../../docs/self_hosted/workflow.md)
and [`tools/build`](../build/README.md). `npm run dev -- ...` and
`npm run bootstrap -- ...` both invoke checked B1 acquisition with explicit source,
fresh output, upstream checkout and JavaScript engine arguments. Native builds,
genuine JS/native bootstrap generations, qualification and installation remain
separate operations with their own receipts.

`npm run verify -- --out FRESH_BUILD_DIRECTORY --upstream PINNED_CHECKOUT
--engine JS_ENGINE` retains the component checker, diagnostics, ownership,
loader, normalization, index, runtime and harness gates. It assembles the current
source and acquires B1 through the maintained build tool. Run compiler jobs under
the documented build-retention guard; this command never overwrites a previous
component report or installs a compiler.

For another component run on the identical source, replace `--engine` with
`--api-receipt CHECKED_B1_REPORT`. The runner verifies the source, image, exact
export roots and all acquisition inputs before reuse. It runs every independent
component gate and reports all failures after successful acquisition.

The former attempt/equality-derived release framework is historical. Recover its
exact source and receipts through the [history tools](../history/README.md),
rather than combining its release schemas with current generation receipts.
The independent stage0 rejection controls remain in
`tests/phase8-bootstrap/run.mjs` and its fixtures.

To regenerate the C runtime's five checked template chunks, use
[`tools/build/native-template.mjs`](../build/native-template.mjs) with an explicit
checked B1 or genuine B2 authority receipt. Template scanning remains in Bend.

Agent token/limit telemetry remains available through
`python3 tools/development/usage.py`. See
[usage monitoring](../../../docs/self_hosted/agent-usage.md) for snapshots,
interval budgets and their limitations.
