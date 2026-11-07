def p177dc_prelude() -> String:
  "type Flag is Data:\n  On{}\n  Off{}\n"

def p177dc_sources() -> List<&2,String>:
  ["def fresh() -> Flag:\n  On{}\n",
   "law pick:\n  for +x: Flag\n  Flag\ndef pick(x):\n  x\n",
   "law pick:\n  for +x: Flag\n  Flag\ndef between() -> Flag:\n  Off{}\ndef pick(x):\n  x\n",
   "law value:\n  Flag\ndef value():\n  On{}\ndef value():\n  Off{}\n",
   "def value() -> Flag:\n  On{}\ndef value() -> Flag:\n  Off{}\n",
   "law pick:\n  for +x: Flag\n  Flag\ndef pick(+x: Flag):\n  x\n",
   "law pick:\n  for +x: Flag\n  Flag\ndef pick(x) -> Flag:\n  x\n",
   "law pick:\n  for +x: Flag\n  Flag\ndef pick(x)\n  x\n",
   "def absent(x):\n  x\n",
   "law choose:\n  for ~A: Type\n  for +x: A\n  A\ndef choose(A, x):\n  x\n",
   "law choose:\n  for ~A: Type\n  for +x: A\n  A\ndef choose(x):\n  x\n",
   "law choose:\n  for ~A: Type\n  for +x: A\n  A\ndef choose(~A, x):\n  x\n",
   "law foreign:\n  Flag\ndef foreign():\n  import \"foreign.c\"\n",
   "def malformed( -> Flag:\n  On{}\n",
   "def malformed() -> :\n  On{}\n",
   "def missingbody() -> Flag:\n",
   "@unsafe\ndef unsafe?(+x: Flag) -> Flag:\n  x\n",
   "def On() -> Flag:\n  Off{}\n",
   "law duplicate:\n  Flag\nlaw duplicate:\n  Flag\n",
   "def recursive(+x: Flag) -> Flag:\n  recursive(x)\n"]

@unsafe
def p177dc_load(source: String) -> FResult:
  f_load_graph("/decl/main.bend",[FSource{"/decl/main.bend","/decl/main.bend",p177dc_prelude() ++ source}])

@unsafe
def p177dc_import(main: String, child: String) -> FResult:
  f_load_graph("/decl/main.bend",[
    FSource{"/decl/main.bend","/decl/main.bend",main},
    FSource{"/decl/child.bend","/decl/child.bend",p177dc_prelude() ++ child}])

@unsafe
def p177dc_imports() -> List<&2,FResult>:
  [p177dc_import("import ./child.bend as A\ndef A.pick(x):\n  x\n", "law pick:\n  for +x: Flag\n  Flag\n"),
   p177dc_import("import ./child.bend as A\ndef A.pick(x) -> A.Flag:\n  x\n", "law pick:\n  for +x: Flag\n  Flag\n"),
   p177dc_import("import ./child.bend as A\ndef A.new() -> A.Flag:\n  A.On{}\n", ""),
   p177dc_import("import ./child.bend as A\nimport ./child.bend as B\ndef A.pick(x):\n  x\ndef B.pick(x):\n  x\n", "law pick:\n  for +x: Flag\n  Flag\n"),
   p177dc_import("import ./child.bend as A\nimport ./child.bend as B\ndef A.pick(x):\n  x\ndef own() -> B.Flag:\n  B.On{}\n", "law pick:\n  for +x: Flag\n  Flag\n"),
   p177dc_import("import ./child.bend as A\ndef pick(+x: A.Flag) -> A.Flag:\n  x\ndef A.pick(x):\n  x\n", "law pick:\n  for +x: Flag\n  Flag\n"),
   p177dc_import("import ./child.bend as A\ndef A.pick(x):\n  x\n", "def pick(+x: Flag) -> Flag:\n  x\n"),
   p177dc_import("import ./child.bend as A\nlaw local:\n  A.Flag\ndef local():\n  A.On{}\ndef A.pick(x):\n  x\n", "law pick:\n  for +x: Flag\n  Flag\n")]

def p177dc_law() -> KDef:
  KDef{"f","Def",1,0,
    KTerm{"All","x",17,2,[KTerm{"Typ","",0,1,[],[],0,0},KTerm{"Typ","",0,1,[],[],0,0}],[],1,2},
    KTerm{"Absent","",0,0,[],[],0,0},[],False{},False{}}

def p177dc_definition() -> KDef:
  KDef{"f","Def",1,0,
    KTerm{"All","x",17,2,[KTerm{"Typ","",0,1,[],[],0,0},KTerm{"Typ","",0,1,[],[],0,0}],[],1,2},
    KLambda{"x",17,2,[KTerm{"Var","x",17,1,[],[],3,4}],[],5,6,True{}},[],False{},True{}}

def p177dc_books() -> List<&2,List<&2,KDef>>:
  [[],[p177dc_law()],[p177dc_definition(),p177dc_law()],
   [p177dc_law(),p177dc_definition()],
   [KDef{"T","ADT",0,0,atom("Typ"),atom("Absent"),
     [KDef{"f","Ctr",0,0,atom("Typ"),atom("Absent"),[],False{},False{}}],False{},False{}}],
   [KDef{"f","ImportFill",1,2,atom("Typ"),atom("Absent"),[],False{},False{}}]]

@unsafe
def p177dc_scopes() -> List<&2,FParseScope>:
  [f_parse_scope_empty(),
   f_context_declare(p177dc_law(),f_parse_scope_empty()),
   f_context_declare(p177dc_definition(),f_parse_scope_empty()),
   f_context_declare(p177dc_law(),FParseScope{[],missing(),missing(),"module",[],None{}}),
   FParseScope{[p177dc_law()],index_build([p177dc_law()]),missing(),"",[],Some{index_build([p177dc_law()])}}]

def p177dc_headers() -> List<&2,String>:
  ["f(x):\n  x\n", "f(+x: Type) -> Type:\n  x\n", "f(x) -> Type:\n  x\n",
   "f(x)\n  x\n", "f(x):\n", "f( -> Type:\n  Type\n", "if() -> Type:\n  Type\n",
   "f?(x):\n  x\n", "f(x):\n  x\ndef next() -> Type:\n  Type\n"]

@unsafe
def p177dc_direct(source: String, +book: List<&2,KDef>, +scope: FParseScope, stop: U32) -> P140PStop:
  p140p_def_header(stop,f_context_scope(f_input(f_lex_cursor(source,1,0,0,[],1,1)),scope),book,[],False{},scope)
