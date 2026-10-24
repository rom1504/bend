# Exact qualified generated query extracts

Parent QBE SHA256 `2c25748d8a0eae711a7dd641d372bbce9f1fb4827dbe95e781b9f1cd11668aec`. All numbers below are lines in that immutable parent, not rewritten pseudocode.

## dn

Parent function starts at QBE line 43144; body SHA256 `8bd7e73cb83e4c9615d33bced8b2ab86acc368eb8a430745604e7c92fca0fffb`.

Parent QBE lines 43144–43188:

```text
43144: function l $p113d_FID_36_100_105_114_101_99_116_46_100_110_(l %state, l %v_v_4294967295) {
43145: @entry
43146: %v_scratch =l alloc8 2048
43147: jmp @p113_loop
43148: @p113_loop
43149: %v_p113p_move_2_0 =l copy %v_v_4294967295
43150: %v_v_4294967294 =l copy %v_p113p_move_2_0
43151: %v_tag =l shr %v_v_4294967294, 40
43152: %v_tag =l and %v_tag, 65535
43153: %v_match_condition =w ceql %v_tag, 153
43154: jnz %v_match_condition, @b_0, @b_1
43155: @b_0
43156: %v_ignored =l call $p111_rt_take(l %state, l %v_v_4294967294, l %v_scratch, w 9)
43157: %v_v_4294967292 =l loadl %v_scratch
43158: %t_3 =l add %v_scratch, 8
43159: %v_v_4294967291 =l loadl %t_3
43160: %t_4 =l add %v_scratch, 16
43161: %v_v_4294967290 =l loadl %t_4
43162: %t_5 =l add %v_scratch, 24
43163: %v_v_4294967289 =l loadl %t_5
43164: %t_6 =l add %v_scratch, 32
43165: %v_v_4294967288 =l loadl %t_6
43166: %t_7 =l add %v_scratch, 40
43167: %v_v_4294967287 =l loadl %t_7
43168: %t_8 =l add %v_scratch, 48
43169: %v_v_4294967286 =l loadl %t_8
43170: %t_9 =l add %v_scratch, 56
43171: %v_v_4294967285 =l loadl %t_9
43172: %t_10 =l add %v_scratch, 64
43173: %v_v_4294967284 =l loadl %t_10
43174: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_4294967291)
43175: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_4294967290)
43176: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_4294967289)
43177: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_4294967288)
43178: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_4294967287)
43179: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_4294967286)
43180: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_4294967285)
43181: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_4294967284)
43182: ret %v_v_4294967292
43183: @b_1
43184: %v_p113p_move_13_0 =l copy %v_v_4294967294
43185: %v_v_4294967283 =l copy %v_p113p_move_13_0
43186: %v_tag =l shr %v_v_4294967283, 40
43187: %v_tag =l and %v_tag, 65535
43188: %v_match_condition =w ceql %v_tag, 154
```
## f_eq

Parent function starts at QBE line 142659; body SHA256 `8f2b90e103e72d4ea53fa025536b2e1560f9a3bf0d997927b3deee1d69af92f4`.

Parent QBE lines 142659–142675:

```text
142659: function l $p113d_FID_36_100_105_114_101_99_116_46_102_95_101_113_(l %state, l %v_v_4294967295, l %v_v_4294967294) {
142660: @entry
142661: %v_scratch =l alloc8 2048
142662: jmp @p113_loop
142663: @p113_loop
142664: %v_p128bs_borrow =l call $p118_rt_borrow_scalar_safe(l %state, l %v_v_4294967295, l %v_v_4294967294, w 2)
142665: %v_p128bs_condition =w cnel %v_p128bs_borrow, 0
142666: jnz %v_p128bs_condition, @b_0, @b_1
142667: @b_0
142668: %v_p128bs_observation =l call $p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_102_95_101_113_(l %state, l %v_v_4294967295, l %v_v_4294967294)
142669: %v_p128bs_drop_0 =l call $p111_rt_sink(l %state, l %v_v_4294967295)
142670: %v_p128bs_drop_1 =l call $p111_rt_sink(l %state, l %v_v_4294967294)
142671: ret %v_p128bs_observation
142672: @b_1
142673: %v_p128bs_fallback =l call $p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_102_95_101_113_(l %state, l %v_v_4294967295, l %v_v_4294967294)
142674: ret %v_p128bs_fallback
142675: }
```
## f_find

