# P78-002: retain already-computed annotation type heads

Source inspection finds annotate computes wnf(book, ty) for ka_node but wraps the
result with the original ty. Layout validation and native erasure normalize
annotation types again. Hypothesis: retain the same already-computed weak-head
type in the annotation instead, without moving or adding normalization demand.
No cross-context cache or source-name exceptions. This changes annotation
representation shared with JS: require exact C screens, differential annotation
meaning/consumer controls, self-hosting, JS output checks and broader release
gates before promotion. Current direct-control candidate03 is the starting point;
source-only ablation will separate any gain. No speed claim from inspection.
