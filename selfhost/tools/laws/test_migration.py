"""Source/data-only law migration controls. No Bend, JS, C or Lean executes."""
import contextlib
import copy
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import re
import sys
import tempfile
import unittest
from unittest.mock import patch

import prepare
import bindings
import check
import finite

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
SPEC=importlib.util.spec_from_file_location('finite_prepare',HERE/'prepare-finite.py')
P=importlib.util.module_from_spec(SPEC);SPEC.loader.exec_module(P)


def identity(data):
    return dict(bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def law_statements(data):
    return {match.group(1):identity(match.group(0).encode()) for match in re.finditer(
        r'^law ([^:\n]+):\n(?:[ \t]+[^\n]*\n)+',data.decode(),re.M)}


def validate_source_update(original,update,data,receipt):
    """Admit explicit current proof bytes without relabelling original extraction."""
    def require(ok,message):
        if not ok:raise ValueError(message)
    require(update['path']==original['to'] and update['previous']==
            {k:original[k] for k in ('bytes','sha256')},'Original extraction identity changed')
    require(update['current']==identity(data),'Current proof differs from audited update')
    statements=law_statements(data)
    preserved=update['preservedLawStatements'];added=update['addedSupportLaws']
    require(preserved and set(statements)==set(preserved)|set(added)
            and not set(preserved)&set(added) and len(added)==len(set(added))
            and all(statements.get(name)==value for name,value in preserved.items()),
            'Original theorem statement changed or undeclared helper added')
    require(receipt.get('schema')=='bend-law-check-v1' and receipt.get('complete') is True
            and receipt.get('independentlyChecked') is True and receipt.get('inputsUnchanged') is True
            and receipt.get('sourceOnly') is False and receipt.get('preparedOnly') is False
            and not receipt.get('error') and not receipt.get('changedInputs')
            and receipt.get('wholeCompilerProved') is False and receipt.get('nativeOwnershipProved') is False,
            'Completed independent proof receipt required')
    require(receipt['elaborationProvider']['upstream']==update['upstream']
            and any(row['origin']['file'].endswith('/'+update['path'])
                    and all({k:row[part][k] for k in ('bytes','sha256')}==update['current']
                            for part in ('origin','snapshot')) for row in receipt['sourceClosure']),
            'Receipt does not bind this current source/provider')
    require(all(name in receipt['lawNames'] and receipt['lawBindings'].get(name)
                and not set(receipt['lawBindings'][name])&set(receipt['opaqueDefinitions'])
                for name in statements),'Every current law must be nonopaque and kernel-bound')
    for name,code,stdout in [('kernel',0,'ALL PROOFS CHECK\n'),
                            ('kernel-negative',1,'SOME PROOFS FAIL\nIn phase67_false:\nexpected: .left\nobserved: .right\n')]:
        row=receipt['rows'][name];process=row['process']
        require(process['exitCode']==code and not process['timedOut']
                and (code!=0 or process['complete'] is True)
                and row['stdout']==stdout and row['stderr']=='','Kernel/control result differs')


class Migration(unittest.TestCase):
    def test_frozen_fixtures_match_migration_pins_without_history(self):
        document=json.loads((HERE/'fixtures-migration.json').read_text())
        updates=document.get('sourceUpdates',{'kind':'compiler-law-source-updates','version':1,'rows':[]})
        self.assertEqual(updates['kind'],'compiler-law-source-updates');self.assertEqual(updates['version'],1)
        by_path={row['path']:row for row in updates['rows']}
        self.assertEqual(len(by_path),len(updates['rows']))
        self.assertFalse(set(by_path)-{row['to'] for row in document['rows']})
        for row in document['rows']:
            data=(ROOT/row['to']).read_bytes()
            with self.subTest(path=row['to']):
                if row['to'] in by_path:
                    update=by_path[row['to']];proof=update['proofReceipt']
                    receipt=(ROOT/proof['file']).read_bytes()
                    self.assertEqual(identity(receipt),{k:proof[k] for k in ('bytes','sha256')})
                    validate_source_update(row,update,data,json.loads(receipt))
                else:self.assertEqual(identity(data),{k:row[k] for k in ('bytes','sha256')})

    def test_proof_source_update_requires_original_statements_and_real_kernel_receipt(self):
        document=json.loads((HERE/'fixtures-migration.json').read_text())
        update=document['sourceUpdates']['rows'][0]
        original=next(row for row in document['rows'] if row['to']==update['path'])
        data=(ROOT/update['path']).read_bytes()
        receipt=json.loads((ROOT/update['proofReceipt']['file']).read_text())
        for change in ['original','current','statement','failed','source-only','wrong-source','wrong-upstream','opaque','negative']:
            edited=copy.deepcopy(update);proof=copy.deepcopy(receipt)
            if change=='original':edited['previous']['sha256']='0'*64
            elif change=='current':edited['current']['sha256']='0'*64
            elif change=='statement':edited['preservedLawStatements']['contains_singleton']['sha256']='0'*64
            elif change=='failed':proof['independentlyChecked']=False
            elif change=='source-only':proof['sourceOnly']=True
            elif change=='wrong-source':proof['sourceClosure']=[]
            elif change=='wrong-upstream':proof['elaborationProvider']['upstream']='0'*40
            elif change=='opaque':proof['opaqueDefinitions']+=proof['lawBindings']['contains_singleton']
            elif change=='negative':proof['rows']['kernel-negative']['process']['exitCode']=0
            with self.subTest(change=change),self.assertRaises(ValueError):
                validate_source_update(original,edited,data,proof)

    def test_case_inventory_and_supplements_are_separate(self):
        cases=P.make_cases()
        self.assertEqual(len(cases),226);self.assertEqual(len({r['family'] for r in cases}),16)
        self.assertEqual(len({r['id'] for r in cases}),226)
        extra=json.loads((P.FIXTURES/'supplements.json').read_text())
        self.assertEqual(len(extra),2)
        self.assertFalse({r['id'] for r in cases}&{r['id'] for r in extra})
        self.assertEqual(extra[0]['expectedWire'],3)

    def test_dependency_extraction_uses_actual_declared_bodies(self):
        source='# Unicode prefix λ and supplementary 𐐀\ndef first() -> U32:\n  second()\n\n# Unicode boundary Ω\ndef second() -> U32:\n  7\n\ndef unused() -> U32:\n  9\n'
        text,rows=P.extract({'source.bend':source},'first()')
        self.assertIn('  7\n',text);self.assertNotIn('unused',text)
        self.assertEqual([r['name'] for r in rows],['first','second'])
        for row in rows:self.assertEqual(hashlib.sha256(source.encode()[row['startByte']:row['endByte']]).hexdigest(),row['sha256'])

    def test_missing_helper_refuses_instead_of_loading_old_compiler(self):
        with self.assertRaises(AssertionError):prepare.unique({},'p98_term_scalar_finish')

    def test_current_observer_preserves_old_encoding_and_refuses_unknown_variant(self):
        source='type N_WordKind is Data:\n  N_W32{}\n  N_W64{}\n  N_Box{}\n  N_Imm64{}\n'
        text,inputs,binding=P.serializer_for(source,'word-kind-v2')
        frozen=(P.FIXTURES/'serialize.bend').read_text()
        self.assertEqual(text.replace('    case N_Imm64{}: "3"\n','',1),frozen)
        self.assertEqual(binding['profile'],'word-kind-v2')
        self.assertEqual(len(inputs),3)
        with self.assertRaises(ValueError):P.serializer_for(source+'  Unknown{}\n','word-kind-v2')
        self.assertEqual(P.serializer_for(source,'frozen')[0],frozen)

    def test_exact_source_binding_rejects_rewritten_body_and_contract(self):
        with tempfile.TemporaryDirectory(dir=ROOT/'selfhost/build') as directory:
            base=Path(directory);candidate=base/'compiler.bend';out=base/'package'
            table=prepare.declarations(prepare.BASE.read_text())
            candidate.write_text('import Base\n\n'+prepare.unique(table,'p88_string_eq_go')+
                'def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:\n  same\n\n'+
                'def p88_string_eq(+a: String, +b: String) -> Bool:\n  p98_eq_finish(p88_string_eq_go(a, b, True{}), a, b)\n')
            with patch.object(sys,'argv',['prepare','--candidate',str(candidate),'--kind','held-simple','--out',str(out)]),contextlib.redirect_stdout(io.StringIO()):prepare.main()
            manifest=out/'manifest.json';doc=json.loads(manifest.read_text());entry=doc['entry']
            binding=bindings.source_binding(manifest,entry)
            self.assertFalse(binding['wholeCompilerProved']);self.assertFalse(binding['nativeOwnershipProved'])
            generated=out/'candidate.bend';generated.write_text(generated.read_text().replace('  same\n','  False{}\n'))
            doc['outputs']=[bindings.pin(r['file']) for r in doc['outputs']];manifest.write_text(json.dumps(doc))
            with self.assertRaisesRegex(ValueError,'exact selected'):bindings.source_binding(manifest,entry)

    def test_unfilled_opaque_and_missing_laws_are_not_independent_checks(self):
        for text in ['opaque item : T := x','other : T := x']:
            with self.assertRaises(ValueError):check.bind_elaboration(text,['item'])
        self.assertEqual(check.bind_elaboration('item : T := x',['item'])[2],{'item':['item']})

    def test_elaboration_codec_requires_the_exact_source_provider(self):
        for digest, expected in check.ELABORATION_PROVIDERS.items():
            pins={'upstream-safe':{'sha256':digest},'upstream-bend':{'sha256':expected['bendSha256']},
                  'kernel-source':{'sha256':expected['kernelSha256']}}
            self.assertEqual(check.elaboration_provider(pins)['nameCodec'],expected['nameCodec'])
            with self.assertRaises(ValueError):check.elaboration_provider(pins,'0'*40)
            mixed=copy.deepcopy(pins);mixed['upstream-bend']['sha256']='0'*64
            with self.assertRaises(ValueError):check.elaboration_provider(mixed)
            mixed=copy.deepcopy(pins);mixed['kernel-source']['sha256']='0'*64
            with self.assertRaises(ValueError):check.elaboration_provider(mixed)
        with self.assertRaises(ValueError):
            check.elaboration_provider({'upstream-safe':{'sha256':'0'*64},'upstream-bend':{'sha256':'0'*64}})

    def test_canonical_codec_preserves_escaping_and_full_namespace(self):
        codec={'nameCodec':'bendtt-canonical-key-v2'}
        vectors={'held_walk_equal':'held__walk__equal','dir/file:law_name':'dir_2f_file_3a_law__name',
                 '9start':'_39_start','.start':'_2e_start','λ_𐐀':'_3bb____10400_',
                 'a:b':'a_3a_b','a_3a_b':'a__3a__b'}
        for source, expected in vectors.items():
            self.assertEqual(check.canonical_name_tt(source),expected)
        key={'law_name':'dir/file:law_name'}
        text='dir_2f_file_3a_law__name.q2_1 : T = x\n'
        self.assertEqual(check.bind_elaboration(text,['law_name'],codec,key)[2],
                         {'law_name':['dir_2f_file_3a_law__name.q2_1']})
        for wrong in ['law__name','other_3a_law__name','dir_2f_file_3a_law_name',
                      'dir_2f_file_3a_law__name_extra','dir_2f_file_3a_law__name.group']:
            with self.subTest(wrong=wrong),self.assertRaises(ValueError):
                check.bind_elaboration(wrong+' : T = x\n',['law_name'],codec,key)
        with self.assertRaises(ValueError):check.bind_elaboration('opaque '+text,['law_name'],codec,key)
        with self.assertRaises(ValueError):check.bind_elaboration(text,['law_name'],codec,{})

    def test_canonical_source_keys_use_paths_not_import_aliases(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);entry=root/'all.bend';child=root/'nested'/'laws.bend';child.parent.mkdir()
            entry.write_text('import ./nested/laws.bend as Misleading\nlaw root_law:\ndef root_law(): x\n')
            child.write_text('law child_law:\ndef child_law(): x\n')
            rows=[{'snapshot':{'file':str(p)}} for p in [entry,child]]
            self.assertEqual(check.law_source_keys(rows,entry),
                             {'root_law':'root_law','child_law':'nested/laws:child_law'})

    def test_historical_law_binding_keeps_its_original_codec(self):
        text='namespace.held_walk_equal.q2_1 : T = x\n'
        expected={'held_walk_equal':['namespace.held_walk_equal.q2_1']}
        self.assertEqual(check.bind_elaboration(text,['held_walk_equal'],{'nameCodec':'bendtt-name-key-v1'})[2],expected)
        with self.assertRaises(ValueError):
            check.bind_elaboration(text,['held_walk_equal'],{'nameCodec':'bendtt-canonical-key-v2'},
                                   {'held_walk_equal':'held_walk_equal'})

    def test_admission_failure_is_not_semantic_mutation_detection(self):
        passed=dict(complete=True,inputsUnchanged=True,compile=dict(status='ok'),passed=False,rows=[dict(id='w',passed=False,actual=[1],expected=[2])])
        finite.semantic_rejection(passed,'w')
        for change in ['admission','resource','no-value','same-value']:
            bad=copy.deepcopy(passed)
            if change=='admission':bad['compile']['status']='error'
            elif change=='resource':bad['complete']=False
            elif change=='no-value':del bad['rows'][0]['actual']
            else:bad['rows'][0]['actual']=[2]
            with self.subTest(change=change),self.assertRaises(ValueError):finite.semantic_rejection(bad,'w')


if __name__=='__main__':unittest.main()
