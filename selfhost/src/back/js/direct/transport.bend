
# Module: src/back/js/direct/transport.bend:4
type JDTextNote is Data:
  JDTextUse{+id: String}
  JDTextRef{+name: String}

# Module: src/back/js/direct/transport.bend:8
type JDText is Data:
  JDTextLeaf{+code: String, +notes: List<&2,JDTextNote>, +size: U32, +safe: Bool}
  JDTextJoin{+left: JDText, +right: JDText, +size: U32, +safe: Bool}

# Module: src/back/js/direct/transport.bend:12
type JDTextMeta is Data:
  JDTextMeta{+notes: List<&2,JDTextNote>, +size: U32, +safe: Bool}

# Module: src/back/js/direct/transport.bend:16
@unsafe
def jd_text_size(+text: JDText) -> U32:
  match text:
    case JDTextLeaf{code, notes, size, safe}: size
    case JDTextJoin{left, right, size, safe}: size

# Module: src/back/js/direct/transport.bend:22
@unsafe
def jd_text_safe(+text: JDText) -> Bool:
  match text:
    case JDTextLeaf{code, notes, size, safe}: safe
    case JDTextJoin{left, right, size, safe}: safe

# Module: src/back/js/direct/transport.bend:28
@unsafe
def jd_text_empty(+text: JDText) -> Bool:
  U32.is_eq(jd_text_size(text), 0)

# The original reach scanner admits at most 2,097,152 code points. Saturating
# size preserves that refusal boundary without overflowing concatenation sums.

# Module: src/back/js/direct/transport.bend:34
@unsafe
def jd_text_add(+a: U32, +b: U32) -> U32:
  U32.min(U32.add(a, b), 2097153)

# Module: src/back/js/direct/transport.bend:38
@unsafe
def jd_text_cat(+left: JDText, +right: JDText) -> JDText:
  kc(JDText, jd_text_empty(left), u => right, u =>
    kc(JDText, jd_text_empty(right), v => left, v =>
      JDTextJoin{left, right, jd_text_add(jd_text_size(left), jd_text_size(right)),
        jd_text_safe(left) && jd_text_safe(right)}))

# Module: src/back/js/direct/transport.bend:45
@unsafe
def jd_text_many(+texts: List<&2,JDText>) -> JDText:
  match texts:
    case Nil{}: JDTextLeaf{"", Nil{}, 0, True{}}
    case Con{head, rest}: jd_text_cat(head, jd_text_many(rest))

# Complete marker recognition is bounded by its nine-character introducer.
# A raw leaf beginning with a complete or partial introducer is unsafe because
# an earlier leaf might provide the physical newline. Empty leaves are inert.

# Module: src/back/js/direct/transport.bend:54
@unsafe
def jd_text_prefix(+text: String, +pattern: String) -> Bool:
  match pattern:
    case SNil{}: True{}
    case SCon{p, more}: jd_text_prefix_char(text, p, more)

# Module: src/back/js/direct/transport.bend:60
@unsafe
def jd_text_prefix_char(+text: String, +expected: Char, +more: String) -> Bool:
  match text:
    case SNil{}: True{}
    case SCon{h, rest}: kc(Bool, Char.is_eq(h, expected), u => jd_text_prefix(rest, more), u => False{})

# Internal literal fragments carry their compiler-known code-point size.
# These call sites are fixed source literals with no USE/REF marker.

# Module: src/back/js/direct/transport.bend:68
@unsafe
def jd_text_literal(+code: String, +size: U32) -> JDText:
  JDTextLeaf{code, Nil{}, U32.min(size, 2097153), True{}}

# Module: src/back/js/direct/transport.bend:72
@unsafe
def jd_text_raw(+code: String) -> JDText:
  jd_text_raw_done(code, jd_text_scan(code, Nil{}, 0,
    Bool.not(Bool.not(p88_string_eq(code, "")) &&
      (jd_text_prefix(code, "/*JD_USE:") || jd_text_prefix(code, "/*JD_REF:")))))

# Module: src/back/js/direct/transport.bend:78
@unsafe
def jd_text_raw_done(+code: String, +meta: JDTextMeta) -> JDText:
  match meta:
    case JDTextMeta{notes, size, safe}:
      JDTextLeaf{code, List.reverse(&2,JDTextNote, notes), size, safe}

