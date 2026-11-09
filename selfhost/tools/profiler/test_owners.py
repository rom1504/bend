"""Synthetic owner-map tests; no compiler execution."""
import importlib.util
import copy
import json
from pathlib import Path
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location("bend_profiler_owners", Path(__file__).with_name("owners.py"))
O = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(O)


def symbol(name, prefix="p111"):
    return prefix + "_FID_" + "".join(str(ord(char)) + "_" for char in name)


def qbe(names, private=()):
    public = [symbol(name) for name in names]
    functions = public + [symbol(name, "p113d") for name in private]
    bodies = "".join(f"function l ${name}(l %state) {{\n@entry\nret 0\n}}\n" for name in functions)
    fields = ["l 11101", "l 192", "l " + str(len(public)), "l 0", "l 0"] + ["l 0"] * 7
    fields += ["l $p111_segments"] + ["l 0"] * 11
    return bodies + "data $p111_segments = align 8 { " + ", ".join("l $" + name for name in public) + " }\n" + \
        "export data $p111_program = align 8 { " + ", ".join(fields) + " }\n"


def assembly(names, private=(), abi=11102):
    public = [symbol(name) for name in names]
    functions = public+[symbol(name,'p113d') for name in private]
    bodies = ''.join('.text\n.type '+name+', @function\n'+name+':\nret\n.size '+name+', .-'+name+'\n' for name in functions)
    fields = [str(abi),'192',str(len(public)),'0','0']+['0']*7+['p111_segments+0']+['0']*11
    blocks = [('p111_segments',['.quad '+name+'+0' for name in public] or ['.byte 0']),
              ('p111_program',['.quad '+value for value in fields])]
    return bodies+''.join('.data\n.balign 8\n.type '+name+', @object\n'+name+':\n'+'\n'.join(rows)+'\n.size '+name+', .-'+name+'\n' for name,rows in blocks)


