# P164-003 — make a compiler-hot recursive computation directly executable

The mixed compiler emits 10.4% fewer continuation segments but still spends
about 201 seconds building the same experimental compiler source. Inserting
into its persistent name/fact index remains generic: `p131i_insert` reconstructs
an owned parent after the recursive child returns, so it falls outside the
closed direct worker DAG. Lookup and String.append are already direct.

Test an additive Bend implementation of the **whole insertion operation**.
Use an explicit typed zipper: traverse via tail calls, retain untouched siblings
and parent metadata, compute the replacement leaf, and rebuild the path through
a tail loop. Isolate legacy `KDef` and malformed/split-zero fallback operations
behind an outer generic boundary; never assume arbitrary public input is a
well-formed depth-32 trie. The fast loop may return a stop state that the outer
function resolves using the unchanged legacy operation, then resumes rebuilding.

This introduces explicit temporary state, so it is not automatically cheaper.
The falsifier is complete native insertion/build/query time plus exact original
tree observations, not a claim based on tail recursion or helper counts.
Inspect whether actual generated code contains direct traversal/unwind workers.
Preserve aliases, duplicate-key replacement, hash collisions, malformed cases,
evaluation behavior and bounded native stack use. Do not weaken final verifiers.

Start with a small compiler-derived map workload and independent original
insertion oracle, then a mixed consumer. Only acquire a full compiler if this
whole-operation comparison shows enough benefit to justify the cost. The phase
does not promise a five-second build or attribute the entire map/ownership cost
to insertion. This is a measured alternative after the broad mixed route proved
too weak, not an additional mandatory optimization layer.