# Module: src/back/js/direct/transport.bend:84
@unsafe
def jd_text_scan(+text: String, +notes: List<&2,JDTextNote>, +size: U32, +safe: Bool) -> JDTextMeta:
  kc(JDTextMeta, U32.is_gt(size, 2097152), u => JDTextMeta{notes, 2097153, False{}},
    u => jd_text_scan_more(text, notes, size, safe))

# Module: src/back/js/direct/transport.bend:89
@unsafe
def jd_text_scan_more(+text: String, +notes: List<&2,JDTextNote>, +size: U32, +safe: Bool) -> JDTextMeta:
  match text:
    case SNil{}: JDTextMeta{notes, size, safe}
    case SCon{h, rest}:
      kc(JDTextMeta, Char.is_eq(h, '\n'), u =>
        jd_text_line(rest, notes, jd_text_add(size, 1), safe), u =>
        jd_text_scan(rest, notes, jd_text_add(size, 1), safe))

# Module: src/back/js/direct/transport.bend:98
@unsafe
def jd_text_line(+text: String, +notes: List<&2,JDTextNote>, +size: U32, +safe: Bool) -> JDTextMeta:
  kc(JDTextMeta, String.starts_with(text, "/*JD_USE:"), u =>
    jd_text_marker(String.drop(text, 9n), "", notes, jd_text_add(size, 9), safe, True{}), u =>
  kc(JDTextMeta, String.starts_with(text, "/*JD_REF:"), u =>
    jd_text_marker(String.drop(text, 9n), "", notes, jd_text_add(size, 9), safe, False{}), u =>
    jd_text_scan(text, notes, size, safe &&
      (p88_string_eq(text, "") || Bool.not(jd_text_prefix(text, "/*JD_USE:") || jd_text_prefix(text, "/*JD_REF:"))))))

# Module: src/back/js/direct/transport.bend:107
@unsafe
def jd_text_marker(+text: String, +rev: String, +notes: List<&2,JDTextNote>, +size: U32, +safe: Bool, +use: Bool) -> JDTextMeta:
  kc(JDTextMeta, U32.is_gt(size, 2097152), u => JDTextMeta{notes, 2097153, False{}},
    u => jd_text_marker_more(text, rev, notes, size, safe, use))

# Module: src/back/js/direct/transport.bend:112
@unsafe
def jd_text_marker_more(+text: String, +rev: String, +notes: List<&2,JDTextNote>, +size: U32, +safe: Bool, +use: Bool) -> JDTextMeta:
  match text:
    case SNil{}: JDTextMeta{notes, size, False{}}
    case SCon{h, rest}: kc(JDTextMeta, Char.is_eq(h, '*'), u =>
      jd_text_marker_end(rest, String.reverse(rev), notes, jd_text_add(size, 1), safe, use), u =>
      kc(JDTextMeta, Char.is_eq(h, '\n'), v =>
        jd_text_scan(rest, notes, jd_text_add(size, 1), False{}), v =>
        jd_text_marker(rest, SCon{h, rev}, notes, jd_text_add(size, 1), safe, use)))

# Module: src/back/js/direct/transport.bend:122
@unsafe
def jd_text_marker_end(+text: String, +name: String, +notes: List<&2,JDTextNote>, +size: U32, +safe: Bool, +use: Bool) -> JDTextMeta:
  match text:
    case SNil{}: JDTextMeta{notes, size, False{}}
    case SCon{h, rest}: kc(JDTextMeta, Char.is_eq(h, '/'), u =>
      jd_text_scan(rest, Con{kc(JDTextNote, use, v => JDTextUse{name}, v => JDTextRef{name}), notes},
        jd_text_add(size, 1), safe && kc(Bool, use, v => jd_inline_digits(name),
          v => String.starts_with(name, "$jd$") && jd_text_ref_chars(String.drop(name, 4n)))),
      u => jd_text_scan(text, notes, size, False{}))

# Module: src/back/js/direct/transport.bend:132
@unsafe
def jd_text_ref_chars(+text: String) -> Bool:
  match text:
    case SNil{}: True{}
    case SCon{h, rest}:
      +n = Char.to_u32(h)
      kc(Bool, Char.is_eq(h, '_') ||
        (U32.is_ge(n, 48) && U32.is_le(n, 57)) ||
        (U32.is_ge(n, 65) && U32.is_le(n, 90)) ||
        (U32.is_ge(n, 97) && U32.is_le(n, 122)),
        u => jd_text_ref_chars(rest), u => False{})

# Explicit worklists bound native stack depth independently of rope skew.

# Module: src/back/js/direct/transport.bend:145
@unsafe
def jd_text_render(+text: JDText) -> String:
  jd_text_render_work([text], "")

