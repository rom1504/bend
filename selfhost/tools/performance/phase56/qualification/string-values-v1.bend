import Base

type StringEqBox is Type:
  StringEqBox{run: String -> Bool}

def equal(a: String, b: String) -> Bool:
  String.eq(a, b)

def callbacks(f: U32 -> String, g: U32 -> String, +x: U32) -> Bool:
  String.eq(f(x), g(x))

def packed(f: U32 -> String, g: U32 -> U32, +x: U32) -> Bool & U32:
  (String.eq(f(x), ""), U32.add(g(x), 0))

def deferred(f: U32 -> String, x: U32) -> StringEqBox:
  StringEqBox{String.eq(f(x))}

def apply(box: StringEqBox, value: String) -> Bool:
  StringEqBox{run} = box
  run(value)
