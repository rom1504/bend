# Diagnostic orchestration only. Existing pure stages and final verifiers remain
# unchanged. All extra metadata is printed after both output files are closed.
type P135TPreparation is Data:
  P135TError{+result: P134UEmission}
  P135TLowered{+request: NR_Request, +certificate: P113ACertificate, +cache: P134UCache, +lowered: P128RawLowering}

type P135TMarks is Data:
  P135TMarks{+started: Nat, +frontend: Nat, +lowered: Nat, +optimized: Nat, +written: Nat}

@unsafe
def p135t_prepare(+request: NR_Request, +error: String, +cache: P134UCache) -> P135TPreparation:
  nt_choose(P135TPreparation,String.is_empty(error),
    u => P135TLowered{request,p113a_certificate(request),cache,p128raw_lower_request(request)},
    u => P135TError{p134u_request(request,error,cache)})

@unsafe
def p135t_result(prepared: P135TPreparation) -> P134UEmission:
  match prepared:
    case P135TError{result}: result
    case P135TLowered{request,certificate,cache,lowered}: p134u_session(request,certificate,cache,lowered)

# Pure bridge uses the exact factory and completion also used by timed IO.
# Its complete output/cache/stats can be compared with p134ns_planned.
@unsafe
def p135t_pure_plan(+plan: P86Plan, cache: P134UCache) -> P134UEmission:
  match plan:
    case P86PlanError{error}: p134ns_planned(plan,cache)
    case P86PlanReady{+request,verdict}:
      p135t_result(p135t_prepare(request,p111_runtime_admission(request),cache))

@unsafe
def p135t_complete(frontend: Nat, lowered: Nat,
  finish: Nat -> Nat -> Nat -> P134UEmission -> IO(U32), +result: P134UEmission) -> IO(U32):
  match result:
    case P134UEmission{emission,cache,stats}:
      do IO<U32>:
        optimized : Nat <- IO.now()
        finish(frontend,lowered,optimized,result)

@unsafe
def p135t_lowered(frontend: Nat, finish: Nat -> Nat -> Nat -> P134UEmission -> IO(U32), prepared: P135TPreparation) -> IO(U32):
  match prepared:
    case P135TError{result}:
      do IO<U32>:
        lowered : Nat <- IO.now()
        p135t_complete(frontend,lowered,finish,result)
    case P135TLowered{request,certificate,cache,lowering}:
      do IO<U32>:
        lowered : Nat <- IO.now()
        p135t_complete(frontend,lowered,finish,p134u_session(request,certificate,cache,lowering))

@unsafe
def p135t_plan(finish: Nat -> Nat -> Nat -> P134UEmission -> IO(U32), cache: P134UCache, +plan: P86Plan) -> IO(U32):
  match plan:
    case P86PlanError{error}:
      do IO<U32>:
        frontend : Nat <- IO.now()
        p135t_lowered(frontend,finish,P135TError{p134ns_planned(plan,cache)})
    case P86PlanReady{+request,verdict}:
      do IO<U32>:
        frontend : Nat <- IO.now()
        p135t_lowered(frontend,finish,p135t_prepare(request,p111_runtime_admission(request),cache))

@unsafe
def p135t_total(marks: P135TMarks) -> Nat:
  match marks:
    case P135TMarks{started,frontend,lowered,optimized,written}: Nat.sub(written,started)

@unsafe
def p135t_line(label: String, marks: P135TMarks) -> String:
  match marks:
    case P135TMarks{started,+frontend,+lowered,+optimized,written}:
      "phase135 stages " ++ label ++ " frontend_ms=" ++ Nat.show(Nat.sub(frontend,started)) ++
        " lowering_ms=" ++ Nat.show(Nat.sub(lowered,frontend)) ++
        " optimize_ms=" ++ Nat.show(Nat.sub(optimized,lowered)) ++
        " render_ms=" ++ Nat.show(Nat.sub(written,optimized))

@unsafe
def p135t_second(prepare_ms: Nat, +a_marks: P135TMarks, a_stats: List<&2,U32>,
  +b_started: Nat, frontend: Nat, lowered: Nat, optimized: Nat, out_b: String, result: P134UEmission) -> IO(U32):
  match result:
    case P134UEmission{emission,cache,stats}:
      do IO<U32>:
        code : U32 <- p135ms_write(out_b,emission)
        +finished : Nat <- IO.now()
        Unit <- IO.print("phase134 prepare_ms " ++ Nat.show(prepare_ms))
        Unit <- IO.print("phase134 A " ++ p134ns_numbers(a_stats) ++ "ms=" ++ Nat.show(p135t_total(a_marks)))
        Unit <- IO.print("phase134 B " ++ p134ns_numbers(stats) ++ "ms=" ++ Nat.show(Nat.sub(finished,b_started)))
        Unit <- IO.print(p135t_line("A",a_marks))
        Unit <- IO.print(p135t_line("B",P135TMarks{b_started,frontend,lowered,optimized,finished}))
        IO.pure(U32,code)

@unsafe
def p135t_first(prepare_ms: Nat, a_started: Nat, frontend: Nat, lowered: Nat, optimized: Nat,
  seed: P86Seed, b: String, source_b: String, out_a: String, out_b: String, warm: Bool, result: P134UEmission) -> IO(U32):
  match result:
    case P134UEmission{emission,cache,stats}:
      do IO<U32>:
        code : U32 <- p135ms_write(out_a,emission)
        +middle : Nat <- IO.now()
        p135t_plan(front => low => opt => next =>
          p135t_second(prepare_ms,P135TMarks{a_started,frontend,lowered,optimized,middle},stats,
            middle,front,low,opt,out_b,next),
          p134ns_cache(warm,cache),p86_plan(seed,b,source_b))

# Only the experimental framed entry is rerouted; ordinary native requests and
# the prior phase134-session implementation are preserved by composition.
@unsafe
def p135ms_prepared(started: Nat, +a: String, +b: String, out_a: String, out_b: String, warm: Bool, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      do IO<U32>:
        source_a : String <- p86_read_file(a)
        source_b : String <- p86_read_file(b)
        +ready : Nat <- IO.now()
        p135t_plan(front => low => opt => result =>
          p135t_first(Nat.sub(ready,started),ready,front,low,opt,seed,b,source_b,out_a,out_b,warm,result),
          P134UCache{[],[]},p86_plan(seed,a,source_a))
