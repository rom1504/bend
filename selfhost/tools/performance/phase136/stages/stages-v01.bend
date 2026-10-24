# One explicit diagnostic continuation per existing compiler stage. A closure
# delays the next stage, never the result which ends the current interval.
type P136Step is Type:
  P136More{label: String, next: Unit -> P136Step}
  P136Plan{plan: P86Plan}
  P136Emission{emission: P111Emission}

@unsafe
def p136s_begin(seed: P86Seed, path: String, text: String) -> P136Step:
  P136More{"parse_import",u => p136f_parse(seed,path,text)}

@unsafe
def p136f_parse_loaded(seed: P86Seed, +load: FPrefixLoad) -> P136Step:
  match seed load:
    case P86Seed{base,book,fresh,ready,+world} FPrefixLoad{trace,prefix,suffix,eligible}:
      match trace:
        case FLoadTrace{result,done,sources}:
          match result:
            case FResult{+original,+error,imports}:
              kc(P136Step,String.is_empty(error),
                u => P136More{"check",v => p136f_checked(load,world,original,check_program_diagnostic_world(load,Nil{},world))},
                u => P136Plan{P86PlanError{"parse: " ++ error}})

@unsafe
def p136f_checked(load: FPrefixLoad, world: KBasePreparedWorld, original: List<&2,KDef>, result: DResult) -> P136Step:
  match result:
    case DResult{+error,book,diagnostic}:
      kc(P136Step,String.is_empty(error),
        u => P136More{"driver_report",v => p136f_reported(load,world,book,driver_report_data(original))},
        u => P136Plan{P86PlanError{"check: " ++ error}})

@unsafe
def p136f_reported(load: FPrefixLoad, world: KBasePreparedWorld, +book: List<&2,KDef>, report: DR_Report) -> P136Step:
  match report:
    case DR_Report{verdict,names}:
      P136More{"ownership",u => p136f_owned(load,world,book,verdict,driver_emit_owned(book))}

@unsafe
def p136f_owned(load: FPrefixLoad, world: KBasePreparedWorld, +book: List<&2,KDef>, verdict: String, +error: String) -> P136Step:
  kc(P136Step,String.is_empty(error),
    u => P136More{"compile_eligibility",v => p136f_eligible(load,world,book,verdict,j_compile_error(book))},
    u => P136Plan{P86PlanError{"compile: " ++ error}})

@unsafe
def p136f_eligible(load: FPrefixLoad, world: KBasePreparedWorld, book: List<&2,KDef>, verdict: String, +error: String) -> P136Step:
  kc(P136Step,String.is_empty(error),
    u => P136More{"context",v => p136f_context(book_context_world(book,load,world),verdict)},
    u => P136Plan{P86PlanError{"compile: " ++ error}})

@unsafe
def p136f_context(+context: List<&2,KDef>, verdict: String) -> P136Step:
  P136More{"annotation",u => p136f_stops(context,nc_annotation_stops(context),verdict)}

@unsafe
def p136f_stops(+context: List<&2,KDef>, +stops: List<&2,String>, verdict: String) -> P136Step:
  p136f_annotated(context,stops,verdict,annotate_selected(context,reach_book(context,["main"],stops),stops))

@unsafe
def p136f_annotated(+context: List<&2,KDef>, +stops: List<&2,String>, verdict: String, +annotated: List<&2,KDef>) -> P136Step:
  P136More{"annotation_check",u => p136f_annotation_checked(context,annotated,verdict,jl_checked_error(context,annotated,["main"],stops))}

@unsafe
def p136f_annotation_checked(context: List<&2,KDef>, annotated: List<&2,KDef>, verdict: String, +error: String) -> P136Step:
  kc(P136Step,String.is_empty(error),
    u => P136More{"erasure",v => P136Plan{P86PlanReady{nr_prepare_annotated(context,annotated),verdict}}},
    u => P136Plan{P86PlanError{"compile: " ++ error}})

@unsafe
def p136b_plan(plan: P86Plan) -> P136Step:
  match plan:
    case P86PlanError{error}: P136Emission{P111Emission{[],error}}
    case P86PlanReady{+request,verdict}:
      P136More{"runtime_admission",u => p136b_admitted(request,p111_runtime_admission(request))}

@unsafe
def p136b_admitted(+request: NR_Request, +error: String) -> P136Step:
  nt_choose(P136Step,String.is_empty(error),
    u => P136More{"raw_lowering",v => p136b_lowered(request,p113a_certificate(request),p128raw_lower_request(request))},
    u => P136Emission{p128raw_emit_admitted(request,error)})

@unsafe
def p136b_lowered(request: NR_Request, certificate: P113ACertificate, session: P128RawLowering) -> P136Step:
  match session:
    case P128RawLowering{lowered,raw}:
      P136More{"open_verify",u => p136b_opened(request,certificate,raw,p114s_open_lowered(lowered))}

