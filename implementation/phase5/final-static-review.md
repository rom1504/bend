# Final-source static review

Three bounded independent reviews inspected the promoted source at commit
`24f3105cf2b357e96bee7d33a9e1be7fb0367986` while the controlled full-source
comparison occupied the machine. These reviews ran no compiler, tests or
archives and changed no source. They supplement the recorded execution gates.

- **Nat parsing and imported freshness:** the numeric atom requires exact
  same-line adjacency, validates the literal before demanding its RHS, and
  retains the native-add boundary. Chronological exact-name import checking
  runs after existing parse/elaboration errors, preserves qualification and
  constructor namespaces, and treats seeded/unseeded loading consistently.
  Previously documented semicolon, imported-law-fill and error-order gaps remain.
- **Private Base memo:** production hashes match the measured candidate. API
  ownership, canonical path/content identity, exact hashed/decoded buffer,
  invalid-entry clearing, immutable graph, caller isolation and recycling agree
  with the 84 observation pairs and 15 adversarial contract groups. The supported
  frozen generated-API workflow still relies on full artifact provenance; a
  content-qualified module URL is not arbitrary transitive JavaScript dependency
  invalidation or an atomic filesystem snapshot.
- **Parser error transport/rendering:** the existing chosen error remains
  authoritative. Type/value/constructor/definition traversal order, unique source
  ownership, empty/seeded module counts and graph-error priority were traced.
  Accepted books avoid the error-only traversal; P519 changes existing rejection
  branches and retains fallback rendering. No acceptance or selection blocker
  was found in this reviewed scope.

## Counterexample confirmed after the timing window

The parser reviewer identified a possible existing line-counter defect after a
physical newline inside a quoted string. A matching character on the wrong
line can satisfy the new renderer's source guard. The executed reproducer is:

```bend
import Base
def main() -> String:
  "a
?"
?
```

`selfhost/build/phase5/static-review/plan.json` records the hypothesis before
execution, with a valid multiline-string neighbor. After the exclusive timing
window, paired maintained validation against genuine integration01 and final05
confirmed the defect. TypeScript identifies physical line5; integration01 already
reports line4; final05 additionally highlights the line4 string content. The
parse/check classifications and checked flags are unchanged, and the valid
neighbor agrees exactly. Each four-observation selection retains two exact
diagnostic mismatches. This is a demonstrated new wrong excerpt over an existing
cursor defect, not a new acceptance regression or a repaired conformance case.
No source fix was attempted before the final frozen-source proof. See the
[exact evidence and follow-up scope](static-counterexample.md).
