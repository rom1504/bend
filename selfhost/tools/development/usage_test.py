import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('usage', Path(__file__).with_name('usage.py'))
usage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(usage)


class UsageTests(unittest.TestCase):
    def sample(self, hour, value, used=10, reset=100):
        tokens = dict(input_tokens=value * 10, cached_input_tokens=value * 8,
                      output_tokens=value, reasoning_output_tokens=value // 2,
                      total_tokens=value * 11)
        stamp = f'2026-10-11T{hour:02d}:00:00+00:00'
        return dict(schema=1, root='r', captured_at=stamp,
                    threads=[dict(id='r', agent='/root', tokens=tokens)],
                    reported_limits=dict(observed_at=stamp, value=dict(limit_id='codex',
                        primary=dict(used_percent=used, resets_at=reset, window_minutes=10080))))

    def test_subsets_not_double_counted(self):
        result = usage.compare(self.sample(2, 20, 12), self.sample(1, 10))
        self.assertEqual(result['tokens']['total_tokens'], 110)
        self.assertEqual(result['tokens']['output_tokens'], 10)
        self.assertEqual(result['output_tokens_per_hour'], 10)
        self.assertEqual(result['account_limit_changes']['primary']['per_hour'], 2)

    def test_quota_reset_and_token_reset_are_not_spending(self):
        result = usage.compare(self.sample(2, 5, 0, 200), self.sample(1, 10))
        self.assertEqual(result['account_limit_changes'], {})
        self.assertEqual(result['tokens']['total_tokens'], 0)
        self.assertTrue(result['warnings'])

    def test_new_child_and_missing_child(self):
        before, now = self.sample(1, 10), self.sample(2, 20)
        child = copy.deepcopy(now['threads'][0]); child['id'] = 'child'
        now['threads'].append(child)
        self.assertEqual(usage.compare(now, before)['tokens']['output_tokens'], 30)
        before['threads'].append(dict(child, id='missing'))
        self.assertTrue(any('incomplete' in x for x in usage.compare(now, before)['warnings']))

    def test_tail_ignores_partial_write_and_messages(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'rollout.jsonl'
            event = dict(type='event_msg', timestamp='now', payload=dict(
                type='token_count', info=dict(total_token_usage={'total_tokens': 7})))
            path.write_text(json.dumps(event) + '\n' +
                            json.dumps(dict(type='response_item', payload={'text': 'private'})) +
                            '\n{"partial":')
            stamp, payload = usage.last_usage(path)
            self.assertEqual(stamp, 'now')
            self.assertEqual(payload['info']['total_token_usage']['total_tokens'], 7)
            self.assertNotIn('private', json.dumps(payload))

    def test_limit_only_event_is_not_lost(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'rollout.jsonl'
            events = [dict(type='event_msg', timestamp='before', payload=dict(
                type='token_count', info=dict(total_token_usage={'total_tokens': 7}))),
                dict(type='event_msg', timestamp='after', payload=dict(
                    type='token_count', info=None, rate_limits={'limit_id': 'codex'}))]
            path.write_text('\n'.join(map(json.dumps, events)))
            stamp, payload = usage.last_usage(path)
            self.assertEqual(stamp, 'before')
            self.assertEqual(payload['_limits_observed_at'], 'after')


if __name__ == '__main__':
    unittest.main()
