# One dispatcher per mutual tail component

This isolated proposal changes only `selfhost/src/back/js/direct/core.bend`:
22 additional physical lines and three helpers. Root owns source application,
checked builds and target execution. The live source was not edited by the
proposal producer. The exact preimage, replacement and patch are pinned in
`identity.json`.

The completed reach01 compiler image contains 133 mutual-component loop groups
across 437 named entry functions. Within each group the entire `for`/`switch`
body is byte-identical; only the entry function name and initial PC differ.
The largest group, led by `f_context_publish`, repeats a 70,138-byte loop
34 times. Its fixed-body sharing derivative saves 2,310,764 bytes. The next
largest groups are led by `f_context_grow` (19 entries) and `norm_cmp_loop`
(13 entries).

The first data-only census is preserved at
`selfhost/build/phase58/scc-census01/report.json`. Its parent is the complete
8,671,962-byte `final-reach01/bootstrap/full/compiler.mjs`; its syntax-checked
sharing derivative is 3,796,489 bytes. These are static file sizes, not speed
or memory measurements. A successor census adds explicit complete-component
dependency comments matching the source proposal; those comments slightly
increase the derivative size without adding runtime work.

The reviewed successor completed at `selfhost/build/phase58/scc-census02`.
Its 3,812,483-byte derivative saves 4,859,479 bytes (56.04%) against the same
parent. The exact report SHA is
`cdbeceb5a88fd7ed724560ae79bf80c8ed995ad2ac2fd465428996fc1e603f8a`;
the output module SHA is
`cea4b818bef79981e4a9752c506840e3b4c3f21fa29abb7f175a226eb18ec713`.
All 133 group bodies remain exact, with 437 complete entry wrappers and all
original maximum-width formal lists. The producer is frozen at
`efd411138f49ca6fbc9ffbbf2450f799797c21b4c90e48a3b73cf0c94f411863`.

`jd_definition_loop` keeps the singleton path unchanged. For a mutual component,
`jd_component_definition` selects the first member in existing source order.
`jd_component_shared` emits the component dispatcher only with that leader's
definition, and emits an ordinary named wrapper for every entry. The wrapper
retains the original maximum-component-width formal parameter list and passes
the fixed initial PC plus those inert locals. Its function name and arity stay
unchanged. The dispatcher name appends `$scc` to the injectively encoded source
name; `jd_name` cannot produce this suffix from a source identifier.

The worker retains the existing switch, case order, case-local lexical bindings,
parallel argument captures, stores and transfers. Each invocation owns its
parameters and PC, so nested non-tail calls and host callback reentry do not
share mutable dispatcher state. Tail transitions stay inside the same loop;
there is no new bounce vector or array spreading. Native and Foreign definitions
cannot enter multi-member tail components under the current call analysis, and
their earlier definition paths remain unchanged.

Every wrapper emits a dependency marker for its real source leader.
`jd_component_refs` explicitly marks every component member at the leader's
dispatcher, in addition to retaining every original body marker. This prevents
emitted reachability from dropping a member and then rebuilding a smaller or
reordered component for final emission. The synthetic dispatcher is never a
source dependency name. No graph, queue, definition or text bound changes.

`../scc-census-v2.mjs` is a data-only diagnostic producer. It recognizes exact
top-level existing loop syntax, requires a complete dense initial-PC set and
identical parameter lists, replaces only those complete function spans, and
reparses the result. Every original loop body must remain byte-identical in its
single dispatcher, the exact runtime prefix remains, and inversion must recover
the complete original module. It does not import or execute the image.

The source patch has independent static approval. Runtime benefits are unproved:
the extra wrapper-to-dispatcher call may affect inlining, stack constants or
program throughput. A clean saved-image latency comparison is the cheap next
test. Checked integration must additionally preserve deep mutual tails,
unequal entry arities, partial applications, escaping captures, errors/reentry,
both entry choices and exact public results. Full emitted reach and source
qualification remain separate from the syntax-only diagnostic. No promotion is
implied by the reduction in duplicated bytes.
