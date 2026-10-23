#!/usr/bin/env python3
import unittest

from timeline import markdown, windows


def evidence():
    header = {"samples": 5, "period_us": 10000, "dropped": 0, "overruns": 0}
    attribution = {"pairing": {"verified": True}, "quality": {"scope": "main_thread", "zero_loss": True,
        **{key: True for key in ("handler_intact", "main_thread_shutdown", "thread_lifecycle_complete",
                                "near_complete_process_cpu_coverage", "delivery_plausible")}},
        "contextHeader": {"context_available": True}, "ownerBinding": {}}
    events = [{"sample": index, "leaf": {"object": "/program", "symbol": symbol, "decoded": symbol},
               "dispatchContext": {"fid": 1 if owner else None, "loweredOwner": owner}}
              for index, (symbol, owner) in enumerate((('late', 'B'), ('early', 'A'), (None, None), ('early', 'A'), ('late', 'B')))]
    return header, attribution, events


class TimelineTests(unittest.TestCase):
    def test_order_windows_and_short_final_window(self):
        h, a, e = evidence()
        result = windows(e, h, a, window_samples=2)
        self.assertEqual([w["samples"] for w in result["windows"]], [2, 2, 1])
        self.assertEqual(result["windows"][0]["topPhysicalLeaves"][0]["symbol"], "late")
        self.assertEqual(result["windows"][2]["approximateCpuStartSeconds"], .04)
        self.assertEqual(result["windows"][2]["approximateCpuEndSeconds"], .05)
        self.assertFalse(result["clock"]["isWallTime"])

    def test_unknown_denominators_survive_top_truncation(self):
        h, a, e = evidence()
        row = windows(e, h, a, window_samples=5, top=1)["windows"][0]
        self.assertEqual(row["unknownPhysicalLeafSamples"], 1)
        self.assertEqual(row["unknownActiveOwnerSamples"], 1)
        self.assertEqual(row["topPhysicalLeaves"][0]["fractionOfWindow"], .4)
        self.assertEqual(row["topActiveOwners"][0]["fractionOfWindow"], .4)

    def test_loss_overruns_or_missing_identity_suppress_cpu_coordinates(self):
        for change in ("loss", "overrun", "identity", "coverage", "delivery", "scope"):
            h, a, e = evidence()
            if change == "loss": h["dropped"] = 1
            if change == "overrun": h["overruns"] = 1
            if change == "identity": a["pairing"]["verified"] = False
            if change == "coverage": a["quality"]["near_complete_process_cpu_coverage"] = False
            if change == "delivery": a["quality"]["delivery_plausible"] = False
            if change == "scope": a["quality"]["scope"] = "all_threads"
            result = windows(e, h, a, window_samples=2)
            with self.subTest(change=change):
                self.assertFalse(result["clock"]["available"])
                self.assertNotIn("approximateCpuStartSeconds", result["windows"][0])
                self.assertEqual(sum(w["samples"] for w in result["windows"]), 5)
                self.assertIn("CPU timeline unavailable", markdown(result))

    def test_reordered_duplicate_or_missing_events_are_rejected(self):
        h, a, e = evidence()
        for broken in ([e[1], e[0], *e[2:]], [e[0], e[0], *e[2:]], e[:-1]):
            with self.assertRaises(ValueError):
                windows(broken, h, a)

    def test_cpu_window_rounding_is_explicit(self):
        h, a, e = evidence()
        result = windows(e, h, a, window_cpu_seconds=.021)
        self.assertEqual(result["windowSamples"], 2)
        self.assertEqual(result["requestedWindowCpuSeconds"], .021)
        self.assertEqual(result["approximateWindowCpuSeconds"], .02)

    def test_optional_contexts_do_not_invent_owners(self):
        h, a, e = evidence()
        a["contextHeader"], a["ownerBinding"] = None, None
        for event in e: event.pop("dispatchContext")
        result = windows(e, h, a, window_samples=5)
        self.assertFalse(result["activeOwnerAvailable"])
        self.assertEqual(result["windows"][0]["topActiveOwners"], [])
        self.assertEqual(result["windows"][0]["unknownActiveOwnerSamples"], 5)

    def test_invalid_width_and_period_rejected(self):
        h, a, e = evidence()
        for kwargs in ({"window_samples": 0}, {"window_cpu_seconds": float('nan')}, {"top": 0}):
            with self.assertRaises(ValueError): windows(e, h, a, **kwargs)
        with self.assertRaises(ValueError): windows(e, {**h, "period_us": 0}, a)


if __name__ == "__main__":
    unittest.main()