# Module: src/back/js/direct/transport.bend:149
@unsafe
def jd_text_render_work(+todo: List<&2,JDText>, +suffix: String) -> String:
  match todo:
    case Nil{}: suffix
    case Con{head, rest}:
      match head:
        case JDTextLeaf{code, notes, size, safe}: jd_text_render_work(rest, code ++ suffix)
        case JDTextJoin{left, right, size, safe}: jd_text_render_work(Con{right, Con{left, rest}}, suffix)

# Module: src/back/js/direct/transport.bend:158
@unsafe
def jd_text_used(+text: JDText, +id: U32) -> Bool:
  kc(Bool, jd_text_safe(text), u => jd_text_used_work([text], U32.show(id)),
    u => String.contains(jd_text_render(text), jd_use(id)))

# Module: src/back/js/direct/transport.bend:163
@unsafe
def jd_text_used_work(+todo: List<&2,JDText>, +id: String) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{head, rest}:
      match head:
        case JDTextLeaf{code, notes, size, safe}: kc(Bool, jd_text_note_used(notes, id),
          u => True{}, u => jd_text_used_work(rest, id))
        case JDTextJoin{left, right, size, safe}: jd_text_used_work(Con{left, Con{right, rest}}, id)

# Module: src/back/js/direct/transport.bend:173
@unsafe
def jd_text_note_used(+notes: List<&2,JDTextNote>, +id: String) -> Bool:
  match notes:
    case Nil{}: False{}
    case Con{head, rest}:
      match head:
        case JDTextUse{value}: kc(Bool, p88_string_eq(value, id), u => True{}, u => jd_text_note_used(rest, id))
        case JDTextRef{name}: jd_text_note_used(rest, id)

# Module: src/back/js/direct/transport.bend:182
@unsafe
def jd_text_refs(+names: List<&2,KDef>, +text: JDText) -> Maybe<&2,List<&2,String>>:
  kc(Maybe<&2,List<&2,String>>, U32.is_le(jd_text_size(text), 2097152), u =>
    kc(Maybe<&2,List<&2,String>>, jd_text_safe(text), v =>
      jd_text_refs_work(names, [text], Nil{}, missing()), v =>
      jd_reach_refs(names, jd_text_render(text), False{}, 2097152, Nil{})), u => None{})

# Module: src/back/js/direct/transport.bend:189
@unsafe
def jd_text_refs_work(+names: List<&2,KDef>, +todo: List<&2,JDText>, +out: List<&2,String>, +seen: KDef) -> Maybe<&2,List<&2,String>>:
  match todo:
    case Nil{}: Some{out}
    case Con{head, rest}:
      match head:
        case JDTextLeaf{code, notes, size, safe}: jd_text_refs_notes(names, notes, rest, out, seen)
        case JDTextJoin{left, right, size, safe}: jd_text_refs_work(names, Con{left, Con{right, rest}}, out, seen)

# Module: src/back/js/direct/transport.bend:198
@unsafe
def jd_text_refs_notes(+names: List<&2,KDef>, +notes: List<&2,JDTextNote>, +todo: List<&2,JDText>, +out: List<&2,String>, +seen: KDef) -> Maybe<&2,List<&2,String>>:
  match notes:
    case Nil{}: jd_text_refs_work(names, todo, out, seen)
    case Con{head, rest}:
      match head:
        case JDTextUse{id}: jd_text_refs_notes(names, rest, todo, out, seen)
        case JDTextRef{name}: jd_text_refs_found(names, rest, todo, out, seen, lookup(names, name))

# Module: src/back/js/direct/transport.bend:207
@unsafe
def jd_text_refs_found(+names: List<&2,KDef>, +notes: List<&2,JDTextNote>, +todo: List<&2,JDText>, +out: List<&2,String>, +seen: KDef, +d: KDef) -> Maybe<&2,List<&2,String>>:
  kc(Maybe<&2,List<&2,String>>, p88_string_eq(dk(d), "JDReachName"), u =>
    kc(Maybe<&2,List<&2,String>>, p88_string_eq(dk(index_find(seen, dn(d), index_hash(dn(d), 2166136261), 32)), "Absent"),
      v => jd_text_refs_notes(names, notes, todo, Con{nm(dv(d)), out}, index_set(seen, d, index_hash(dn(d), 2166136261), 32)),
      v => jd_text_refs_notes(names, notes, todo, out, seen)), u => None{})