Parent function starts at QBE line 229334; body SHA256 `5b861c29dbde8de2a7e05ba72c58e1059497091de581bb1992743530320811a6`.

Parent QBE lines 229334–229341:

```text
229334: function l $p113d_FID_36_100_105_114_101_99_116_46_102_95_102_105_110_100_(l %state, l %v_v_4294967295, l %v_v_4294967294) {
229335: @entry
229336: %v_scratch =l alloc8 2048
229337: jmp @p113_loop
229338: @p113_loop
229339: %v_p126scc_result =l call $p113d_FID_36_112_49_50_54_115_99_99_46_49_48_49_51_(l %state, l 1, l %v_v_4294967295, l %v_v_4294967294, l 0, l 0)
229340: ret %v_p126scc_result
229341: }
```
## lookup

Parent function starts at QBE line 277396; body SHA256 `e409c5e10712d912b16a61ff37cf1f56b9dc2e2c6ae2c0470bf278b3a58bfeec`.

Parent QBE lines 277428–277471:

```text
277428: %v_ignored =l call $p125_rt_take2(l %state, l %v_v_4294967288, l %v_scratch)
277429: %v_v_4294967284 =l loadl %v_scratch
277430: %t_6 =l add %v_scratch, 8
277431: %v_v_4294967283 =l loadl %t_6
277432: %v_v_4294967284 =l call $p111_rt_keep(l %state, l %v_v_4294967284)
277433: %v_p113p_move_80_0 =l copy %v_v_4294967284
277434: %v_v_4294967216 =l copy %v_p113p_move_80_0
277435: %v_p113i_1_local_v_4294967295 =l copy %v_v_4294967216
277436: %v_p113i_1_local_p113p_move_2_0 =l copy %v_p113i_1_local_v_4294967295
277437: %v_p113i_1_local_v_4294967294 =l copy %v_p113i_1_local_p113p_move_2_0
277438: %v_p113i_1_local_tag =l shr %v_p113i_1_local_v_4294967294, 40
277439: %v_p113i_1_local_tag =l and %v_p113i_1_local_tag, 65535
277440: %v_p113i_1_local_match_condition =w ceql %v_p113i_1_local_tag, 153
277441: jnz %v_p113i_1_local_match_condition, @b_7, @b_8
277442: @b_7
277443: %v_p113i_1_local_ignored =l call $p111_rt_take(l %state, l %v_p113i_1_local_v_4294967294, l %v_p113i_1_local_scratch, w 9)
277444: %v_p113i_1_local_v_4294967292 =l loadl %v_p113i_1_local_scratch
277445: %t_10 =l add %v_p113i_1_local_scratch, 8
277446: %v_p113i_1_local_v_4294967291 =l loadl %t_10
277447: %t_11 =l add %v_p113i_1_local_scratch, 16
277448: %v_p113i_1_local_v_4294967290 =l loadl %t_11
277449: %t_12 =l add %v_p113i_1_local_scratch, 24
277450: %v_p113i_1_local_v_4294967289 =l loadl %t_12
277451: %t_13 =l add %v_p113i_1_local_scratch, 32
277452: %v_p113i_1_local_v_4294967288 =l loadl %t_13
277453: %t_14 =l add %v_p113i_1_local_scratch, 40
277454: %v_p113i_1_local_v_4294967287 =l loadl %t_14
277455: %t_15 =l add %v_p113i_1_local_scratch, 48
277456: %v_p113i_1_local_v_4294967286 =l loadl %t_15
277457: %t_16 =l add %v_p113i_1_local_scratch, 56
277458: %v_p113i_1_local_v_4294967285 =l loadl %t_16
277459: %t_17 =l add %v_p113i_1_local_scratch, 64
277460: %v_p113i_1_local_v_4294967284 =l loadl %t_17
277461: %v_p113i_1_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_1_local_v_4294967292)
277462: %v_p113i_1_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_1_local_v_4294967290)
277463: %v_p113i_1_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_1_local_v_4294967289)
277464: %v_p113i_1_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_1_local_v_4294967288)
277465: %v_p113i_1_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_1_local_v_4294967287)
277466: %v_p113i_1_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_1_local_v_4294967286)
277467: %v_p113i_1_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_1_local_v_4294967285)
277468: %v_p113i_1_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_1_local_v_4294967284)
277469: %v_p113i_1_result_0 =l copy %v_p113i_1_local_v_4294967291
277470: %v_p113p_call_81_0 =l copy %v_p113i_1_result_0
277471: jmp @b_9
```

