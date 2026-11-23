#!/usr/bin/env python3
"""Wave 8: Eliminate cross-TU p111_static_image offset collisions & move local
read-only string/byte tables to .rodata.

Changes in compiler.bend:
1. p112s_constructor: keep P112SPacked (immediate nullary / 1-U32 ctors, zero
   static-image coupling), skip P112SBox interning into the single global
   H[STAT_OFF + offset] table (`p111_static_image`). Boxed constant ctors
   (including String literals `Con{c, rest}`) stay normal `Ctr` terms and lower
   through the standard dynamic constructor path, eliminating all hardcoded
   `0x031082XX` per-TU static-image offsets while staying 100% compatible with
   unmodified runtime-agy.o and single-TU compilation.
2. x188_table_head: emit non-exported alignment-1 read-only tables (including
   local UTF-8 string defs `p111_cid_names_N`, `p111_show_names_N`,
   `p111_effects_N` and arity/flag byte tables) into `.rodata` (PSection{2})
   instead of `.data` (PSection{3}).
"""
from __future__ import annotations

import argparse
from pathlib import Path

OLD_P112S_CTOR = (
    "def p112s_constructor(+constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:\n"
    "  nt_choose(P112STerm,agy_str_eq(tg(term),\"NWord\"),u => P112STerm{term,image},u =>\n"
    "    nt_choose(P112STerm,ns_ctor(constructors,nm(term),terms_len(ks(term))) && ns_constants(ks(term)),u =>\n"
    "      nt_choose(P112STerm,ns_packed(term),v => p112s_packed(term,ks(term),image),v => p112s_intern(term,p112s_fields(ks(term)),image)),\n"
    "      u => P112STerm{term,image}))"
)

NEW_P112S_CTOR = (
    "def p112s_constructor(+constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:\n"
    "  nt_choose(P112STerm,agy_str_eq(tg(term),\"NWord\"),u => P112STerm{term,image},u =>\n"
    "    nt_choose(P112STerm,ns_ctor(constructors,nm(term),terms_len(ks(term))) && ns_constants(ks(term)),u =>\n"
    "      nt_choose(P112STerm,ns_packed(term),v => p112s_packed(term,ks(term),image),v => P112STerm{term,image}),\n"
    "      u => P112STerm{term,image}))"
)

OLD_TABLE_HEAD = (
    "def x188_table_head(+name: String, alignment: U32, exported: Bool) -> X188Seq:\n"
    "  x188_many([X188One{PSection{3}},X188One{PAlign{alignment}},\n"
    "    nt_choose(X188Seq,exported,u => X188One{PGlobal{name}},u => X188Empty{}),\n"
    "    X188One{PType{name,1}},x188_label(name)])"
)

NEW_TABLE_HEAD = (
    "def x188_table_head(+name: String, +alignment: U32, +exported: Bool) -> X188Seq:\n"
    "  x188_many([X188One{PSection{nt_choose(U32,U32.is_eq(alignment,1) && Bool.not(exported) && Bool.not(agy_str_eq(name,\"p111_cid_hot\")),u => 2,u => 3)}},X188One{PAlign{alignment}},\n"
    "    nt_choose(X188Seq,exported,u => X188One{PGlobal{name}},u => X188Empty{}),\n"
    "    X188One{PType{name,1}},x188_label(name)])"
)


def patch_text(src: str) -> str:
    for label, old, new in [
        ("p112s_constructor", OLD_P112S_CTOR, NEW_P112S_CTOR),
        ("x188_table_head", OLD_TABLE_HEAD, NEW_TABLE_HEAD),
    ]:
        count = src.count(old)
        if count != 1:
            raise RuntimeError(f"Expected 1 match for {label}, found {count}")
        src = src.replace(old, new, 1)
    return src


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, required=True)
    ap.add_argument("--dst", type=Path, required=True)
    args = ap.parse_args()
    out = patch_text(args.src.read_text())
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out)
    print(f"[w8_rodata_str] Patched {args.src} -> {args.dst} (disabled P112SBox static-image interning + local align-1 tables -> .rodata)")


if __name__ == "__main__":
    main()
