import Base

type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

# Module: src/core/term.bend:30
type KDef is Data:
  KDef{+name: String, +kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2, KDef>, +native: Bool, +unsafe: Bool}
  KIndexLeaf{+hash: U32, +bucket: List<&2,KDef>}
  KIndexNode{+hash: U32, +mask: U32, +left: KDef, +right: KDef}

# Module: src/core/normalize.bend:367
@unsafe
def kt(
  +tag: String,
  +name: String,
  +id: U32,
  +quant: U32,
  +kids: List<&2, KTerm>,
) -> KTerm:
  KTerm{tag, name, id, quant, kids, Nil{}, 0, 0}

# Module: src/core/term.bend:46
@unsafe
def atom(
  +tag: String,
) -> KTerm:
  kt(tag, "", 0, 0, Nil{})

# Module: src/core/term.bend:52
@unsafe
def missing() -> KDef:
  KDef{"", "Absent", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}

# Module: src/core/term.bend:278

@unsafe
def original_missing() -> KDef:
  missing()

@unsafe
def direct_missing() -> KDef:
  KDef{"", "Absent", 0, 0, KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0}, KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0}, Nil{}, False{}, False{}}

type Packet is Data:
  Packet{+tag: String, +left: U32, +right: U32}

def packet(+value: U32) -> Packet:
  Packet{"hdr",value,value}

def original_packet() -> Packet:
  packet(7)

def direct_packet() -> Packet:
  Packet{"hdr",7,7}

def main() -> IO(Unit):
  IO.print("factory-probe")
