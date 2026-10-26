# Private, one-request event schedule. No checker verdict is cached.
type P143CEvent is Data:
  P143CEvent{+definition: KDef, +next: KDef}

type P143CSchedule is Data:
  P143CSchedule{+index: KDef, +events: List<&2,P143CEvent>}

@unsafe
def p143cs_build(todo: List<&2,KDef>) -> P143CSchedule:
  match todo:
    case Nil{}: P143CSchedule{missing(),[]}
    case Con{head,rest}: p143cs_step(head,p143cs_build(rest))

@unsafe
def p143cs_step(+head: KDef, tail: P143CSchedule) -> P143CSchedule:
  match tail:
    case P143CSchedule{+index,events}:
      +next = index_find(index,dn(head),index_hash(dn(head),2166136261),32)
      P143CSchedule{
        nt_choose(KDef,p88_string_eq(dk(head),"BookCache"),
          u => index_first(dc(head)),
          u => index_set(index,head,index_hash(dn(head),2166136261),32)),
        Con{P143CEvent{head,next},events}}

@unsafe
def p143cs_plan(todo: List<&2,KDef>) -> List<&2,P143CEvent>:
  p143cs_events(p143cs_build(todo))

def p143cs_events(plan: P143CSchedule) -> List<&2,P143CEvent>:
  match plan:
    case P143CSchedule{index,events}: events

@unsafe
def p143cs_mode(+definition: KDef, next: KDef) -> KDef:
  nt_choose(KDef,p88_string_eq(dk(definition),"Def") && p98_tag_eq(dv(definition),"Absent"),
    u => signature_fill_mode(definition,next),u => definition)
