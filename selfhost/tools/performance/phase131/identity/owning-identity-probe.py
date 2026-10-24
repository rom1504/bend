"""Data-only exact-String owning-adapter ceiling; never production emission."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[5]
spec=importlib.util.spec_from_file_location('reader',Path(__file__).with_name('reader-identity-probe.py'))
reader=importlib.util.module_from_spec(spec);spec.loader.exec_module(reader)
pin=reader.pin
NAMES={'$direct.p88_string_eq','$direct.p88_string_eq_go'}

def adapters(path):
    result={}
    for symbol,name,body in reader.functions(path):
        if symbol.startswith('p113d_') and name in NAMES:
            assert name not in result;result[name]=body
    assert result.keys()==NAMES
    return result

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',type=Path,required=True);p.add_argument('--compiler',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    original=a.source.read_text();selected=adapters(a.source);native=adapters(a.compiler)
    assert selected==native,'Require exact final-N2 public adapter bodies'
    diagnostic=original;ceiling=original
    for name,body in selected.items():
        assert body.count('\n@p113_loop\n')==1
        assert body.count('call $p111_rt_sink(')==2 and body.count('call $p118_rt_borrow_scalar_safe(')==1
        assert 'l %v_v_4294967295)' in body and 'l %v_v_4294967294)' in body
        same=('  %p131_identity_equal =w ceql %v_v_4294967295, %v_v_4294967294\n')
        if name.endswith('_go'):
            same+=('  %p131_identity_pending =w ceql %v_v_4294967293, 1\n'
                   '  %p131_identity_hit =w and %p131_identity_equal, %p131_identity_pending\n')
        else:same+='  %p131_identity_hit =w copy %p131_identity_equal\n'
        counter=('  %p131_identity_calls_old =l loadl $p131_identity_calls\n'
                 '  %p131_identity_calls_new =l add %p131_identity_calls_old, 1\n'
                 '  storel %p131_identity_calls_new, $p131_identity_calls\n'+same+
                 '  %p131_identity_hit_long =l extuw %p131_identity_hit\n'
                 '  %p131_identity_hits_old =l loadl $p131_identity_hits\n'
                 '  %p131_identity_hits_new =l add %p131_identity_hits_old, %p131_identity_hit_long\n'
                 '  storel %p131_identity_hits_new, $p131_identity_hits\n')
        changed=body.replace('\n@p113_loop\n','\n@p113_loop\n'+counter)
        assert diagnostic.count(body)==1;diagnostic=diagnostic.replace(body,changed)
        shortcut=(same+'  jnz %p131_identity_hit, @p131_identity_return, @p131_identity_continue\n'
                  '@p131_identity_return\n'
                  '  %p131_identity_drop_first =l call $p111_rt_sink(l %state, l %v_v_4294967295)\n'
                  '  %p131_identity_drop_second =l call $p111_rt_sink(l %state, l %v_v_4294967294)\n'
                  '  ret 1\n@p131_identity_continue\n')
        changed=body.replace('\n@p113_loop\n','\n@p113_loop\n'+shortcut)
        assert ceiling.count(body)==1;ceiling=ceiling.replace(body,changed)
    main_body=[body for symbol,_,body in reader.functions(a.source) if symbol=='main']
    assert len(main_body)==1 and main_body[0].count('\nret %result\n')==1
    printer=('  %p131_identity_calls =l loadl $p131_identity_calls\n'
             '  %p131_identity_hits =l loadl $p131_identity_hits\n'
             '  %p131_identity_printed =w call $printf(l $p131_identity_format, ..., '
             'l %p131_identity_calls, l %p131_identity_calls, l %p131_identity_hits)\n')
    diagnostic=diagnostic.replace(main_body[0],main_body[0].replace('\nret %result\n','\n'+printer+'ret %result\n'))
    diagnostic+=('\ndata $p131_identity_calls = align 8 { l 0 }\n'
                 'data $p131_identity_hits = align 8 { l 0 }\n'
                 'data $p131_identity_format = { b "p131-identity %lu %lu %lu", b 10, b 0 }\n')
    out.mkdir();(out/'diagnostic.ssa').write_text(diagnostic);(out/'ceiling.ssa').write_text(ceiling)
    r=dict(complete=True,targetsRun=False,productionChange=False,independentVerifierAppliedToPatches=False,
        exactN2ReaderMatch=True,exactN2AdapterMatch=True,kind='owning-adapter-identity',
        inputs=[pin(Path(__file__)),pin(Path(__file__).with_name('reader-identity-probe.py')),pin(a.source),pin(a.compiler)],
        diagnostic=pin(out/'diagnostic.ssa'),ceiling=pin(out/'ceiling.ssa'),
        scope='Two exact public String adapters only. Identity-True path consumes both roots in original sink order; '
              'all other instructions/fallbacks unchanged. Diagnostic entries are counted as both calls and steps '
              'for existing output parser. Source theorem requires valid immutable typed Strings; corruption excluded. '
              'No independent IR verifier qualification, performance claim, or promotion.')
    (out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
    print(json.dumps(dict(complete=True,out=str(out))))

if __name__=='__main__':main()
