# P73-005: compose borrowing with constructor sharing

Hypothesis: a datatype whose every destructive match is replaced by a proven
borrowed traversal when shared does not need sealed child pointers. It can have
an RFC on the root while its children remain cold. Dropping a shared root only
decrements its root; dropping a unique root can consume cold children normally.

First combine the saved-C scalar borrowing diagnostic with cold stores of Tape's
recursive constructor only. If useful, prove the property across all reachable
source matches. Permit only the existing bounded observer root schemas; reject
any type with a match outside an admitted observer, including bang/opaque paths.
Scalar workers must choose borrowing when ANY root is shared; their owned tail
loop must recheck for a shared descendant. Root-preserving observers with a
private ordinary/product bypass must prevent admission of their root type.

This composes two general facts; no benchmark name is a production rule. Device,
raw, unsupported effects and uncertain global sharing analyses retain all seals.
Require deep/shared/nested/parallel controls and full selected native gate before
promotion. The saved-C prototype does not establish this general proof itself.
