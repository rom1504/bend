# Budget policy: authenticated hosted/native development products

The four development objects emitted by checked hosted B1 are byte-identical
to their corresponding native N1 objects. All twelve linked section checks
(`.text`, `.data`, `.rodata` for each case) also pass. The cases are
`coverage-map-churn-32`, `coverage-expression-32`, `tree-bitonic`, and `lexer`.
This is a four-case comparison; it does not claim cross-host identity of all
45 native qualification products.

The compiler parents have different bytes, so the original exact-parent
comparison was not relaxed. A separate source audit reconstructs the actual
hosted source from its recorded selected-source01 snapshot, absent Phase190
API bridge declarations, exact `x193f_plan` replacement, and budget module.
The reconstruction equals all 1,799,073 hosted source bytes. The native
producer is bound to selected-source02, SHA256
`fd95adc1bdc210bc3827c9dd3536b8e7289fb60c4e983f0e008714665239428a`.

Using the original Phase147 conservative lexical dependency extractor and
Phase175 API transport rules, both seven-root compiler closures contain
exactly 5,272 declarations with identical bytes apart from outer CR/LF
separators. This comprises 5,267 declarations shared with native source and
five exact API bridge wrappers. Every shared declaration in the complete
sources also matches. Comments, annotations, body text, and internal
whitespace remain in the comparison. The only hosted declarations outside
the compiler closure are `x193fb_controls` and `x193fb_row`.

The API view removes the CLI `main`, exactly as the existing preparation
does, before extracting the seven roots. Without that original transport
step, the conservative lexical extractor interprets local words named
`main` as references to the CLI declaration and retains unrelated IO
wrappers. No reachable compiler declaration is individually waived.
Source identity is a declaration-level claim after this transport, not a
proof of CLI IO wrapper equivalence or universal compiler correctness.

The product comparison retains Phase190 authentication of checked B1/N1
producer images, source bindings, acquisition and emission receipts,
independent expected-output observations, prepared Base/carrier, target
runtime, complete objects, and linked sections. It authenticates 445 pins
and reports no changed inputs. No compiler, target, assembler, linker, or
disassembler was run; ELF sections were read with the existing Python
reader.

Reproduce offline from the repository root, using a fresh output directory:

```sh
python3 selfhost/tests/phase193/compare-hosted-subset-v3.py \
  --left selfhost/build/phase193/budget-dev-build01/programs.manifest.json \
  --right selfhost/build/phase193/budget-native45-01/programs.manifest.json \
  --out selfhost/build/phase193/budget-hosted-native-products-fresh
```

The comparator calls `budget-core-equivalence-v2.py`; the core proof is
recomputed before product comparison. Durable receipts are
`implementation/phase193/budget-source-core-audit.json` and
`implementation/phase193/budget-hosted-native-products.json`, copied
byte-for-byte from `budget-hosted-native-products02`. The initial
`budget-hosted-native-products01` refusal is preserved: its reconstruction
did not reparse the bridged source before declaration extraction and hence
failed exact bytes on blank separators. The v2 audit follows the original
preparation's parsing boundary and passes the stronger exact reconstruction.