Parent QBE lines 277740–277791:

```text
277740: %v_value =l call $p111_rt_ctor(l %state, w 0, l %v_scratch, w 0)
277741: %v_p113p_move_96_0 =l copy %v_value
277742: %v_v_6726 =l copy %v_p113p_move_96_0
277743: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_6726)
277744: %v_v_4294967287 =l call $p111_rt_keep(l %state, l %v_v_4294967287)
277745: %v_v_4294967284 =l call $p111_rt_keep(l %state, l %v_v_4294967284)
277746: %v_p113p_move_164_0 =l copy %v_v_4294967284
277747: %v_v_4294967132 =l copy %v_p113p_move_164_0
277748: %v_p113i_4_local_v_4294967295 =l copy %v_v_4294967132
277749: %v_p113i_4_local_p113p_move_2_0 =l copy %v_p113i_4_local_v_4294967295
277750: %v_p113i_4_local_v_4294967294 =l copy %v_p113i_4_local_p113p_move_2_0
277751: %v_p113i_4_local_tag =l shr %v_p113i_4_local_v_4294967294, 40
277752: %v_p113i_4_local_tag =l and %v_p113i_4_local_tag, 65535
277753: %v_p113i_4_local_match_condition =w ceql %v_p113i_4_local_tag, 153
277754: jnz %v_p113i_4_local_match_condition, @b_64, @b_65
277755: @b_64
277756: %v_p113i_4_local_ignored =l call $p111_rt_take(l %state, l %v_p113i_4_local_v_4294967294, l %v_p113i_4_local_scratch, w 9)
277757: %v_p113i_4_local_v_4294967292 =l loadl %v_p113i_4_local_scratch
277758: %t_67 =l add %v_p113i_4_local_scratch, 8
277759: %v_p113i_4_local_v_4294967291 =l loadl %t_67
277760: %t_68 =l add %v_p113i_4_local_scratch, 16
277761: %v_p113i_4_local_v_4294967290 =l loadl %t_68
277762: %t_69 =l add %v_p113i_4_local_scratch, 24
277763: %v_p113i_4_local_v_4294967289 =l loadl %t_69
277764: %t_70 =l add %v_p113i_4_local_scratch, 32
277765: %v_p113i_4_local_v_4294967288 =l loadl %t_70
277766: %t_71 =l add %v_p113i_4_local_scratch, 40
277767: %v_p113i_4_local_v_4294967287 =l loadl %t_71
277768: %t_72 =l add %v_p113i_4_local_scratch, 48
277769: %v_p113i_4_local_v_4294967286 =l loadl %t_72
277770: %t_73 =l add %v_p113i_4_local_scratch, 56
277771: %v_p113i_4_local_v_4294967285 =l loadl %t_73
277772: %t_74 =l add %v_p113i_4_local_scratch, 64
277773: %v_p113i_4_local_v_4294967284 =l loadl %t_74
277774: %v_p113i_4_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_4_local_v_4294967291)
277775: %v_p113i_4_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_4_local_v_4294967290)
277776: %v_p113i_4_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_4_local_v_4294967289)
277777: %v_p113i_4_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_4_local_v_4294967288)
277778: %v_p113i_4_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_4_local_v_4294967287)
277779: %v_p113i_4_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_4_local_v_4294967286)
277780: %v_p113i_4_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_4_local_v_4294967285)
277781: %v_p113i_4_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_4_local_v_4294967284)
277782: %v_p113i_4_result_0 =l copy %v_p113i_4_local_v_4294967292
277783: %v_p113p_call_165_0 =l copy %v_p113i_4_result_0
277784: jmp @b_66
277785: @b_65
277786: %v_p113i_4_local_p113p_move_13_0 =l copy %v_p113i_4_local_v_4294967294
277787: %v_p113i_4_local_v_4294967283 =l copy %v_p113i_4_local_p113p_move_13_0
277788: %v_p113i_4_local_tag =l shr %v_p113i_4_local_v_4294967283, 40
277789: %v_p113i_4_local_tag =l and %v_p113i_4_local_tag, 65535
277790: %v_p113i_4_local_match_condition =w ceql %v_p113i_4_local_tag, 154
277791: jnz %v_p113i_4_local_match_condition, @b_75, @b_76
```

