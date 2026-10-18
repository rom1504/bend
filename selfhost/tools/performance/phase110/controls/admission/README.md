These source-only controls freeze the distinction between checked source types,
erased owning words, and the concrete four-constructor runtime catalogue. They
must be captured by the real source checker before certificate verdicts count.
The reference outputs are elementary source meanings, derived independently of
the certificate or lowering candidate. No compiler or target was run to create
them.

`source.bend` makes every candidate definition reachable from `main`. All its
source declarations are intended to typecheck. A refusal by the narrow
certificate is expected for otherwise valid unsupported types. The exact
generic compiler `nt_reverse` is included separately: its caller has concrete
List<String> input/result roles, but the closed library remains uncertified
without checked specialization of the erased type argument. A host assertion
that its two owning words are lists is not that specialization evidence.

`wrong-result.bend` is a separate source-check failure. The expected error is
not an exact diagnostic string, and an unchecked fact from it never counts as
a successful certificate-negative control. `main` reaches the bad declaration
through an otherwise well-typed List.length call, so reachable-only capture
cannot silently omit it.

`oracle.json` lists entry signature verdicts, closed-library verdicts, and
adversarial certificate requests independently. Mutation recipes require
fresh revalidation after changing a typed fact, descriptor provenance, or
claimed role. They must fail closed; restoring the original exact data must
recover the positive control. These are admission tests, not claims about
runtime function semantics or measured compiler hotness.

Aliases are deliberately outside the first certificate grammar. A future
checked normalization extension may admit them under a newly frozen version;
silently treating any unrecognized type as an owning word is not sufficient.
