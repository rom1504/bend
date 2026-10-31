
# Module: src/back/native/ir.bend:3
type N_WordKind is Data:
  N_W32{}
  N_W64{}
  N_Box{}
  N_Imm64{}

type N_Param is Data:
  N_Param{+name: String, +kind: N_WordKind}

# Module: src/back/native/ir.bend:11
type N_Frame is Data:
  N_Direct{}
  N_Frame{+pop: U32, +slots: List<&2, String>}

# Module: src/back/native/ir.bend:15
type N_Segment is Data:
  N_Segment{+name: String, +params: List<&2, N_Param>, +result: U32, +frame: N_Frame, +body: String, +refs: List<&2, String>, +host: Bool, +spin: Bool, +fork: Bool, +bang: Bool}

# Module: src/back/native/ir.bend:18
type N_Constructor is Data:
  N_Constructor{+name: String, +arity: U32, +hot: Bool}

# Module: src/back/native/ir.bend:21
type N_Program is Data:
  N_Program{+segments: List<&2, N_Segment>, +constructors: List<&2, N_Constructor>, +image: List<&2, String>, +requests: String, +declarations: String, +show: String, +pure: Bool}

# Module: src/back/native/ir.bend:24
type N_Emitted is Data:
  N_Emitted{+code: String, +value: String, +fresh: U32}
