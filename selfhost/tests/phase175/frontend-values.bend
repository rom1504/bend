# Actual compiler computations and separate literal complete-value expectations.
# No hash, equality normalizer, or generated compiler output supplies the oracle.
type P175FrontendValues is Data:
  P175FrontendValues{+located: KTerm, +substituted: KTerm, +retained: KTerm}

def p175fv_original() -> KTerm:
  KTerm{"Ctr","Pair",4,2,
    [KTerm{"Var","x",7,1,[],["variable-note"],11,12},
     KLambda{"y",8,2,[KLiteral{"U32",3,"three",0,0}],[],0,0,True{}}],
    ["root-note"],0,0}

@unsafe
def p175fv_actual() -> P175FrontendValues:
  +original = p175fv_original()
  P175FrontendValues{
    f_span_created(original,20,30),
    f_pattern_sub(original,7,KLiteral{"U32",99,"replacement",1,2}),
    original}

def p175fv_expected() -> P175FrontendValues:
  P175FrontendValues{
    KTerm{"Ctr","Pair",4,2,
      [KTerm{"Var","x",7,1,[],["variable-note"],11,12},
       KLambda{"y",8,2,[KLiteral{"U32",3,"three",20,30}],[],20,30,True{}}],
      ["root-note"],20,30},
    KTerm{"Ctr","Pair",4,2,
      [KLiteral{"U32",99,"replacement",11,12},
       KLambda{"y",8,2,[KLiteral{"U32",3,"three",0,0}],[],0,0,True{}}],
      ["root-note"],0,0},
    KTerm{"Ctr","Pair",4,2,
      [KTerm{"Var","x",7,1,[],["variable-note"],11,12},
       KLambda{"y",8,2,[KLiteral{"U32",3,"three",0,0}],[],0,0,True{}}],
      ["root-note"],0,0}}
