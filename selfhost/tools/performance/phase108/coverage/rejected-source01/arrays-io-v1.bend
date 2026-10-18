import Base

def render(pair: Array<String> & Array<String>) -> String:
  (original, copy) = pair
  (copy_read, before) = Array.get(String, copy, 1)
  changed = Array.set(String, copy_read, 1, "changed")
  (changed_read, after) = Array.get(String, changed, 1)
  (original_read, kept) = Array.get(String, original, 1)
  "arrays=" ++ before ++ "/" ++ after ++ "/" ++ kept

def main() -> IO(Unit):
  IO.print(render(Array.clone(String, Array.new(String, 2n, "seed"))))

#|arrays=seed/changed/seed
