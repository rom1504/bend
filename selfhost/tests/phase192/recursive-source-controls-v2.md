Recursive source transport, revision 2
=====================================

The original `recursive-controls01` run is an incomplete resource failure.
Its retained guard reports `stoppedFor: tree-rss-limit`, return code -9,
peak process-tree RSS 2,222,202,880 bytes, and a 2,147,483,648-byte limit.
The report records both `one` routes and `two`'s direct route passing their
complete literal outputs. The last completed job was `two/assembly-link`;
the next execution was interrupted. This establishes neither a semantic
failure nor a completed six-case pass. Here “tree” means the process tree,
not execution of the fixture named `tree`.

The retained evidence is:

- `selfhost/build/phase192/recursive-controls01/report.json`
- `selfhost/build/phase192/recursive-controls01-guard/process.json`
- `selfhost/build/phase192/recursive-controls01-guard/retention.json`

The original driver and all six fixture/oracle files stay unchanged.
`recursive-source-controls-v2.mjs` adds an explicit lifetime boundary:
`emitCase` owns source preparation, lowered IR, typed machine sequence,
rendered assembly and encoded byte-list temporaries, and returns artifact
pins only. After that function returns, the caller performs `Bun.gc(true)`
before any assembler, linker or target child runs. The loaded compiler API
and prepared Base remain live because later cases need them.

The v2 report records current host RSS, heap and external-memory observations
before and after every full collection. Each native job also records the
host RSS immediately before its spawn. These host-only samples supplement
the existing process-tree guard; they do not replace aggregate accounting.
The CPU, RSS, disk, source authority, runtime pins, six-case selection and
exact output comparisons retain the original policy. No cap was raised.

Use the same arguments as the first driver, pointing `--out` at a fresh run
root. This revision had not been run when authored. If collection does not
reduce host residency enough, emission and native execution should be split
into separately guarded processes rather than treating a larger limit as
the default fix.
