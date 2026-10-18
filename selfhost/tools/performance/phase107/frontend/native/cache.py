"""Exact-text/tool/ABI object cache; no IR interpretation or code generation."""
import hashlib
import json
import os
import shutil
from pathlib import Path
from run import pin


def digest(value):
    return hashlib.sha256(value.encode()).hexdigest()


class ObjectCache:
    def __init__(self, directory, output, events):
        self.directory = Path(directory).resolve() if directory else None
        self.output, self.events = Path(output), events
        if self.directory:
            self.directory.mkdir(parents=True, exist_ok=True)

    def object(self, name, text, identity, build, assembly=False):
        key = digest(json.dumps(dict(text=text, identity=identity), sort_keys=True, separators=(',', ':')))
        stem = digest(name)
        obj, asm = self.output/(stem+'.o'), self.output/(stem+'.s')
        folder = self.directory/key if self.directory else None
        event = dict(name=name, key=key, hit=False)
        self.events.append(event)
        if folder and (folder/'record.json').exists():
            try:
                record = json.loads((folder/'record.json').read_text())
                if record['key'] != key:
                    raise ValueError('cache identity mismatch')
                expected = ['object.o', 'assembly.s'] if assembly else ['object.o']
                for filename in expected:
                    actual = pin(folder/filename)
                    if (actual['sha256'], actual['bytes']) != tuple(record[filename][k] for k in ['sha256', 'bytes']):
                        raise ValueError('cache artifact digest mismatch')
                shutil.copyfile(folder/'object.o', obj)
                if assembly:
                    shutil.copyfile(folder/'assembly.s', asm)
                event.update(hit=True, object=pin(obj))
                if assembly:
                    event['assembly'] = pin(asm)
                return obj
            except (ValueError, KeyError, OSError, TypeError):
                event['corrupt'] = True
        build(obj, asm)
        event['object'] = pin(obj)
        if assembly:
            event['assembly'] = pin(asm)
        if folder:
            folder.mkdir(parents=True, exist_ok=True)
            record = dict(key=key)
            artifacts = [('object.o', obj)] + ([('assembly.s', asm)] if assembly else [])
            for filename, source in artifacts:
                temporary = folder/(filename+'.'+str(os.getpid())+'.tmp')
                shutil.copyfile(source, temporary)
                os.replace(temporary, folder/filename)
                record[filename] = {k:pin(source)[k] for k in ['sha256', 'bytes']}
            temporary = folder/('record.'+str(os.getpid())+'.tmp')
            temporary.write_text(json.dumps(record, sort_keys=True))
            os.replace(temporary, folder/'record.json')
        return obj
