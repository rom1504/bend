# Mutations of owned semantic IR, independently of source-use counting and Nx.
type NxoOwnershipControl is Data:
  NxoOwnershipControl{+name: String, +ops: List<&2,NxoOp>, +arity: U32, +expected: Bool}

def nxo_v_binary_arm(ops: List<&2,NxoOp>) -> List<&2,NxoOp>:
  [NxoBranch{"p0",1,ops,[NxoFail{1}]}]

def nxo_v_nullary_arm(ops: List<&2,NxoOp>) -> List<&2,NxoOp>:
  [NxoBranch{"p0",0,ops,[NxoFail{1}]}]

def nxo_ownership_cases() -> List<&2,NxoOwnershipControl>:
  [NxoOwnershipControl{"identity",[NxoReturn{"p0"}],1,True{}},
   NxoOwnershipControl{"retained-owner",[NxoKeep{"p0"},NxoSink{"p0"},NxoReturn{"p0"}],1,True{}},
   NxoOwnershipControl{"duplicated-after-keep",[NxoKeep{"p0"},NxoBuild{"v0",1,["p0","p0"]},NxoReturn{"v0"}],1,True{}},
   NxoOwnershipControl{"binary-take",nxo_v_binary_arm([NxoTake{"p0",["v0","v1"]},NxoSink{"v0"},NxoReturn{"v1"}]),1,True{}},
   NxoOwnershipControl{"nullary-consume",nxo_v_nullary_arm([NxoTake{"p0",[]},NxoBuild{"v0",0,[]},NxoReturn{"v0"}]),1,True{}},
   NxoOwnershipControl{"tail-swap",[NxoTail{["p1","p0"]}],2,True{}},
   NxoOwnershipControl{"fail-stop",[NxoFail{1}],1,True{}},
   NxoOwnershipControl{"missing-keep",[NxoBuild{"v0",1,["p0","p0"]},NxoReturn{"v0"}],1,False{}},
   NxoOwnershipControl{"missing-sink",[NxoKeep{"p0"},NxoReturn{"p0"}],1,False{}},
   NxoOwnershipControl{"double-consume",[NxoSink{"p0"},NxoSink{"p0"},NxoBuild{"v0",0,[]},NxoReturn{"v0"}],1,False{}},
   NxoOwnershipControl{"keep-after-consume",[NxoSink{"p0"},NxoKeep{"p0"},NxoReturn{"p0"}],1,False{}},
   NxoOwnershipControl{"return-after-consume",[NxoSink{"p0"},NxoReturn{"p0"}],1,False{}},
   NxoOwnershipControl{"unknown-return",[NxoSink{"p0"},NxoReturn{"v0"}],1,False{}},
   NxoOwnershipControl{"unrefined-take",[NxoTake{"p0",["v0","v1"]},NxoSink{"v0"},NxoReturn{"v1"}],1,False{}},
   NxoOwnershipControl{"nullary-discard-of-binary",nxo_v_binary_arm([NxoTake{"p0",[]},NxoBuild{"v0",0,[]},NxoReturn{"v0"}]),1,False{}},
   NxoOwnershipControl{"missing-nullary-consume",nxo_v_nullary_arm([NxoBuild{"v0",0,[]},NxoReturn{"v0"}]),1,False{}},
   NxoOwnershipControl{"duplicate-scratch-destination",nxo_v_binary_arm([NxoTake{"p0",["v0","v0"]},NxoReturn{"v0"}]),1,False{}},
   NxoOwnershipControl{"missing-scratch-field",nxo_v_binary_arm([NxoTake{"p0",["v0"]},NxoReturn{"v0"}]),1,False{}},
   NxoOwnershipControl{"overwritten-live-owner",[NxoBuild{"p0",0,[]},NxoReturn{"p0"}],1,False{}},
   NxoOwnershipControl{"scratch-overwrites-live-owner",nxo_v_binary_arm([NxoTake{"p0",["p1","v1"]},NxoSink{"p1"},NxoReturn{"v1"}]),2,False{}},
   NxoOwnershipControl{"wrong-constructor-arity",[NxoBuild{"v0",0,["p0","p0"]},NxoReturn{"v0"}],1,False{}},
   NxoOwnershipControl{"wrong-tail-arity",[NxoTail{["p0","p0"]}],1,False{}},
   NxoOwnershipControl{"duplicate-tail-owner",[NxoTail{["p0","p0"]}],2,False{}},
   NxoOwnershipControl{"tail-fallthrough",[NxoTail{["p0"]},NxoReturn{"p0"}],1,False{}},
   NxoOwnershipControl{"return-fallthrough",[NxoReturn{"p0"},NxoFail{1}],1,False{}},
   NxoOwnershipControl{"unterminated-path",[NxoSink{"p0"}],1,False{}},
   NxoOwnershipControl{"one-arm-leaks",[NxoBranch{"p0",0,
     [NxoTake{"p0",[]},NxoBuild{"v0",0,[]},NxoReturn{"v0"}],
     [NxoBuild{"v0",0,[]},NxoReturn{"v0"}]}],1,False{}},
   NxoOwnershipControl{"branch-on-consumed-owner",[NxoSink{"p0"},NxoBranch{"p0",0,[NxoFail{1}],[NxoFail{1}]}],1,False{}}]

@unsafe
def nxo_ownership_report_cases(+cases: List<&2,NxoOwnershipControl>) -> String:
  match cases:
    case Nil{}: ""
    case Con{NxoOwnershipControl{name,ops,arity,expected},rest}:
      name ++ nx_choose(String,U32.is_eq(nx_bool32(nxo_verify(ops,arity)),nx_bool32(expected)),u => " PASS\n",u => " FAIL\n") ++ nxo_ownership_report_cases(rest)

@unsafe
def nxo_ownership_report() -> String:
  nxo_ownership_report_cases(nxo_ownership_cases())
