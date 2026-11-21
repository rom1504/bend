"""Optional one-pass fusion after a request with no successful repeat-hoist edits."""
from pathlib import Path
HERE=Path(__file__).resolve().parent

def apply(src):
    anchor='@unsafe\ndef p205_ready('
    assert src.count(anchor)==1 and 'def p205o_start(' not in src
    start=src.index(anchor);end=src.find('\n@unsafe\n',start+len(anchor))
    end=len(src) if end<0 else end
    body=src[start:end]
    old='u => P86PlanReady{nr_prepare_annotated(context,original),verdict},'
    assert body.count(old)==1,'No-edit branch changed; do not patch another fallback.'
    body=body.replace(old,'u => p205o_start(context,stops,verdict,original),')
    units='\n\n'.join((HERE/name).read_text() for name in ['helpers.bend','select.bend'])
    return src[:start]+units+'\n\n'+body+src[end:]

if __name__=='__main__':
    import argparse
    p=argparse.ArgumentParser();p.add_argument('source',type=Path);p.add_argument('out',type=Path);a=p.parse_args()
    a.out.write_text(apply(a.source.read_text()))
