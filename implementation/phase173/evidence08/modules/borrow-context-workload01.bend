# Full real loader cases plus explicit materialization boundary values.
# The loader/parser/materializer functions are extracted unchanged for baseline.
type P173CMReport is Data:
  P173CMReport{+loaded: List<&2,FResult>, +materialized: List<&2,KTerm>, +aliases: List<&2,KTerm>}

def p173cmw_prelude() -> String:
  "type Flag is Data:\n  On{}\n  Off{}\n\n"

def p173cmw_load(+name: String, text: String) -> FResult:
  f_load_graph(name,[FSource{name,name,text}])

def p173cmw_loads() -> List<&2,FResult>:
  [p173cmw_load("/context/simple.bend",p173cmw_prelude() ++ "def main() -> Flag:\n  On{}\n"),
   p173cmw_load("/context/law.bend",p173cmw_prelude() ++ "law pick:\n  for +a: Flag\n  for +b: Flag\n  Flag\n@unsafe\ndef pick(a, b):\n  a\ndef main() -> Flag:\n  pick(On{}, Off{})\n"),
   p173cmw_load("/context/binding.bend",p173cmw_prelude() ++ "def id(+value: Flag) -> Flag:\n  result = value\n  result\ndef main() -> Flag:\n  id(On{})\n"),
   f_load_graph("/context/main.bend",[
     FSource{"/context/main.bend","/context/main.bend","import ./child.bend as A\nimport ./child.bend as B\ndef main() -> A.Flag:\n  B.On{}\n"},
     FSource{"/context/child.bend","/context/child.bend",p173cmw_prelude()}]),
   p173cmw_load("/context/error.bend","def main(\n"),
   p173cmw_load("/context/duplicate.bend",p173cmw_prelude() ++ "def value() -> Flag:\n  On{}\ndef value() -> Flag:\n  Off{}\n")]

def p173cmw_error(+label: String, +begin: U32) -> KTerm:
  KTerm{"Error",label,0,2,[],["retained-error-metadata"],begin,U32.inc(begin)}

def p173cmw_value(+number: U32) -> KTerm:
  KLiteral{"U32",number,"literal-metadata",31,37}

def p173cmw_boundaries() -> List<&2,KTerm>:
  +first = p173cmw_error("first",41)
  +second = p173cmw_error("second",71)
  +lambda : KTerm = KLambda{"x",19,2,[first],["lambda-removed"],11,23,False{}}
  +all : KTerm = KTerm{"All","forall",17,2,[p173cmw_value(7),first],["all-removed"],3,29}
  +letTerm : KTerm = KTerm{"Let","bound",23,1,[p173cmw_value(9),first],["let-removed"],5,43}
  +beta : KTerm = KTerm{"App","application",0,2,[KLambda{"v",47,2,[KTerm{"Var","v",47,2,[],[],0,0}],[],13,17,True{}},p173cmw_value(101)],["app-removed"],59,89}
  [f_context_higher(lambda),f_context_lower(lambda),
   f_context_higher(all),f_context_lower(all),
   f_context_higher(letTerm),f_context_lower(letTerm),
   f_context_higher(KTerm{"Unknown","ordered",29,2,[first,second],["outer-removed"],2,97}),
   f_context_higher(beta),f_context_lower(beta),
   f_context_higher(KTerm{"FName","surface",0,2,[p173cmw_value(1),p173cmw_value(2)],[],7,53}),
   f_context_higher(KTerm{"Ref",".unknown",0,2,[],[],17,19}),
   f_context_lower(KTerm{"Unknown","empty",31,0,[],["keep-empty"],127,131}),
   f_context_higher(KLambda{"empty-lambda",37,0,[],["keep-lambda"],137,139,False{}}),
   f_context_higher(KLiteral{"FName",43,"arbitrary-literal-kind",149,151})]

def p173cmw_aliases() -> List<&2,KTerm>:
  +child : KTerm = KTerm{"Unknown","shared-child",7,2,[p173cmw_value(5)],["child-removed"],163,167}
  +root : KTerm = KTerm{"Unknown","shared-root",11,2,[child,child],["root-removed"],173,179}
  [root,f_context_materialize(root),root,child]

def p173cmw_result() -> P173CMReport:
  P173CMReport{p173cmw_loads(),p173cmw_boundaries(),p173cmw_aliases()}
