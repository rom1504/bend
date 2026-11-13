# Experimental coexistence, not value renaming: integer statements retain
# their original order and GPR/frame emission. Every ordinary read/write name
# is globally barred from XMM allocation. Only unrelated float names span it.
# Calls, allocations, returns, branches and backedges keep original cuts.
def x192fr_enabled() -> Bool: True{}

def x192fr_word(typ: N111Type) -> Bool:
  match typ:
    case N111U32{}: True{}
    case N111U64{}: True{}
    case N111Ptr{}: True{}
    case _: False{}

@unsafe
def x192fr_safe(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: x192fr_word(typ)
    case N111Bin{name,+typ,+op,left,right}:
      (U32.is_eq(p111v_type(typ),1) || U32.is_eq(p111v_type(typ),2)) &&
        (Bool.not(String.is_empty(x181_alu(op))) || Bool.not(String.is_empty(x181_condition(op))))
    case N111Load{name,typ,base,offset}: x192fr_word(typ)
    case N111Store{typ,base,offset,value}: x192fr_word(typ)
    case N111Offset{name,base,bytes}: True{}
    case _: False{}

# Clearing a written name's canonical marker is required even though that
# name is already globally blocked: later canonical copies consult this map.
@unsafe
def x192fr_write(+name: String, reads: List<&2,N111Value>, scan: X186XScan) -> X186XScan:
  match scan:
    case X186XScan{ranges,canonical}:
      X186XScan{x185_t_next(x185_t_forbid(name,x185_t_forbid_values(reads,ranges))),
        p111v_put(canonical,name,"X186Canonical",0,0)}

@unsafe
def x192fr_ordinary(stmt: N111Stmt, scan: X186XScan) -> X186XScan:
  match stmt:
    case N111Set{name,typ,value}: x192fr_write(name,[value],scan)
    case N111Bin{name,typ,op,left,right}: x192fr_write(name,[left,right],scan)
    case N111Load{name,typ,base,offset}: x192fr_write(name,[base],scan)
    case N111Offset{name,base,bytes}: x192fr_write(name,[base,bytes],scan)
    case N111Store{typ,base,offset,value}: x192fr_store([base,value],scan)
    case _: scan

@unsafe
def x192fr_store(reads: List<&2,N111Value>, scan: X186XScan) -> X186XScan:
  match scan:
    case X186XScan{ranges,canonical}:
      X186XScan{x185_t_next(x185_t_forbid_values(reads,ranges)),canonical}

@unsafe
def x192fr_copy(+stmt: P113DStmt, +scalar: N111Stmt, value: N111Value, +scan: X186XScan) -> X186XScan:
  match scan:
    case X186XScan{ranges,canonical}:
      nt_choose(X186XScan,x186_x_canonical(value,canonical),
        u => x186_x_plain(stmt,scan),u => x192fr_ordinary(scalar,scan))

@unsafe
def x192fr_plain(+stmt: P113DStmt, +scan: X186XScan) -> X186XScan:
  match stmt:
    case P113DScalar{N111Set{name,N111U64{},+value}}:
      x192fr_copy(stmt,N111Set{name,N111U64{},value},value,scan)
    case P113DScalar{+scalar}:
      nt_choose(X186XScan,x192fr_enabled() && x192fr_safe(scalar),
        u => x192fr_ordinary(scalar,scan),u => x186_x_plain(stmt,scan))
    case _: x186_x_plain(stmt,scan)

law x192fr_scan:
  for nodes: List<&2,X186FloatNode>
  for scan: X186XScan
  X186XScan

@unsafe
def x192fr_node(node: X186FloatNode, +scan: X186XScan) -> X186XScan:
  match node scan:
    case X186FloatValues{+destination,id,left,right} X186XScan{ranges,canonical}:
      X186XScan{x185_t_next(x185_t_event(destination,True{},x185_t_reads([left,right],ranges))),
        p111v_put(canonical,destination,"X186Canonical",1,0)}
    case X186FloatBranch{condition,yes,no} X186XScan{ranges,canonical}:
      x186_x_cut(x192fr_scan(no,x186_x_cut(x192fr_scan(yes,
        X186XScan{x185_t_cut(x185_t_read(condition,x185_t_cut(ranges))),missing()}))))
    case X186FloatPlain{stmt} _: x192fr_plain(stmt,scan)

@unsafe
def x192fr_scan(nodes,scan):
  match nodes:
    case Nil{}: scan
    case Con{head,rest}: x192fr_scan(rest,x192fr_node(head,scan))

@unsafe
def x192fr_homes(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>) -> KDef:
  x186_x_scanned(x192fr_scan(nodes,X186XScan{
    X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0},missing()}))
