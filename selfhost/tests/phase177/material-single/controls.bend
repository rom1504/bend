# Additional complete expectations for restoring parent summaries and modes.
# Include parser/material-controls.bend unchanged for the shared constructors.
def p177msc_name() -> KTerm:
  KTerm{"FName","selected",0,2,[p177cc_error("ignored-syntax",70),p177cc_value()],
    ["name-note"],81,83}

def p177msc_selected() -> KTerm:
  KLiteral{"U32",123,"literal-metadata",81,83}

def p177msc_discard() -> KTerm:
  KTerm{"App","discard",4,2,
    [p177cc_lambda(p177cc_value()),p177cc_lambda(p177cc_error("discarded",90))],
    ["discard-note"],87,99}

def p177msc_cases() -> List<&2,KTerm>:
  +first = p177cc_error("first-deferred",11)
  +second = p177cc_error("second-eager",13)
  [KTerm{"Ctr","Pair",9,2,[p177cc_lambda(p177msc_name()),p177msc_discard()],
      ["outer-note"],1,100},
   KTerm{"Ctr","Pair",9,2,[p177msc_discard(),p177cc_lambda(second)],
      ["outer-note"],1,100},
   p177cc_lambda(KTerm{"Ctr","inner",9,2,[p177cc_lambda(first),second],[],1,100}),
   KTerm{"All","outer",17,2,[p177cc_lambda(first),second],["outer-note"],1,100},
   KTerm{"Let","outer",17,2,[p177cc_lambda(first),second],["outer-note"],1,100},
   KTerm{"App","discard-nested",0,1,[p177cc_lambda(p177cc_value()),
      KTerm{"All","nested",17,2,[p177cc_lambda(first),second],[],2,9}],[],1,100}]

def p177msc_expected() -> List<&2,KTerm>:
  [KTerm{"Ctr","Pair",9,2,[p177cc_lambda(p177msc_selected()),p177cc_value()],
      ["outer-note"],1,100},
   p177cc_error("second-eager",13),
   p177cc_error("second-eager",13),
   p177cc_error("first-deferred",11),
   p177cc_error("first-deferred",11),
   p177cc_value()]

@unsafe
def p177msc_materials(terms: List<&2,KTerm>) -> List<&2,KTerm>:
  match terms:
    case Nil{}: Nil{}
    case Con{term,rest}: Con{f_context_materialize(term),p177msc_materials(rest)}

@unsafe
def p177msc_actual() -> List<&2,KTerm>:
  p177msc_materials(p177msc_cases())
