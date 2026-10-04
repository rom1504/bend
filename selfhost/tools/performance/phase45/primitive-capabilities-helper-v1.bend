# Primitive fences come from the complete successful source graph, before IR
# folding or private capture rewriting can remove operation provenance. Original
# contextual source bodies are scanned too; erased/type references may overfence.
# Every child/branch is visited once under one aggregate budget. Uncertainty keeps
# the historical all-family fence; native, source and host guards are unchanged.
@unsafe
def j_instance_primitive_capabilities(+rows: List<&2,KDef>, +pure: JPure) -> String:
  kc(String, j_pure_valid(pure) && Bool.not(List.is_empty(&2,KDef, j_pure_defs(pure))), u =>
    j_instance_primitive_cap_result(j_instance_primitive_cap_scan(
      List.append(&2,KTerm, j_instance_primitive_cap_sources(rows), j_instance_primitive_cap_bodies(j_pure_defs(pure))),
      Nil{}, 131072)), u => j_instance_primitive_guards())

@unsafe
def j_instance_primitive_cap_sources(+rows: List<&2,KDef>) -> List<&2,KTerm>:
  match rows:
    case Nil{}: Nil{}
    case Con{fact, rest}: Con{dv(j_instance_original(fact)), j_instance_primitive_cap_sources(rest)}

@unsafe
def j_instance_primitive_cap_bodies(+defs: List<&2,KDef>) -> List<&2,KTerm>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{dv(d), j_instance_primitive_cap_bodies(rest)}

@unsafe
def j_instance_primitive_cap_scan(+todo: List<&2,KTerm>, +names: List<&2,String>, +fuel: U32) -> Maybe<&2,List<&2,String>>:
  match todo:
    case Nil{}: Some{List.reverse(&2,String, names)}
    case Con{t, rest}:
      kc(Maybe<&2,List<&2,String>>, U32.is_gt(fuel, 0), u =>
        j_instance_primitive_cap_scan(List.append(&2,KTerm, ks(t), rest),
          kc(List<&2,String>, j_primitive_known(nm(t)) && Bool.not(has_name(names, nm(t))),
            u => Con{nm(t), names}, u => names), U32.sub(fuel, 1)), u => None{})

@unsafe
def j_instance_primitive_cap_result(+r: Maybe<&2,List<&2,String>>) -> String:
  match r:
    case None{}: j_instance_primitive_guards()
    case Some{names}: j_instance_primitive_cap_print(names)

@unsafe
def j_instance_primitive_cap_print(+names: List<&2,String>) -> String:
  match names:
    case Nil{}: ""
    case Con{name, rest}: j_quote(name) ++ "," ++ j_instance_primitive_cap_print(rest)
