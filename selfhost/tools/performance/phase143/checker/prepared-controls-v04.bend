# Use INSTEAD OF prepared-controls-v02.bend. Actual authenticated Base seed only.
# Route 0: original outer refusal; 1: new prepared loop; 2: original hash replay;
# route 3: nonregular-event fallback. Expected result status is asserted too.

@unsafe
def p143cbc_route(+prepared: KBasePreparedWorld, load: FPrefixLoad) -> U32:
  match prepared load:
    case KBasePreparedWorld{+state,original,final,+saved,checked,seen,todos,checkedBound} FPrefixLoad{trace,prefix,+suffix,+ready}:
      match trace:
        case FLoadTrace{result,done,sources}:
          match result:
            case FResult{book,+error,imports}:
              +bound = norm_max(base_prefix_world_bound(state),norm_max_book(suffix))
              nt_choose(U32,ready && String.is_empty(error) &&
                base_prefix_world_admitted(state,suffix,bound,final,saved),
                u => nt_choose(U32,p143cp_regular(suffix),
                  v => nt_choose(U32,base_prefix_world_hash_disjoint(suffix,index_first(dc(index_first(saved)))),
                    w => 1,w => 2),v => 3),u => 0)

@unsafe
def p143cbc_status(checked: DChecking, success: Bool) -> Bool:
  match checked:
    case DChecking{result,diagnostic}: p134v_bool(String.is_empty(ce(result)),success)

def p143cbc_program_status(result: DResult, success: Bool) -> Bool:
  match result:
    case DResult{error,book,diagnostic}: p134v_bool(String.is_empty(error),success)

@unsafe
def p143cbc_checked(+prepared: KBasePreparedWorld, +load: FPrefixLoad,
    route: U32, checked_success: Bool, program_success: Bool) -> Bool:
  +checked = base_prefix_check_world_load(prepared,load)
  +program = check_program_diagnostic_world(load,[],prepared)
  U32.is_eq(p143cbc_route(prepared,load),route) &&
    p143cbc_status(checked,checked_success) && p143cbc_program_status(program,program_success) &&
    p140ce_checked(p143cb_check_load(prepared,load,False{}),checked) &&
    p140ce_checked(p143cb_check_load(prepared,load,True{}),checked) &&
    p140ce_result(p143cb_program(load,[],prepared,True{}),program)

@unsafe
def p143cbc_unready(load: FPrefixLoad) -> FPrefixLoad:
  match load:
    case FPrefixLoad{trace,prefix,suffix,ready}: FPrefixLoad{trace,prefix,suffix,False{}}

@unsafe
def p143cbc_loaded(+prepared: KBasePreparedWorld, loaded: P140PLoadResult, force_fallback: Bool,
    +route: U32, +checked_success: Bool, +program_success: Bool) -> Bool:
  match loaded:
    case P140PLoadReady{+load,cache,hit}:
      nt_choose(Bool,force_fallback,
        u => p143cbc_checked(prepared,p143cbc_unready(load),route,checked_success,program_success),
        u => p143cbc_checked(prepared,load,route,checked_success,program_success))
    case P140PLoadError{error,cache}: False{}

@unsafe
def p143cbc_case(+seed: P86Seed, text: String, force_fallback: Bool,
    route: U32, checked_success: Bool, program_success: Bool) -> Bool:
  match seed:
    case P86Seed{base,book,fresh,ready,world}:
      p143cbc_loaded(world,p140pl_load(seed,"/phase143/prepared.bend",text,None{},0),
        force_fallback,route,checked_success,program_success)

@unsafe
def p143cbc_collision_seed(seed: P86Seed) -> Bool:
  match seed:
    case P86Seed{base,book,fresh,ready,world}:
      match world:
        case KBasePreparedWorld{state,prefix,final,+saved,checked,seen,todos,checkedBound}:
          U32.is_eq(index_hash("p143CollisionlrXlHP",2166136261),index_hash("Unit",2166136261)) &&
            p88_string_eq(dn(lookup(saved,"Unit")),"Unit") &&
            p88_string_eq(dk(lookup(saved,"p143CollisionlrXlHP")),"Absent")

@unsafe
def p143cbc_controls(+seed: P86Seed) -> List<&2,String>:
  [p131u_row(p143cbc_case(seed,"import Base\n",False{},1,True{},True{}),"prepared-empty-suffix-admitted-success"),
   p131u_row(p143cbc_case(seed,"import Base\ndef early() -> U32:\n  3\ndef main() -> U32:\n  early\n",False{},1,True{},True{}),"prepared-body-admitted-success"),
   p131u_row(p143cbc_case(seed,"import Base\ndef early() -> U32:\n  3\ndef main() -> U32:\n  True{}\n",False{},1,False{},False{}),"prepared-admitted-type-failure"),
   p131u_row(p143cbc_case(seed,"import Base\ndef early() -> U32:\n  3\ndef ident(~A: Type, x: A) -> A:\n  x\ndef main() -> U32:\n  ident(~U32, 7)\n",False{},1,True{},True{}),"prepared-admitted-template-success"),
   p131u_row(p143cbc_case(seed,"import Base\ndef early() -> U32:\n  3\ndef ident(~A: Type, x: A) -> A:\n  x\ndef use() -> U32:\n  ident(~U32, 7)\ndef main() -> U32:\n  True{}\n",False{},1,False{},False{}),"prepared-admitted-failure-after-template"),
   p131u_row(p143cbc_case(seed,"import Base\ndef main() -> U32:\n  7\n",True{},0,True{},True{}),"unready-original-full-check-success"),
   p131u_row(p143cbc_case(seed,"import Base\nlaw early:\n  U32\ndef middle() -> U32:\n  1\ndef early() -> U32:\n  3\ndef main() -> U32:\n  early\n",False{},1,True{},True{}),"prepared-admitted-law-fill-success"),
   p131u_row(p143cbc_case(seed,"import Base\nlaw pending:\n  U32\ndef main() -> U32:\n  0\n",False{},1,True{},False{}),"prepared-admitted-unfilled-law-TODO"),
   p131u_row(p143cbc_collision_seed(seed),"independent-Unit-name-hash-collision"),
   p131u_row(p143cbc_case(seed,"import Base\ndef p143CollisionlrXlHP() -> U32:\n  9\ndef main() -> U32:\n  p143CollisionlrXlHP\n",False{},2,True{},True{}),"prepared-original-hash-replay-success")]
