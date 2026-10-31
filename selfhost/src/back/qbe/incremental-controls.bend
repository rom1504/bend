

def p141sf_expected(+row: U32, +column: U32, +alias: U32) -> Bool:
  U32.is_eq(row,column) || (U32.is_gt(alias,0) &&
    ((U32.is_eq(row,0) && U32.is_eq(column,alias)) ||
     (U32.is_eq(column,0) && U32.is_eq(row,alias))))

@unsafe
def p141sf_row(~A: Data, ~same: A -> A -> Bool, +a: A, bs: List<&2,A>, +row: U32, +column: U32, +alias: U32) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{b,rest}: p134v_bool(same(a,b),p141sf_expected(row,column,alias)) && p141sf_row(~A,~same,a,rest,row,U32.inc(column),alias)

@unsafe
def p141sf_matrix(~A: Data, ~same: A -> A -> Bool, as: List<&2,A>, +bs: List<&2,A>, +row: U32, +alias: U32) -> Bool:
  match as:
    case Nil{}: True{}
    case Con{a,rest}: p141sf_row(~A,~same,a,bs,row,0,alias) && p141sf_matrix(~A,~same,rest,bs,U32.inc(row),alias)


@unsafe
def p141p_raw(stopped: P140PStop) -> FRawResult:
  match stopped:
    case P140PDone{raw}: raw
    case P140PCut{input,book,imports,unsafe,scope}:
      p141p_raw(p140p_top(0,input,book,imports,unsafe,scope))
