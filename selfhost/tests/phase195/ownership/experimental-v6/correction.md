# V6 correction: explicit local constructor type

Preserved failure: owned-diagnostic-api04/stderr rejects inference of the local
Con literal in p195oa_match_fields, frozen api-source04/compiler.bend:52969.
V6 changes only that local declaration to:

    +yesfacts : List<&2,KTerm> = Con{...}

No constructor, field order, ownership proof, branch or fallback behavior changes.
All other Bend source bytes are unchanged from v5. The preceding error was a
source inference failure, not a failed runtime control or an ownership counterexample.

The new static local-binding inventory covers130 named local assignments across
the three compiler modules and the BST source. Exactly one begins with a list or
other constructor literal: yesfacts. It is now annotated. Other Con/Nil/list
literals occur in typed call/return/pattern contexts rather than inferred local
bindings. Prior delimiter/header, match-site and symbol/arity inventories were
rerun and report no issues. These remain lexical checks, not compiler acceptance.

This is the final bounded source-check candidate requested by root. If source
acceptance fails again, preserve the failure and stop this diagnostic experiment;
do not claim actual Map admission. No targets or compiler jobs ran here. Earlier
versions and all four failed acquisitions remain preserved.
