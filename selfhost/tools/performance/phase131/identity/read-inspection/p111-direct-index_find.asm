
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p130-native01-n1/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000dc7080 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_>:
  dc7080:	f3 0f 1e fa          	endbr64 
  dc7084:	55                   	push   %rbp
  dc7085:	48 89 e5             	mov    %rsp,%rbp
  dc7088:	48 81 ec 78 10 00 00 	sub    $0x1078,%rsp
  dc708f:	53                   	push   %rbx
  dc7090:	41 54                	push   %r12
  dc7092:	41 55                	push   %r13
  dc7094:	41 56                	push   %r14
  dc7096:	41 57                	push   %r15
  dc7098:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  dc709c:	4c 8b 6f 30          	mov    0x30(%rdi),%r13
  dc70a0:	4c 8b 67 38          	mov    0x38(%rdi),%r12
  dc70a4:	48 8b 5f 40          	mov    0x40(%rdi),%rbx
  dc70a8:	48 89 f0             	mov    %rsi,%rax
  dc70ab:	48 c1 e8 28          	shr    $0x28,%rax
  dc70af:	48 25 ff ff 00 00    	and    $0xffff,%rax
  dc70b5:	48 3d 99 00 00 00    	cmp    $0x99,%rax
  dc70bb:	0f 94 c1             	sete   %cl
  dc70be:	0f b6 c9             	movzbl %cl,%ecx
  dc70c1:	83 f9 00             	cmp    $0x0,%ecx
  dc70c4:	0f 85 bb 05 00 00    	jne    dc7685 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x605>
  dc70ca:	48 3d 9a 00 00 00    	cmp    $0x9a,%rax
  dc70d0:	0f 94 c1             	sete   %cl
  dc70d3:	0f b6 c9             	movzbl %cl,%ecx
  dc70d6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  dc70db:	4d 89 e6             	mov    %r12,%r14
  dc70de:	49 21 d6             	and    %rdx,%r14
  dc70e1:	4c 89 75 e8          	mov    %r14,-0x18(%rbp)
  dc70e5:	83 f9 00             	cmp    $0x0,%ecx
  dc70e8:	0f 85 2e 04 00 00    	jne    dc751c <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x49c>
  dc70ee:	48 3d 9b 00 00 00    	cmp    $0x9b,%rax
  dc70f4:	0f 84 8b 00 00 00    	je     dc7185 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x105>
  dc70fa:	2e 2e 2e 2e 48 89 9d 	cs cs cs mov %rbx,%cs:-0x1070(%rbp)
  dc7101:	90 ef ff ff 
  dc7105:	48 8b 47 10          	mov    0x10(%rdi),%rax
  dc7109:	48 89 18             	mov    %rbx,(%rax)
  dc710c:	48 c7 40 08 86 b9 00 	movq   $0xb986,0x8(%rax)
  dc7113:	00 
  dc7114:	48 83 c0 10          	add    $0x10,%rax
  dc7118:	48 89 47 10          	mov    %rax,0x10(%rdi)
  dc711c:	4c 89 a5 90 ef ff ff 	mov    %r12,-0x1070(%rbp)
  dc7123:	48 8b 47 10          	mov    0x10(%rdi),%rax
  dc7127:	4c 89 20             	mov    %r12,(%rax)
  dc712a:	48 c7 40 08 87 b9 00 	movq   $0xb987,0x8(%rax)
  dc7131:	00 
  dc7132:	48 83 c0 10          	add    $0x10,%rax
  dc7136:	48 89 47 10          	mov    %rax,0x10(%rdi)
  dc713a:	4c 89 ad 90 ef ff ff 	mov    %r13,-0x1070(%rbp)
  dc7141:	48 8b 47 10          	mov    0x10(%rdi),%rax
  dc7145:	4c 89 28             	mov    %r13,(%rax)
  dc7148:	48 c7 40 08 88 b9 00 	movq   $0xb988,0x8(%rax)
  dc714f:	00 
  dc7150:	48 83 c0 10          	add    $0x10,%rax
  dc7154:	48 89 47 10          	mov    %rax,0x10(%rdi)
  dc7158:	48 89 b5 90 ef ff ff 	mov    %rsi,-0x1070(%rbp)
  dc715f:	48 8b 47 10          	mov    0x10(%rdi),%rax
  dc7163:	48 89 30             	mov    %rsi,(%rax)
  dc7166:	48 c7 40 08 89 b9 00 	movq   $0xb989,0x8(%rax)
  dc716d:	00 
  dc716e:	48 83 c0 10          	add    $0x10,%rax
  dc7172:	48 89 47 10          	mov    %rax,0x10(%rdi)
  dc7176:	be 04 00 00 00       	mov    $0x4,%esi
  dc717b:	e8 50 08 02 00       	callq  de79d0 <p111_rt_fail>
  dc7180:	e9 4e 06 00 00       	jmpq   dc77d3 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  dc7185:	2e 2e 2e 2e 48 8d 95 	cs cs cs lea %cs:-0x1070(%rbp),%rdx
  dc718c:	90 ef ff ff 
  dc7190:	49 89 fe             	mov    %rdi,%r14
  dc7193:	e8 28 5d 02 00       	callq  decec0 <p125_rt_take4>
  dc7198:	4c 89 f7             	mov    %r14,%rdi
  dc719b:	48 8b b5 90 ef ff ff 	mov    -0x1070(%rbp),%rsi
  dc71a2:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  dc71a6:	48 8b b5 98 ef ff ff 	mov    -0x1068(%rbp),%rsi
  dc71ad:	4c 8b bd a0 ef ff ff 	mov    -0x1060(%rbp),%r15
  dc71b4:	4c 89 7d e0          	mov    %r15,-0x20(%rbp)
  dc71b8:	4d 89 ee             	mov    %r13,%r14
  dc71bb:	4c 8b ad a8 ef ff ff 	mov    -0x1058(%rbp),%r13
  dc71c2:	49 89 ff             	mov    %rdi,%r15
  dc71c5:	e8 e6 ff 01 00       	callq  de71b0 <p111_rt_keep>
  dc71ca:	4c 89 ff             	mov    %r15,%rdi
  dc71cd:	4c 8b 7d e0          	mov    -0x20(%rbp),%r15
  dc71d1:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  dc71d5:	48 89 c1             	mov    %rax,%rcx
  dc71d8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  dc71dc:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
  dc71e0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  dc71e5:	48 21 d1             	and    %rdx,%rcx
  dc71e8:	48 89 4d f0          	mov    %rcx,-0x10(%rbp)
  dc71ec:	48 83 f9 00          	cmp    $0x0,%rcx
  dc71f0:	0f 94 c2             	sete   %dl
  dc71f3:	0f b6 d2             	movzbl %dl,%edx
  dc71f6:	89 55 f8             	mov    %edx,-0x8(%rbp)
  dc71f9:	48 83 fa 01          	cmp    $0x1,%rdx
  dc71fd:	0f 94 c1             	sete   %cl
  dc7200:	0f b6 c9             	movzbl %cl,%ecx
  dc7203:	48 c1 ea 28          	shr    $0x28,%rdx
  dc7207:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  dc720e:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  dc7215:	0f 94 c2             	sete   %dl
  dc7218:	0f b6 d2             	movzbl %dl,%edx
  dc721b:	09 ca                	or     %ecx,%edx
  dc721d:	89 55 fc             	mov    %edx,-0x4(%rbp)
  dc7220:	0f 85 3f 02 00 00    	jne    dc7465 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x3e5>
  dc7226:	49 89 ff             	mov    %rdi,%r15
  dc7229:	e8 12 00 02 00       	callq  de7240 <p111_rt_sink>
  dc722e:	4c 89 ff             	mov    %r15,%rdi
  dc7231:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  dc7235:	4c 8b 7d e0          	mov    -0x20(%rbp),%r15
  dc7239:	8b 4d f8             	mov    -0x8(%rbp),%ecx
  dc723c:	8b 55 fc             	mov    -0x4(%rbp),%edx
  dc723f:	83 f2 01             	xor    $0x1,%edx
  dc7242:	75 6d                	jne    dc72b1 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x231>
  dc7244:	49 89 c4             	mov    %rax,%r12
  dc7247:	89 cb                	mov    %ecx,%ebx
  dc7249:	4c 89 f6             	mov    %r14,%rsi
  dc724c:	49 89 fe             	mov    %rdi,%r14
  dc724f:	e8 ec ff 01 00       	callq  de7240 <p111_rt_sink>
  dc7254:	4c 89 f7             	mov    %r14,%rdi
  dc7257:	4c 89 e0             	mov    %r12,%rax
  dc725a:	48 89 c6             	mov    %rax,%rsi
  dc725d:	49 89 fc             	mov    %rdi,%r12
  dc7260:	e8 db ff 01 00       	callq  de7240 <p111_rt_sink>
  dc7265:	4c 89 e7             	mov    %r12,%rdi
  dc7268:	4c 89 fe             	mov    %r15,%rsi
  dc726b:	49 89 fc             	mov    %rdi,%r12
  dc726e:	e8 cd ff 01 00       	callq  de7240 <p111_rt_sink>
  dc7273:	4c 89 e7             	mov    %r12,%rdi
  dc7276:	4c 89 ee             	mov    %r13,%rsi
  dc7279:	49 89 fc             	mov    %rdi,%r12
  dc727c:	e8 bf ff 01 00       	callq  de7240 <p111_rt_sink>
  dc7281:	4c 89 e7             	mov    %r12,%rdi
  dc7284:	48 89 9d 90 ef ff ff 	mov    %rbx,-0x1070(%rbp)
  dc728b:	48 8b 47 10          	mov    0x10(%rdi),%rax
  dc728f:	48 89 18             	mov    %rbx,(%rax)
  dc7292:	48 c7 40 08 85 b9 00 	movq   $0xb985,0x8(%rax)
  dc7299:	00 
  dc729a:	48 83 c0 10          	add    $0x10,%rax
  dc729e:	48 89 47 10          	mov    %rax,0x10(%rdi)
  dc72a2:	be 04 00 00 00       	mov    $0x4,%esi
  dc72a7:	e8 24 07 02 00       	callq  de79d0 <p111_rt_fail>
  dc72ac:	e9 22 05 00 00       	jmpq   dc77d3 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  dc72b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  dc72b6:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc72bd:	be 00 00 00 00       	mov    $0x0,%esi
  dc72c2:	49 89 ff             	mov    %rdi,%r15
  dc72c5:	e8 e6 ff 01 00       	callq  de72b0 <p111_rt_ctor>
  dc72ca:	4c 89 ff             	mov    %r15,%rdi
  dc72cd:	48 89 c6             	mov    %rax,%rsi
  dc72d0:	49 89 ff             	mov    %rdi,%r15
  dc72d3:	e8 68 ff 01 00       	callq  de7240 <p111_rt_sink>
  dc72d8:	4c 89 ff             	mov    %r15,%rdi
  dc72db:	4c 8b 7d e0          	mov    -0x20(%rbp),%r15
  dc72df:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  dc72e3:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  dc72e7:	48 21 c8             	and    %rcx,%rax
  dc72ea:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  dc72ef:	48 21 c8             	and    %rcx,%rax
  dc72f2:	48 83 f8 00          	cmp    $0x0,%rax
  dc72f6:	0f 94 c1             	sete   %cl
  dc72f9:	0f b6 c9             	movzbl %cl,%ecx
  dc72fc:	89 4d d8             	mov    %ecx,-0x28(%rbp)
  dc72ff:	48 83 f9 01          	cmp    $0x1,%rcx
  dc7303:	0f 94 c0             	sete   %al
  dc7306:	0f b6 c0             	movzbl %al,%eax
  dc7309:	48 c1 e9 28          	shr    $0x28,%rcx
  dc730d:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  dc7314:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  dc731b:	0f 94 c1             	sete   %cl
  dc731e:	0f b6 c9             	movzbl %cl,%ecx
  dc7321:	09 c8                	or     %ecx,%eax
  dc7323:	89 45 dc             	mov    %eax,-0x24(%rbp)
  dc7326:	0f 85 c7 00 00 00    	jne    dc73f3 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x373>
  dc732c:	4c 89 fe             	mov    %r15,%rsi
  dc732f:	49 89 ff             	mov    %rdi,%r15
  dc7332:	e8 09 ff 01 00       	callq  de7240 <p111_rt_sink>
  dc7337:	4c 89 ff             	mov    %r15,%rdi
  dc733a:	44 8b 7d d8          	mov    -0x28(%rbp),%r15d
  dc733e:	8b 45 dc             	mov    -0x24(%rbp),%eax
  dc7341:	83 f0 01             	xor    $0x1,%eax
  dc7344:	75 4c                	jne    dc7392 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x312>
  dc7346:	44 89 fb             	mov    %r15d,%ebx
  dc7349:	4c 89 f6             	mov    %r14,%rsi
  dc734c:	49 89 fc             	mov    %rdi,%r12
  dc734f:	e8 ec fe 01 00       	callq  de7240 <p111_rt_sink>
  dc7354:	4c 89 e7             	mov    %r12,%rdi
  dc7357:	4c 89 ee             	mov    %r13,%rsi
  dc735a:	49 89 fc             	mov    %rdi,%r12
  dc735d:	e8 de fe 01 00       	callq  de7240 <p111_rt_sink>
  dc7362:	4c 89 e7             	mov    %r12,%rdi
  dc7365:	48 89 9d 90 ef ff ff 	mov    %rbx,-0x1070(%rbp)
  dc736c:	48 8b 47 10          	mov    0x10(%rdi),%rax
  dc7370:	48 89 18             	mov    %rbx,(%rax)
  dc7373:	48 c7 40 08 84 b9 00 	movq   $0xb984,0x8(%rax)
  dc737a:	00 
  dc737b:	48 83 c0 10          	add    $0x10,%rax
  dc737f:	48 89 47 10          	mov    %rax,0x10(%rdi)
  dc7383:	be 04 00 00 00       	mov    $0x4,%esi
  dc7388:	e8 43 06 02 00       	callq  de79d0 <p111_rt_fail>
  dc738d:	e9 41 04 00 00       	jmpq   dc77d3 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  dc7392:	b9 00 00 00 00       	mov    $0x0,%ecx
  dc7397:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc739e:	be 00 00 00 00       	mov    $0x0,%esi
  dc73a3:	49 89 ff             	mov    %rdi,%r15
  dc73a6:	e8 05 ff 01 00       	callq  de72b0 <p111_rt_ctor>
  dc73ab:	4c 89 ff             	mov    %r15,%rdi
  dc73ae:	48 89 c6             	mov    %rax,%rsi
  dc73b1:	49 89 ff             	mov    %rdi,%r15
  dc73b4:	e8 87 fe 01 00       	callq  de7240 <p111_rt_sink>
  dc73b9:	4c 89 ff             	mov    %r15,%rdi
  dc73bc:	4c 89 ad 90 ef ff ff 	mov    %r13,-0x1070(%rbp)
  dc73c3:	4c 89 b5 98 ef ff ff 	mov    %r14,-0x1068(%rbp)
  dc73ca:	4c 89 a5 a0 ef ff ff 	mov    %r12,-0x1060(%rbp)
  dc73d1:	48 89 9d a8 ef ff ff 	mov    %rbx,-0x1058(%rbp)
  dc73d8:	b9 04 00 00 00       	mov    $0x4,%ecx
  dc73dd:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc73e4:	be 81 b9 00 00       	mov    $0xb981,%esi
  dc73e9:	e8 12 04 02 00       	callq  de7800 <p111_rt_jump>
  dc73ee:	e9 e0 03 00 00       	jmpq   dc77d3 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  dc73f3:	2e 2e 2e 4c 89 ee    	cs cs cs mov %r13,%rsi
  dc73f9:	49 89 fd             	mov    %rdi,%r13
  dc73fc:	e8 3f fe 01 00       	callq  de7240 <p111_rt_sink>
  dc7401:	4c 89 ef             	mov    %r13,%rdi
  dc7404:	b9 00 00 00 00       	mov    $0x0,%ecx
  dc7409:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc7410:	be 00 00 00 00       	mov    $0x0,%esi
  dc7415:	49 89 fd             	mov    %rdi,%r13
  dc7418:	e8 93 fe 01 00       	callq  de72b0 <p111_rt_ctor>
  dc741d:	4c 89 ef             	mov    %r13,%rdi
  dc7420:	48 89 c6             	mov    %rax,%rsi
  dc7423:	49 89 fd             	mov    %rdi,%r13
  dc7426:	e8 15 fe 01 00       	callq  de7240 <p111_rt_sink>
  dc742b:	4c 89 ef             	mov    %r13,%rdi
  dc742e:	4c 89 bd 90 ef ff ff 	mov    %r15,-0x1070(%rbp)
  dc7435:	4c 89 b5 98 ef ff ff 	mov    %r14,-0x1068(%rbp)
  dc743c:	4c 89 a5 a0 ef ff ff 	mov    %r12,-0x1060(%rbp)
  dc7443:	48 89 9d a8 ef ff ff 	mov    %rbx,-0x1058(%rbp)
  dc744a:	b9 04 00 00 00       	mov    $0x4,%ecx
  dc744f:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc7456:	be 81 b9 00 00       	mov    $0xb981,%esi
  dc745b:	e8 a0 03 02 00       	callq  de7800 <p111_rt_jump>
  dc7460:	e9 6e 03 00 00       	jmpq   dc77d3 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  dc7465:	49 89 c4             	mov    %rax,%r12
  dc7468:	b9 00 00 00 00       	mov    $0x0,%ecx
  dc746d:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc7474:	be 00 00 00 00       	mov    $0x0,%esi
  dc7479:	48 89 fb             	mov    %rdi,%rbx
  dc747c:	e8 2f fe 01 00       	callq  de72b0 <p111_rt_ctor>
  dc7481:	48 89 df             	mov    %rbx,%rdi
  dc7484:	48 89 c6             	mov    %rax,%rsi
  dc7487:	48 89 fb             	mov    %rdi,%rbx
  dc748a:	e8 b1 fd 01 00       	callq  de7240 <p111_rt_sink>
  dc748f:	48 89 df             	mov    %rbx,%rdi
  dc7492:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  dc7496:	48 89 fb             	mov    %rdi,%rbx
  dc7499:	e8 12 fd 01 00       	callq  de71b0 <p111_rt_keep>
  dc749e:	48 89 df             	mov    %rbx,%rdi
  dc74a1:	48 89 c3             	mov    %rax,%rbx
  dc74a4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  dc74a8:	48 89 9d 90 ef ff ff 	mov    %rbx,-0x1070(%rbp)
  dc74af:	48 89 85 98 ef ff ff 	mov    %rax,-0x1068(%rbp)
  dc74b6:	4c 89 bd a0 ef ff ff 	mov    %r15,-0x1060(%rbp)
  dc74bd:	4c 89 ad a8 ef ff ff 	mov    %r13,-0x1058(%rbp)
  dc74c4:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc74cb:	be 9b 00 00 00       	mov    $0x9b,%esi
  dc74d0:	49 89 fd             	mov    %rdi,%r13
  dc74d3:	e8 18 59 02 00       	callq  decdf0 <p125_rt_ctor4>
  dc74d8:	4c 89 ef             	mov    %r13,%rdi
  dc74db:	48 89 85 90 ef ff ff 	mov    %rax,-0x1070(%rbp)
  dc74e2:	4c 89 b5 98 ef ff ff 	mov    %r14,-0x1068(%rbp)
  dc74e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  dc74ee:	48 21 d8             	and    %rbx,%rax
  dc74f1:	4c 39 e0             	cmp    %r12,%rax
  dc74f4:	0f 94 c0             	sete   %al
  dc74f7:	0f b6 c0             	movzbl %al,%eax
  dc74fa:	48 89 85 a0 ef ff ff 	mov    %rax,-0x1060(%rbp)
  dc7501:	b9 03 00 00 00       	mov    $0x3,%ecx
  dc7506:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc750d:	be 64 b9 00 00       	mov    $0xb964,%esi
  dc7512:	e8 e9 02 02 00       	callq  de7800 <p111_rt_jump>
  dc7517:	e9 b7 02 00 00       	jmpq   dc77d3 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  dc751c:	4d 89 f4             	mov    %r14,%r12
  dc751f:	4d 89 ee             	mov    %r13,%r14
  dc7522:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc7529:	48 89 fb             	mov    %rdi,%rbx
  dc752c:	e8 bf 54 02 00       	callq  dec9f0 <p125_rt_take2>
  dc7531:	48 89 df             	mov    %rbx,%rdi
  dc7534:	48 8b 85 90 ef ff ff 	mov    -0x1070(%rbp),%rax
  dc753b:	48 8b 9d 98 ef ff ff 	mov    -0x1068(%rbp),%rbx
  dc7542:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  dc7547:	48 21 c8             	and    %rcx,%rax
  dc754a:	4c 39 e0             	cmp    %r12,%rax
  dc754d:	49 89 dd             	mov    %rbx,%r13
  dc7550:	0f 94 c3             	sete   %bl
  dc7553:	0f b6 db             	movzbl %bl,%ebx
  dc7556:	48 83 fb 01          	cmp    $0x1,%rbx
  dc755a:	0f 94 c0             	sete   %al
  dc755d:	0f b6 c0             	movzbl %al,%eax
  dc7560:	48 89 d9             	mov    %rbx,%rcx
  dc7563:	48 c1 e9 28          	shr    $0x28,%rcx
  dc7567:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  dc756e:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  dc7575:	0f 94 c1             	sete   %cl
  dc7578:	0f b6 c9             	movzbl %cl,%ecx
  dc757b:	41 89 c4             	mov    %eax,%r12d
  dc757e:	41 09 cc             	or     %ecx,%r12d
  dc7581:	0f 85 a3 00 00 00    	jne    dc762a <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x5aa>
  dc7587:	4c 89 f6             	mov    %r14,%rsi
  dc758a:	49 89 fe             	mov    %rdi,%r14
  dc758d:	e8 ae fc 01 00       	callq  de7240 <p111_rt_sink>
  dc7592:	4c 89 f7             	mov    %r14,%rdi
  dc7595:	4c 89 ee             	mov    %r13,%rsi
  dc7598:	49 89 fd             	mov    %rdi,%r13
  dc759b:	e8 a0 fc 01 00       	callq  de7240 <p111_rt_sink>
  dc75a0:	4c 89 ef             	mov    %r13,%rdi
  dc75a3:	44 89 e0             	mov    %r12d,%eax
  dc75a6:	83 f0 01             	xor    $0x1,%eax
  dc75a9:	75 2d                	jne    dc75d8 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x558>
  dc75ab:	48 89 9d 90 ef ff ff 	mov    %rbx,-0x1070(%rbp)
  dc75b2:	48 8b 47 10          	mov    0x10(%rdi),%rax
  dc75b6:	48 89 18             	mov    %rbx,(%rax)
  dc75b9:	48 c7 40 08 83 b9 00 	movq   $0xb983,0x8(%rax)
  dc75c0:	00 
  dc75c1:	48 83 c0 10          	add    $0x10,%rax
  dc75c5:	48 89 47 10          	mov    %rax,0x10(%rdi)
  dc75c9:	be 04 00 00 00       	mov    $0x4,%esi
  dc75ce:	e8 fd 03 02 00       	callq  de79d0 <p111_rt_fail>
  dc75d3:	e9 fb 01 00 00       	jmpq   dc77d3 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  dc75d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  dc75dd:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc75e4:	be 00 00 00 00       	mov    $0x0,%esi
  dc75e9:	48 89 fb             	mov    %rdi,%rbx
  dc75ec:	e8 bf fc 01 00       	callq  de72b0 <p111_rt_ctor>
  dc75f1:	48 89 df             	mov    %rbx,%rdi
  dc75f4:	48 89 c6             	mov    %rax,%rsi
  dc75f7:	48 89 fb             	mov    %rdi,%rbx
  dc75fa:	e8 41 fc 01 00       	callq  de7240 <p111_rt_sink>
  dc75ff:	48 89 df             	mov    %rbx,%rdi
  dc7602:	48 89 fb             	mov    %rdi,%rbx
  dc7605:	e8 76 30 80 ff       	callq  5ca680 <p112w_FID_109_105_115_115_105_110_103_>
  dc760a:	48 89 df             	mov    %rbx,%rdi
  dc760d:	48 89 85 90 ef ff ff 	mov    %rax,-0x1070(%rbp)
  dc7614:	ba 01 00 00 00       	mov    $0x1,%edx
  dc7619:	48 8d b5 90 ef ff ff 	lea    -0x1070(%rbp),%rsi
  dc7620:	e8 3b 02 02 00       	callq  de7860 <p111_rt_return>
  dc7625:	e9 a9 01 00 00       	jmpq   dc77d3 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  dc762a:	2e 2e 4c 89 eb       	cs cs mov %r13,%rbx
  dc762f:	4d 89 f5             	mov    %r14,%r13
  dc7632:	b9 00 00 00 00       	mov    $0x0,%ecx
  dc7637:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc763e:	be 00 00 00 00       	mov    $0x0,%esi
  dc7643:	49 89 fc             	mov    %rdi,%r12
  dc7646:	e8 65 fc 01 00       	callq  de72b0 <p111_rt_ctor>
  dc764b:	4c 89 e7             	mov    %r12,%rdi
  dc764e:	48 89 c6             	mov    %rax,%rsi
  dc7651:	49 89 fc             	mov    %rdi,%r12
  dc7654:	e8 e7 fb 01 00       	callq  de7240 <p111_rt_sink>
  dc7659:	4c 89 e7             	mov    %r12,%rdi
  dc765c:	48 89 9d 90 ef ff ff 	mov    %rbx,-0x1070(%rbp)
  dc7663:	4c 89 ad 98 ef ff ff 	mov    %r13,-0x1068(%rbp)
  dc766a:	b9 02 00 00 00       	mov    $0x2,%ecx
  dc766f:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc7676:	be 5a b9 00 00       	mov    $0xb95a,%esi
  dc767b:	e8 80 01 02 00       	callq  de7800 <p111_rt_jump>
  dc7680:	e9 4e 01 00 00       	jmpq   dc77d3 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_+0x753>
  dc7685:	b9 09 00 00 00       	mov    $0x9,%ecx
  dc768a:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc7691:	49 89 fe             	mov    %rdi,%r14
  dc7694:	e8 97 fd 01 00       	callq  de7430 <p111_rt_take>
  dc7699:	4c 89 f7             	mov    %r14,%rdi
  dc769c:	4c 8b b5 90 ef ff ff 	mov    -0x1070(%rbp),%r14
  dc76a3:	48 8b b5 98 ef ff ff 	mov    -0x1068(%rbp),%rsi
  dc76aa:	4c 8b 9d a0 ef ff ff 	mov    -0x1060(%rbp),%r11
  dc76b1:	4c 89 5d 90          	mov    %r11,-0x70(%rbp)
  dc76b5:	4c 8b 95 a8 ef ff ff 	mov    -0x1058(%rbp),%r10
  dc76bc:	4c 89 55 98          	mov    %r10,-0x68(%rbp)
  dc76c0:	4c 8b 8d b0 ef ff ff 	mov    -0x1050(%rbp),%r9
  dc76c7:	4c 89 4d a0          	mov    %r9,-0x60(%rbp)
  dc76cb:	4c 8b 85 b8 ef ff ff 	mov    -0x1048(%rbp),%r8
  dc76d2:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  dc76d6:	48 8b 95 c0 ef ff ff 	mov    -0x1040(%rbp),%rdx
  dc76dd:	48 89 55 b0          	mov    %rdx,-0x50(%rbp)
  dc76e1:	48 8b 8d c8 ef ff ff 	mov    -0x1038(%rbp),%rcx
  dc76e8:	48 89 4d b8          	mov    %rcx,-0x48(%rbp)
  dc76ec:	48 8b 85 d0 ef ff ff 	mov    -0x1030(%rbp),%rax
  dc76f3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  dc76f7:	49 89 ff             	mov    %rdi,%r15
  dc76fa:	e8 b1 fa 01 00       	callq  de71b0 <p111_rt_keep>
  dc76ff:	4c 89 ff             	mov    %r15,%rdi
  dc7702:	48 89 c6             	mov    %rax,%rsi
  dc7705:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  dc7709:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  dc770d:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  dc7711:	4c 8b 45 a8          	mov    -0x58(%rbp),%r8
  dc7715:	4c 8b 4d a0          	mov    -0x60(%rbp),%r9
  dc7719:	4c 8b 55 98          	mov    -0x68(%rbp),%r10
  dc771d:	4c 8b 5d 90          	mov    -0x70(%rbp),%r11
  dc7721:	4c 89 b5 90 ef ff ff 	mov    %r14,-0x1070(%rbp)
  dc7728:	48 89 b5 98 ef ff ff 	mov    %rsi,-0x1068(%rbp)
  dc772f:	4c 89 9d a0 ef ff ff 	mov    %r11,-0x1060(%rbp)
  dc7736:	4c 89 95 a8 ef ff ff 	mov    %r10,-0x1058(%rbp)
  dc773d:	4c 89 8d b0 ef ff ff 	mov    %r9,-0x1050(%rbp)
  dc7744:	4c 89 85 b8 ef ff ff 	mov    %r8,-0x1048(%rbp)
  dc774b:	48 89 95 c0 ef ff ff 	mov    %rdx,-0x1040(%rbp)
  dc7752:	48 89 8d c8 ef ff ff 	mov    %rcx,-0x1038(%rbp)
  dc7759:	48 89 85 d0 ef ff ff 	mov    %rax,-0x1030(%rbp)
  dc7760:	b9 09 00 00 00       	mov    $0x9,%ecx
  dc7765:	48 8d 95 90 ef ff ff 	lea    -0x1070(%rbp),%rdx
  dc776c:	49 89 f7             	mov    %rsi,%r15
  dc776f:	be 99 00 00 00       	mov    $0x99,%esi
  dc7774:	49 89 fe             	mov    %rdi,%r14
  dc7777:	e8 34 fb 01 00       	callq  de72b0 <p111_rt_ctor>
  dc777c:	4c 89 fe             	mov    %r15,%rsi
  dc777f:	4c 89 f7             	mov    %r14,%rdi
  dc7782:	49 89 c6             	mov    %rax,%r14
  dc7785:	48 ba 0a 82 10 03 00 	movabs $0x20019000310820a,%rdx
  dc778c:	19 00 02 
  dc778f:	49 89 ff             	mov    %rdi,%r15
  dc7792:	e8 29 2f 80 ff       	callq  5ca6c0 <p112w_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_>
  dc7797:	4c 89 ff             	mov    %r15,%rdi
  dc779a:	4c 89 b5 90 f7 ff ff 	mov    %r14,-0x870(%rbp)
  dc77a1:	4c 89 ad 98 f7 ff ff 	mov    %r13,-0x868(%rbp)
  dc77a8:	4c 89 a5 a0 f7 ff ff 	mov    %r12,-0x860(%rbp)
  dc77af:	48 89 9d a8 f7 ff ff 	mov    %rbx,-0x858(%rbp)
  dc77b6:	48 89 85 b0 f7 ff ff 	mov    %rax,-0x850(%rbp)
  dc77bd:	b9 05 00 00 00       	mov    $0x5,%ecx
  dc77c2:	48 8d 95 90 f7 ff ff 	lea    -0x870(%rbp),%rdx
  dc77c9:	be 79 b9 00 00       	mov    $0xb979,%esi
  dc77ce:	e8 2d 00 02 00       	callq  de7800 <p111_rt_jump>
  dc77d3:	41 5f                	pop    %r15
  dc77d5:	41 5e                	pop    %r14
  dc77d7:	41 5d                	pop    %r13
  dc77d9:	41 5c                	pop    %r12
  dc77db:	5b                   	pop    %rbx
  dc77dc:	c9                   	leaveq 
  dc77dd:	c3                   	retq   

Disassembly of section .fini:
