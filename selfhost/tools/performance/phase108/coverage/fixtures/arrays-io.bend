import Base

def render_kept(before: String, after: String, pair: Array<String> & String) -> String:
  (original_read, kept) = pair
  "arrays=" ++ before ++ "/" ++ after ++ "/" ++ kept

def render_changed(original: Array<String>, before: String, pair: Array<String> & String) -> String:
  (changed_read, after) = pair
  render_kept(before, after, Array.get(String, original, 1))

def render_before(original: Array<String>, pair: Array<String> & String) -> String:
  (copy_read, before) = pair
  changed = Array.set(String, copy_read, 1, "changed")
  render_changed(original, before, Array.get(String, changed, 1))

def render(pair: Array<String> & Array<String>) -> String:
  (original, copy) = pair
  render_before(original, Array.get(String, copy, 1))

def main() -> IO(Unit):
  IO.print(render(Array.clone(String, Array.new(String, 2n, "seed"))))

#|arrays=seed/changed/seed
