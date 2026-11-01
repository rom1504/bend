"""Source/data-only law migration controls. No Bend, JS, C or Lean executes."""
import contextlib
import copy
import hashlib
import importlib.util
import io
import json
from pathlib import Path
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


class Migration(unittest.TestCase):
    def test_frozen_fixtures_match_migration_pins_without_history(self):
        document=json.loads((HERE/'fixtures-migration.json').read_text())
        for row in document['rows']:
            data=(ROOT/row['to']).read_bytes()
            with self.subTest(path=row['to']):
                self.assertEqual(len(data),row['bytes'])
                self.assertEqual(hashlib.sha256(data).hexdigest(),row['sha256'])

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
