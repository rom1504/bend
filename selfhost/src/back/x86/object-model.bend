# Machine object boundary. Bytes are U32 values restricted to0..255. Registers
# use architectural encoding numbers; byte registers4..7 mean spl/bpl/sil/dil,
# never ah/ch/dh/bh. Displacements/addends carry exact two's-complement bits.
type X187Operand is Data:
  X187Reg{+index: U32, +width: U32, +vector: Bool}
  X187Imm{+lo: U32, +hi: U32}
  X187Mem{+base: U32, +disp: U32}
  X187Rip{+symbol: String, +addendLo: U32, +addendHi: U32}
  X187Target{+symbol: String}

type X187Instruction is Data:
  X187Instruction{+op: String, +operands: List<&2,X187Operand>}

type X187Symbol is Data:
  X187Symbol{+name: String, +section: U32, +value: U32, +size: U32, +global: Bool, +kind: U32}

type X187Relocation is Data:
  X187Relocation{+section: U32, +offset: U32, +kind: U32, +symbol: String, +addendLo: U32, +addendHi: U32}

type X187Encoded is Data:
  X187Encoded{+bytes: List<&2,U32>, +relocations: List<&2,X187Relocation>, +error: String}

type X187Object is Data:
  X187Object{+text: List<&2,U32>, +rodata: List<&2,U32>, +data: List<&2,U32>,
    +symbols: List<&2,X187Symbol>, +relocations: List<&2,X187Relocation>}

type X187ObjectResult is Data:
  X187ObjectResult{+bytes: List<&2,U32>, +error: String}
