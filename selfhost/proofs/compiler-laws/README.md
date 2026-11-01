# Frozen compiler contracts

These unique proof/reference fixtures retain exact historical bytes. They are
not a second maintained compiler. `reference-declarations.bend` contains only
six frozen reference declarations used to define the original comparison and
representation boundary; actual candidate declarations are always extracted
from the explicitly requested compiler source.

`algebra` proves abstract list/environment contracts. `ownership` proves the
explicit token protocol model, not concrete C ownership. `representation`,
`comparison` and `permission` supply frozen contracts for the current-source
preparer; preparation is not a proof receipt. The scalar contract may require
new bridge work when its historical helper no longer exists.

Use the [maintained law tools](../../tools/laws/README.md). Their
[fixture map](../../tools/laws/fixtures-migration.json) records byte identities
and exact origins. Old phase names inside comments, law names or the algebra
reference subdirectory are frozen fixture identities, not phase implementation
imports. Historical proof receipts remain historical.
