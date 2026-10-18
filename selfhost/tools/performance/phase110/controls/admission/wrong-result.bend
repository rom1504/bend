# Deliberately ill-typed source: never use its unchecked fact as an admission
# negative. The source checker itself must refuse before certificate generation.
import Base

def p110_cert_wrong_result(x: String) -> List<&2,String>:
  x

def main() -> IO(Unit):
  IO.print(Nat.show(List.length(&2, String, p110_cert_wrong_result("bad"))))
