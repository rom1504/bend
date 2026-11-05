# Phase164 conservative hybrid: retained runtime mechanism

The Mandelbrot and Unicode results have a concrete code-path explanation beyond
layout: generic callers can now invoke existing direct workers without a scheduler
round trip. The expensive arithmetic/array/String worker bodies inspected here are
unchanged. Edit distance already had that connection in its principal repeated
work, making its neutral result a useful counterexample to a general runtime-win
claim. These are static findings, not attribution of the measured percentages.

This audit executes no compiler, workload, or profiler. Its exact input hashes,
selected function hashes, decoded FIDs, assembly calls and static instruction
counts are in [runtime-mechanism.json](runtime-mechanism.json). Reproduce the
offline extraction with `python3 experiments/phase164/tools/runtime-mechanism.py`.
The conservative source is
`selfhost/build/phase164/hybrid-api-source01/compiler.bend`, 1,524,187 bytes,
SHA256 `54d6dc38e7ba1c860f41fafb7a28e0c155c60a767afbde7578c1b785136e79be`.
Current private discovery changes are outside this comparison.

| Original IO fixture | Baseline / candidate internal ms, two pairs | Ratio of medians | SSA bytes | All emitted functions | Linked ELF bytes |
| --- | --- | --- | --- | --- | --- |
| Mandelbrot | 689,714 / 605,606 | 0.86315 | 1,256,237 → 831,383 | 908 → 843 | 294,680 → 264,592 |
| Unicode text 16 | 270,272 / 240,239 | 0.88376 | 535,214 → 527,398 | 689 → 670 | 235,040 → 233,520 |
| Edit distance | 253,253 / 251,254 | 0.99802 | 1,218,184 → 1,195,386 | 927 → 894 | 284,280 → 277,320 |

Source/expected-output pins, correctness gates, commands and timing observations
come from `selfhost/build/phase164/transfer01/report.json` and
`selfhost/build/phase164/transfer-machine01/report.json`. Both backends consume the
same checked plan in `experiments/phase164/tools/lower.mjs`; these are the original
IO catalog fixtures, not Phase163's pure-main transfer copies. All six machine
builds use the same pinned QBE and runtime object. ELF size is not dynamic work or
RSS. Whole-file function counts include wrappers and continuations.

## What the frozen compiler changes

At frozen-source lines 37044–37084, `p134e_prepare` removes authenticated adapters
from the generic region candidate set, seeds that region registry with
`p164r_imports`, and then runs the ordinary region passes. `p134e_private` emits an
ordinary-call forwarding symbol for each imported direct body. At lines
39874–39905, `p164r_import` publishes the existing owner/arity as a `P112Worker`;
`p164r_forward` defines `p112w_<owner>(state,args...)` calling
`p113d_<owner>(state,args...)`. This makes a previously known direct worker
available to generic callers' region composition. It does not specialize the
worker algorithm anew.

Source admission and the final mixed verifier remain part of the route:
`p164a_allowed` (39485) checks source kind, non-native/non-foreign/non-bang status,
arity and ready signature; `p164v_obligation` (39652) rechecks source/header
correspondence. This note identifies performance mechanics, not a replacement for
the separate semantic qualification.

## Mandelbrot: remove two leaf dispatcher boundaries

The fixture's `hfold` base case calls `hchunk`, and `rcol` base case calls `rpix`.
Decoded retained SSA gives:

| Caller | Baseline route | Candidate route |
| --- | --- | --- |
| `$direct.hfold` | FID280 → `p111_rt_jump` FID254 (`$direct.hchunk`) | FID217 → `p112w_$direct.hchunk` → `p113d_$direct.hchunk` |
| `$direct.rcol` | FID413 → `p111_rt_jump` FID390 (`$direct.rpix`) | FID321 → `p112w_$direct.rpix` → `p113d_$direct.rpix` |

