@unsafe
def p114t_words(body: List<&2,N111Stmt>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{head,rest}: p114t_words(rest,ids,p114t_original_stmt(head,ids,code))

# Reserve one fresh site even when the underlying zero-offset memory emitter
# would not advance its counter. Original If rendering advances the same counter
# through both branches; its child statements still visit the global hook.
@unsafe
def p114t_expanded(expansion: P114TExpansion, ids: N111Ids, code: P111QCode) -> P111QCode:
  match expansion code:
    case P114TExpansion{body,changed} P111QCode{chunks,+next,terminal,error}:
      p114t_words(body,ids,P111QCode{chunks,nt_choose(U32,changed,u => U32.inc(next),u => next),terminal,error})

@unsafe
def p114t_stmt(stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}: p114t_expanded(p114t_expand(stmt,ids,next),ids,code)
