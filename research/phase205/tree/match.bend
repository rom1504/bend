# Operations in a frozen equation: exact atom, binder, bound variable, declaration role.
type P205TExpr is Data:
  P205TExpr{+tag: String,+op: U32,+name: String,+id: U32,+quant: U32,+kids: List<&2,P205TExpr>}

type P205TMatch is Data:
  P205TNo{}
  P205TYes{+roles: List<&2,KTerm>,+vars: List<&2,KTerm>}

@unsafe
def p205t_find(+key: String, +rows: List<&2,KTerm>) -> KTerm:
  match rows:
    case Nil{}: atom("Absent")
    case Con{+h,+t}: nt_choose(KTerm,String.eq(tg(h),key),u => h,u => p205t_find(key,t))

@unsafe
def p205t_taken(+value: String, +rows: List<&2,KTerm>) -> Bool:
  match rows:
    case Nil{}: False{}
    case Con{+h,+t}: String.eq(nm(h),value) || p205t_taken(value,t)

def p205t_symbol(+key: String,+value: String,+roles: List<&2,KTerm>,+vars: List<&2,KTerm>) -> P205TMatch:
  +old = p205t_find(key,roles)
  nt_choose(P205TMatch,String.eq(tg(old),"Absent"),
    u => nt_choose(P205TMatch,String.is_empty(value) || p205t_taken(value,roles),v => P205TNo{},
      v => P205TYes{Con{kt(key,value,0,0,[]),roles},vars}),
    u => nt_choose(P205TMatch,String.eq(nm(old),value),v => P205TYes{roles,vars},v => P205TNo{}))

@unsafe
def p205t_scalar(+op: U32,+n: String,+i: U32,+t: KTerm,+roles: List<&2,KTerm>,+vars: List<&2,KTerm>) -> P205TMatch:
  nt_choose(P205TMatch,U32.is_eq(op,1),
    u => P205TYes{roles,Con{kt(U32.show(i),"",ix(t),0,[]),vars}},
    u => nt_choose(P205TMatch,U32.is_eq(op,2),
      v => nt_choose(P205TMatch,U32.is_eq(ix(p205t_find(U32.show(i),vars)),ix(t)) &&
        Bool.not(String.eq(tg(p205t_find(U32.show(i),vars)),"Absent")),w => P205TYes{roles,vars},w => P205TNo{}),
      v => nt_choose(P205TMatch,U32.is_eq(ix(t),i),
        w => nt_choose(P205TMatch,U32.is_eq(op,3),z => p205t_symbol(n,nm(t),roles,vars),
          z => nt_choose(P205TMatch,String.eq(nm(t),n),y => P205TYes{roles,vars},y => P205TNo{})),
        w => P205TNo{})))

law p205t_match:
  for +p: P205TExpr
  for +t: KTerm
  for +st: P205TMatch
  P205TMatch

@unsafe
def p205t_kids(+ps: List<&2,P205TExpr>,+ts: List<&2,KTerm>,+st: P205TMatch) -> P205TMatch:
  match ps ts st:
    case Nil{} Nil{} +result: result
    case Con{+p,+pr} Con{+t,+tr} P205TYes{+r,+v}: p205t_kids(pr,tr,p205t_match(p,t,P205TYes{r,v}))
    case _ _ _: P205TNo{}

@unsafe
def p205t_match(p,t,st):
  match p st:
    case P205TExpr{+tag,+op,+n,+i,+q,+ps} P205TYes{+r,+v}:
      nt_choose(P205TMatch,String.eq(tg(t),tag) && U32.is_eq(qt(t),q),
        u => p205t_kids(ps,nt_choose(List<&2,KTerm>,String.eq(tag,"Var"),w => [],w => ks(t)),p205t_scalar(op,n,i,t,r,v)),
        u => P205TNo{})
    case _ _: P205TNo{}
