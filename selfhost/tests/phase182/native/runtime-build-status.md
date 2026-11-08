# Phase182 runtime build status

`selfhost/build/phase182/runtime-build01` is **superseded**. Its successful build
receipt and object remain unchanged as historical evidence. Its bound QBE
runtime source was 156710 bytes, SHA256
`c60de7066ba9f0ea171d049b0f859c02f4b2f65a8917e471fd6c99696f271548`.
It is not the runtime object for the final migrated-source validation.

Subsequent reviewed edits require a fresh build: Halt/Exit range rejection,
packed Exit payload extraction, and strict upstream GPU-size parsing. Both
native and QBE runtime parsers now apply the upstream decimal spelling check
(`end == v + strspn(v, "0123456789.")`) and 16384-byte minimum. `on` and `off`
remain explicit alternatives. QBE's separate one-worker/GPU-off limitation is
unchanged.

No runtime target or invalid-option probe was executed by this audit. Root owns
the replacement build, its fresh identity and subsequent ordinary controls.
