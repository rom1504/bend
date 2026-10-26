"""Finite mode-specific oracle admission; no targets or cross-mode equivalence."""
from pathlib import Path


def verify_session_oracle(W,path,plan):
    read,require,pin,retain=W.read,W.require,W.pin,W.retain
    root=W.ROOT;here=Path(__file__).resolve().parent;retain(pin(__file__))
    mr=read(path);ad=plan['sourceAdmission']
    method=here/'session-mode-oracle-v02.mjs'
    require(pin(method)['sha256']=='15b33bc0abc45af66c4e1f166a7ecb04f4867aaa26749b52c2e48a7cb9de1355', 'Frozen mode method differs')
    require(mr['kind']=='phase144-hosted-session-mode-oracle' and mr['complete'] and mr['warmProductsExact']
        and mr['mode']=='phase140-cached-optimizer' and mr['crossModeByteIdentityClaimed'] is False
        and mr['compilerSource']==ad['source'] and mr['originalCheckedApi']==ad['checkedApi']
        and mr['originalApi']==ad['api'] and mr['runtime']==plan['runtime'] and pin(method) in mr['inputs'],
        'Complete selected-source independent session oracle required')
    original=W.bound(ad['checkedApi']);extended=W.bound(mr['oracleCheckedApi'])
    require(extended['complete'] and extended['checked'] and extended['status']==0 and extended['api']==mr['oracleApi']
        and extended['command'][:2]==original['command'][:2]
        and extended['command'][2:4]==[ad['source']['file'],extended['api']['file']]
        and extended['command'][4:]==extended['exports'], 'Same-source independently checked extra exports required')
    extra={'f_source_end','p140s_empty','p140s_named','p140g_prepare','p140r_begin_cursor','p140r_next'}
    require(set(extended['exports'])==set(original['exports'])|extra and len(extended['exports'])==len(set(extended['exports'])), 'Exact extra-export inventory differs')
    olddir=Path(ad['checkedApi']['file']).parent;newdir=Path(mr['oracleCheckedApi']['file']).parent
    require(len(extended['inputs'])==len(original['inputs']), 'Checker input count differs')
    for item in original['inputs']:
        f=Path(item['file']);expected=dict(item)
        if f.parent==olddir and f.name in {'method.py','stage0-library.mjs'}:expected['file']=str(newdir/f.name)
        require(expected in extended['inputs'],'Checker closure differs beyond exact two relocated snapshots')
    fixture_path=root/'selfhost/build/phase140/batch-smoke-plan01.json';fixture=read(fixture_path)
    require(mr['fixture']==pin(fixture_path) and mr['logicalPath']==fixture['logical']
        and mr['sources']==[pin(fixture['jobs'][i]['source']) for i in [0,1]], 'Frozen A/B source or logical path differs')
    require([j['name'] for j in fixture['jobs']]==['seed','edit','revert','edit-again'] and
        all(j['hint']==1784 and j['owner']=='prng' and j['mode']==('cold' if i==0 else 'warm')
            for i,j in enumerate(fixture['jobs'])), 'Frozen request owner/hint/mode differs')
    require([r['name'] for r in mr['rows']]==['cold-a','cold-b','seed','edit','revert','edit-again'], 'Six independent hosted observations required')
    require(mr['cold']==dict(a=mr['rows'][0]['product'],b=mr['rows'][1]['product']), 'Cold oracle identity differs')
    aa,bb=[W.Q.verify(mr['cold'][k]).read_bytes() for k in ['a','b']]
    require(aa and bb and aa!=bb,'Complete differing A/B cold products required')
    for i,row in enumerate(mr['rows']):
        require(row['verified'] and row['logicalPath']==fixture['logical'] and row['source']==mr['sources'][i%2]
            and W.Q.verify(row['product']).read_bytes()==(aa if i%2==0 else bb), 'Complete cold/warm hosted equality differs')
    ordinary_path=root/'selfhost/build/phase144/final04-ordinary-mode-equality01.json'
    require(pin(ordinary_path)['sha256']=='63d33ee628de983c6175de310f1be3764f9be648bf15d8930b55cb9b0345f174', 'Frozen ordinary comparison differs')
    ordinary=read(ordinary_path);build_path=Path(plan['paths']['n2'])/'report.json';built=read(build_path)
    require(ordinary['kind']=='phase144-ordinary-mode-hosted-native-equality' and ordinary['complete'] and ordinary['passed']
        and ordinary['compilerSource']==ad['source'] and ordinary['checkedApi']==ad['checkedApi'] and ordinary['api']==ad['api']
        and ordinary['image']==built['binary'] and ordinary['runtime']==plan['runtime'] and ordinary['imageReceipt']==pin(build_path)
        and [x['name'] for x in ordinary['rows']]==['lexer','coverage-map-churn-128','coverage-closures-256']
        and all(x['byteExact'] and x['outputExact'] for x in ordinary['rows']), 'Independent ordinary mode gates required separately')
    require(pin(here/'ordinary-mode-equality-v01.py')['sha256']=='95dbfa58b4a4559ee986cfefcd05db9f392be36fe7b9b60d40313679f4c81a31'
        and ordinary['full45']==pin(Path(plan['paths']['n2-full45'])/'report.json')
        and pin(here/'ordinary-mode-equality-v01.py') in ordinary['inputs'], 'Ordinary comparison method/full45 authority differs')
    failure_path=root/'selfhost/build/phase144/final04-host-smokes01/report.json';failure=read(failure_path)
    require(failure['complete'] is False and failure['image']==built['binary'] and failure['gates']['path']
        and failure['gates']['publish'] and not failure['gates']['batch'], 'Original cross-mode failure must remain intact')
    return dict(modeOracle=pin(path),ordinaryModeEquality=pin(ordinary_path),crossModeFailure=pin(failure_path),
        compilerSource=ad['source'],checkedApi=ad['checkedApi'],api=ad['api'],oracleCheckedApi=mr['oracleCheckedApi'],
        oracleApi=mr['oracleApi'],logicalPath=fixture['logical'],a=mr['cold']['a'],b=mr['cold']['b'],
        mode='phase140-cached-optimizer',crossModeByteIdentityClaimed=False)
