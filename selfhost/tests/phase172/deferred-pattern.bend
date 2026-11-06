# Private typed rows retain the original body and ordered pending substitutions.
# Root-owned checking/equality gates remain required before any speed claim.
type P172DPSub is Data:
  P172DPSub{+id: U32, +value: KTerm}

type P172DPRow is Data:
  P172DPRow{+patterns: List<&2,KTerm>, +body: KTerm, quantity: U32,
    +pending: List<&2,P172DPSub>}

law p172dp_apply:
  for +term: KTerm
  for +operations: List<&2,P172DPSub>
  KTerm

law p172dp_children:
  for +terms: List<&2,KTerm>
  for +operations: List<&2,P172DPSub>
  List<&2,KTerm>

law p172dp_variable:
  for +term: KTerm
  for +remaining: List<&2,P172DPSub>
  for +all: List<&2,P172DPSub>
  KTerm

law p172dp_match:
  for +heads: List<&2,KTerm>
  for +rows: List<&2,P172DPRow>
  for +vars: List<&2,KTerm>
  for +next: U32
  for +origin: KTerm
  FFlatten

law p172dp_column:
  for +head: KTerm
  for +heads: List<&2,KTerm>
  for +rows: List<&2,P172DPRow>
  for +vars: List<&2,KTerm>
  for +next: U32
  for +origin: KTerm
  FFlatten

law p172dp_split:
  for +head: KTerm
  for +heads: List<&2,KTerm>
  for +rows: List<&2,P172DPRow>
  for +variable: KTerm
  for +vars: List<&2,KTerm>
  for +constructor: KTerm
  for +next: U32
  for +origin: KTerm
  FFlatten

law p172dp_fields_done:
  for +head: KTerm
  for +heads: List<&2,KTerm>
  for +rows: List<&2,P172DPRow>
  for +variable: KTerm
  for +vars: List<&2,KTerm>
  for +constructor: KTerm
  for +fields: FFields
  for +origin: KTerm
  FFlatten

law p172dp_hit_done:
  for +head: KTerm
  for +heads: List<&2,KTerm>
  for +rows: List<&2,P172DPRow>
  for +variable: KTerm
  for +vars: List<&2,KTerm>
  for +constructor: KTerm
  for +hit: FFlatten
  for +origin: KTerm
  FFlatten

# A node that is not replaced preserves its original metadata, and its children
# are produced once. A replaced variable sees only the subsequent operations.
# Earlier child work is discarded by the original replacement and need not exist.
@unsafe
def p172dp_apply(term, operations):
  match operations:
    case Nil{}: term
    case Con{operation, rest}:
      f_choose(KTerm, f_eq(tg(term), "Var"),
        u => p172dp_variable(term, operations, operations),
        u => k_with_children(term, p172dp_children(ks(term), operations)))

@unsafe
def p172dp_variable(term, remaining, all):
  match remaining:
    case Nil{}: k_with_children(term, p172dp_children(ks(term), all))
    case Con{operation, +rest}:
      match operation:
        case P172DPSub{id, value}:
          f_choose(KTerm, U32.is_eq(ix(term), id),
            u => p172dp_apply(f_pattern_value(value, kb(term), ke(term)), rest),
            u => p172dp_variable(term, rest, all))

@unsafe
def p172dp_children(terms, operations):
  match terms:
    case Nil{}: []
    case Con{term, rest}: Con{p172dp_apply(term, operations), p172dp_children(rest, operations)}

@unsafe
def p172dp_rows(rows: List<&2,KTerm>) -> List<&2,P172DPRow>:
  match rows:
    case Nil{}: []
    case Con{+row, rest}:
      Con{P172DPRow{ks(kid(row, 0)), kid(row, 1), qt(row), []}, p172dp_rows(rest)}

@unsafe
def p172dp_pattern(row: P172DPRow) -> KTerm:
  match row:
    case P172DPRow{patterns, body, quantity, pending}: terms_at(patterns, 0)

@unsafe
def p172dp_first(rows: List<&2,P172DPRow>) -> KTerm:
  match rows:
    case Nil{}: {KTerm{"Absent", "", 0, 0, [], [], 0, 0} : KTerm}
    case Con{+row, rest}:
      +pattern = p172dp_pattern(row)
      f_choose(KTerm, f_eq(tg(pattern), "Ctr"), u => pattern, u => p172dp_first(rest))

@unsafe
def p172dp_mark(rows: List<&2,P172DPRow>, quantity: U32) -> U32:
  match rows:
    case Nil{}: quantity
    case Con{row, rest}:
      +pattern = p172dp_pattern(row)
      p172dp_mark(rest, f_choose(U32, f_eq(tg(pattern), "Var") && U32.is_eq(qt(pattern), 2),
        u => 2, u => quantity))

@unsafe
def p172dp_var_rows(rows: List<&2,P172DPRow>, +variable: KTerm) -> List<&2,P172DPRow>:
  match rows:
    case Nil{}: []
    case Con{row, rest}:
      match row:
        case P172DPRow{+patterns, body, +quantity, +pending}:
          Con{P172DPRow{f_tail_terms(patterns), body, quantity,
            f_choose(List<&2,P172DPSub>, U32.is_eq(quantity, 0), u => pending,
              u => Con{P172DPSub{ix(terms_at(patterns, 0)), variable}, pending})},
            p172dp_var_rows(rest, variable)}