Parent QBE lines 277880–277906:

```text
277880: ret %v_v_4294967284
277881: @b_86
277882: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_4294967284)
277883: %v_p113p_move_174_0 =l copy %v_v_4294967125
277884: %v_v_4294967122 =l copy %v_p113p_move_174_0
277885: %v_p112_b_raw =w ceql %v_v_4294967122, 1
277886: %v_p112_b_bits =l shr %v_v_4294967122, 40
277887: %v_p112_b_bits =l and %v_p112_b_bits, 8388607
277888: %v_p112_b_expected =l or 2, 65536
277889: %v_p112_b_boxed =w ceql %v_p112_b_bits, %v_p112_b_expected
277890: %v_match_condition =w or %v_p112_b_raw, %v_p112_b_boxed
277891: %v_match_condition =w xor %v_match_condition, 1
277892: jnz %v_match_condition, @b_88, @b_89
277893: @b_88
277894: %v_value =l call $p111_rt_ctor(l %state, w 0, l %v_scratch, w 0)
277895: %v_p113p_move_175_0 =l copy %v_value
277896: %v_v_6728 =l copy %v_p113p_move_175_0
277897: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_6728)
277898: %v_p113p_move_178_0 =l copy %v_v_4294967283
277899: %v_v_4294967119 =l copy %v_p113p_move_178_0
277900: %v_p113p_move_179_0 =l copy %v_v_4294967287
277901: %v_v_4294967118 =l copy %v_p113p_move_179_0
277902: %p113_again_0 =l copy %v_v_4294967119
277903: %p113_again_1 =l copy %v_v_4294967118
277904: %v_v_4294967295 =l copy %p113_again_0
277905: %v_v_4294967294 =l copy %p113_again_1
277906: jmp @p113_loop
```
## nc_ctor_owned

Parent function starts at QBE line 336793; body SHA256 `c1e89e846e7053e46b2dab72cd4369a012c15553b4755df2a9acda9e10e452d2`.

Parent QBE lines 336823–336866:

```text
336823: %v_ignored =l call $p125_rt_take2(l %state, l %v_v_4294967289, l %v_scratch)
336824: %v_v_4294967285 =l loadl %v_scratch
336825: %t_6 =l add %v_scratch, 8
336826: %v_v_4294967284 =l loadl %t_6
336827: %v_v_4294967285 =l call $p111_rt_keep(l %state, l %v_v_4294967285)
336828: %v_p113p_move_79_0 =l copy %v_v_4294967285
336829: %v_v_4294967217 =l copy %v_p113p_move_79_0
336830: %v_p113i_0_local_v_4294967295 =l copy %v_v_4294967217
336831: %v_p113i_0_local_p113p_move_2_0 =l copy %v_p113i_0_local_v_4294967295
336832: %v_p113i_0_local_v_4294967294 =l copy %v_p113i_0_local_p113p_move_2_0
336833: %v_p113i_0_local_tag =l shr %v_p113i_0_local_v_4294967294, 40
336834: %v_p113i_0_local_tag =l and %v_p113i_0_local_tag, 65535
336835: %v_p113i_0_local_match_condition =w ceql %v_p113i_0_local_tag, 153
336836: jnz %v_p113i_0_local_match_condition, @b_7, @b_8
336837: @b_7
336838: %v_p113i_0_local_ignored =l call $p111_rt_take(l %state, l %v_p113i_0_local_v_4294967294, l %v_p113i_0_local_scratch, w 9)
336839: %v_p113i_0_local_v_4294967292 =l loadl %v_p113i_0_local_scratch
336840: %t_10 =l add %v_p113i_0_local_scratch, 8
336841: %v_p113i_0_local_v_4294967291 =l loadl %t_10
336842: %t_11 =l add %v_p113i_0_local_scratch, 16
336843: %v_p113i_0_local_v_4294967290 =l loadl %t_11
336844: %t_12 =l add %v_p113i_0_local_scratch, 24
336845: %v_p113i_0_local_v_4294967289 =l loadl %t_12
336846: %t_13 =l add %v_p113i_0_local_scratch, 32
336847: %v_p113i_0_local_v_4294967288 =l loadl %t_13
336848: %t_14 =l add %v_p113i_0_local_scratch, 40
336849: %v_p113i_0_local_v_4294967287 =l loadl %t_14
336850: %t_15 =l add %v_p113i_0_local_scratch, 48
336851: %v_p113i_0_local_v_4294967286 =l loadl %t_15
336852: %t_16 =l add %v_p113i_0_local_scratch, 56
336853: %v_p113i_0_local_v_4294967285 =l loadl %t_16
336854: %t_17 =l add %v_p113i_0_local_scratch, 64
336855: %v_p113i_0_local_v_4294967284 =l loadl %t_17
336856: %v_p113i_0_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_0_local_v_4294967292)
336857: %v_p113i_0_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_0_local_v_4294967290)
336858: %v_p113i_0_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_0_local_v_4294967289)
336859: %v_p113i_0_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_0_local_v_4294967288)
336860: %v_p113i_0_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_0_local_v_4294967287)
336861: %v_p113i_0_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_0_local_v_4294967286)
336862: %v_p113i_0_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_0_local_v_4294967285)
336863: %v_p113i_0_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_0_local_v_4294967284)
336864: %v_p113i_0_result_0 =l copy %v_p113i_0_local_v_4294967291
336865: %v_p113p_call_80_0 =l copy %v_p113i_0_result_0
336866: jmp @b_9
```