@unsafe
def p136b_opened(request: NR_Request, certificate: P113ACertificate, raw: List<&2,P113DCandidate>, lowered: P114SLowered) -> P136Step:
  match lowered:
    case P114SLowered{boundary,error}:
      P136More{"inline_commit",u => p136b_inlined(request,certificate,raw,p114s_inline_lowered(P114SLowered{boundary,error}))}

@unsafe
def p136b_inlined(request: NR_Request, certificate: P113ACertificate, raw: List<&2,P113DCandidate>, lowered: P114SLowered) -> P136Step:
  match lowered:
    case P114SLowered{boundary,error}:
      P136More{"ranges_commit",u => p136b_ranged(request,certificate,raw,p114s_ranges_lowered(P114SLowered{boundary,error}))}

@unsafe
def p136b_ranged(request: NR_Request, certificate: P113ACertificate, raw: List<&2,P113DCandidate>, lowered: P114SLowered) -> P136Step:
  match lowered:
    case P114SLowered{boundary,error}:
      P136More{"final_verify_borrow",u => P136Emission{p128raw_lowered(request,raw,p113a_finish(certificate,p114s_close_lowered(P114SLowered{boundary,error})))}}

# Pure bridge and native IO consume the same transitions.
@unsafe
def p136s_pure_front(step: P136Step) -> P86Plan:
  match step:
    case P136More{label,next}: p136s_pure_front(next(Unit{}))
    case P136Plan{plan}: plan
    case P136Emission{emission}: P86PlanError{"phase136 internal front route"}

@unsafe
def p136s_pure_emit(step: P136Step) -> P111Emission:
  match step:
    case P136More{label,next}: p136s_pure_emit(next(Unit{}))
    case P136Plan{plan}: p136s_pure_emit(p136b_plan(plan))
    case P136Emission{emission}: p134e_collect(emission)

@unsafe
def p136s_pure_plan(seed: P86Seed, path: String, text: String) -> P86Plan:
  p136s_pure_front(p136s_begin(seed,path,text))

@unsafe
def p136s_pure_backend(plan: P86Plan) -> P111Emission:
  p136s_pure_emit(p136b_plan(plan))

# Metadata is printed only after QBE output closes. Milliseconds are monotonic.
@unsafe
def p136s_print(lines: List<&2,String>) -> IO(U32):
  match lines:
    case Nil{}: IO.pure(U32,0)
    case Con{line,rest}:
      do IO<U32>:
        Unit <- IO.print_err(line)
        p136s_print(rest)

@unsafe
def p136s_line(label: String, before: Nat, after: Nat) -> String:
  "phase136 stage " ++ label ++ " ms=" ++ Nat.show(Nat.sub(after,before))

@unsafe
def p136s_record(label: String, before: Nat, lines: List<&2,String>, step: P136Step) -> IO(U32):
  do IO<U32>:
    +after : Nat <- IO.now()
    p136s_io(after,Con{p136s_line(label,before,after),lines},step)

@unsafe
def p136s_after(label: String, before: Nat, lines: List<&2,String>, step: P136Step) -> IO(U32):
  match step:
    case P136More{next_label,next}: p136s_record(label,before,lines,P136More{next_label,next})
    case P136Plan{plan}: p136s_record(label,before,lines,P136Plan{plan})
    case P136Emission{emission}: p136s_record(label,before,lines,P136Emission{emission})

@unsafe
def p136s_io(before: Nat, lines: List<&2,String>, step: P136Step) -> IO(U32):
  match step:
    case P136More{label,next}: p136s_after(label,before,lines,next(Unit{}))
    case P136Plan{plan}: p136s_io(before,lines,p136b_plan(plan))
    case P136Emission{emission}:
      do IO<U32>:
        code : U32 <- p111_print_emission(emission)
        after : Nat <- IO.now()
        ignored : U32 <- p136s_print(nt_reverse(String,Con{p136s_line("render",before,after),lines},[]))
        IO.pure(U32,code)

@unsafe
def p136s_prepared(path: String, source: String, before: Nat, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{seed}:
      do IO<U32>:
        +after : Nat <- IO.now()
        p136s_io(after,[p136s_line("base_prepare",before,after)],p136s_begin(seed,path,source))

@unsafe
def p136s_request(+path: String, +base: String, carrier: String, stamp: String) -> IO(U32):
  do IO<U32>:
    source : String <- p86_read_file(path)
    base_text : String <- p86_read_file(base)
    carrier_text : String <- p86_read_file(carrier)
    before : Nat <- IO.now()
    p136s_prepared(path,source,before,p88_cache_prepare(base,base_text,carrier_text,stamp))
