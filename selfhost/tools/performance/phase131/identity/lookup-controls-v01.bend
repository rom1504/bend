# Exact selected catalogue dispatch, renamed only. Requires read-controls-v01 for original index_find.

@unsafe
def p131il_original_lookup(
  +book: List<&2, KDef>,
  +name: String,
) -> KDef:
  match book:
    case Nil{}:
      missing()
    case Con{d, rest}:
      p131il_original_lookup_cached(d, rest, name, p88_string_eq(dk(d), "BookCache"))

# Module: src/core/term.bend:289

@unsafe
def p131il_original_lookup_cached(
  +d: KDef,
  +rest: List<&2, KDef>,
  +name: String,
  +cached: Bool,
) -> KDef:
  match cached:
    case True{}: p131il_original_index_lookup(d, name)
    case False{}: p131il_original_lookup_named(d, rest, name, p88_string_eq(dn(d), name))

# Module: src/core/term.bend:300

@unsafe
def p131il_original_lookup_named(
  +d: KDef,
  +rest: List<&2, KDef>,
  +name: String,
  +same: Bool,
) -> KDef:
  match same:
    case True{}: d
    case False{}: p131il_original_lookup(rest, name)

# Module: src/core/term.bend:311

@unsafe
def p131il_original_index_lookup(+cache: KDef, +name: String) -> KDef:
  p131ir_original_index_find(index_first(dc(cache)), name, index_hash(name, 2166136261), 32)

# Module: src/core/index.bend:263

@unsafe
def p131il_probe(+book: List<&2,KDef>, +name: String, +old: Bool) -> KDef:
  kc(KDef, old,
    u => p131il_original_lookup(book, name),
    u => lookup(book, name))