Parent QBE lines 336957–336975:

```text
336957: %v_p113p_move_87_0 =l copy %v_value
336958: %v_v_40707 =l copy %v_p113p_move_87_0
336959: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_40707)
336960: %v_v_4294967288 =l call $p111_rt_keep(l %state, l %v_v_4294967288)
336961: %v_v_4294967285 =l call $p111_rt_keep(l %state, l %v_v_4294967285)
336962: %v_p113p_move_158_0 =l copy %v_v_4294967285
336963: %v_v_4294967138 =l copy %v_p113p_move_158_0
336964: %v_p113i_2_local_v_4294967295 =l copy %v_v_4294967138
336965: %v_p113i_2_local_p113p_move_2_0 =l copy %v_p113i_2_local_v_4294967295
336966: %v_p113i_2_local_v_4294967294 =l copy %v_p113i_2_local_p113p_move_2_0
336967: %v_p113i_2_local_tag =l shr %v_p113i_2_local_v_4294967294, 40
336968: %v_p113i_2_local_tag =l and %v_p113i_2_local_tag, 65535
336969: %v_p113i_2_local_match_condition =w ceql %v_p113i_2_local_tag, 153
336970: jnz %v_p113i_2_local_match_condition, @b_31, @b_32
336971: @b_31
336972: %v_p113i_2_local_ignored =l call $p111_rt_take(l %state, l %v_p113i_2_local_v_4294967294, l %v_p113i_2_local_scratch, w 9)
336973: %v_p113i_2_local_v_4294967292 =l loadl %v_p113i_2_local_scratch
336974: %t_34 =l add %v_p113i_2_local_scratch, 8
336975: %v_p113i_2_local_v_4294967291 =l loadl %t_34
```

Parent QBE lines 337060–337078:

```text
337060: @b_33
337061: %v_p113p_move_160_0 =l copy %v_p113p_call_159_0
337062: %v_v_4294967140 =l copy %v_p113p_move_160_0
337063: %v_p113p_move_161_0 =l copy %v_v_4294967288
337064: %v_v_4294967139 =l copy %v_p113p_move_161_0
337065: %v_p113p_call_162_0 =l call $p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_(l %state, l %v_v_4294967140, l %v_v_4294967139)
337066: %v_p113p_move_163_0 =l copy %v_p113p_call_162_0
337067: %v_v_4294967141 =l copy %v_p113p_move_163_0
337068: %v_p113i_3_local_v_4294967295 =l copy %v_v_4294967141
337069: %v_p113i_3_local_p113p_move_2_0 =l copy %v_p113i_3_local_v_4294967295
337070: %v_p113i_3_local_v_4294967294 =l copy %v_p113i_3_local_p113p_move_2_0
337071: %v_p113i_3_local_tag =l shr %v_p113i_3_local_v_4294967294, 40
337072: %v_p113i_3_local_tag =l and %v_p113i_3_local_tag, 65535
337073: %v_p113i_3_local_match_condition =w ceql %v_p113i_3_local_tag, 153
337074: jnz %v_p113i_3_local_match_condition, @b_54, @b_55
337075: @b_54
337076: %v_p113i_3_local_ignored =l call $p111_rt_take(l %state, l %v_p113i_3_local_v_4294967294, l %v_p113i_3_local_scratch, w 9)
337077: %v_p113i_3_local_v_4294967292 =l loadl %v_p113i_3_local_scratch
337078: %t_57 =l add %v_p113i_3_local_scratch, 8
```

