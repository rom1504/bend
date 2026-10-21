# Verified helpers inside local recursive regions

Phase124 extends the experimental direct-QBE compiler with a small compositional
capability: a verified complete helper can return into an explicit local
continuation table. This does not change the installed compiler, runtime, or
qualified native image. See the [experiment report](../../implementation/phase124/README.md)
and [design](../../design/phase124/local-ready-resume.md).

## The boundary that prevented optimization

A checked computation may save captures, call a heap-owning helper, receive its
result, recurse, and finally call another helper. The previous local table planner
accepted a saved frame only immediately before descent into the recursive owner.
It could call an old ready helper terminally, but did not see the newer complete
worker catalogue. Individually fast helpers therefore still required generic
continuation dispatch between steps.

The extension has two parts. An immutable view over existing verified catalogues
resolves the exact symbol, argument count, and single-Term result ABI. A new
`P114RResumeReady{frame,call,result}` operation retains the original captures and
argument preparation, calls that helper with snapshotted arguments, and delivers
its result to the existing local unwind table. Self recursion still uses the
explicit loop and continuation stack. No recursive native owner call is added.

## Legality and fallback

Original graph and private-function verification run before emission. Complete
worker verification admits calls only to already checked functions; private self
recursion is an explicit loop. Helpers cannot reenter the unadmitted owner or
observe generic argument-register updates. Exact scratch stores, jump signatures,
capture counts, clean namespaces, and bounded continuation closure remain required.
Full-width transport copies create no additional owning roots. Capture/frame
effects precede argument effects and the helper call, in their original order.

Existing direct, H, R, and G successes retain priority. Only their final failure
tries the extended H planner; unsupported graphs fall back to the original public
emission. The unrelated old renderer explicitly refuses the new statement kind.
The case renamer handles all three fields, including the result.

These contracts are separate from QBE profitability. They describe a closed helper
call returning to a local continuation, which could be useful in a future shared
IR. No general IR, persistent cache, or new runtime ABI is required today.

## Evidence and limits

Pure admission/refusal controls accompany independent ordinary list/tree controls
with externally observed aliases and bounded deep inputs. Static evidence traces
the exact owner/continuations absorbed into each local region. Frozen benchmarks
use unchanged inputs, outputs, batch counts, and upstream products. Host compilation
cost and generated-program runtime are measured separately.

The capability removes generic scheduler transitions; it does not remove every
frame, allocation, ownership operation, or intermediate data structure. Broad
hosted qualification does not establish native N1/N2 self-reproduction or compiler
speedup. Repeated optimization commits are not evidence of recursive acceleration.

An additional scoped frame-template experiment is retained separately and excluded
from the selected source because its small measured benefit did not justify extra
renderer complexity. Do not globally treat a matching scratch-variable spelling
as proof of buffer provenance.
