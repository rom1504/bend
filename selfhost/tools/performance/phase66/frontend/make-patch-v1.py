#!/usr/bin/env python3
"""Prepare the Phase66 frontend migration without changing production sources."""
from pathlib import Path
import difflib
import hashlib
import json

ROOT = Path(__file__).resolve().parents[5]
OUT = Path(__file__).resolve().parent / "candidate-v1"
assert not OUT.exists(), f"preserve existing candidate: {OUT}"
OUT.mkdir()
changes = {}


def change(name, before, after):
    original = changes.get(name, (ROOT / name).read_text())
    assert original.count(before) == 1, (name, before[:120], original.count(before))
    changes[name] = original.replace(before, after)


name = "selfhost/src/core/term.bend"
change(name, "# First-order trusted core. Binder identifiers are globally unique.", """# Module identity uses ns:name; only external output replaces its first colon.
@unsafe
def name_key(+name: String) -> String:
  match name:
    case SNil{}: ""
    case SCon{c, rest}: kc(String, Char.is_eq(c, ':'), u => "." ++ rest, u => SCon{c, name_key(rest)})

# First-order trusted core. Binder identifiers are globally unique.""")

name = "selfhost/src/load/modules.bend"
change(name, 'u => ns ++ "." ++ name)', 'u => ns ++ ":" ++ name)')
change(name, 'u => nm(im) ++ "." ++ f_drop_prefix(name, nm(kid(im, 0)) ++ ".")', 'u => nm(im) ++ ":" ++ f_drop_prefix(name, nm(kid(im, 0)) ++ ".")')

name = "selfhost/src/core/pretty.bend"
change(name, """def kp_alias_name(+aliases: List<&2,KTerm>, +name: String) -> String:
  match aliases:
    case Nil{}: name
    case Con{im, rest}:
      kc(String, Bool.not(List.is_empty(&2,KTerm,ks(im))) && String.starts_with(name, nm(im) ++ "."), u => nm(kid(im, 0)) ++ String.drop(name, String.length(nm(im))), u => kp_alias_name(rest, name))""", """def kp_alias_name(+aliases: List<&2,KTerm>, +ns: String, +local: String, +name: String) -> String:
  match aliases:
    case Nil{}: name_key(name)
    case Con{im, rest}:
      kc(String, Bool.not(List.is_empty(&2,KTerm,ks(im))) && String.eq(ns, nm(im)), u => nm(kid(im, 0)) ++ "." ++ local, u => kp_alias_name(rest, ns, local, name))

@unsafe
def kp_file_name(+ns: String, +aliases: List<&2,KTerm>, +name: String, +parts: List<&2,String>) -> String:
  match parts:
    case Con{owner, Con{local, rest}}: kc(String, String.eq(ns, owner), u => local, u => kp_alias_name(aliases, owner, local, name))
    case _: kc(String, String.is_empty(ns), u => name, u => kp_alias_name(aliases, "", name, name))""")
change(name, """def kp_name(+env: List<&2,KPName>, +name: String) -> String:
  match env:
    case Nil{}: name
    case Con{KPName{n, id, depth}, rest}: kp_name(rest, name)
    case Con{KPFile{ns, aliases}, rest}:
      kc(String, Bool.not(String.is_empty(ns)) && String.starts_with(name, ns ++ "."), u => String.drop(name, String.length(ns ++ ".")), u => kp_alias_name(aliases, name))""", """def kp_name(+env: List<&2,KPName>, +name: String) -> String:
  match env:
    case Nil{}: name_key(name)
    case Con{KPName{n, id, depth}, rest}: kp_name(rest, name)
    case Con{KPFile{ns, aliases}, rest}: kp_file_name(ns, aliases, name, String.split(name, ':'))""")

name = "selfhost/src/front/declarations.bend"
change(name, 'f_context_statement_more(n, ts, column)', 'f_context_statement_more(n, ts, column, begin)')

