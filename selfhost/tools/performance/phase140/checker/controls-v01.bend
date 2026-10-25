# Actual frontend -> global freshener -> original checker; tiny source programs.
@unsafe
def p140cc_parse(text: String) -> FResult:
  f_load_graph("Unit",[FSource{"Unit","/checkpoint.bend",text}])

def p140cc_text(value: String) -> String:
  "type Bit is Data:\n  Off{}\n  Onn{}\ndef keep() -> Bit:\n  Off{}\ndef edit() -> Bit:\n  " ++ value ++ "\n"

def p140cc_book(result: FResult) -> List<&2,KDef>:
  match result:
    case FResult{book,error,imports}: book

def p140cc_parsed(result: FResult) -> Bool:
  match result:
    case FResult{book,error,imports}: String.is_empty(error)

def p140cc_good(checked: DChecking) -> Bool:
  match checked:
    case DChecking{result,diagnostic}: String.is_empty(ce(result))

def p140cc_hit(replay: P140CPReplay) -> Bool:
  match replay:
    case P140CPReplay{checked,reused,skipped,reason}: reused && U32.is_gt(skipped,0) && String.is_empty(reason)

def p140cc_refused(admission: P140CPAdmission, reason: String) -> Bool:
  match admission:
    case P140CPAccepted{suffix,world,seen,steps}: False{}
    case P140CPRefused{actual}: String.eq(reason,actual)

@unsafe
def p140cc_rows(+old: FResult, +edited: FResult, +invalid: FResult) -> List<&2,String>:
  +a = p140cc_book(old)
  +b = p140cc_book(edited)
  +bad = p140cc_book(invalid)
  +seed = p140cp_seed("epoch-A",a,2)
  +cache = p140cp_saved(seed)
  +ra = p140cp_replay("epoch-A",a,cache)
  +rb = p140cp_replay("epoch-A",b,cache)
  +rf = p140cp_replay("epoch-A",bad,cache)
  +fresh = dg_check_world(b)
  [p131u_row(p140cc_parsed(old) && p140cc_parsed(edited) && p140cc_parsed(invalid),"frontend-success"),
   p131u_row(p140cc_good(p140cp_seed_checked(seed)),"original-check-success"),
   p131u_row(p140ce_checked(p140cp_seed_checked(seed),dg_check_world(a)),"capture-versus-fresh-complete-state"),
   p131u_row(p140cc_hit(ra) && p140ce_checked(p140cp_replay_checked(ra),dg_check_world(a)),"no-op-hit-full-state"),
   p131u_row(p140cc_hit(rb) && p140cc_good(fresh),"body-edit-hit"),
   p131u_row(p140ce_checked(p140cp_replay_checked(rb),fresh),"body-edit-full-state"),
   p131u_row(Bool.not(p140ce_checked(p140cp_seed_checked(seed),fresh)),"edit-changes-real-checked-output"),
   p131u_row(p140ce_result(driver_program_checked(b,[],p140cp_replay_checked(rb)),driver_program_checked(b,[],fresh)),"current-original-finalization"),
   p131u_row(p140cc_refused(p140cp_admit("epoch-B",b,cache),"producer epoch"),"producer-epoch-refusal"),
   p131u_row(p140ce_checked(p140cp_replay_checked(p140cp_replay("epoch-B",b,cache)),fresh),"epoch-miss-independent-fallback"),
   p131u_row(p140cc_hit(rf) && Bool.not(p140cc_good(p140cp_replay_checked(rf))),"invalid-body-admitted-then-rejected"),
   p131u_row(p140ce_checked(p140cp_replay_checked(rf),dg_check_world(bad)),"invalid-body-exact-diagnostic-state"),
   p131u_row(p140cc_hit(p140cp_replay("epoch-A",b,cache)) && p140ce_checked(p140cp_replay_checked(p140cp_replay("epoch-A",b,cache)),fresh),"failure-does-not-poison-checkpoint"),
   p131u_row(p140cc_refused(p140cp_admit("epoch-A",b,P140CPEmpty{}),"no checkpoint"),"empty-checkpoint-refusal"),
   p131u_row(p140ce_checked(p140cp_seed_checked(p140cp_seed("epoch-A",a,999)),dg_check_world(a)),"cut-past-end-fresh-result")]

@unsafe
def p140cc_controls() -> List<&2,String>:
  p140cc_rows(p140cc_parse(p140cc_text("Off{}")),p140cc_parse(p140cc_text("Onn{}")),p140cc_parse(p140cc_text("Bit")))
