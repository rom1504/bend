import Base

# Native bodies remain ordered Data until a segment or flat-function boundary.
# Empty leaves/joins are normalized, so emptiness is an exact tag test.
type NC_Text is Data:
  NC_Empty{}
  NC_Leaf{+text: String}
  NC_Join{+left: NC_Text, +right: NC_Text}

@unsafe
def nct_leaf(text: String) -> NC_Text:
  match text:
    case SNil{}: NC_Empty{}
    case SCon{head, tail}: NC_Leaf{SCon{head, tail}}

@unsafe
def nct_empty(text: NC_Text) -> Bool:
  match text:
    case NC_Empty{}: True{}
    case NC_Leaf{code}: False{}
    case NC_Join{left, right}: False{}

# The predicate borrows a Data reference; no function-valued continuation is
# stored or duplicated. Each chosen branch consumes its two tree arguments.
@unsafe
def nct_cat_right(left: NC_Text, right: NC_Text, empty: Bool) -> NC_Text:
  match empty:
    case True{}: left
    case False{}: NC_Join{left, right}

@unsafe
def nct_cat_left(left: NC_Text, +right: NC_Text, empty: Bool) -> NC_Text:
  match empty:
    case True{}: right
    case False{}: nct_cat_right(left, right, nct_empty(right))

@unsafe
def nct_cat(+left: NC_Text, right: NC_Text) -> NC_Text:
  nct_cat_left(left, right, nct_empty(left))

# This is the existing JDText right-first worklist algorithm, without JS marker
# metadata or cached lengths. A growing output string is never an append left.
@unsafe
def nct_render_work(todo: List<&2, NC_Text>, suffix: String) -> String:
  match todo:
    case Nil{}: suffix
    case Con{head, rest}:
      match head:
        case NC_Empty{}: nct_render_work(rest, suffix)
        case NC_Leaf{code}: nct_render_work(rest, code ++ suffix)
        case NC_Join{left, right}: nct_render_work(Con{right, Con{left, rest}}, suffix)

@unsafe
def nct_render(text: NC_Text) -> String:
  nct_render_work([text], "")

# Walk at most limit+1 characters, without flattening or assuming byte length.
# Both pending trees and the current leaf use explicit tail-recursive state.
@unsafe
def nct_within_work(todo: List<&2, NC_Text>, current: String, +remaining: U32) -> Bool:
  match current:
    case SNil{}:
      match todo:
        case Nil{}: True{}
        case Con{head, rest}:
          match head:
            case NC_Empty{}: nct_within_work(rest, "", remaining)
            case NC_Leaf{code}: nct_within_work(rest, code, remaining)
            case NC_Join{left, right}: nct_within_work(Con{left, Con{right, rest}}, "", remaining)
    case SCon{head, tail}:
      match remaining:
        case 0: False{}
        case _: nct_within_work(todo, tail, U32.sub(remaining, 1))

@unsafe
def nct_within(text: NC_Text, limit: U32) -> Bool:
  nct_within_work([text], "", limit)

type P89TextCase is Data:
  P89TextCase{+name: String, +text: String, +empty: Bool, +within0: Bool, +within4095: Bool, +within4096: Bool, +within4097: Bool}

@unsafe
def p89_text_case(name: String, +tree: NC_Text) -> P89TextCase:
  P89TextCase{name, nct_render(tree), nct_empty(tree), nct_within(tree, 0), nct_within(tree, 4095), nct_within(tree, 4096), nct_within(tree, 4097)}

@unsafe
def p89_text_left(+n: U32, +leaf: NC_Text, tree: NC_Text) -> NC_Text:
  match n:
    case 0: tree
    case _: p89_text_left(U32.sub(n, 1), leaf, nct_cat(tree, leaf))

@unsafe
def p89_text_right(+n: U32, +leaf: NC_Text, tree: NC_Text) -> NC_Text:
  match n:
    case 0: tree
    case _: p89_text_right(U32.sub(n, 1), leaf, nct_cat(leaf, tree))

@unsafe
def p89_text_shared(+tree: NC_Text) -> NC_Text:
  nct_cat(tree, nct_cat(nct_leaf("|"), tree))

@unsafe
def main() -> List<&2, P89TextCase>:
  [
    p89_text_case("empty-literal", nct_leaf("")),
    p89_text_case("empty-node", NC_Empty{}),
    p89_text_case("left-empty", nct_cat(nct_leaf(""), nct_leaf("R"))),
    p89_text_case("right-empty", nct_cat(nct_leaf("L"), nct_leaf(""))),
    p89_text_case("both-empty", nct_cat(nct_leaf(""), nct_cat(nct_leaf(""), NC_Empty{}))),
    p89_text_case("nested-order", nct_cat(nct_cat(nct_leaf("a"), nct_leaf("bc")), nct_cat(nct_leaf("de"), nct_leaf("f")))),
    p89_text_case("unicode", nct_cat(nct_leaf("λ"), nct_leaf("😀\n"))),
    p89_text_case("shared-leaf", p89_text_shared(nct_leaf("shared"))),
    p89_text_case("shared-tree", p89_text_shared(nct_cat(nct_leaf("A"), nct_leaf("B")))),
    p89_text_case("skew-left-8192", p89_text_left(8192, nct_leaf("x"), NC_Empty{})),
    p89_text_case("skew-right-8192", p89_text_right(8192, nct_leaf("x"), NC_Empty{})),
    p89_text_case("ascii-4095", p89_text_left(4095, nct_leaf("a"), NC_Empty{})),
    p89_text_case("ascii-4096", p89_text_left(4096, nct_leaf("a"), NC_Empty{})),
    p89_text_case("ascii-4097", p89_text_left(4097, nct_leaf("a"), NC_Empty{})),
    p89_text_case("unicode-4095", p89_text_left(4095, nct_leaf("😀"), NC_Empty{})),
    p89_text_case("unicode-4096", p89_text_left(4096, nct_leaf("😀"), NC_Empty{})),
    p89_text_case("unicode-4097", p89_text_left(4097, nct_leaf("😀"), NC_Empty{})),
    p89_text_case("split-4096", nct_cat(p89_text_left(2048, nct_leaf("a"), NC_Empty{}), p89_text_right(2048, nct_leaf("😀"), NC_Empty{}))),
    p89_text_case("split-4097", nct_cat(p89_text_left(2048, nct_leaf("a"), NC_Empty{}), p89_text_right(2049, nct_leaf("😀"), NC_Empty{})))
  ]
