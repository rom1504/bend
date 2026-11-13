"""Reuse transaction controls with Phase189 preserved-component/object contracts."""
import importlib.util
from pathlib import Path
import unittest

HERE = Path(__file__).resolve().parent

def load(name, path):
    spec=importlib.util.spec_from_file_location(name,path)
    module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    return module

P=load('p189_prepare',HERE/'prepare-release.py')
legacy=load('p183_prepare_tests',HERE.parent/'phase183/test_release_preparation.py')
legacy.P=P

class ReleasePreparation(legacy.ReleasePreparation):
    def preserved(self):
        current,previous,audit=super().preserved()
        for document in [current,previous['bindings']]:
            document['components']['x86']={'gates':['old-x86']}
        audit['components']['x86']={'gates':['old-x86']}
        current['gateStatus']['components']['x86']=['old-x86']
        return current,previous,audit

    def operational(self):
        original,current,n2=super().operational()
        current['components']['x86'].update(defaultEmission='object',qualificationVariant='direct-object-v1')
        original['assets']['x86-n2']=legacy.row('old-x86','7')
        original['images']['x86-n2']={'defaultEmission':'assembly'}
        return original,current,n2

    def test_operational_maps_preserve_old_capabilities_and_add_exact_assembly_binding(self):
        original,current,n2=self.operational()
        result=P.operational_map(original,current,n2,legacy.row('/promotion'))
        for key,value in original['assets'].items():
            if key!='x86-n2': self.assertEqual(result['assets'][key],value)
        self.assertEqual(result['images']['qbe-n2'],original['images']['qbe-n2'])
        self.assertEqual(result['images']['x86-n2']['defaultEmission'],'object')
        self.assertTrue(P.release.same(result['assets']['x86-n2'],current['components']['x86']['image']))
        self.assertEqual(result['providers'],original['providers'])

    def test_conflicting_runtime_or_toolchain_refused(self):
        for field in ['runtime','toolchain','linker']:
            original,current,n2=self.operational()
            if field=='runtime': original['runtimePolicies']['qbe-runtime']['runtimeABI']=11101
            elif field=='toolchain': n2['toolchain']['linkerFlags']=[]
            else: original['assets']['linker']['sha256']='f'*64
            with self.subTest(field=field),self.assertRaises(ValueError):
                P.operational_map(original,current,n2,legacy.row('/promotion'))

if __name__=='__main__': unittest.main()