Parent QBE lines 337197–337213:

```text
337197: %v_p113p_move_171_0 =l copy %v_value
337198: %v_v_40708 =l copy %v_p113p_move_171_0
337199: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_40708)
337200: %v_p113p_move_173_0 =l copy %v_v_4294967285
337201: %v_v_4294967123 =l copy %v_p113p_move_173_0
337202: %v_p113i_5_local_v_4294967295 =l copy %v_v_4294967123
337203: %v_p113i_5_local_p113p_move_2_0 =l copy %v_p113i_5_local_v_4294967295
337204: %v_p113i_5_local_v_4294967294 =l copy %v_p113i_5_local_p113p_move_2_0
337205: %v_p113i_5_local_tag =l shr %v_p113i_5_local_v_4294967294, 40
337206: %v_p113i_5_local_tag =l and %v_p113i_5_local_tag, 65535
337207: %v_p113i_5_local_match_condition =w ceql %v_p113i_5_local_tag, 153
337208: jnz %v_p113i_5_local_match_condition, @b_78, @b_79
337209: @b_78
337210: %v_p113i_5_local_ignored =l call $p111_rt_take(l %state, l %v_p113i_5_local_v_4294967294, l %v_p113i_5_local_scratch, w 9)
337211: %v_p113i_5_local_v_4294967292 =l loadl %v_p113i_5_local_scratch
337212: %t_81 =l add %v_p113i_5_local_scratch, 8
337213: %v_p113i_5_local_v_4294967291 =l loadl %t_81
```

Parent QBE lines 337323–337344:

```text
337323: %v_p112_b_bits =l shr %v_v_4294967113, 40
337324: %v_p112_b_bits =l and %v_p112_b_bits, 8388607
337325: %v_p112_b_expected =l or 2, 65536
337326: %v_p112_b_boxed =w ceql %v_p112_b_bits, %v_p112_b_expected
337327: %v_match_condition =w or %v_p112_b_raw, %v_p112_b_boxed
337328: %v_match_condition =w xor %v_match_condition, 1
337329: jnz %v_match_condition, @b_102, @b_103
337330: @b_102
337331: %v_value =l call $p111_rt_ctor(l %state, w 0, l %v_scratch, w 0)
337332: %v_p113p_move_184_0 =l copy %v_value
337333: %v_v_40710 =l copy %v_p113p_move_184_0
337334: %v_ignored =l call $p111_rt_sink(l %state, l %v_v_40710)
337335: %v_p113p_move_187_0 =l copy %v_v_4294967284
337336: %v_v_4294967110 =l copy %v_p113p_move_187_0
337337: %v_p113p_move_188_0 =l copy %v_v_4294967288
337338: %v_v_4294967109 =l copy %v_p113p_move_188_0
337339: %p113_again_0 =l copy %v_v_4294967110
337340: %p113_again_1 =l copy %v_v_4294967109
337341: %v_v_4294967295 =l copy %p113_again_0
337342: %v_v_4294967294 =l copy %p113_again_1
337343: jmp @p113_loop
337344: @b_103
```
## f_find-scc

Parent function starts at QBE line 229166; body SHA256 `010ff794fd78030f40fad4b2ca05998c606ea0e10ec42629ee1c283cbe904f5d`.

Parent QBE lines 229188–229194:

```text
229188: @b_3
229189: %v_p113i_14_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_14_local_v_4294967295)
229190: %v_p113i_14_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_14_local_v_4294967293)
229191: ret %v_p113i_14_local_v_4294967294
229192: @b_4
229193: %v_p113i_14_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_14_local_v_4294967294)
229194: %v_p113i_14_local_p113p_move_7_0 =l copy %v_p113i_14_local_v_4294967291
```

