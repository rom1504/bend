# Shared machine boundary. Instruction selection never renders assembly.
# Opcodes are selected finite mnemonics; operands retain widths, register
# identities, exact bit patterns and symbolic references. Directives preserve
# data widths. The sequence is released one function/data slice at a time.
type X187Parsed is Data:
  PInst{+inst: X187Instruction}
  PLabel{+name: String}
  PSection{+section: U32}
  PGlobal{+name: String}
  PType{+name: String, +kind: U32}
  PSize{+name: String}
  PAlign{+alignment: U32}
  PBytes{+bytes: List<&2,U32>}
  PDataReloc{+symbol: String, +addendLo: U32, +addendHi: U32}
  PDatum{+datum: P111QDatum}
  PEmpty{}
  PError{+error: String}

type X188Seq is Data:
  X188Empty{}
  X188One{+item: X187Parsed}
  X188Join{+left: X188Seq, +right: X188Seq}

