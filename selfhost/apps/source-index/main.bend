import Base

# A lexical source inventory. Every input character is read from a runtime file.
type LexMode is Data:
  Plain{}
  Comment{}
  Single{}
  Double{}
  EscapeSingle{}
  EscapeDouble{}

type DeclKind is Data:
  NoDecl{}
  Definition{}
  TypeDecl{}
  ImportDecl{}

type Entry is Data:
  Entry{kind: DeclKind, line: U32, name: String}

type Token is Data:
  Token{word: String, rest: String}

type SourceIndex is Data:
  SourceIndex{lines: U32, characters: U32, bytes: U32, comments: U32, mode: LexMode, entries: List<&2, Entry>}

type Counts is Data:
  Counts{definitions: U32, types: U32, imports: U32}

def choose(-A: Type, flag: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match flag:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

def utf8_width_flags(one: Bool, two: Bool, three: Bool) -> U32:
  match one two three:
    case True{} _ _: 1
    case False{} True{} _: 2
    case False{} False{} True{}: 3
    case False{} False{} False{}: 4

def utf8_width(+code: U32) -> U32:
  utf8_width_flags(U32.is_lt(code, 128), U32.is_lt(code, 2048), U32.is_lt(code, 65536))

def plain_mode_flags(comment: Bool, double: Bool, single: Bool) -> LexMode:
  match comment double single:
    case True{} _ _: Comment{}
    case False{} True{} _: Double{}
    case False{} False{} True{}: Single{}
    case False{} False{} False{}: Plain{}

def plain_mode(+code: U32) -> LexMode:
  plain_mode_flags(U32.is_eq(code, 35), U32.is_eq(code, 34), U32.is_eq(code, 39))

def quote_mode(ordinary: LexMode, escape: LexMode, slash: Bool, close: Bool) -> LexMode:
  match slash close:
    case True{} _: escape
    case False{} True{}: Plain{}
    case False{} False{}: ordinary

def next_mode(mode: LexMode, +code: U32) -> LexMode:
  match mode:
    case Plain{}: plain_mode(code)
    case Comment{}: Comment{}
    case Single{}: quote_mode(Single{}, EscapeSingle{}, U32.is_eq(code, 92), U32.is_eq(code, 39))
    case Double{}: quote_mode(Double{}, EscapeDouble{}, U32.is_eq(code, 92), U32.is_eq(code, 34))
    case EscapeSingle{}: Single{}
    case EscapeDouble{}: Double{}

def next_line(mode: LexMode) -> LexMode:
  match mode:
    case Comment{}: Plain{}
    case EscapeSingle{}: Single{}
    case EscapeDouble{}: Double{}
    case other: other

def is_comment(mode: LexMode) -> U32:
  match mode:
    case Comment{}: 1
    case _: 0

def unfinished(mode: LexMode) -> U32:
  match mode:
    case Plain{}: 0
    case Comment{}: 0
    case _: 1

def is_name(+code: U32) -> Bool:
  (U32.is_ge(code, 65) && U32.is_le(code, 90)) ||
  (U32.is_ge(code, 97) && U32.is_le(code, 122)) ||
  (U32.is_ge(code, 48) && U32.is_le(code, 57)) ||
  U32.is_eq(code, 95) || U32.is_eq(code, 46) || U32.is_ge(code, 128)

def is_space(+code: U32) -> Bool:
  U32.is_eq(code, 32) || U32.is_eq(code, 9) || U32.is_eq(code, 13)

def read_word(text: String, +acc: String) -> Token:
  match text:
    case SNil{}: Token{String.reverse(acc), SNil{}}
    case SCon{+h, +rest}:
      choose(Token, is_name(Char.to_u32(h)),
        u => read_word(rest, SCon{h, acc}),
        u => Token{String.reverse(acc), SCon{h, rest}})

def skip_space(text: String) -> String:
  match text:
    case SNil{}: SNil{}
    case SCon{+h, +rest}:
      choose(String, is_space(Char.to_u32(h)), u => skip_space(rest), u => SCon{h, rest})

def read_quoted(text: String, +acc: String, +escaped: Bool) -> Token:
  match text:
    case SNil{}: Token{String.reverse(acc), SNil{}}
    case SCon{+h, +rest}:
      choose(Token, Char.is_eq(h, '\n'), u => Token{String.reverse(acc), SCon{h, rest}}, u =>
        choose(Token, escaped, v => read_quoted(rest, SCon{h, acc}, False{}), v =>
          choose(Token, Char.is_eq(h, '\\'), w => read_quoted(rest, SCon{h, acc}, True{}), w =>
            choose(Token, Char.is_eq(h, '"'), z => Token{String.reverse(SCon{h, acc}), rest}, z => read_quoted(rest, SCon{h, acc}, False{})))))

def operand_first(h: Char, rest: String, quoted: Bool) -> Token:
  match quoted:
    case True{}: read_quoted(rest, SCon{h, SNil{}}, False{})
    case False{}: read_word(SCon{h, rest}, "")

def operand(text: String) -> Token:
  match text:
    case SNil{}: Token{"", ""}
    case SCon{+h, rest}: operand_first(h, rest, Char.is_eq(h, '"'))

def keyword_flags(definition: Bool, type_decl: Bool, import_decl: Bool) -> DeclKind:
  match definition type_decl import_decl:
    case True{} _ _: Definition{}
    case False{} True{} _: TypeDecl{}
    case False{} False{} True{}: ImportDecl{}
    case False{} False{} False{}: NoDecl{}

def keyword(+word: String) -> DeclKind:
  keyword_flags(String.eq(word, "def"), String.eq(word, "type"), String.eq(word, "import"))

def make_nonempty(kind: DeclKind, line: U32, name: String, empty: Bool) -> Maybe<&2, Entry>:
  match empty:
    case True{}: None{}
    case False{}: Some{Entry{kind, line, name}}

def make_entry(kind: DeclKind, line: U32, token: Token) -> Maybe<&2, Entry>:
  match token:
    case Token{+word, rest}: make_nonempty(kind, line, word, String.is_empty(word))

def declaration_kind(kind: DeclKind, rest: String, line: U32) -> Maybe<&2, Entry>:
  match kind:
    case NoDecl{}: None{}
    case other: make_entry(other, line, operand(skip_space(rest)))

def declaration_word(token: Token, line: U32) -> Maybe<&2, Entry>:
  match token:
    case Token{word, rest}: declaration_kind(keyword(word), rest, line)

def remove_bom_char(h: Char, rest: String, bom: Bool) -> String:
  match bom:
    case True{}: rest
    case False{}: SCon{h, rest}

def remove_bom(first: Bool, text: String) -> String:
  match first text:
    case True{} SCon{+h, rest}: remove_bom_char(h, rest, U32.is_eq(Char.to_u32(h), 65279))
    case _ other: other

def declaration(text: String, mode: LexMode, +line: U32) -> Maybe<&2, Entry>:
  match mode:
    case Plain{}: declaration_word(read_word(remove_bom(U32.is_eq(line, 1), text), ""), line)
    case _: None{}

def add_entry(entry: Maybe<&2, Entry>, entries: List<&2, Entry>) -> List<&2, Entry>:
  match entry:
    case None{}: entries
    case Some{value}: Con{value, entries}

def index_entry(start: Bool, mode: LexMode, h: Char, rest: String, line: U32, entries: List<&2, Entry>) -> List<&2, Entry>:
  match start:
    case True{}: add_entry(declaration(SCon{h, rest}, mode, line), entries)
    case False{}: entries

def newline_mode(newline: Bool, mode: LexMode) -> LexMode:
  match newline:
    case True{}: next_line(mode)
    case False{}: mode

def index_lines(text: String, +mode: LexMode, lines: U32, characters: U32, bytes: U32, comments: U32, entries: List<&2, Entry>, +start: Bool) -> SourceIndex:
  match text:
    case SNil{}: SourceIndex{lines, characters, bytes, comments, mode, entries}
    case SCon{+h, +rest}:
      +number = U32.add(lines, Bool.to_u32(start))
      +code = Char.to_u32(h)
      +after = next_mode(mode, code)
      +newline = U32.is_eq(code, 10)
      index_lines(rest, newline_mode(newline, after), number, U32.inc(characters), U32.add(bytes, utf8_width(code)), U32.add(comments, U32.sub(is_comment(after), is_comment(mode))), index_entry(start, mode, h, rest, number, entries), newline)

def count_kind(counts: Counts, kind: DeclKind) -> Counts:
  match counts:
    case Counts{defs, types, imports}:
      match kind:
        case Definition{}: Counts{U32.inc(defs), types, imports}
        case TypeDecl{}: Counts{defs, U32.inc(types), imports}
        case ImportDecl{}: Counts{defs, types, U32.inc(imports)}
        case NoDecl{}: Counts{defs, types, imports}

def count_entries(entries: List<&2, Entry>, counts: Counts) -> Counts:
  match entries:
    case Nil{}: counts
    case Con{Entry{kind, line, name}, rest}: count_entries(rest, count_kind(counts, kind))

def kind_name(kind: DeclKind) -> String:
  match kind:
    case Definition{}: "def"
    case TypeDecl{}: "type"
    case ImportDecl{}: "import"
    case NoDecl{}: "unknown"

def escape_flags(h: Char, tab: Bool, cr: Bool, slash: Bool) -> String:
  match tab cr slash:
    case True{} _ _: "t\\"
    case False{} True{} _: "r\\"
    case False{} False{} True{}: "\\\\"
    case False{} False{} False{}: SCon{h, SNil{}}

def escape_char(h: Char, +code: U32) -> String:
  escape_flags(h, U32.is_eq(code, 9), U32.is_eq(code, 13), U32.is_eq(code, 92))

def escape_field(text: String, acc: String) -> String:
  match text:
    case SNil{}: String.reverse(acc)
    case SCon{+h, rest}: escape_field(rest, escape_char(h, Char.to_u32(h)) ++ acc)

def render_entries(entries: List<&2, Entry>, suffix: String) -> String:
  match entries:
    case Nil{}: suffix
    case Con{Entry{kind, line, name}, rest}:
      render_entries(rest, "\n" ++ kind_name(kind) ++ "\t" ++ U32.show(line) ++ "\t" ++ escape_field(name, "") ++ suffix)

def render_counts(counts: Counts) -> String:
  match counts:
    case Counts{defs, types, imports}:
      "\ndefinitions\t" ++ U32.show(defs) ++ "\ntypes\t" ++ U32.show(types) ++ "\nimports\t" ++ U32.show(imports)

def report_size(exact: Bool, output: String) -> IO(Unit):
  match exact:
    case True{}: IO.print(output)
    case False{}: IO.print("error\tread-size-mismatch")

def report(index: SourceIndex, expected_bytes: U32) -> IO(Unit):
  match index:
    case SourceIndex{lines, characters, +bytes, comments, mode, +entries}:
      report_size(U32.is_eq(bytes, expected_bytes), "format\tbend-source-index-v1\nbytes\t" ++ U32.show(bytes) ++ "\ncharacters\t" ++ U32.show(characters) ++ "\nlines\t" ++ U32.show(lines) ++ "\ncomment_lines\t" ++ U32.show(comments) ++ render_counts(count_entries(entries, Counts{0, 0, 0})) ++ "\nunterminated_quote\t" ++ U32.show(unfinished(mode)) ++ "\nkind\tline\tname" ++ render_entries(entries, ""))

def read_result(result: Result<&1, &1, U32 & String, String>, size: U32) -> IO(Unit):
  match result:
    case Fail{error}: IO.print("error\tread")
    case Done{text}: report(index_lines(text, Plain{}, 0, 0, 0, 0, Nil{}, True{}), size)

def read_done(pair: File & Result<&1, &1, U32 & String, String>, size: U32) -> IO(Unit):
  (file, result) = pair
  do IO<Unit>:
    Unit <- File.close(file)
    read_result(result, size)

def read_bounded(file: File, +size: U32, allowed: Bool) -> IO(Unit):
  match allowed:
    case True{}:
      do IO<Unit>:
        pair : File & Result<&1, &1, U32 & String, String> <- File.read(file, U32.inc(size))
        read_done(pair, size)
    case False{}:
      do IO<Unit>:
        Unit <- File.close(file)
        IO.print("error\ttoo-large")

def size_result(file: File, result: Result<&1, &1, U32 & String, U32>) -> IO(Unit):
  match result:
    case Fail{error}:
      do IO<Unit>:
        Unit <- File.close(file)
        IO.print("error\tsize")
    case Done{+size}: read_bounded(file, size, U32.is_le(size, 8388608))

def size_done(pair: File & Result<&1, &1, U32 & String, U32>) -> IO(Unit):
  (file, result) = pair
  size_result(file, result)

def open_done(result: Result<&1, &1, U32 & String, File>) -> IO(Unit):
  match result:
    case Fail{error}: IO.print("error\topen")
    case Done{file}:
      do IO<Unit>:
        pair : File & Result<&1, &1, U32 & String, U32> <- File.size(file)
        size_done(pair)

def open_path(path: String) -> IO(Unit):
  do IO<Unit>:
    result : Result<&1, &1, U32 & String, File> <- File.open(path, "r")
    open_done(result)

def find_file(args: List<&1, String>, found: Bool) -> IO(Unit):
  match args found:
    case Nil{} _: IO.print("usage: source-index --file PATH")
    case Con{path, rest} True{}: open_path(path)
    case Con{arg, rest} False{}: find_file(rest, String.eq(arg, "--file"))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1, String> <- IO.args()
    find_file(args, False{})

# Without --file:
#|usage: source-index --file PATH
