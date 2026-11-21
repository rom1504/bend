# Public static tail transfer

Use `tail.apply(stage)` on a fresh copy of the progress portfolio's `maintained` directory. It consumes the previously checked Bend implementation and replaces one declaration in `src/back/x86/branch-selection.bend`. The five added helpers and replacement hook match their independently checked executable bodies, including annotations. The portable replay uses the committed Phase 198 modules, the archived original API receipt and six captured body hashes. The standalone tail-only assembly SHA-256 is `8e9d08d5099807cf395a9863b025eefa319a833bb7e767fe34880a7c70ae6c0a` over 1,950,389 bytes. Of 5,700 existing executable declarations, only `x190_step` changes. Full type checking and behavioral qualification apply to the final composed source. [Tail authority](tail-authority.json) · [Phase 198 machine and ordinary-program qualification](../../phase198/reuse/tail/results.md)

Word changes `x185_sf_body` and `x186_u32_float_probe`. Machine quotient changes `x191_ff_work`. Their declaration sets are disjoint from tail. The standalone ordering overlay also replaces `x186_u32_float_probe`; selecting both word and ordering requires an explicit join. The port supplies the original tail fallback to `x194_ps_step`.

The supported entry convention is the ABI11102 standalone scheduler. A public segment receives one state pointer. For an ordinary known FID, the dispatcher sets next to STOP and dispatches to the matching entry in its segment table. A terminal guarded transfer in the source already sets the same successor along both paths. The tail rule executes the original transport, reloads the state argument, resets next and restores the native frame before jumping to the symbol used in that table. The slow `p111_rt_jump` still validates arity and applies the required register-bank clearing. Unknown or runtime-reserved targets, nonterminal transfers, other parameter lists and dynamic closure/application entries keep their original paths. The bound program descriptor has one process lifetime. Built-in foreign effects bind by constructor identity and do not replace its segment table.

The 22 transport, verifier and emitter declarations recorded in the audit have identical executable bodies in the original checked source and the progress portfolio. All 9,863 relocations naming public segment symbols across the 45 immutable progress objects are 64-bit data pointers. The 24.8, 32.4 and 32.4 MB compiler objects for N1, N2 and N3 each have another 46,874 such data pointers. None of the examined references originates in executable text. This establishes the observed call convention for the supplied ordinary products. An external C embedder that calls exported segments to observe a single scheduler transition, or replaces entries in the compiled dispatch table, falls outside that standalone contract. [Object and source audit](tail-abi.json)

Rebuild the tail-only experiment from the repository root with a fresh output path.

```sh
python3 -B research/phase199/composition/tail.py --out selfhost/build/phase199/tail-only-replay01
python3 -B research/phase199/composition/tail_abi.py
```
