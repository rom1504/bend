# Phase119: refresh the changed bottlenecks

Starting point: selfhost/bootstrap `6315f14`, qualified Phase118 safe03. This is
measurement only: no compiler/runtime changes, image builds or promotion.

Questions: which overhead survived the ownership/transport improvements; do
numeric regions still lose representation information; and what now dominates
an ordinary request in the generated native compiler?

Reuse authenticated frozen products for scalar-region-8192, active-ray-256,
lexer, tree-bitonic, list-pipeline-128 and map-churn-128. Compare Phase118 QBE,
mature selfhost C102 and pinned upstream C on identical sources, arguments and
complete-output oracles. The safe03/float01 exact-QBE bridge authenticates reuse;
these are hosted-produced user-program binaries, not a new native batch campaign.

Run three rotated clean rounds at four times the original iteration counts.
Separately collect two physical-PC profiles (8ms and13ms, about7s each) per role.
Sampling clocks are not performance measurements; report losses, coverage and
sample counts. Compare one exact ordinary compiler request on qualified N1
Phase114/118, with each image's independently frozen full-QBE output oracle.
Keep the existing JS profiles historical; they are not needed to distinguish
remaining native numeric versus memory/control overhead.

One serial CPU3 lane, existing guard,2GiB RSS,16GiB available floor. No full-image
campaign. Disk is tight, so retain small profiles/receipts and reference existing
large artifacts. An offline numeric-code audit can run alongside target execution.

Deliver reproducible evidence, updated hotspot rankings and the smallest next
experiment. Distinguish observations from proposed transformations; shorter IR,
static helper counts and broad libc buckets are not performance explanations.
