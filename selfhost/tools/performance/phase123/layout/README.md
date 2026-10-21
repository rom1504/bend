# Phase123 narrow finite-Sigma admission prototype

Offline, unexecuted prototype. No production hook or selection change.
`strict-subterm01.bend` replaces only `nq_layout_leaf`. All existing caller
checks remain: exact ADT/constructor identity, one constructor, live fields,
matching result type and absence of prior-field dependencies. Ordinary opaque
fields retain the original rule. The new exception admits only same-name Sigma
fields that occur as a **strict syntactic subterm** of their enclosing four-argument
Sigma instance. Both type syntax trees together are bounded to256nodes before
comparison. The traversal cannot expand aliases or unfold recursive definitions.

Strict subterm descent prevents admitting the exact enclosing recursive type.
Other ADT names remain under the original direct-recursion refusal. Inner fields
remain ordinary owned Terms; this change unboxes one shell, not its complete
transitive layout. Unknown or alias-expanded syntax that is not visibly a proper
subterm remains boxed. Dependency checking is unchanged; no ownership or ABI rule
is weakened. This deliberately conservative sufficient condition may reject useful
finite aliases. Admission and checked-source tests must establish whether it
actually recognizes the frozen original RLE type before any runtime campaign.

Prepare an isolated compiler using the existing exact-declaration assembler:

```sh
python3 selfhost/tools/performance/phase123/prepare.py \
  --out selfhost/build/phase123/layout-source01 \
  --module selfhost/tools/performance/phase123/layout/strict-subterm01.bend \
  --overrides nq_layout_leaf
```

No command above has been run by this audit. The root's serial checked-API and
emission lane should first query original RLE layout and emit the three ordinary
fixtures in `cases.json`. Check optimized activation separately from exact output.
The recursive fixture requires a layout query on `Knot123`; its trivial main does
not prove refusal. The dependent fixture requires the analogous Packet123 query.
The nested fixture checks wraparound, retained heap lifetime and complete returned
values. These newly authored source fixtures have not yet been parsed or checked;
preserve any rejected version and correct by adding a new version.

V2 ceiling inspection: outer SSA line1117 has the existing product worker with
four arguments xs,cur,count,acc; full SSA line1117 has the direct worker with the
same lanes. Both backedges are state-shell-free. The outer source rewrite made its
remaining inner pair eligible for existing one-level flattening. This does **not**
prove that accepting the original outer pair also recursively flattens the inner
pair; inspect emitted calls and state ctor/take counts. The measured10–14% ceiling
therefore bounds a larger source restructuring; this small repair may win less.
Do not pursue recursive layout infrastructure on this evidence alone.

Frozen evidence: `selfhost/build/phase118/p123-rle-emit02/` contains the two SSA
files. Parent source and original RLE pins are in the existing Phase123 preparation
and rle-v2 manifests. No target, build, compiler check or native qualification was
performed for this audit.
