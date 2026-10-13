# Phase78 experimental methods

See [design](../../../../design/phase78/b1-parity.md) and
[report](../../../../implementation/phase78/README.md). Use fresh output paths.

`screen-b1.py ATTEMPT OUT --rounds 2` freezes checked candidate B1, Phase77 B1 and
upstream. Run `compilation/run.py --plan OUT/plan.json --group prepare`, then
`--group clean`, one guarded heavy process at a time. Screen02–08 require exact
Phase77 C. `screen-symbols.py` uses `compact-symbols.py` to derive an independent
identifier-only C oracle for compiler09. This is not runtime qualification.

`branch-source.py` and `branch-source-v2.py` are historical prototype rewriters,
not production build steps. V2's initial law-definition header attempt was
rejected by the parser; compiler06 restores the existing untyped def headers.
Do not rerun these against the current already-rewritten sources.

The frozen compilation worker/run/analyze methods are unchanged Phase77 copies.
Every plan records methods and inputs; never mutate a method after pinning it.