Parent QBE lines 229284–229318:

```text
229284: jnz %v_p113i_15_local_match_condition, @b_20, @b_21
229285: @b_20
229286: %v_p113i_15_local_ignored =l call $p125_rt_take2(l %state, l %v_p113i_15_local_v_4294967267, l %v_p113i_15_local_scratch)
229287: %v_p113i_15_local_v_4294967265 =l loadl %v_p113i_15_local_scratch
229288: %t_23 =l add %v_p113i_15_local_scratch, 8
229289: %v_p113i_15_local_v_4294967264 =l loadl %t_23
229290: %v_p113i_15_local_v_4294967295 =l call $p111_rt_keep(l %state, l %v_p113i_15_local_v_4294967295)
229291: %v_p113i_15_local_p113p_move_36_0 =l copy %v_p113i_15_local_v_4294967295
229292: %v_p113i_15_local_v_4294967263 =l copy %v_p113i_15_local_p113p_move_36_0
229293: %v_p113i_15_local_v_4294967265 =l call $p111_rt_keep(l %state, l %v_p113i_15_local_v_4294967265)
229294: %v_p113i_15_local_p113p_move_37_0 =l copy %v_p113i_15_local_v_4294967265
229295: %v_p113i_15_local_v_4294967262 =l copy %v_p113i_15_local_p113p_move_37_0
229296: %v_p113i_15_local_p113p_move_38_0 =l copy %v_p113i_15_local_v_4294967264
229297: %v_p113i_15_local_v_4294967261 =l copy %v_p113i_15_local_p113p_move_38_0
229298: %v_p113i_15_local_p113p_move_41_0 =l copy %v_p113i_15_local_v_4294967295
229299: %v_p113i_15_local_v_4294967256 =l copy %v_p113i_15_local_p113p_move_41_0
229300: %v_p113i_15_local_p113p_move_43_0 =l copy %v_p113i_15_local_v_4294967265
229301: %v_p113i_15_local_v_4294967253 =l copy %v_p113i_15_local_p113p_move_43_0
229302: %v_p113i_15_local_p113p_call_44_0 =l call $p113d_FID_36_100_105_114_101_99_116_46_100_110_(l %state, l %v_p113i_15_local_v_4294967253)
229303: %v_p113i_15_local_p113p_move_45_0 =l copy %v_p113i_15_local_p113p_call_44_0
229304: %v_p113i_15_local_v_4294967255 =l copy %v_p113i_15_local_p113p_move_45_0
229305: %v_p113i_15_local_p113p_call_46_0 =l call $p113d_FID_36_100_105_114_101_99_116_46_102_95_101_113_(l %state, l %v_p113i_15_local_v_4294967256, l %v_p113i_15_local_v_4294967255)
229306: %v_p113i_15_local_p113p_move_47_0 =l copy %v_p113i_15_local_p113p_call_46_0
229307: %v_p113i_15_local_v_4294967260 =l copy %v_p113i_15_local_p113p_move_47_0
229308: %p113_again_0 =l copy 0
229309: %p113_again_1 =l copy %v_p113i_15_local_v_4294967263
229310: %p113_again_2 =l copy %v_p113i_15_local_v_4294967262
229311: %p113_again_3 =l copy %v_p113i_15_local_v_4294967261
229312: %p113_again_4 =l copy %v_p113i_15_local_v_4294967260
229313: %v_p126scc_tag =l copy %p113_again_0
229314: %v_p126scc_arg_0 =l copy %p113_again_1
229315: %v_p126scc_arg_1 =l copy %p113_again_2
229316: %v_p126scc_arg_2 =l copy %p113_again_3
229317: %v_p126scc_arg_3 =l copy %p113_again_4
229318: jmp @p113_loop
```
## Runtime 879–895

```c
879: INLINE void rfc_bump(Env e, Loc r, u32 k) {
880:   u32 c = a32_add(a32_at(e.mem, r), k);
881:   if ((c & RFC_CNT) >= RFC_CNT - k) {
882:     err_post(e.mem, ERR_RFCS);
883:   }
884: }
885: 
886: INLINE Term term_keep(Env e, Term t) {
887:   if (term_rfc(t)) {
888:     rfc_bump(e, term_loc(t), 1);
889:     return t;
890:   }
891:   if (term_triv(t)) {
892:     return t;
893:   }
894:   return rfc_wrap(e, t, 2);
895: }
```
## Runtime 1015–1053

