# Structured CPU segment IR. Values are machine words, never C expressions.
# Binary typ is operand width; comparisons produce U32. Offsets are bytes.
type N111Type is Data:
  N111U32{}
  N111U64{}
  N111Ptr{}

type N111Value is Data:
  N111Local{+name: String}
  N111Const{+lo: U32, +hi: U32}
  N111Symbol{+name: String}
  N111FuncId{+name: String}
  N111CtorId{+name: String}

type N111Arg is Data:
  N111Arg{+typ: N111Type, +value: N111Value}

type N111Stmt is Data:
  N111Set{+name: String, +typ: N111Type, +value: N111Value}
  N111Bin{+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value}
  N111Call{+name: String, +typ: N111Type, +symbol: String, +args: List<&2, N111Arg>}
  N111If{+condition: N111Value, +yes: List<&2, N111Stmt>, +no: List<&2, N111Stmt>}
  N111Return{+value: N111Value}
  N111Load{+name: String, +typ: N111Type, +base: N111Value, +offset: U32}
  N111Store{+typ: N111Type, +base: N111Value, +offset: U32, +value: N111Value}
  N111Offset{+name: String, +base: N111Value, +bytes: N111Value}
  N111Alloca{+name: String, +bytes: U32, +align: U32}

# Every body already includes its parameter/frame prelude. The sole machine
# argument is the borrowed state pointer, available as N111Local{"state"}.
type N111Segment is Data:
  N111Segment{+name: String, +arity: U32, +result: U32, +incoming: U32, +flags: U32, +body: List<&2, N111Stmt>}

type N111Ids is Data:
  N111Ids{+functions: KDef, +constructors: KDef}

type P111Program is Data:
  P111Program{+segments: List<&2, N111Segment>, +constructors: List<&2, N_Constructor>, +show: List<&2, U32>, +show_names: List<&2, String>, +effects: List<&2, String>, +pure: Bool}

type P111Result is Data:
  P111Result{+program: P111Program, +error: String}

type P111Code is Data:
  P111Code{+body: List<&2, N111Stmt>, +segments: List<&2, N111Segment>, +fresh: U32, +error: String}

type P111Book is Data:
  P111Book{+segments: List<&2, N111Segment>, +fresh: U32, +error: String}

type P111Partition is Data:
  P111Partition{+live: List<&2, NC_Binding>, +drop: List<&2, N111Stmt>}

type P111ValueCode is Data:
  P111ValueCode{+body: List<&2, N111Stmt>, +value: N111Value, +error: String}