@unsafe
def p172dp_hit_row(row: P172DPRow, +constructor: KTerm, +fields: List<&2,KTerm>, +variable: KTerm) -> P172DPRow:
  match row:
    case P172DPRow{+patterns, body, +quantity, +pending}:
      +pattern = terms_at(patterns, 0)
      +is_variable = f_eq(tg(pattern), "Var")
      P172DPRow{norm_join(f_choose(List<&2,KTerm>, is_variable, u => fields, u => ks(pattern)),
          f_tail_terms(patterns)), body, quantity,
        f_choose(List<&2,P172DPSub>, U32.is_eq(quantity, 0), u => pending,
          u => Con{P172DPSub{ix(variable), kt_span("Ctr", nm(constructor), 0, 1, fields, kb(constructor), ke(constructor))},
            f_choose(List<&2,P172DPSub>, is_variable,
              u => Con{P172DPSub{ix(pattern), variable}, pending}, u => pending)})}

@unsafe
def p172dp_hit_rows(rows: List<&2,P172DPRow>, +constructor: KTerm, +fields: List<&2,KTerm>, +variable: KTerm) -> List<&2,P172DPRow>:
  match rows:
    case Nil{}: []
    case Con{+row, +rest}:
      +pattern = p172dp_pattern(row)
      f_choose(List<&2,P172DPRow>, f_eq(tg(pattern), "Var") || f_eq(nm(pattern), nm(constructor)),
        u => Con{p172dp_hit_row(row, constructor, fields, variable), p172dp_hit_rows(rest, constructor, fields, variable)},
        u => p172dp_hit_rows(rest, constructor, fields, variable))

@unsafe
def p172dp_miss_rows(rows: List<&2,P172DPRow>, +name: String) -> List<&2,P172DPRow>:
  match rows:
    case Nil{}: []
    case Con{+row, +rest}:
      +pattern = p172dp_pattern(row)
      f_choose(List<&2,P172DPRow>, f_eq(tg(pattern), "Ctr") && f_eq(nm(pattern), name),
        u => p172dp_miss_rows(rest, name), u => Con{row, p172dp_miss_rows(rest, name)})

@unsafe
def p172dp_terminal(row: P172DPRow, vars: List<&2,KTerm>, next: U32) -> FFlatten:
  match row:
    case P172DPRow{patterns, body, quantity, pending}:
      ff_flat(p172dp_apply(body, List.reverse(&2,P172DPSub,pending)), vars, next)

@unsafe
def p172dp_entry(heads, rows, vars, next, origin):
  p172dp_match(heads, p172dp_rows(rows), vars, next, origin)

@unsafe
def p172dp_match(heads, rows, vars, next, origin):
  match heads:
    case Nil{}:
      match rows:
        case Nil{}: FFlatten{kt_span("Efq", "", 0, 0, [], kb(origin), ke(origin)), next}
        case Con{row, rest}: p172dp_terminal(row, vars, next)
    case Con{+head, +heads}:
      f_choose(FFlatten, f_eq(tg(p172dp_first(rows)), "Absent") && Bool.not(List.is_empty(&2,P172DPRow,rows)) &&
        ff_variable(head) && f_has_id(vars, ix(head)),
        u => p172dp_match(heads, p172dp_var_rows(rows, head), f_mark_vars(vars, ix(head), p172dp_mark(rows, qt(head))), next, origin),
        u => p172dp_column(head, heads, rows, vars, next, origin))

@unsafe
def p172dp_column(head, heads, rows, vars, next, origin):
  match vars:
    case Nil{}: FFlatten{f_match_error(head, origin), next}
    case Con{+variable, +vars}:
      f_choose(FFlatten, ff_variable(head) && U32.is_eq(ix(head), ix(variable)),
        u => p172dp_split(head, heads, rows, variable, vars, p172dp_first(rows), next, origin),
        u => ff_lam(variable, p172dp_match(Con{head, heads}, rows, vars, next, origin)))

@unsafe
def p172dp_split(head, heads, rows, variable, vars, constructor, next, origin):
  f_choose(FFlatten, f_eq(tg(constructor), "Absent"),
    u => FFlatten{kt_span("Efq", "", 0, 0, [], kb(origin), ke(origin)), next},
    u => p172dp_fields_done(head, heads, rows, variable, vars, constructor,
      ff_fields(ks(constructor), p172dp_mark(rows, qt(variable)), next), origin))

@unsafe
def p172dp_fields_done(head, heads, rows, variable, vars, constructor, fields, origin):
  match fields:
    case FFields{+fields, next}:
      p172dp_hit_done(head, heads, rows, variable, vars, constructor,
        p172dp_match(norm_join(fields, heads), p172dp_hit_rows(rows, constructor, fields, variable),
          norm_join(fields, vars), next, origin), origin)

@unsafe
def p172dp_hit_done(head, heads, rows, variable, vars, constructor, hit, origin):
  match hit:
    case FFlatten{+hit, +next}:
      f_choose(FFlatten, ff_failed(hit), u => FFlatten{hit, next},
        u => ff_miss_done(constructor, hit,
          p172dp_match(Con{head, heads}, p172dp_miss_rows(rows, nm(constructor)), Con{variable, vars}, next, origin), origin))
