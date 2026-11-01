# Conformance support tests

For current finite compiler/program gates use
[the maintained qualification runner](../../tools/conformance/qualification.md).
For full or selected upstream comparisons use the checked adapters in
[`tools/conformance`](../../tools/conformance/README.md). The active inventory
is pinned to `059266225b77c8ca256ac6b25ee5c21449bab151`; its current inventory has
1,587 oracle-bearing fixtures, 11 support sources and 64 effect files.

`judge.test.mjs`, `selection.test.mjs`, `native-adapter.test.mjs` and the new
qualification/graph tests exercise host/oracle contracts without running the
compiler. Other files may execute real compiler programs or controlled child
processes. Run compiler targets only inside the shared outer resource guard.
Do not treat an unfiltered test-directory invocation as a cheap unit-test lane.

Files explicitly named for earlier phases and retained JSON reports describe
historical snapshots. Their old pins are not current qualification results.
The retained fixture oracles remain independent; current runners must select
the intended pin and adapter explicitly. Successful parsing, source checking,
generated-program execution and independent BendTT kernel verification are
different observations.
