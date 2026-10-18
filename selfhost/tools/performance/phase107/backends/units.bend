# Independent QBE compilation units. The full Nx graph is verified once; each
# emitted function retains its exact signature and post-optimization body.
# Cache policy, identities and object publication belong to the host driver.
type NxqUnit is Data:
  NxqUnit{+name: String, +text: String}

type NxqUnits is Data:
  NxqUnits{+units: List<&2, NxqUnit>, +error: String}

@unsafe
def nxq_function_units(+items: List<&2, NxFunction>, +fs: List<&2, NxFunction>) -> List<&2, NxqUnit>:
  match items:
    case Nil{}: Nil{}
    case Con{f, rest}:
      match f:
        case NxFunction{name, params, result, locals, body}:
          Con{NxqUnit{"function_" ++ name, "export " ++ nxq_function(f, fs)}, nxq_function_units(rest, fs)}

@unsafe
def nxq_units_entry(+found: Maybe<&2, NxFunction>, +fs: List<&2, NxFunction>, +fuse: Bool) -> NxqUnits:
  match found:
    case None{}: NxqUnits{[], "Entry is missing"}
    case Some{f}:
      NxqUnits{Con{NxqUnit{"runtime", "export " ++ nxq_runtime()},
        Con{NxqUnit{"entry", nxq_entry_body(f, fs, fuse)}, nxq_function_units(fs, fs)}}, ""}

@unsafe
def nxq_units_verified(+program: NxProgram, +fuse: Bool) -> NxqUnits:
  match program:
    case NxProgram{entry, fs}: nxq_units_entry(nx_find(entry, fs), fs, fuse)

@unsafe
def nxq_units(+program: NxProgram, +fuse: Bool) -> NxqUnits:
  nx_choose(NxqUnits, nx_verify(program),
    u => nxq_units_verified(program, fuse),
    u => NxqUnits{[], "IR verifier refused program"})