name = "selfhost/src/front/contextual.bend"
change(name, '"a term (" ++ nm(head) ++ " takes "', '"a term (" ++ name_key(nm(head)) ++ " takes "')
change(name, """def f_context_statement_more(+term: KTerm, +input: FInput, +column: U32) -> FParsed:
  f_choose(FParsed, f_binding_head(input), u => f_statement_more(FParsed{term, input}),
    u => f_context_write_more(term, input, column, f_context_write(term)))""", """def f_context_statement_more(+term: KTerm, +input: FInput, +column: U32, +begin: U32) -> FParsed:
  f_choose(FParsed, f_binding_head(input), u => f_statement_more(FParsed{term, input}),
    u => f_context_write_more(term, input, column, f_context_write(term, begin)))""")

name = "selfhost/src/front/literals_arrays.bend"
change(name, '# A written Array.set call and index-write sugar have the same body rule.', '# Only index-write syntax starts at its array binder; an explicit call does not.')
change(name, 'def f_context_write(+term: KTerm) -> KTerm:', 'def f_context_write(+term: KTerm, +begin: U32) -> KTerm:')
change(name, 'f_context_write_var(kid(kid(kid(term, 0), 0), 1))', 'f_context_write_var(kid(kid(kid(term, 0), 0), 1), begin)')
change(name, """def f_context_write_var(+term: KTerm) -> KTerm:
  f_choose(KTerm, f_eq(tg(term), "Var") || f_eq(tg(term), "FName"), u => term, u => atom("Absent"))""", """def f_context_write_var(+term: KTerm, +begin: U32) -> KTerm:
  f_choose(KTerm, (f_eq(tg(term), "Var") || f_eq(tg(term), "FName")) && U32.is_gt(begin, 0) && U32.is_eq(kb(term), begin), u => term, u => atom("Absent"))""")

name = "selfhost/src/front/validate.bend"
change(name, '"a declared constructor (unknown: " ++ nm(p) ++ ")"', '"a declared constructor (unknown: " ++ name_key(nm(p)) ++ ")"')
change(name, '"a " ++ nm(p) ++ " pattern with "', '"a " ++ name_key(nm(p)) ++ " pattern with "')
change(name, '"a braced constructor pattern (" ++ nm(p) ++ " is a constructor: write " ++ nm(p) ++ "{}, or rename the binder)"', '"a braced constructor pattern (" ++ name_key(nm(p)) ++ " is a constructor: write " ++ name_key(nm(p)) ++ "{}, or rename the binder)"')
change(name, """    u => fpe_message_at(head, legacy, "a match on a parameter or field (this name is a def or a consumed binder: give the value its own def)"),
    u => f_choose(KTerm, f_eq(tg(head), "Ctr") || f_eq(tg(head), "Literal") || core_literal(head),
      u => fpe_message_at(origin, legacy, "an undestructed scrutinee (this value is already a constructor: bind its fields directly; if an outer match destructed it, fold the pattern into the outer case)"),""", """    u => fpe_match_at(head, head, legacy, 0),
    u => f_choose(KTerm, f_eq(tg(head), "Ctr") || f_eq(tg(head), "Literal") || core_literal(head),
      u => fpe_match_at(head, origin, legacy, 1),""")

name = "selfhost/src/front/parser.bend"
change(name, """def fpe_origin_render(+source: String, +start: U32, +error: KTerm) -> String:
  f_choose(String, U32.is_eq(kb(error), 0),""", """def fpe_origin_render(+source: String, +start: U32, +error: KTerm) -> String:
  f_choose(String, f_eq(tg(kid(error, 0)), "ParseMatch"),
    u => fpe_origin_render(source, start, fpe_match_resolved(source, start, error)),
    u => fpe_origin_plain(source, start, error))

@unsafe
def fpe_origin_plain(+source: String, +start: U32, +error: KTerm) -> String:
  f_choose(String, U32.is_eq(kb(error), 0),""")
