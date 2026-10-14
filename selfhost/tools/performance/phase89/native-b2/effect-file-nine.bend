@unsafe
def p86_effect_file(+base: String, +path: String) -> String:
  +dir = f_path_dir(base) ++ "effs/"
  +dot = f_path_dir(base) ++ "./effs/"
  kc(String, String.eq(path, dir ++ "args.c") || String.eq(path, dot ++ "args.c"), u => "args.c", u =>
    kc(String, String.eq(path, dir ++ "print.c") || String.eq(path, dot ++ "print.c"), u => "print.c", u =>
    kc(String, String.eq(path, dir ++ "now.c") || String.eq(path, dot ++ "now.c"), u => "now.c", u =>
    kc(String, String.eq(path, dir ++ "print_err.c") || String.eq(path, dot ++ "print_err.c"), u => "print_err.c", u =>
    kc(String, String.eq(path, dir ++ "file_open.c") || String.eq(path, dot ++ "file_open.c"), u => "file_open.c", u =>
    kc(String, String.eq(path, dir ++ "file_read.c") || String.eq(path, dot ++ "file_read.c"), u => "file_read.c", u =>
    kc(String, String.eq(path, dir ++ "file_size.c") || String.eq(path, dot ++ "file_size.c"), u => "file_size.c", u =>
    kc(String, String.eq(path, dir ++ "file_write.c") || String.eq(path, dot ++ "file_write.c"), u => "file_write.c", u =>
    kc(String, String.eq(path, dir ++ "file_close.c") || String.eq(path, dot ++ "file_close.c"), u => "file_close.c", u => "")))))))))

