# P162-001 — identical-input frontend timing and work

Hypothesis: the large self-compilation gap includes a frontend implementation
cost that cannot be explained by source size or code emission. Compare both
implementations' actual parser/loader/checker on identical source/Base, then
measure concrete work (especially declaration publication and term allocation).

Reject timings if source/semantic boundaries do not match, a parser returns only
a prefix, @unsafe skips relevant work, or failed type checking is mistaken for
success. A failing independent proof verdict after type checking is a different
outcome; retain it explicitly. Source adaptation requires independent parse
identity, not whitespace intuition. Exact accepted diagnostic and clean outputs
must agree. No existing compiler image is promoted by these observations.
