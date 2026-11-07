# Finite complete inputs; all construction happens in independently checked Bend.
def p177fc_var() -> KTerm:
  KTerm{"Var","x",9,2,[KLiteral{"U32",77,"discarded-on-hit",3,4}],["var-note"],11,12}

def p177fc_original() -> KTerm:
  KTerm{"All","x",9,2,
    [KTerm{"Var","outer",9,0,[],["outer-note"],1,2},
     KLambda{"y",10,1,
       [KTerm{"Let","ignored",88,2,
         [KTerm{"Bind","a",11,2,[KTerm{"Var","x",9,1,[],[],3,4}],["bind-note"],5,6},
          KTerm{"Bind","b",12,0,[KTerm{"Var","a",11,1,[],[],7,8}],[],9,10},
          KTerm{"Ctr","Pair",0,1,
            [KTerm{"Var","a",11,2,[],[],13,14},KTerm{"Var","b",12,0,[],[],15,16}],
            ["pair-note"],17,18}],
         ["let-note"],19,20}],
       ["lambda-note"],21,22,False{}}],
    ["all-note"],23,24}

@unsafe
def p177fc_actual() -> FFresh:
  f_fresh_term(p177fc_original(),[],100)

def p177fc_expected() -> FFresh:
  FFresh{
    KTerm{"All","x",100,2,
      [KTerm{"Var","outer",9,0,[],["outer-note"],1,2},
       KLambda{"y",101,1,
         [KTerm{"Let","",0,1,
           [KTerm{"Bind","a",102,2,[KTerm{"Var","x",100,1,[],[],3,4}],[],5,6},
            KTerm{"Bind","b",103,0,[KTerm{"Var","a",11,1,[],[],7,8}],[],9,10},
            KTerm{"Ctr","Pair",0,1,
              [KTerm{"Var","a",102,2,[],[],13,14},KTerm{"Var","b",103,0,[],[],15,16}],
              ["pair-note"],17,18}],
           [],19,20}],
         [],21,22,False{}}],
      [],23,24},104}

def p177fc_cases() -> List<&2,KTerm>:
  [p177fc_original(),p177fc_var(),
   KLiteral{"U32",123,"literal",25,26},
   KTerm{"FName","wrapper",0,0,
     [KLiteral{"U32",0,"ignored",0,0},KTerm{"FGlobal","A.f",93,2,[],["global-note"],1,2}],
     ["wrapper-note"],31,32},
   KTerm{"FName","nested",0,0,
     [KLiteral{"U32",0,"ignored",0,0},KTerm{"FName","inner",0,0,
       [KLiteral{"U32",0,"ignored",0,0},p177fc_var()],[],0,0}],[],33,34},
   KTerm{"FGlobal","A.g",99,2,[p177fc_var()],["global-note"],35,36},
   KTerm{"FUnboundVar","unbound",9,2,[p177fc_var()],["unbound-note"],37,38},
   KTerm{"Let","empty",0,2,[],["lost-note"],39,40},
   KTerm{"Let","body-only",0,2,[p177fc_var()],["lost-note"],41,42},
   KTerm{"Let","malformed",0,2,[KLiteral{"U32",5,"binding",0,0},p177fc_var()],[],43,44},
   KTerm{"All","missing",9,0,[],["lost-note"],45,46},
   KLambda{"missing",9,0,[],["lost-note"],47,48,True{}},
   KTerm{"Lam","legacy",9,2,[p177fc_var()],["lost-note"],49,50},
   KTerm{"All","extra",9,2,[p177fc_var(),p177fc_var(),p177fc_var()],[],51,52},
   KLambda{"extra",9,2,[p177fc_var(),p177fc_var()],[],53,54,False{}},
   KTerm{"FName","missing",0,0,[],["lost-note"],55,56},
   KTerm{"Ctr","Alias",123,2,[p177fc_var(),p177fc_var()],["kept-note"],57,58}]

def p177fc_envs() -> List<&2,List<&2,KTerm>>:
  [[],
   [KTerm{"Map","",9,0,[KTerm{"Var","new",81,1,[],[],0,0}],[],0,0}],
   [KTerm{"Map","",9,0,[KTerm{"Ref","Global.f",0,3,[KLiteral{"U32",7,"child",1,2}],["ref-note"],0,0}],[],0,0}],
   [KTerm{"Map","",9,0,[KTerm{"Var","first",91,1,[],[],0,0}],[],0,0},
    KTerm{"Map","",9,0,[KTerm{"Var","second",92,1,[],[],0,0}],[],0,0}],
   [KTerm{"Map","",9,0,[],[],0,0}],
   [KTerm{"Map","",7,0,[KTerm{"Var","miss",71,1,[],[],0,0}],[],0,0}]]

def p177fc_book() -> List<&2,KDef>:
  [KDef{"outer","Data",2,1,p177fc_original(),p177fc_original(),
    [KDef{"First","Ctr",1,0,p177fc_original(),p177fc_var(),[],False{},False{}},
     KDef{"Second","Ctr",0,0,p177fc_var(),p177fc_original(),
       [KDef{"Nested","Ctr",1,0,p177fc_original(),p177fc_var(),[],False{},True{}}],True{},False{}}],
    False{},True{}},
   KDef{"after","Def",0,0,p177fc_original(),p177fc_original(),[],True{},False{}}]
