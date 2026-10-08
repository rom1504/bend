# Native CPU effects and compatibility

The active compiler source targets upstream
`059266225b77c8ca256ac6b25ee5c21449bab151`. Native CPU output uses the retained
selfhost C runtime and scheduler. Its coverage differs from direct JavaScript
and legacy Node output. The [Phase66 report](../../implementation/phase66/README.md)
records selected/installed images and final gates; the
[backend report](../../implementation/phase66/backend.md) records the native
migration, controls and preserved failures.

## Ordinary blocking operations

The Phase66 native migration keeps the scheduler and updates the current Base
result and ownership contracts:

| Operation | Result contract |
| --- | --- |
| `Chan.send` | `Done{Unit}` after transfer; `Fail{originalValue}` on a closed channel, including a sender already waiting when it closes. |
| `Chan.recv` | `Some{value}` or `None` after a closed channel drains. Waiting senders keep ownership until transfer or return. |
| `TCP.recv`, `TCP.recv_bytes` | `Done{Some{data}}` or `Done{None}` at peer EOF. A zero maximum fails immediately without reading. |
| `TCP.send`, `TCP.send_bytes` | A failure returns the error and exact unsent suffix. Invalid byte lists return intact before any syscall. |
| `UDP.send_to` | A failure returns the error and complete unsent datagram. |
| `UDP.recv_from` | Empty datagrams remain valid data; zero maximum fails immediately without consuming a queued datagram. |

Nineteen actual source controls passed against both the pinned reference and
the candidate native runtime: fifteen upstream cases plus four focused
channel-ownership and zero-maximum controls. This is a selected CPU coverage
claim, not full native/GPU conformance. The source controls used the exact
checked 04 API with an explicitly recorded native-only overlay. The
[selected-05 receipt](../../implementation/phase66/evidence/native-backend05.json)
binds that overlay to the actual 05 snapshot and records native16, native3 and
seven deterministic TCP syscall controls. The [final07 admission](../../implementation/phase66/evidence/native-backend07.json)
verifies 4,661 identities, all 646 native functions and 48 unchanged native files,
then binds fresh final07 native3 output, B1/B2 C equality and the namespace-collision
diagnostic. This is the selected installed compiler's native qualification.

Foreign C sources can register immediate effects with `io_eff(cid, run)`.
Existing three-argument registrations retain their readiness/timer argument.
The host boundary supports both retained `term_peek(Env, term)` calls and
current `term_peek(Corpus, term)`/`blk_loc(Corpus, term)` calls. These shims
use the retained runtime's representation and redirect-cell semantics;
they do not replace it with upstream's complete C runtime.

## New APIs not implemented by the retained native runtime

The following thirteen newly added Base operations have named runtime
refusals if actually dispatched without a provider:

- Channels: `Chan.try_send`, `Chan.try_recv`.
- TCP: `TCP.try_accept`, `TCP.try_send`, `TCP.try_send_bytes`,
  `TCP.try_recv`, `TCP.try_recv_bytes`.
- UDP: `UDP.try_send_to`, `UDP.try_send_bytes_to`, `UDP.try_recv_from`,
  `UDP.try_recv_bytes_from`, `UDP.send_bytes_to`, `UDP.recv_bytes_from`.

Merely importing Base does not trigger a refusal. A custom provider can
register an implementation; the unavailable-operation diagnostic is used only
when the request has no handler. These are explicit new-capability gaps,
separate from the migrated ordinary blocking operations. Do not infer support
from the shared Base declaration or from another backend passing a test.

The earlier native `IO.args` discrepancy and broader GPU coverage remain
outside this repair. Historical native release smoke tests mostly exercised
arithmetic, arrays and ordinary output; their passing status did not establish
channel or network compatibility.
