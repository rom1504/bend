@unsafe
def p135ms_second(prepare_ms: Nat, a_ms: Nat, b_started: Nat, a_stats: List<&2,U32>, out_b: String, result: P134UEmission) -> IO(U32):
  match result:
    case P134UEmission{emission,cache,stats}:
      do IO<U32>:
        code : U32 <- p135ms_write(out_b,emission)
        finished : Nat <- IO.now()
        Unit <- IO.print("phase134 prepare_ms " ++ Nat.show(prepare_ms))
        Unit <- IO.print("phase134 A " ++ p134ns_numbers(a_stats) ++ "ms=" ++ Nat.show(a_ms))
        Unit <- IO.print("phase134 B " ++ p134ns_numbers(stats) ++ "ms=" ++ Nat.show(Nat.sub(finished,b_started)))
        IO.pure(U32,code)



@unsafe
def p135ms_first(prepare_ms: Nat, a_started: Nat, seed: P86Seed, b: String, source_b: String, out_a: String, out_b: String, warm: Bool, result: P134UEmission) -> IO(U32):
  match result:
    case P134UEmission{emission,cache,stats}:
      do IO<U32>:
        code : U32 <- p135ms_write(out_a,emission)
        +middle : Nat <- IO.now()
        p135ms_second(prepare_ms,Nat.sub(middle,a_started),middle,stats,out_b,p134ns_planned(p86_plan(seed,b,source_b),p134ns_cache(warm,cache)))



@unsafe
def p135ms_prepared(started: Nat, +a: String, +b: String, out_a: String, out_b: String, warm: Bool, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      do IO<U32>:
        source_a : String <- p86_read_file(a)
        source_b : String <- p86_read_file(b)
        +ready : Nat <- IO.now()
        p135ms_first(Nat.sub(ready,started),ready,seed,b,source_b,out_a,out_b,warm,p134ns_planned(p86_plan(seed,a,source_a),P134UCache{[],[]}))



@unsafe
def p135ms_start(a: String, b: String, +base: String, carrier: String, stamp: String, out_a: String, out_b: String, warm: Bool) -> IO(U32):
  do IO<U32>:
    started : Nat <- IO.now()
    base_text : String <- p86_read_file(base)
    carrier_text : String <- p86_read_file(carrier)
    p135ms_prepared(started,a,b,out_a,out_b,warm,p88_cache_prepare(base,base_text,carrier_text,stamp))



@unsafe
def p135m_start(framed: Bool, a: String, b: String, base: String, carrier: String, stamp: String, out_a: String, out_b: String, warm: Bool) -> IO(U32):
  match framed:
    case True{}: p135ms_start(a,b,base,carrier,stamp,out_a,out_b,warm)
    case False{}: p134ns_start(a,b,base,carrier,stamp,out_a,out_b,warm)
