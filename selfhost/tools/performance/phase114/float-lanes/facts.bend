# Renderer facts only: an existing F32 operation produced both this lane and
# the still-emitted zero-extended word. No argument/type/memory inference.
type P114FLFact is Data:
  P114FLFact{+word: String, +lane: String}

@unsafe
def p114fl_find(facts: List<&2,P114FLFact>, +word: String) -> String:
  match facts:
    case Nil{}: ""
    case Con{P114FLFact{name,lane},rest}:
      nt_choose(String,String.eq(name,word),u => lane,u => p114fl_find(rest,word))

@unsafe
def p114fl_value(value: N111Value, +facts: List<&2,P114FLFact>) -> String:
  match value:
    case N111Local{name}: p114fl_find(facts,name)
    case _: ""

@unsafe
def p114fl_remove(facts: List<&2,P114FLFact>, +word: String) -> List<&2,P114FLFact>:
  match facts:
    case Nil{}: []
    case Con{+fact,+rest}: p114fl_remove_head(fact,rest,word)

@unsafe
def p114fl_remove_head(fact: P114FLFact, +rest: List<&2,P114FLFact>, +word: String) -> List<&2,P114FLFact>:
  match fact:
    case P114FLFact{+name,+lane}:
      nt_choose(List<&2,P114FLFact>,String.eq(name,word),
        u => p114fl_remove(rest,word),u => Con{P114FLFact{name,lane},p114fl_remove(rest,word)})

@unsafe
def p114fl_limit(facts: List<&2,P114FLFact>, +left: U32) -> List<&2,P114FLFact>:
  match facts:
    case Nil{}: []
    case Con{head,rest}:
      nt_choose(List<&2,P114FLFact>,U32.is_eq(left,0),u => [],
        u => Con{head,p114fl_limit(rest,U32.sub(left,1))})

@unsafe
def p114fl_bind(+facts: List<&2,P114FLFact>, +word: String, +lane: String) -> List<&2,P114FLFact>:
  +remaining = p114fl_remove(facts,word)
  nt_choose(List<&2,P114FLFact>,String.is_empty(lane),u => remaining,
    u => Con{P114FLFact{word,lane},p114fl_limit(remaining,15)})

@unsafe
def p114fl_copy(+facts: List<&2,P114FLFact>, +destination: String, +source: String) -> List<&2,P114FLFact>:
  p114fl_bind(facts,destination,p114fl_find(facts,source))

@unsafe
def p114fl_result(+facts: List<&2,P114FLFact>, +name: String, +id: U32, +site: U32) -> List<&2,P114FLFact>:
  p114fl_bind(facts,name,nt_choose(String,U32.is_eq(id,23) || (U32.is_ge(id,26) && U32.is_le(id,29)),
    u => p111q_tmp(U32.add(site,4)),u => ""))
