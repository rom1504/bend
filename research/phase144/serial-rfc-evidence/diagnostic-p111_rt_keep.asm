
/home/ai/bend2/build/publish/bend/selfhost/build/phase144/profile01/runtime/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000f54420 <p111_rt_keep>:
  f54420:	8b 15 62 e3 21 00    	mov    0x21e362(%rip),%edx        # 1172788 <bp_counts_enabled>
  f54426:	48 89 f0             	mov    %rsi,%rax
  f54429:	48 8b 77 08          	mov    0x8(%rdi),%rsi
  f5442d:	48 8b 3f             	mov    (%rdi),%rdi
  f54430:	85 d2                	test   %edx,%edx
  f54432:	75 54                	jne    f54488 <p111_rt_keep+0x68>
  f54434:	48 85 c0             	test   %rax,%rax
  f54437:	78 7f                	js     f544b8 <p111_rt_keep+0x98>
  f54439:	48 89 c2             	mov    %rax,%rdx
  f5443c:	48 c1 ea 38          	shr    $0x38,%rdx
  f54440:	83 e2 7e             	and    $0x7e,%edx
  f54443:	75 0b                	jne    f54450 <p111_rt_keep+0x30>
  f54445:	c3                   	retq   
  f54446:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  f5444d:	00 00 00 
  f54450:	48 8b 15 59 5f 20 00 	mov    0x205f59(%rip),%rdx        # 115a3b0 <p111_program_active>
  f54457:	48 b9 ff ff ff ff ff 	movabs $0xffffffffff,%rcx
  f5445e:	00 00 00 
  f54461:	48 21 c1             	and    %rax,%rcx
  f54464:	48 8b 52 40          	mov    0x40(%rdx),%rdx
  f54468:	48 83 c2 7f          	add    $0x7f,%rdx
  f5446c:	48 83 e2 80          	and    $0xffffffffffffff80,%rdx
  f54470:	48 81 c2 00 82 10 03 	add    $0x3108200,%rdx
  f54477:	48 39 d1             	cmp    %rdx,%rcx
  f5447a:	0f 83 13 fd 4a ff    	jae    404193 <p111_rt_keep.cold>
  f54480:	c3                   	retq   
  f54481:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  f54488:	48 c7 c2 fc ff ff ff 	mov    $0xfffffffffffffffc,%rdx
  f5448f:	64 8b 12             	mov    %fs:(%rdx),%edx
  f54492:	8b 0d 08 e3 21 00    	mov    0x21e308(%rip),%ecx        # 11727a0 <bp_rows>
  f54498:	83 fa ff             	cmp    $0xffffffff,%edx
  f5449b:	74 53                	je     f544f0 <p111_rt_keep+0xd0>
  f5449d:	83 e9 01             	sub    $0x1,%ecx
  f544a0:	39 ca                	cmp    %ecx,%edx
  f544a2:	72 4f                	jb     f544f3 <p111_rt_keep+0xd3>
  f544a4:	f0 48 83 05 03 e3 21 	lock addq $0x1,0x21e303(%rip)        # 11727b0 <bp_bad_contexts>
  f544ab:	00 01 
  f544ad:	48 85 c0             	test   %rax,%rax
  f544b0:	79 87                	jns    f54439 <p111_rt_keep+0x19>
  f544b2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  f544b8:	48 ba ff ff ff ff ff 	movabs $0xffffffffff,%rdx
  f544bf:	00 00 00 
  f544c2:	b9 01 00 00 00       	mov    $0x1,%ecx
  f544c7:	48 21 c2             	and    %rax,%rdx
  f544ca:	f0 0f c1 0c d7       	lock xadd %ecx,(%rdi,%rdx,8)
  f544cf:	81 e1 ff ff ff 00    	and    $0xffffff,%ecx
  f544d5:	81 f9 fd ff ff 00    	cmp    $0xfffffd,%ecx
  f544db:	0f 86 64 ff ff ff    	jbe    f54445 <p111_rt_keep+0x25>
  f544e1:	50                   	push   %rax
  f544e2:	e8 19 b9 ff ff       	callq  f4fe00 <rfc_bump.part.0>
  f544e7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  f544ee:	00 00 
  f544f0:	8d 51 ff             	lea    -0x1(%rcx),%edx
  f544f3:	48 c1 e2 04          	shl    $0x4,%rdx
  f544f7:	48 8b 0d ba e2 21 00 	mov    0x21e2ba(%rip),%rcx        # 11727b8 <bp_counts>
  f544fe:	48 83 c2 06          	add    $0x6,%rdx
  f54502:	f0 48 83 04 d1 01    	lock addq $0x1,(%rcx,%rdx,8)
  f54508:	0f 85 26 ff ff ff    	jne    f54434 <p111_rt_keep+0x14>
  f5450e:	c7 05 90 e2 21 00 01 	movl   $0x1,0x21e290(%rip)        # 11727a8 <bp_overflow>
  f54515:	00 00 00 
  f54518:	e9 17 ff ff ff       	jmpq   f54434 <p111_rt_keep+0x14>

Disassembly of section .fini:
