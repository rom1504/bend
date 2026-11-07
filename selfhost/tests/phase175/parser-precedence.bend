# Exact replacement for f_prec. No token representation or lexer change.
# Inspect at most four codepoints, then reject longer words. The old chain
# repeatedly enters String equality even for delimiters and ordinary names.
@unsafe
def f_prec(+s: String) -> U32:
  match s:
    case SNil{}: 0
    case SCon{a,ar}:
      match ar:
        case SNil{}: p175p_prec1(Char.to_u32(a))
        case SCon{b,br}:
          match br:
            case SNil{}: p175p_prec2(Char.to_u32(a),Char.to_u32(b))
            case SCon{c,cr}:
              match cr:
                case SNil{}: p175p_prec3(Char.to_u32(a),Char.to_u32(b),Char.to_u32(c))
                case SCon{d,dr}:
                  match dr:
                    case SNil{}: p175p_prec4(Char.to_u32(a),Char.to_u32(b),Char.to_u32(c),Char.to_u32(d))
                    case SCon{e,er}: 0

@unsafe
def p175p_prec1(a):
  match a:
    case 38: 2
    case 124: 2
    case 60: 5
    case 43: 11
    case 45: 11
    case 42: 12
    case 47: 12
    case 37: 12
    case _: 0

@unsafe
def p175p_prec2(a,b):
  match a:
    case 61: f_choose(U32,U32.is_eq(b,62),u => 1,u => 0)
    case 45: f_choose(U32,U32.is_eq(b,62),u => 1,u => 0)
    case 124: f_choose(U32,U32.is_eq(b,124),u => 3,u => 0)
    case 38: f_choose(U32,U32.is_eq(b,38),u => 4,u => 0)
    case 60: f_choose(U32,U32.is_eq(b,61),u => 5,u => f_choose(U32,U32.is_eq(b,62),u => 6,u => f_choose(U32,U32.is_eq(b,60),u => 10,u => 0)))
    case 62: f_choose(U32,U32.is_eq(b,61),u => 5,u => 0)
    case 43: f_choose(U32,U32.is_eq(b,43),u => 6,u => 0)
    case _: 0

@unsafe
def p175p_prec3(a,b,c):
  match a:
    case 46:
      f_choose(U32,U32.is_eq(c,46),u =>
        f_choose(U32,U32.is_eq(b,124),u => 7,u =>
        f_choose(U32,U32.is_eq(b,94),u => 8,u =>
        f_choose(U32,U32.is_eq(b,38),u => 9,u => 0))),u => 0)
    case 60: f_choose(U32,U32.is_eq(b,38) && U32.is_eq(c,62),u => 6,u => 0)
    case 62: f_choose(U32,U32.is_eq(b,111) && U32.is_eq(c,112),u => 5,u => 0)
    case _: 0

@unsafe
def p175p_prec4(a,b,c,d):
  f_choose(U32,U32.is_eq(a,62) && U32.is_eq(b,62) && U32.is_eq(c,111) && U32.is_eq(d,112),u => 10,u => 0)