```c
1015: INLINE void term_sink(Env e, Term t) {
1016:   if (!term_triv(t)) {
1017:     term_drop(e, t);
1018:   }
1019: }
1020: 
1021: OUTLINE void span_fade(Env e, Term t, Loc src, u32 n) {
1022:   for (u32 j = 0; j < n; j += 1) {
1023:     Term f = e.mem[src + j];
1024:     if (term_rfc(f)) {
1025:       rfc_bump(e, term_loc(f), 1);
1026:     } else if (!term_triv(f)) {
1027:       err_post(e.mem, ERR_RFCS);
1028:     }
1029:   }
1030:   term_drop(e, t);
1031: }
1032: 
1033: INLINE Loc ctr_take(Env e, Term t, u32 n, THR Term* out) {
1034:   Corpus H = e.mem;
1035:   if (!term_rfc(t)) {
1036:     for (u32 j = 0; j < n; j += 1) {
1037:       out[j] = H[term_loc(t) + j];
1038:     }
1039:     return term_loc(t);
1040:   }
1041:   Loc r    = term_loc(t);
1042:   u64 cell = rfc_view(e, r);
1043:   Loc src  = cell >> 24;
1044:   for (u32 j = 0; j < n; j += 1) {
1045:     out[j] = H[src + j];
1046:   }
1047:   if ((cell & RFC_CNT) == 1) {
1048:     heap_free(e, 0, r);
1049:     return src;
1050:   }
1051:   span_fade(e, t, src, n);
1052:   return 0;
1053: }
```
## Runtime 3890–3920

```c
3890: uint64_t p111_rt_sink(P111State *state, uint64_t term) { term_sink(state->e, term); return 0; }
3891: uint64_t p111_rt_tag(P111State *state, uint64_t term) { (void)state; return term_aux(term); }
3892: 
3893: uint64_t p111_rt_ctor(P111State *state, uint32_t cid, const uint64_t *fields, uint32_t count) {
3894:   p111_require(cid < p111_program_active->constructor_count && count == cid_arity(cid),
3895:     "phase111: constructor arity mismatch");
3896:   if (!count) return term_pak(cid, 0);
3897:   p111_require(fields != NULL, "phase111: missing constructor fields");
3898:   Env e = state->e;
3899:   Loc at = heap_alloc(e, cls_fit(count));
3900:   if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) {
3901:     for (u32 i = 0; i < count; ++i) e.mem[at + i] = fields[i];
3902:   } else {
3903:     for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, fields[i]);
3904:   }
3905:   return term_ctr(cid, at);
3906: }
3907: 
3908: uint64_t p111_rt_take(P111State *state, uint64_t term, uint64_t *out, uint32_t count) {
3909:   u32 cid = (u32)term_aux(term);
3910:   p111_require(cid < p111_program_active->constructor_count && count == cid_arity(cid),
3911:     "phase111: take arity mismatch");
3912:   if (!count) return 0;
3913:   p111_require(out != NULL, "phase111: missing take outputs");
3914:   if (count == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term);
3915:   else {
3916:     p111_require(term_tag(term) == TAG_CTR, "phase111: expected constructor owner");
3917:     spare_free(state->e, cls_fit(count), ctr_take(state->e, term, count, out));
3918:   }
3919:   return count;
3920: }
```
## Runtime 4624–4637

```c
4624: uint64_t p118_rt_borrow_fields(P111State *state, uint64_t term, uint64_t *out,
4625:                                uint32_t cid, uint32_t count) {
4626:   p111_require(cid < p111_program_active->constructor_count &&
4627:     term_aux(term) == cid && count == cid_arity(cid) && (!count || out),
4628:     "phase118: borrowed constructor mismatch");
4629:   if (!count) return 0;
4630:   if (count == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term);
4631:   else {
4632:     p111_require(term_tag(term) == TAG_CTR, "phase118: expected borrowed constructor");
4633:     Loc at = term_peek(state->e, term);
4634:     for (u32 i = 0; i < count; ++i) out[i] = state->e.mem[at + i];
4635:   }
4636:   return count;
4637: }
```
