# Upstream Bend2.0.40 compatibility

Phase182 migrates maintained source from upstream
`059266225b77c8ca256ac6b25ee5c21449bab151` to
`9a4223d577ba56a0cb53d1fd952d2b481c38930f`. The
[source recipe](../../selfhost/src/compiler.json) selects the exact checkout.
This page describes implemented contracts and remaining limits; it does not
qualify an image, install a release, or establish a performance improvement.
Historical images retain their own source, Base and runtime identities. See the
[migration design](../../design/phase182/README.md) and
[maintained workflow](workflow.md) for the separate acquisition and release gates.

## Frontend

Name resolution separates declarations from constructors. References, laws and
datatype applications use the declaration namespace; construction and matching
use the constructor namespace. Generated sugar selects the defining file's own
names, then Base, without capture by import aliases. Dependent lets retain their
outer inference scope; the repeated kind check applies to safe reusable Data
bindings. [Namespace controls](../../selfhost/tests/phase182/namespaces/README.md)
retain accepted and rejected upstream examples.

Equality sharing records equivalence classes separately from evaluation values.
A completed equality can discharge equality or subtyping comparisons; a
directional subtyping success cannot publish an equality. Joining classes never
copies a value into another share cell, avoiding the cyclic-thunk defect.
[Sharing controls](../../selfhost/tests/phase182/sharing/README.md) describe the
heap-preservation invariant. Facts remain scoped to one comparison; upstream's
cache lifetime and speedups are not implied. Character escapes now admit the
full U32 range, with non-scalar string characters preserved internally.

## JavaScript

The maintained direct backend uses host ABI `number-nat-scalar-text-v2`:

- Scalar Nat arguments are JavaScript Numbers, validated as integers from zero
  through `2**53`, inclusive; BigInt is rejected. Bend Nat arithmetic retains
  its separate `2**48 - 1` representation bound.
- Scalar F32 inputs round to float32. Char and String host boundaries normalize
  invalid scalar text, while internal character operations retain full U32
  values. Aggregate and function values preserve their existing identity.
- Exports retain exact qualified names. Constructor tags remove the semantic
  module prefix before the colon; literal dots remain part of the constructor
  name. Construction, matching and foreign CID emission use the same rule.
  Definition CID/FID names retain qualification; tooling does no graph repair.

`F32.from_nat`, `String.contains` and `Array.get_unchecked` have direct lowering.
The runtime and exact vendored effect sources adopt the current IO protocol,
including nested scheduling, standard-stream buffering, timers, append handling,
Exit and argument parsing. The [paired JS controls](../../selfhost/tests/phase182/js/README.md)
compare ordinary libraries and foreign programs with the unmodified upstream
loader, checker and emitter. The legacy descriptor JS backend/runtime retains
its earlier ABI and is outside this new direct-backend qualification.

## Native runtime and tooling

Native lowering retains the maintained ownership and value representation.
The C and QBE runtimes adapt current primitive/effect interfaces, full-U32 Char
text output, file operations, argument handling, and Halt/Exit status handling.
`F32.from_nat` adds primitive 86; unchecked array reads reuse the existing array
get operation. Shared boxed array leaves retain their element before releasing
the array handle. QBE keeps its pinned embedded effect-provider table; arbitrary
C foreign embedding and callbacks are not supported by that path.
The C environment provider rejects names containing `=`. A failed C `TCP.send`
returns the exact unsent byte list required by current Base, including a partial
UTF-8 sequence. These narrow corrections do not qualify the full network stack.

| Contract | Current selection |
| --- | --- |
| Native descriptor | [ABI11102](../../selfhost/src/runtime/qbe/runtime.h); the physical descriptor layout is unchanged, but the Base/provider/primitive contract is versioned. ABI11101 products require their original runtime. |
| Runtime arguments | `bend-rts-v1`: `+RTS ... -RTS`; tools use `--RTS` before application arguments. `IO.args` includes the executable name at index zero. |
| Historical invocation | `bend-legacy-v1` keeps the old options and `--` separator. Selection follows the executing provider's metadata, not the current upstream source pin. |
| Runtime templates | The convention is accepted only with the exact selected runtime hash. New compiler entry profiles account for the executable-name argument. |

