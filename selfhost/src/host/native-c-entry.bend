
# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:800
@unsafe
def p111_previous_main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p86_cli(List.tail(&1,String,args))