The baseline target adapters read 11 and 10 arguments respectively with
`p111_rt_reg_get`, call the same native worker, and return through
`p111_rt_return`. The candidate calls the worker through the forwarding wrapper
and performs the final runtime return in the caller. Thus a leaf invocation
avoids the outgoing jump's register transfer, one scheduler dispatch, and those
adapter register-get calls. Recursive tree edges still use the existing generic
protocol. The workers `p113d_$direct.mit`, `hchunk`, and `rpix` have **byte-identical
SSA bodies** and identical assembly after renaming only local `.Lbb` labels.
Their assembly contains 99, 285 and 218 instruction lines respectively.

This is not fewer instructions in the caller alone: `hfold` grows from 61 to 81
assembly instruction lines, `rcol` from 119 to 141. New forwarders contain 29 and
26 lines, including argument stack marshalling and a real `callq`. The removed
runtime work is outside those caller bodies. The small input's source-level tree
has four histogram leaves and 256 recolor leaves per complete result; this is a
derivation from input `[2,0]` and fixture recursion, not a measured call count.
It makes the changed boundaries relevant to repeated execution without proving
that they explain all 13.7% observed reduction.

## Unicode: two append continuations become direct calls

The active `bench` constructs repeated Unicode text, splits it, then joins with
`"|"`. The two continuations belonging to `$direct.sjoin.go` change as follows:

* Baseline FIDs281/282 (`$p111.k.53073` / `.53076`) tail-transfer with
  `p111_rt_jump` to FID334, `$direct.String.append`.
* Candidate FIDs240/241 (`$p111.k.52710` / `.52713`) call
  `p112w_$direct.String.append`, then perform `p111_rt_return` themselves.

Both continuation changes survive assembly: 18 lines with one runtime jump
become 23 lines with a direct import call and runtime return. The forwarding
wrapper is six lines with a real `callq`; it is not optimized into a tail jump.
The unchanged append adapter otherwise reads two runtime registers before
entering the direct body. The underlying
`p113d_$p118.trmc.$direct.String.append` worker is exact in SSA and label-normalized
assembly (72 instruction lines), including the same take/extend/finish calls.
There is no evidence here of fewer String allocations or different String
representation.

There are smaller changes at `bench`'s U32.show/append setup. There is also a
countervailing change: `p114r_$direct.p37.text.repeat` already called
`p113d_$direct.String.append` directly; it now calls the extra `p112w` forwarder.
Its loop keeps the same instruction count and ownership calls.
`p114r_$direct.ssplit` differs in three continuation-FID immediates (272→231,
275→234, and the corresponding comparison), with the same instructions/calls.
Those FIDs resolve to corresponding renamed continuations. This supports a
join-boundary explanation, not a new split/append algorithm.

## Edit distance: the repeated core was already direct

`p114r_$direct.batch` already directly invoked `p113d_$direct.pair`. The candidate
changes that target to `p112w_$direct.pair`; it does not eliminate a scheduler
boundary on that edge. `pair` already calls the product form of `dp`, which calls
the product form of `row`. `p113d_$direct.pair`, `dp`, `row`, and `$product.row`
have exact SSA and label-normalized assembly in both images. Their array pair,
constructor, ownership and primitive calls remain. The batch machine body retains
117 instruction lines, with the direct-call target changed. Registry/function
shrinkage elsewhere therefore need not improve this workload's repeated core.

## Interpretation and limits

The runtime contract makes the removed boundary concrete:
`selfhost/src/runtime/qbe/runtime.c:3984` copies jump arguments to runtime
registers; `p111_rt_jump` validates arity and sets `next`; the work loop at 1433
looks up `segments[next]` and makes an indirect call; `p111_rt_reg_get` at 4019
checks and reads the transported argument. Both routes still execute a runtime
return. No additional ownership operation was found eliminated in the inspected
hot workers. Continuation numbering, whole-file order and binary layout also
change, so they remain possible contributors to timing.

Two pairs are a screen, not a broad performance qualification. Static call-site
counts cannot apportion elapsed time. The evidence supports a general **ability
to compose generic callers with already-admitted direct workers**, with a runtime
benefit where repeated edges previously used the dispatcher. It does not support
a general percentage gain, an allocation reduction, or a full compiler runtime
speedup. A later focused dispatch-count observation on the same fixtures could
test that causal explanation; no such additional experiment was run for this
audit. Compiler-work reduction is a separate measurement.
