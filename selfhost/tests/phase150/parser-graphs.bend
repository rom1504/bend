# Fifteen complete loader products. Paths identify supplied in-memory sources;
# this fixture performs no IO and does not read Base or any external module.
# Located source ranges exercise UTF-16 token origins and diagnostic ownership.
@unsafe
def p150g_source(name: String, path: String, +text: String, +begin: U32) -> FSource:
  FLocatedSource{FSource{name,path,text},begin,U32.add(U32.add(begin,dg_width(text)),1)}

@unsafe
def p150g_single(+name: String, text: String) -> FLoadTrace:
  +path = "/phase150/" ++ name ++ ".bend"
  f_load_graph_trace(path,[p150g_source(name,path,text,1)])

@unsafe
def p150g_namespace() -> FLoadTrace:
  f_load_graph_trace("/phase150/namespace/main.bend",[
    p150g_source("Unit","/phase150/namespace/main.bend",
      "import ./sub/library.bend as L\ndef main() -> L.Flag:\n  L.make()\n",1),
    p150g_source("Library","/phase150/namespace/sub/library.bend",
      "type Flag is Data:\n  Off{}\ndef make() -> Flag:\n  Off{}\n",10001)])

# Two aliases for the same canonical path must load the library only once.
@unsafe
def p150g_aliases() -> FLoadTrace:
  f_load_graph_trace("/phase150/aliases/main.bend",[
    p150g_source("Unit","/phase150/aliases/main.bend",
      "import ./library.bend as A\nimport ./library.bend as B\ndef first() -> A.Flag:\n  A.make()\ndef second() -> B.Flag:\n  B.make()\n",1),
    p150g_source("Library","/phase150/aliases/library.bend",
      "type Flag is Data:\n  Off{}\ndef make() -> Flag:\n  Off{}\n",10001)])

@unsafe
def p150g_graphs() -> List<&2,FLoadTrace>:
  [p150g_single("functions",
     "type Flag is Data:\n  Off{}\ndef ident(x: Flag) -> Flag:\n  x\ndef use() -> Flag:\n  ident(Off{})\n"),
   p150g_single("datatype-pattern",
     "type Flag is Data:\n  Off{}\ntype Box is Data:\n  Boxed{value: Flag}\ndef unwrap(box: Box) -> Flag:\n  match box:\n    case Boxed{value}: value\n"),
   p150g_single("law-fill",
     "type Flag is Data:\n  Off{}\nlaw early:\n  Flag\ndef middle() -> Flag:\n  Off{}\ndef early():\n  Off{}\n"),
   p150g_single("templates",
     "type Flag is Data:\n  Off{}\ndef ident(~A: Type, x: A) -> A:\n  x\ndef use() -> Flag:\n  ident(~Flag, Off{})\n"),
   p150g_namespace(),
   p150g_aliases(),
   p150g_single("unicode-quotes",
     "def text() -> String:\n  \"猫😀\\n\\u{1F600}\\\"\"\ndef glyph() -> Char:\n  '😀'\n"),
   p150g_single("comments-multiline-quote",
     "# header 😀\ndef text() -> String:\n  ( # nested comment 猫\n    \"first\n😀second\"\n  )\ndef ident(x: String) -> String:\n  x # final comment 😀\n"),
   p150g_single("duplicate-definition",
     "type Flag is Data:\n  Off{}\ndef keep() -> Flag:\n  Off{}\ndef keep() -> Flag:\n  Off{}\n"),
   p150g_single("duplicate-constructor",
     "type Flag is Data:\n  Off{}\n  Off{}\n"),
   p150g_single("incomplete-header","def broken(\n"),
   p150g_single("first-error",
     "type Flag is Data:\n  Off{}\ndef one(\ndef two(\n"),
   p150g_single("unterminated-quote","def text() -> String:\n  \"broken😀"),
   p150g_single("invalid-escape","def text() -> String:\n  \"bad\\q\"\n"),
   p150g_single("missing-import","import ./absent.bend as Missing\n")]

@unsafe
def p150g_names() -> List<&2,String>:
  ["functions","datatype-pattern","law-fill","templates","namespace",
   "two-aliases-one-module","unicode-quotes","comments-multiline-quote",
   "duplicate-definition","duplicate-constructor","incomplete-header",
   "first-error","unterminated-quote","invalid-escape","missing-import"]

# Empty means success. Nonempty entries are independently selected required
# diagnostic fragments, not values learned from either experimental execution.
# Unknown String/Char references in the literal controls are legal at this raw
# graph boundary; typechecking is a separate operation and is not claimed here.
@unsafe
def p150g_expected_errors() -> List<&2,String>:
  ["","","","","","","","",
   "duplicate declaration: keep","duplicate declaration: Off","a name",
   "got the keyword 'def'","expected term","an escape",
   "module source was not supplied"]

# Successful top-level event counts include separate law and definition events.
# Zero leaves an error case's partial-book size unconstrained; complete products
# still have to match the independently compiled reference byte for byte.
@unsafe
def p150g_expected_counts() -> List<&2,U32>:
  [3,3,4,3,3,4,2,2,0,0,0,0,0,0,0]

@unsafe
def p150g_count(book: List<&2,KDef>, count: U32) -> U32:
  match book:
    case Nil{}: count
    case Con{head,rest}: p150g_count(rest,U32.add(count,1))

@unsafe
def p150g_verdict(trace: FLoadTrace, +expected: String, +count: U32) -> Bool:
  match trace:
    case FLoadTrace{result,done,sources}:
      match result:
        case FResult{book,+error,imports}:
          f_choose(Bool,String.is_empty(expected),
            u => String.is_empty(error) && U32.is_eq(p150g_count(book,0),count),
            u => Bool.not(String.is_empty(error)) && String.contains(error,expected))

@unsafe
def p150g_check(traces: List<&2,FLoadTrace>, errors: List<&2,String>, counts: List<&2,U32>) -> Bool:
  match traces errors counts:
    case Nil{} Nil{} Nil{}: True{}
    case Con{trace,rest} Con{error,tail} Con{count,more}:
      f_choose(Bool,p150g_verdict(trace,error,count),u => p150g_check(rest,tail,more),u => False{})
    case _ _ _: False{}

@unsafe
def p150g_expected(traces: List<&2,FLoadTrace>) -> Bool:
  p150g_check(traces,p150g_expected_errors(),p150g_expected_counts())
