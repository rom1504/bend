import Base

# Native code-generation IR. A word is an already evaluated C expression.
# Segments are shared by the CPU trampoline and Metal/CUDA dispatch switch.
type N_WordKind is Data:
  N_W32{}
  N_W64{}
  N_Box{}

type N_Param is Data:
  N_Param{+name: String, +kind: N_WordKind}

type N_Frame is Data:
  N_Direct{}
  N_Frame{+pop: U32, +slots: List<&2, String>}

type N_Segment is Data:
  N_Segment{+name: String, +params: List<&2, N_Param>, +result: U32, +frame: N_Frame, +body: String, +refs: List<&2, String>, +host: Bool, +spin: Bool, +fork: Bool, +bang: Bool}

type N_Constructor is Data:
  N_Constructor{+name: String, +arity: U32, +hot: Bool}

type N_Program is Data:
  N_Program{+segments: List<&2, N_Segment>, +constructors: List<&2, N_Constructor>, +image: List<&2, String>, +requests: String, +declarations: String, +show: String, +pure: Bool}

type N_Emitted is Data:
  N_Emitted{+code: String, +value: String, +fresh: U32}

law nc_ctor_codes:
  for +name: String
  String

@unsafe
def nc_ctor_codes(name):
  match name:
    case SNil{}:
      ""
    case SCon{h, rest}:
      U32.show(Char.to_u32(h)) ++ "_" ++ nc_ctor_codes(rest)

@unsafe
def nt_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

# Chunks arrive in reverse output order. Only each new chunk is traversed by
# append; the growing suffix stays on its right.

@unsafe
def nt_text_finish(xs: List<&2, String>, acc: String) -> String:
  match xs:
    case Nil{}: acc
    case Con{h, t}: nt_text_finish(t, h ++ acc)

@unsafe
def nt_count_go(-A: Data, xs: List<&2, A>, +n: U32) -> U32:
  match xs:
    case Nil{}: n
    case Con{h, t}: nt_count_go(A, t, U32.inc(n))

@unsafe
def nt_count(-A: Data, xs: List<&2, A>) -> U32:
  nt_count_go(A, xs, 0)

@unsafe
def nt_fid(k: String) -> String:
  "FID_" ++ nc_ctor_codes(k)

@unsafe
def nt_bool(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0

@unsafe
def nb_frame_results(+f: N_Frame, +n: U32) -> U32:
  match f:
    case N_Direct{}: 0
    case N_Frame{+pop, +at}: U32.sub(n, nt_count(String, at))

@unsafe
def nb_contains(+xs: List<&2, String>, +k: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{+h, +t}: String.eq(h, k) || nb_contains(t, k)

@unsafe
def old_nb_seg_ids_go(ss: List<&2, N_Segment>, +i: U32, +acc: String) -> String:
  match ss:
    case Nil{}: acc ++ "#define FID_IO_EMIT " ++ U32.show(i) ++ "\n#define BEND_CLO_APPLY " ++ U32.show(U32.add(i, 1)) ++ "\n#define FID_EXIT " ++ U32.show(U32.add(i, 2)) ++ "\n#define FID_ENTER " ++ U32.show(U32.add(i, 3)) ++ "\n"
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: old_nb_seg_ids_go(t, U32.inc(i), acc ++ "#define " ++ nt_fid(k) ++ " " ++ U32.show(i) ++ "\n")

@unsafe
def nb_seg_ids_chunks(ss: List<&2, N_Segment>, +i: U32, acc: List<&2, String>) -> String:
  match ss:
    case Nil{}: nt_text_finish(acc, "#define FID_IO_EMIT " ++ U32.show(i) ++ "\n#define BEND_CLO_APPLY " ++ U32.show(U32.add(i, 1)) ++ "\n#define FID_EXIT " ++ U32.show(U32.add(i, 2)) ++ "\n#define FID_ENTER " ++ U32.show(U32.add(i, 3)) ++ "\n")
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: nb_seg_ids_chunks(t, U32.inc(i), Con{"#define " ++ nt_fid(k) ++ " " ++ U32.show(i) ++ "\n", acc})

@unsafe
def nb_seg_ids_go(ss: List<&2, N_Segment>, +i: U32, +acc: String) -> String:
  nb_seg_ids_chunks(ss, i, Con{acc, Nil{}})

@unsafe
def nb_seg_ids(ss: List<&2, N_Segment>, i: U32) -> String:
  nb_seg_ids_go(ss, i, "")

@unsafe
def old_nb_arities_go(ss: List<&2, N_Segment>, +acc: String) -> String:
  match ss:
    case Nil{}: acc ++ "1, 2"
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: old_nb_arities_go(t, acc ++ U32.show(nt_count(N_Param, ps)) ++ ", ")

@unsafe
def nb_arities_chunks(ss: List<&2, N_Segment>, acc: List<&2, String>) -> String:
  match ss:
    case Nil{}: nt_text_finish(acc, "1, 2")
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: nb_arities_chunks(t, Con{U32.show(nt_count(N_Param, ps)) ++ ", ", acc})

@unsafe
def nb_arities_go(ss: List<&2, N_Segment>, +acc: String) -> String:
  nb_arities_chunks(ss, Con{acc, Nil{}})

@unsafe
def nb_arities(ss: List<&2, N_Segment>) -> String:
  nb_arities_go(ss, "")

@unsafe
def old_nb_result_words_go(ss: List<&2, N_Segment>, +acc: String) -> String:
  match ss:
    case Nil{}: acc ++ "0, 0"
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: old_nb_result_words_go(t, acc ++ U32.show(nb_frame_results(f, nt_count(N_Param, ps))) ++ ", ")

@unsafe
def nb_result_words_chunks(ss: List<&2, N_Segment>, acc: List<&2, String>) -> String:
  match ss:
    case Nil{}: nt_text_finish(acc, "0, 0")
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: nb_result_words_chunks(t, Con{U32.show(nb_frame_results(f, nt_count(N_Param, ps))) ++ ", ", acc})

@unsafe
def nb_result_words_go(ss: List<&2, N_Segment>, +acc: String) -> String:
  nb_result_words_chunks(ss, Con{acc, Nil{}})

@unsafe
def nb_result_words(ss: List<&2, N_Segment>) -> String:
  nb_result_words_go(ss, "")

@unsafe
def old_nb_flags_go(ss: List<&2, N_Segment>, +forks: List<&2, String>, +acc: String) -> String:
  match ss:
    case Nil{}: acc ++ "2, 0"
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}:
      old_nb_flags_go(t, forks, acc ++ U32.show(U32.add(nt_bool(bang), U32.mul(2, nt_bool(nt_choose(Bool, fork, u => False{}, u => Bool.not(nb_contains(forks, k))))))) ++ ", ")

@unsafe
def nb_flags_chunks(ss: List<&2, N_Segment>, +forks: List<&2, String>, acc: List<&2, String>) -> String:
  match ss:
    case Nil{}: nt_text_finish(acc, "2, 0")
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}:
      nb_flags_chunks(t, forks, Con{U32.show(U32.add(nt_bool(bang), U32.mul(2, nt_bool(nt_choose(Bool, fork, u => False{}, u => Bool.not(nb_contains(forks, k))))))) ++ ", ", acc})

@unsafe
def nb_flags_go(ss: List<&2, N_Segment>, +forks: List<&2, String>, +acc: String) -> String:
  nb_flags_chunks(ss, forks, Con{acc, Nil{}})

@unsafe
def nb_flags(ss: List<&2, N_Segment>, forks: List<&2, String>) -> String:
  nb_flags_go(ss, forks, "")

@unsafe
def old_nb_dispatch_go(ss: List<&2, N_Segment>, +acc: String) -> String:
  match ss:
    case Nil{}: acc ++ "WL_X(FID_IO_EMIT) WL_X(BEND_CLO_APPLY) WL_X(FID_EXIT)"
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: old_nb_dispatch_go(t, acc ++ "WL_X(" ++ nt_fid(k) ++ ") ")

@unsafe
def nb_dispatch_chunks(ss: List<&2, N_Segment>, acc: List<&2, String>) -> String:
  match ss:
    case Nil{}: nt_text_finish(acc, "WL_X(FID_IO_EMIT) WL_X(BEND_CLO_APPLY) WL_X(FID_EXIT)")
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: nb_dispatch_chunks(t, Con{"WL_X(" ++ nt_fid(k) ++ ") ", acc})

@unsafe
def nb_dispatch_go(ss: List<&2, N_Segment>, +acc: String) -> String:
  nb_dispatch_chunks(ss, Con{acc, Nil{}})

@unsafe
def nb_dispatch(ss: List<&2, N_Segment>) -> String:
  nb_dispatch_go(ss, "")

@unsafe
def p90_chars(s: String) -> List<&2,U32>:
  match s:
    case SNil{}: Nil{}
    case SCon{h,t}: Con{Char.to_u32(h),p90_chars(t)}

@unsafe
def p90_pack(xs: List<&2,String>) -> List<&2,U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h,t}: Con{U32.from_nat(String.length(h)),List.append(&2,U32,p90_chars(h),p90_pack(t))}

@unsafe
def p90_case(+ss: List<&2,N_Segment>, +forks: List<&2,String>, +i: U32, +prefix: String) -> List<&2,String>:
  [old_nb_seg_ids_go(ss,i,prefix), nb_seg_ids_go(ss,i,prefix),
   old_nb_arities_go(ss,prefix), nb_arities_go(ss,prefix),
   old_nb_result_words_go(ss,prefix), nb_result_words_go(ss,prefix),
   old_nb_flags_go(ss,forks,prefix), nb_flags_go(ss,forks,prefix),
   old_nb_dispatch_go(ss,prefix), nb_dispatch_go(ss,prefix),
   nb_seg_ids(ss,i), nb_arities(ss), nb_result_words(ss), nb_flags(ss,forks), nb_dispatch(ss),
   prefix, U32.show(nt_count(N_Segment,ss)), U32.show(nt_count(String,forks))]

@unsafe
def main() -> List<&2,U32>:
  p90_pack(List.append(&2,String,p90_case([],[],0,""),List.append(&2,String,p90_case([],["unused"],9,"prefix;\n"),List.append(&2,String,p90_case([N_Segment{"alpha",[],3,N_Direct{},"retained body 😀",["reference"],True{},False{},False{},False{}}],[],7,"P:"),List.append(&2,String,p90_case([N_Segment{"alpha",[],3,N_Direct{},"retained body 😀",["reference"],True{},False{},False{},False{}},N_Segment{"é\n😀",[N_Param{"p0", N_W32{}}, N_Param{"p1", N_W64{}}, N_Param{"p2", N_Box{}}],3,N_Frame{3,["x"]},"retained body 😀",["reference"],True{},False{},True{},True{}},N_Segment{"tail",[N_Param{"p0", N_W32{}}, N_Param{"p1", N_W64{}}],3,N_Frame{3,[]},"retained body 😀",["reference"],True{},False{},False{},True{}},N_Segment{"",[N_Param{"p0", N_W32{}}],3,N_Direct{},"retained body 😀",["reference"],True{},False{},False{},True{}}],["tail"],11,"é\n"),List.append(&2,String,p90_case([N_Segment{"alpha",[],3,N_Direct{},"retained body 😀",["reference"],True{},False{},False{},False{}},N_Segment{"é\n😀",[N_Param{"p0", N_W32{}}, N_Param{"p1", N_W64{}}, N_Param{"p2", N_Box{}}],3,N_Frame{3,["x"]},"retained body 😀",["reference"],True{},False{},True{},True{}},N_Segment{"tail",[N_Param{"p0", N_W32{}}, N_Param{"p1", N_W64{}}],3,N_Frame{3,[]},"retained body 😀",["reference"],True{},False{},False{},True{}},N_Segment{"",[N_Param{"p0", N_W32{}}],3,N_Direct{},"retained body 😀",["reference"],True{},False{},False{},True{}}],[],4294967294,"/*p*/"),List.append(&2,String,p90_case([N_Segment{"tail",[N_Param{"p0", N_W32{}}, N_Param{"p1", N_W64{}}],3,N_Frame{3,[]},"retained body 😀",["reference"],True{},False{},False{},True{}},N_Segment{"alpha",[],3,N_Direct{},"retained body 😀",["reference"],True{},False{},False{},False{}},N_Segment{"tail",[N_Param{"p0", N_W32{}}, N_Param{"p1", N_W64{}}],3,N_Frame{3,[]},"retained body 😀",["reference"],True{},False{},False{},True{}}],["alpha","tail"],1,""),Nil{})))))))
