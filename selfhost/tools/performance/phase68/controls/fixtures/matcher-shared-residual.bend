# The same owned constructor is the matcher scrutinee and a residual argument.
# The partially applied path also captures its payload before a second use.
import Base

type TextBox68 is Data:
  TextBox68{value: String}

def append_boxes68(box: TextBox68) -> TextBox68 -> String:
  match box:
    case TextBox68{prefix}:
      other =>
        match other:
          case TextBox68{suffix}:
            String.append(prefix, suffix)

def call_box68(f: TextBox68 -> String, box: TextBox68) -> String:
  f(box)

def main() -> String:
  +box = TextBox68{"keep"}
  String.append(append_boxes68(box, box), call_box68(append_boxes68(box), box))

#|keepkeepkeepkeep
