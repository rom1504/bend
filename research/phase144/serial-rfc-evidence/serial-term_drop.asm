
selfhost/build/phase144/serial-rfc01/serial-rfc-compiler:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000f514a0 <term_drop>:
  f514a0:	49 b9 00 00 00 00 00 	movabs $0x1000000000000,%r9
  f514a7:	00 01 00 
  f514aa:	41 57                	push   %r15
  f514ac:	49 b8 00 00 00 00 00 	movabs $0x10000000000,%r8
  f514b3:	01 00 00 
  f514b6:	41 56                	push   %r14
  f514b8:	45 31 f6             	xor    %r14d,%r14d
  f514bb:	41 55                	push   %r13
  f514bd:	41 54                	push   %r12
  f514bf:	49 bc ff ff ff ff ff 	movabs $0xffffffffff,%r12
  f514c6:	00 00 00 
  f514c9:	55                   	push   %rbp
  f514ca:	48 89 d5             	mov    %rdx,%rbp
  f514cd:	53                   	push   %rbx
  f514ce:	31 db                	xor    %ebx,%ebx
  f514d0:	48 89 e9             	mov    %rbp,%rcx
  f514d3:	48 c1 e9 38          	shr    $0x38,%rcx
  f514d7:	f6 c1 7e             	test   $0x7e,%cl
  f514da:	74 34                	je     f51510 <term_drop+0x70>
  f514dc:	48 83 fd ff          	cmp    $0xffffffffffffffff,%rbp
  f514e0:	74 2e                	je     f51510 <term_drop+0x70>
  f514e2:	4c 8b 1d 47 5e 20 00 	mov    0x205e47(%rip),%r11        # 1157330 <p111_program_active>
  f514e9:	49 89 ea             	mov    %rbp,%r10
  f514ec:	4d 21 e2             	and    %r12,%r10
  f514ef:	49 8b 43 40          	mov    0x40(%r11),%rax
  f514f3:	48 83 c0 7f          	add    $0x7f,%rax
  f514f7:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
  f514fb:	48 05 00 82 10 03    	add    $0x3108200,%rax
  f51501:	49 39 c2             	cmp    %rax,%r10
  f51504:	0f 83 de 00 00 00    	jae    f515e8 <term_drop+0x148>
  f5150a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  f51510:	48 85 db             	test   %rbx,%rbx
  f51513:	0f 84 c0 00 00 00    	je     f515d9 <term_drop+0x139>
  f51519:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  f5151f:	41 bf 01 00 00 00    	mov    $0x1,%r15d
  f51525:	0f 1f 00             	nopl   (%rax)
  f51528:	48 89 d8             	mov    %rbx,%rax
  f5152b:	48 89 d9             	mov    %rbx,%rcx
  f5152e:	49 89 da             	mov    %rbx,%r10
  f51531:	48 c1 e8 28          	shr    $0x28,%rax
  f51535:	48 c1 e9 38          	shr    $0x38,%rcx
  f51539:	4d 21 e2             	and    %r12,%r10
  f5153c:	0f b6 c0             	movzbl %al,%eax
  f5153f:	48 83 f9 3f          	cmp    $0x3f,%rcx
  f51543:	0f 87 37 01 00 00    	ja     f51680 <term_drop+0x1e0>
  f51549:	48 89 dd             	mov    %rbx,%rbp
  f5154c:	89 c2                	mov    %eax,%edx
  f5154e:	41 89 cb             	mov    %ecx,%r11d
  f51551:	48 c1 ed 30          	shr    $0x30,%rbp
  f51555:	40 0f b6 ed          	movzbl %bpl,%ebp
  f51559:	39 d5                	cmp    %edx,%ebp
  f5155b:	0f 86 47 01 00 00    	jbe    f516a8 <term_drop+0x208>
  f51561:	85 d2                	test   %edx,%edx
  f51563:	0f 84 af 01 00 00    	je     f51718 <term_drop+0x278>
  f51569:	41 89 d3             	mov    %edx,%r11d
  f5156c:	4d 01 d3             	add    %r10,%r11
  f5156f:	4a 8b 2c df          	mov    (%rdi,%r11,8),%rbp
  f51573:	48 83 f9 3f          	cmp    $0x3f,%rcx
  f51577:	0f 86 73 01 00 00    	jbe    f516f0 <term_drop+0x250>
  f5157d:	83 c2 01             	add    $0x1,%edx
  f51580:	4a 89 54 d7 08       	mov    %rdx,0x8(%rdi,%r10,8)
  f51585:	83 f9 3f             	cmp    $0x3f,%ecx
  f51588:	0f 86 62 01 00 00    	jbe    f516f0 <term_drop+0x250>
  f5158e:	83 f8 01             	cmp    $0x1,%eax
  f51591:	0f 86 59 01 00 00    	jbe    f516f0 <term_drop+0x250>
  f51597:	48 89 e8             	mov    %rbp,%rax
  f5159a:	48 c1 e8 38          	shr    $0x38,%rax
  f5159e:	a8 7e                	test   $0x7e,%al
  f515a0:	74 86                	je     f51528 <term_drop+0x88>
  f515a2:	48 83 fd ff          	cmp    $0xffffffffffffffff,%rbp
  f515a6:	74 80                	je     f51528 <term_drop+0x88>
  f515a8:	48 8b 05 81 5d 20 00 	mov    0x205d81(%rip),%rax        # 1157330 <p111_program_active>
  f515af:	48 89 ea             	mov    %rbp,%rdx
  f515b2:	4c 21 e2             	and    %r12,%rdx
  f515b5:	48 8b 40 40          	mov    0x40(%rax),%rax
  f515b9:	48 83 c0 7f          	add    $0x7f,%rax
  f515bd:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
  f515c1:	48 05 00 82 10 03    	add    $0x3108200,%rax
  f515c7:	48 39 c2             	cmp    %rax,%rdx
  f515ca:	0f 83 00 ff ff ff    	jae    f514d0 <term_drop+0x30>
  f515d0:	48 85 db             	test   %rbx,%rbx
  f515d3:	0f 85 4f ff ff ff    	jne    f51528 <term_drop+0x88>
  f515d9:	5b                   	pop    %rbx
  f515da:	5d                   	pop    %rbp
  f515db:	41 5c                	pop    %r12
  f515dd:	41 5d                	pop    %r13
  f515df:	41 5e                	pop    %r14
  f515e1:	41 5f                	pop    %r15
  f515e3:	c3                   	retq   
  f515e4:	0f 1f 40 00          	nopl   0x0(%rax)
  f515e8:	48 85 ed             	test   %rbp,%rbp
  f515eb:	0f 88 2f 01 00 00    	js     f51720 <term_drop+0x280>
  f515f1:	83 e1 7f             	and    $0x7f,%ecx
  f515f4:	48 83 f9 04          	cmp    $0x4,%rcx
  f515f8:	0f 84 58 02 00 00    	je     f51856 <term_drop+0x3b6>
  f515fe:	48 c1 ed 28          	shr    $0x28,%rbp
  f51602:	0f b7 ed             	movzwl %bp,%ebp
  f51605:	48 83 f9 06          	cmp    $0x6,%rcx
  f51609:	0f 84 b1 01 00 00    	je     f517c0 <term_drop+0x320>
  f5160f:	48 83 f9 02          	cmp    $0x2,%rcx
  f51613:	0f 84 f7 01 00 00    	je     f51810 <term_drop+0x370>
  f51619:	49 8b 43 10          	mov    0x10(%r11),%rax
  f5161d:	48 83 f9 03          	cmp    $0x3,%rcx
  f51621:	0f 84 bc 01 00 00    	je     f517e3 <term_drop+0x343>
  f51627:	39 c5                	cmp    %eax,%ebp
  f51629:	0f 82 07 02 00 00    	jb     f51836 <term_drop+0x396>
  f5162f:	0f 84 c0 02 00 00    	je     f518f5 <term_drop+0x455>
  f51635:	83 c0 01             	add    $0x1,%eax
  f51638:	39 c5                	cmp    %eax,%ebp
  f5163a:	0f 84 8d 02 00 00    	je     f518cd <term_drop+0x42d>
  f51640:	4c 89 d0             	mov    %r10,%rax
  f51643:	48 83 f9 05          	cmp    $0x5,%rcx
  f51647:	0f 85 84 01 00 00    	jne    f517d1 <term_drop+0x331>
  f5164d:	45 31 db             	xor    %r11d,%r11d
  f51650:	ba 02 00 00 00       	mov    $0x2,%edx
  f51655:	0f 1f 00             	nopl   (%rax)
  f51658:	83 ea 01             	sub    $0x1,%edx
  f5165b:	b8 20 00 00 00       	mov    $0x20,%eax
  f51660:	0f bd d2             	bsr    %edx,%edx
  f51663:	83 f2 1f             	xor    $0x1f,%edx
  f51666:	29 d0                	sub    %edx,%eax
  f51668:	48 c1 e0 38          	shl    $0x38,%rax
  f5166c:	4c 09 d8             	or     %r11,%rax
  f5166f:	4c 09 d0             	or     %r10,%rax
  f51672:	e9 5a 01 00 00       	jmpq   f517d1 <term_drop+0x331>
  f51677:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  f5167e:	00 00 
  f51680:	41 89 cb             	mov    %ecx,%r11d
  f51683:	44 89 ed             	mov    %r13d,%ebp
  f51686:	89 c2                	mov    %eax,%edx
  f51688:	41 83 e3 3f          	and    $0x3f,%r11d
  f5168c:	d3 e5                	shl    %cl,%ebp
  f5168e:	83 f8 02             	cmp    $0x2,%eax
  f51691:	0f 85 c2 fe ff ff    	jne    f51559 <term_drop+0xb9>
  f51697:	42 8b 54 d7 08       	mov    0x8(%rdi,%r10,8),%edx
  f5169c:	39 d5                	cmp    %edx,%ebp
  f5169e:	0f 87 bd fe ff ff    	ja     f51561 <term_drop+0xc1>
  f516a4:	0f 1f 40 00          	nopl   0x0(%rax)
  f516a8:	44 89 d8             	mov    %r11d,%eax
  f516ab:	4a 8d 14 d7          	lea    (%rdi,%r10,8),%rdx
  f516af:	48 8d 04 c6          	lea    (%rsi,%rax,8),%rax
  f516b3:	48 8b 1a             	mov    (%rdx),%rbx
  f516b6:	48 8b 08             	mov    (%rax),%rcx
  f516b9:	48 89 0a             	mov    %rcx,(%rdx)
  f516bc:	44 89 d9             	mov    %r11d,%ecx
  f516bf:	4c 89 10             	mov    %r10,(%rax)
  f516c2:	41 8d 43 20          	lea    0x20(%r11),%eax
  f516c6:	48 8d 14 c6          	lea    (%rsi,%rax,8),%rdx
  f516ca:	4c 89 f8             	mov    %r15,%rax
  f516cd:	48 d3 e0             	shl    %cl,%rax
  f516d0:	48 03 02             	add    (%rdx),%rax
  f516d3:	48 89 02             	mov    %rax,(%rdx)
  f516d6:	8b 15 08 5d 20 00    	mov    0x205d08(%rip),%edx        # 11573e4 <KEEP_WORDS>
  f516dc:	48 39 d0             	cmp    %rdx,%rax
  f516df:	0f 82 eb fe ff ff    	jb     f515d0 <term_drop+0x130>
  f516e5:	e9 84 1c 4b ff       	jmpq   40336e <term_drop.cold>
  f516ea:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  f516f0:	48 89 e8             	mov    %rbp,%rax
  f516f3:	4c 01 c3             	add    %r8,%rbx
  f516f6:	48 c1 e8 38          	shr    $0x38,%rax
  f516fa:	a8 7e                	test   $0x7e,%al
  f516fc:	0f 84 ce fe ff ff    	je     f515d0 <term_drop+0x130>
  f51702:	48 83 fd ff          	cmp    $0xffffffffffffffff,%rbp
  f51706:	0f 84 c4 fe ff ff    	je     f515d0 <term_drop+0x130>
  f5170c:	e9 97 fe ff ff       	jmpq   f515a8 <term_drop+0x108>
  f51711:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  f51718:	4c 89 f5             	mov    %r14,%rbp
  f5171b:	e9 65 fe ff ff       	jmpq   f51585 <term_drop+0xe5>
  f51720:	4a 8d 0c d7          	lea    (%rdi,%r10,8),%rcx
  f51724:	8b 01                	mov    (%rcx),%eax
  f51726:	8d 50 ff             	lea    -0x1(%rax),%edx
  f51729:	25 ff ff ff 00       	and    $0xffffff,%eax
  f5172e:	89 11                	mov    %edx,(%rcx)
  f51730:	83 f8 01             	cmp    $0x1,%eax
  f51733:	0f 85 d7 fd ff ff    	jne    f51510 <term_drop+0x70>
  f51739:	8b 01                	mov    (%rcx),%eax
  f5173b:	48 b8 00 00 00 00 00 	movabs $0x7fffff0000000000,%rax
  f51742:	ff ff 7f 
  f51745:	48 21 c5             	and    %rax,%rbp
  f51748:	48 8b 11             	mov    (%rcx),%rdx
  f5174b:	48 8b 06             	mov    (%rsi),%rax
  f5174e:	48 c1 ea 18          	shr    $0x18,%rdx
  f51752:	48 89 01             	mov    %rax,(%rcx)
  f51755:	48 8b 86 00 01 00 00 	mov    0x100(%rsi),%rax
  f5175c:	48 09 d5             	or     %rdx,%rbp
  f5175f:	8b 15 7f 5c 20 00    	mov    0x205c7f(%rip),%edx        # 11573e4 <KEEP_WORDS>
  f51765:	4c 89 16             	mov    %r10,(%rsi)
  f51768:	48 83 c0 01          	add    $0x1,%rax
  f5176c:	48 89 86 00 01 00 00 	mov    %rax,0x100(%rsi)
  f51773:	48 39 d0             	cmp    %rdx,%rax
  f51776:	0f 83 13 1c 4b ff    	jae    40338f <term_drop.cold+0x21>
  f5177c:	48 89 e9             	mov    %rbp,%rcx
  f5177f:	48 c1 e9 38          	shr    $0x38,%rcx
  f51783:	f6 c1 7e             	test   $0x7e,%cl
  f51786:	0f 84 84 fd ff ff    	je     f51510 <term_drop+0x70>
  f5178c:	4c 8b 1d 9d 5b 20 00 	mov    0x205b9d(%rip),%r11        # 1157330 <p111_program_active>
  f51793:	49 89 ea             	mov    %rbp,%r10
  f51796:	4d 21 e2             	and    %r12,%r10
  f51799:	49 8b 43 40          	mov    0x40(%r11),%rax
  f5179d:	48 83 c0 7f          	add    $0x7f,%rax
  f517a1:	48 83 e0 80          	and    $0xffffffffffffff80,%rax
  f517a5:	48 05 00 82 10 03    	add    $0x3108200,%rax
  f517ab:	4c 39 d0             	cmp    %r10,%rax
  f517ae:	0f 86 3d fe ff ff    	jbe    f515f1 <term_drop+0x151>
  f517b4:	e9 57 fd ff ff       	jmpq   f51510 <term_drop+0x70>
  f517b9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  f517c0:	48 89 e8             	mov    %rbp,%rax
  f517c3:	83 e0 1f             	and    $0x1f,%eax
  f517c6:	48 83 c8 40          	or     $0x40,%rax
  f517ca:	48 c1 e0 38          	shl    $0x38,%rax
  f517ce:	4c 09 d0             	or     %r10,%rax
  f517d1:	4a 8d 14 d7          	lea    (%rdi,%r10,8),%rdx
  f517d5:	4c 8b 32             	mov    (%rdx),%r14
  f517d8:	48 89 1a             	mov    %rbx,(%rdx)
  f517db:	48 89 c3             	mov    %rax,%rbx
  f517de:	e9 2d fd ff ff       	jmpq   f51510 <term_drop+0x70>
  f517e3:	39 c5                	cmp    %eax,%ebp
  f517e5:	0f 82 ad 00 00 00    	jb     f51898 <term_drop+0x3f8>
  f517eb:	0f 84 15 01 00 00    	je     f51906 <term_drop+0x466>
  f517f1:	83 c0 01             	add    $0x1,%eax
  f517f4:	39 c5                	cmp    %eax,%ebp
  f517f6:	0f 84 1f 01 00 00    	je     f5191b <term_drop+0x47b>
  f517fc:	49 bb 00 00 00 00 00 	movabs $0xffff000000000000,%r11
  f51803:	00 ff ff 
  f51806:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  f5180b:	e9 48 fe ff ff       	jmpq   f51658 <term_drop+0x1b8>
  f51810:	49 8b 83 80 00 00 00 	mov    0x80(%r11),%rax
  f51817:	0f b6 14 28          	movzbl (%rax,%rbp,1),%edx
  f5181b:	48 89 d0             	mov    %rdx,%rax
  f5181e:	48 c1 e0 30          	shl    $0x30,%rax
  f51822:	49 89 c3             	mov    %rax,%r11
  f51825:	83 fa 01             	cmp    $0x1,%edx
  f51828:	0f 87 2a fe ff ff    	ja     f51658 <term_drop+0x1b8>
  f5182e:	4c 89 d8             	mov    %r11,%rax
  f51831:	4c 09 d0             	or     %r10,%rax
  f51834:	eb 9b                	jmp    f517d1 <term_drop+0x331>
  f51836:	49 8b 43 68          	mov    0x68(%r11),%rax
  f5183a:	0f b6 14 28          	movzbl (%rax,%rbp,1),%edx
  f5183e:	48 89 d0             	mov    %rdx,%rax
  f51841:	48 c1 e0 30          	shl    $0x30,%rax
  f51845:	49 89 c3             	mov    %rax,%r11
  f51848:	48 83 f9 05          	cmp    $0x5,%rcx
  f5184c:	75 d7                	jne    f51825 <term_drop+0x385>
  f5184e:	83 c2 02             	add    $0x2,%edx
  f51851:	e9 02 fe ff ff       	jmpq   f51658 <term_drop+0x1b8>
  f51856:	48 c1 ed 28          	shr    $0x28,%rbp
  f5185a:	83 e5 1f             	and    $0x1f,%ebp
  f5185d:	75 50                	jne    f518af <term_drop+0x40f>
  f5185f:	48 89 f2             	mov    %rsi,%rdx
  f51862:	b8 01 00 00 00       	mov    $0x1,%eax
  f51867:	41 bb 00 01 00 00    	mov    $0x100,%r11d
  f5186d:	48 8b 0a             	mov    (%rdx),%rcx
  f51870:	4a 89 0c d7          	mov    %rcx,(%rdi,%r10,8)
  f51874:	4a 8d 0c 1e          	lea    (%rsi,%r11,1),%rcx
  f51878:	4c 89 12             	mov    %r10,(%rdx)
  f5187b:	8b 15 63 5b 20 00    	mov    0x205b63(%rip),%edx        # 11573e4 <KEEP_WORDS>
  f51881:	48 03 01             	add    (%rcx),%rax
  f51884:	48 89 01             	mov    %rax,(%rcx)
  f51887:	48 39 d0             	cmp    %rdx,%rax
  f5188a:	0f 82 80 fc ff ff    	jb     f51510 <term_drop+0x70>
  f51890:	e9 1a 1b 4b ff       	jmpq   4033af <term_drop.cold+0x41>
  f51895:	0f 1f 00             	nopl   (%rax)
  f51898:	49 8b 43 68          	mov    0x68(%r11),%rax
  f5189c:	0f b6 14 28          	movzbl (%rax,%rbp,1),%edx
  f518a0:	83 ea 01             	sub    $0x1,%edx
  f518a3:	49 89 d3             	mov    %rdx,%r11
  f518a6:	49 c1 e3 30          	shl    $0x30,%r11
  f518aa:	e9 76 ff ff ff       	jmpq   f51825 <term_drop+0x385>
  f518af:	8d 45 ff             	lea    -0x1(%rbp),%eax
  f518b2:	44 8d 5d 1f          	lea    0x1f(%rbp),%r11d
  f518b6:	48 89 c1             	mov    %rax,%rcx
  f518b9:	48 8d 14 c6          	lea    (%rsi,%rax,8),%rdx
  f518bd:	b8 01 00 00 00       	mov    $0x1,%eax
  f518c2:	49 c1 e3 03          	shl    $0x3,%r11
  f518c6:	48 d3 e0             	shl    %cl,%rax
  f518c9:	89 cd                	mov    %ecx,%ebp
  f518cb:	eb a0                	jmp    f5186d <term_drop+0x3cd>
  f518cd:	48 b8 00 00 00 00 00 	movabs $0x102000000000000,%rax
  f518d4:	00 02 01 
  f518d7:	48 83 f9 05          	cmp    $0x5,%rcx
  f518db:	0f 85 8e fd ff ff    	jne    f5166f <term_drop+0x1cf>
  f518e1:	49 bb 00 00 00 00 00 	movabs $0x2000000000000,%r11
  f518e8:	00 02 00 
  f518eb:	ba 04 00 00 00       	mov    $0x4,%edx
  f518f0:	e9 63 fd ff ff       	jmpq   f51658 <term_drop+0x1b8>
  f518f5:	48 83 f9 05          	cmp    $0x5,%rcx
  f518f9:	74 13                	je     f5190e <term_drop+0x46e>
  f518fb:	4c 89 d0             	mov    %r10,%rax
  f518fe:	4c 09 c8             	or     %r9,%rax
  f51901:	e9 cb fe ff ff       	jmpq   f517d1 <term_drop+0x331>
  f51906:	45 31 db             	xor    %r11d,%r11d
  f51909:	e9 20 ff ff ff       	jmpq   f5182e <term_drop+0x38e>
  f5190e:	4d 89 cb             	mov    %r9,%r11
  f51911:	ba 03 00 00 00       	mov    $0x3,%edx
  f51916:	e9 3d fd ff ff       	jmpq   f51658 <term_drop+0x1b8>
  f5191b:	4d 89 cb             	mov    %r9,%r11
  f5191e:	e9 0b ff ff ff       	jmpq   f5182e <term_drop+0x38e>

Disassembly of section .fini:
