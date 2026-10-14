@unsafe
def p86_effect_file(+base: String, +path: String) -> String:
  +dir = f_path_dir(base) ++ "effs/"
  +dot = f_path_dir(base) ++ "./effs/"
  kc(String, String.eq(path, dir ++ "args.c") || String.eq(path, dot ++ "args.c"), u => "args.c", u =>
    kc(String, String.eq(path, dir ++ "print.c") || String.eq(path, dot ++ "print.c"), u => "print.c", u =>
      kc(String, String.eq(path, dir ++ "now.c") || String.eq(path, dot ++ "now.c"), u => "now.c", u => "")))

