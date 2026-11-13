import Base

# A stateful array cipher with multiply/xor rather than an addition fold.
# Every iteration reads the previous write after eight elements; large indices
# exercise the ordinary Array masking boundary before full-width addressing.
def cipher.step(+i: U32, +key: U32, pair: Array<U32> & U32) -> Array<U32> & U32:
  (a, old) = pair
  +next = U32.xor(U32.mul(old, 17), key)
  (a[i] <- next, U32.xor(next, U32.add(key, 23)))

def cipher.loop(n: Nat, +i: U32, +key: U32, a: Array<U32>) -> Array<U32> & U32:
  match n:
    case 0n: (a, key)
    case 1n+p:
      (a, key) = cipher.step(i, key, Array.get(U32, a, i))
      cipher.loop(p, U32.add(i, 3), key, a)

def cipher.finish(pair: Array<U32> & U32) -> U32:
  (a, key) = pair
  key

def main() -> IO(Unit):
  IO.print(U32.show(cipher.finish(cipher.loop(37n, 4294967289, 123, [17 : U32*8n]))))
#| 8318258
