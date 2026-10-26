# Required ELF symbol roles, not globally unique spellings

The final03 N2 serial-runtime Lexer capture produced its exact expected QBE.
Offline owner binding failed before any full capture because the ELF legally
contains both of these local symbols:

| Name | Address | Kind/section |
| --- | --- | --- |
| `p111_fid_arity` | `0xf61eb0` | FUNC, executable `.text` |
| `p111_fid_arity` | `0xfeda20` | zero-size NOTYPE, allocated `.data` |

The generic binder previously built a single name→address dictionary for every
defined symbol and rejected the unrelated collision. Neither choosing the first
entry nor permitting every ambiguous name would preserve its contract.

The corrected `attribute.py` reads actual ELF64 section headers and retains
separate function/data address sets. Descriptor and segment-table queries require
OBJECT/NOTYPE labels in allocated file-backed non-executable non-TLS sections.
Generated function queries require FUNC/NOTYPE labels in allocated executable
non-TLS sections. Duplicate symbol-table rows at the same address agree. More
than one address in a queried role still raises an ambiguity error; unsupported
roles do not masquerade as a successful lookup. Actual descriptor words and
every FID pointer remain independently checked.

The original `attribute.py`, original tests and failed stage report are preserved
under `final03-stages01/elf-binding-repair01`. Nineteen attribution tests and ten
stage tests pass. New synthetic ELF controls exercise descriptor/function name
collisions, same-role ambiguity, unqueried ambiguous names, repeated symbol-table
rows, wrong sections, TLS/NOBITS/nonallocated data, unsupported function kinds
and truncated section headers. Existing pointer-order corruption still fails.

`pilot-stages02.json` reanalyzes the **same** capture and passes exact output,
required marker order and actual ELF/FID binding with 179 samples. The report
pins the repaired binding method. Such a short sample profile remains descriptive;
this repair does not grant it quantitative stage attribution. No compiler source,
runtime, binary, capture or oracle changed and no target was rerun.

[Receipt and method identities](../../selfhost/build/phase144/final03-stages01/elf-binding-repair01/report.json).
The root can now run the prepared full capture after this successful small gate.
