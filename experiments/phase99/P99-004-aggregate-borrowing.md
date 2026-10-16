# P99-004: borrow through checked aggregate roots

Status: prototype, before execution. Baseline: Phase99 source04 `c19e926e…`.
User steering: prioritize discovery over repeated qualification of small wins.

Generalize the observer schema to bounded plain ADTs, keeping unsupported/applied
fields opaque. Permit a typed child to borrow under a live aggregate root and
bounded specialization of certified calls with virtual literal arguments. This
could eliminate consuming KTerm tag/projection work in many compiler callers.
The estimated 10–20% full-B2 opportunity is speculative and overlaps existing
equality improvements.

First gate: exact-source testing API, real KTerm shapes, complete values and
retained aliases, refusals for opaque/escaping/effectful cases, generated borrowed
code, and a small repeated projection benchmark. Stop if the intended code is
absent or gains are weak. No full images, new proof framework or release campaign
until this and other candidates justify one combined integration.
