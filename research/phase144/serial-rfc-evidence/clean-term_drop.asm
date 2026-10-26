
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p143-integrated-n2/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000f51630 <term_drop>:
  f51630:	49 b9 00 00 00 00 00 	movabs $0x1000000000000,%r9
  f51637:	00 01 00 
  f5163a:	41 57                	push   %r15
  f5163c:	49 b8 00 00 00 00 00 	movabs $0x10000000000,%r8
  f51643:	01 00 00 
  f51646:	41 56                	push   %r14
  f51648:	45 31 f6             	xor    %r14d,%r14d
  f5164b:	41 55                	push   %r13
  f5164d:	41 54                	push   %r12
  f5164f:	49 bc ff ff ff ff ff 	movabs $0xffffffffff,%r12
  f51656:	00 00 00 
  f51659:	55                   	push   %rbp
  f5165a:	48 89 d5             	mov    %rdx,%rbp
  f5165d:	53                   	push   %rbx
  f5165e:	31 db                	xor    %ebx,%ebx
  f51660:	48 89 e9             	mov    %rbp,%rcx
  f51663:	48 c1 e9 38          	shr    $0x38,%rcx
  f51667:	f6 c1 7e             	test   $0x7e,%cl
  f5166a:	74 34                	je     f516a0 <term_drop+0x70>
  f5166c:	48 83 fd ff          	cmp    $0xffffffffffffffff,%rbp
  f51670:	74 2e                	je     f516a0 <term_drop+0x70>
  f51672:	4c 8b 1d b7 6c 20 00 	mov    0x206cb7(%rip),%r11        # 1158330 <p111_program_active>
  f51679:	49 89 ea             	mov    %rbp,%r10
  f5167c:	4d 21 e2             	and    %r12,%r10
  f5167f:	49 8b 43 40          	mov    0x40(%r11),%rax
  f51683:	48 83 c0 7f          	add    $0x7f,%rax
  f51687:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
  f5168b:	48 05 00 82 10 03    	add    $0x3108200,%rax
  f51691:	49 39 c2             	cmp    %rax,%r10
  f51694:	0f 83 de 00 00 00    	jae    f51778 <term_drop+0x148>
  f5169a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  f516a0:	48 85 db             	test   %rbx,%rbx
  f516a3:	0f 84 c0 00 00 00    	je     f51769 <term_drop+0x139>
  f516a9:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  f516af:	41 bf 01 00 00 00    	mov    $0x1,%r15d
  f516b5:	0f 1f 00             	nopl   (%rax)
  f516b8:	48 89 d8             	mov    %rbx,%rax
  f516bb:	48 89 d9             	mov    %rbx,%rcx
  f516be:	49 89 da             	mov    %rbx,%r10
  f516c1:	48 c1 e8 28          	shr    $0x28,%rax
  f516c5:	48 c1 e9 38          	shr    $0x38,%rcx
  f516c9:	4d 21 e2             	and    %r12,%r10
  f516cc:	0f b6 c0             	movzbl %al,%eax
  f516cf:	48 83 f9 3f          	cmp    $0x3f,%rcx
  f516d3:	0f 87 37 01 00 00    	ja     f51810 <term_drop+0x1e0>
  f516d9:	48 89 dd             	mov    %rbx,%rbp
  f516dc:	89 c2                	mov    %eax,%edx
  f516de:	41 89 cb             	mov    %ecx,%r11d
  f516e1:	48 c1 ed 30          	shr    $0x30,%rbp
  f516e5:	40 0f b6 ed          	movzbl %bpl,%ebp
  f516e9:	39 d5                	cmp    %edx,%ebp
  f516eb:	0f 86 47 01 00 00    	jbe    f51838 <term_drop+0x208>
  f516f1:	85 d2                	test   %edx,%edx
  f516f3:	0f 84 af 01 00 00    	je     f518a8 <term_drop+0x278>
  f516f9:	41 89 d3             	mov    %edx,%r11d
  f516fc:	4d 01 d3             	add    %r10,%r11
  f516ff:	4a 8b 2c df          	mov    (%rdi,%r11,8),%rbp
  f51703:	48 83 f9 3f          	cmp    $0x3f,%rcx
  f51707:	0f 86 73 01 00 00    	jbe    f51880 <term_drop+0x250>
  f5170d:	83 c2 01             	add    $0x1,%edx
  f51710:	4a 89 54 d7 08       	mov    %rdx,0x8(%rdi,%r10,8)
  f51715:	83 f9 3f             	cmp    $0x3f,%ecx
  f51718:	0f 86 62 01 00 00    	jbe    f51880 <term_drop+0x250>
  f5171e:	83 f8 01             	cmp    $0x1,%eax
  f51721:	0f 86 59 01 00 00    	jbe    f51880 <term_drop+0x250>
  f51727:	48 89 e8             	mov    %rbp,%rax
  f5172a:	48 c1 e8 38          	shr    $0x38,%rax
  f5172e:	a8 7e                	test   $0x7e,%al
  f51730:	74 86                	je     f516b8 <term_drop+0x88>
  f51732:	48 83 fd ff          	cmp    $0xffffffffffffffff,%rbp
  f51736:	74 80                	je     f516b8 <term_drop+0x88>
  f51738:	48 8b 05 f1 6b 20 00 	mov    0x206bf1(%rip),%rax        # 1158330 <p111_program_active>
  f5173f:	48 89 ea             	mov    %rbp,%rdx
  f51742:	4c 21 e2             	and    %r12,%rdx
  f51745:	48 8b 40 40          	mov    0x40(%rax),%rax
  f51749:	48 83 c0 7f          	add    $0x7f,%rax
  f5174d:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
  f51751:	48 05 00 82 10 03    	add    $0x3108200,%rax
  f51757:	48 39 c2             	cmp    %rax,%rdx
  f5175a:	0f 83 00 ff ff ff    	jae    f51660 <term_drop+0x30>
  f51760:	48 85 db             	test   %rbx,%rbx
  f51763:	0f 85 4f ff ff ff    	jne    f516b8 <term_drop+0x88>
  f51769:	5b                   	pop    %rbx
  f5176a:	5d                   	pop    %rbp
  f5176b:	41 5c                	pop    %r12
  f5176d:	41 5d                	pop    %r13
  f5176f:	41 5e                	pop    %r14
  f51771:	41 5f                	pop    %r15
  f51773:	c3                   	retq   
  f51774:	0f 1f 40 00          	nopl   0x0(%rax)
  f51778:	48 85 ed             	test   %rbp,%rbp
  f5177b:	0f 88 57 01 00 00    	js     f518d8 <term_drop+0x2a8>
  f51781:	83 e1 7f             	and    $0x7f,%ecx
  f51784:	48 83 f9 04          	cmp    $0x4,%rcx
  f51788:	0f 84 17 02 00 00    	je     f519a5 <term_drop+0x375>
  f5178e:	48 c1 ed 28          	shr    $0x28,%rbp
  f51792:	0f b7 ed             	movzwl %bp,%ebp
  f51795:	48 83 f9 06          	cmp    $0x6,%rcx
  f51799:	0f 84 11 01 00 00    	je     f518b0 <term_drop+0x280>
  f5179f:	48 83 f9 02          	cmp    $0x2,%rcx
  f517a3:	0f 84 47 02 00 00    	je     f519f0 <term_drop+0x3c0>
  f517a9:	49 8b 43 10          	mov    0x10(%r11),%rax
  f517ad:	48 83 f9 03          	cmp    $0x3,%rcx
  f517b1:	0f 84 c1 01 00 00    	je     f51978 <term_drop+0x348>
  f517b7:	39 c5                	cmp    %eax,%ebp
  f517b9:	0f 82 5a 02 00 00    	jb     f51a19 <term_drop+0x3e9>
  f517bf:	0f 84 d1 02 00 00    	je     f51a96 <term_drop+0x466>
  f517c5:	83 c0 01             	add    $0x1,%eax
  f517c8:	39 c5                	cmp    %eax,%ebp
  f517ca:	0f 84 9e 02 00 00    	je     f51a6e <term_drop+0x43e>
  f517d0:	4c 89 d0             	mov    %r10,%rax
  f517d3:	48 83 f9 05          	cmp    $0x5,%rcx
  f517d7:	0f 85 e4 00 00 00    	jne    f518c1 <term_drop+0x291>
  f517dd:	45 31 db             	xor    %r11d,%r11d
  f517e0:	ba 02 00 00 00       	mov    $0x2,%edx
  f517e5:	0f 1f 00             	nopl   (%rax)
  f517e8:	83 ea 01             	sub    $0x1,%edx
  f517eb:	b8 20 00 00 00       	mov    $0x20,%eax
  f517f0:	0f bd d2             	bsr    %edx,%edx
  f517f3:	83 f2 1f             	xor    $0x1f,%edx
  f517f6:	29 d0                	sub    %edx,%eax
  f517f8:	48 c1 e0 38          	shl    $0x38,%rax
  f517fc:	4c 09 d8             	or     %r11,%rax
  f517ff:	4c 09 d0             	or     %r10,%rax
  f51802:	e9 ba 00 00 00       	jmpq   f518c1 <term_drop+0x291>
  f51807:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  f5180e:	00 00 
  f51810:	41 89 cb             	mov    %ecx,%r11d
  f51813:	44 89 ed             	mov    %r13d,%ebp
  f51816:	89 c2                	mov    %eax,%edx
  f51818:	41 83 e3 3f          	and    $0x3f,%r11d
  f5181c:	d3 e5                	shl    %cl,%ebp
  f5181e:	83 f8 02             	cmp    $0x2,%eax
  f51821:	0f 85 c2 fe ff ff    	jne    f516e9 <term_drop+0xb9>
  f51827:	42 8b 54 d7 08       	mov    0x8(%rdi,%r10,8),%edx
  f5182c:	39 d5                	cmp    %edx,%ebp
  f5182e:	0f 87 bd fe ff ff    	ja     f516f1 <term_drop+0xc1>
  f51834:	0f 1f 40 00          	nopl   0x0(%rax)
  f51838:	44 89 d8             	mov    %r11d,%eax
  f5183b:	4a 8d 14 d7          	lea    (%rdi,%r10,8),%rdx
  f5183f:	48 8d 04 c6          	lea    (%rsi,%rax,8),%rax
  f51843:	48 8b 1a             	mov    (%rdx),%rbx
  f51846:	48 8b 08             	mov    (%rax),%rcx
  f51849:	48 89 0a             	mov    %rcx,(%rdx)
  f5184c:	44 89 d9             	mov    %r11d,%ecx
  f5184f:	4c 89 10             	mov    %r10,(%rax)
  f51852:	41 8d 43 20          	lea    0x20(%r11),%eax
  f51856:	48 8d 14 c6          	lea    (%rsi,%rax,8),%rdx
  f5185a:	4c 89 f8             	mov    %r15,%rax
  f5185d:	48 d3 e0             	shl    %cl,%rax
  f51860:	48 03 02             	add    (%rdx),%rax
  f51863:	48 89 02             	mov    %rax,(%rdx)
  f51866:	8b 15 7c 6b 20 00    	mov    0x206b7c(%rip),%edx        # 11583e8 <KEEP_WORDS>
  f5186c:	48 39 d0             	cmp    %rdx,%rax
  f5186f:	0f 82 eb fe ff ff    	jb     f51760 <term_drop+0x130>
  f51875:	e9 1e 17 4b ff       	jmpq   402f98 <term_drop.cold+0x40>
  f5187a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  f51880:	48 89 e8             	mov    %rbp,%rax
  f51883:	4c 01 c3             	add    %r8,%rbx
  f51886:	48 c1 e8 38          	shr    $0x38,%rax
  f5188a:	a8 7e                	test   $0x7e,%al
  f5188c:	0f 84 ce fe ff ff    	je     f51760 <term_drop+0x130>
  f51892:	48 83 fd ff          	cmp    $0xffffffffffffffff,%rbp
  f51896:	0f 84 c4 fe ff ff    	je     f51760 <term_drop+0x130>
  f5189c:	e9 97 fe ff ff       	jmpq   f51738 <term_drop+0x108>
  f518a1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  f518a8:	4c 89 f5             	mov    %r14,%rbp
  f518ab:	e9 65 fe ff ff       	jmpq   f51715 <term_drop+0xe5>
  f518b0:	48 89 e8             	mov    %rbp,%rax
  f518b3:	83 e0 1f             	and    $0x1f,%eax
  f518b6:	48 83 c8 40          	or     $0x40,%rax
  f518ba:	48 c1 e0 38          	shl    $0x38,%rax
  f518be:	4c 09 d0             	or     %r10,%rax
  f518c1:	4a 8d 14 d7          	lea    (%rdi,%r10,8),%rdx
  f518c5:	4c 8b 32             	mov    (%rdx),%r14
  f518c8:	48 89 1a             	mov    %rbx,(%rdx)
  f518cb:	48 89 c3             	mov    %rax,%rbx
  f518ce:	e9 cd fd ff ff       	jmpq   f516a0 <term_drop+0x70>
  f518d3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  f518d8:	4a 8d 04 d7          	lea    (%rdi,%r10,8),%rax
  f518dc:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  f518e1:	f0 0f c1 10          	lock xadd %edx,(%rax)
  f518e5:	81 e2 ff ff ff 00    	and    $0xffffff,%edx
  f518eb:	83 fa 01             	cmp    $0x1,%edx
  f518ee:	0f 85 ac fd ff ff    	jne    f516a0 <term_drop+0x70>
  f518f4:	8b 10                	mov    (%rax),%edx
  f518f6:	48 ba 00 00 00 00 00 	movabs $0x7fffff0000000000,%rdx
  f518fd:	ff ff 7f 
  f51900:	48 21 d5             	and    %rdx,%rbp
  f51903:	48 8b 10             	mov    (%rax),%rdx
  f51906:	48 c1 ea 18          	shr    $0x18,%rdx
  f5190a:	48 09 d5             	or     %rdx,%rbp
  f5190d:	48 8b 16             	mov    (%rsi),%rdx
  f51910:	48 89 10             	mov    %rdx,(%rax)
  f51913:	48 8b 86 00 01 00 00 	mov    0x100(%rsi),%rax
  f5191a:	8b 15 c8 6a 20 00    	mov    0x206ac8(%rip),%edx        # 11583e8 <KEEP_WORDS>
  f51920:	4c 89 16             	mov    %r10,(%rsi)
  f51923:	48 83 c0 01          	add    $0x1,%rax
  f51927:	48 89 86 00 01 00 00 	mov    %rax,0x100(%rsi)
  f5192e:	48 39 d0             	cmp    %rdx,%rax
  f51931:	0f 83 21 16 4b ff    	jae    402f58 <term_drop.cold>
  f51937:	48 89 e9             	mov    %rbp,%rcx
  f5193a:	48 c1 e9 38          	shr    $0x38,%rcx
  f5193e:	f6 c1 7e             	test   $0x7e,%cl
  f51941:	0f 84 59 fd ff ff    	je     f516a0 <term_drop+0x70>
  f51947:	4c 8b 1d e2 69 20 00 	mov    0x2069e2(%rip),%r11        # 1158330 <p111_program_active>
  f5194e:	49 89 ea             	mov    %rbp,%r10
  f51951:	4d 21 e2             	and    %r12,%r10
  f51954:	49 8b 43 40          	mov    0x40(%r11),%rax
  f51958:	48 83 c0 7f          	add    $0x7f,%rax
  f5195c:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
  f51960:	48 05 00 82 10 03    	add    $0x3108200,%rax
  f51966:	4c 39 d0             	cmp    %r10,%rax
  f51969:	0f 86 12 fe ff ff    	jbe    f51781 <term_drop+0x151>
  f5196f:	e9 2c fd ff ff       	jmpq   f516a0 <term_drop+0x70>
  f51974:	0f 1f 40 00          	nopl   0x0(%rax)
  f51978:	39 c5                	cmp    %eax,%ebp
  f5197a:	0f 82 b9 00 00 00    	jb     f51a39 <term_drop+0x409>
  f51980:	0f 84 21 01 00 00    	je     f51aa7 <term_drop+0x477>
  f51986:	83 c0 01             	add    $0x1,%eax
  f51989:	39 c5                	cmp    %eax,%ebp
  f5198b:	0f 84 2b 01 00 00    	je     f51abc <term_drop+0x48c>
  f51991:	49 bb 00 00 00 00 00 	movabs $0xffff000000000000,%r11
  f51998:	00 ff ff 
  f5199b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  f519a0:	e9 43 fe ff ff       	jmpq   f517e8 <term_drop+0x1b8>
  f519a5:	48 c1 ed 28          	shr    $0x28,%rbp
  f519a9:	83 e5 1f             	and    $0x1f,%ebp
  f519ac:	0f 85 9b 00 00 00    	jne    f51a4d <term_drop+0x41d>
  f519b2:	48 89 f2             	mov    %rsi,%rdx
  f519b5:	b8 01 00 00 00       	mov    $0x1,%eax
  f519ba:	41 bb 00 01 00 00    	mov    $0x100,%r11d
  f519c0:	48 8b 0a             	mov    (%rdx),%rcx
  f519c3:	4a 89 0c d7          	mov    %rcx,(%rdi,%r10,8)
  f519c7:	4a 8d 0c 1e          	lea    (%rsi,%r11,1),%rcx
  f519cb:	4c 89 12             	mov    %r10,(%rdx)
  f519ce:	8b 15 14 6a 20 00    	mov    0x206a14(%rip),%edx        # 11583e8 <KEEP_WORDS>
  f519d4:	48 03 01             	add    (%rcx),%rax
  f519d7:	48 89 01             	mov    %rax,(%rcx)
  f519da:	48 39 d0             	cmp    %rdx,%rax
  f519dd:	0f 82 bd fc ff ff    	jb     f516a0 <term_drop+0x70>
  f519e3:	e9 90 15 4b ff       	jmpq   402f78 <term_drop.cold+0x20>
  f519e8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  f519ef:	00 
  f519f0:	49 8b 83 80 00 00 00 	mov    0x80(%r11),%rax
  f519f7:	0f b6 14 28          	movzbl (%rax,%rbp,1),%edx
  f519fb:	48 89 d0             	mov    %rdx,%rax
  f519fe:	48 c1 e0 30          	shl    $0x30,%rax
  f51a02:	49 89 c3             	mov    %rax,%r11
  f51a05:	83 fa 01             	cmp    $0x1,%edx
  f51a08:	0f 87 da fd ff ff    	ja     f517e8 <term_drop+0x1b8>
  f51a0e:	4c 89 d8             	mov    %r11,%rax
  f51a11:	4c 09 d0             	or     %r10,%rax
  f51a14:	e9 a8 fe ff ff       	jmpq   f518c1 <term_drop+0x291>
  f51a19:	49 8b 43 68          	mov    0x68(%r11),%rax
  f51a1d:	0f b6 14 28          	movzbl (%rax,%rbp,1),%edx
  f51a21:	48 89 d0             	mov    %rdx,%rax
  f51a24:	48 c1 e0 30          	shl    $0x30,%rax
  f51a28:	49 89 c3             	mov    %rax,%r11
  f51a2b:	48 83 f9 05          	cmp    $0x5,%rcx
  f51a2f:	75 d4                	jne    f51a05 <term_drop+0x3d5>
  f51a31:	83 c2 02             	add    $0x2,%edx
  f51a34:	e9 af fd ff ff       	jmpq   f517e8 <term_drop+0x1b8>
  f51a39:	49 8b 43 68          	mov    0x68(%r11),%rax
  f51a3d:	0f b6 14 28          	movzbl (%rax,%rbp,1),%edx
  f51a41:	83 ea 01             	sub    $0x1,%edx
  f51a44:	49 89 d3             	mov    %rdx,%r11
  f51a47:	49 c1 e3 30          	shl    $0x30,%r11
  f51a4b:	eb b8                	jmp    f51a05 <term_drop+0x3d5>
  f51a4d:	8d 45 ff             	lea    -0x1(%rbp),%eax
  f51a50:	44 8d 5d 1f          	lea    0x1f(%rbp),%r11d
  f51a54:	48 89 c1             	mov    %rax,%rcx
  f51a57:	48 8d 14 c6          	lea    (%rsi,%rax,8),%rdx
  f51a5b:	b8 01 00 00 00       	mov    $0x1,%eax
  f51a60:	49 c1 e3 03          	shl    $0x3,%r11
  f51a64:	48 d3 e0             	shl    %cl,%rax
  f51a67:	89 cd                	mov    %ecx,%ebp
  f51a69:	e9 52 ff ff ff       	jmpq   f519c0 <term_drop+0x390>
  f51a6e:	48 b8 00 00 00 00 00 	movabs $0x102000000000000,%rax
  f51a75:	00 02 01 
  f51a78:	48 83 f9 05          	cmp    $0x5,%rcx
  f51a7c:	0f 85 7d fd ff ff    	jne    f517ff <term_drop+0x1cf>
  f51a82:	49 bb 00 00 00 00 00 	movabs $0x2000000000000,%r11
  f51a89:	00 02 00 
  f51a8c:	ba 04 00 00 00       	mov    $0x4,%edx
  f51a91:	e9 52 fd ff ff       	jmpq   f517e8 <term_drop+0x1b8>
  f51a96:	48 83 f9 05          	cmp    $0x5,%rcx
  f51a9a:	74 13                	je     f51aaf <term_drop+0x47f>
  f51a9c:	4c 89 d0             	mov    %r10,%rax
  f51a9f:	4c 09 c8             	or     %r9,%rax
  f51aa2:	e9 1a fe ff ff       	jmpq   f518c1 <term_drop+0x291>
  f51aa7:	45 31 db             	xor    %r11d,%r11d
  f51aaa:	e9 5f ff ff ff       	jmpq   f51a0e <term_drop+0x3de>
  f51aaf:	4d 89 cb             	mov    %r9,%r11
  f51ab2:	ba 03 00 00 00       	mov    $0x3,%edx
  f51ab7:	e9 2c fd ff ff       	jmpq   f517e8 <term_drop+0x1b8>
  f51abc:	4d 89 cb             	mov    %r9,%r11
  f51abf:	e9 4a ff ff ff       	jmpq   f51a0e <term_drop+0x3de>

Disassembly of section .fini:
