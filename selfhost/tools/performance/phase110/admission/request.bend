# Unintegrated early adapter; NOT the general native trust boundary.
# It assumes a trusted seed and is deliberately absent from all prepared images.
# Production general entry uses native/general.bend and constructs its seed.
# Native-only adapter. It creates the checked request itself after validating
# the prepared Base source against the caller's authenticated path AND bytes.
# The caller must obtain seed from the mature preparation/cache factory and
# trusted_base_* from pinned image assets; raw KDefs are not provenance.
@unsafe
def nxe_plan(+seed: P86Seed, +path: String, +text: String, +name: String, +trusted_base_path: String, +trusted_base_text: String) -> NxeResult:
  match seed:
    case P86Seed{base,book,fresh,ready,world}:
      nx_choose(NxeResult,f_seed_matches(base,trusted_base_path,trusted_base_text) && String.starts_with(path,"/"),u =>
        nxe_planned(p86_plan(seed,path,text),name),u => nxe_refused("authenticated Base path and source bytes required"))

@unsafe
def nxe_planned(plan: P86Plan, +name: String) -> NxeResult:
  match plan:
    case P86PlanError{error}: nxe_refused("checked source preparation: " ++ error)
    case P86PlanReady{NR_Request{source,book,names,paths,scope,bound},verdict}:
      nxe_entry(source,[ns_body(book,name)],name)
