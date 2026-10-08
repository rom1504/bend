# Selected product flow audit

`audit-emitted-products.py` reads saved generated C as data on CPU0. It does not
invoke Bend, JavaScript, a C compiler, a preprocessor, or a generated program.
The script hash at creation is
`d81f27b5236f004cb848884d370f039821968472faa7e03c1e2d4c86f00ddd13`.

After the parent captures product array C, run from the repository root with
fresh receipt paths:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase68/flat-products/audit-emitted-products.py ARRAY_PROGRAM_C --hot-suffix fold.loop --require-q-hot-zero --out FRESH_ARRAY_RECEIPT_JSON
taskset -c 0 python3 selfhost/tools/performance/phase68/flat-products/audit-emitted-products.py BRANCH_DROP_PROGRAM_C --forbid-product-suffix drop_product_branch68 --out FRESH_DROP_RECEIPT_JSON
```

The array receipt contains a line-numbered path from scheduler `main` through
referenced continuations/closures to selected ordinary/private worker calls.
It chooses host `!DEVICE` branches in scheduler wrappers, so the preserved device
body cannot create a false worker edge. Direct worker edges are taken only from
actual function bodies, not prototypes or name catalogues. Private product
definitions with no entry-reachable edge are reported separately.

The strong array check requires an entry-reachable `$product.*fold.loop` and
follows all of its direct worker callees. Every body in that closure must contain
zero Tuple constructors, Tuple tag references and constructor takes. The receipt
also records heap allocations, array keeps, physical parameter counts, result
indices and the local `nf_again` backedge. Inspect the path, loop backedge and
field/output assignments alongside the usual worker-DAG checker. The intended
selected route includes the loop, cell and step product variants; both getter
and recurrence-state pairs must stay vectors between those workers.

This is static structural reachability, not a runtime execution proof. Scheduler
references conservatively include possible closures and continuations; they do
not prove branch feasibility or invocation counts. Pair this receipt with the
parent's unchanged positive workload/oracle and operation counters. Whole-program
Tuple counts are not a qualification criterion because scheduler/device and
boxed worker fallbacks remain in C.

The branch-drop command independently requires that no private entry whose name
ends in `drop_product_branch68` is defined. Its separate frontend/oracle control
is `1831`; the output alone cannot establish the ownership barrier.

Saved baseline `array06-source-audit.json` reads the existing worker06 C hash
`fb417bb191539a7e3633054bad8253a9ec829ae93a7b58e3c4a345cba2d3290e`.
It reports 17 entry-reachable ordinary workers and zero products. Running the
strong product condition on that same input correctly fails with
`no entry-reachable product hot worker`. No target was run for either read.