changes[name] += """

# Match diagnostics need the original spelling, including parentheses and the
# use-site name of a constructor introduced by an earlier pattern substitution.
# Keep this rejection-only payload until the existing source owner is available.
@unsafe
def fpe_match_at(+head: KTerm, +origin: KTerm, +legacy: String, +mode: U32) -> KTerm:
  kt_span("Error", legacy, 0, 0, [kt_span("ParseMatch", nm(head), mode, 0, Nil{}, kb(head), ke(head))], kb(origin), ke(origin))

@unsafe
def fpe_match_resolved(+source: String, +start: U32, +error: KTerm) -> KTerm:
  +head = kid(error, 0)
  +text = f_choose(String, U32.is_gt(start, 0) && U32.is_ge(kb(head), start) && U32.is_ge(ke(head), kb(head)) && U32.is_le(U32.sub(ke(head), start), dg_width(source)),
    u => fpe_source_slice(source, U32.sub(kb(head), start), U32.sub(ke(head), start)), u => nm(head))
  k_with_children(error, [kt("ParseMessage", fpe_match_message(text, ix(head)), 0, 0, Nil{})])

@unsafe
def fpe_match_message(+text: String, +mode: U32) -> String:
  "'" ++ text ++ "' can't be matched" ++ f_choose(String, U32.is_eq(mode, 0),
    u => " in this position (it is matched after a local statement or after a match on a later binder, it was already matched, or it is a def)",
    u => f_choose(String, (f_ascii_alpha(f_head(text)) || Char.is_eq(f_head(text), '_')) && fpe_name_text(text),
      u => " here (match it in the same match as the pattern that introduced it)",
      u => " (this value is already a constructor: bind its fields directly)"))

@unsafe
def fpe_name_text(+text: String) -> Bool:
  match text:
    case SNil{}: True{}
    case SCon{c, rest}: f_ident(c) && fpe_name_text(rest)

# Authentic parser spans are UTF16 scalar boundaries, not String character counts.
@unsafe
def fpe_source_slice(+source: String, +begin: U32, +end: U32) -> String:
  match source:
    case SNil{}: ""
    case SCon{c, rest}:
      f_choose(String, U32.is_ge(begin, dg_units(c)),
        u => fpe_source_slice(rest, U32.sub(begin, dg_units(c)), U32.sub(end, dg_units(c))),
        u => f_choose(String, U32.is_ge(end, dg_units(c)), u => SCon{c, fpe_source_slice(rest, 0, U32.sub(end, dg_units(c)))}, u => ""))
"""

patches = []
entries = []
for name, after in changes.items():
    before = (ROOT / name).read_text()
    for kind, text in [("before", before), ("after", after)]:
        out = OUT / kind / name
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(text)
    patches.extend(difflib.unified_diff(before.splitlines(True), after.splitlines(True), fromfile="a/" + name, tofile="b/" + name))
    entries.append({"file": name, "beforeSha256": hashlib.sha256(before.encode()).hexdigest(), "afterSha256": hashlib.sha256(after.encode()).hexdigest(), "physicalLineDelta": len(after.splitlines()) - len(before.splitlines())})
(OUT / "candidate.patch").write_text("".join(patches))
reference = ROOT / "selfhost/.bootstrap/upstream-phase66/bend2/bend.ts"
(OUT / "manifest.json").write_text(json.dumps({"kind": "phase66-frontend-isolated-candidate", "productionApplied": False, "targetExecuted": False, "upstream": "059266225b77c8ca256ac6b25ee5c21449bab151", "referenceSha256": hashlib.sha256(reference.read_bytes()).hexdigest(), "files": entries}, indent=2) + "\n")
print(json.dumps({"candidate": str(OUT), "files": len(entries), "physicalLineDelta": sum(row["physicalLineDelta"] for row in entries)}))
