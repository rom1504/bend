import Base

type NC_Text is Data:
  NC_Empty{}
  NC_Leaf{+text: String}
  NC_Join{+left: NC_Text, +right: NC_Text}

def nct_empty(text: NC_Text) -> Bool:
  match text:
    case NC_Empty{}: True{}
    case NC_Leaf{code}: False{}
    case NC_Join{left, right}: False{}

def nct_cat_right(left: NC_Text, right: NC_Text, empty: Bool) -> NC_Text:
  match empty:
    case True{}: left
    case False{}: NC_Join{left, right}

def nct_cat_left(left: NC_Text, +right: NC_Text, empty: Bool) -> NC_Text:
  match empty:
    case True{}: right
    case False{}: nct_cat_right(left, right, nct_empty(right))

def nct_cat(+left: NC_Text, right: NC_Text) -> NC_Text:
  nct_cat_left(left, right, nct_empty(left))

def render(t: NC_Text) -> String:
  match t:
    case NC_Empty{}: ""
    case NC_Leaf{code}: code
    case NC_Join{left, right}: render(left) ++ render(right)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(render(nct_cat(NC_Empty{}, NC_Leaf{"right"})))
    Unit <- IO.print(render(nct_cat(NC_Leaf{"left"}, NC_Empty{})))
    IO.print(render(nct_cat(NC_Leaf{"left"}, NC_Leaf{"right"})))

#|right
#|left
#|leftright
