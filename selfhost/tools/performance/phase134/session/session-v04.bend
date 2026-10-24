# Separate process-local experiment. Only returned typed caches are admitted;
# the producer/runtime/policy cannot change within this process.
@unsafe
def p134ns_paths(+a: String, +b: String, +base: String, +carrier: String, +out_a: String, +out_b: String, +mode: String) -> Bool:
  String.starts_with(a,"/") && String.starts_with(b,"/") &&
  String.starts_with(base,"/") && String.starts_with(carrier,"/") &&
  String.starts_with(out_a,"/") && String.starts_with(out_b,"/") &&
  Bool.not(String.eq(out_a,out_b)) &&
  Bool.not(String.eq(out_a,a) || String.eq(out_a,b) || String.eq(out_a,base) || String.eq(out_a,carrier)) &&
  Bool.not(String.eq(out_b,a) || String.eq(out_b,b) || String.eq(out_b,base) || String.eq(out_b,carrier)) &&
  (String.eq(mode,"warm") || String.eq(mode,"cold"))

def p134ns_cache(warm: Bool, cache: P134UCache) -> P134UCache:
  match warm:
    case False{}: P134UCache{[],[]}
    case True{}: cache

@unsafe
def p134ns_planned(plan: P86Plan, cache: P134UCache) -> P134UEmission:
  match plan:
    case P86PlanError{error}: P134UEmission{P111Emission{[],error},P134UCache{[],[]},[]}
    case P86PlanReady{+request,verdict}: p134u_request(request,p111_runtime_admission(request),cache)

@unsafe
def p134ns_write(path: String, emission: P111Emission) -> IO(U32):
  match emission:
    case P134Planned{plan}:
      do IO<U32>:
        file : File <- IO.try(File,File.open(path,"w"))
        p134w_drain(file,p134e_begin(plan))
    case P111Emission{chunks,+error}:
      IO.die(U32,1,nt_choose(String,String.is_empty(error),u => "session requires a sealed emission plan",u => error))

@unsafe
def p134ns_numbers(values: List<&2,U32>) -> String:
  match values:
    case Nil{}: ""
    case Con{head,tail}: U32.show(head) ++ " " ++ p134ns_numbers(tail)

@unsafe
def p134ns_second(prepare_ms: Nat, a_ms: Nat, b_started: Nat, a_stats: List<&2,U32>, out_b: String, result: P134UEmission) -> IO(U32):
  match result:
    case P134UEmission{emission,cache,stats}:
      do IO<U32>:
        code : U32 <- p134ns_write(out_b,emission)
        finished : Nat <- IO.now()
        Unit <- IO.print("phase134 prepare_ms " ++ Nat.show(prepare_ms))
        Unit <- IO.print("phase134 A " ++ p134ns_numbers(a_stats) ++ "ms=" ++ Nat.show(a_ms))
        Unit <- IO.print("phase134 B " ++ p134ns_numbers(stats) ++ "ms=" ++ Nat.show(Nat.sub(finished,b_started)))
        IO.pure(U32,code)

@unsafe
def p134ns_first(prepare_ms: Nat, a_started: Nat, seed: P86Seed, b: String, source_b: String, out_a: String, out_b: String, warm: Bool, result: P134UEmission) -> IO(U32):
  match result:
    case P134UEmission{emission,cache,stats}:
      do IO<U32>:
        code : U32 <- p134ns_write(out_a,emission)
        +middle : Nat <- IO.now()
        p134ns_second(prepare_ms,Nat.sub(middle,a_started),middle,stats,out_b,p134ns_planned(p86_plan(seed,b,source_b),p134ns_cache(warm,cache)))

@unsafe
def p134ns_prepared(started: Nat, +a: String, +b: String, out_a: String, out_b: String, warm: Bool, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      do IO<U32>:
        source_a : String <- p86_read_file(a)
        source_b : String <- p86_read_file(b)
        +ready : Nat <- IO.now()
        p134ns_first(Nat.sub(ready,started),ready,seed,b,source_b,out_a,out_b,warm,p134ns_planned(p86_plan(seed,a,source_a),P134UCache{[],[]}))

@unsafe
def p134ns_start(a: String, b: String, +base: String, carrier: String, stamp: String, out_a: String, out_b: String, warm: Bool) -> IO(U32):
  do IO<U32>:
    started : Nat <- IO.now()
    base_text : String <- p86_read_file(base)
    carrier_text : String <- p86_read_file(carrier)
    p134ns_prepared(started,a,b,out_a,out_b,warm,p88_cache_prepare(base,base_text,carrier_text,stamp))

@unsafe
def p134ns_cache_empty(cache: P134UCache) -> Bool:
  match cache:
    case P134UCache{inline,ranges}: List.is_empty(&2,P134USlot,inline) && List.is_empty(&2,P134RKMemo,ranges)

@unsafe
def p134ns_row(ok: Bool, +name: String) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":fail")

@unsafe
def p134ns_controls() -> List<&2,String>:
  [p134ns_row(p134ns_paths("/a","/b","/base","/carrier","/outA","/outB","warm"),"warm-paths"),
   p134ns_row(p134ns_paths("/a","/b","/base","/carrier","/outA","/outB","cold"),"cold-paths"),
   p134ns_row(Bool.not(p134ns_paths("a","/b","/base","/carrier","/outA","/outB","warm")),"relative-input-refused"),
   p134ns_row(Bool.not(p134ns_paths("/a","/b","/base","/carrier","outA","/outB","warm")),"relative-output-refused"),
   p134ns_row(Bool.not(p134ns_paths("/a","/b","/base","/carrier","/out","/out","warm")),"same-output-refused"),
   p134ns_row(Bool.not(p134ns_paths("/a","/b","/base","/carrier","/b","/outB","warm")),"output-input-refused"),
   p134ns_row(Bool.not(p134ns_paths("/a","/b","/base","/carrier","/outA","/base","warm")),"output-base-refused"),
   p134ns_row(Bool.not(p134ns_paths("/a","/b","/base","/carrier","/outA","/outB","external")),"unknown-policy-refused"),
   p134ns_row(p134ns_cache_empty(p134ns_cache(False{},P134UCache{[P134UEmpty{}],[P134RKEmpty{}]})),"cold-drops-state"),
   p134ns_row(Bool.not(p134ns_cache_empty(p134ns_cache(True{},P134UCache{[P134UEmpty{}],[P134RKEmpty{}]}))),"warm-retains-state")]
