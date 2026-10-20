# Bounded same-owner continuation table

Optional table01 source profile, pinned by `modules01.json`. All compiler and
native qualification belongs to the coordinator; the author has run no targets.
The profile composes on G02 and its reviewed failure-scan repair. Existing
complete functions, narrow constructor spines and singleton G regions retain
precedence. Unsupported regions retain the exact earlier generic renderer.

The original verified entry must return one Term, have one to eight arguments,
and contain at most 512 N111 statements. Planning discovers at most eight distinct
continuation FIDs. Each must pass `p112f_cont` with an exact capture count from
zero through eight, one incoming result, no flags and at most 128 body statements.
Every repeated use of a FID must agree on its capture layout. Discovery closes
the complete reachable continuation table before emission; missing, oversized,
inconsistent or unsupported cases refuse the whole region.

Bodies reuse `P114RStmt`. They preserve scalar instructions and may return a
value, tail-transfer to the same owner, push a checked continuation then descend
to that owner, or terminally call an existing immutable-registry private worker
with at most eight arguments. Such calls retain all argument stores, snapshot
the full U64 arguments, call the already emitted one-Term worker, then feed that
result to local unwind. The recursive owner must not itself be a ready worker.
Unknown calls, dynamic apply and other recursive targets are not admitted. Exact
failure suffixes retain the pinned sequential CPU fail-stop premise.

The native worker has local entry and unwind labels. It retains the original
frame helper and increments a local frame depth after each retained push. A
result at depth zero returns to the public wrapper, which performs the original
`rt_return` once. At positive depth, local unwind decrements depth, pops the saved
FID, chooses its checked case, and pops exactly that case's captures. It restores
the original pop-result zero, ordered capture locals and incoming result local.
The resume can itself push another frame and descend without a machine-recursive
call. The invariant is an unchanged caller prefix followed by `depth` internal
frames, each containing its original ordered captures and matching FID. Their
sizes may differ. Unknown FIDs cannot arise under that invariant; the emitted
default uses the existing runtime failure helper.

Every case is renamed injectively with its table index, including its scratch
buffer. Entry locals and all original continuation locals must avoid both
reserved namespaces. Up to eight separate 2048-byte case buffers plus the entry
buffer avoid a new shared-scratch alias assumption. All edge arguments are
snapshotted before entry parameters are reassigned. Boolean diamonds reuse the
selected explicit-width normalization, and all labels/temporary counters follow
the existing emitter discipline. Every emitted entry/case must terminate in a
recognized local transfer or copied fail-stop return.

Native stack depth does not grow with recursive traversal depth. Existing
private callees have the prior verified call graph, and their self-tail edges
remain loops. Explicit worklist space still grows with pending captures; this is
not constant-space construction, allocation elimination or a measured 100× claim.
The plan is an authenticated transformation of original checked IR, not a new
ownership proof for arbitrary reflected graphs.

The ordinary witness is concrete. In the preserved packing01 expression product,
`$direct.eval` has six internal continuation FIDs: each Add/Mul/Sub first resumes
with the owned right subtree, saves the left result and descends again; its second
resume performs the corresponding wrapping U32 operation. Tree-bitonic `scan`
has two cases: resume the right subtree after saving the left Stat, then call the
already admitted `stat_join`. The table follows these existing operations and
their strict order. QBE was read only to select the experiment; all production
decisions use structured N111 and the original constructor/function IDs.

`p114h_inspect_request` returns admitted entry names with exact continuation names.
`inspect.mjs` uses the same authenticated ordinary frontend transport as R/G and
records those lists. Because earlier routes retain precedence, an inspection
plan need not be the selected emitted route. Qualification must separately show
the table worker is called, compare complete expression/owned-tree outputs and
retained aliases, and measure the unchanged development kernels. No full native
compiler image or corpus-wide runtime claim follows from this prototype.