The [argument adapter](../../selfhost/tools/runtime-arguments.mjs), explicit
upstream checkout, Base bindings and effect manifests make these choices
reproducible. The [JS effect inventory](../../selfhost/src/runtime/js/effs/README.md)
contains 36 unchanged upstream files, each bound by size and hash. Only listed
imports beside the authenticated Base are redirected; custom imports keep their
normal resolution. Old provider schemas remain available for historical replay.

## Limits and evidence

QBE and the experimental [x86 emitter](x86-backend.md) remain sequential CPU
paths with one worker and GPU off. C retains platform-dependent GPU code, but
this migration does not establish Metal/CUDA qualification. Unsupported native
`Window.fullscreen` use refuses explicitly. Ordinary file/argument controls do
not qualify display, audio, networking, subprocesses or broad effect scheduling;
their platform and foreign-interface requirements remain separate.

The retained C providers have concrete remaining differences from the new
upstream, beyond unavailable hardware. This is a source audit, not an execution
result:

| Provider | Remaining compatibility limit |
| --- | --- |
| [Linux audio](../../selfhost/src/runtime/native/effs/audio.c#L114) | The ALSA pump advances a whole chunk after a partial write and ignores recovery failure. Upstream retains unwritten frames and stops on an unrecoverable error. |
| [Process](../../selfhost/src/runtime/native/effs/process_run.c#L71) | The retained loop reaps the child, then drains currently available bytes; upstream drains output pipes to EOF before reaping. Later descendant output can differ. On macOS, retained `posix_spawnp` lacks upstream's explicit no-shell PATH search. |
| [TCP send](../../selfhost/src/runtime/native/effs/tcp_send.c#L9), [receive](../../selfhost/src/runtime/native/effs/tcp_recv.c#L11), [accept](../../selfhost/src/runtime/native/effs/tcp_accept.c#L7), [connect](../../selfhost/src/runtime/native/effs/tcp_connect.c#L33) | EINTR retry/connect handling remains older. A zero-progress send lacks upstream's EIO termination. The corrected byte-list failure payload does not resolve these scheduling/error differences. |
| [UDP receive](../../selfhost/src/runtime/native/effs/udp_recv_from.c#L7), [send](../../selfhost/src/runtime/native/effs/udp_send_to.c#L7) | EINTR retries remain absent; receive allocation caps at INT32_MAX instead of upstream's 65507-byte datagram bound. |
| [Channel/network dispatch](../../selfhost/src/runtime/native/runtime.c#L2808) | Timed `Chan.try_*`, `TCP.try_*`, `UDP.try_*` and UDP byte operations remain explicitly unavailable. Blocking channels retain the earlier host-row ownership scheme. |
| [Window](../../selfhost/src/runtime/native/effs/window.c#L16) | The retained five-word event buffer predates upstream's expanded pointer/tool event schema; current window-event parity is not established. |

The nine [public CLI provider assets](../../selfhost/tools/build/public-cli.py#L20)
are args, print, print_err, now, file_open, file_read, file_size, file_write and
file_close. Their qualification does not cover the provider differences above.
The current read/write providers already include line, byte and positioned IO;
their two-argument registrations use the runtime's explicit compatibility
adapter. They need no registration-arity rewrite.

`Array.get_unchecked` requires an in-bounds caller. Native lowering retains the
existing wrapping implementation; it makes no unchecked-address optimization or
out-of-bounds compatibility claim. Common boxed and multiword arrays remain
supported. Exact upstream rejection at extreme `Array.new` depths for multiword
elements is unresolved in direct JS: its two-argument emission does not carry
the element layout footprint and retains the historical one-word depth limit.

Source acceptance, finite independent outputs, backend verification and
self-reproduction check different properties. None alone proves the compiler or
runtime correct. The [independent proof gate](../../design/phase182/proof-qualification.md)
requires the current complete BendTT kernel, nonopaque named law definitions,
exact source bindings and rejection of a frozen false equality. An old compiled
kernel or a forward law signature does not establish that result. The
[release recipe](../../design/phase182/release-preparation.md) consumes completed,
artifact-bound receipts; its existence is not evidence that those gates passed.
