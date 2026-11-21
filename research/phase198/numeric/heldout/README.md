These two ordinary source programs were authored after the stable-orbit compiler
rule froze, before either program was compiled or timed. They are new transfer
controls, not members of the native45 catalog or its historical held-out split.

Both accumulate `increment + (state & 7)` modulo U32. The increment is the runtime
seed OR1, and the initial counter is a different seed-derived word. The converging
program halves state on each iteration; it reaches zero within32 transitions and
then has a fixed state with a variable nonzero increment. The cycling program
increments state modulo U32, so no consecutive states are equal, even at wraparound.
The latter should take no shortcut and may expose the cost of the new checks.

The ordinary point is size8192/seed0x12345678. An independently written iterative
Python oracle gives382881820 and382910401 respectively. Five additional input
points cover empty work, maximum seed, short convergence and high bits. A separate
handwritten C loop is both an output oracle and performance reference; it uses no
fixed-state shortcut. Volatile runtime arguments prevent hoisting complete work
out of the repeated C measurement loop. It is not a mature Bend C-backend product.

The frozen transport reuses the existing checked shared-preparation emitter:
API03 is the measured escape-only baseline, API05 is the alpha-renamed stable-orbit
candidate. Neither is the later composed portfolio N1. Actual target ELF timing
is planned across both and pinned clang O3 C, with per-role calibration and six
rotated rounds, full outputs/counts checked. This is separate from the previously
completed abstract-IR controls. `frozen.json` pins source/oracle/driver methods;
`screen-argv.json` has the single65-second hard cap. No retry or extension is
included. Status at this source checkpoint: prepared, not executed.
