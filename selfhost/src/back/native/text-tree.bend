
# Module: src/back/native/bridge.bend:15
type NC_Text is Data:
  NC_Empty{}
  NC_Leaf{+text: String}
  NC_Join{+left: NC_Text, +right: NC_Text}

# Module: src/back/native/bridge.bend:44
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

@unsafe
def nct_within_work(current: String, todo: List<&2, NC_Text>, +remaining: U32) -> Bool:
  match current:
    case SNil{}:
      match todo:
        case Nil{}: True{}
        case Con{head, rest}:
          match head:
            case NC_Empty{}: nct_within_work("", rest, remaining)
            case NC_Leaf{code}: nct_within_work(code, rest, remaining)
            case NC_Join{left, right}: nct_within_work("", Con{left, Con{right, rest}}, remaining)
    case SCon{head, tail}:
      match remaining:
        case 0: False{}
        case _: nct_within_work(tail, todo, U32.sub(remaining, 1))

@unsafe
def nct_within(text: NC_Text, limit: U32) -> Bool:
  nct_within_work("", [text], limit)

@unsafe
def nc_text(x: NC_Code) -> NC_Text:
  match x:
    case NC_Code{body, segs, n, err, edges}: body