class Owners(unittest.TestCase):
    def parse(self, text):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "program.ssa"
            path.write_text(text)
            return O.parse_qbe_owners(path)

    def test_nested_lambdas_and_continuations_keep_lexical_owner(self):
        names = ["outer", "$p111.k.1", "$p111.k.3", "$direct.outer", "$p111.k.2", "next"]
        report = self.parse(qbe(names, ["$p111.k.3", "$direct.outer", "$product.outer"]))
        self.assertEqual([r["lowered_owner"] for r in report["fids"]], ["outer"] * 5 + ["next"])
        self.assertEqual(report["fids"][2]["fid"], 2)
        self.assertEqual(report["coverage"]["invalid_groups"], 0)
        private = {row["decoded"]: row for row in report["functions"] if row["symbol"].startswith("p113d")}
        self.assertEqual(private["$direct.outer"]["lowered_owner"], "outer")
        self.assertEqual(private["$p111.k.3"]["lowered_owner"], "outer")
        self.assertIsNone(private["$product.outer"]["lowered_owner"])
        self.assertFalse(report["producer_provenance_verified"])

    def test_mismatch_invalidates_whole_group_and_next_group_recovers(self):
        report = self.parse(qbe(["a", "$p111.k.1", "$direct.b", "$p111.k.2", "c", "$direct.c"]))
        self.assertEqual([r["lowered_owner"] for r in report["fids"]], [None] * 4 + ["c", "c"])
        self.assertEqual(report["coverage"]["invalid_groups"], 1)

    def test_unknown_generated_kind_and_orphan_fail_closed(self):
        report = self.parse(qbe(["$p111.k.0", "a", "$new.reordered", "$p111.k.1"]))
        self.assertTrue(all(row["lowered_owner"] is None for row in report["fids"]))

    def test_native_wrapper_is_distinct_lowered_identity(self):
        report = self.parse(qbe(["$native.Nat.add", "$p111.k.1", "$direct.$native.Nat.add"]))
        self.assertEqual([r["lowered_owner"] for r in report["fids"]], ["$native.Nat.add"] * 3)

    def test_bad_table_or_descriptor_rejected(self):
        for text in [qbe(["a"]).replace("l 11101", "l 11103"),
                     qbe(["a"]).replace("l $" + symbol("a") + " }", "l $absent }"),
                     qbe(["a"]).replace("l 192, l 1", "l 192, l 2"),
                     qbe(["a"]).replace("l $" + symbol("a") + " }", "l $" + symbol("a") + " + 8 }")]:
            with self.subTest(text=text), self.assertRaises(ValueError):
                self.parse(text)

    def test_table_order_not_function_or_numeric_name_order(self):
        text = qbe(["a", "$p111.k.50", "$p111.k.3", "$direct.a"])
        report = self.parse(text)
        self.assertEqual(report["fids"][1]["decoded"], "$p111.k.50")
        self.assertEqual(report["fids"][2]["decoded"], "$p111.k.3")

    def test_multiline_tables(self):
        report = self.parse(qbe(["a", "$direct.a"]).replace(", l $p111_FID_", ",\nl $p111_FID_"))
        self.assertEqual(report["coverage"]["owned_fids"], 2)

    def test_both_descriptor_versions_preserve_exact_abi(self):
        for abi in [11101,11102]:
            self.assertEqual(self.parse(qbe(['a']).replace('l 11101','l '+str(abi)))['descriptor']['magic'],abi)
            with tempfile.TemporaryDirectory() as directory:
                path=Path(directory)/'program.s';path.write_text(assembly(['a'],abi=abi))
                self.assertEqual(O.parse_assembly_owners(path)['descriptor']['magic'],abi)

    def test_assembly_uses_table_order_and_same_lexical_grouping(self):
        names=['outer','$p111.k.50','$p111.k.3','$direct.outer','next']
        private=['$direct.outer','$product.outer']
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/'program.s';path.write_text(assembly(names,private))
            report=O.parse_assembly_owners(path)
            reference=self.parse(qbe(names,private))
            self.assertEqual(report['fids'],reference['fids']);self.assertEqual(report['groups'],reference['groups'])
            self.assertEqual(report['schema'],'bend-native-lowered-owners-v1')
            self.assertEqual(report['sourceFormat'],'gnu-x86-64-assembly')
            self.assertEqual(O.source_identity(report),O.pin(path))
            self.assertTrue(all(row['assembly_line']>0 for row in report['functions']))
            self.assertFalse(report['producer_provenance_verified'])

    def test_assembly_rejects_nonliteral_ambiguous_and_incomplete_structure(self):
        good=assembly(['a'])
        for broken in [good.replace('.quad '+symbol('a')+'+0','.quad '+symbol('a')+'+8'),
                       good.replace('.quad '+symbol('a')+'+0','.quad absent+0'),
                       good.replace('.quad 11102','.quad 11103'),
                       good.replace('p111_program:\n','wrong_program:\n'),
                       good.replace('.size p111_program, .-p111_program\n',''),
                       good.replace('.quad 192','.zero 192'),good+good]:
            with tempfile.TemporaryDirectory() as directory,self.assertRaises(ValueError):
                path=Path(directory)/'program.s';path.write_text(broken);O.parse_assembly_owners(path)

    def test_completed_build_receipt_binds_actual_artifacts_and_rejects_mismatch(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);path=root/'program.s';path.write_text(assembly(['a']))
            for name in ['source.bend','producer','runtime.o','binary']:(root/name).write_bytes(b'synthetic '+name.encode())
            body=b'def a() -> U32:\n  1\n';(root/'source.bend').write_bytes(body);(root/'module.bend').write_bytes(body)
            report=dict(kind='bend-native-build',target='x86',complete=True,changedInputs=[],runtimeABI=11102,
                request={'target':'x86','source':O.pin(root/'source.bend'),'image':O.pin(root/'producer')},
                assembly=O.pin(path),assemblyDigest={k:O.pin(path)[k] for k in ['bytes','sha256']},
                runtime=O.pin(root/'runtime.o'),binary=O.pin(root/'binary'),
                jobs=[dict(label=label,complete=True,exitCode=0,timedOut=False,stdout=O.pin(path),stderr={'bytes':0})
                      for label in ['compiler','assemble','link']])
            receipt=root/'report.json';receipt.write_text(json.dumps(report))
            mapped=O.parse_assembly_owners(path,build_receipt=receipt)
            self.assertTrue(mapped['producer_provenance_verified'])
            self.assertEqual(mapped['buildProvenance']['source'],report['request']['source'])
            map_file=root/'map.json';map_file.write_text(json.dumps([dict(file='module.bend',kind='def',name='a',
                sourceLine=1,generatedLine=1,sourceStartByte=0,generatedStartByte=0,spanBytes=len(body),
                sourceByte=0,generatedByte=0,bytes=len(body))]))
            located=O.parse_assembly_owners(path,build_receipt=receipt,source_map=map_file,source_root=root)
            self.assertEqual(located['fids'][0]['sourceLocation']['file'],str(root/'module.bend'))
            with self.assertRaises(ValueError):O.parse_assembly_owners(path,source_map=map_file,source_root=root)
            for field,value in [('complete',False),('target','qbe'),('changedInputs',['source']),('runtimeABI',11101),
                                ('assemblyDigest',{'bytes':1,'sha256':'0'*64}),('jobs',[])]:
                bad=copy.deepcopy(report);bad[field]=value;receipt.write_text(json.dumps(bad))
                with self.subTest(field=field),self.assertRaises(ValueError):O.parse_assembly_owners(path,build_receipt=receipt)
            receipt.write_text(json.dumps(report));(root/'source.bend').write_bytes(b'changed')
            with self.assertRaisesRegex(ValueError,'changed'):O.parse_assembly_owners(path,build_receipt=receipt)

    def test_source_map_binds_actual_module_spans_and_names(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);module=root/'entry.bend';compiled=root/'compiler.bend';map_file=root/'map.json'
            body=b'def main() -> U32:\n  1\n';prefix=b'import Base\n'
            module.write_bytes(body);compiled.write_bytes(prefix+body)
            rows=[dict(file='entry.bend',kind='def',name='main',sourceLine=1,generatedLine=2,
                sourceStartByte=0,generatedStartByte=len(prefix),spanBytes=len(body),sourceByte=0,
                generatedByte=len(prefix),bytes=len(body))]
            map_file.write_text(json.dumps(rows))
            result=O.source_map_provenance(map_file,root,O.pin(compiled))
            self.assertEqual(result['modules'],[O.pin(module)])
            self.assertEqual(result['definitions']['main']['file'],str(module))
            for field,value in [('file','../outside'),('name','wrong'),('sourceLine',2),('spanBytes',len(body)-1),('generatedByte',0)]:
                bad=copy.deepcopy(rows);bad[0][field]=value;map_file.write_text(json.dumps(bad))
                with self.subTest(field=field),self.assertRaises(ValueError):O.source_map_provenance(map_file,root,O.pin(compiled))


if __name__ == "__main__":
    unittest.main()
