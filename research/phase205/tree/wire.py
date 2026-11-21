"""Install the private-spine pass at the verified x86 catalog boundary in a staged compiler."""
from pathlib import Path
HERE=Path(__file__).resolve().parent

def apply(source):
    anchor='@unsafe\ndef p168_request_mode('
    assert source.count(anchor)==1 and 'def p205t_catalogued(' not in source
    invocation='v => p168_catalogued(nt_choose(U32,U32.is_eq(mode,1),'
    assert source.count(invocation)==1
    units='\n\n'.join((HERE/f).read_text() for f in ['match.bend','schema.bend','pass.bend'])
    return source.replace(anchor,units+'\n\n'+anchor).replace(invocation,'v => p205t_catalogued(bound,nt_choose(U32,U32.is_eq(mode,1),')

if __name__=='__main__':
    import argparse
    p=argparse.ArgumentParser();p.add_argument('source',type=Path);p.add_argument('out',type=Path)
    a=p.parse_args();a.out.write_text(apply(a.source.read_text()))
