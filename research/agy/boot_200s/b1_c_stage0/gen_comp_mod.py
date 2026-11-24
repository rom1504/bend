#!/usr/bin/env python3
"""Generate comp_mod.ts from read-only bend2/comp.ts for fast modular C emission."""
from __future__ import annotations
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
OUT = ROOT / "research/agy/boot_200s/b1_c_stage0/comp_mod.ts"


def generate() -> None:
    src = (ROOT / "bend2/comp.ts").read_text(encoding="utf-8")
    src = src.replace('from "./bend.ts"', f'from "{ROOT}/bend2/bend.ts"')

    # 1. Global SKIP_SET for modular stub exclusion
    anchor = "let FL: File;"
    assert anchor in src, "let FL not found"
    src = src.replace(anchor, "let FL: File;\nlet SKIP_SET: Set<string> = new Set();", 1)

    # 2. Uniform cross-module ABI: all params owned, all ctrs hot, uniform Array flag -> 1-pass c_units!
    old_fact = """function fact(kind: string, k = ""): boolean {
  return FL.facts.has(kind + " " + k);
}"""
    assert old_fact in src, "fact not found"
    src = src.replace(old_fact, """function fact(kind: string, k = ""): boolean {
  if (kind === "ctr" || kind === "own") return true;
  if (kind === "type" && k === "Array") return false;
  return FL.facts.has(kind + " " + k);
}""", 1)

    # 3. Never classify stubbed defs as flat/spin
    old_flat = "function flat_of(k: Name): boolean {"
    assert old_flat in src, "flat_of not found"
    src = src.replace(old_flat, "function flat_of(k: Name): boolean {\n  if (SKIP_SET.has(k)) return false;", 1)

    # 4. Disable single-call-site inlining (avoids mutual-recursion inlining in modular splits and speeds up emit)
    old_once = "const once = FL.sites.get(ck.k) === 1 && !ck.b && !def_foreign(ck.tld)"
    assert old_once in src, "once not found"
    src = src.replace(old_once, "const once = false && FL.sites.get(ck.k) === 1 && !ck.b && !def_foreign(ck.tld)", 1)

    # 4b. Box large user ADTs (> 4 words) instead of flattening up to WIDE=247 words!
    #     Keep Base types (tld.b) unboxed so U32/Char word-bit matches work cleanly.
    #     Fixes m05 arity>247 crash and cuts m06 from 36 MB / 7.5 GiB / 41s down to ~3 MB / 400 MiB / 4s!
    old_wide = "return lay.ks.length > WIDE ? BOX : lay;"
    assert old_wide in src, "lay_of WIDE check not found"
    src = src.replace(old_wide, "return (!tld.b && lay.ks.length > 4) || lay.ks.length > WIDE ? BOX : lay;", 1)

    # 5. Export compile_module(book, roots, skipFlatSet, noEmitSet)
    old_export = "export function compile_book(book: Bend.Book): string {"
    assert old_export in src, "compile_book not found"
    mod_fn = """
export function compile_module(book: Bend.Book, roots: string[], skipFlatSet: Set<string>, noEmitSet: Set<string>): string {
  SKIP_SET = skipFlatSet;
  FL = file_new(book, false);
  file_owned();
  const monoRoots = roots.filter((k) => {
    const t = book.tlds[k];
    return t !== undefined && t.$ === "Def" && t.v !== null && t.x === 0;
  });
  file_book([...monoRoots, ...RUNTIME_ADTS]);
  for (const [k, tld] of [...done_defs().reverse(), ...done_defs(def_foreign)]) {
    if (noEmitSet.has(k)) continue;
    unit_new(k, () => {
      const [dl, vals] = emit_open(k);
      FL.unit!.segs.push(dl.seg);
      if (def_foreign(tld)) {
        emit_put(dl, null, val_new([ctr_build(dl, k, dl.seg.params)], BOX));
      } else {
        emit_body(dl, fun_of(k).h!, tld.T, vals, null);
      }
    });
  }
  FL.units.forEach(unit_emit);
  const us = [...FL.units.values()];
  const all = us.flatMap((u) => u.segs);
  const clos = us.flatMap((u) => [...u.clos]);
  const segs = all.filter((s) => !s.native);
  const spins = all.filter((s) => s.native);
  const tabs = c_header(segs, clos);
  const img = [`CONSTV u64 STAT_IMG[] = { ${FL.img.join(", ") || 0} };`,
    spins.map((s) => s.head + ";").join("\\n"),
    ...spins.map((s) => s.lines.join("\\n"))].join("\\n\\n");
  const text = segs.map((seg) => {
    const out = [`  WL_CASE(${seg.fid})`, ...seg_text([...seg_take(seg),
      "WL_OPEN", ...seg.spin ? ["WL_SPIN", ...seg.lines, "WL_SPUN"]
        : seg.lines], 2), "  }}"];
    return ["#if !DEVICE", ...out, "#endif"].join("\\n");
  }).join("\\n\\n");
  const reqs = [...FL.effs.values()].map(([m, src]) => c_ids(src, m)).join("");
  const raw = c_ids(runtime_c("\\0", "\\0", "\\0", "\\0")).split("\\0");
  const c = String.raw({ raw }, tabs, img, text, reqs);
  SKIP_SET = new Set();
  FL = file_new(book, false);
  return c;
}

""" + old_export
    src = src.replace(old_export, mod_fn, 1)
    OUT.write_text(src, encoding="utf-8")


if __name__ == "__main__":
    generate()
    print(f"Generated {OUT} ({OUT.stat().st_size} bytes)")
