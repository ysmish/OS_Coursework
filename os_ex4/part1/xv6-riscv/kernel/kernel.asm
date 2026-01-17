
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a1010113          	addi	sp,sp,-1520 # 80008a10 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000024:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000028:	2781                	sext.w	a5,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037961b          	slliw	a2,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	963a                	add	a2,a2,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f46b7          	lui	a3,0xf4
    80000040:	24068693          	addi	a3,a3,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9736                	add	a4,a4,a3
    80000046:	e218                	sd	a4,0(a2)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00279713          	slli	a4,a5,0x2
    8000004c:	973e                	add	a4,a4,a5
    8000004e:	070e                	slli	a4,a4,0x3
    80000050:	00009797          	auipc	a5,0x9
    80000054:	88078793          	addi	a5,a5,-1920 # 800088d0 <timer_scratch>
    80000058:	97ba                	add	a5,a5,a4
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef90                	sd	a2,24(a5)
  scratch[4] = interval;
    8000005c:	f394                	sd	a3,32(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	ece78793          	addi	a5,a5,-306 # 80005f30 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	60a2                	ld	ra,8(sp)
    80000088:	6402                	ld	s0,0(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc6bf>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	e6078793          	addi	a5,a5,-416 # 80000f0e <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	711d                	addi	sp,sp,-96
    80000104:	ec86                	sd	ra,88(sp)
    80000106:	e8a2                	sd	s0,80(sp)
    80000108:	e0ca                	sd	s2,64(sp)
    8000010a:	1080                	addi	s0,sp,96
  int i;

  for(i = 0; i < n; i++){
    8000010c:	04c05b63          	blez	a2,80000162 <consolewrite+0x60>
    80000110:	e4a6                	sd	s1,72(sp)
    80000112:	fc4e                	sd	s3,56(sp)
    80000114:	f852                	sd	s4,48(sp)
    80000116:	f456                	sd	s5,40(sp)
    80000118:	f05a                	sd	s6,32(sp)
    8000011a:	ec5e                	sd	s7,24(sp)
    8000011c:	8a2a                	mv	s4,a0
    8000011e:	84ae                	mv	s1,a1
    80000120:	89b2                	mv	s3,a2
    80000122:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000124:	faf40b93          	addi	s7,s0,-81
    80000128:	4b05                	li	s6,1
    8000012a:	5afd                	li	s5,-1
    8000012c:	86da                	mv	a3,s6
    8000012e:	8626                	mv	a2,s1
    80000130:	85d2                	mv	a1,s4
    80000132:	855e                	mv	a0,s7
    80000134:	00002097          	auipc	ra,0x2
    80000138:	568080e7          	jalr	1384(ra) # 8000269c <either_copyin>
    8000013c:	03550563          	beq	a0,s5,80000166 <consolewrite+0x64>
      break;
    uartputc(c);
    80000140:	faf44503          	lbu	a0,-81(s0)
    80000144:	00000097          	auipc	ra,0x0
    80000148:	7d8080e7          	jalr	2008(ra) # 8000091c <uartputc>
  for(i = 0; i < n; i++){
    8000014c:	2905                	addiw	s2,s2,1
    8000014e:	0485                	addi	s1,s1,1
    80000150:	fd299ee3          	bne	s3,s2,8000012c <consolewrite+0x2a>
    80000154:	64a6                	ld	s1,72(sp)
    80000156:	79e2                	ld	s3,56(sp)
    80000158:	7a42                	ld	s4,48(sp)
    8000015a:	7aa2                	ld	s5,40(sp)
    8000015c:	7b02                	ld	s6,32(sp)
    8000015e:	6be2                	ld	s7,24(sp)
    80000160:	a809                	j	80000172 <consolewrite+0x70>
    80000162:	4901                	li	s2,0
    80000164:	a039                	j	80000172 <consolewrite+0x70>
    80000166:	64a6                	ld	s1,72(sp)
    80000168:	79e2                	ld	s3,56(sp)
    8000016a:	7a42                	ld	s4,48(sp)
    8000016c:	7aa2                	ld	s5,40(sp)
    8000016e:	7b02                	ld	s6,32(sp)
    80000170:	6be2                	ld	s7,24(sp)
  }

  return i;
}
    80000172:	854a                	mv	a0,s2
    80000174:	60e6                	ld	ra,88(sp)
    80000176:	6446                	ld	s0,80(sp)
    80000178:	6906                	ld	s2,64(sp)
    8000017a:	6125                	addi	sp,sp,96
    8000017c:	8082                	ret

000000008000017e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000017e:	711d                	addi	sp,sp,-96
    80000180:	ec86                	sd	ra,88(sp)
    80000182:	e8a2                	sd	s0,80(sp)
    80000184:	e4a6                	sd	s1,72(sp)
    80000186:	e0ca                	sd	s2,64(sp)
    80000188:	fc4e                	sd	s3,56(sp)
    8000018a:	f852                	sd	s4,48(sp)
    8000018c:	f05a                	sd	s6,32(sp)
    8000018e:	ec5e                	sd	s7,24(sp)
    80000190:	1080                	addi	s0,sp,96
    80000192:	8b2a                	mv	s6,a0
    80000194:	8a2e                	mv	s4,a1
    80000196:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000198:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    8000019a:	00011517          	auipc	a0,0x11
    8000019e:	87650513          	addi	a0,a0,-1930 # 80010a10 <cons>
    800001a2:	00001097          	auipc	ra,0x1
    800001a6:	aba080e7          	jalr	-1350(ra) # 80000c5c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001aa:	00011497          	auipc	s1,0x11
    800001ae:	86648493          	addi	s1,s1,-1946 # 80010a10 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b2:	00011917          	auipc	s2,0x11
    800001b6:	8f690913          	addi	s2,s2,-1802 # 80010aa8 <cons+0x98>
  while(n > 0){
    800001ba:	0d305563          	blez	s3,80000284 <consoleread+0x106>
    while(cons.r == cons.w){
    800001be:	0984a783          	lw	a5,152(s1)
    800001c2:	09c4a703          	lw	a4,156(s1)
    800001c6:	0af71a63          	bne	a4,a5,8000027a <consoleread+0xfc>
      if(killed(myproc())){
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	940080e7          	jalr	-1728(ra) # 80001b0a <myproc>
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	31a080e7          	jalr	794(ra) # 800024ec <killed>
    800001da:	e52d                	bnez	a0,80000244 <consoleread+0xc6>
      sleep(&cons.r, &cons.lock);
    800001dc:	85a6                	mv	a1,s1
    800001de:	854a                	mv	a0,s2
    800001e0:	00002097          	auipc	ra,0x2
    800001e4:	03c080e7          	jalr	60(ra) # 8000221c <sleep>
    while(cons.r == cons.w){
    800001e8:	0984a783          	lw	a5,152(s1)
    800001ec:	09c4a703          	lw	a4,156(s1)
    800001f0:	fcf70de3          	beq	a4,a5,800001ca <consoleread+0x4c>
    800001f4:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001f6:	00011717          	auipc	a4,0x11
    800001fa:	81a70713          	addi	a4,a4,-2022 # 80010a10 <cons>
    800001fe:	0017869b          	addiw	a3,a5,1
    80000202:	08d72c23          	sw	a3,152(a4)
    80000206:	07f7f693          	andi	a3,a5,127
    8000020a:	9736                	add	a4,a4,a3
    8000020c:	01874703          	lbu	a4,24(a4)
    80000210:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    80000214:	4691                	li	a3,4
    80000216:	04da8a63          	beq	s5,a3,8000026a <consoleread+0xec>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000021a:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000021e:	4685                	li	a3,1
    80000220:	faf40613          	addi	a2,s0,-81
    80000224:	85d2                	mv	a1,s4
    80000226:	855a                	mv	a0,s6
    80000228:	00002097          	auipc	ra,0x2
    8000022c:	41e080e7          	jalr	1054(ra) # 80002646 <either_copyout>
    80000230:	57fd                	li	a5,-1
    80000232:	04f50863          	beq	a0,a5,80000282 <consoleread+0x104>
      break;

    dst++;
    80000236:	0a05                	addi	s4,s4,1
    --n;
    80000238:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000023a:	47a9                	li	a5,10
    8000023c:	04fa8f63          	beq	s5,a5,8000029a <consoleread+0x11c>
    80000240:	7aa2                	ld	s5,40(sp)
    80000242:	bfa5                	j	800001ba <consoleread+0x3c>
        release(&cons.lock);
    80000244:	00010517          	auipc	a0,0x10
    80000248:	7cc50513          	addi	a0,a0,1996 # 80010a10 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	ac0080e7          	jalr	-1344(ra) # 80000d0c <release>
        return -1;
    80000254:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000256:	60e6                	ld	ra,88(sp)
    80000258:	6446                	ld	s0,80(sp)
    8000025a:	64a6                	ld	s1,72(sp)
    8000025c:	6906                	ld	s2,64(sp)
    8000025e:	79e2                	ld	s3,56(sp)
    80000260:	7a42                	ld	s4,48(sp)
    80000262:	7b02                	ld	s6,32(sp)
    80000264:	6be2                	ld	s7,24(sp)
    80000266:	6125                	addi	sp,sp,96
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0179fa63          	bgeu	s3,s7,8000027e <consoleread+0x100>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	82f72d23          	sw	a5,-1990(a4) # 80010aa8 <cons+0x98>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	a031                	j	80000284 <consoleread+0x106>
    8000027a:	f456                	sd	s5,40(sp)
    8000027c:	bfad                	j	800001f6 <consoleread+0x78>
    8000027e:	7aa2                	ld	s5,40(sp)
    80000280:	a011                	j	80000284 <consoleread+0x106>
    80000282:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000284:	00010517          	auipc	a0,0x10
    80000288:	78c50513          	addi	a0,a0,1932 # 80010a10 <cons>
    8000028c:	00001097          	auipc	ra,0x1
    80000290:	a80080e7          	jalr	-1408(ra) # 80000d0c <release>
  return target - n;
    80000294:	413b853b          	subw	a0,s7,s3
    80000298:	bf7d                	j	80000256 <consoleread+0xd8>
    8000029a:	7aa2                	ld	s5,40(sp)
    8000029c:	b7e5                	j	80000284 <consoleread+0x106>

000000008000029e <consputc>:
{
    8000029e:	1141                	addi	sp,sp,-16
    800002a0:	e406                	sd	ra,8(sp)
    800002a2:	e022                	sd	s0,0(sp)
    800002a4:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800002a6:	10000793          	li	a5,256
    800002aa:	00f50a63          	beq	a0,a5,800002be <consputc+0x20>
    uartputc_sync(c);
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	590080e7          	jalr	1424(ra) # 8000083e <uartputc_sync>
}
    800002b6:	60a2                	ld	ra,8(sp)
    800002b8:	6402                	ld	s0,0(sp)
    800002ba:	0141                	addi	sp,sp,16
    800002bc:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002be:	4521                	li	a0,8
    800002c0:	00000097          	auipc	ra,0x0
    800002c4:	57e080e7          	jalr	1406(ra) # 8000083e <uartputc_sync>
    800002c8:	02000513          	li	a0,32
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	572080e7          	jalr	1394(ra) # 8000083e <uartputc_sync>
    800002d4:	4521                	li	a0,8
    800002d6:	00000097          	auipc	ra,0x0
    800002da:	568080e7          	jalr	1384(ra) # 8000083e <uartputc_sync>
    800002de:	bfe1                	j	800002b6 <consputc+0x18>

00000000800002e0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002e0:	1101                	addi	sp,sp,-32
    800002e2:	ec06                	sd	ra,24(sp)
    800002e4:	e822                	sd	s0,16(sp)
    800002e6:	e426                	sd	s1,8(sp)
    800002e8:	1000                	addi	s0,sp,32
    800002ea:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002ec:	00010517          	auipc	a0,0x10
    800002f0:	72450513          	addi	a0,a0,1828 # 80010a10 <cons>
    800002f4:	00001097          	auipc	ra,0x1
    800002f8:	968080e7          	jalr	-1688(ra) # 80000c5c <acquire>

  switch(c){
    800002fc:	47d5                	li	a5,21
    800002fe:	0af48363          	beq	s1,a5,800003a4 <consoleintr+0xc4>
    80000302:	0297c963          	blt	a5,s1,80000334 <consoleintr+0x54>
    80000306:	47a1                	li	a5,8
    80000308:	0ef48a63          	beq	s1,a5,800003fc <consoleintr+0x11c>
    8000030c:	47c1                	li	a5,16
    8000030e:	10f49d63          	bne	s1,a5,80000428 <consoleintr+0x148>
  case C('P'):  // Print process list.
    procdump();
    80000312:	00002097          	auipc	ra,0x2
    80000316:	3e0080e7          	jalr	992(ra) # 800026f2 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000031a:	00010517          	auipc	a0,0x10
    8000031e:	6f650513          	addi	a0,a0,1782 # 80010a10 <cons>
    80000322:	00001097          	auipc	ra,0x1
    80000326:	9ea080e7          	jalr	-1558(ra) # 80000d0c <release>
}
    8000032a:	60e2                	ld	ra,24(sp)
    8000032c:	6442                	ld	s0,16(sp)
    8000032e:	64a2                	ld	s1,8(sp)
    80000330:	6105                	addi	sp,sp,32
    80000332:	8082                	ret
  switch(c){
    80000334:	07f00793          	li	a5,127
    80000338:	0cf48263          	beq	s1,a5,800003fc <consoleintr+0x11c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000033c:	00010717          	auipc	a4,0x10
    80000340:	6d470713          	addi	a4,a4,1748 # 80010a10 <cons>
    80000344:	0a072783          	lw	a5,160(a4)
    80000348:	09872703          	lw	a4,152(a4)
    8000034c:	9f99                	subw	a5,a5,a4
    8000034e:	07f00713          	li	a4,127
    80000352:	fcf764e3          	bltu	a4,a5,8000031a <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    80000356:	47b5                	li	a5,13
    80000358:	0cf48b63          	beq	s1,a5,8000042e <consoleintr+0x14e>
      consputc(c);
    8000035c:	8526                	mv	a0,s1
    8000035e:	00000097          	auipc	ra,0x0
    80000362:	f40080e7          	jalr	-192(ra) # 8000029e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000366:	00010717          	auipc	a4,0x10
    8000036a:	6aa70713          	addi	a4,a4,1706 # 80010a10 <cons>
    8000036e:	0a072683          	lw	a3,160(a4)
    80000372:	0016879b          	addiw	a5,a3,1
    80000376:	863e                	mv	a2,a5
    80000378:	0af72023          	sw	a5,160(a4)
    8000037c:	07f6f693          	andi	a3,a3,127
    80000380:	9736                	add	a4,a4,a3
    80000382:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000386:	ff648713          	addi	a4,s1,-10
    8000038a:	cb61                	beqz	a4,8000045a <consoleintr+0x17a>
    8000038c:	14f1                	addi	s1,s1,-4
    8000038e:	c4f1                	beqz	s1,8000045a <consoleintr+0x17a>
    80000390:	00010717          	auipc	a4,0x10
    80000394:	71872703          	lw	a4,1816(a4) # 80010aa8 <cons+0x98>
    80000398:	9f99                	subw	a5,a5,a4
    8000039a:	08000713          	li	a4,128
    8000039e:	f6e79ee3          	bne	a5,a4,8000031a <consoleintr+0x3a>
    800003a2:	a865                	j	8000045a <consoleintr+0x17a>
    800003a4:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a6:	00010717          	auipc	a4,0x10
    800003aa:	66a70713          	addi	a4,a4,1642 # 80010a10 <cons>
    800003ae:	0a072783          	lw	a5,160(a4)
    800003b2:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b6:	00010497          	auipc	s1,0x10
    800003ba:	65a48493          	addi	s1,s1,1626 # 80010a10 <cons>
    while(cons.e != cons.w &&
    800003be:	4929                	li	s2,10
    800003c0:	02f70a63          	beq	a4,a5,800003f4 <consoleintr+0x114>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003c4:	37fd                	addiw	a5,a5,-1
    800003c6:	07f7f713          	andi	a4,a5,127
    800003ca:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003cc:	01874703          	lbu	a4,24(a4)
    800003d0:	03270463          	beq	a4,s2,800003f8 <consoleintr+0x118>
      cons.e--;
    800003d4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d8:	10000513          	li	a0,256
    800003dc:	00000097          	auipc	ra,0x0
    800003e0:	ec2080e7          	jalr	-318(ra) # 8000029e <consputc>
    while(cons.e != cons.w &&
    800003e4:	0a04a783          	lw	a5,160(s1)
    800003e8:	09c4a703          	lw	a4,156(s1)
    800003ec:	fcf71ce3          	bne	a4,a5,800003c4 <consoleintr+0xe4>
    800003f0:	6902                	ld	s2,0(sp)
    800003f2:	b725                	j	8000031a <consoleintr+0x3a>
    800003f4:	6902                	ld	s2,0(sp)
    800003f6:	b715                	j	8000031a <consoleintr+0x3a>
    800003f8:	6902                	ld	s2,0(sp)
    800003fa:	b705                	j	8000031a <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003fc:	00010717          	auipc	a4,0x10
    80000400:	61470713          	addi	a4,a4,1556 # 80010a10 <cons>
    80000404:	0a072783          	lw	a5,160(a4)
    80000408:	09c72703          	lw	a4,156(a4)
    8000040c:	f0f707e3          	beq	a4,a5,8000031a <consoleintr+0x3a>
      cons.e--;
    80000410:	37fd                	addiw	a5,a5,-1
    80000412:	00010717          	auipc	a4,0x10
    80000416:	68f72f23          	sw	a5,1694(a4) # 80010ab0 <cons+0xa0>
      consputc(BACKSPACE);
    8000041a:	10000513          	li	a0,256
    8000041e:	00000097          	auipc	ra,0x0
    80000422:	e80080e7          	jalr	-384(ra) # 8000029e <consputc>
    80000426:	bdd5                	j	8000031a <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000428:	ee0489e3          	beqz	s1,8000031a <consoleintr+0x3a>
    8000042c:	bf01                	j	8000033c <consoleintr+0x5c>
      consputc(c);
    8000042e:	4529                	li	a0,10
    80000430:	00000097          	auipc	ra,0x0
    80000434:	e6e080e7          	jalr	-402(ra) # 8000029e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000438:	00010797          	auipc	a5,0x10
    8000043c:	5d878793          	addi	a5,a5,1496 # 80010a10 <cons>
    80000440:	0a07a703          	lw	a4,160(a5)
    80000444:	0017069b          	addiw	a3,a4,1
    80000448:	8636                	mv	a2,a3
    8000044a:	0ad7a023          	sw	a3,160(a5)
    8000044e:	07f77713          	andi	a4,a4,127
    80000452:	97ba                	add	a5,a5,a4
    80000454:	4729                	li	a4,10
    80000456:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000045a:	00010797          	auipc	a5,0x10
    8000045e:	64c7a923          	sw	a2,1618(a5) # 80010aac <cons+0x9c>
        wakeup(&cons.r);
    80000462:	00010517          	auipc	a0,0x10
    80000466:	64650513          	addi	a0,a0,1606 # 80010aa8 <cons+0x98>
    8000046a:	00002097          	auipc	ra,0x2
    8000046e:	e16080e7          	jalr	-490(ra) # 80002280 <wakeup>
    80000472:	b565                	j	8000031a <consoleintr+0x3a>

0000000080000474 <consoleinit>:

void
consoleinit(void)
{
    80000474:	1141                	addi	sp,sp,-16
    80000476:	e406                	sd	ra,8(sp)
    80000478:	e022                	sd	s0,0(sp)
    8000047a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000047c:	00008597          	auipc	a1,0x8
    80000480:	b8458593          	addi	a1,a1,-1148 # 80008000 <etext>
    80000484:	00010517          	auipc	a0,0x10
    80000488:	58c50513          	addi	a0,a0,1420 # 80010a10 <cons>
    8000048c:	00000097          	auipc	ra,0x0
    80000490:	736080e7          	jalr	1846(ra) # 80000bc2 <initlock>

  uartinit();
    80000494:	00000097          	auipc	ra,0x0
    80000498:	350080e7          	jalr	848(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000049c:	00021797          	auipc	a5,0x21
    800004a0:	b0c78793          	addi	a5,a5,-1268 # 80020fa8 <devsw>
    800004a4:	00000717          	auipc	a4,0x0
    800004a8:	cda70713          	addi	a4,a4,-806 # 8000017e <consoleread>
    800004ac:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004ae:	00000717          	auipc	a4,0x0
    800004b2:	c5470713          	addi	a4,a4,-940 # 80000102 <consolewrite>
    800004b6:	ef98                	sd	a4,24(a5)
}
    800004b8:	60a2                	ld	ra,8(sp)
    800004ba:	6402                	ld	s0,0(sp)
    800004bc:	0141                	addi	sp,sp,16
    800004be:	8082                	ret

00000000800004c0 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004c0:	7179                	addi	sp,sp,-48
    800004c2:	f406                	sd	ra,40(sp)
    800004c4:	f022                	sd	s0,32(sp)
    800004c6:	e84a                	sd	s2,16(sp)
    800004c8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ca:	c219                	beqz	a2,800004d0 <printint+0x10>
    800004cc:	08054563          	bltz	a0,80000556 <printint+0x96>
    x = -xx;
  else
    x = xx;
    800004d0:	4301                	li	t1,0

  i = 0;
    800004d2:	fd040913          	addi	s2,s0,-48
    x = xx;
    800004d6:	86ca                	mv	a3,s2
  i = 0;
    800004d8:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004da:	00008817          	auipc	a6,0x8
    800004de:	24e80813          	addi	a6,a6,590 # 80008728 <digits>
    800004e2:	88ba                	mv	a7,a4
    800004e4:	0017061b          	addiw	a2,a4,1
    800004e8:	8732                	mv	a4,a2
    800004ea:	02b577bb          	remuw	a5,a0,a1
    800004ee:	1782                	slli	a5,a5,0x20
    800004f0:	9381                	srli	a5,a5,0x20
    800004f2:	97c2                	add	a5,a5,a6
    800004f4:	0007c783          	lbu	a5,0(a5)
    800004f8:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004fc:	87aa                	mv	a5,a0
    800004fe:	02b5553b          	divuw	a0,a0,a1
    80000502:	0685                	addi	a3,a3,1
    80000504:	fcb7ffe3          	bgeu	a5,a1,800004e2 <printint+0x22>

  if(sign)
    80000508:	00030c63          	beqz	t1,80000520 <printint+0x60>
    buf[i++] = '-';
    8000050c:	fe060793          	addi	a5,a2,-32
    80000510:	00878633          	add	a2,a5,s0
    80000514:	02d00793          	li	a5,45
    80000518:	fef60823          	sb	a5,-16(a2)
    8000051c:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    80000520:	02e05663          	blez	a4,8000054c <printint+0x8c>
    80000524:	ec26                	sd	s1,24(sp)
    80000526:	377d                	addiw	a4,a4,-1
    80000528:	00e904b3          	add	s1,s2,a4
    8000052c:	197d                	addi	s2,s2,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	1702                	slli	a4,a4,0x20
    80000532:	9301                	srli	a4,a4,0x20
    80000534:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000538:	0004c503          	lbu	a0,0(s1)
    8000053c:	00000097          	auipc	ra,0x0
    80000540:	d62080e7          	jalr	-670(ra) # 8000029e <consputc>
  while(--i >= 0)
    80000544:	14fd                	addi	s1,s1,-1
    80000546:	ff2499e3          	bne	s1,s2,80000538 <printint+0x78>
    8000054a:	64e2                	ld	s1,24(sp)
}
    8000054c:	70a2                	ld	ra,40(sp)
    8000054e:	7402                	ld	s0,32(sp)
    80000550:	6942                	ld	s2,16(sp)
    80000552:	6145                	addi	sp,sp,48
    80000554:	8082                	ret
    x = -xx;
    80000556:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055a:	4305                	li	t1,1
    x = -xx;
    8000055c:	bf9d                	j	800004d2 <printint+0x12>

000000008000055e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000055e:	1101                	addi	sp,sp,-32
    80000560:	ec06                	sd	ra,24(sp)
    80000562:	e822                	sd	s0,16(sp)
    80000564:	e426                	sd	s1,8(sp)
    80000566:	1000                	addi	s0,sp,32
    80000568:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056a:	00010797          	auipc	a5,0x10
    8000056e:	5607a323          	sw	zero,1382(a5) # 80010ad0 <pr+0x18>
  printf("panic: ");
    80000572:	00008517          	auipc	a0,0x8
    80000576:	a9650513          	addi	a0,a0,-1386 # 80008008 <etext+0x8>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	02e080e7          	jalr	46(ra) # 800005a8 <printf>
  printf(s);
    80000582:	8526                	mv	a0,s1
    80000584:	00000097          	auipc	ra,0x0
    80000588:	024080e7          	jalr	36(ra) # 800005a8 <printf>
  printf("\n");
    8000058c:	00008517          	auipc	a0,0x8
    80000590:	a8450513          	addi	a0,a0,-1404 # 80008010 <etext+0x10>
    80000594:	00000097          	auipc	ra,0x0
    80000598:	014080e7          	jalr	20(ra) # 800005a8 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059c:	4785                	li	a5,1
    8000059e:	00008717          	auipc	a4,0x8
    800005a2:	2ef72923          	sw	a5,754(a4) # 80008890 <panicked>
  for(;;)
    800005a6:	a001                	j	800005a6 <panic+0x48>

00000000800005a8 <printf>:
{
    800005a8:	7131                	addi	sp,sp,-192
    800005aa:	fc86                	sd	ra,120(sp)
    800005ac:	f8a2                	sd	s0,112(sp)
    800005ae:	e8d2                	sd	s4,80(sp)
    800005b0:	ec6e                	sd	s11,24(sp)
    800005b2:	0100                	addi	s0,sp,128
    800005b4:	8a2a                	mv	s4,a0
    800005b6:	e40c                	sd	a1,8(s0)
    800005b8:	e810                	sd	a2,16(s0)
    800005ba:	ec14                	sd	a3,24(s0)
    800005bc:	f018                	sd	a4,32(s0)
    800005be:	f41c                	sd	a5,40(s0)
    800005c0:	03043823          	sd	a6,48(s0)
    800005c4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c8:	00010d97          	auipc	s11,0x10
    800005cc:	508dad83          	lw	s11,1288(s11) # 80010ad0 <pr+0x18>
  if(locking)
    800005d0:	040d9463          	bnez	s11,80000618 <printf+0x70>
  if (fmt == 0)
    800005d4:	040a0b63          	beqz	s4,8000062a <printf+0x82>
  va_start(ap, fmt);
    800005d8:	00840793          	addi	a5,s0,8
    800005dc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e0:	000a4503          	lbu	a0,0(s4)
    800005e4:	18050c63          	beqz	a0,8000077c <printf+0x1d4>
    800005e8:	f4a6                	sd	s1,104(sp)
    800005ea:	f0ca                	sd	s2,96(sp)
    800005ec:	ecce                	sd	s3,88(sp)
    800005ee:	e4d6                	sd	s5,72(sp)
    800005f0:	e0da                	sd	s6,64(sp)
    800005f2:	fc5e                	sd	s7,56(sp)
    800005f4:	f862                	sd	s8,48(sp)
    800005f6:	f466                	sd	s9,40(sp)
    800005f8:	f06a                	sd	s10,32(sp)
    800005fa:	4981                	li	s3,0
    if(c != '%'){
    800005fc:	02500b13          	li	s6,37
    switch(c){
    80000600:	07000b93          	li	s7,112
  consputc('x');
    80000604:	07800c93          	li	s9,120
    80000608:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000060a:	00008a97          	auipc	s5,0x8
    8000060e:	11ea8a93          	addi	s5,s5,286 # 80008728 <digits>
    switch(c){
    80000612:	07300c13          	li	s8,115
    80000616:	a0b9                	j	80000664 <printf+0xbc>
    acquire(&pr.lock);
    80000618:	00010517          	auipc	a0,0x10
    8000061c:	4a050513          	addi	a0,a0,1184 # 80010ab8 <pr>
    80000620:	00000097          	auipc	ra,0x0
    80000624:	63c080e7          	jalr	1596(ra) # 80000c5c <acquire>
    80000628:	b775                	j	800005d4 <printf+0x2c>
    8000062a:	f4a6                	sd	s1,104(sp)
    8000062c:	f0ca                	sd	s2,96(sp)
    8000062e:	ecce                	sd	s3,88(sp)
    80000630:	e4d6                	sd	s5,72(sp)
    80000632:	e0da                	sd	s6,64(sp)
    80000634:	fc5e                	sd	s7,56(sp)
    80000636:	f862                	sd	s8,48(sp)
    80000638:	f466                	sd	s9,40(sp)
    8000063a:	f06a                	sd	s10,32(sp)
    panic("null fmt");
    8000063c:	00008517          	auipc	a0,0x8
    80000640:	9e450513          	addi	a0,a0,-1564 # 80008020 <etext+0x20>
    80000644:	00000097          	auipc	ra,0x0
    80000648:	f1a080e7          	jalr	-230(ra) # 8000055e <panic>
      consputc(c);
    8000064c:	00000097          	auipc	ra,0x0
    80000650:	c52080e7          	jalr	-942(ra) # 8000029e <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000654:	0019879b          	addiw	a5,s3,1
    80000658:	89be                	mv	s3,a5
    8000065a:	97d2                	add	a5,a5,s4
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050563          	beqz	a0,8000076a <printf+0x1c2>
    if(c != '%'){
    80000664:	ff6514e3          	bne	a0,s6,8000064c <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000668:	0019879b          	addiw	a5,s3,1
    8000066c:	89be                	mv	s3,a5
    8000066e:	97d2                	add	a5,a5,s4
    80000670:	0007c783          	lbu	a5,0(a5)
    80000674:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000678:	10078a63          	beqz	a5,8000078c <printf+0x1e4>
    switch(c){
    8000067c:	05778a63          	beq	a5,s7,800006d0 <printf+0x128>
    80000680:	02fbf463          	bgeu	s7,a5,800006a8 <printf+0x100>
    80000684:	09878763          	beq	a5,s8,80000712 <printf+0x16a>
    80000688:	0d979663          	bne	a5,s9,80000754 <printf+0x1ac>
      printint(va_arg(ap, int), 16, 1);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4605                	li	a2,1
    8000069a:	85ea                	mv	a1,s10
    8000069c:	4388                	lw	a0,0(a5)
    8000069e:	00000097          	auipc	ra,0x0
    800006a2:	e22080e7          	jalr	-478(ra) # 800004c0 <printint>
      break;
    800006a6:	b77d                	j	80000654 <printf+0xac>
    switch(c){
    800006a8:	0b678063          	beq	a5,s6,80000748 <printf+0x1a0>
    800006ac:	06400713          	li	a4,100
    800006b0:	0ae79263          	bne	a5,a4,80000754 <printf+0x1ac>
      printint(va_arg(ap, int), 10, 1);
    800006b4:	f8843783          	ld	a5,-120(s0)
    800006b8:	00878713          	addi	a4,a5,8
    800006bc:	f8e43423          	sd	a4,-120(s0)
    800006c0:	4605                	li	a2,1
    800006c2:	45a9                	li	a1,10
    800006c4:	4388                	lw	a0,0(a5)
    800006c6:	00000097          	auipc	ra,0x0
    800006ca:	dfa080e7          	jalr	-518(ra) # 800004c0 <printint>
      break;
    800006ce:	b759                	j	80000654 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006d0:	f8843783          	ld	a5,-120(s0)
    800006d4:	00878713          	addi	a4,a5,8
    800006d8:	f8e43423          	sd	a4,-120(s0)
    800006dc:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006e0:	03000513          	li	a0,48
    800006e4:	00000097          	auipc	ra,0x0
    800006e8:	bba080e7          	jalr	-1094(ra) # 8000029e <consputc>
  consputc('x');
    800006ec:	8566                	mv	a0,s9
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	bb0080e7          	jalr	-1104(ra) # 8000029e <consputc>
    800006f6:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c95793          	srli	a5,s2,0x3c
    800006fc:	97d6                	add	a5,a5,s5
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b9c080e7          	jalr	-1124(ra) # 8000029e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0912                	slli	s2,s2,0x4
    8000070c:	34fd                	addiw	s1,s1,-1
    8000070e:	f4ed                	bnez	s1,800006f8 <printf+0x150>
    80000710:	b791                	j	80000654 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000712:	f8843783          	ld	a5,-120(s0)
    80000716:	00878713          	addi	a4,a5,8
    8000071a:	f8e43423          	sd	a4,-120(s0)
    8000071e:	6384                	ld	s1,0(a5)
    80000720:	cc89                	beqz	s1,8000073a <printf+0x192>
      for(; *s; s++)
    80000722:	0004c503          	lbu	a0,0(s1)
    80000726:	d51d                	beqz	a0,80000654 <printf+0xac>
        consputc(*s);
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b76080e7          	jalr	-1162(ra) # 8000029e <consputc>
      for(; *s; s++)
    80000730:	0485                	addi	s1,s1,1
    80000732:	0004c503          	lbu	a0,0(s1)
    80000736:	f96d                	bnez	a0,80000728 <printf+0x180>
    80000738:	bf31                	j	80000654 <printf+0xac>
        s = "(null)";
    8000073a:	00008497          	auipc	s1,0x8
    8000073e:	8de48493          	addi	s1,s1,-1826 # 80008018 <etext+0x18>
      for(; *s; s++)
    80000742:	02800513          	li	a0,40
    80000746:	b7cd                	j	80000728 <printf+0x180>
      consputc('%');
    80000748:	855a                	mv	a0,s6
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	b54080e7          	jalr	-1196(ra) # 8000029e <consputc>
      break;
    80000752:	b709                	j	80000654 <printf+0xac>
      consputc('%');
    80000754:	855a                	mv	a0,s6
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	b48080e7          	jalr	-1208(ra) # 8000029e <consputc>
      consputc(c);
    8000075e:	8526                	mv	a0,s1
    80000760:	00000097          	auipc	ra,0x0
    80000764:	b3e080e7          	jalr	-1218(ra) # 8000029e <consputc>
      break;
    80000768:	b5f5                	j	80000654 <printf+0xac>
    8000076a:	74a6                	ld	s1,104(sp)
    8000076c:	7906                	ld	s2,96(sp)
    8000076e:	69e6                	ld	s3,88(sp)
    80000770:	6aa6                	ld	s5,72(sp)
    80000772:	6b06                	ld	s6,64(sp)
    80000774:	7be2                	ld	s7,56(sp)
    80000776:	7c42                	ld	s8,48(sp)
    80000778:	7ca2                	ld	s9,40(sp)
    8000077a:	7d02                	ld	s10,32(sp)
  if(locking)
    8000077c:	020d9263          	bnez	s11,800007a0 <printf+0x1f8>
}
    80000780:	70e6                	ld	ra,120(sp)
    80000782:	7446                	ld	s0,112(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	6de2                	ld	s11,24(sp)
    80000788:	6129                	addi	sp,sp,192
    8000078a:	8082                	ret
    8000078c:	74a6                	ld	s1,104(sp)
    8000078e:	7906                	ld	s2,96(sp)
    80000790:	69e6                	ld	s3,88(sp)
    80000792:	6aa6                	ld	s5,72(sp)
    80000794:	6b06                	ld	s6,64(sp)
    80000796:	7be2                	ld	s7,56(sp)
    80000798:	7c42                	ld	s8,48(sp)
    8000079a:	7ca2                	ld	s9,40(sp)
    8000079c:	7d02                	ld	s10,32(sp)
    8000079e:	bff9                	j	8000077c <printf+0x1d4>
    release(&pr.lock);
    800007a0:	00010517          	auipc	a0,0x10
    800007a4:	31850513          	addi	a0,a0,792 # 80010ab8 <pr>
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	564080e7          	jalr	1380(ra) # 80000d0c <release>
}
    800007b0:	bfc1                	j	80000780 <printf+0x1d8>

00000000800007b2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b2:	1141                	addi	sp,sp,-16
    800007b4:	e406                	sd	ra,8(sp)
    800007b6:	e022                	sd	s0,0(sp)
    800007b8:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    800007ba:	00008597          	auipc	a1,0x8
    800007be:	87658593          	addi	a1,a1,-1930 # 80008030 <etext+0x30>
    800007c2:	00010517          	auipc	a0,0x10
    800007c6:	2f650513          	addi	a0,a0,758 # 80010ab8 <pr>
    800007ca:	00000097          	auipc	ra,0x0
    800007ce:	3f8080e7          	jalr	1016(ra) # 80000bc2 <initlock>
  pr.locking = 1;
    800007d2:	4785                	li	a5,1
    800007d4:	00010717          	auipc	a4,0x10
    800007d8:	2ef72e23          	sw	a5,764(a4) # 80010ad0 <pr+0x18>
}
    800007dc:	60a2                	ld	ra,8(sp)
    800007de:	6402                	ld	s0,0(sp)
    800007e0:	0141                	addi	sp,sp,16
    800007e2:	8082                	ret

00000000800007e4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e4:	1141                	addi	sp,sp,-16
    800007e6:	e406                	sd	ra,8(sp)
    800007e8:	e022                	sd	s0,0(sp)
    800007ea:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ec:	100007b7          	lui	a5,0x10000
    800007f0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f4:	10000737          	lui	a4,0x10000
    800007f8:	f8000693          	li	a3,-128
    800007fc:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	468d                	li	a3,3
    80000802:	10000637          	lui	a2,0x10000
    80000806:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080e:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000812:	8732                	mv	a4,a2
    80000814:	461d                	li	a2,7
    80000816:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081a:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000081e:	00008597          	auipc	a1,0x8
    80000822:	81a58593          	addi	a1,a1,-2022 # 80008038 <etext+0x38>
    80000826:	00010517          	auipc	a0,0x10
    8000082a:	2b250513          	addi	a0,a0,690 # 80010ad8 <uart_tx_lock>
    8000082e:	00000097          	auipc	ra,0x0
    80000832:	394080e7          	jalr	916(ra) # 80000bc2 <initlock>
}
    80000836:	60a2                	ld	ra,8(sp)
    80000838:	6402                	ld	s0,0(sp)
    8000083a:	0141                	addi	sp,sp,16
    8000083c:	8082                	ret

000000008000083e <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000083e:	1101                	addi	sp,sp,-32
    80000840:	ec06                	sd	ra,24(sp)
    80000842:	e822                	sd	s0,16(sp)
    80000844:	e426                	sd	s1,8(sp)
    80000846:	1000                	addi	s0,sp,32
    80000848:	84aa                	mv	s1,a0
  push_off();
    8000084a:	00000097          	auipc	ra,0x0
    8000084e:	3c2080e7          	jalr	962(ra) # 80000c0c <push_off>

  if(panicked){
    80000852:	00008797          	auipc	a5,0x8
    80000856:	03e7a783          	lw	a5,62(a5) # 80008890 <panicked>
    8000085a:	eb85                	bnez	a5,8000088a <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085c:	10000737          	lui	a4,0x10000
    80000860:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000862:	00074783          	lbu	a5,0(a4)
    80000866:	0207f793          	andi	a5,a5,32
    8000086a:	dfe5                	beqz	a5,80000862 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086c:	0ff4f513          	zext.b	a0,s1
    80000870:	100007b7          	lui	a5,0x10000
    80000874:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000878:	00000097          	auipc	ra,0x0
    8000087c:	438080e7          	jalr	1080(ra) # 80000cb0 <pop_off>
}
    80000880:	60e2                	ld	ra,24(sp)
    80000882:	6442                	ld	s0,16(sp)
    80000884:	64a2                	ld	s1,8(sp)
    80000886:	6105                	addi	sp,sp,32
    80000888:	8082                	ret
    for(;;)
    8000088a:	a001                	j	8000088a <uartputc_sync+0x4c>

000000008000088c <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088c:	00008797          	auipc	a5,0x8
    80000890:	00c7b783          	ld	a5,12(a5) # 80008898 <uart_tx_r>
    80000894:	00008717          	auipc	a4,0x8
    80000898:	00c73703          	ld	a4,12(a4) # 800088a0 <uart_tx_w>
    8000089c:	06f70f63          	beq	a4,a5,8000091a <uartstart+0x8e>
{
    800008a0:	7139                	addi	sp,sp,-64
    800008a2:	fc06                	sd	ra,56(sp)
    800008a4:	f822                	sd	s0,48(sp)
    800008a6:	f426                	sd	s1,40(sp)
    800008a8:	f04a                	sd	s2,32(sp)
    800008aa:	ec4e                	sd	s3,24(sp)
    800008ac:	e852                	sd	s4,16(sp)
    800008ae:	e456                	sd	s5,8(sp)
    800008b0:	e05a                	sd	s6,0(sp)
    800008b2:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b4:	10000937          	lui	s2,0x10000
    800008b8:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ba:	00010a97          	auipc	s5,0x10
    800008be:	21ea8a93          	addi	s5,s5,542 # 80010ad8 <uart_tx_lock>
    uart_tx_r += 1;
    800008c2:	00008497          	auipc	s1,0x8
    800008c6:	fd648493          	addi	s1,s1,-42 # 80008898 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008ca:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008ce:	00008997          	auipc	s3,0x8
    800008d2:	fd298993          	addi	s3,s3,-46 # 800088a0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d6:	00094703          	lbu	a4,0(s2)
    800008da:	02077713          	andi	a4,a4,32
    800008de:	c705                	beqz	a4,80000906 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e0:	01f7f713          	andi	a4,a5,31
    800008e4:	9756                	add	a4,a4,s5
    800008e6:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ea:	0785                	addi	a5,a5,1
    800008ec:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008ee:	8526                	mv	a0,s1
    800008f0:	00002097          	auipc	ra,0x2
    800008f4:	990080e7          	jalr	-1648(ra) # 80002280 <wakeup>
    WriteReg(THR, c);
    800008f8:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fc:	609c                	ld	a5,0(s1)
    800008fe:	0009b703          	ld	a4,0(s3)
    80000902:	fcf71ae3          	bne	a4,a5,800008d6 <uartstart+0x4a>
  }
}
    80000906:	70e2                	ld	ra,56(sp)
    80000908:	7442                	ld	s0,48(sp)
    8000090a:	74a2                	ld	s1,40(sp)
    8000090c:	7902                	ld	s2,32(sp)
    8000090e:	69e2                	ld	s3,24(sp)
    80000910:	6a42                	ld	s4,16(sp)
    80000912:	6aa2                	ld	s5,8(sp)
    80000914:	6b02                	ld	s6,0(sp)
    80000916:	6121                	addi	sp,sp,64
    80000918:	8082                	ret
    8000091a:	8082                	ret

000000008000091c <uartputc>:
{
    8000091c:	7179                	addi	sp,sp,-48
    8000091e:	f406                	sd	ra,40(sp)
    80000920:	f022                	sd	s0,32(sp)
    80000922:	ec26                	sd	s1,24(sp)
    80000924:	e84a                	sd	s2,16(sp)
    80000926:	e44e                	sd	s3,8(sp)
    80000928:	e052                	sd	s4,0(sp)
    8000092a:	1800                	addi	s0,sp,48
    8000092c:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000092e:	00010517          	auipc	a0,0x10
    80000932:	1aa50513          	addi	a0,a0,426 # 80010ad8 <uart_tx_lock>
    80000936:	00000097          	auipc	ra,0x0
    8000093a:	326080e7          	jalr	806(ra) # 80000c5c <acquire>
  if(panicked){
    8000093e:	00008797          	auipc	a5,0x8
    80000942:	f527a783          	lw	a5,-174(a5) # 80008890 <panicked>
    80000946:	ebc1                	bnez	a5,800009d6 <uartputc+0xba>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000948:	00008717          	auipc	a4,0x8
    8000094c:	f5873703          	ld	a4,-168(a4) # 800088a0 <uart_tx_w>
    80000950:	00008797          	auipc	a5,0x8
    80000954:	f487b783          	ld	a5,-184(a5) # 80008898 <uart_tx_r>
    80000958:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095c:	00010997          	auipc	s3,0x10
    80000960:	17c98993          	addi	s3,s3,380 # 80010ad8 <uart_tx_lock>
    80000964:	00008497          	auipc	s1,0x8
    80000968:	f3448493          	addi	s1,s1,-204 # 80008898 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096c:	00008917          	auipc	s2,0x8
    80000970:	f3490913          	addi	s2,s2,-204 # 800088a0 <uart_tx_w>
    80000974:	00e79f63          	bne	a5,a4,80000992 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000978:	85ce                	mv	a1,s3
    8000097a:	8526                	mv	a0,s1
    8000097c:	00002097          	auipc	ra,0x2
    80000980:	8a0080e7          	jalr	-1888(ra) # 8000221c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000984:	00093703          	ld	a4,0(s2)
    80000988:	609c                	ld	a5,0(s1)
    8000098a:	02078793          	addi	a5,a5,32
    8000098e:	fee785e3          	beq	a5,a4,80000978 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000992:	01f77693          	andi	a3,a4,31
    80000996:	00010797          	auipc	a5,0x10
    8000099a:	14278793          	addi	a5,a5,322 # 80010ad8 <uart_tx_lock>
    8000099e:	97b6                	add	a5,a5,a3
    800009a0:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a4:	0705                	addi	a4,a4,1
    800009a6:	00008797          	auipc	a5,0x8
    800009aa:	eee7bd23          	sd	a4,-262(a5) # 800088a0 <uart_tx_w>
  uartstart();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	ede080e7          	jalr	-290(ra) # 8000088c <uartstart>
  release(&uart_tx_lock);
    800009b6:	00010517          	auipc	a0,0x10
    800009ba:	12250513          	addi	a0,a0,290 # 80010ad8 <uart_tx_lock>
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	34e080e7          	jalr	846(ra) # 80000d0c <release>
}
    800009c6:	70a2                	ld	ra,40(sp)
    800009c8:	7402                	ld	s0,32(sp)
    800009ca:	64e2                	ld	s1,24(sp)
    800009cc:	6942                	ld	s2,16(sp)
    800009ce:	69a2                	ld	s3,8(sp)
    800009d0:	6a02                	ld	s4,0(sp)
    800009d2:	6145                	addi	sp,sp,48
    800009d4:	8082                	ret
    for(;;)
    800009d6:	a001                	j	800009d6 <uartputc+0xba>

00000000800009d8 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d8:	1141                	addi	sp,sp,-16
    800009da:	e406                	sd	ra,8(sp)
    800009dc:	e022                	sd	s0,0(sp)
    800009de:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009e8:	8b85                	andi	a5,a5,1
    800009ea:	cb89                	beqz	a5,800009fc <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f4:	60a2                	ld	ra,8(sp)
    800009f6:	6402                	ld	s0,0(sp)
    800009f8:	0141                	addi	sp,sp,16
    800009fa:	8082                	ret
    return -1;
    800009fc:	557d                	li	a0,-1
    800009fe:	bfdd                	j	800009f4 <uartgetc+0x1c>

0000000080000a00 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a00:	1101                	addi	sp,sp,-32
    80000a02:	ec06                	sd	ra,24(sp)
    80000a04:	e822                	sd	s0,16(sp)
    80000a06:	e426                	sd	s1,8(sp)
    80000a08:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a0a:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a0c:	00000097          	auipc	ra,0x0
    80000a10:	fcc080e7          	jalr	-52(ra) # 800009d8 <uartgetc>
    if(c == -1)
    80000a14:	00950763          	beq	a0,s1,80000a22 <uartintr+0x22>
      break;
    consoleintr(c);
    80000a18:	00000097          	auipc	ra,0x0
    80000a1c:	8c8080e7          	jalr	-1848(ra) # 800002e0 <consoleintr>
  while(1){
    80000a20:	b7f5                	j	80000a0c <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a22:	00010517          	auipc	a0,0x10
    80000a26:	0b650513          	addi	a0,a0,182 # 80010ad8 <uart_tx_lock>
    80000a2a:	00000097          	auipc	ra,0x0
    80000a2e:	232080e7          	jalr	562(ra) # 80000c5c <acquire>
  uartstart();
    80000a32:	00000097          	auipc	ra,0x0
    80000a36:	e5a080e7          	jalr	-422(ra) # 8000088c <uartstart>
  release(&uart_tx_lock);
    80000a3a:	00010517          	auipc	a0,0x10
    80000a3e:	09e50513          	addi	a0,a0,158 # 80010ad8 <uart_tx_lock>
    80000a42:	00000097          	auipc	ra,0x0
    80000a46:	2ca080e7          	jalr	714(ra) # 80000d0c <release>
}
    80000a4a:	60e2                	ld	ra,24(sp)
    80000a4c:	6442                	ld	s0,16(sp)
    80000a4e:	64a2                	ld	s1,8(sp)
    80000a50:	6105                	addi	sp,sp,32
    80000a52:	8082                	ret

0000000080000a54 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a54:	1101                	addi	sp,sp,-32
    80000a56:	ec06                	sd	ra,24(sp)
    80000a58:	e822                	sd	s0,16(sp)
    80000a5a:	e426                	sd	s1,8(sp)
    80000a5c:	e04a                	sd	s2,0(sp)
    80000a5e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a60:	00021797          	auipc	a5,0x21
    80000a64:	6e078793          	addi	a5,a5,1760 # 80022140 <end>
    80000a68:	00f53733          	sltu	a4,a0,a5
    80000a6c:	47c5                	li	a5,17
    80000a6e:	07ee                	slli	a5,a5,0x1b
    80000a70:	17fd                	addi	a5,a5,-1
    80000a72:	00a7b7b3          	sltu	a5,a5,a0
    80000a76:	8fd9                	or	a5,a5,a4
    80000a78:	e7a1                	bnez	a5,80000ac0 <kfree+0x6c>
    80000a7a:	84aa                	mv	s1,a0
    80000a7c:	03451793          	slli	a5,a0,0x34
    80000a80:	e3a1                	bnez	a5,80000ac0 <kfree+0x6c>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a82:	6605                	lui	a2,0x1
    80000a84:	4585                	li	a1,1
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	2ce080e7          	jalr	718(ra) # 80000d54 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a8e:	00010917          	auipc	s2,0x10
    80000a92:	08290913          	addi	s2,s2,130 # 80010b10 <kmem>
    80000a96:	854a                	mv	a0,s2
    80000a98:	00000097          	auipc	ra,0x0
    80000a9c:	1c4080e7          	jalr	452(ra) # 80000c5c <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	00000097          	auipc	ra,0x0
    80000ab0:	260080e7          	jalr	608(ra) # 80000d0c <release>
}
    80000ab4:	60e2                	ld	ra,24(sp)
    80000ab6:	6442                	ld	s0,16(sp)
    80000ab8:	64a2                	ld	s1,8(sp)
    80000aba:	6902                	ld	s2,0(sp)
    80000abc:	6105                	addi	sp,sp,32
    80000abe:	8082                	ret
    panic("kfree");
    80000ac0:	00007517          	auipc	a0,0x7
    80000ac4:	58050513          	addi	a0,a0,1408 # 80008040 <etext+0x40>
    80000ac8:	00000097          	auipc	ra,0x0
    80000acc:	a96080e7          	jalr	-1386(ra) # 8000055e <panic>

0000000080000ad0 <freerange>:
{
    80000ad0:	7179                	addi	sp,sp,-48
    80000ad2:	f406                	sd	ra,40(sp)
    80000ad4:	f022                	sd	s0,32(sp)
    80000ad6:	ec26                	sd	s1,24(sp)
    80000ad8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ada:	6785                	lui	a5,0x1
    80000adc:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ae0:	00e504b3          	add	s1,a0,a4
    80000ae4:	777d                	lui	a4,0xfffff
    80000ae6:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae8:	94be                	add	s1,s1,a5
    80000aea:	0295e463          	bltu	a1,s1,80000b12 <freerange+0x42>
    80000aee:	e84a                	sd	s2,16(sp)
    80000af0:	e44e                	sd	s3,8(sp)
    80000af2:	e052                	sd	s4,0(sp)
    80000af4:	892e                	mv	s2,a1
    kfree(p);
    80000af6:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af8:	89be                	mv	s3,a5
    kfree(p);
    80000afa:	01448533          	add	a0,s1,s4
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	f56080e7          	jalr	-170(ra) # 80000a54 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b06:	94ce                	add	s1,s1,s3
    80000b08:	fe9979e3          	bgeu	s2,s1,80000afa <freerange+0x2a>
    80000b0c:	6942                	ld	s2,16(sp)
    80000b0e:	69a2                	ld	s3,8(sp)
    80000b10:	6a02                	ld	s4,0(sp)
}
    80000b12:	70a2                	ld	ra,40(sp)
    80000b14:	7402                	ld	s0,32(sp)
    80000b16:	64e2                	ld	s1,24(sp)
    80000b18:	6145                	addi	sp,sp,48
    80000b1a:	8082                	ret

0000000080000b1c <kinit>:
{
    80000b1c:	1141                	addi	sp,sp,-16
    80000b1e:	e406                	sd	ra,8(sp)
    80000b20:	e022                	sd	s0,0(sp)
    80000b22:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b24:	00007597          	auipc	a1,0x7
    80000b28:	52458593          	addi	a1,a1,1316 # 80008048 <etext+0x48>
    80000b2c:	00010517          	auipc	a0,0x10
    80000b30:	fe450513          	addi	a0,a0,-28 # 80010b10 <kmem>
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	08e080e7          	jalr	142(ra) # 80000bc2 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b3c:	45c5                	li	a1,17
    80000b3e:	05ee                	slli	a1,a1,0x1b
    80000b40:	00021517          	auipc	a0,0x21
    80000b44:	60050513          	addi	a0,a0,1536 # 80022140 <end>
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	f88080e7          	jalr	-120(ra) # 80000ad0 <freerange>
}
    80000b50:	60a2                	ld	ra,8(sp)
    80000b52:	6402                	ld	s0,0(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b58:	1101                	addi	sp,sp,-32
    80000b5a:	ec06                	sd	ra,24(sp)
    80000b5c:	e822                	sd	s0,16(sp)
    80000b5e:	e426                	sd	s1,8(sp)
    80000b60:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b62:	00010517          	auipc	a0,0x10
    80000b66:	fae50513          	addi	a0,a0,-82 # 80010b10 <kmem>
    80000b6a:	00000097          	auipc	ra,0x0
    80000b6e:	0f2080e7          	jalr	242(ra) # 80000c5c <acquire>
  r = kmem.freelist;
    80000b72:	00010497          	auipc	s1,0x10
    80000b76:	fb64b483          	ld	s1,-74(s1) # 80010b28 <kmem+0x18>
  if(r)
    80000b7a:	c89d                	beqz	s1,80000bb0 <kalloc+0x58>
    kmem.freelist = r->next;
    80000b7c:	609c                	ld	a5,0(s1)
    80000b7e:	00010717          	auipc	a4,0x10
    80000b82:	faf73523          	sd	a5,-86(a4) # 80010b28 <kmem+0x18>
  release(&kmem.lock);
    80000b86:	00010517          	auipc	a0,0x10
    80000b8a:	f8a50513          	addi	a0,a0,-118 # 80010b10 <kmem>
    80000b8e:	00000097          	auipc	ra,0x0
    80000b92:	17e080e7          	jalr	382(ra) # 80000d0c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b96:	6605                	lui	a2,0x1
    80000b98:	4595                	li	a1,5
    80000b9a:	8526                	mv	a0,s1
    80000b9c:	00000097          	auipc	ra,0x0
    80000ba0:	1b8080e7          	jalr	440(ra) # 80000d54 <memset>
  return (void*)r;
}
    80000ba4:	8526                	mv	a0,s1
    80000ba6:	60e2                	ld	ra,24(sp)
    80000ba8:	6442                	ld	s0,16(sp)
    80000baa:	64a2                	ld	s1,8(sp)
    80000bac:	6105                	addi	sp,sp,32
    80000bae:	8082                	ret
  release(&kmem.lock);
    80000bb0:	00010517          	auipc	a0,0x10
    80000bb4:	f6050513          	addi	a0,a0,-160 # 80010b10 <kmem>
    80000bb8:	00000097          	auipc	ra,0x0
    80000bbc:	154080e7          	jalr	340(ra) # 80000d0c <release>
  if(r)
    80000bc0:	b7d5                	j	80000ba4 <kalloc+0x4c>

0000000080000bc2 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bc2:	1141                	addi	sp,sp,-16
    80000bc4:	e406                	sd	ra,8(sp)
    80000bc6:	e022                	sd	s0,0(sp)
    80000bc8:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bca:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bcc:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bd0:	00053823          	sd	zero,16(a0)
}
    80000bd4:	60a2                	ld	ra,8(sp)
    80000bd6:	6402                	ld	s0,0(sp)
    80000bd8:	0141                	addi	sp,sp,16
    80000bda:	8082                	ret

0000000080000bdc <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bdc:	411c                	lw	a5,0(a0)
    80000bde:	e399                	bnez	a5,80000be4 <holding+0x8>
    80000be0:	4501                	li	a0,0
  return r;
}
    80000be2:	8082                	ret
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bee:	691c                	ld	a5,16(a0)
    80000bf0:	84be                	mv	s1,a5
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	ef8080e7          	jalr	-264(ra) # 80001aea <mycpu>
    80000bfa:	40a48533          	sub	a0,s1,a0
    80000bfe:	00153513          	seqz	a0,a0
}
    80000c02:	60e2                	ld	ra,24(sp)
    80000c04:	6442                	ld	s0,16(sp)
    80000c06:	64a2                	ld	s1,8(sp)
    80000c08:	6105                	addi	sp,sp,32
    80000c0a:	8082                	ret

0000000080000c0c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c0c:	1101                	addi	sp,sp,-32
    80000c0e:	ec06                	sd	ra,24(sp)
    80000c10:	e822                	sd	s0,16(sp)
    80000c12:	e426                	sd	s1,8(sp)
    80000c14:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c16:	100027f3          	csrr	a5,sstatus
    80000c1a:	84be                	mv	s1,a5
    80000c1c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c20:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c22:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c26:	00001097          	auipc	ra,0x1
    80000c2a:	ec4080e7          	jalr	-316(ra) # 80001aea <mycpu>
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	cf89                	beqz	a5,80000c4a <push_off+0x3e>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	eb8080e7          	jalr	-328(ra) # 80001aea <mycpu>
    80000c3a:	5d3c                	lw	a5,120(a0)
    80000c3c:	2785                	addiw	a5,a5,1
    80000c3e:	dd3c                	sw	a5,120(a0)
}
    80000c40:	60e2                	ld	ra,24(sp)
    80000c42:	6442                	ld	s0,16(sp)
    80000c44:	64a2                	ld	s1,8(sp)
    80000c46:	6105                	addi	sp,sp,32
    80000c48:	8082                	ret
    mycpu()->intena = old;
    80000c4a:	00001097          	auipc	ra,0x1
    80000c4e:	ea0080e7          	jalr	-352(ra) # 80001aea <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c52:	0014d793          	srli	a5,s1,0x1
    80000c56:	8b85                	andi	a5,a5,1
    80000c58:	dd7c                	sw	a5,124(a0)
    80000c5a:	bfe1                	j	80000c32 <push_off+0x26>

0000000080000c5c <acquire>:
{
    80000c5c:	1101                	addi	sp,sp,-32
    80000c5e:	ec06                	sd	ra,24(sp)
    80000c60:	e822                	sd	s0,16(sp)
    80000c62:	e426                	sd	s1,8(sp)
    80000c64:	1000                	addi	s0,sp,32
    80000c66:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c68:	00000097          	auipc	ra,0x0
    80000c6c:	fa4080e7          	jalr	-92(ra) # 80000c0c <push_off>
  if(holding(lk))
    80000c70:	8526                	mv	a0,s1
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	f6a080e7          	jalr	-150(ra) # 80000bdc <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c7a:	4705                	li	a4,1
  if(holding(lk))
    80000c7c:	e115                	bnez	a0,80000ca0 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c7e:	87ba                	mv	a5,a4
    80000c80:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c84:	2781                	sext.w	a5,a5
    80000c86:	ffe5                	bnez	a5,80000c7e <acquire+0x22>
  __sync_synchronize();
    80000c88:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c8c:	00001097          	auipc	ra,0x1
    80000c90:	e5e080e7          	jalr	-418(ra) # 80001aea <mycpu>
    80000c94:	e888                	sd	a0,16(s1)
}
    80000c96:	60e2                	ld	ra,24(sp)
    80000c98:	6442                	ld	s0,16(sp)
    80000c9a:	64a2                	ld	s1,8(sp)
    80000c9c:	6105                	addi	sp,sp,32
    80000c9e:	8082                	ret
    panic("acquire");
    80000ca0:	00007517          	auipc	a0,0x7
    80000ca4:	3b050513          	addi	a0,a0,944 # 80008050 <etext+0x50>
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	8b6080e7          	jalr	-1866(ra) # 8000055e <panic>

0000000080000cb0 <pop_off>:

void
pop_off(void)
{
    80000cb0:	1141                	addi	sp,sp,-16
    80000cb2:	e406                	sd	ra,8(sp)
    80000cb4:	e022                	sd	s0,0(sp)
    80000cb6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cb8:	00001097          	auipc	ra,0x1
    80000cbc:	e32080e7          	jalr	-462(ra) # 80001aea <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cc0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cc4:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cc6:	e39d                	bnez	a5,80000cec <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cc8:	5d3c                	lw	a5,120(a0)
    80000cca:	02f05963          	blez	a5,80000cfc <pop_off+0x4c>
    panic("pop_off");
  c->noff -= 1;
    80000cce:	37fd                	addiw	a5,a5,-1
    80000cd0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cd2:	eb89                	bnez	a5,80000ce4 <pop_off+0x34>
    80000cd4:	5d7c                	lw	a5,124(a0)
    80000cd6:	c799                	beqz	a5,80000ce4 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cd8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cdc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ce0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ce4:	60a2                	ld	ra,8(sp)
    80000ce6:	6402                	ld	s0,0(sp)
    80000ce8:	0141                	addi	sp,sp,16
    80000cea:	8082                	ret
    panic("pop_off - interruptible");
    80000cec:	00007517          	auipc	a0,0x7
    80000cf0:	36c50513          	addi	a0,a0,876 # 80008058 <etext+0x58>
    80000cf4:	00000097          	auipc	ra,0x0
    80000cf8:	86a080e7          	jalr	-1942(ra) # 8000055e <panic>
    panic("pop_off");
    80000cfc:	00007517          	auipc	a0,0x7
    80000d00:	37450513          	addi	a0,a0,884 # 80008070 <etext+0x70>
    80000d04:	00000097          	auipc	ra,0x0
    80000d08:	85a080e7          	jalr	-1958(ra) # 8000055e <panic>

0000000080000d0c <release>:
{
    80000d0c:	1101                	addi	sp,sp,-32
    80000d0e:	ec06                	sd	ra,24(sp)
    80000d10:	e822                	sd	s0,16(sp)
    80000d12:	e426                	sd	s1,8(sp)
    80000d14:	1000                	addi	s0,sp,32
    80000d16:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d18:	00000097          	auipc	ra,0x0
    80000d1c:	ec4080e7          	jalr	-316(ra) # 80000bdc <holding>
    80000d20:	c115                	beqz	a0,80000d44 <release+0x38>
  lk->cpu = 0;
    80000d22:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d26:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d2a:	0310000f          	fence	rw,w
    80000d2e:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d32:	00000097          	auipc	ra,0x0
    80000d36:	f7e080e7          	jalr	-130(ra) # 80000cb0 <pop_off>
}
    80000d3a:	60e2                	ld	ra,24(sp)
    80000d3c:	6442                	ld	s0,16(sp)
    80000d3e:	64a2                	ld	s1,8(sp)
    80000d40:	6105                	addi	sp,sp,32
    80000d42:	8082                	ret
    panic("release");
    80000d44:	00007517          	auipc	a0,0x7
    80000d48:	33450513          	addi	a0,a0,820 # 80008078 <etext+0x78>
    80000d4c:	00000097          	auipc	ra,0x0
    80000d50:	812080e7          	jalr	-2030(ra) # 8000055e <panic>

0000000080000d54 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d54:	1141                	addi	sp,sp,-16
    80000d56:	e406                	sd	ra,8(sp)
    80000d58:	e022                	sd	s0,0(sp)
    80000d5a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d5c:	ca19                	beqz	a2,80000d72 <memset+0x1e>
    80000d5e:	87aa                	mv	a5,a0
    80000d60:	1602                	slli	a2,a2,0x20
    80000d62:	9201                	srli	a2,a2,0x20
    80000d64:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d68:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d6c:	0785                	addi	a5,a5,1
    80000d6e:	fee79de3          	bne	a5,a4,80000d68 <memset+0x14>
  }
  return dst;
}
    80000d72:	60a2                	ld	ra,8(sp)
    80000d74:	6402                	ld	s0,0(sp)
    80000d76:	0141                	addi	sp,sp,16
    80000d78:	8082                	ret

0000000080000d7a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d7a:	1141                	addi	sp,sp,-16
    80000d7c:	e406                	sd	ra,8(sp)
    80000d7e:	e022                	sd	s0,0(sp)
    80000d80:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d82:	c61d                	beqz	a2,80000db0 <memcmp+0x36>
    80000d84:	1602                	slli	a2,a2,0x20
    80000d86:	9201                	srli	a2,a2,0x20
    80000d88:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d8c:	00054783          	lbu	a5,0(a0)
    80000d90:	0005c703          	lbu	a4,0(a1)
    80000d94:	00e79863          	bne	a5,a4,80000da4 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d98:	0505                	addi	a0,a0,1
    80000d9a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d9c:	fed518e3          	bne	a0,a3,80000d8c <memcmp+0x12>
  }

  return 0;
    80000da0:	4501                	li	a0,0
    80000da2:	a019                	j	80000da8 <memcmp+0x2e>
      return *s1 - *s2;
    80000da4:	40e7853b          	subw	a0,a5,a4
}
    80000da8:	60a2                	ld	ra,8(sp)
    80000daa:	6402                	ld	s0,0(sp)
    80000dac:	0141                	addi	sp,sp,16
    80000dae:	8082                	ret
  return 0;
    80000db0:	4501                	li	a0,0
    80000db2:	bfdd                	j	80000da8 <memcmp+0x2e>

0000000080000db4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000db4:	1141                	addi	sp,sp,-16
    80000db6:	e406                	sd	ra,8(sp)
    80000db8:	e022                	sd	s0,0(sp)
    80000dba:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000dbc:	c205                	beqz	a2,80000ddc <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dbe:	02a5e363          	bltu	a1,a0,80000de4 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dc2:	1602                	slli	a2,a2,0x20
    80000dc4:	9201                	srli	a2,a2,0x20
    80000dc6:	00c587b3          	add	a5,a1,a2
{
    80000dca:	872a                	mv	a4,a0
      *d++ = *s++;
    80000dcc:	0585                	addi	a1,a1,1
    80000dce:	0705                	addi	a4,a4,1
    80000dd0:	fff5c683          	lbu	a3,-1(a1)
    80000dd4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000dd8:	feb79ae3          	bne	a5,a1,80000dcc <memmove+0x18>

  return dst;
}
    80000ddc:	60a2                	ld	ra,8(sp)
    80000dde:	6402                	ld	s0,0(sp)
    80000de0:	0141                	addi	sp,sp,16
    80000de2:	8082                	ret
  if(s < d && s + n > d){
    80000de4:	02061693          	slli	a3,a2,0x20
    80000de8:	9281                	srli	a3,a3,0x20
    80000dea:	00d58733          	add	a4,a1,a3
    80000dee:	fce57ae3          	bgeu	a0,a4,80000dc2 <memmove+0xe>
    d += n;
    80000df2:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000df4:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000df8:	1782                	slli	a5,a5,0x20
    80000dfa:	9381                	srli	a5,a5,0x20
    80000dfc:	fff7c793          	not	a5,a5
    80000e00:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e02:	177d                	addi	a4,a4,-1
    80000e04:	16fd                	addi	a3,a3,-1
    80000e06:	00074603          	lbu	a2,0(a4)
    80000e0a:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e0e:	fee79ae3          	bne	a5,a4,80000e02 <memmove+0x4e>
    80000e12:	b7e9                	j	80000ddc <memmove+0x28>

0000000080000e14 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e14:	1141                	addi	sp,sp,-16
    80000e16:	e406                	sd	ra,8(sp)
    80000e18:	e022                	sd	s0,0(sp)
    80000e1a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e1c:	00000097          	auipc	ra,0x0
    80000e20:	f98080e7          	jalr	-104(ra) # 80000db4 <memmove>
}
    80000e24:	60a2                	ld	ra,8(sp)
    80000e26:	6402                	ld	s0,0(sp)
    80000e28:	0141                	addi	sp,sp,16
    80000e2a:	8082                	ret

0000000080000e2c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e2c:	1141                	addi	sp,sp,-16
    80000e2e:	e406                	sd	ra,8(sp)
    80000e30:	e022                	sd	s0,0(sp)
    80000e32:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e34:	ce11                	beqz	a2,80000e50 <strncmp+0x24>
    80000e36:	00054783          	lbu	a5,0(a0)
    80000e3a:	cf89                	beqz	a5,80000e54 <strncmp+0x28>
    80000e3c:	0005c703          	lbu	a4,0(a1)
    80000e40:	00f71a63          	bne	a4,a5,80000e54 <strncmp+0x28>
    n--, p++, q++;
    80000e44:	367d                	addiw	a2,a2,-1
    80000e46:	0505                	addi	a0,a0,1
    80000e48:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e4a:	f675                	bnez	a2,80000e36 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000e4c:	4501                	li	a0,0
    80000e4e:	a801                	j	80000e5e <strncmp+0x32>
    80000e50:	4501                	li	a0,0
    80000e52:	a031                	j	80000e5e <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000e54:	00054503          	lbu	a0,0(a0)
    80000e58:	0005c783          	lbu	a5,0(a1)
    80000e5c:	9d1d                	subw	a0,a0,a5
}
    80000e5e:	60a2                	ld	ra,8(sp)
    80000e60:	6402                	ld	s0,0(sp)
    80000e62:	0141                	addi	sp,sp,16
    80000e64:	8082                	ret

0000000080000e66 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e66:	1141                	addi	sp,sp,-16
    80000e68:	e406                	sd	ra,8(sp)
    80000e6a:	e022                	sd	s0,0(sp)
    80000e6c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e6e:	87aa                	mv	a5,a0
    80000e70:	a011                	j	80000e74 <strncpy+0xe>
    80000e72:	8636                	mv	a2,a3
    80000e74:	02c05863          	blez	a2,80000ea4 <strncpy+0x3e>
    80000e78:	fff6069b          	addiw	a3,a2,-1
    80000e7c:	8836                	mv	a6,a3
    80000e7e:	0785                	addi	a5,a5,1
    80000e80:	0005c703          	lbu	a4,0(a1)
    80000e84:	fee78fa3          	sb	a4,-1(a5)
    80000e88:	0585                	addi	a1,a1,1
    80000e8a:	f765                	bnez	a4,80000e72 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e8c:	873e                	mv	a4,a5
    80000e8e:	01005b63          	blez	a6,80000ea4 <strncpy+0x3e>
    80000e92:	9fb1                	addw	a5,a5,a2
    80000e94:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e96:	0705                	addi	a4,a4,1
    80000e98:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e9c:	40e786bb          	subw	a3,a5,a4
    80000ea0:	fed04be3          	bgtz	a3,80000e96 <strncpy+0x30>
  return os;
}
    80000ea4:	60a2                	ld	ra,8(sp)
    80000ea6:	6402                	ld	s0,0(sp)
    80000ea8:	0141                	addi	sp,sp,16
    80000eaa:	8082                	ret

0000000080000eac <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000eac:	1141                	addi	sp,sp,-16
    80000eae:	e406                	sd	ra,8(sp)
    80000eb0:	e022                	sd	s0,0(sp)
    80000eb2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eb4:	02c05363          	blez	a2,80000eda <safestrcpy+0x2e>
    80000eb8:	fff6069b          	addiw	a3,a2,-1
    80000ebc:	1682                	slli	a3,a3,0x20
    80000ebe:	9281                	srli	a3,a3,0x20
    80000ec0:	96ae                	add	a3,a3,a1
    80000ec2:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ec4:	00d58963          	beq	a1,a3,80000ed6 <safestrcpy+0x2a>
    80000ec8:	0585                	addi	a1,a1,1
    80000eca:	0785                	addi	a5,a5,1
    80000ecc:	fff5c703          	lbu	a4,-1(a1)
    80000ed0:	fee78fa3          	sb	a4,-1(a5)
    80000ed4:	fb65                	bnez	a4,80000ec4 <safestrcpy+0x18>
    ;
  *s = 0;
    80000ed6:	00078023          	sb	zero,0(a5)
  return os;
}
    80000eda:	60a2                	ld	ra,8(sp)
    80000edc:	6402                	ld	s0,0(sp)
    80000ede:	0141                	addi	sp,sp,16
    80000ee0:	8082                	ret

0000000080000ee2 <strlen>:

int
strlen(const char *s)
{
    80000ee2:	1141                	addi	sp,sp,-16
    80000ee4:	e406                	sd	ra,8(sp)
    80000ee6:	e022                	sd	s0,0(sp)
    80000ee8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eea:	00054783          	lbu	a5,0(a0)
    80000eee:	cf91                	beqz	a5,80000f0a <strlen+0x28>
    80000ef0:	00150793          	addi	a5,a0,1
    80000ef4:	86be                	mv	a3,a5
    80000ef6:	0785                	addi	a5,a5,1
    80000ef8:	fff7c703          	lbu	a4,-1(a5)
    80000efc:	ff65                	bnez	a4,80000ef4 <strlen+0x12>
    80000efe:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000f02:	60a2                	ld	ra,8(sp)
    80000f04:	6402                	ld	s0,0(sp)
    80000f06:	0141                	addi	sp,sp,16
    80000f08:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f0a:	4501                	li	a0,0
    80000f0c:	bfdd                	j	80000f02 <strlen+0x20>

0000000080000f0e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f0e:	1141                	addi	sp,sp,-16
    80000f10:	e406                	sd	ra,8(sp)
    80000f12:	e022                	sd	s0,0(sp)
    80000f14:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f16:	00001097          	auipc	ra,0x1
    80000f1a:	bc0080e7          	jalr	-1088(ra) # 80001ad6 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f1e:	00008717          	auipc	a4,0x8
    80000f22:	98a70713          	addi	a4,a4,-1654 # 800088a8 <started>
  if(cpuid() == 0){
    80000f26:	c139                	beqz	a0,80000f6c <main+0x5e>
    while(started == 0)
    80000f28:	431c                	lw	a5,0(a4)
    80000f2a:	2781                	sext.w	a5,a5
    80000f2c:	dff5                	beqz	a5,80000f28 <main+0x1a>
      ;
    __sync_synchronize();
    80000f2e:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000f32:	00001097          	auipc	ra,0x1
    80000f36:	ba4080e7          	jalr	-1116(ra) # 80001ad6 <cpuid>
    80000f3a:	85aa                	mv	a1,a0
    80000f3c:	00007517          	auipc	a0,0x7
    80000f40:	15c50513          	addi	a0,a0,348 # 80008098 <etext+0x98>
    80000f44:	fffff097          	auipc	ra,0xfffff
    80000f48:	664080e7          	jalr	1636(ra) # 800005a8 <printf>
    kvminithart();    // turn on paging
    80000f4c:	00000097          	auipc	ra,0x0
    80000f50:	0d8080e7          	jalr	216(ra) # 80001024 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f54:	00002097          	auipc	ra,0x2
    80000f58:	8e0080e7          	jalr	-1824(ra) # 80002834 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	018080e7          	jalr	24(ra) # 80005f74 <plicinithart>
  }

  scheduler();        
    80000f64:	00001097          	auipc	ra,0x1
    80000f68:	0be080e7          	jalr	190(ra) # 80002022 <scheduler>
    consoleinit();
    80000f6c:	fffff097          	auipc	ra,0xfffff
    80000f70:	508080e7          	jalr	1288(ra) # 80000474 <consoleinit>
    printfinit();
    80000f74:	00000097          	auipc	ra,0x0
    80000f78:	83e080e7          	jalr	-1986(ra) # 800007b2 <printfinit>
    printf("\n");
    80000f7c:	00007517          	auipc	a0,0x7
    80000f80:	09450513          	addi	a0,a0,148 # 80008010 <etext+0x10>
    80000f84:	fffff097          	auipc	ra,0xfffff
    80000f88:	624080e7          	jalr	1572(ra) # 800005a8 <printf>
    printf("xv6 kernel is booting\n");
    80000f8c:	00007517          	auipc	a0,0x7
    80000f90:	0f450513          	addi	a0,a0,244 # 80008080 <etext+0x80>
    80000f94:	fffff097          	auipc	ra,0xfffff
    80000f98:	614080e7          	jalr	1556(ra) # 800005a8 <printf>
    printf("\n");
    80000f9c:	00007517          	auipc	a0,0x7
    80000fa0:	07450513          	addi	a0,a0,116 # 80008010 <etext+0x10>
    80000fa4:	fffff097          	auipc	ra,0xfffff
    80000fa8:	604080e7          	jalr	1540(ra) # 800005a8 <printf>
    kinit();         // physical page allocator
    80000fac:	00000097          	auipc	ra,0x0
    80000fb0:	b70080e7          	jalr	-1168(ra) # 80000b1c <kinit>
    kvminit();       // create kernel page table
    80000fb4:	00000097          	auipc	ra,0x0
    80000fb8:	324080e7          	jalr	804(ra) # 800012d8 <kvminit>
    kvminithart();   // turn on paging
    80000fbc:	00000097          	auipc	ra,0x0
    80000fc0:	068080e7          	jalr	104(ra) # 80001024 <kvminithart>
    procinit();      // process table
    80000fc4:	00001097          	auipc	ra,0x1
    80000fc8:	a56080e7          	jalr	-1450(ra) # 80001a1a <procinit>
    trapinit();      // trap vectors
    80000fcc:	00002097          	auipc	ra,0x2
    80000fd0:	840080e7          	jalr	-1984(ra) # 8000280c <trapinit>
    trapinithart();  // install kernel trap vector
    80000fd4:	00002097          	auipc	ra,0x2
    80000fd8:	860080e7          	jalr	-1952(ra) # 80002834 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fdc:	00005097          	auipc	ra,0x5
    80000fe0:	f7e080e7          	jalr	-130(ra) # 80005f5a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fe4:	00005097          	auipc	ra,0x5
    80000fe8:	f90080e7          	jalr	-112(ra) # 80005f74 <plicinithart>
    binit();         // buffer cache
    80000fec:	00002097          	auipc	ra,0x2
    80000ff0:	000080e7          	jalr	ra # 80002fec <binit>
    iinit();         // inode table
    80000ff4:	00002097          	auipc	ra,0x2
    80000ff8:	680080e7          	jalr	1664(ra) # 80003674 <iinit>
    fileinit();      // file table
    80000ffc:	00003097          	auipc	ra,0x3
    80001000:	66a080e7          	jalr	1642(ra) # 80004666 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001004:	00005097          	auipc	ra,0x5
    80001008:	078080e7          	jalr	120(ra) # 8000607c <virtio_disk_init>
    userinit();      // first user process
    8000100c:	00001097          	auipc	ra,0x1
    80001010:	df6080e7          	jalr	-522(ra) # 80001e02 <userinit>
    __sync_synchronize();
    80001014:	0330000f          	fence	rw,rw
    started = 1;
    80001018:	4785                	li	a5,1
    8000101a:	00008717          	auipc	a4,0x8
    8000101e:	88f72723          	sw	a5,-1906(a4) # 800088a8 <started>
    80001022:	b789                	j	80000f64 <main+0x56>

0000000080001024 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001024:	1141                	addi	sp,sp,-16
    80001026:	e406                	sd	ra,8(sp)
    80001028:	e022                	sd	s0,0(sp)
    8000102a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000102c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001030:	00008797          	auipc	a5,0x8
    80001034:	8807b783          	ld	a5,-1920(a5) # 800088b0 <kernel_pagetable>
    80001038:	83b1                	srli	a5,a5,0xc
    8000103a:	577d                	li	a4,-1
    8000103c:	177e                	slli	a4,a4,0x3f
    8000103e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001040:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001044:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001048:	60a2                	ld	ra,8(sp)
    8000104a:	6402                	ld	s0,0(sp)
    8000104c:	0141                	addi	sp,sp,16
    8000104e:	8082                	ret

0000000080001050 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001050:	7139                	addi	sp,sp,-64
    80001052:	fc06                	sd	ra,56(sp)
    80001054:	f822                	sd	s0,48(sp)
    80001056:	f426                	sd	s1,40(sp)
    80001058:	f04a                	sd	s2,32(sp)
    8000105a:	ec4e                	sd	s3,24(sp)
    8000105c:	e852                	sd	s4,16(sp)
    8000105e:	e456                	sd	s5,8(sp)
    80001060:	e05a                	sd	s6,0(sp)
    80001062:	0080                	addi	s0,sp,64
    80001064:	84aa                	mv	s1,a0
    80001066:	89ae                	mv	s3,a1
    80001068:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    8000106a:	57fd                	li	a5,-1
    8000106c:	83e9                	srli	a5,a5,0x1a
    8000106e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001070:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80001072:	04b7e263          	bltu	a5,a1,800010b6 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80001076:	0149d933          	srl	s2,s3,s4
    8000107a:	1ff97913          	andi	s2,s2,511
    8000107e:	090e                	slli	s2,s2,0x3
    80001080:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001082:	00093483          	ld	s1,0(s2)
    80001086:	0014f793          	andi	a5,s1,1
    8000108a:	cf95                	beqz	a5,800010c6 <walk+0x76>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000108c:	80a9                	srli	s1,s1,0xa
    8000108e:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80001090:	3a5d                	addiw	s4,s4,-9
    80001092:	ff5a12e3          	bne	s4,s5,80001076 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80001096:	00c9d513          	srli	a0,s3,0xc
    8000109a:	1ff57513          	andi	a0,a0,511
    8000109e:	050e                	slli	a0,a0,0x3
    800010a0:	9526                	add	a0,a0,s1
}
    800010a2:	70e2                	ld	ra,56(sp)
    800010a4:	7442                	ld	s0,48(sp)
    800010a6:	74a2                	ld	s1,40(sp)
    800010a8:	7902                	ld	s2,32(sp)
    800010aa:	69e2                	ld	s3,24(sp)
    800010ac:	6a42                	ld	s4,16(sp)
    800010ae:	6aa2                	ld	s5,8(sp)
    800010b0:	6b02                	ld	s6,0(sp)
    800010b2:	6121                	addi	sp,sp,64
    800010b4:	8082                	ret
    panic("walk");
    800010b6:	00007517          	auipc	a0,0x7
    800010ba:	ffa50513          	addi	a0,a0,-6 # 800080b0 <etext+0xb0>
    800010be:	fffff097          	auipc	ra,0xfffff
    800010c2:	4a0080e7          	jalr	1184(ra) # 8000055e <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010c6:	020b0663          	beqz	s6,800010f2 <walk+0xa2>
    800010ca:	00000097          	auipc	ra,0x0
    800010ce:	a8e080e7          	jalr	-1394(ra) # 80000b58 <kalloc>
    800010d2:	84aa                	mv	s1,a0
    800010d4:	d579                	beqz	a0,800010a2 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    800010d6:	6605                	lui	a2,0x1
    800010d8:	4581                	li	a1,0
    800010da:	00000097          	auipc	ra,0x0
    800010de:	c7a080e7          	jalr	-902(ra) # 80000d54 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010e2:	00c4d793          	srli	a5,s1,0xc
    800010e6:	07aa                	slli	a5,a5,0xa
    800010e8:	0017e793          	ori	a5,a5,1
    800010ec:	00f93023          	sd	a5,0(s2)
    800010f0:	b745                	j	80001090 <walk+0x40>
        return 0;
    800010f2:	4501                	li	a0,0
    800010f4:	b77d                	j	800010a2 <walk+0x52>

00000000800010f6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010f6:	57fd                	li	a5,-1
    800010f8:	83e9                	srli	a5,a5,0x1a
    800010fa:	00b7f463          	bgeu	a5,a1,80001102 <walkaddr+0xc>
    return 0;
    800010fe:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001100:	8082                	ret
{
    80001102:	1141                	addi	sp,sp,-16
    80001104:	e406                	sd	ra,8(sp)
    80001106:	e022                	sd	s0,0(sp)
    80001108:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000110a:	4601                	li	a2,0
    8000110c:	00000097          	auipc	ra,0x0
    80001110:	f44080e7          	jalr	-188(ra) # 80001050 <walk>
  if(pte == 0)
    80001114:	c901                	beqz	a0,80001124 <walkaddr+0x2e>
  if((*pte & PTE_V) == 0)
    80001116:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001118:	0117f693          	andi	a3,a5,17
    8000111c:	4745                	li	a4,17
    return 0;
    8000111e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001120:	00e68663          	beq	a3,a4,8000112c <walkaddr+0x36>
}
    80001124:	60a2                	ld	ra,8(sp)
    80001126:	6402                	ld	s0,0(sp)
    80001128:	0141                	addi	sp,sp,16
    8000112a:	8082                	ret
  pa = PTE2PA(*pte);
    8000112c:	83a9                	srli	a5,a5,0xa
    8000112e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001132:	bfcd                	j	80001124 <walkaddr+0x2e>

0000000080001134 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001134:	715d                	addi	sp,sp,-80
    80001136:	e486                	sd	ra,72(sp)
    80001138:	e0a2                	sd	s0,64(sp)
    8000113a:	fc26                	sd	s1,56(sp)
    8000113c:	f84a                	sd	s2,48(sp)
    8000113e:	f44e                	sd	s3,40(sp)
    80001140:	f052                	sd	s4,32(sp)
    80001142:	ec56                	sd	s5,24(sp)
    80001144:	e85a                	sd	s6,16(sp)
    80001146:	e45e                	sd	s7,8(sp)
    80001148:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000114a:	ca21                	beqz	a2,8000119a <mappages+0x66>
    8000114c:	8a2a                	mv	s4,a0
    8000114e:	8aba                	mv	s5,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001150:	777d                	lui	a4,0xfffff
    80001152:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001156:	fff58913          	addi	s2,a1,-1
    8000115a:	9932                	add	s2,s2,a2
    8000115c:	00e97933          	and	s2,s2,a4
  a = PGROUNDDOWN(va);
    80001160:	84be                	mv	s1,a5
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001162:	4b05                	li	s6,1
    80001164:	40f689b3          	sub	s3,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001168:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    8000116a:	865a                	mv	a2,s6
    8000116c:	85a6                	mv	a1,s1
    8000116e:	8552                	mv	a0,s4
    80001170:	00000097          	auipc	ra,0x0
    80001174:	ee0080e7          	jalr	-288(ra) # 80001050 <walk>
    80001178:	c129                	beqz	a0,800011ba <mappages+0x86>
    if(*pte & PTE_V)
    8000117a:	611c                	ld	a5,0(a0)
    8000117c:	8b85                	andi	a5,a5,1
    8000117e:	e795                	bnez	a5,800011aa <mappages+0x76>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001180:	013487b3          	add	a5,s1,s3
    80001184:	83b1                	srli	a5,a5,0xc
    80001186:	07aa                	slli	a5,a5,0xa
    80001188:	0157e7b3          	or	a5,a5,s5
    8000118c:	0017e793          	ori	a5,a5,1
    80001190:	e11c                	sd	a5,0(a0)
    if(a == last)
    80001192:	05248063          	beq	s1,s2,800011d2 <mappages+0x9e>
    a += PGSIZE;
    80001196:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001198:	bfc9                	j	8000116a <mappages+0x36>
    panic("mappages: size");
    8000119a:	00007517          	auipc	a0,0x7
    8000119e:	f1e50513          	addi	a0,a0,-226 # 800080b8 <etext+0xb8>
    800011a2:	fffff097          	auipc	ra,0xfffff
    800011a6:	3bc080e7          	jalr	956(ra) # 8000055e <panic>
      panic("mappages: remap");
    800011aa:	00007517          	auipc	a0,0x7
    800011ae:	f1e50513          	addi	a0,a0,-226 # 800080c8 <etext+0xc8>
    800011b2:	fffff097          	auipc	ra,0xfffff
    800011b6:	3ac080e7          	jalr	940(ra) # 8000055e <panic>
      return -1;
    800011ba:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011bc:	60a6                	ld	ra,72(sp)
    800011be:	6406                	ld	s0,64(sp)
    800011c0:	74e2                	ld	s1,56(sp)
    800011c2:	7942                	ld	s2,48(sp)
    800011c4:	79a2                	ld	s3,40(sp)
    800011c6:	7a02                	ld	s4,32(sp)
    800011c8:	6ae2                	ld	s5,24(sp)
    800011ca:	6b42                	ld	s6,16(sp)
    800011cc:	6ba2                	ld	s7,8(sp)
    800011ce:	6161                	addi	sp,sp,80
    800011d0:	8082                	ret
  return 0;
    800011d2:	4501                	li	a0,0
    800011d4:	b7e5                	j	800011bc <mappages+0x88>

00000000800011d6 <kvmmap>:
{
    800011d6:	1141                	addi	sp,sp,-16
    800011d8:	e406                	sd	ra,8(sp)
    800011da:	e022                	sd	s0,0(sp)
    800011dc:	0800                	addi	s0,sp,16
    800011de:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011e0:	86b2                	mv	a3,a2
    800011e2:	863e                	mv	a2,a5
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f50080e7          	jalr	-176(ra) # 80001134 <mappages>
    800011ec:	e509                	bnez	a0,800011f6 <kvmmap+0x20>
}
    800011ee:	60a2                	ld	ra,8(sp)
    800011f0:	6402                	ld	s0,0(sp)
    800011f2:	0141                	addi	sp,sp,16
    800011f4:	8082                	ret
    panic("kvmmap");
    800011f6:	00007517          	auipc	a0,0x7
    800011fa:	ee250513          	addi	a0,a0,-286 # 800080d8 <etext+0xd8>
    800011fe:	fffff097          	auipc	ra,0xfffff
    80001202:	360080e7          	jalr	864(ra) # 8000055e <panic>

0000000080001206 <kvmmake>:
{
    80001206:	1101                	addi	sp,sp,-32
    80001208:	ec06                	sd	ra,24(sp)
    8000120a:	e822                	sd	s0,16(sp)
    8000120c:	e426                	sd	s1,8(sp)
    8000120e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001210:	00000097          	auipc	ra,0x0
    80001214:	948080e7          	jalr	-1720(ra) # 80000b58 <kalloc>
    80001218:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000121a:	6605                	lui	a2,0x1
    8000121c:	4581                	li	a1,0
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	b36080e7          	jalr	-1226(ra) # 80000d54 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001226:	4719                	li	a4,6
    80001228:	6685                	lui	a3,0x1
    8000122a:	10000637          	lui	a2,0x10000
    8000122e:	85b2                	mv	a1,a2
    80001230:	8526                	mv	a0,s1
    80001232:	00000097          	auipc	ra,0x0
    80001236:	fa4080e7          	jalr	-92(ra) # 800011d6 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000123a:	4719                	li	a4,6
    8000123c:	6685                	lui	a3,0x1
    8000123e:	10001637          	lui	a2,0x10001
    80001242:	85b2                	mv	a1,a2
    80001244:	8526                	mv	a0,s1
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f90080e7          	jalr	-112(ra) # 800011d6 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000124e:	4719                	li	a4,6
    80001250:	004006b7          	lui	a3,0x400
    80001254:	0c000637          	lui	a2,0xc000
    80001258:	85b2                	mv	a1,a2
    8000125a:	8526                	mv	a0,s1
    8000125c:	00000097          	auipc	ra,0x0
    80001260:	f7a080e7          	jalr	-134(ra) # 800011d6 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001264:	4729                	li	a4,10
    80001266:	80007697          	auipc	a3,0x80007
    8000126a:	d9a68693          	addi	a3,a3,-614 # 8000 <_entry-0x7fff8000>
    8000126e:	4605                	li	a2,1
    80001270:	067e                	slli	a2,a2,0x1f
    80001272:	85b2                	mv	a1,a2
    80001274:	8526                	mv	a0,s1
    80001276:	00000097          	auipc	ra,0x0
    8000127a:	f60080e7          	jalr	-160(ra) # 800011d6 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000127e:	4719                	li	a4,6
    80001280:	00007697          	auipc	a3,0x7
    80001284:	d8068693          	addi	a3,a3,-640 # 80008000 <etext>
    80001288:	47c5                	li	a5,17
    8000128a:	07ee                	slli	a5,a5,0x1b
    8000128c:	40d786b3          	sub	a3,a5,a3
    80001290:	00007617          	auipc	a2,0x7
    80001294:	d7060613          	addi	a2,a2,-656 # 80008000 <etext>
    80001298:	85b2                	mv	a1,a2
    8000129a:	8526                	mv	a0,s1
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	f3a080e7          	jalr	-198(ra) # 800011d6 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012a4:	4729                	li	a4,10
    800012a6:	6685                	lui	a3,0x1
    800012a8:	00006617          	auipc	a2,0x6
    800012ac:	d5860613          	addi	a2,a2,-680 # 80007000 <_trampoline>
    800012b0:	040005b7          	lui	a1,0x4000
    800012b4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800012b6:	05b2                	slli	a1,a1,0xc
    800012b8:	8526                	mv	a0,s1
    800012ba:	00000097          	auipc	ra,0x0
    800012be:	f1c080e7          	jalr	-228(ra) # 800011d6 <kvmmap>
  proc_mapstacks(kpgtbl);
    800012c2:	8526                	mv	a0,s1
    800012c4:	00000097          	auipc	ra,0x0
    800012c8:	6ac080e7          	jalr	1708(ra) # 80001970 <proc_mapstacks>
}
    800012cc:	8526                	mv	a0,s1
    800012ce:	60e2                	ld	ra,24(sp)
    800012d0:	6442                	ld	s0,16(sp)
    800012d2:	64a2                	ld	s1,8(sp)
    800012d4:	6105                	addi	sp,sp,32
    800012d6:	8082                	ret

00000000800012d8 <kvminit>:
{
    800012d8:	1141                	addi	sp,sp,-16
    800012da:	e406                	sd	ra,8(sp)
    800012dc:	e022                	sd	s0,0(sp)
    800012de:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012e0:	00000097          	auipc	ra,0x0
    800012e4:	f26080e7          	jalr	-218(ra) # 80001206 <kvmmake>
    800012e8:	00007797          	auipc	a5,0x7
    800012ec:	5ca7b423          	sd	a0,1480(a5) # 800088b0 <kernel_pagetable>
}
    800012f0:	60a2                	ld	ra,8(sp)
    800012f2:	6402                	ld	s0,0(sp)
    800012f4:	0141                	addi	sp,sp,16
    800012f6:	8082                	ret

00000000800012f8 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012f8:	715d                	addi	sp,sp,-80
    800012fa:	e486                	sd	ra,72(sp)
    800012fc:	e0a2                	sd	s0,64(sp)
    800012fe:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001300:	03459793          	slli	a5,a1,0x34
    80001304:	e39d                	bnez	a5,8000132a <uvmunmap+0x32>
    80001306:	f84a                	sd	s2,48(sp)
    80001308:	f44e                	sd	s3,40(sp)
    8000130a:	f052                	sd	s4,32(sp)
    8000130c:	ec56                	sd	s5,24(sp)
    8000130e:	e85a                	sd	s6,16(sp)
    80001310:	e45e                	sd	s7,8(sp)
    80001312:	8a2a                	mv	s4,a0
    80001314:	892e                	mv	s2,a1
    80001316:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001318:	0632                	slli	a2,a2,0xc
    8000131a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000131e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001320:	6b05                	lui	s6,0x1
    80001322:	0935fb63          	bgeu	a1,s3,800013b8 <uvmunmap+0xc0>
    80001326:	fc26                	sd	s1,56(sp)
    80001328:	a8a9                	j	80001382 <uvmunmap+0x8a>
    8000132a:	fc26                	sd	s1,56(sp)
    8000132c:	f84a                	sd	s2,48(sp)
    8000132e:	f44e                	sd	s3,40(sp)
    80001330:	f052                	sd	s4,32(sp)
    80001332:	ec56                	sd	s5,24(sp)
    80001334:	e85a                	sd	s6,16(sp)
    80001336:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001338:	00007517          	auipc	a0,0x7
    8000133c:	da850513          	addi	a0,a0,-600 # 800080e0 <etext+0xe0>
    80001340:	fffff097          	auipc	ra,0xfffff
    80001344:	21e080e7          	jalr	542(ra) # 8000055e <panic>
      panic("uvmunmap: walk");
    80001348:	00007517          	auipc	a0,0x7
    8000134c:	db050513          	addi	a0,a0,-592 # 800080f8 <etext+0xf8>
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	20e080e7          	jalr	526(ra) # 8000055e <panic>
      panic("uvmunmap: not mapped");
    80001358:	00007517          	auipc	a0,0x7
    8000135c:	db050513          	addi	a0,a0,-592 # 80008108 <etext+0x108>
    80001360:	fffff097          	auipc	ra,0xfffff
    80001364:	1fe080e7          	jalr	510(ra) # 8000055e <panic>
      panic("uvmunmap: not a leaf");
    80001368:	00007517          	auipc	a0,0x7
    8000136c:	db850513          	addi	a0,a0,-584 # 80008120 <etext+0x120>
    80001370:	fffff097          	auipc	ra,0xfffff
    80001374:	1ee080e7          	jalr	494(ra) # 8000055e <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001378:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000137c:	995a                	add	s2,s2,s6
    8000137e:	03397c63          	bgeu	s2,s3,800013b6 <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001382:	4601                	li	a2,0
    80001384:	85ca                	mv	a1,s2
    80001386:	8552                	mv	a0,s4
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	cc8080e7          	jalr	-824(ra) # 80001050 <walk>
    80001390:	84aa                	mv	s1,a0
    80001392:	d95d                	beqz	a0,80001348 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80001394:	6108                	ld	a0,0(a0)
    80001396:	00157793          	andi	a5,a0,1
    8000139a:	dfdd                	beqz	a5,80001358 <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000139c:	3ff57793          	andi	a5,a0,1023
    800013a0:	fd7784e3          	beq	a5,s7,80001368 <uvmunmap+0x70>
    if(do_free){
    800013a4:	fc0a8ae3          	beqz	s5,80001378 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    800013a8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013aa:	0532                	slli	a0,a0,0xc
    800013ac:	fffff097          	auipc	ra,0xfffff
    800013b0:	6a8080e7          	jalr	1704(ra) # 80000a54 <kfree>
    800013b4:	b7d1                	j	80001378 <uvmunmap+0x80>
    800013b6:	74e2                	ld	s1,56(sp)
    800013b8:	7942                	ld	s2,48(sp)
    800013ba:	79a2                	ld	s3,40(sp)
    800013bc:	7a02                	ld	s4,32(sp)
    800013be:	6ae2                	ld	s5,24(sp)
    800013c0:	6b42                	ld	s6,16(sp)
    800013c2:	6ba2                	ld	s7,8(sp)
  }
}
    800013c4:	60a6                	ld	ra,72(sp)
    800013c6:	6406                	ld	s0,64(sp)
    800013c8:	6161                	addi	sp,sp,80
    800013ca:	8082                	ret

00000000800013cc <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013cc:	1101                	addi	sp,sp,-32
    800013ce:	ec06                	sd	ra,24(sp)
    800013d0:	e822                	sd	s0,16(sp)
    800013d2:	e426                	sd	s1,8(sp)
    800013d4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013d6:	fffff097          	auipc	ra,0xfffff
    800013da:	782080e7          	jalr	1922(ra) # 80000b58 <kalloc>
    800013de:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013e0:	c519                	beqz	a0,800013ee <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013e2:	6605                	lui	a2,0x1
    800013e4:	4581                	li	a1,0
    800013e6:	00000097          	auipc	ra,0x0
    800013ea:	96e080e7          	jalr	-1682(ra) # 80000d54 <memset>
  return pagetable;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret

00000000800013fa <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013fa:	7179                	addi	sp,sp,-48
    800013fc:	f406                	sd	ra,40(sp)
    800013fe:	f022                	sd	s0,32(sp)
    80001400:	ec26                	sd	s1,24(sp)
    80001402:	e84a                	sd	s2,16(sp)
    80001404:	e44e                	sd	s3,8(sp)
    80001406:	e052                	sd	s4,0(sp)
    80001408:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000140a:	6785                	lui	a5,0x1
    8000140c:	04f67863          	bgeu	a2,a5,8000145c <uvmfirst+0x62>
    80001410:	89aa                	mv	s3,a0
    80001412:	8a2e                	mv	s4,a1
    80001414:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001416:	fffff097          	auipc	ra,0xfffff
    8000141a:	742080e7          	jalr	1858(ra) # 80000b58 <kalloc>
    8000141e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001420:	6605                	lui	a2,0x1
    80001422:	4581                	li	a1,0
    80001424:	00000097          	auipc	ra,0x0
    80001428:	930080e7          	jalr	-1744(ra) # 80000d54 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000142c:	4779                	li	a4,30
    8000142e:	86ca                	mv	a3,s2
    80001430:	6605                	lui	a2,0x1
    80001432:	4581                	li	a1,0
    80001434:	854e                	mv	a0,s3
    80001436:	00000097          	auipc	ra,0x0
    8000143a:	cfe080e7          	jalr	-770(ra) # 80001134 <mappages>
  memmove(mem, src, sz);
    8000143e:	8626                	mv	a2,s1
    80001440:	85d2                	mv	a1,s4
    80001442:	854a                	mv	a0,s2
    80001444:	00000097          	auipc	ra,0x0
    80001448:	970080e7          	jalr	-1680(ra) # 80000db4 <memmove>
}
    8000144c:	70a2                	ld	ra,40(sp)
    8000144e:	7402                	ld	s0,32(sp)
    80001450:	64e2                	ld	s1,24(sp)
    80001452:	6942                	ld	s2,16(sp)
    80001454:	69a2                	ld	s3,8(sp)
    80001456:	6a02                	ld	s4,0(sp)
    80001458:	6145                	addi	sp,sp,48
    8000145a:	8082                	ret
    panic("uvmfirst: more than a page");
    8000145c:	00007517          	auipc	a0,0x7
    80001460:	cdc50513          	addi	a0,a0,-804 # 80008138 <etext+0x138>
    80001464:	fffff097          	auipc	ra,0xfffff
    80001468:	0fa080e7          	jalr	250(ra) # 8000055e <panic>

000000008000146c <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000146c:	1101                	addi	sp,sp,-32
    8000146e:	ec06                	sd	ra,24(sp)
    80001470:	e822                	sd	s0,16(sp)
    80001472:	e426                	sd	s1,8(sp)
    80001474:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001476:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001478:	00b67d63          	bgeu	a2,a1,80001492 <uvmdealloc+0x26>
    8000147c:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000147e:	6785                	lui	a5,0x1
    80001480:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001482:	00f60733          	add	a4,a2,a5
    80001486:	76fd                	lui	a3,0xfffff
    80001488:	8f75                	and	a4,a4,a3
    8000148a:	97ae                	add	a5,a5,a1
    8000148c:	8ff5                	and	a5,a5,a3
    8000148e:	00f76863          	bltu	a4,a5,8000149e <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001492:	8526                	mv	a0,s1
    80001494:	60e2                	ld	ra,24(sp)
    80001496:	6442                	ld	s0,16(sp)
    80001498:	64a2                	ld	s1,8(sp)
    8000149a:	6105                	addi	sp,sp,32
    8000149c:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000149e:	8f99                	sub	a5,a5,a4
    800014a0:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014a2:	4685                	li	a3,1
    800014a4:	0007861b          	sext.w	a2,a5
    800014a8:	85ba                	mv	a1,a4
    800014aa:	00000097          	auipc	ra,0x0
    800014ae:	e4e080e7          	jalr	-434(ra) # 800012f8 <uvmunmap>
    800014b2:	b7c5                	j	80001492 <uvmdealloc+0x26>

00000000800014b4 <uvmalloc>:
  if(newsz < oldsz)
    800014b4:	0ab66d63          	bltu	a2,a1,8000156e <uvmalloc+0xba>
{
    800014b8:	715d                	addi	sp,sp,-80
    800014ba:	e486                	sd	ra,72(sp)
    800014bc:	e0a2                	sd	s0,64(sp)
    800014be:	f84a                	sd	s2,48(sp)
    800014c0:	f052                	sd	s4,32(sp)
    800014c2:	ec56                	sd	s5,24(sp)
    800014c4:	e45e                	sd	s7,8(sp)
    800014c6:	0880                	addi	s0,sp,80
    800014c8:	8aaa                	mv	s5,a0
    800014ca:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014cc:	6785                	lui	a5,0x1
    800014ce:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014d0:	95be                	add	a1,a1,a5
    800014d2:	77fd                	lui	a5,0xfffff
    800014d4:	00f5f933          	and	s2,a1,a5
    800014d8:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014da:	08c97c63          	bgeu	s2,a2,80001572 <uvmalloc+0xbe>
    800014de:	fc26                	sd	s1,56(sp)
    800014e0:	f44e                	sd	s3,40(sp)
    800014e2:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    800014e4:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014e6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800014ea:	fffff097          	auipc	ra,0xfffff
    800014ee:	66e080e7          	jalr	1646(ra) # 80000b58 <kalloc>
    800014f2:	84aa                	mv	s1,a0
    if(mem == 0){
    800014f4:	c90d                	beqz	a0,80001526 <uvmalloc+0x72>
    memset(mem, 0, PGSIZE);
    800014f6:	864e                	mv	a2,s3
    800014f8:	4581                	li	a1,0
    800014fa:	00000097          	auipc	ra,0x0
    800014fe:	85a080e7          	jalr	-1958(ra) # 80000d54 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001502:	875a                	mv	a4,s6
    80001504:	86a6                	mv	a3,s1
    80001506:	864e                	mv	a2,s3
    80001508:	85ca                	mv	a1,s2
    8000150a:	8556                	mv	a0,s5
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	c28080e7          	jalr	-984(ra) # 80001134 <mappages>
    80001514:	ed05                	bnez	a0,8000154c <uvmalloc+0x98>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001516:	994e                	add	s2,s2,s3
    80001518:	fd4969e3          	bltu	s2,s4,800014ea <uvmalloc+0x36>
  return newsz;
    8000151c:	8552                	mv	a0,s4
    8000151e:	74e2                	ld	s1,56(sp)
    80001520:	79a2                	ld	s3,40(sp)
    80001522:	6b42                	ld	s6,16(sp)
    80001524:	a821                	j	8000153c <uvmalloc+0x88>
      uvmdealloc(pagetable, a, oldsz);
    80001526:	865e                	mv	a2,s7
    80001528:	85ca                	mv	a1,s2
    8000152a:	8556                	mv	a0,s5
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	f40080e7          	jalr	-192(ra) # 8000146c <uvmdealloc>
      return 0;
    80001534:	4501                	li	a0,0
    80001536:	74e2                	ld	s1,56(sp)
    80001538:	79a2                	ld	s3,40(sp)
    8000153a:	6b42                	ld	s6,16(sp)
}
    8000153c:	60a6                	ld	ra,72(sp)
    8000153e:	6406                	ld	s0,64(sp)
    80001540:	7942                	ld	s2,48(sp)
    80001542:	7a02                	ld	s4,32(sp)
    80001544:	6ae2                	ld	s5,24(sp)
    80001546:	6ba2                	ld	s7,8(sp)
    80001548:	6161                	addi	sp,sp,80
    8000154a:	8082                	ret
      kfree(mem);
    8000154c:	8526                	mv	a0,s1
    8000154e:	fffff097          	auipc	ra,0xfffff
    80001552:	506080e7          	jalr	1286(ra) # 80000a54 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001556:	865e                	mv	a2,s7
    80001558:	85ca                	mv	a1,s2
    8000155a:	8556                	mv	a0,s5
    8000155c:	00000097          	auipc	ra,0x0
    80001560:	f10080e7          	jalr	-240(ra) # 8000146c <uvmdealloc>
      return 0;
    80001564:	4501                	li	a0,0
    80001566:	74e2                	ld	s1,56(sp)
    80001568:	79a2                	ld	s3,40(sp)
    8000156a:	6b42                	ld	s6,16(sp)
    8000156c:	bfc1                	j	8000153c <uvmalloc+0x88>
    return oldsz;
    8000156e:	852e                	mv	a0,a1
}
    80001570:	8082                	ret
  return newsz;
    80001572:	8532                	mv	a0,a2
    80001574:	b7e1                	j	8000153c <uvmalloc+0x88>

0000000080001576 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001576:	7179                	addi	sp,sp,-48
    80001578:	f406                	sd	ra,40(sp)
    8000157a:	f022                	sd	s0,32(sp)
    8000157c:	ec26                	sd	s1,24(sp)
    8000157e:	e84a                	sd	s2,16(sp)
    80001580:	e44e                	sd	s3,8(sp)
    80001582:	1800                	addi	s0,sp,48
    80001584:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001586:	84aa                	mv	s1,a0
    80001588:	6905                	lui	s2,0x1
    8000158a:	992a                	add	s2,s2,a0
    8000158c:	a821                	j	800015a4 <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    8000158e:	00007517          	auipc	a0,0x7
    80001592:	bca50513          	addi	a0,a0,-1078 # 80008158 <etext+0x158>
    80001596:	fffff097          	auipc	ra,0xfffff
    8000159a:	fc8080e7          	jalr	-56(ra) # 8000055e <panic>
  for(int i = 0; i < 512; i++){
    8000159e:	04a1                	addi	s1,s1,8
    800015a0:	03248363          	beq	s1,s2,800015c6 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015a4:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015a6:	0017f713          	andi	a4,a5,1
    800015aa:	db75                	beqz	a4,8000159e <freewalk+0x28>
    800015ac:	00e7f713          	andi	a4,a5,14
    800015b0:	ff79                	bnez	a4,8000158e <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800015b2:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800015b4:	00c79513          	slli	a0,a5,0xc
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	fbe080e7          	jalr	-66(ra) # 80001576 <freewalk>
      pagetable[i] = 0;
    800015c0:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015c4:	bfe9                	j	8000159e <freewalk+0x28>
    }
  }
  kfree((void*)pagetable);
    800015c6:	854e                	mv	a0,s3
    800015c8:	fffff097          	auipc	ra,0xfffff
    800015cc:	48c080e7          	jalr	1164(ra) # 80000a54 <kfree>
}
    800015d0:	70a2                	ld	ra,40(sp)
    800015d2:	7402                	ld	s0,32(sp)
    800015d4:	64e2                	ld	s1,24(sp)
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	69a2                	ld	s3,8(sp)
    800015da:	6145                	addi	sp,sp,48
    800015dc:	8082                	ret

00000000800015de <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015de:	1101                	addi	sp,sp,-32
    800015e0:	ec06                	sd	ra,24(sp)
    800015e2:	e822                	sd	s0,16(sp)
    800015e4:	e426                	sd	s1,8(sp)
    800015e6:	1000                	addi	s0,sp,32
    800015e8:	84aa                	mv	s1,a0
  if(sz > 0)
    800015ea:	e999                	bnez	a1,80001600 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015ec:	8526                	mv	a0,s1
    800015ee:	00000097          	auipc	ra,0x0
    800015f2:	f88080e7          	jalr	-120(ra) # 80001576 <freewalk>
}
    800015f6:	60e2                	ld	ra,24(sp)
    800015f8:	6442                	ld	s0,16(sp)
    800015fa:	64a2                	ld	s1,8(sp)
    800015fc:	6105                	addi	sp,sp,32
    800015fe:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001600:	6785                	lui	a5,0x1
    80001602:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001604:	95be                	add	a1,a1,a5
    80001606:	4685                	li	a3,1
    80001608:	00c5d613          	srli	a2,a1,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	00000097          	auipc	ra,0x0
    80001612:	cea080e7          	jalr	-790(ra) # 800012f8 <uvmunmap>
    80001616:	bfd9                	j	800015ec <uvmfree+0xe>

0000000080001618 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001618:	c669                	beqz	a2,800016e2 <uvmcopy+0xca>
{
    8000161a:	715d                	addi	sp,sp,-80
    8000161c:	e486                	sd	ra,72(sp)
    8000161e:	e0a2                	sd	s0,64(sp)
    80001620:	fc26                	sd	s1,56(sp)
    80001622:	f84a                	sd	s2,48(sp)
    80001624:	f44e                	sd	s3,40(sp)
    80001626:	f052                	sd	s4,32(sp)
    80001628:	ec56                	sd	s5,24(sp)
    8000162a:	e85a                	sd	s6,16(sp)
    8000162c:	e45e                	sd	s7,8(sp)
    8000162e:	0880                	addi	s0,sp,80
    80001630:	8b2a                	mv	s6,a0
    80001632:	8aae                	mv	s5,a1
    80001634:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001636:	4901                	li	s2,0
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001638:	6985                	lui	s3,0x1
    if((pte = walk(old, i, 0)) == 0)
    8000163a:	4601                	li	a2,0
    8000163c:	85ca                	mv	a1,s2
    8000163e:	855a                	mv	a0,s6
    80001640:	00000097          	auipc	ra,0x0
    80001644:	a10080e7          	jalr	-1520(ra) # 80001050 <walk>
    80001648:	c139                	beqz	a0,8000168e <uvmcopy+0x76>
    if((*pte & PTE_V) == 0)
    8000164a:	00053b83          	ld	s7,0(a0)
    8000164e:	001bf793          	andi	a5,s7,1
    80001652:	c7b1                	beqz	a5,8000169e <uvmcopy+0x86>
    if((mem = kalloc()) == 0)
    80001654:	fffff097          	auipc	ra,0xfffff
    80001658:	504080e7          	jalr	1284(ra) # 80000b58 <kalloc>
    8000165c:	84aa                	mv	s1,a0
    8000165e:	cd29                	beqz	a0,800016b8 <uvmcopy+0xa0>
    pa = PTE2PA(*pte);
    80001660:	00abd593          	srli	a1,s7,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001664:	864e                	mv	a2,s3
    80001666:	05b2                	slli	a1,a1,0xc
    80001668:	fffff097          	auipc	ra,0xfffff
    8000166c:	74c080e7          	jalr	1868(ra) # 80000db4 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001670:	3ffbf713          	andi	a4,s7,1023
    80001674:	86a6                	mv	a3,s1
    80001676:	864e                	mv	a2,s3
    80001678:	85ca                	mv	a1,s2
    8000167a:	8556                	mv	a0,s5
    8000167c:	00000097          	auipc	ra,0x0
    80001680:	ab8080e7          	jalr	-1352(ra) # 80001134 <mappages>
    80001684:	e50d                	bnez	a0,800016ae <uvmcopy+0x96>
  for(i = 0; i < sz; i += PGSIZE){
    80001686:	994e                	add	s2,s2,s3
    80001688:	fb4969e3          	bltu	s2,s4,8000163a <uvmcopy+0x22>
    8000168c:	a081                	j	800016cc <uvmcopy+0xb4>
      panic("uvmcopy: pte should exist");
    8000168e:	00007517          	auipc	a0,0x7
    80001692:	ada50513          	addi	a0,a0,-1318 # 80008168 <etext+0x168>
    80001696:	fffff097          	auipc	ra,0xfffff
    8000169a:	ec8080e7          	jalr	-312(ra) # 8000055e <panic>
      panic("uvmcopy: page not present");
    8000169e:	00007517          	auipc	a0,0x7
    800016a2:	aea50513          	addi	a0,a0,-1302 # 80008188 <etext+0x188>
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	eb8080e7          	jalr	-328(ra) # 8000055e <panic>
      kfree(mem);
    800016ae:	8526                	mv	a0,s1
    800016b0:	fffff097          	auipc	ra,0xfffff
    800016b4:	3a4080e7          	jalr	932(ra) # 80000a54 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016b8:	4685                	li	a3,1
    800016ba:	00c95613          	srli	a2,s2,0xc
    800016be:	4581                	li	a1,0
    800016c0:	8556                	mv	a0,s5
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	c36080e7          	jalr	-970(ra) # 800012f8 <uvmunmap>
  return -1;
    800016ca:	557d                	li	a0,-1
}
    800016cc:	60a6                	ld	ra,72(sp)
    800016ce:	6406                	ld	s0,64(sp)
    800016d0:	74e2                	ld	s1,56(sp)
    800016d2:	7942                	ld	s2,48(sp)
    800016d4:	79a2                	ld	s3,40(sp)
    800016d6:	7a02                	ld	s4,32(sp)
    800016d8:	6ae2                	ld	s5,24(sp)
    800016da:	6b42                	ld	s6,16(sp)
    800016dc:	6ba2                	ld	s7,8(sp)
    800016de:	6161                	addi	sp,sp,80
    800016e0:	8082                	ret
  return 0;
    800016e2:	4501                	li	a0,0
}
    800016e4:	8082                	ret

00000000800016e6 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016e6:	1141                	addi	sp,sp,-16
    800016e8:	e406                	sd	ra,8(sp)
    800016ea:	e022                	sd	s0,0(sp)
    800016ec:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016ee:	4601                	li	a2,0
    800016f0:	00000097          	auipc	ra,0x0
    800016f4:	960080e7          	jalr	-1696(ra) # 80001050 <walk>
  if(pte == 0)
    800016f8:	c901                	beqz	a0,80001708 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016fa:	611c                	ld	a5,0(a0)
    800016fc:	9bbd                	andi	a5,a5,-17
    800016fe:	e11c                	sd	a5,0(a0)
}
    80001700:	60a2                	ld	ra,8(sp)
    80001702:	6402                	ld	s0,0(sp)
    80001704:	0141                	addi	sp,sp,16
    80001706:	8082                	ret
    panic("uvmclear");
    80001708:	00007517          	auipc	a0,0x7
    8000170c:	aa050513          	addi	a0,a0,-1376 # 800081a8 <etext+0x1a8>
    80001710:	fffff097          	auipc	ra,0xfffff
    80001714:	e4e080e7          	jalr	-434(ra) # 8000055e <panic>

0000000080001718 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001718:	c6bd                	beqz	a3,80001786 <copyout+0x6e>
{
    8000171a:	715d                	addi	sp,sp,-80
    8000171c:	e486                	sd	ra,72(sp)
    8000171e:	e0a2                	sd	s0,64(sp)
    80001720:	fc26                	sd	s1,56(sp)
    80001722:	f84a                	sd	s2,48(sp)
    80001724:	f44e                	sd	s3,40(sp)
    80001726:	f052                	sd	s4,32(sp)
    80001728:	ec56                	sd	s5,24(sp)
    8000172a:	e85a                	sd	s6,16(sp)
    8000172c:	e45e                	sd	s7,8(sp)
    8000172e:	e062                	sd	s8,0(sp)
    80001730:	0880                	addi	s0,sp,80
    80001732:	8b2a                	mv	s6,a0
    80001734:	8c2e                	mv	s8,a1
    80001736:	8a32                	mv	s4,a2
    80001738:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000173a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000173c:	6a85                	lui	s5,0x1
    8000173e:	a015                	j	80001762 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001740:	9562                	add	a0,a0,s8
    80001742:	0004861b          	sext.w	a2,s1
    80001746:	85d2                	mv	a1,s4
    80001748:	41250533          	sub	a0,a0,s2
    8000174c:	fffff097          	auipc	ra,0xfffff
    80001750:	668080e7          	jalr	1640(ra) # 80000db4 <memmove>

    len -= n;
    80001754:	409989b3          	sub	s3,s3,s1
    src += n;
    80001758:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000175a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000175e:	02098263          	beqz	s3,80001782 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001762:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001766:	85ca                	mv	a1,s2
    80001768:	855a                	mv	a0,s6
    8000176a:	00000097          	auipc	ra,0x0
    8000176e:	98c080e7          	jalr	-1652(ra) # 800010f6 <walkaddr>
    if(pa0 == 0)
    80001772:	cd01                	beqz	a0,8000178a <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001774:	418904b3          	sub	s1,s2,s8
    80001778:	94d6                	add	s1,s1,s5
    if(n > len)
    8000177a:	fc99f3e3          	bgeu	s3,s1,80001740 <copyout+0x28>
    8000177e:	84ce                	mv	s1,s3
    80001780:	b7c1                	j	80001740 <copyout+0x28>
  }
  return 0;
    80001782:	4501                	li	a0,0
    80001784:	a021                	j	8000178c <copyout+0x74>
    80001786:	4501                	li	a0,0
}
    80001788:	8082                	ret
      return -1;
    8000178a:	557d                	li	a0,-1
}
    8000178c:	60a6                	ld	ra,72(sp)
    8000178e:	6406                	ld	s0,64(sp)
    80001790:	74e2                	ld	s1,56(sp)
    80001792:	7942                	ld	s2,48(sp)
    80001794:	79a2                	ld	s3,40(sp)
    80001796:	7a02                	ld	s4,32(sp)
    80001798:	6ae2                	ld	s5,24(sp)
    8000179a:	6b42                	ld	s6,16(sp)
    8000179c:	6ba2                	ld	s7,8(sp)
    8000179e:	6c02                	ld	s8,0(sp)
    800017a0:	6161                	addi	sp,sp,80
    800017a2:	8082                	ret

00000000800017a4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017a4:	caa5                	beqz	a3,80001814 <copyin+0x70>
{
    800017a6:	715d                	addi	sp,sp,-80
    800017a8:	e486                	sd	ra,72(sp)
    800017aa:	e0a2                	sd	s0,64(sp)
    800017ac:	fc26                	sd	s1,56(sp)
    800017ae:	f84a                	sd	s2,48(sp)
    800017b0:	f44e                	sd	s3,40(sp)
    800017b2:	f052                	sd	s4,32(sp)
    800017b4:	ec56                	sd	s5,24(sp)
    800017b6:	e85a                	sd	s6,16(sp)
    800017b8:	e45e                	sd	s7,8(sp)
    800017ba:	e062                	sd	s8,0(sp)
    800017bc:	0880                	addi	s0,sp,80
    800017be:	8b2a                	mv	s6,a0
    800017c0:	8a2e                	mv	s4,a1
    800017c2:	8c32                	mv	s8,a2
    800017c4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017c6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017c8:	6a85                	lui	s5,0x1
    800017ca:	a01d                	j	800017f0 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017cc:	018505b3          	add	a1,a0,s8
    800017d0:	0004861b          	sext.w	a2,s1
    800017d4:	412585b3          	sub	a1,a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	fffff097          	auipc	ra,0xfffff
    800017de:	5da080e7          	jalr	1498(ra) # 80000db4 <memmove>

    len -= n;
    800017e2:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017e6:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017e8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017ec:	02098263          	beqz	s3,80001810 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017f0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017f4:	85ca                	mv	a1,s2
    800017f6:	855a                	mv	a0,s6
    800017f8:	00000097          	auipc	ra,0x0
    800017fc:	8fe080e7          	jalr	-1794(ra) # 800010f6 <walkaddr>
    if(pa0 == 0)
    80001800:	cd01                	beqz	a0,80001818 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001802:	418904b3          	sub	s1,s2,s8
    80001806:	94d6                	add	s1,s1,s5
    if(n > len)
    80001808:	fc99f2e3          	bgeu	s3,s1,800017cc <copyin+0x28>
    8000180c:	84ce                	mv	s1,s3
    8000180e:	bf7d                	j	800017cc <copyin+0x28>
  }
  return 0;
    80001810:	4501                	li	a0,0
    80001812:	a021                	j	8000181a <copyin+0x76>
    80001814:	4501                	li	a0,0
}
    80001816:	8082                	ret
      return -1;
    80001818:	557d                	li	a0,-1
}
    8000181a:	60a6                	ld	ra,72(sp)
    8000181c:	6406                	ld	s0,64(sp)
    8000181e:	74e2                	ld	s1,56(sp)
    80001820:	7942                	ld	s2,48(sp)
    80001822:	79a2                	ld	s3,40(sp)
    80001824:	7a02                	ld	s4,32(sp)
    80001826:	6ae2                	ld	s5,24(sp)
    80001828:	6b42                	ld	s6,16(sp)
    8000182a:	6ba2                	ld	s7,8(sp)
    8000182c:	6c02                	ld	s8,0(sp)
    8000182e:	6161                	addi	sp,sp,80
    80001830:	8082                	ret

0000000080001832 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001832:	cad5                	beqz	a3,800018e6 <copyinstr+0xb4>
{
    80001834:	715d                	addi	sp,sp,-80
    80001836:	e486                	sd	ra,72(sp)
    80001838:	e0a2                	sd	s0,64(sp)
    8000183a:	fc26                	sd	s1,56(sp)
    8000183c:	f84a                	sd	s2,48(sp)
    8000183e:	f44e                	sd	s3,40(sp)
    80001840:	f052                	sd	s4,32(sp)
    80001842:	ec56                	sd	s5,24(sp)
    80001844:	e85a                	sd	s6,16(sp)
    80001846:	e45e                	sd	s7,8(sp)
    80001848:	0880                	addi	s0,sp,80
    8000184a:	8aaa                	mv	s5,a0
    8000184c:	84ae                	mv	s1,a1
    8000184e:	8bb2                	mv	s7,a2
    80001850:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001852:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001854:	6a05                	lui	s4,0x1
    80001856:	a82d                	j	80001890 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001858:	00078023          	sb	zero,0(a5)
        got_null = 1;
    8000185c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000185e:	0017c793          	xori	a5,a5,1
    80001862:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001866:	60a6                	ld	ra,72(sp)
    80001868:	6406                	ld	s0,64(sp)
    8000186a:	74e2                	ld	s1,56(sp)
    8000186c:	7942                	ld	s2,48(sp)
    8000186e:	79a2                	ld	s3,40(sp)
    80001870:	7a02                	ld	s4,32(sp)
    80001872:	6ae2                	ld	s5,24(sp)
    80001874:	6b42                	ld	s6,16(sp)
    80001876:	6ba2                	ld	s7,8(sp)
    80001878:	6161                	addi	sp,sp,80
    8000187a:	8082                	ret
    8000187c:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001880:	9726                	add	a4,a4,s1
      --max;
    80001882:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    80001886:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    8000188a:	04e58663          	beq	a1,a4,800018d6 <copyinstr+0xa4>
{
    8000188e:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001890:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001894:	85ca                	mv	a1,s2
    80001896:	8556                	mv	a0,s5
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	85e080e7          	jalr	-1954(ra) # 800010f6 <walkaddr>
    if(pa0 == 0)
    800018a0:	cd0d                	beqz	a0,800018da <copyinstr+0xa8>
    n = PGSIZE - (srcva - va0);
    800018a2:	417906b3          	sub	a3,s2,s7
    800018a6:	96d2                	add	a3,a3,s4
    if(n > max)
    800018a8:	00d9f363          	bgeu	s3,a3,800018ae <copyinstr+0x7c>
    800018ac:	86ce                	mv	a3,s3
    while(n > 0){
    800018ae:	ca85                	beqz	a3,800018de <copyinstr+0xac>
    char *p = (char *) (pa0 + (srcva - va0));
    800018b0:	01750633          	add	a2,a0,s7
    800018b4:	41260633          	sub	a2,a2,s2
    800018b8:	87a6                	mv	a5,s1
      if(*p == '\0'){
    800018ba:	8e05                	sub	a2,a2,s1
    while(n > 0){
    800018bc:	96a6                	add	a3,a3,s1
    800018be:	85be                	mv	a1,a5
      if(*p == '\0'){
    800018c0:	00f60733          	add	a4,a2,a5
    800018c4:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdcec0>
    800018c8:	db41                	beqz	a4,80001858 <copyinstr+0x26>
        *dst = *p;
    800018ca:	00e78023          	sb	a4,0(a5)
      dst++;
    800018ce:	0785                	addi	a5,a5,1
    while(n > 0){
    800018d0:	fed797e3          	bne	a5,a3,800018be <copyinstr+0x8c>
    800018d4:	b765                	j	8000187c <copyinstr+0x4a>
    800018d6:	4781                	li	a5,0
    800018d8:	b759                	j	8000185e <copyinstr+0x2c>
      return -1;
    800018da:	557d                	li	a0,-1
    800018dc:	b769                	j	80001866 <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800018de:	6b85                	lui	s7,0x1
    800018e0:	9bca                	add	s7,s7,s2
    800018e2:	87a6                	mv	a5,s1
    800018e4:	b76d                	j	8000188e <copyinstr+0x5c>
  int got_null = 0;
    800018e6:	4781                	li	a5,0
  if(got_null){
    800018e8:	0017c793          	xori	a5,a5,1
    800018ec:	40f0053b          	negw	a0,a5
}
    800018f0:	8082                	ret

00000000800018f2 <findMinAccum>:
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;


long long findMinAccum(struct proc *skip){
    800018f2:	7139                	addi	sp,sp,-64
    800018f4:	fc06                	sd	ra,56(sp)
    800018f6:	f822                	sd	s0,48(sp)
    800018f8:	f426                	sd	s1,40(sp)
    800018fa:	f04a                	sd	s2,32(sp)
    800018fc:	ec4e                	sd	s3,24(sp)
    800018fe:	e852                	sd	s4,16(sp)
    80001900:	e456                	sd	s5,8(sp)
    80001902:	e05a                	sd	s6,0(sp)
    80001904:	0080                	addi	s0,sp,64
    80001906:	892a                	mv	s2,a0
  struct proc *temp;
  long long min = -1;
    80001908:	5afd                	li	s5,-1
  for(temp = proc; temp < &proc[NPROC]; temp++){
    8000190a:	0000f497          	auipc	s1,0xf
    8000190e:	65648493          	addi	s1,s1,1622 # 80010f60 <proc>
    if(temp == skip) 
      continue;
    acquire(&temp->lock);
    if(temp->state == RUNNABLE || temp->state == RUNNING){
    80001912:	4a05                	li	s4,1
      if(min == -1 || temp->accumulator < min){
    80001914:	8b56                	mv	s6,s5
  for(temp = proc; temp < &proc[NPROC]; temp++){
    80001916:	00015997          	auipc	s3,0x15
    8000191a:	44a98993          	addi	s3,s3,1098 # 80016d60 <tickslock>
    8000191e:	a821                	j	80001936 <findMinAccum+0x44>
        min = temp->accumulator;
    80001920:	1684ba83          	ld	s5,360(s1)
      }
    }
    release(&temp->lock);
    80001924:	8526                	mv	a0,s1
    80001926:	fffff097          	auipc	ra,0xfffff
    8000192a:	3e6080e7          	jalr	998(ra) # 80000d0c <release>
  for(temp = proc; temp < &proc[NPROC]; temp++){
    8000192e:	17848493          	addi	s1,s1,376
    80001932:	03348463          	beq	s1,s3,8000195a <findMinAccum+0x68>
    if(temp == skip) 
    80001936:	fe990ce3          	beq	s2,s1,8000192e <findMinAccum+0x3c>
    acquire(&temp->lock);
    8000193a:	8526                	mv	a0,s1
    8000193c:	fffff097          	auipc	ra,0xfffff
    80001940:	320080e7          	jalr	800(ra) # 80000c5c <acquire>
    if(temp->state == RUNNABLE || temp->state == RUNNING){
    80001944:	4c9c                	lw	a5,24(s1)
    80001946:	37f5                	addiw	a5,a5,-3
    80001948:	fcfa6ee3          	bltu	s4,a5,80001924 <findMinAccum+0x32>
      if(min == -1 || temp->accumulator < min){
    8000194c:	fd6a8ae3          	beq	s5,s6,80001920 <findMinAccum+0x2e>
    80001950:	1684b783          	ld	a5,360(s1)
    80001954:	fd57d8e3          	bge	a5,s5,80001924 <findMinAccum+0x32>
    80001958:	b7e1                	j	80001920 <findMinAccum+0x2e>
  }
  return min;
}
    8000195a:	8556                	mv	a0,s5
    8000195c:	70e2                	ld	ra,56(sp)
    8000195e:	7442                	ld	s0,48(sp)
    80001960:	74a2                	ld	s1,40(sp)
    80001962:	7902                	ld	s2,32(sp)
    80001964:	69e2                	ld	s3,24(sp)
    80001966:	6a42                	ld	s4,16(sp)
    80001968:	6aa2                	ld	s5,8(sp)
    8000196a:	6b02                	ld	s6,0(sp)
    8000196c:	6121                	addi	sp,sp,64
    8000196e:	8082                	ret

0000000080001970 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001970:	715d                	addi	sp,sp,-80
    80001972:	e486                	sd	ra,72(sp)
    80001974:	e0a2                	sd	s0,64(sp)
    80001976:	fc26                	sd	s1,56(sp)
    80001978:	f84a                	sd	s2,48(sp)
    8000197a:	f44e                	sd	s3,40(sp)
    8000197c:	f052                	sd	s4,32(sp)
    8000197e:	ec56                	sd	s5,24(sp)
    80001980:	e85a                	sd	s6,16(sp)
    80001982:	e45e                	sd	s7,8(sp)
    80001984:	e062                	sd	s8,0(sp)
    80001986:	0880                	addi	s0,sp,80
    80001988:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000198a:	0000f497          	auipc	s1,0xf
    8000198e:	5d648493          	addi	s1,s1,1494 # 80010f60 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001992:	8c26                	mv	s8,s1
    80001994:	677d47b7          	lui	a5,0x677d4
    80001998:	6cf78793          	addi	a5,a5,1743 # 677d46cf <_entry-0x1882b931>
    8000199c:	51b3c937          	lui	s2,0x51b3c
    800019a0:	ea390913          	addi	s2,s2,-349 # 51b3bea3 <_entry-0x2e4c415d>
    800019a4:	1902                	slli	s2,s2,0x20
    800019a6:	993e                	add	s2,s2,a5
    800019a8:	040009b7          	lui	s3,0x4000
    800019ac:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019ae:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019b0:	4b99                	li	s7,6
    800019b2:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b4:	00015a97          	auipc	s5,0x15
    800019b8:	3aca8a93          	addi	s5,s5,940 # 80016d60 <tickslock>
    char *pa = kalloc();
    800019bc:	fffff097          	auipc	ra,0xfffff
    800019c0:	19c080e7          	jalr	412(ra) # 80000b58 <kalloc>
    800019c4:	862a                	mv	a2,a0
    if(pa == 0)
    800019c6:	c131                	beqz	a0,80001a0a <proc_mapstacks+0x9a>
    uint64 va = KSTACK((int) (p - proc));
    800019c8:	418485b3          	sub	a1,s1,s8
    800019cc:	858d                	srai	a1,a1,0x3
    800019ce:	032585b3          	mul	a1,a1,s2
    800019d2:	05b6                	slli	a1,a1,0xd
    800019d4:	6789                	lui	a5,0x2
    800019d6:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019d8:	875e                	mv	a4,s7
    800019da:	86da                	mv	a3,s6
    800019dc:	40b985b3          	sub	a1,s3,a1
    800019e0:	8552                	mv	a0,s4
    800019e2:	fffff097          	auipc	ra,0xfffff
    800019e6:	7f4080e7          	jalr	2036(ra) # 800011d6 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ea:	17848493          	addi	s1,s1,376
    800019ee:	fd5497e3          	bne	s1,s5,800019bc <proc_mapstacks+0x4c>
  }
}
    800019f2:	60a6                	ld	ra,72(sp)
    800019f4:	6406                	ld	s0,64(sp)
    800019f6:	74e2                	ld	s1,56(sp)
    800019f8:	7942                	ld	s2,48(sp)
    800019fa:	79a2                	ld	s3,40(sp)
    800019fc:	7a02                	ld	s4,32(sp)
    800019fe:	6ae2                	ld	s5,24(sp)
    80001a00:	6b42                	ld	s6,16(sp)
    80001a02:	6ba2                	ld	s7,8(sp)
    80001a04:	6c02                	ld	s8,0(sp)
    80001a06:	6161                	addi	sp,sp,80
    80001a08:	8082                	ret
      panic("kalloc");
    80001a0a:	00006517          	auipc	a0,0x6
    80001a0e:	7ae50513          	addi	a0,a0,1966 # 800081b8 <etext+0x1b8>
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	b4c080e7          	jalr	-1204(ra) # 8000055e <panic>

0000000080001a1a <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001a1a:	7139                	addi	sp,sp,-64
    80001a1c:	fc06                	sd	ra,56(sp)
    80001a1e:	f822                	sd	s0,48(sp)
    80001a20:	f426                	sd	s1,40(sp)
    80001a22:	f04a                	sd	s2,32(sp)
    80001a24:	ec4e                	sd	s3,24(sp)
    80001a26:	e852                	sd	s4,16(sp)
    80001a28:	e456                	sd	s5,8(sp)
    80001a2a:	e05a                	sd	s6,0(sp)
    80001a2c:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001a2e:	00006597          	auipc	a1,0x6
    80001a32:	79258593          	addi	a1,a1,1938 # 800081c0 <etext+0x1c0>
    80001a36:	0000f517          	auipc	a0,0xf
    80001a3a:	0fa50513          	addi	a0,a0,250 # 80010b30 <pid_lock>
    80001a3e:	fffff097          	auipc	ra,0xfffff
    80001a42:	184080e7          	jalr	388(ra) # 80000bc2 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a46:	00006597          	auipc	a1,0x6
    80001a4a:	78258593          	addi	a1,a1,1922 # 800081c8 <etext+0x1c8>
    80001a4e:	0000f517          	auipc	a0,0xf
    80001a52:	0fa50513          	addi	a0,a0,250 # 80010b48 <wait_lock>
    80001a56:	fffff097          	auipc	ra,0xfffff
    80001a5a:	16c080e7          	jalr	364(ra) # 80000bc2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a5e:	0000f497          	auipc	s1,0xf
    80001a62:	50248493          	addi	s1,s1,1282 # 80010f60 <proc>
      initlock(&p->lock, "proc");
    80001a66:	00006b17          	auipc	s6,0x6
    80001a6a:	772b0b13          	addi	s6,s6,1906 # 800081d8 <etext+0x1d8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001a6e:	8aa6                	mv	s5,s1
    80001a70:	677d47b7          	lui	a5,0x677d4
    80001a74:	6cf78793          	addi	a5,a5,1743 # 677d46cf <_entry-0x1882b931>
    80001a78:	51b3c937          	lui	s2,0x51b3c
    80001a7c:	ea390913          	addi	s2,s2,-349 # 51b3bea3 <_entry-0x2e4c415d>
    80001a80:	1902                	slli	s2,s2,0x20
    80001a82:	993e                	add	s2,s2,a5
    80001a84:	040009b7          	lui	s3,0x4000
    80001a88:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a8a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a8c:	00015a17          	auipc	s4,0x15
    80001a90:	2d4a0a13          	addi	s4,s4,724 # 80016d60 <tickslock>
      initlock(&p->lock, "proc");
    80001a94:	85da                	mv	a1,s6
    80001a96:	8526                	mv	a0,s1
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	12a080e7          	jalr	298(ra) # 80000bc2 <initlock>
      p->state = UNUSED;
    80001aa0:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001aa4:	415487b3          	sub	a5,s1,s5
    80001aa8:	878d                	srai	a5,a5,0x3
    80001aaa:	032787b3          	mul	a5,a5,s2
    80001aae:	07b6                	slli	a5,a5,0xd
    80001ab0:	6709                	lui	a4,0x2
    80001ab2:	9fb9                	addw	a5,a5,a4
    80001ab4:	40f987b3          	sub	a5,s3,a5
    80001ab8:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aba:	17848493          	addi	s1,s1,376
    80001abe:	fd449be3          	bne	s1,s4,80001a94 <procinit+0x7a>
  }
}
    80001ac2:	70e2                	ld	ra,56(sp)
    80001ac4:	7442                	ld	s0,48(sp)
    80001ac6:	74a2                	ld	s1,40(sp)
    80001ac8:	7902                	ld	s2,32(sp)
    80001aca:	69e2                	ld	s3,24(sp)
    80001acc:	6a42                	ld	s4,16(sp)
    80001ace:	6aa2                	ld	s5,8(sp)
    80001ad0:	6b02                	ld	s6,0(sp)
    80001ad2:	6121                	addi	sp,sp,64
    80001ad4:	8082                	ret

0000000080001ad6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001ad6:	1141                	addi	sp,sp,-16
    80001ad8:	e406                	sd	ra,8(sp)
    80001ada:	e022                	sd	s0,0(sp)
    80001adc:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ade:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001ae0:	2501                	sext.w	a0,a0
    80001ae2:	60a2                	ld	ra,8(sp)
    80001ae4:	6402                	ld	s0,0(sp)
    80001ae6:	0141                	addi	sp,sp,16
    80001ae8:	8082                	ret

0000000080001aea <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001aea:	1141                	addi	sp,sp,-16
    80001aec:	e406                	sd	ra,8(sp)
    80001aee:	e022                	sd	s0,0(sp)
    80001af0:	0800                	addi	s0,sp,16
    80001af2:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001af4:	2781                	sext.w	a5,a5
    80001af6:	079e                	slli	a5,a5,0x7
  return c;
}
    80001af8:	0000f517          	auipc	a0,0xf
    80001afc:	06850513          	addi	a0,a0,104 # 80010b60 <cpus>
    80001b00:	953e                	add	a0,a0,a5
    80001b02:	60a2                	ld	ra,8(sp)
    80001b04:	6402                	ld	s0,0(sp)
    80001b06:	0141                	addi	sp,sp,16
    80001b08:	8082                	ret

0000000080001b0a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001b0a:	1101                	addi	sp,sp,-32
    80001b0c:	ec06                	sd	ra,24(sp)
    80001b0e:	e822                	sd	s0,16(sp)
    80001b10:	e426                	sd	s1,8(sp)
    80001b12:	1000                	addi	s0,sp,32
  push_off();
    80001b14:	fffff097          	auipc	ra,0xfffff
    80001b18:	0f8080e7          	jalr	248(ra) # 80000c0c <push_off>
    80001b1c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b1e:	2781                	sext.w	a5,a5
    80001b20:	079e                	slli	a5,a5,0x7
    80001b22:	0000f717          	auipc	a4,0xf
    80001b26:	00e70713          	addi	a4,a4,14 # 80010b30 <pid_lock>
    80001b2a:	97ba                	add	a5,a5,a4
    80001b2c:	7b9c                	ld	a5,48(a5)
    80001b2e:	84be                	mv	s1,a5
  pop_off();
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	180080e7          	jalr	384(ra) # 80000cb0 <pop_off>
  return p;
}
    80001b38:	8526                	mv	a0,s1
    80001b3a:	60e2                	ld	ra,24(sp)
    80001b3c:	6442                	ld	s0,16(sp)
    80001b3e:	64a2                	ld	s1,8(sp)
    80001b40:	6105                	addi	sp,sp,32
    80001b42:	8082                	ret

0000000080001b44 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b44:	1141                	addi	sp,sp,-16
    80001b46:	e406                	sd	ra,8(sp)
    80001b48:	e022                	sd	s0,0(sp)
    80001b4a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001b4c:	00000097          	auipc	ra,0x0
    80001b50:	fbe080e7          	jalr	-66(ra) # 80001b0a <myproc>
    80001b54:	fffff097          	auipc	ra,0xfffff
    80001b58:	1b8080e7          	jalr	440(ra) # 80000d0c <release>

  if (first) {
    80001b5c:	00007797          	auipc	a5,0x7
    80001b60:	ce47a783          	lw	a5,-796(a5) # 80008840 <first.1>
    80001b64:	eb89                	bnez	a5,80001b76 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b66:	00001097          	auipc	ra,0x1
    80001b6a:	cea080e7          	jalr	-790(ra) # 80002850 <usertrapret>
}
    80001b6e:	60a2                	ld	ra,8(sp)
    80001b70:	6402                	ld	s0,0(sp)
    80001b72:	0141                	addi	sp,sp,16
    80001b74:	8082                	ret
    first = 0;
    80001b76:	00007797          	auipc	a5,0x7
    80001b7a:	cc07a523          	sw	zero,-822(a5) # 80008840 <first.1>
    fsinit(ROOTDEV);
    80001b7e:	4505                	li	a0,1
    80001b80:	00002097          	auipc	ra,0x2
    80001b84:	a76080e7          	jalr	-1418(ra) # 800035f6 <fsinit>
    80001b88:	bff9                	j	80001b66 <forkret+0x22>

0000000080001b8a <allocpid>:
{
    80001b8a:	1101                	addi	sp,sp,-32
    80001b8c:	ec06                	sd	ra,24(sp)
    80001b8e:	e822                	sd	s0,16(sp)
    80001b90:	e426                	sd	s1,8(sp)
    80001b92:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b94:	0000f517          	auipc	a0,0xf
    80001b98:	f9c50513          	addi	a0,a0,-100 # 80010b30 <pid_lock>
    80001b9c:	fffff097          	auipc	ra,0xfffff
    80001ba0:	0c0080e7          	jalr	192(ra) # 80000c5c <acquire>
  pid = nextpid;
    80001ba4:	00007797          	auipc	a5,0x7
    80001ba8:	ca078793          	addi	a5,a5,-864 # 80008844 <nextpid>
    80001bac:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bae:	0014871b          	addiw	a4,s1,1
    80001bb2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bb4:	0000f517          	auipc	a0,0xf
    80001bb8:	f7c50513          	addi	a0,a0,-132 # 80010b30 <pid_lock>
    80001bbc:	fffff097          	auipc	ra,0xfffff
    80001bc0:	150080e7          	jalr	336(ra) # 80000d0c <release>
}
    80001bc4:	8526                	mv	a0,s1
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <proc_pagetable>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
    80001bdc:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bde:	fffff097          	auipc	ra,0xfffff
    80001be2:	7ee080e7          	jalr	2030(ra) # 800013cc <uvmcreate>
    80001be6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001be8:	c121                	beqz	a0,80001c28 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bea:	4729                	li	a4,10
    80001bec:	00005697          	auipc	a3,0x5
    80001bf0:	41468693          	addi	a3,a3,1044 # 80007000 <_trampoline>
    80001bf4:	6605                	lui	a2,0x1
    80001bf6:	040005b7          	lui	a1,0x4000
    80001bfa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bfc:	05b2                	slli	a1,a1,0xc
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	536080e7          	jalr	1334(ra) # 80001134 <mappages>
    80001c06:	02054863          	bltz	a0,80001c36 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c0a:	4719                	li	a4,6
    80001c0c:	05893683          	ld	a3,88(s2)
    80001c10:	6605                	lui	a2,0x1
    80001c12:	020005b7          	lui	a1,0x2000
    80001c16:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c18:	05b6                	slli	a1,a1,0xd
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	fffff097          	auipc	ra,0xfffff
    80001c20:	518080e7          	jalr	1304(ra) # 80001134 <mappages>
    80001c24:	02054163          	bltz	a0,80001c46 <proc_pagetable+0x76>
}
    80001c28:	8526                	mv	a0,s1
    80001c2a:	60e2                	ld	ra,24(sp)
    80001c2c:	6442                	ld	s0,16(sp)
    80001c2e:	64a2                	ld	s1,8(sp)
    80001c30:	6902                	ld	s2,0(sp)
    80001c32:	6105                	addi	sp,sp,32
    80001c34:	8082                	ret
    uvmfree(pagetable, 0);
    80001c36:	4581                	li	a1,0
    80001c38:	8526                	mv	a0,s1
    80001c3a:	00000097          	auipc	ra,0x0
    80001c3e:	9a4080e7          	jalr	-1628(ra) # 800015de <uvmfree>
    return 0;
    80001c42:	4481                	li	s1,0
    80001c44:	b7d5                	j	80001c28 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c46:	4681                	li	a3,0
    80001c48:	4605                	li	a2,1
    80001c4a:	040005b7          	lui	a1,0x4000
    80001c4e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c50:	05b2                	slli	a1,a1,0xc
    80001c52:	8526                	mv	a0,s1
    80001c54:	fffff097          	auipc	ra,0xfffff
    80001c58:	6a4080e7          	jalr	1700(ra) # 800012f8 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c5c:	4581                	li	a1,0
    80001c5e:	8526                	mv	a0,s1
    80001c60:	00000097          	auipc	ra,0x0
    80001c64:	97e080e7          	jalr	-1666(ra) # 800015de <uvmfree>
    return 0;
    80001c68:	4481                	li	s1,0
    80001c6a:	bf7d                	j	80001c28 <proc_pagetable+0x58>

0000000080001c6c <proc_freepagetable>:
{
    80001c6c:	1101                	addi	sp,sp,-32
    80001c6e:	ec06                	sd	ra,24(sp)
    80001c70:	e822                	sd	s0,16(sp)
    80001c72:	e426                	sd	s1,8(sp)
    80001c74:	e04a                	sd	s2,0(sp)
    80001c76:	1000                	addi	s0,sp,32
    80001c78:	84aa                	mv	s1,a0
    80001c7a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c7c:	4681                	li	a3,0
    80001c7e:	4605                	li	a2,1
    80001c80:	040005b7          	lui	a1,0x4000
    80001c84:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c86:	05b2                	slli	a1,a1,0xc
    80001c88:	fffff097          	auipc	ra,0xfffff
    80001c8c:	670080e7          	jalr	1648(ra) # 800012f8 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c90:	4681                	li	a3,0
    80001c92:	4605                	li	a2,1
    80001c94:	020005b7          	lui	a1,0x2000
    80001c98:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c9a:	05b6                	slli	a1,a1,0xd
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	fffff097          	auipc	ra,0xfffff
    80001ca2:	65a080e7          	jalr	1626(ra) # 800012f8 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ca6:	85ca                	mv	a1,s2
    80001ca8:	8526                	mv	a0,s1
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	934080e7          	jalr	-1740(ra) # 800015de <uvmfree>
}
    80001cb2:	60e2                	ld	ra,24(sp)
    80001cb4:	6442                	ld	s0,16(sp)
    80001cb6:	64a2                	ld	s1,8(sp)
    80001cb8:	6902                	ld	s2,0(sp)
    80001cba:	6105                	addi	sp,sp,32
    80001cbc:	8082                	ret

0000000080001cbe <freeproc>:
{
    80001cbe:	1101                	addi	sp,sp,-32
    80001cc0:	ec06                	sd	ra,24(sp)
    80001cc2:	e822                	sd	s0,16(sp)
    80001cc4:	e426                	sd	s1,8(sp)
    80001cc6:	1000                	addi	s0,sp,32
    80001cc8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001cca:	6d28                	ld	a0,88(a0)
    80001ccc:	c509                	beqz	a0,80001cd6 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	d86080e7          	jalr	-634(ra) # 80000a54 <kfree>
  p->trapframe = 0;
    80001cd6:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001cda:	68a8                	ld	a0,80(s1)
    80001cdc:	c511                	beqz	a0,80001ce8 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001cde:	64ac                	ld	a1,72(s1)
    80001ce0:	00000097          	auipc	ra,0x0
    80001ce4:	f8c080e7          	jalr	-116(ra) # 80001c6c <proc_freepagetable>
  p->pagetable = 0;
    80001ce8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cec:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cf0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001cf4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001cf8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cfc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d00:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d04:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d08:	0004ac23          	sw	zero,24(s1)
}
    80001d0c:	60e2                	ld	ra,24(sp)
    80001d0e:	6442                	ld	s0,16(sp)
    80001d10:	64a2                	ld	s1,8(sp)
    80001d12:	6105                	addi	sp,sp,32
    80001d14:	8082                	ret

0000000080001d16 <allocproc>:
{
    80001d16:	1101                	addi	sp,sp,-32
    80001d18:	ec06                	sd	ra,24(sp)
    80001d1a:	e822                	sd	s0,16(sp)
    80001d1c:	e426                	sd	s1,8(sp)
    80001d1e:	e04a                	sd	s2,0(sp)
    80001d20:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d22:	0000f497          	auipc	s1,0xf
    80001d26:	23e48493          	addi	s1,s1,574 # 80010f60 <proc>
    80001d2a:	00015917          	auipc	s2,0x15
    80001d2e:	03690913          	addi	s2,s2,54 # 80016d60 <tickslock>
    acquire(&p->lock);
    80001d32:	8526                	mv	a0,s1
    80001d34:	fffff097          	auipc	ra,0xfffff
    80001d38:	f28080e7          	jalr	-216(ra) # 80000c5c <acquire>
    if(p->state == UNUSED) {
    80001d3c:	4c9c                	lw	a5,24(s1)
    80001d3e:	cf81                	beqz	a5,80001d56 <allocproc+0x40>
      release(&p->lock);
    80001d40:	8526                	mv	a0,s1
    80001d42:	fffff097          	auipc	ra,0xfffff
    80001d46:	fca080e7          	jalr	-54(ra) # 80000d0c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d4a:	17848493          	addi	s1,s1,376
    80001d4e:	ff2492e3          	bne	s1,s2,80001d32 <allocproc+0x1c>
  return 0;
    80001d52:	4481                	li	s1,0
    80001d54:	a0b5                	j	80001dc0 <allocproc+0xaa>
  p->pid = allocpid();
    80001d56:	00000097          	auipc	ra,0x0
    80001d5a:	e34080e7          	jalr	-460(ra) # 80001b8a <allocpid>
    80001d5e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d60:	4785                	li	a5,1
    80001d62:	cc9c                	sw	a5,24(s1)
  p->ps_priority = 5;
    80001d64:	4795                	li	a5,5
    80001d66:	16f4a823          	sw	a5,368(s1)
  long long min = findMinAccum(p);
    80001d6a:	8526                	mv	a0,s1
    80001d6c:	00000097          	auipc	ra,0x0
    80001d70:	b86080e7          	jalr	-1146(ra) # 800018f2 <findMinAccum>
  if(min == -1){
    80001d74:	57fd                	li	a5,-1
    80001d76:	04f50c63          	beq	a0,a5,80001dce <allocproc+0xb8>
  p->accumulator = min;
    80001d7a:	16a4b423          	sd	a0,360(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	dda080e7          	jalr	-550(ra) # 80000b58 <kalloc>
    80001d86:	892a                	mv	s2,a0
    80001d88:	eca8                	sd	a0,88(s1)
    80001d8a:	c521                	beqz	a0,80001dd2 <allocproc+0xbc>
  p->pagetable = proc_pagetable(p);
    80001d8c:	8526                	mv	a0,s1
    80001d8e:	00000097          	auipc	ra,0x0
    80001d92:	e42080e7          	jalr	-446(ra) # 80001bd0 <proc_pagetable>
    80001d96:	892a                	mv	s2,a0
    80001d98:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d9a:	c921                	beqz	a0,80001dea <allocproc+0xd4>
  memset(&p->context, 0, sizeof(p->context));
    80001d9c:	07000613          	li	a2,112
    80001da0:	4581                	li	a1,0
    80001da2:	06048513          	addi	a0,s1,96
    80001da6:	fffff097          	auipc	ra,0xfffff
    80001daa:	fae080e7          	jalr	-82(ra) # 80000d54 <memset>
  p->context.ra = (uint64)forkret;
    80001dae:	00000797          	auipc	a5,0x0
    80001db2:	d9678793          	addi	a5,a5,-618 # 80001b44 <forkret>
    80001db6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001db8:	60bc                	ld	a5,64(s1)
    80001dba:	6705                	lui	a4,0x1
    80001dbc:	97ba                	add	a5,a5,a4
    80001dbe:	f4bc                	sd	a5,104(s1)
}
    80001dc0:	8526                	mv	a0,s1
    80001dc2:	60e2                	ld	ra,24(sp)
    80001dc4:	6442                	ld	s0,16(sp)
    80001dc6:	64a2                	ld	s1,8(sp)
    80001dc8:	6902                	ld	s2,0(sp)
    80001dca:	6105                	addi	sp,sp,32
    80001dcc:	8082                	ret
    min = 0;
    80001dce:	4501                	li	a0,0
    80001dd0:	b76d                	j	80001d7a <allocproc+0x64>
    freeproc(p);
    80001dd2:	8526                	mv	a0,s1
    80001dd4:	00000097          	auipc	ra,0x0
    80001dd8:	eea080e7          	jalr	-278(ra) # 80001cbe <freeproc>
    release(&p->lock);
    80001ddc:	8526                	mv	a0,s1
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	f2e080e7          	jalr	-210(ra) # 80000d0c <release>
    return 0;
    80001de6:	84ca                	mv	s1,s2
    80001de8:	bfe1                	j	80001dc0 <allocproc+0xaa>
    freeproc(p);
    80001dea:	8526                	mv	a0,s1
    80001dec:	00000097          	auipc	ra,0x0
    80001df0:	ed2080e7          	jalr	-302(ra) # 80001cbe <freeproc>
    release(&p->lock);
    80001df4:	8526                	mv	a0,s1
    80001df6:	fffff097          	auipc	ra,0xfffff
    80001dfa:	f16080e7          	jalr	-234(ra) # 80000d0c <release>
    return 0;
    80001dfe:	84ca                	mv	s1,s2
    80001e00:	b7c1                	j	80001dc0 <allocproc+0xaa>

0000000080001e02 <userinit>:
{
    80001e02:	1101                	addi	sp,sp,-32
    80001e04:	ec06                	sd	ra,24(sp)
    80001e06:	e822                	sd	s0,16(sp)
    80001e08:	e426                	sd	s1,8(sp)
    80001e0a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e0c:	00000097          	auipc	ra,0x0
    80001e10:	f0a080e7          	jalr	-246(ra) # 80001d16 <allocproc>
    80001e14:	84aa                	mv	s1,a0
  initproc = p;
    80001e16:	00007797          	auipc	a5,0x7
    80001e1a:	aaa7b123          	sd	a0,-1374(a5) # 800088b8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e1e:	03400613          	li	a2,52
    80001e22:	00007597          	auipc	a1,0x7
    80001e26:	a2e58593          	addi	a1,a1,-1490 # 80008850 <initcode>
    80001e2a:	6928                	ld	a0,80(a0)
    80001e2c:	fffff097          	auipc	ra,0xfffff
    80001e30:	5ce080e7          	jalr	1486(ra) # 800013fa <uvmfirst>
  p->sz = PGSIZE;
    80001e34:	6785                	lui	a5,0x1
    80001e36:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001e38:	6cb8                	ld	a4,88(s1)
    80001e3a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001e3e:	6cb8                	ld	a4,88(s1)
    80001e40:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e42:	4641                	li	a2,16
    80001e44:	00006597          	auipc	a1,0x6
    80001e48:	39c58593          	addi	a1,a1,924 # 800081e0 <etext+0x1e0>
    80001e4c:	15848513          	addi	a0,s1,344
    80001e50:	fffff097          	auipc	ra,0xfffff
    80001e54:	05c080e7          	jalr	92(ra) # 80000eac <safestrcpy>
  p->cwd = namei("/");
    80001e58:	00006517          	auipc	a0,0x6
    80001e5c:	39850513          	addi	a0,a0,920 # 800081f0 <etext+0x1f0>
    80001e60:	00002097          	auipc	ra,0x2
    80001e64:	202080e7          	jalr	514(ra) # 80004062 <namei>
    80001e68:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e6c:	478d                	li	a5,3
    80001e6e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e70:	8526                	mv	a0,s1
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	e9a080e7          	jalr	-358(ra) # 80000d0c <release>
}
    80001e7a:	60e2                	ld	ra,24(sp)
    80001e7c:	6442                	ld	s0,16(sp)
    80001e7e:	64a2                	ld	s1,8(sp)
    80001e80:	6105                	addi	sp,sp,32
    80001e82:	8082                	ret

0000000080001e84 <growproc>:
{
    80001e84:	1101                	addi	sp,sp,-32
    80001e86:	ec06                	sd	ra,24(sp)
    80001e88:	e822                	sd	s0,16(sp)
    80001e8a:	e426                	sd	s1,8(sp)
    80001e8c:	e04a                	sd	s2,0(sp)
    80001e8e:	1000                	addi	s0,sp,32
    80001e90:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001e92:	00000097          	auipc	ra,0x0
    80001e96:	c78080e7          	jalr	-904(ra) # 80001b0a <myproc>
    80001e9a:	84aa                	mv	s1,a0
  sz = p->sz;
    80001e9c:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001e9e:	01204c63          	bgtz	s2,80001eb6 <growproc+0x32>
  } else if(n < 0){
    80001ea2:	02094663          	bltz	s2,80001ece <growproc+0x4a>
  p->sz = sz;
    80001ea6:	e4ac                	sd	a1,72(s1)
  return 0;
    80001ea8:	4501                	li	a0,0
}
    80001eaa:	60e2                	ld	ra,24(sp)
    80001eac:	6442                	ld	s0,16(sp)
    80001eae:	64a2                	ld	s1,8(sp)
    80001eb0:	6902                	ld	s2,0(sp)
    80001eb2:	6105                	addi	sp,sp,32
    80001eb4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001eb6:	4691                	li	a3,4
    80001eb8:	00b90633          	add	a2,s2,a1
    80001ebc:	6928                	ld	a0,80(a0)
    80001ebe:	fffff097          	auipc	ra,0xfffff
    80001ec2:	5f6080e7          	jalr	1526(ra) # 800014b4 <uvmalloc>
    80001ec6:	85aa                	mv	a1,a0
    80001ec8:	fd79                	bnez	a0,80001ea6 <growproc+0x22>
      return -1;
    80001eca:	557d                	li	a0,-1
    80001ecc:	bff9                	j	80001eaa <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ece:	00b90633          	add	a2,s2,a1
    80001ed2:	6928                	ld	a0,80(a0)
    80001ed4:	fffff097          	auipc	ra,0xfffff
    80001ed8:	598080e7          	jalr	1432(ra) # 8000146c <uvmdealloc>
    80001edc:	85aa                	mv	a1,a0
    80001ede:	b7e1                	j	80001ea6 <growproc+0x22>

0000000080001ee0 <fork>:
{
    80001ee0:	7139                	addi	sp,sp,-64
    80001ee2:	fc06                	sd	ra,56(sp)
    80001ee4:	f822                	sd	s0,48(sp)
    80001ee6:	f426                	sd	s1,40(sp)
    80001ee8:	e456                	sd	s5,8(sp)
    80001eea:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001eec:	00000097          	auipc	ra,0x0
    80001ef0:	c1e080e7          	jalr	-994(ra) # 80001b0a <myproc>
    80001ef4:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001ef6:	00000097          	auipc	ra,0x0
    80001efa:	e20080e7          	jalr	-480(ra) # 80001d16 <allocproc>
    80001efe:	12050063          	beqz	a0,8000201e <fork+0x13e>
    80001f02:	e852                	sd	s4,16(sp)
    80001f04:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f06:	048ab603          	ld	a2,72(s5)
    80001f0a:	692c                	ld	a1,80(a0)
    80001f0c:	050ab503          	ld	a0,80(s5)
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	708080e7          	jalr	1800(ra) # 80001618 <uvmcopy>
    80001f18:	04054863          	bltz	a0,80001f68 <fork+0x88>
    80001f1c:	f04a                	sd	s2,32(sp)
    80001f1e:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001f20:	048ab783          	ld	a5,72(s5)
    80001f24:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001f28:	058ab683          	ld	a3,88(s5)
    80001f2c:	87b6                	mv	a5,a3
    80001f2e:	058a3703          	ld	a4,88(s4)
    80001f32:	12068693          	addi	a3,a3,288
    80001f36:	6388                	ld	a0,0(a5)
    80001f38:	678c                	ld	a1,8(a5)
    80001f3a:	6b90                	ld	a2,16(a5)
    80001f3c:	e308                	sd	a0,0(a4)
    80001f3e:	e70c                	sd	a1,8(a4)
    80001f40:	eb10                	sd	a2,16(a4)
    80001f42:	6f90                	ld	a2,24(a5)
    80001f44:	ef10                	sd	a2,24(a4)
    80001f46:	02078793          	addi	a5,a5,32 # 1020 <_entry-0x7fffefe0>
    80001f4a:	02070713          	addi	a4,a4,32
    80001f4e:	fed794e3          	bne	a5,a3,80001f36 <fork+0x56>
  np->trapframe->a0 = 0;
    80001f52:	058a3783          	ld	a5,88(s4)
    80001f56:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f5a:	0d0a8493          	addi	s1,s5,208
    80001f5e:	0d0a0913          	addi	s2,s4,208
    80001f62:	150a8993          	addi	s3,s5,336
    80001f66:	a015                	j	80001f8a <fork+0xaa>
    freeproc(np);
    80001f68:	8552                	mv	a0,s4
    80001f6a:	00000097          	auipc	ra,0x0
    80001f6e:	d54080e7          	jalr	-684(ra) # 80001cbe <freeproc>
    release(&np->lock);
    80001f72:	8552                	mv	a0,s4
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	d98080e7          	jalr	-616(ra) # 80000d0c <release>
    return -1;
    80001f7c:	54fd                	li	s1,-1
    80001f7e:	6a42                	ld	s4,16(sp)
    80001f80:	a841                	j	80002010 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001f82:	04a1                	addi	s1,s1,8
    80001f84:	0921                	addi	s2,s2,8
    80001f86:	01348b63          	beq	s1,s3,80001f9c <fork+0xbc>
    if(p->ofile[i])
    80001f8a:	6088                	ld	a0,0(s1)
    80001f8c:	d97d                	beqz	a0,80001f82 <fork+0xa2>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f8e:	00002097          	auipc	ra,0x2
    80001f92:	76a080e7          	jalr	1898(ra) # 800046f8 <filedup>
    80001f96:	00a93023          	sd	a0,0(s2)
    80001f9a:	b7e5                	j	80001f82 <fork+0xa2>
  np->cwd = idup(p->cwd);
    80001f9c:	150ab503          	ld	a0,336(s5)
    80001fa0:	00002097          	auipc	ra,0x2
    80001fa4:	89a080e7          	jalr	-1894(ra) # 8000383a <idup>
    80001fa8:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fac:	4641                	li	a2,16
    80001fae:	158a8593          	addi	a1,s5,344
    80001fb2:	158a0513          	addi	a0,s4,344
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	ef6080e7          	jalr	-266(ra) # 80000eac <safestrcpy>
  pid = np->pid;
    80001fbe:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001fc2:	8552                	mv	a0,s4
    80001fc4:	fffff097          	auipc	ra,0xfffff
    80001fc8:	d48080e7          	jalr	-696(ra) # 80000d0c <release>
  acquire(&wait_lock);
    80001fcc:	0000f517          	auipc	a0,0xf
    80001fd0:	b7c50513          	addi	a0,a0,-1156 # 80010b48 <wait_lock>
    80001fd4:	fffff097          	auipc	ra,0xfffff
    80001fd8:	c88080e7          	jalr	-888(ra) # 80000c5c <acquire>
  np->parent = p;
    80001fdc:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001fe0:	0000f517          	auipc	a0,0xf
    80001fe4:	b6850513          	addi	a0,a0,-1176 # 80010b48 <wait_lock>
    80001fe8:	fffff097          	auipc	ra,0xfffff
    80001fec:	d24080e7          	jalr	-732(ra) # 80000d0c <release>
  acquire(&np->lock);
    80001ff0:	8552                	mv	a0,s4
    80001ff2:	fffff097          	auipc	ra,0xfffff
    80001ff6:	c6a080e7          	jalr	-918(ra) # 80000c5c <acquire>
  np->state = RUNNABLE;
    80001ffa:	478d                	li	a5,3
    80001ffc:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80002000:	8552                	mv	a0,s4
    80002002:	fffff097          	auipc	ra,0xfffff
    80002006:	d0a080e7          	jalr	-758(ra) # 80000d0c <release>
  return pid;
    8000200a:	7902                	ld	s2,32(sp)
    8000200c:	69e2                	ld	s3,24(sp)
    8000200e:	6a42                	ld	s4,16(sp)
}
    80002010:	8526                	mv	a0,s1
    80002012:	70e2                	ld	ra,56(sp)
    80002014:	7442                	ld	s0,48(sp)
    80002016:	74a2                	ld	s1,40(sp)
    80002018:	6aa2                	ld	s5,8(sp)
    8000201a:	6121                	addi	sp,sp,64
    8000201c:	8082                	ret
    return -1;
    8000201e:	54fd                	li	s1,-1
    80002020:	bfc5                	j	80002010 <fork+0x130>

0000000080002022 <scheduler>:
{
    80002022:	715d                	addi	sp,sp,-80
    80002024:	e486                	sd	ra,72(sp)
    80002026:	e0a2                	sd	s0,64(sp)
    80002028:	fc26                	sd	s1,56(sp)
    8000202a:	f84a                	sd	s2,48(sp)
    8000202c:	f44e                	sd	s3,40(sp)
    8000202e:	f052                	sd	s4,32(sp)
    80002030:	ec56                	sd	s5,24(sp)
    80002032:	e85a                	sd	s6,16(sp)
    80002034:	e45e                	sd	s7,8(sp)
    80002036:	0880                	addi	s0,sp,80
    80002038:	8792                	mv	a5,tp
  int id = r_tp();
    8000203a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000203c:	00779b13          	slli	s6,a5,0x7
    80002040:	0000f717          	auipc	a4,0xf
    80002044:	af070713          	addi	a4,a4,-1296 # 80010b30 <pid_lock>
    80002048:	975a                	add	a4,a4,s6
    8000204a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &minP->context);
    8000204e:	0000f717          	auipc	a4,0xf
    80002052:	b1a70713          	addi	a4,a4,-1254 # 80010b68 <cpus+0x8>
    80002056:	9b3a                	add	s6,s6,a4
      if(p->state == RUNNABLE) {
    80002058:	4a0d                	li	s4,3
    for(p = proc; p < &proc[NPROC]; p++) {
    8000205a:	00015997          	auipc	s3,0x15
    8000205e:	d0698993          	addi	s3,s3,-762 # 80016d60 <tickslock>
        minP->state = RUNNING;
    80002062:	4b91                	li	s7,4
        c->proc = minP;
    80002064:	079e                	slli	a5,a5,0x7
    80002066:	0000fa97          	auipc	s5,0xf
    8000206a:	acaa8a93          	addi	s5,s5,-1334 # 80010b30 <pid_lock>
    8000206e:	9abe                	add	s5,s5,a5
    80002070:	a0bd                	j	800020de <scheduler+0xbc>
      release(&p->lock);
    80002072:	8526                	mv	a0,s1
    80002074:	fffff097          	auipc	ra,0xfffff
    80002078:	c98080e7          	jalr	-872(ra) # 80000d0c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000207c:	17848493          	addi	s1,s1,376
    80002080:	03348b63          	beq	s1,s3,800020b6 <scheduler+0x94>
      acquire(&p->lock);
    80002084:	8526                	mv	a0,s1
    80002086:	fffff097          	auipc	ra,0xfffff
    8000208a:	bd6080e7          	jalr	-1066(ra) # 80000c5c <acquire>
      if(p->state == RUNNABLE) {
    8000208e:	4c9c                	lw	a5,24(s1)
    80002090:	ff4791e3          	bne	a5,s4,80002072 <scheduler+0x50>
        if(minP == 0 || p->accumulator < minP->accumulator) {
    80002094:	00090f63          	beqz	s2,800020b2 <scheduler+0x90>
    80002098:	1684b703          	ld	a4,360(s1)
    8000209c:	16893783          	ld	a5,360(s2)
    800020a0:	fcf759e3          	bge	a4,a5,80002072 <scheduler+0x50>
                release(&minP->lock);
    800020a4:	854a                	mv	a0,s2
    800020a6:	fffff097          	auipc	ra,0xfffff
    800020aa:	c66080e7          	jalr	-922(ra) # 80000d0c <release>
            minP = p;
    800020ae:	8926                	mv	s2,s1
    800020b0:	b7f1                	j	8000207c <scheduler+0x5a>
    800020b2:	8926                	mv	s2,s1
    800020b4:	b7e1                	j	8000207c <scheduler+0x5a>
    if(minP != 0) {
    800020b6:	04090063          	beqz	s2,800020f6 <scheduler+0xd4>
        minP->state = RUNNING;
    800020ba:	01792c23          	sw	s7,24(s2)
        c->proc = minP;
    800020be:	032ab823          	sd	s2,48(s5)
        swtch(&c->context, &minP->context);
    800020c2:	06090593          	addi	a1,s2,96
    800020c6:	855a                	mv	a0,s6
    800020c8:	00000097          	auipc	ra,0x0
    800020cc:	6da080e7          	jalr	1754(ra) # 800027a2 <swtch>
        c->proc = 0;
    800020d0:	020ab823          	sd	zero,48(s5)
        release(&minP->lock);
    800020d4:	854a                	mv	a0,s2
    800020d6:	fffff097          	auipc	ra,0xfffff
    800020da:	c36080e7          	jalr	-970(ra) # 80000d0c <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020de:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020e2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020e6:	10079073          	csrw	sstatus,a5
    minP = 0;
    800020ea:	4901                	li	s2,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800020ec:	0000f497          	auipc	s1,0xf
    800020f0:	e7448493          	addi	s1,s1,-396 # 80010f60 <proc>
    800020f4:	bf41                	j	80002084 <scheduler+0x62>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020f6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020fa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020fe:	10079073          	csrw	sstatus,a5
        asm volatile("wfi");
    80002102:	10500073          	wfi
    80002106:	bfe1                	j	800020de <scheduler+0xbc>

0000000080002108 <sched>:
{
    80002108:	7179                	addi	sp,sp,-48
    8000210a:	f406                	sd	ra,40(sp)
    8000210c:	f022                	sd	s0,32(sp)
    8000210e:	ec26                	sd	s1,24(sp)
    80002110:	e84a                	sd	s2,16(sp)
    80002112:	e44e                	sd	s3,8(sp)
    80002114:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002116:	00000097          	auipc	ra,0x0
    8000211a:	9f4080e7          	jalr	-1548(ra) # 80001b0a <myproc>
    8000211e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	abc080e7          	jalr	-1348(ra) # 80000bdc <holding>
    80002128:	cd25                	beqz	a0,800021a0 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000212a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000212c:	2781                	sext.w	a5,a5
    8000212e:	079e                	slli	a5,a5,0x7
    80002130:	0000f717          	auipc	a4,0xf
    80002134:	a0070713          	addi	a4,a4,-1536 # 80010b30 <pid_lock>
    80002138:	97ba                	add	a5,a5,a4
    8000213a:	0a87a703          	lw	a4,168(a5)
    8000213e:	4785                	li	a5,1
    80002140:	06f71863          	bne	a4,a5,800021b0 <sched+0xa8>
  if(p->state == RUNNING)
    80002144:	4c98                	lw	a4,24(s1)
    80002146:	4791                	li	a5,4
    80002148:	06f70c63          	beq	a4,a5,800021c0 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000214c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002150:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002152:	efbd                	bnez	a5,800021d0 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002154:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002156:	0000f917          	auipc	s2,0xf
    8000215a:	9da90913          	addi	s2,s2,-1574 # 80010b30 <pid_lock>
    8000215e:	2781                	sext.w	a5,a5
    80002160:	079e                	slli	a5,a5,0x7
    80002162:	97ca                	add	a5,a5,s2
    80002164:	0ac7a983          	lw	s3,172(a5)
    80002168:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000216a:	2781                	sext.w	a5,a5
    8000216c:	079e                	slli	a5,a5,0x7
    8000216e:	07a1                	addi	a5,a5,8
    80002170:	0000f597          	auipc	a1,0xf
    80002174:	9f058593          	addi	a1,a1,-1552 # 80010b60 <cpus>
    80002178:	95be                	add	a1,a1,a5
    8000217a:	06048513          	addi	a0,s1,96
    8000217e:	00000097          	auipc	ra,0x0
    80002182:	624080e7          	jalr	1572(ra) # 800027a2 <swtch>
    80002186:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002188:	2781                	sext.w	a5,a5
    8000218a:	079e                	slli	a5,a5,0x7
    8000218c:	993e                	add	s2,s2,a5
    8000218e:	0b392623          	sw	s3,172(s2)
}
    80002192:	70a2                	ld	ra,40(sp)
    80002194:	7402                	ld	s0,32(sp)
    80002196:	64e2                	ld	s1,24(sp)
    80002198:	6942                	ld	s2,16(sp)
    8000219a:	69a2                	ld	s3,8(sp)
    8000219c:	6145                	addi	sp,sp,48
    8000219e:	8082                	ret
    panic("sched p->lock");
    800021a0:	00006517          	auipc	a0,0x6
    800021a4:	05850513          	addi	a0,a0,88 # 800081f8 <etext+0x1f8>
    800021a8:	ffffe097          	auipc	ra,0xffffe
    800021ac:	3b6080e7          	jalr	950(ra) # 8000055e <panic>
    panic("sched locks");
    800021b0:	00006517          	auipc	a0,0x6
    800021b4:	05850513          	addi	a0,a0,88 # 80008208 <etext+0x208>
    800021b8:	ffffe097          	auipc	ra,0xffffe
    800021bc:	3a6080e7          	jalr	934(ra) # 8000055e <panic>
    panic("sched running");
    800021c0:	00006517          	auipc	a0,0x6
    800021c4:	05850513          	addi	a0,a0,88 # 80008218 <etext+0x218>
    800021c8:	ffffe097          	auipc	ra,0xffffe
    800021cc:	396080e7          	jalr	918(ra) # 8000055e <panic>
    panic("sched interruptible");
    800021d0:	00006517          	auipc	a0,0x6
    800021d4:	05850513          	addi	a0,a0,88 # 80008228 <etext+0x228>
    800021d8:	ffffe097          	auipc	ra,0xffffe
    800021dc:	386080e7          	jalr	902(ra) # 8000055e <panic>

00000000800021e0 <yield>:
{
    800021e0:	1101                	addi	sp,sp,-32
    800021e2:	ec06                	sd	ra,24(sp)
    800021e4:	e822                	sd	s0,16(sp)
    800021e6:	e426                	sd	s1,8(sp)
    800021e8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021ea:	00000097          	auipc	ra,0x0
    800021ee:	920080e7          	jalr	-1760(ra) # 80001b0a <myproc>
    800021f2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	a68080e7          	jalr	-1432(ra) # 80000c5c <acquire>
  p->state = RUNNABLE;
    800021fc:	478d                	li	a5,3
    800021fe:	cc9c                	sw	a5,24(s1)
  sched();
    80002200:	00000097          	auipc	ra,0x0
    80002204:	f08080e7          	jalr	-248(ra) # 80002108 <sched>
  release(&p->lock);
    80002208:	8526                	mv	a0,s1
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	b02080e7          	jalr	-1278(ra) # 80000d0c <release>
}
    80002212:	60e2                	ld	ra,24(sp)
    80002214:	6442                	ld	s0,16(sp)
    80002216:	64a2                	ld	s1,8(sp)
    80002218:	6105                	addi	sp,sp,32
    8000221a:	8082                	ret

000000008000221c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000221c:	7179                	addi	sp,sp,-48
    8000221e:	f406                	sd	ra,40(sp)
    80002220:	f022                	sd	s0,32(sp)
    80002222:	ec26                	sd	s1,24(sp)
    80002224:	e84a                	sd	s2,16(sp)
    80002226:	e44e                	sd	s3,8(sp)
    80002228:	1800                	addi	s0,sp,48
    8000222a:	89aa                	mv	s3,a0
    8000222c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000222e:	00000097          	auipc	ra,0x0
    80002232:	8dc080e7          	jalr	-1828(ra) # 80001b0a <myproc>
    80002236:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	a24080e7          	jalr	-1500(ra) # 80000c5c <acquire>
  release(lk);
    80002240:	854a                	mv	a0,s2
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	aca080e7          	jalr	-1334(ra) # 80000d0c <release>

  // Go to sleep.
  p->chan = chan;
    8000224a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000224e:	4789                	li	a5,2
    80002250:	cc9c                	sw	a5,24(s1)

  sched();
    80002252:	00000097          	auipc	ra,0x0
    80002256:	eb6080e7          	jalr	-330(ra) # 80002108 <sched>

  // Tidy up.
  p->chan = 0;
    8000225a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000225e:	8526                	mv	a0,s1
    80002260:	fffff097          	auipc	ra,0xfffff
    80002264:	aac080e7          	jalr	-1364(ra) # 80000d0c <release>
  acquire(lk);
    80002268:	854a                	mv	a0,s2
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	9f2080e7          	jalr	-1550(ra) # 80000c5c <acquire>
}
    80002272:	70a2                	ld	ra,40(sp)
    80002274:	7402                	ld	s0,32(sp)
    80002276:	64e2                	ld	s1,24(sp)
    80002278:	6942                	ld	s2,16(sp)
    8000227a:	69a2                	ld	s3,8(sp)
    8000227c:	6145                	addi	sp,sp,48
    8000227e:	8082                	ret

0000000080002280 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002280:	7139                	addi	sp,sp,-64
    80002282:	fc06                	sd	ra,56(sp)
    80002284:	f822                	sd	s0,48(sp)
    80002286:	f426                	sd	s1,40(sp)
    80002288:	f04a                	sd	s2,32(sp)
    8000228a:	ec4e                	sd	s3,24(sp)
    8000228c:	e852                	sd	s4,16(sp)
    8000228e:	e456                	sd	s5,8(sp)
    80002290:	e05a                	sd	s6,0(sp)
    80002292:	0080                	addi	s0,sp,64
    80002294:	8a2a                	mv	s4,a0
  struct proc *p;
  
  long long min = findMinAccum(myproc());
    80002296:	00000097          	auipc	ra,0x0
    8000229a:	874080e7          	jalr	-1932(ra) # 80001b0a <myproc>
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	654080e7          	jalr	1620(ra) # 800018f2 <findMinAccum>
    800022a6:	8aaa                	mv	s5,a0
  if(min == -1){
    800022a8:	57fd                	li	a5,-1
    800022aa:	00f50d63          	beq	a0,a5,800022c4 <wakeup+0x44>
    min = 0;
  }
  for(p = proc; p < &proc[NPROC]; p++) {
    800022ae:	0000f497          	auipc	s1,0xf
    800022b2:	cb248493          	addi	s1,s1,-846 # 80010f60 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800022b6:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022b8:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800022ba:	00015917          	auipc	s2,0x15
    800022be:	aa690913          	addi	s2,s2,-1370 # 80016d60 <tickslock>
    800022c2:	a821                	j	800022da <wakeup+0x5a>
    min = 0;
    800022c4:	4a81                	li	s5,0
    800022c6:	b7e5                	j	800022ae <wakeup+0x2e>
        p->accumulator = min;
      }
      release(&p->lock);
    800022c8:	8526                	mv	a0,s1
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	a42080e7          	jalr	-1470(ra) # 80000d0c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022d2:	17848493          	addi	s1,s1,376
    800022d6:	03248863          	beq	s1,s2,80002306 <wakeup+0x86>
    if(p != myproc()){
    800022da:	00000097          	auipc	ra,0x0
    800022de:	830080e7          	jalr	-2000(ra) # 80001b0a <myproc>
    800022e2:	fe9508e3          	beq	a0,s1,800022d2 <wakeup+0x52>
      acquire(&p->lock);
    800022e6:	8526                	mv	a0,s1
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	974080e7          	jalr	-1676(ra) # 80000c5c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022f0:	4c9c                	lw	a5,24(s1)
    800022f2:	fd379be3          	bne	a5,s3,800022c8 <wakeup+0x48>
    800022f6:	709c                	ld	a5,32(s1)
    800022f8:	fd4798e3          	bne	a5,s4,800022c8 <wakeup+0x48>
        p->state = RUNNABLE;
    800022fc:	0164ac23          	sw	s6,24(s1)
        p->accumulator = min;
    80002300:	1754b423          	sd	s5,360(s1)
    80002304:	b7d1                	j	800022c8 <wakeup+0x48>
    }
  }
}
    80002306:	70e2                	ld	ra,56(sp)
    80002308:	7442                	ld	s0,48(sp)
    8000230a:	74a2                	ld	s1,40(sp)
    8000230c:	7902                	ld	s2,32(sp)
    8000230e:	69e2                	ld	s3,24(sp)
    80002310:	6a42                	ld	s4,16(sp)
    80002312:	6aa2                	ld	s5,8(sp)
    80002314:	6b02                	ld	s6,0(sp)
    80002316:	6121                	addi	sp,sp,64
    80002318:	8082                	ret

000000008000231a <reparent>:
{
    8000231a:	7179                	addi	sp,sp,-48
    8000231c:	f406                	sd	ra,40(sp)
    8000231e:	f022                	sd	s0,32(sp)
    80002320:	ec26                	sd	s1,24(sp)
    80002322:	e84a                	sd	s2,16(sp)
    80002324:	e44e                	sd	s3,8(sp)
    80002326:	e052                	sd	s4,0(sp)
    80002328:	1800                	addi	s0,sp,48
    8000232a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000232c:	0000f497          	auipc	s1,0xf
    80002330:	c3448493          	addi	s1,s1,-972 # 80010f60 <proc>
      pp->parent = initproc;
    80002334:	00006a17          	auipc	s4,0x6
    80002338:	584a0a13          	addi	s4,s4,1412 # 800088b8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000233c:	00015997          	auipc	s3,0x15
    80002340:	a2498993          	addi	s3,s3,-1500 # 80016d60 <tickslock>
    80002344:	a029                	j	8000234e <reparent+0x34>
    80002346:	17848493          	addi	s1,s1,376
    8000234a:	01348d63          	beq	s1,s3,80002364 <reparent+0x4a>
    if(pp->parent == p){
    8000234e:	7c9c                	ld	a5,56(s1)
    80002350:	ff279be3          	bne	a5,s2,80002346 <reparent+0x2c>
      pp->parent = initproc;
    80002354:	000a3503          	ld	a0,0(s4)
    80002358:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000235a:	00000097          	auipc	ra,0x0
    8000235e:	f26080e7          	jalr	-218(ra) # 80002280 <wakeup>
    80002362:	b7d5                	j	80002346 <reparent+0x2c>
}
    80002364:	70a2                	ld	ra,40(sp)
    80002366:	7402                	ld	s0,32(sp)
    80002368:	64e2                	ld	s1,24(sp)
    8000236a:	6942                	ld	s2,16(sp)
    8000236c:	69a2                	ld	s3,8(sp)
    8000236e:	6a02                	ld	s4,0(sp)
    80002370:	6145                	addi	sp,sp,48
    80002372:	8082                	ret

0000000080002374 <exit>:
{
    80002374:	7179                	addi	sp,sp,-48
    80002376:	f406                	sd	ra,40(sp)
    80002378:	f022                	sd	s0,32(sp)
    8000237a:	ec26                	sd	s1,24(sp)
    8000237c:	e84a                	sd	s2,16(sp)
    8000237e:	e44e                	sd	s3,8(sp)
    80002380:	e052                	sd	s4,0(sp)
    80002382:	1800                	addi	s0,sp,48
    80002384:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002386:	fffff097          	auipc	ra,0xfffff
    8000238a:	784080e7          	jalr	1924(ra) # 80001b0a <myproc>
    8000238e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002390:	00006797          	auipc	a5,0x6
    80002394:	5287b783          	ld	a5,1320(a5) # 800088b8 <initproc>
    80002398:	0d050493          	addi	s1,a0,208
    8000239c:	15050913          	addi	s2,a0,336
    800023a0:	00a79d63          	bne	a5,a0,800023ba <exit+0x46>
    panic("init exiting");
    800023a4:	00006517          	auipc	a0,0x6
    800023a8:	e9c50513          	addi	a0,a0,-356 # 80008240 <etext+0x240>
    800023ac:	ffffe097          	auipc	ra,0xffffe
    800023b0:	1b2080e7          	jalr	434(ra) # 8000055e <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    800023b4:	04a1                	addi	s1,s1,8
    800023b6:	01248b63          	beq	s1,s2,800023cc <exit+0x58>
    if(p->ofile[fd]){
    800023ba:	6088                	ld	a0,0(s1)
    800023bc:	dd65                	beqz	a0,800023b4 <exit+0x40>
      fileclose(f);
    800023be:	00002097          	auipc	ra,0x2
    800023c2:	38c080e7          	jalr	908(ra) # 8000474a <fileclose>
      p->ofile[fd] = 0;
    800023c6:	0004b023          	sd	zero,0(s1)
    800023ca:	b7ed                	j	800023b4 <exit+0x40>
  begin_op();
    800023cc:	00002097          	auipc	ra,0x2
    800023d0:	e9c080e7          	jalr	-356(ra) # 80004268 <begin_op>
  iput(p->cwd);
    800023d4:	1509b503          	ld	a0,336(s3)
    800023d8:	00001097          	auipc	ra,0x1
    800023dc:	65e080e7          	jalr	1630(ra) # 80003a36 <iput>
  end_op();
    800023e0:	00002097          	auipc	ra,0x2
    800023e4:	f08080e7          	jalr	-248(ra) # 800042e8 <end_op>
  p->cwd = 0;
    800023e8:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800023ec:	0000e517          	auipc	a0,0xe
    800023f0:	75c50513          	addi	a0,a0,1884 # 80010b48 <wait_lock>
    800023f4:	fffff097          	auipc	ra,0xfffff
    800023f8:	868080e7          	jalr	-1944(ra) # 80000c5c <acquire>
  reparent(p);
    800023fc:	854e                	mv	a0,s3
    800023fe:	00000097          	auipc	ra,0x0
    80002402:	f1c080e7          	jalr	-228(ra) # 8000231a <reparent>
  wakeup(p->parent);
    80002406:	0389b503          	ld	a0,56(s3)
    8000240a:	00000097          	auipc	ra,0x0
    8000240e:	e76080e7          	jalr	-394(ra) # 80002280 <wakeup>
  acquire(&p->lock);
    80002412:	854e                	mv	a0,s3
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	848080e7          	jalr	-1976(ra) # 80000c5c <acquire>
  p->xstate = status;
    8000241c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002420:	4795                	li	a5,5
    80002422:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002426:	0000e517          	auipc	a0,0xe
    8000242a:	72250513          	addi	a0,a0,1826 # 80010b48 <wait_lock>
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	8de080e7          	jalr	-1826(ra) # 80000d0c <release>
  sched();
    80002436:	00000097          	auipc	ra,0x0
    8000243a:	cd2080e7          	jalr	-814(ra) # 80002108 <sched>
  panic("zombie exit");
    8000243e:	00006517          	auipc	a0,0x6
    80002442:	e1250513          	addi	a0,a0,-494 # 80008250 <etext+0x250>
    80002446:	ffffe097          	auipc	ra,0xffffe
    8000244a:	118080e7          	jalr	280(ra) # 8000055e <panic>

000000008000244e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000244e:	7179                	addi	sp,sp,-48
    80002450:	f406                	sd	ra,40(sp)
    80002452:	f022                	sd	s0,32(sp)
    80002454:	ec26                	sd	s1,24(sp)
    80002456:	e84a                	sd	s2,16(sp)
    80002458:	e44e                	sd	s3,8(sp)
    8000245a:	1800                	addi	s0,sp,48
    8000245c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000245e:	0000f497          	auipc	s1,0xf
    80002462:	b0248493          	addi	s1,s1,-1278 # 80010f60 <proc>
    80002466:	00015997          	auipc	s3,0x15
    8000246a:	8fa98993          	addi	s3,s3,-1798 # 80016d60 <tickslock>
    acquire(&p->lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	ffffe097          	auipc	ra,0xffffe
    80002474:	7ec080e7          	jalr	2028(ra) # 80000c5c <acquire>
    if(p->pid == pid){
    80002478:	589c                	lw	a5,48(s1)
    8000247a:	01278d63          	beq	a5,s2,80002494 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000247e:	8526                	mv	a0,s1
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	88c080e7          	jalr	-1908(ra) # 80000d0c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002488:	17848493          	addi	s1,s1,376
    8000248c:	ff3491e3          	bne	s1,s3,8000246e <kill+0x20>
  }
  return -1;
    80002490:	557d                	li	a0,-1
    80002492:	a829                	j	800024ac <kill+0x5e>
      p->killed = 1;
    80002494:	4785                	li	a5,1
    80002496:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002498:	4c98                	lw	a4,24(s1)
    8000249a:	4789                	li	a5,2
    8000249c:	00f70f63          	beq	a4,a5,800024ba <kill+0x6c>
      release(&p->lock);
    800024a0:	8526                	mv	a0,s1
    800024a2:	fffff097          	auipc	ra,0xfffff
    800024a6:	86a080e7          	jalr	-1942(ra) # 80000d0c <release>
      return 0;
    800024aa:	4501                	li	a0,0
}
    800024ac:	70a2                	ld	ra,40(sp)
    800024ae:	7402                	ld	s0,32(sp)
    800024b0:	64e2                	ld	s1,24(sp)
    800024b2:	6942                	ld	s2,16(sp)
    800024b4:	69a2                	ld	s3,8(sp)
    800024b6:	6145                	addi	sp,sp,48
    800024b8:	8082                	ret
        p->state = RUNNABLE;
    800024ba:	478d                	li	a5,3
    800024bc:	cc9c                	sw	a5,24(s1)
    800024be:	b7cd                	j	800024a0 <kill+0x52>

00000000800024c0 <setkilled>:

void
setkilled(struct proc *p)
{
    800024c0:	1101                	addi	sp,sp,-32
    800024c2:	ec06                	sd	ra,24(sp)
    800024c4:	e822                	sd	s0,16(sp)
    800024c6:	e426                	sd	s1,8(sp)
    800024c8:	1000                	addi	s0,sp,32
    800024ca:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024cc:	ffffe097          	auipc	ra,0xffffe
    800024d0:	790080e7          	jalr	1936(ra) # 80000c5c <acquire>
  p->killed = 1;
    800024d4:	4785                	li	a5,1
    800024d6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800024d8:	8526                	mv	a0,s1
    800024da:	fffff097          	auipc	ra,0xfffff
    800024de:	832080e7          	jalr	-1998(ra) # 80000d0c <release>
}
    800024e2:	60e2                	ld	ra,24(sp)
    800024e4:	6442                	ld	s0,16(sp)
    800024e6:	64a2                	ld	s1,8(sp)
    800024e8:	6105                	addi	sp,sp,32
    800024ea:	8082                	ret

00000000800024ec <killed>:

int
killed(struct proc *p)
{
    800024ec:	1101                	addi	sp,sp,-32
    800024ee:	ec06                	sd	ra,24(sp)
    800024f0:	e822                	sd	s0,16(sp)
    800024f2:	e426                	sd	s1,8(sp)
    800024f4:	e04a                	sd	s2,0(sp)
    800024f6:	1000                	addi	s0,sp,32
    800024f8:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800024fa:	ffffe097          	auipc	ra,0xffffe
    800024fe:	762080e7          	jalr	1890(ra) # 80000c5c <acquire>
  k = p->killed;
    80002502:	549c                	lw	a5,40(s1)
    80002504:	893e                	mv	s2,a5
  release(&p->lock);
    80002506:	8526                	mv	a0,s1
    80002508:	fffff097          	auipc	ra,0xfffff
    8000250c:	804080e7          	jalr	-2044(ra) # 80000d0c <release>
  return k;
}
    80002510:	854a                	mv	a0,s2
    80002512:	60e2                	ld	ra,24(sp)
    80002514:	6442                	ld	s0,16(sp)
    80002516:	64a2                	ld	s1,8(sp)
    80002518:	6902                	ld	s2,0(sp)
    8000251a:	6105                	addi	sp,sp,32
    8000251c:	8082                	ret

000000008000251e <wait>:
{
    8000251e:	715d                	addi	sp,sp,-80
    80002520:	e486                	sd	ra,72(sp)
    80002522:	e0a2                	sd	s0,64(sp)
    80002524:	fc26                	sd	s1,56(sp)
    80002526:	f84a                	sd	s2,48(sp)
    80002528:	f44e                	sd	s3,40(sp)
    8000252a:	f052                	sd	s4,32(sp)
    8000252c:	ec56                	sd	s5,24(sp)
    8000252e:	e85a                	sd	s6,16(sp)
    80002530:	e45e                	sd	s7,8(sp)
    80002532:	0880                	addi	s0,sp,80
    80002534:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002536:	fffff097          	auipc	ra,0xfffff
    8000253a:	5d4080e7          	jalr	1492(ra) # 80001b0a <myproc>
    8000253e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002540:	0000e517          	auipc	a0,0xe
    80002544:	60850513          	addi	a0,a0,1544 # 80010b48 <wait_lock>
    80002548:	ffffe097          	auipc	ra,0xffffe
    8000254c:	714080e7          	jalr	1812(ra) # 80000c5c <acquire>
        if(pp->state == ZOMBIE){
    80002550:	4a15                	li	s4,5
        havekids = 1;
    80002552:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002554:	00015997          	auipc	s3,0x15
    80002558:	80c98993          	addi	s3,s3,-2036 # 80016d60 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000255c:	0000eb17          	auipc	s6,0xe
    80002560:	5ecb0b13          	addi	s6,s6,1516 # 80010b48 <wait_lock>
    80002564:	a0c9                	j	80002626 <wait+0x108>
          pid = pp->pid;
    80002566:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000256a:	000b8e63          	beqz	s7,80002586 <wait+0x68>
    8000256e:	4691                	li	a3,4
    80002570:	02c48613          	addi	a2,s1,44
    80002574:	85de                	mv	a1,s7
    80002576:	05093503          	ld	a0,80(s2)
    8000257a:	fffff097          	auipc	ra,0xfffff
    8000257e:	19e080e7          	jalr	414(ra) # 80001718 <copyout>
    80002582:	04054063          	bltz	a0,800025c2 <wait+0xa4>
          freeproc(pp);
    80002586:	8526                	mv	a0,s1
    80002588:	fffff097          	auipc	ra,0xfffff
    8000258c:	736080e7          	jalr	1846(ra) # 80001cbe <freeproc>
          release(&pp->lock);
    80002590:	8526                	mv	a0,s1
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	77a080e7          	jalr	1914(ra) # 80000d0c <release>
          release(&wait_lock);
    8000259a:	0000e517          	auipc	a0,0xe
    8000259e:	5ae50513          	addi	a0,a0,1454 # 80010b48 <wait_lock>
    800025a2:	ffffe097          	auipc	ra,0xffffe
    800025a6:	76a080e7          	jalr	1898(ra) # 80000d0c <release>
}
    800025aa:	854e                	mv	a0,s3
    800025ac:	60a6                	ld	ra,72(sp)
    800025ae:	6406                	ld	s0,64(sp)
    800025b0:	74e2                	ld	s1,56(sp)
    800025b2:	7942                	ld	s2,48(sp)
    800025b4:	79a2                	ld	s3,40(sp)
    800025b6:	7a02                	ld	s4,32(sp)
    800025b8:	6ae2                	ld	s5,24(sp)
    800025ba:	6b42                	ld	s6,16(sp)
    800025bc:	6ba2                	ld	s7,8(sp)
    800025be:	6161                	addi	sp,sp,80
    800025c0:	8082                	ret
            release(&pp->lock);
    800025c2:	8526                	mv	a0,s1
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	748080e7          	jalr	1864(ra) # 80000d0c <release>
            release(&wait_lock);
    800025cc:	0000e517          	auipc	a0,0xe
    800025d0:	57c50513          	addi	a0,a0,1404 # 80010b48 <wait_lock>
    800025d4:	ffffe097          	auipc	ra,0xffffe
    800025d8:	738080e7          	jalr	1848(ra) # 80000d0c <release>
            return -1;
    800025dc:	59fd                	li	s3,-1
    800025de:	b7f1                	j	800025aa <wait+0x8c>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025e0:	17848493          	addi	s1,s1,376
    800025e4:	03348463          	beq	s1,s3,8000260c <wait+0xee>
      if(pp->parent == p){
    800025e8:	7c9c                	ld	a5,56(s1)
    800025ea:	ff279be3          	bne	a5,s2,800025e0 <wait+0xc2>
        acquire(&pp->lock);
    800025ee:	8526                	mv	a0,s1
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	66c080e7          	jalr	1644(ra) # 80000c5c <acquire>
        if(pp->state == ZOMBIE){
    800025f8:	4c9c                	lw	a5,24(s1)
    800025fa:	f74786e3          	beq	a5,s4,80002566 <wait+0x48>
        release(&pp->lock);
    800025fe:	8526                	mv	a0,s1
    80002600:	ffffe097          	auipc	ra,0xffffe
    80002604:	70c080e7          	jalr	1804(ra) # 80000d0c <release>
        havekids = 1;
    80002608:	8756                	mv	a4,s5
    8000260a:	bfd9                	j	800025e0 <wait+0xc2>
    if(!havekids || killed(p)){
    8000260c:	c31d                	beqz	a4,80002632 <wait+0x114>
    8000260e:	854a                	mv	a0,s2
    80002610:	00000097          	auipc	ra,0x0
    80002614:	edc080e7          	jalr	-292(ra) # 800024ec <killed>
    80002618:	ed09                	bnez	a0,80002632 <wait+0x114>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000261a:	85da                	mv	a1,s6
    8000261c:	854a                	mv	a0,s2
    8000261e:	00000097          	auipc	ra,0x0
    80002622:	bfe080e7          	jalr	-1026(ra) # 8000221c <sleep>
    havekids = 0;
    80002626:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002628:	0000f497          	auipc	s1,0xf
    8000262c:	93848493          	addi	s1,s1,-1736 # 80010f60 <proc>
    80002630:	bf65                	j	800025e8 <wait+0xca>
      release(&wait_lock);
    80002632:	0000e517          	auipc	a0,0xe
    80002636:	51650513          	addi	a0,a0,1302 # 80010b48 <wait_lock>
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	6d2080e7          	jalr	1746(ra) # 80000d0c <release>
      return -1;
    80002642:	59fd                	li	s3,-1
    80002644:	b79d                	j	800025aa <wait+0x8c>

0000000080002646 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002646:	7179                	addi	sp,sp,-48
    80002648:	f406                	sd	ra,40(sp)
    8000264a:	f022                	sd	s0,32(sp)
    8000264c:	ec26                	sd	s1,24(sp)
    8000264e:	e84a                	sd	s2,16(sp)
    80002650:	e44e                	sd	s3,8(sp)
    80002652:	e052                	sd	s4,0(sp)
    80002654:	1800                	addi	s0,sp,48
    80002656:	84aa                	mv	s1,a0
    80002658:	8a2e                	mv	s4,a1
    8000265a:	89b2                	mv	s3,a2
    8000265c:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000265e:	fffff097          	auipc	ra,0xfffff
    80002662:	4ac080e7          	jalr	1196(ra) # 80001b0a <myproc>
  if(user_dst){
    80002666:	c08d                	beqz	s1,80002688 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002668:	86ca                	mv	a3,s2
    8000266a:	864e                	mv	a2,s3
    8000266c:	85d2                	mv	a1,s4
    8000266e:	6928                	ld	a0,80(a0)
    80002670:	fffff097          	auipc	ra,0xfffff
    80002674:	0a8080e7          	jalr	168(ra) # 80001718 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002678:	70a2                	ld	ra,40(sp)
    8000267a:	7402                	ld	s0,32(sp)
    8000267c:	64e2                	ld	s1,24(sp)
    8000267e:	6942                	ld	s2,16(sp)
    80002680:	69a2                	ld	s3,8(sp)
    80002682:	6a02                	ld	s4,0(sp)
    80002684:	6145                	addi	sp,sp,48
    80002686:	8082                	ret
    memmove((char *)dst, src, len);
    80002688:	0009061b          	sext.w	a2,s2
    8000268c:	85ce                	mv	a1,s3
    8000268e:	8552                	mv	a0,s4
    80002690:	ffffe097          	auipc	ra,0xffffe
    80002694:	724080e7          	jalr	1828(ra) # 80000db4 <memmove>
    return 0;
    80002698:	8526                	mv	a0,s1
    8000269a:	bff9                	j	80002678 <either_copyout+0x32>

000000008000269c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000269c:	7179                	addi	sp,sp,-48
    8000269e:	f406                	sd	ra,40(sp)
    800026a0:	f022                	sd	s0,32(sp)
    800026a2:	ec26                	sd	s1,24(sp)
    800026a4:	e84a                	sd	s2,16(sp)
    800026a6:	e44e                	sd	s3,8(sp)
    800026a8:	e052                	sd	s4,0(sp)
    800026aa:	1800                	addi	s0,sp,48
    800026ac:	8a2a                	mv	s4,a0
    800026ae:	84ae                	mv	s1,a1
    800026b0:	89b2                	mv	s3,a2
    800026b2:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800026b4:	fffff097          	auipc	ra,0xfffff
    800026b8:	456080e7          	jalr	1110(ra) # 80001b0a <myproc>
  if(user_src){
    800026bc:	c08d                	beqz	s1,800026de <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026be:	86ca                	mv	a3,s2
    800026c0:	864e                	mv	a2,s3
    800026c2:	85d2                	mv	a1,s4
    800026c4:	6928                	ld	a0,80(a0)
    800026c6:	fffff097          	auipc	ra,0xfffff
    800026ca:	0de080e7          	jalr	222(ra) # 800017a4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026ce:	70a2                	ld	ra,40(sp)
    800026d0:	7402                	ld	s0,32(sp)
    800026d2:	64e2                	ld	s1,24(sp)
    800026d4:	6942                	ld	s2,16(sp)
    800026d6:	69a2                	ld	s3,8(sp)
    800026d8:	6a02                	ld	s4,0(sp)
    800026da:	6145                	addi	sp,sp,48
    800026dc:	8082                	ret
    memmove(dst, (char*)src, len);
    800026de:	0009061b          	sext.w	a2,s2
    800026e2:	85ce                	mv	a1,s3
    800026e4:	8552                	mv	a0,s4
    800026e6:	ffffe097          	auipc	ra,0xffffe
    800026ea:	6ce080e7          	jalr	1742(ra) # 80000db4 <memmove>
    return 0;
    800026ee:	8526                	mv	a0,s1
    800026f0:	bff9                	j	800026ce <either_copyin+0x32>

00000000800026f2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800026f2:	715d                	addi	sp,sp,-80
    800026f4:	e486                	sd	ra,72(sp)
    800026f6:	e0a2                	sd	s0,64(sp)
    800026f8:	fc26                	sd	s1,56(sp)
    800026fa:	f84a                	sd	s2,48(sp)
    800026fc:	f44e                	sd	s3,40(sp)
    800026fe:	f052                	sd	s4,32(sp)
    80002700:	ec56                	sd	s5,24(sp)
    80002702:	e85a                	sd	s6,16(sp)
    80002704:	e45e                	sd	s7,8(sp)
    80002706:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002708:	00006517          	auipc	a0,0x6
    8000270c:	90850513          	addi	a0,a0,-1784 # 80008010 <etext+0x10>
    80002710:	ffffe097          	auipc	ra,0xffffe
    80002714:	e98080e7          	jalr	-360(ra) # 800005a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002718:	0000f497          	auipc	s1,0xf
    8000271c:	9a048493          	addi	s1,s1,-1632 # 800110b8 <proc+0x158>
    80002720:	00014917          	auipc	s2,0x14
    80002724:	79890913          	addi	s2,s2,1944 # 80016eb8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002728:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000272a:	00006997          	auipc	s3,0x6
    8000272e:	b3698993          	addi	s3,s3,-1226 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    80002732:	00006a97          	auipc	s5,0x6
    80002736:	b36a8a93          	addi	s5,s5,-1226 # 80008268 <etext+0x268>
    printf("\n");
    8000273a:	00006a17          	auipc	s4,0x6
    8000273e:	8d6a0a13          	addi	s4,s4,-1834 # 80008010 <etext+0x10>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002742:	00006b97          	auipc	s7,0x6
    80002746:	ffeb8b93          	addi	s7,s7,-2 # 80008740 <states.0>
    8000274a:	a00d                	j	8000276c <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000274c:	ed86a583          	lw	a1,-296(a3)
    80002750:	8556                	mv	a0,s5
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	e56080e7          	jalr	-426(ra) # 800005a8 <printf>
    printf("\n");
    8000275a:	8552                	mv	a0,s4
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	e4c080e7          	jalr	-436(ra) # 800005a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002764:	17848493          	addi	s1,s1,376
    80002768:	03248263          	beq	s1,s2,8000278c <procdump+0x9a>
    if(p->state == UNUSED)
    8000276c:	86a6                	mv	a3,s1
    8000276e:	ec04a783          	lw	a5,-320(s1)
    80002772:	dbed                	beqz	a5,80002764 <procdump+0x72>
      state = "???";
    80002774:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002776:	fcfb6be3          	bltu	s6,a5,8000274c <procdump+0x5a>
    8000277a:	02079713          	slli	a4,a5,0x20
    8000277e:	01d75793          	srli	a5,a4,0x1d
    80002782:	97de                	add	a5,a5,s7
    80002784:	6390                	ld	a2,0(a5)
    80002786:	f279                	bnez	a2,8000274c <procdump+0x5a>
      state = "???";
    80002788:	864e                	mv	a2,s3
    8000278a:	b7c9                	j	8000274c <procdump+0x5a>
  }
}
    8000278c:	60a6                	ld	ra,72(sp)
    8000278e:	6406                	ld	s0,64(sp)
    80002790:	74e2                	ld	s1,56(sp)
    80002792:	7942                	ld	s2,48(sp)
    80002794:	79a2                	ld	s3,40(sp)
    80002796:	7a02                	ld	s4,32(sp)
    80002798:	6ae2                	ld	s5,24(sp)
    8000279a:	6b42                	ld	s6,16(sp)
    8000279c:	6ba2                	ld	s7,8(sp)
    8000279e:	6161                	addi	sp,sp,80
    800027a0:	8082                	ret

00000000800027a2 <swtch>:
    800027a2:	00153023          	sd	ra,0(a0)
    800027a6:	00253423          	sd	sp,8(a0)
    800027aa:	e900                	sd	s0,16(a0)
    800027ac:	ed04                	sd	s1,24(a0)
    800027ae:	03253023          	sd	s2,32(a0)
    800027b2:	03353423          	sd	s3,40(a0)
    800027b6:	03453823          	sd	s4,48(a0)
    800027ba:	03553c23          	sd	s5,56(a0)
    800027be:	05653023          	sd	s6,64(a0)
    800027c2:	05753423          	sd	s7,72(a0)
    800027c6:	05853823          	sd	s8,80(a0)
    800027ca:	05953c23          	sd	s9,88(a0)
    800027ce:	07a53023          	sd	s10,96(a0)
    800027d2:	07b53423          	sd	s11,104(a0)
    800027d6:	0005b083          	ld	ra,0(a1)
    800027da:	0085b103          	ld	sp,8(a1)
    800027de:	6980                	ld	s0,16(a1)
    800027e0:	6d84                	ld	s1,24(a1)
    800027e2:	0205b903          	ld	s2,32(a1)
    800027e6:	0285b983          	ld	s3,40(a1)
    800027ea:	0305ba03          	ld	s4,48(a1)
    800027ee:	0385ba83          	ld	s5,56(a1)
    800027f2:	0405bb03          	ld	s6,64(a1)
    800027f6:	0485bb83          	ld	s7,72(a1)
    800027fa:	0505bc03          	ld	s8,80(a1)
    800027fe:	0585bc83          	ld	s9,88(a1)
    80002802:	0605bd03          	ld	s10,96(a1)
    80002806:	0685bd83          	ld	s11,104(a1)
    8000280a:	8082                	ret

000000008000280c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000280c:	1141                	addi	sp,sp,-16
    8000280e:	e406                	sd	ra,8(sp)
    80002810:	e022                	sd	s0,0(sp)
    80002812:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002814:	00006597          	auipc	a1,0x6
    80002818:	a9458593          	addi	a1,a1,-1388 # 800082a8 <etext+0x2a8>
    8000281c:	00014517          	auipc	a0,0x14
    80002820:	54450513          	addi	a0,a0,1348 # 80016d60 <tickslock>
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	39e080e7          	jalr	926(ra) # 80000bc2 <initlock>
}
    8000282c:	60a2                	ld	ra,8(sp)
    8000282e:	6402                	ld	s0,0(sp)
    80002830:	0141                	addi	sp,sp,16
    80002832:	8082                	ret

0000000080002834 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002834:	1141                	addi	sp,sp,-16
    80002836:	e406                	sd	ra,8(sp)
    80002838:	e022                	sd	s0,0(sp)
    8000283a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000283c:	00003797          	auipc	a5,0x3
    80002840:	66478793          	addi	a5,a5,1636 # 80005ea0 <kernelvec>
    80002844:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002848:	60a2                	ld	ra,8(sp)
    8000284a:	6402                	ld	s0,0(sp)
    8000284c:	0141                	addi	sp,sp,16
    8000284e:	8082                	ret

0000000080002850 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002850:	1141                	addi	sp,sp,-16
    80002852:	e406                	sd	ra,8(sp)
    80002854:	e022                	sd	s0,0(sp)
    80002856:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002858:	fffff097          	auipc	ra,0xfffff
    8000285c:	2b2080e7          	jalr	690(ra) # 80001b0a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002860:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002864:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002866:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000286a:	00004697          	auipc	a3,0x4
    8000286e:	79668693          	addi	a3,a3,1942 # 80007000 <_trampoline>
    80002872:	00004717          	auipc	a4,0x4
    80002876:	78e70713          	addi	a4,a4,1934 # 80007000 <_trampoline>
    8000287a:	8f15                	sub	a4,a4,a3
    8000287c:	040007b7          	lui	a5,0x4000
    80002880:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002882:	07b2                	slli	a5,a5,0xc
    80002884:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002886:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000288a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000288c:	18002673          	csrr	a2,satp
    80002890:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002892:	6d30                	ld	a2,88(a0)
    80002894:	6138                	ld	a4,64(a0)
    80002896:	6585                	lui	a1,0x1
    80002898:	972e                	add	a4,a4,a1
    8000289a:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000289c:	6d38                	ld	a4,88(a0)
    8000289e:	00000617          	auipc	a2,0x0
    800028a2:	13c60613          	addi	a2,a2,316 # 800029da <usertrap>
    800028a6:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028a8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028aa:	8612                	mv	a2,tp
    800028ac:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ae:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028b2:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028b6:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028ba:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028be:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028c0:	6f18                	ld	a4,24(a4)
    800028c2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800028c6:	6928                	ld	a0,80(a0)
    800028c8:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800028ca:	00004717          	auipc	a4,0x4
    800028ce:	7d270713          	addi	a4,a4,2002 # 8000709c <userret>
    800028d2:	8f15                	sub	a4,a4,a3
    800028d4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800028d6:	577d                	li	a4,-1
    800028d8:	177e                	slli	a4,a4,0x3f
    800028da:	8d59                	or	a0,a0,a4
    800028dc:	9782                	jalr	a5
}
    800028de:	60a2                	ld	ra,8(sp)
    800028e0:	6402                	ld	s0,0(sp)
    800028e2:	0141                	addi	sp,sp,16
    800028e4:	8082                	ret

00000000800028e6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800028e6:	1141                	addi	sp,sp,-16
    800028e8:	e406                	sd	ra,8(sp)
    800028ea:	e022                	sd	s0,0(sp)
    800028ec:	0800                	addi	s0,sp,16
  acquire(&tickslock);
    800028ee:	00014517          	auipc	a0,0x14
    800028f2:	47250513          	addi	a0,a0,1138 # 80016d60 <tickslock>
    800028f6:	ffffe097          	auipc	ra,0xffffe
    800028fa:	366080e7          	jalr	870(ra) # 80000c5c <acquire>
  ticks++;
    800028fe:	00006717          	auipc	a4,0x6
    80002902:	fc270713          	addi	a4,a4,-62 # 800088c0 <ticks>
    80002906:	431c                	lw	a5,0(a4)
    80002908:	2785                	addiw	a5,a5,1
    8000290a:	c31c                	sw	a5,0(a4)
  wakeup(&ticks);
    8000290c:	853a                	mv	a0,a4
    8000290e:	00000097          	auipc	ra,0x0
    80002912:	972080e7          	jalr	-1678(ra) # 80002280 <wakeup>
  release(&tickslock);
    80002916:	00014517          	auipc	a0,0x14
    8000291a:	44a50513          	addi	a0,a0,1098 # 80016d60 <tickslock>
    8000291e:	ffffe097          	auipc	ra,0xffffe
    80002922:	3ee080e7          	jalr	1006(ra) # 80000d0c <release>
}
    80002926:	60a2                	ld	ra,8(sp)
    80002928:	6402                	ld	s0,0(sp)
    8000292a:	0141                	addi	sp,sp,16
    8000292c:	8082                	ret

000000008000292e <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000292e:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002932:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002934:	0a07d263          	bgez	a5,800029d8 <devintr+0xaa>
{
    80002938:	1101                	addi	sp,sp,-32
    8000293a:	ec06                	sd	ra,24(sp)
    8000293c:	e822                	sd	s0,16(sp)
    8000293e:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002940:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002944:	46a5                	li	a3,9
    80002946:	00d70c63          	beq	a4,a3,8000295e <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    8000294a:	577d                	li	a4,-1
    8000294c:	177e                	slli	a4,a4,0x3f
    8000294e:	0705                	addi	a4,a4,1
    return 0;
    80002950:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002952:	06e78263          	beq	a5,a4,800029b6 <devintr+0x88>
  }
}
    80002956:	60e2                	ld	ra,24(sp)
    80002958:	6442                	ld	s0,16(sp)
    8000295a:	6105                	addi	sp,sp,32
    8000295c:	8082                	ret
    8000295e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002960:	00003097          	auipc	ra,0x3
    80002964:	64c080e7          	jalr	1612(ra) # 80005fac <plic_claim>
    80002968:	872a                	mv	a4,a0
    8000296a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000296c:	47a9                	li	a5,10
    8000296e:	00f50963          	beq	a0,a5,80002980 <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ){
    80002972:	4785                	li	a5,1
    80002974:	00f50b63          	beq	a0,a5,8000298a <devintr+0x5c>
    return 1;
    80002978:	4505                	li	a0,1
    } else if(irq){
    8000297a:	ef09                	bnez	a4,80002994 <devintr+0x66>
    8000297c:	64a2                	ld	s1,8(sp)
    8000297e:	bfe1                	j	80002956 <devintr+0x28>
      uartintr();
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	080080e7          	jalr	128(ra) # 80000a00 <uartintr>
    if(irq)
    80002988:	a839                	j	800029a6 <devintr+0x78>
      virtio_disk_intr();
    8000298a:	00004097          	auipc	ra,0x4
    8000298e:	b1c080e7          	jalr	-1252(ra) # 800064a6 <virtio_disk_intr>
    if(irq)
    80002992:	a811                	j	800029a6 <devintr+0x78>
      printf("unexpected interrupt irq=%d\n", irq);
    80002994:	85ba                	mv	a1,a4
    80002996:	00006517          	auipc	a0,0x6
    8000299a:	91a50513          	addi	a0,a0,-1766 # 800082b0 <etext+0x2b0>
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	c0a080e7          	jalr	-1014(ra) # 800005a8 <printf>
      plic_complete(irq);
    800029a6:	8526                	mv	a0,s1
    800029a8:	00003097          	auipc	ra,0x3
    800029ac:	628080e7          	jalr	1576(ra) # 80005fd0 <plic_complete>
    return 1;
    800029b0:	4505                	li	a0,1
    800029b2:	64a2                	ld	s1,8(sp)
    800029b4:	b74d                	j	80002956 <devintr+0x28>
    if(cpuid() == 0){
    800029b6:	fffff097          	auipc	ra,0xfffff
    800029ba:	120080e7          	jalr	288(ra) # 80001ad6 <cpuid>
    800029be:	c901                	beqz	a0,800029ce <devintr+0xa0>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800029c0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029c4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029c6:	14479073          	csrw	sip,a5
    return 2;
    800029ca:	4509                	li	a0,2
    800029cc:	b769                	j	80002956 <devintr+0x28>
      clockintr();
    800029ce:	00000097          	auipc	ra,0x0
    800029d2:	f18080e7          	jalr	-232(ra) # 800028e6 <clockintr>
    800029d6:	b7ed                	j	800029c0 <devintr+0x92>
}
    800029d8:	8082                	ret

00000000800029da <usertrap>:
{
    800029da:	1101                	addi	sp,sp,-32
    800029dc:	ec06                	sd	ra,24(sp)
    800029de:	e822                	sd	s0,16(sp)
    800029e0:	e426                	sd	s1,8(sp)
    800029e2:	e04a                	sd	s2,0(sp)
    800029e4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029ea:	1007f793          	andi	a5,a5,256
    800029ee:	e3b1                	bnez	a5,80002a32 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029f0:	00003797          	auipc	a5,0x3
    800029f4:	4b078793          	addi	a5,a5,1200 # 80005ea0 <kernelvec>
    800029f8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029fc:	fffff097          	auipc	ra,0xfffff
    80002a00:	10e080e7          	jalr	270(ra) # 80001b0a <myproc>
    80002a04:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a06:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a08:	14102773          	csrr	a4,sepc
    80002a0c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a0e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a12:	47a1                	li	a5,8
    80002a14:	02f70763          	beq	a4,a5,80002a42 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002a18:	00000097          	auipc	ra,0x0
    80002a1c:	f16080e7          	jalr	-234(ra) # 8000292e <devintr>
    80002a20:	892a                	mv	s2,a0
    80002a22:	c151                	beqz	a0,80002aa6 <usertrap+0xcc>
  if(killed(p))
    80002a24:	8526                	mv	a0,s1
    80002a26:	00000097          	auipc	ra,0x0
    80002a2a:	ac6080e7          	jalr	-1338(ra) # 800024ec <killed>
    80002a2e:	c929                	beqz	a0,80002a80 <usertrap+0xa6>
    80002a30:	a099                	j	80002a76 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002a32:	00006517          	auipc	a0,0x6
    80002a36:	89e50513          	addi	a0,a0,-1890 # 800082d0 <etext+0x2d0>
    80002a3a:	ffffe097          	auipc	ra,0xffffe
    80002a3e:	b24080e7          	jalr	-1244(ra) # 8000055e <panic>
    if(killed(p))
    80002a42:	00000097          	auipc	ra,0x0
    80002a46:	aaa080e7          	jalr	-1366(ra) # 800024ec <killed>
    80002a4a:	e921                	bnez	a0,80002a9a <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002a4c:	6cb8                	ld	a4,88(s1)
    80002a4e:	6f1c                	ld	a5,24(a4)
    80002a50:	0791                	addi	a5,a5,4
    80002a52:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a54:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a58:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a5c:	10079073          	csrw	sstatus,a5
    syscall();
    80002a60:	00000097          	auipc	ra,0x0
    80002a64:	2dc080e7          	jalr	732(ra) # 80002d3c <syscall>
  if(killed(p))
    80002a68:	8526                	mv	a0,s1
    80002a6a:	00000097          	auipc	ra,0x0
    80002a6e:	a82080e7          	jalr	-1406(ra) # 800024ec <killed>
    80002a72:	c911                	beqz	a0,80002a86 <usertrap+0xac>
    80002a74:	4901                	li	s2,0
    exit(-1);
    80002a76:	557d                	li	a0,-1
    80002a78:	00000097          	auipc	ra,0x0
    80002a7c:	8fc080e7          	jalr	-1796(ra) # 80002374 <exit>
  if(which_dev == 2){
    80002a80:	4789                	li	a5,2
    80002a82:	04f90f63          	beq	s2,a5,80002ae0 <usertrap+0x106>
  usertrapret();
    80002a86:	00000097          	auipc	ra,0x0
    80002a8a:	dca080e7          	jalr	-566(ra) # 80002850 <usertrapret>
}
    80002a8e:	60e2                	ld	ra,24(sp)
    80002a90:	6442                	ld	s0,16(sp)
    80002a92:	64a2                	ld	s1,8(sp)
    80002a94:	6902                	ld	s2,0(sp)
    80002a96:	6105                	addi	sp,sp,32
    80002a98:	8082                	ret
      exit(-1);
    80002a9a:	557d                	li	a0,-1
    80002a9c:	00000097          	auipc	ra,0x0
    80002aa0:	8d8080e7          	jalr	-1832(ra) # 80002374 <exit>
    80002aa4:	b765                	j	80002a4c <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aa6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002aaa:	5890                	lw	a2,48(s1)
    80002aac:	00006517          	auipc	a0,0x6
    80002ab0:	84450513          	addi	a0,a0,-1980 # 800082f0 <etext+0x2f0>
    80002ab4:	ffffe097          	auipc	ra,0xffffe
    80002ab8:	af4080e7          	jalr	-1292(ra) # 800005a8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002abc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ac0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ac4:	00006517          	auipc	a0,0x6
    80002ac8:	85c50513          	addi	a0,a0,-1956 # 80008320 <etext+0x320>
    80002acc:	ffffe097          	auipc	ra,0xffffe
    80002ad0:	adc080e7          	jalr	-1316(ra) # 800005a8 <printf>
    setkilled(p);
    80002ad4:	8526                	mv	a0,s1
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	9ea080e7          	jalr	-1558(ra) # 800024c0 <setkilled>
    80002ade:	b769                	j	80002a68 <usertrap+0x8e>
    p->accumulator += p->ps_priority;
    80002ae0:	1704a703          	lw	a4,368(s1)
    80002ae4:	1684b783          	ld	a5,360(s1)
    80002ae8:	97ba                	add	a5,a5,a4
    80002aea:	16f4b423          	sd	a5,360(s1)
    yield();
    80002aee:	fffff097          	auipc	ra,0xfffff
    80002af2:	6f2080e7          	jalr	1778(ra) # 800021e0 <yield>
    80002af6:	bf41                	j	80002a86 <usertrap+0xac>

0000000080002af8 <kerneltrap>:
{
    80002af8:	7179                	addi	sp,sp,-48
    80002afa:	f406                	sd	ra,40(sp)
    80002afc:	f022                	sd	s0,32(sp)
    80002afe:	ec26                	sd	s1,24(sp)
    80002b00:	e84a                	sd	s2,16(sp)
    80002b02:	e44e                	sd	s3,8(sp)
    80002b04:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b06:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b0a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b0e:	142027f3          	csrr	a5,scause
    80002b12:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002b14:	1004f793          	andi	a5,s1,256
    80002b18:	cb85                	beqz	a5,80002b48 <kerneltrap+0x50>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b1a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b1e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b20:	ef85                	bnez	a5,80002b58 <kerneltrap+0x60>
  if((which_dev = devintr()) == 0){
    80002b22:	00000097          	auipc	ra,0x0
    80002b26:	e0c080e7          	jalr	-500(ra) # 8000292e <devintr>
    80002b2a:	cd1d                	beqz	a0,80002b68 <kerneltrap+0x70>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b2c:	4789                	li	a5,2
    80002b2e:	06f50a63          	beq	a0,a5,80002ba2 <kerneltrap+0xaa>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b32:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b36:	10049073          	csrw	sstatus,s1
}
    80002b3a:	70a2                	ld	ra,40(sp)
    80002b3c:	7402                	ld	s0,32(sp)
    80002b3e:	64e2                	ld	s1,24(sp)
    80002b40:	6942                	ld	s2,16(sp)
    80002b42:	69a2                	ld	s3,8(sp)
    80002b44:	6145                	addi	sp,sp,48
    80002b46:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b48:	00005517          	auipc	a0,0x5
    80002b4c:	7f850513          	addi	a0,a0,2040 # 80008340 <etext+0x340>
    80002b50:	ffffe097          	auipc	ra,0xffffe
    80002b54:	a0e080e7          	jalr	-1522(ra) # 8000055e <panic>
    panic("kerneltrap: interrupts enabled");
    80002b58:	00006517          	auipc	a0,0x6
    80002b5c:	81050513          	addi	a0,a0,-2032 # 80008368 <etext+0x368>
    80002b60:	ffffe097          	auipc	ra,0xffffe
    80002b64:	9fe080e7          	jalr	-1538(ra) # 8000055e <panic>
    printf("scause %p\n", scause);
    80002b68:	85ce                	mv	a1,s3
    80002b6a:	00006517          	auipc	a0,0x6
    80002b6e:	81e50513          	addi	a0,a0,-2018 # 80008388 <etext+0x388>
    80002b72:	ffffe097          	auipc	ra,0xffffe
    80002b76:	a36080e7          	jalr	-1482(ra) # 800005a8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b7a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b7e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b82:	00006517          	auipc	a0,0x6
    80002b86:	81650513          	addi	a0,a0,-2026 # 80008398 <etext+0x398>
    80002b8a:	ffffe097          	auipc	ra,0xffffe
    80002b8e:	a1e080e7          	jalr	-1506(ra) # 800005a8 <printf>
    panic("kerneltrap");
    80002b92:	00006517          	auipc	a0,0x6
    80002b96:	81e50513          	addi	a0,a0,-2018 # 800083b0 <etext+0x3b0>
    80002b9a:	ffffe097          	auipc	ra,0xffffe
    80002b9e:	9c4080e7          	jalr	-1596(ra) # 8000055e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ba2:	fffff097          	auipc	ra,0xfffff
    80002ba6:	f68080e7          	jalr	-152(ra) # 80001b0a <myproc>
    80002baa:	d541                	beqz	a0,80002b32 <kerneltrap+0x3a>
    80002bac:	fffff097          	auipc	ra,0xfffff
    80002bb0:	f5e080e7          	jalr	-162(ra) # 80001b0a <myproc>
    80002bb4:	4d18                	lw	a4,24(a0)
    80002bb6:	4791                	li	a5,4
    80002bb8:	f6f71de3          	bne	a4,a5,80002b32 <kerneltrap+0x3a>
    yield();
    80002bbc:	fffff097          	auipc	ra,0xfffff
    80002bc0:	624080e7          	jalr	1572(ra) # 800021e0 <yield>
    80002bc4:	b7bd                	j	80002b32 <kerneltrap+0x3a>

0000000080002bc6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002bc6:	1101                	addi	sp,sp,-32
    80002bc8:	ec06                	sd	ra,24(sp)
    80002bca:	e822                	sd	s0,16(sp)
    80002bcc:	e426                	sd	s1,8(sp)
    80002bce:	1000                	addi	s0,sp,32
    80002bd0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002bd2:	fffff097          	auipc	ra,0xfffff
    80002bd6:	f38080e7          	jalr	-200(ra) # 80001b0a <myproc>
  switch (n) {
    80002bda:	4795                	li	a5,5
    80002bdc:	0497e163          	bltu	a5,s1,80002c1e <argraw+0x58>
    80002be0:	048a                	slli	s1,s1,0x2
    80002be2:	00006717          	auipc	a4,0x6
    80002be6:	b8e70713          	addi	a4,a4,-1138 # 80008770 <states.0+0x30>
    80002bea:	94ba                	add	s1,s1,a4
    80002bec:	409c                	lw	a5,0(s1)
    80002bee:	97ba                	add	a5,a5,a4
    80002bf0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002bf2:	6d3c                	ld	a5,88(a0)
    80002bf4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002bf6:	60e2                	ld	ra,24(sp)
    80002bf8:	6442                	ld	s0,16(sp)
    80002bfa:	64a2                	ld	s1,8(sp)
    80002bfc:	6105                	addi	sp,sp,32
    80002bfe:	8082                	ret
    return p->trapframe->a1;
    80002c00:	6d3c                	ld	a5,88(a0)
    80002c02:	7fa8                	ld	a0,120(a5)
    80002c04:	bfcd                	j	80002bf6 <argraw+0x30>
    return p->trapframe->a2;
    80002c06:	6d3c                	ld	a5,88(a0)
    80002c08:	63c8                	ld	a0,128(a5)
    80002c0a:	b7f5                	j	80002bf6 <argraw+0x30>
    return p->trapframe->a3;
    80002c0c:	6d3c                	ld	a5,88(a0)
    80002c0e:	67c8                	ld	a0,136(a5)
    80002c10:	b7dd                	j	80002bf6 <argraw+0x30>
    return p->trapframe->a4;
    80002c12:	6d3c                	ld	a5,88(a0)
    80002c14:	6bc8                	ld	a0,144(a5)
    80002c16:	b7c5                	j	80002bf6 <argraw+0x30>
    return p->trapframe->a5;
    80002c18:	6d3c                	ld	a5,88(a0)
    80002c1a:	6fc8                	ld	a0,152(a5)
    80002c1c:	bfe9                	j	80002bf6 <argraw+0x30>
  panic("argraw");
    80002c1e:	00005517          	auipc	a0,0x5
    80002c22:	7a250513          	addi	a0,a0,1954 # 800083c0 <etext+0x3c0>
    80002c26:	ffffe097          	auipc	ra,0xffffe
    80002c2a:	938080e7          	jalr	-1736(ra) # 8000055e <panic>

0000000080002c2e <fetchaddr>:
{
    80002c2e:	1101                	addi	sp,sp,-32
    80002c30:	ec06                	sd	ra,24(sp)
    80002c32:	e822                	sd	s0,16(sp)
    80002c34:	e426                	sd	s1,8(sp)
    80002c36:	e04a                	sd	s2,0(sp)
    80002c38:	1000                	addi	s0,sp,32
    80002c3a:	84aa                	mv	s1,a0
    80002c3c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	ecc080e7          	jalr	-308(ra) # 80001b0a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c46:	653c                	ld	a5,72(a0)
    80002c48:	02f4f863          	bgeu	s1,a5,80002c78 <fetchaddr+0x4a>
    80002c4c:	00848713          	addi	a4,s1,8
    80002c50:	02e7e663          	bltu	a5,a4,80002c7c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c54:	46a1                	li	a3,8
    80002c56:	8626                	mv	a2,s1
    80002c58:	85ca                	mv	a1,s2
    80002c5a:	6928                	ld	a0,80(a0)
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	b48080e7          	jalr	-1208(ra) # 800017a4 <copyin>
    80002c64:	00a03533          	snez	a0,a0
    80002c68:	40a0053b          	negw	a0,a0
}
    80002c6c:	60e2                	ld	ra,24(sp)
    80002c6e:	6442                	ld	s0,16(sp)
    80002c70:	64a2                	ld	s1,8(sp)
    80002c72:	6902                	ld	s2,0(sp)
    80002c74:	6105                	addi	sp,sp,32
    80002c76:	8082                	ret
    return -1;
    80002c78:	557d                	li	a0,-1
    80002c7a:	bfcd                	j	80002c6c <fetchaddr+0x3e>
    80002c7c:	557d                	li	a0,-1
    80002c7e:	b7fd                	j	80002c6c <fetchaddr+0x3e>

0000000080002c80 <fetchstr>:
{
    80002c80:	7179                	addi	sp,sp,-48
    80002c82:	f406                	sd	ra,40(sp)
    80002c84:	f022                	sd	s0,32(sp)
    80002c86:	ec26                	sd	s1,24(sp)
    80002c88:	e84a                	sd	s2,16(sp)
    80002c8a:	e44e                	sd	s3,8(sp)
    80002c8c:	1800                	addi	s0,sp,48
    80002c8e:	89aa                	mv	s3,a0
    80002c90:	84ae                	mv	s1,a1
    80002c92:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002c94:	fffff097          	auipc	ra,0xfffff
    80002c98:	e76080e7          	jalr	-394(ra) # 80001b0a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002c9c:	86ca                	mv	a3,s2
    80002c9e:	864e                	mv	a2,s3
    80002ca0:	85a6                	mv	a1,s1
    80002ca2:	6928                	ld	a0,80(a0)
    80002ca4:	fffff097          	auipc	ra,0xfffff
    80002ca8:	b8e080e7          	jalr	-1138(ra) # 80001832 <copyinstr>
    80002cac:	00054e63          	bltz	a0,80002cc8 <fetchstr+0x48>
  return strlen(buf);
    80002cb0:	8526                	mv	a0,s1
    80002cb2:	ffffe097          	auipc	ra,0xffffe
    80002cb6:	230080e7          	jalr	560(ra) # 80000ee2 <strlen>
}
    80002cba:	70a2                	ld	ra,40(sp)
    80002cbc:	7402                	ld	s0,32(sp)
    80002cbe:	64e2                	ld	s1,24(sp)
    80002cc0:	6942                	ld	s2,16(sp)
    80002cc2:	69a2                	ld	s3,8(sp)
    80002cc4:	6145                	addi	sp,sp,48
    80002cc6:	8082                	ret
    return -1;
    80002cc8:	557d                	li	a0,-1
    80002cca:	bfc5                	j	80002cba <fetchstr+0x3a>

0000000080002ccc <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ccc:	1101                	addi	sp,sp,-32
    80002cce:	ec06                	sd	ra,24(sp)
    80002cd0:	e822                	sd	s0,16(sp)
    80002cd2:	e426                	sd	s1,8(sp)
    80002cd4:	1000                	addi	s0,sp,32
    80002cd6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cd8:	00000097          	auipc	ra,0x0
    80002cdc:	eee080e7          	jalr	-274(ra) # 80002bc6 <argraw>
    80002ce0:	c088                	sw	a0,0(s1)
}
    80002ce2:	60e2                	ld	ra,24(sp)
    80002ce4:	6442                	ld	s0,16(sp)
    80002ce6:	64a2                	ld	s1,8(sp)
    80002ce8:	6105                	addi	sp,sp,32
    80002cea:	8082                	ret

0000000080002cec <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002cec:	1101                	addi	sp,sp,-32
    80002cee:	ec06                	sd	ra,24(sp)
    80002cf0:	e822                	sd	s0,16(sp)
    80002cf2:	e426                	sd	s1,8(sp)
    80002cf4:	1000                	addi	s0,sp,32
    80002cf6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cf8:	00000097          	auipc	ra,0x0
    80002cfc:	ece080e7          	jalr	-306(ra) # 80002bc6 <argraw>
    80002d00:	e088                	sd	a0,0(s1)
}
    80002d02:	60e2                	ld	ra,24(sp)
    80002d04:	6442                	ld	s0,16(sp)
    80002d06:	64a2                	ld	s1,8(sp)
    80002d08:	6105                	addi	sp,sp,32
    80002d0a:	8082                	ret

0000000080002d0c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d0c:	1101                	addi	sp,sp,-32
    80002d0e:	ec06                	sd	ra,24(sp)
    80002d10:	e822                	sd	s0,16(sp)
    80002d12:	e426                	sd	s1,8(sp)
    80002d14:	e04a                	sd	s2,0(sp)
    80002d16:	1000                	addi	s0,sp,32
    80002d18:	892e                	mv	s2,a1
    80002d1a:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002d1c:	00000097          	auipc	ra,0x0
    80002d20:	eaa080e7          	jalr	-342(ra) # 80002bc6 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002d24:	8626                	mv	a2,s1
    80002d26:	85ca                	mv	a1,s2
    80002d28:	00000097          	auipc	ra,0x0
    80002d2c:	f58080e7          	jalr	-168(ra) # 80002c80 <fetchstr>
}
    80002d30:	60e2                	ld	ra,24(sp)
    80002d32:	6442                	ld	s0,16(sp)
    80002d34:	64a2                	ld	s1,8(sp)
    80002d36:	6902                	ld	s2,0(sp)
    80002d38:	6105                	addi	sp,sp,32
    80002d3a:	8082                	ret

0000000080002d3c <syscall>:
[SYS_set_ps_priority] sys_set_ps_priority,
};

void
syscall(void)
{
    80002d3c:	1101                	addi	sp,sp,-32
    80002d3e:	ec06                	sd	ra,24(sp)
    80002d40:	e822                	sd	s0,16(sp)
    80002d42:	e426                	sd	s1,8(sp)
    80002d44:	e04a                	sd	s2,0(sp)
    80002d46:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d48:	fffff097          	auipc	ra,0xfffff
    80002d4c:	dc2080e7          	jalr	-574(ra) # 80001b0a <myproc>
    80002d50:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d52:	05853903          	ld	s2,88(a0)
    80002d56:	0a893783          	ld	a5,168(s2)
    80002d5a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d5e:	37fd                	addiw	a5,a5,-1
    80002d60:	4755                	li	a4,21
    80002d62:	00f76f63          	bltu	a4,a5,80002d80 <syscall+0x44>
    80002d66:	00369713          	slli	a4,a3,0x3
    80002d6a:	00006797          	auipc	a5,0x6
    80002d6e:	a1e78793          	addi	a5,a5,-1506 # 80008788 <syscalls>
    80002d72:	97ba                	add	a5,a5,a4
    80002d74:	639c                	ld	a5,0(a5)
    80002d76:	c789                	beqz	a5,80002d80 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d78:	9782                	jalr	a5
    80002d7a:	06a93823          	sd	a0,112(s2)
    80002d7e:	a839                	j	80002d9c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d80:	15848613          	addi	a2,s1,344
    80002d84:	588c                	lw	a1,48(s1)
    80002d86:	00005517          	auipc	a0,0x5
    80002d8a:	64250513          	addi	a0,a0,1602 # 800083c8 <etext+0x3c8>
    80002d8e:	ffffe097          	auipc	ra,0xffffe
    80002d92:	81a080e7          	jalr	-2022(ra) # 800005a8 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d96:	6cbc                	ld	a5,88(s1)
    80002d98:	577d                	li	a4,-1
    80002d9a:	fbb8                	sd	a4,112(a5)
  }
}
    80002d9c:	60e2                	ld	ra,24(sp)
    80002d9e:	6442                	ld	s0,16(sp)
    80002da0:	64a2                	ld	s1,8(sp)
    80002da2:	6902                	ld	s2,0(sp)
    80002da4:	6105                	addi	sp,sp,32
    80002da6:	8082                	ret

0000000080002da8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002da8:	1101                	addi	sp,sp,-32
    80002daa:	ec06                	sd	ra,24(sp)
    80002dac:	e822                	sd	s0,16(sp)
    80002dae:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002db0:	fec40593          	addi	a1,s0,-20
    80002db4:	4501                	li	a0,0
    80002db6:	00000097          	auipc	ra,0x0
    80002dba:	f16080e7          	jalr	-234(ra) # 80002ccc <argint>
  exit(n);
    80002dbe:	fec42503          	lw	a0,-20(s0)
    80002dc2:	fffff097          	auipc	ra,0xfffff
    80002dc6:	5b2080e7          	jalr	1458(ra) # 80002374 <exit>
  return 0;  // not reached
}
    80002dca:	4501                	li	a0,0
    80002dcc:	60e2                	ld	ra,24(sp)
    80002dce:	6442                	ld	s0,16(sp)
    80002dd0:	6105                	addi	sp,sp,32
    80002dd2:	8082                	ret

0000000080002dd4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002dd4:	1141                	addi	sp,sp,-16
    80002dd6:	e406                	sd	ra,8(sp)
    80002dd8:	e022                	sd	s0,0(sp)
    80002dda:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ddc:	fffff097          	auipc	ra,0xfffff
    80002de0:	d2e080e7          	jalr	-722(ra) # 80001b0a <myproc>
}
    80002de4:	5908                	lw	a0,48(a0)
    80002de6:	60a2                	ld	ra,8(sp)
    80002de8:	6402                	ld	s0,0(sp)
    80002dea:	0141                	addi	sp,sp,16
    80002dec:	8082                	ret

0000000080002dee <sys_fork>:

uint64
sys_fork(void)
{
    80002dee:	1141                	addi	sp,sp,-16
    80002df0:	e406                	sd	ra,8(sp)
    80002df2:	e022                	sd	s0,0(sp)
    80002df4:	0800                	addi	s0,sp,16
  return fork();
    80002df6:	fffff097          	auipc	ra,0xfffff
    80002dfa:	0ea080e7          	jalr	234(ra) # 80001ee0 <fork>
}
    80002dfe:	60a2                	ld	ra,8(sp)
    80002e00:	6402                	ld	s0,0(sp)
    80002e02:	0141                	addi	sp,sp,16
    80002e04:	8082                	ret

0000000080002e06 <sys_wait>:

uint64
sys_wait(void)
{
    80002e06:	1101                	addi	sp,sp,-32
    80002e08:	ec06                	sd	ra,24(sp)
    80002e0a:	e822                	sd	s0,16(sp)
    80002e0c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e0e:	fe840593          	addi	a1,s0,-24
    80002e12:	4501                	li	a0,0
    80002e14:	00000097          	auipc	ra,0x0
    80002e18:	ed8080e7          	jalr	-296(ra) # 80002cec <argaddr>
  return wait(p);
    80002e1c:	fe843503          	ld	a0,-24(s0)
    80002e20:	fffff097          	auipc	ra,0xfffff
    80002e24:	6fe080e7          	jalr	1790(ra) # 8000251e <wait>
}
    80002e28:	60e2                	ld	ra,24(sp)
    80002e2a:	6442                	ld	s0,16(sp)
    80002e2c:	6105                	addi	sp,sp,32
    80002e2e:	8082                	ret

0000000080002e30 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e30:	7179                	addi	sp,sp,-48
    80002e32:	f406                	sd	ra,40(sp)
    80002e34:	f022                	sd	s0,32(sp)
    80002e36:	ec26                	sd	s1,24(sp)
    80002e38:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002e3a:	fdc40593          	addi	a1,s0,-36
    80002e3e:	4501                	li	a0,0
    80002e40:	00000097          	auipc	ra,0x0
    80002e44:	e8c080e7          	jalr	-372(ra) # 80002ccc <argint>
  addr = myproc()->sz;
    80002e48:	fffff097          	auipc	ra,0xfffff
    80002e4c:	cc2080e7          	jalr	-830(ra) # 80001b0a <myproc>
    80002e50:	653c                	ld	a5,72(a0)
    80002e52:	84be                	mv	s1,a5
  if(growproc(n) < 0)
    80002e54:	fdc42503          	lw	a0,-36(s0)
    80002e58:	fffff097          	auipc	ra,0xfffff
    80002e5c:	02c080e7          	jalr	44(ra) # 80001e84 <growproc>
    80002e60:	00054863          	bltz	a0,80002e70 <sys_sbrk+0x40>
    return -1;
  return addr;
}
    80002e64:	8526                	mv	a0,s1
    80002e66:	70a2                	ld	ra,40(sp)
    80002e68:	7402                	ld	s0,32(sp)
    80002e6a:	64e2                	ld	s1,24(sp)
    80002e6c:	6145                	addi	sp,sp,48
    80002e6e:	8082                	ret
    return -1;
    80002e70:	57fd                	li	a5,-1
    80002e72:	84be                	mv	s1,a5
    80002e74:	bfc5                	j	80002e64 <sys_sbrk+0x34>

0000000080002e76 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e76:	7139                	addi	sp,sp,-64
    80002e78:	fc06                	sd	ra,56(sp)
    80002e7a:	f822                	sd	s0,48(sp)
    80002e7c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002e7e:	fcc40593          	addi	a1,s0,-52
    80002e82:	4501                	li	a0,0
    80002e84:	00000097          	auipc	ra,0x0
    80002e88:	e48080e7          	jalr	-440(ra) # 80002ccc <argint>
  acquire(&tickslock);
    80002e8c:	00014517          	auipc	a0,0x14
    80002e90:	ed450513          	addi	a0,a0,-300 # 80016d60 <tickslock>
    80002e94:	ffffe097          	auipc	ra,0xffffe
    80002e98:	dc8080e7          	jalr	-568(ra) # 80000c5c <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002e9c:	fcc42783          	lw	a5,-52(s0)
    80002ea0:	cba9                	beqz	a5,80002ef2 <sys_sleep+0x7c>
    80002ea2:	f426                	sd	s1,40(sp)
    80002ea4:	f04a                	sd	s2,32(sp)
    80002ea6:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002ea8:	00006997          	auipc	s3,0x6
    80002eac:	a189a983          	lw	s3,-1512(s3) # 800088c0 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002eb0:	00014917          	auipc	s2,0x14
    80002eb4:	eb090913          	addi	s2,s2,-336 # 80016d60 <tickslock>
    80002eb8:	00006497          	auipc	s1,0x6
    80002ebc:	a0848493          	addi	s1,s1,-1528 # 800088c0 <ticks>
    if(killed(myproc())){
    80002ec0:	fffff097          	auipc	ra,0xfffff
    80002ec4:	c4a080e7          	jalr	-950(ra) # 80001b0a <myproc>
    80002ec8:	fffff097          	auipc	ra,0xfffff
    80002ecc:	624080e7          	jalr	1572(ra) # 800024ec <killed>
    80002ed0:	ed15                	bnez	a0,80002f0c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002ed2:	85ca                	mv	a1,s2
    80002ed4:	8526                	mv	a0,s1
    80002ed6:	fffff097          	auipc	ra,0xfffff
    80002eda:	346080e7          	jalr	838(ra) # 8000221c <sleep>
  while(ticks - ticks0 < n){
    80002ede:	409c                	lw	a5,0(s1)
    80002ee0:	413787bb          	subw	a5,a5,s3
    80002ee4:	fcc42703          	lw	a4,-52(s0)
    80002ee8:	fce7ece3          	bltu	a5,a4,80002ec0 <sys_sleep+0x4a>
    80002eec:	74a2                	ld	s1,40(sp)
    80002eee:	7902                	ld	s2,32(sp)
    80002ef0:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002ef2:	00014517          	auipc	a0,0x14
    80002ef6:	e6e50513          	addi	a0,a0,-402 # 80016d60 <tickslock>
    80002efa:	ffffe097          	auipc	ra,0xffffe
    80002efe:	e12080e7          	jalr	-494(ra) # 80000d0c <release>
  return 0;
    80002f02:	4501                	li	a0,0
}
    80002f04:	70e2                	ld	ra,56(sp)
    80002f06:	7442                	ld	s0,48(sp)
    80002f08:	6121                	addi	sp,sp,64
    80002f0a:	8082                	ret
      release(&tickslock);
    80002f0c:	00014517          	auipc	a0,0x14
    80002f10:	e5450513          	addi	a0,a0,-428 # 80016d60 <tickslock>
    80002f14:	ffffe097          	auipc	ra,0xffffe
    80002f18:	df8080e7          	jalr	-520(ra) # 80000d0c <release>
      return -1;
    80002f1c:	557d                	li	a0,-1
    80002f1e:	74a2                	ld	s1,40(sp)
    80002f20:	7902                	ld	s2,32(sp)
    80002f22:	69e2                	ld	s3,24(sp)
    80002f24:	b7c5                	j	80002f04 <sys_sleep+0x8e>

0000000080002f26 <sys_kill>:

uint64
sys_kill(void)
{
    80002f26:	1101                	addi	sp,sp,-32
    80002f28:	ec06                	sd	ra,24(sp)
    80002f2a:	e822                	sd	s0,16(sp)
    80002f2c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f2e:	fec40593          	addi	a1,s0,-20
    80002f32:	4501                	li	a0,0
    80002f34:	00000097          	auipc	ra,0x0
    80002f38:	d98080e7          	jalr	-616(ra) # 80002ccc <argint>
  return kill(pid);
    80002f3c:	fec42503          	lw	a0,-20(s0)
    80002f40:	fffff097          	auipc	ra,0xfffff
    80002f44:	50e080e7          	jalr	1294(ra) # 8000244e <kill>
}
    80002f48:	60e2                	ld	ra,24(sp)
    80002f4a:	6442                	ld	s0,16(sp)
    80002f4c:	6105                	addi	sp,sp,32
    80002f4e:	8082                	ret

0000000080002f50 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f50:	1101                	addi	sp,sp,-32
    80002f52:	ec06                	sd	ra,24(sp)
    80002f54:	e822                	sd	s0,16(sp)
    80002f56:	e426                	sd	s1,8(sp)
    80002f58:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f5a:	00014517          	auipc	a0,0x14
    80002f5e:	e0650513          	addi	a0,a0,-506 # 80016d60 <tickslock>
    80002f62:	ffffe097          	auipc	ra,0xffffe
    80002f66:	cfa080e7          	jalr	-774(ra) # 80000c5c <acquire>
  xticks = ticks;
    80002f6a:	00006797          	auipc	a5,0x6
    80002f6e:	9567a783          	lw	a5,-1706(a5) # 800088c0 <ticks>
    80002f72:	84be                	mv	s1,a5
  release(&tickslock);
    80002f74:	00014517          	auipc	a0,0x14
    80002f78:	dec50513          	addi	a0,a0,-532 # 80016d60 <tickslock>
    80002f7c:	ffffe097          	auipc	ra,0xffffe
    80002f80:	d90080e7          	jalr	-624(ra) # 80000d0c <release>
  return xticks;
}
    80002f84:	02049513          	slli	a0,s1,0x20
    80002f88:	9101                	srli	a0,a0,0x20
    80002f8a:	60e2                	ld	ra,24(sp)
    80002f8c:	6442                	ld	s0,16(sp)
    80002f8e:	64a2                	ld	s1,8(sp)
    80002f90:	6105                	addi	sp,sp,32
    80002f92:	8082                	ret

0000000080002f94 <sys_set_ps_priority>:

// step 3
uint64
sys_set_ps_priority(void){
    80002f94:	7179                	addi	sp,sp,-48
    80002f96:	f406                	sd	ra,40(sp)
    80002f98:	f022                	sd	s0,32(sp)
    80002f9a:	ec26                	sd	s1,24(sp)
    80002f9c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002f9e:	fffff097          	auipc	ra,0xfffff
    80002fa2:	b6c080e7          	jalr	-1172(ra) # 80001b0a <myproc>
    80002fa6:	84aa                	mv	s1,a0
  int priority;
  argint(0,&priority);
    80002fa8:	fdc40593          	addi	a1,s0,-36
    80002fac:	4501                	li	a0,0
    80002fae:	00000097          	auipc	ra,0x0
    80002fb2:	d1e080e7          	jalr	-738(ra) # 80002ccc <argint>
  if(priority < 1 || priority > 10){
    80002fb6:	fdc42783          	lw	a5,-36(s0)
    80002fba:	37fd                	addiw	a5,a5,-1
    80002fbc:	4725                	li	a4,9
    return -1;
    80002fbe:	557d                	li	a0,-1
  if(priority < 1 || priority > 10){
    80002fc0:	02f76163          	bltu	a4,a5,80002fe2 <sys_set_ps_priority+0x4e>
  }
  acquire(&p->lock);
    80002fc4:	8526                	mv	a0,s1
    80002fc6:	ffffe097          	auipc	ra,0xffffe
    80002fca:	c96080e7          	jalr	-874(ra) # 80000c5c <acquire>
  p->ps_priority = priority;
    80002fce:	fdc42783          	lw	a5,-36(s0)
    80002fd2:	16f4a823          	sw	a5,368(s1)
  release(&p->lock);
    80002fd6:	8526                	mv	a0,s1
    80002fd8:	ffffe097          	auipc	ra,0xffffe
    80002fdc:	d34080e7          	jalr	-716(ra) # 80000d0c <release>

  return 0;
    80002fe0:	4501                	li	a0,0
    80002fe2:	70a2                	ld	ra,40(sp)
    80002fe4:	7402                	ld	s0,32(sp)
    80002fe6:	64e2                	ld	s1,24(sp)
    80002fe8:	6145                	addi	sp,sp,48
    80002fea:	8082                	ret

0000000080002fec <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fec:	7179                	addi	sp,sp,-48
    80002fee:	f406                	sd	ra,40(sp)
    80002ff0:	f022                	sd	s0,32(sp)
    80002ff2:	ec26                	sd	s1,24(sp)
    80002ff4:	e84a                	sd	s2,16(sp)
    80002ff6:	e44e                	sd	s3,8(sp)
    80002ff8:	e052                	sd	s4,0(sp)
    80002ffa:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ffc:	00005597          	auipc	a1,0x5
    80003000:	3ec58593          	addi	a1,a1,1004 # 800083e8 <etext+0x3e8>
    80003004:	00014517          	auipc	a0,0x14
    80003008:	d7450513          	addi	a0,a0,-652 # 80016d78 <bcache>
    8000300c:	ffffe097          	auipc	ra,0xffffe
    80003010:	bb6080e7          	jalr	-1098(ra) # 80000bc2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003014:	0001c797          	auipc	a5,0x1c
    80003018:	d6478793          	addi	a5,a5,-668 # 8001ed78 <bcache+0x8000>
    8000301c:	0001c717          	auipc	a4,0x1c
    80003020:	fc470713          	addi	a4,a4,-60 # 8001efe0 <bcache+0x8268>
    80003024:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003028:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000302c:	00014497          	auipc	s1,0x14
    80003030:	d6448493          	addi	s1,s1,-668 # 80016d90 <bcache+0x18>
    b->next = bcache.head.next;
    80003034:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003036:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003038:	00005a17          	auipc	s4,0x5
    8000303c:	3b8a0a13          	addi	s4,s4,952 # 800083f0 <etext+0x3f0>
    b->next = bcache.head.next;
    80003040:	2b893783          	ld	a5,696(s2)
    80003044:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003046:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000304a:	85d2                	mv	a1,s4
    8000304c:	01048513          	addi	a0,s1,16
    80003050:	00001097          	auipc	ra,0x1
    80003054:	4ec080e7          	jalr	1260(ra) # 8000453c <initsleeplock>
    bcache.head.next->prev = b;
    80003058:	2b893783          	ld	a5,696(s2)
    8000305c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000305e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003062:	45848493          	addi	s1,s1,1112
    80003066:	fd349de3          	bne	s1,s3,80003040 <binit+0x54>
  }
}
    8000306a:	70a2                	ld	ra,40(sp)
    8000306c:	7402                	ld	s0,32(sp)
    8000306e:	64e2                	ld	s1,24(sp)
    80003070:	6942                	ld	s2,16(sp)
    80003072:	69a2                	ld	s3,8(sp)
    80003074:	6a02                	ld	s4,0(sp)
    80003076:	6145                	addi	sp,sp,48
    80003078:	8082                	ret

000000008000307a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000307a:	7179                	addi	sp,sp,-48
    8000307c:	f406                	sd	ra,40(sp)
    8000307e:	f022                	sd	s0,32(sp)
    80003080:	ec26                	sd	s1,24(sp)
    80003082:	e84a                	sd	s2,16(sp)
    80003084:	e44e                	sd	s3,8(sp)
    80003086:	1800                	addi	s0,sp,48
    80003088:	892a                	mv	s2,a0
    8000308a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000308c:	00014517          	auipc	a0,0x14
    80003090:	cec50513          	addi	a0,a0,-788 # 80016d78 <bcache>
    80003094:	ffffe097          	auipc	ra,0xffffe
    80003098:	bc8080e7          	jalr	-1080(ra) # 80000c5c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000309c:	0001c497          	auipc	s1,0x1c
    800030a0:	f944b483          	ld	s1,-108(s1) # 8001f030 <bcache+0x82b8>
    800030a4:	0001c797          	auipc	a5,0x1c
    800030a8:	f3c78793          	addi	a5,a5,-196 # 8001efe0 <bcache+0x8268>
    800030ac:	02f48f63          	beq	s1,a5,800030ea <bread+0x70>
    800030b0:	873e                	mv	a4,a5
    800030b2:	a021                	j	800030ba <bread+0x40>
    800030b4:	68a4                	ld	s1,80(s1)
    800030b6:	02e48a63          	beq	s1,a4,800030ea <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800030ba:	449c                	lw	a5,8(s1)
    800030bc:	ff279ce3          	bne	a5,s2,800030b4 <bread+0x3a>
    800030c0:	44dc                	lw	a5,12(s1)
    800030c2:	ff3799e3          	bne	a5,s3,800030b4 <bread+0x3a>
      b->refcnt++;
    800030c6:	40bc                	lw	a5,64(s1)
    800030c8:	2785                	addiw	a5,a5,1
    800030ca:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030cc:	00014517          	auipc	a0,0x14
    800030d0:	cac50513          	addi	a0,a0,-852 # 80016d78 <bcache>
    800030d4:	ffffe097          	auipc	ra,0xffffe
    800030d8:	c38080e7          	jalr	-968(ra) # 80000d0c <release>
      acquiresleep(&b->lock);
    800030dc:	01048513          	addi	a0,s1,16
    800030e0:	00001097          	auipc	ra,0x1
    800030e4:	496080e7          	jalr	1174(ra) # 80004576 <acquiresleep>
      return b;
    800030e8:	a8b9                	j	80003146 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030ea:	0001c497          	auipc	s1,0x1c
    800030ee:	f3e4b483          	ld	s1,-194(s1) # 8001f028 <bcache+0x82b0>
    800030f2:	0001c797          	auipc	a5,0x1c
    800030f6:	eee78793          	addi	a5,a5,-274 # 8001efe0 <bcache+0x8268>
    800030fa:	00f48863          	beq	s1,a5,8000310a <bread+0x90>
    800030fe:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003100:	40bc                	lw	a5,64(s1)
    80003102:	cf81                	beqz	a5,8000311a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003104:	64a4                	ld	s1,72(s1)
    80003106:	fee49de3          	bne	s1,a4,80003100 <bread+0x86>
  panic("bget: no buffers");
    8000310a:	00005517          	auipc	a0,0x5
    8000310e:	2ee50513          	addi	a0,a0,750 # 800083f8 <etext+0x3f8>
    80003112:	ffffd097          	auipc	ra,0xffffd
    80003116:	44c080e7          	jalr	1100(ra) # 8000055e <panic>
      b->dev = dev;
    8000311a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000311e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003122:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003126:	4785                	li	a5,1
    80003128:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000312a:	00014517          	auipc	a0,0x14
    8000312e:	c4e50513          	addi	a0,a0,-946 # 80016d78 <bcache>
    80003132:	ffffe097          	auipc	ra,0xffffe
    80003136:	bda080e7          	jalr	-1062(ra) # 80000d0c <release>
      acquiresleep(&b->lock);
    8000313a:	01048513          	addi	a0,s1,16
    8000313e:	00001097          	auipc	ra,0x1
    80003142:	438080e7          	jalr	1080(ra) # 80004576 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003146:	409c                	lw	a5,0(s1)
    80003148:	cb89                	beqz	a5,8000315a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000314a:	8526                	mv	a0,s1
    8000314c:	70a2                	ld	ra,40(sp)
    8000314e:	7402                	ld	s0,32(sp)
    80003150:	64e2                	ld	s1,24(sp)
    80003152:	6942                	ld	s2,16(sp)
    80003154:	69a2                	ld	s3,8(sp)
    80003156:	6145                	addi	sp,sp,48
    80003158:	8082                	ret
    virtio_disk_rw(b, 0);
    8000315a:	4581                	li	a1,0
    8000315c:	8526                	mv	a0,s1
    8000315e:	00003097          	auipc	ra,0x3
    80003162:	11a080e7          	jalr	282(ra) # 80006278 <virtio_disk_rw>
    b->valid = 1;
    80003166:	4785                	li	a5,1
    80003168:	c09c                	sw	a5,0(s1)
  return b;
    8000316a:	b7c5                	j	8000314a <bread+0xd0>

000000008000316c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000316c:	1101                	addi	sp,sp,-32
    8000316e:	ec06                	sd	ra,24(sp)
    80003170:	e822                	sd	s0,16(sp)
    80003172:	e426                	sd	s1,8(sp)
    80003174:	1000                	addi	s0,sp,32
    80003176:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003178:	0541                	addi	a0,a0,16
    8000317a:	00001097          	auipc	ra,0x1
    8000317e:	496080e7          	jalr	1174(ra) # 80004610 <holdingsleep>
    80003182:	cd01                	beqz	a0,8000319a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003184:	4585                	li	a1,1
    80003186:	8526                	mv	a0,s1
    80003188:	00003097          	auipc	ra,0x3
    8000318c:	0f0080e7          	jalr	240(ra) # 80006278 <virtio_disk_rw>
}
    80003190:	60e2                	ld	ra,24(sp)
    80003192:	6442                	ld	s0,16(sp)
    80003194:	64a2                	ld	s1,8(sp)
    80003196:	6105                	addi	sp,sp,32
    80003198:	8082                	ret
    panic("bwrite");
    8000319a:	00005517          	auipc	a0,0x5
    8000319e:	27650513          	addi	a0,a0,630 # 80008410 <etext+0x410>
    800031a2:	ffffd097          	auipc	ra,0xffffd
    800031a6:	3bc080e7          	jalr	956(ra) # 8000055e <panic>

00000000800031aa <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031aa:	1101                	addi	sp,sp,-32
    800031ac:	ec06                	sd	ra,24(sp)
    800031ae:	e822                	sd	s0,16(sp)
    800031b0:	e426                	sd	s1,8(sp)
    800031b2:	e04a                	sd	s2,0(sp)
    800031b4:	1000                	addi	s0,sp,32
    800031b6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031b8:	01050913          	addi	s2,a0,16
    800031bc:	854a                	mv	a0,s2
    800031be:	00001097          	auipc	ra,0x1
    800031c2:	452080e7          	jalr	1106(ra) # 80004610 <holdingsleep>
    800031c6:	c535                	beqz	a0,80003232 <brelse+0x88>
    panic("brelse");

  releasesleep(&b->lock);
    800031c8:	854a                	mv	a0,s2
    800031ca:	00001097          	auipc	ra,0x1
    800031ce:	402080e7          	jalr	1026(ra) # 800045cc <releasesleep>

  acquire(&bcache.lock);
    800031d2:	00014517          	auipc	a0,0x14
    800031d6:	ba650513          	addi	a0,a0,-1114 # 80016d78 <bcache>
    800031da:	ffffe097          	auipc	ra,0xffffe
    800031de:	a82080e7          	jalr	-1406(ra) # 80000c5c <acquire>
  b->refcnt--;
    800031e2:	40bc                	lw	a5,64(s1)
    800031e4:	37fd                	addiw	a5,a5,-1
    800031e6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031e8:	e79d                	bnez	a5,80003216 <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031ea:	68b8                	ld	a4,80(s1)
    800031ec:	64bc                	ld	a5,72(s1)
    800031ee:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800031f0:	68b8                	ld	a4,80(s1)
    800031f2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031f4:	0001c797          	auipc	a5,0x1c
    800031f8:	b8478793          	addi	a5,a5,-1148 # 8001ed78 <bcache+0x8000>
    800031fc:	2b87b703          	ld	a4,696(a5)
    80003200:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003202:	0001c717          	auipc	a4,0x1c
    80003206:	dde70713          	addi	a4,a4,-546 # 8001efe0 <bcache+0x8268>
    8000320a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000320c:	2b87b703          	ld	a4,696(a5)
    80003210:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003212:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003216:	00014517          	auipc	a0,0x14
    8000321a:	b6250513          	addi	a0,a0,-1182 # 80016d78 <bcache>
    8000321e:	ffffe097          	auipc	ra,0xffffe
    80003222:	aee080e7          	jalr	-1298(ra) # 80000d0c <release>
}
    80003226:	60e2                	ld	ra,24(sp)
    80003228:	6442                	ld	s0,16(sp)
    8000322a:	64a2                	ld	s1,8(sp)
    8000322c:	6902                	ld	s2,0(sp)
    8000322e:	6105                	addi	sp,sp,32
    80003230:	8082                	ret
    panic("brelse");
    80003232:	00005517          	auipc	a0,0x5
    80003236:	1e650513          	addi	a0,a0,486 # 80008418 <etext+0x418>
    8000323a:	ffffd097          	auipc	ra,0xffffd
    8000323e:	324080e7          	jalr	804(ra) # 8000055e <panic>

0000000080003242 <bpin>:

void
bpin(struct buf *b) {
    80003242:	1101                	addi	sp,sp,-32
    80003244:	ec06                	sd	ra,24(sp)
    80003246:	e822                	sd	s0,16(sp)
    80003248:	e426                	sd	s1,8(sp)
    8000324a:	1000                	addi	s0,sp,32
    8000324c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000324e:	00014517          	auipc	a0,0x14
    80003252:	b2a50513          	addi	a0,a0,-1238 # 80016d78 <bcache>
    80003256:	ffffe097          	auipc	ra,0xffffe
    8000325a:	a06080e7          	jalr	-1530(ra) # 80000c5c <acquire>
  b->refcnt++;
    8000325e:	40bc                	lw	a5,64(s1)
    80003260:	2785                	addiw	a5,a5,1
    80003262:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003264:	00014517          	auipc	a0,0x14
    80003268:	b1450513          	addi	a0,a0,-1260 # 80016d78 <bcache>
    8000326c:	ffffe097          	auipc	ra,0xffffe
    80003270:	aa0080e7          	jalr	-1376(ra) # 80000d0c <release>
}
    80003274:	60e2                	ld	ra,24(sp)
    80003276:	6442                	ld	s0,16(sp)
    80003278:	64a2                	ld	s1,8(sp)
    8000327a:	6105                	addi	sp,sp,32
    8000327c:	8082                	ret

000000008000327e <bunpin>:

void
bunpin(struct buf *b) {
    8000327e:	1101                	addi	sp,sp,-32
    80003280:	ec06                	sd	ra,24(sp)
    80003282:	e822                	sd	s0,16(sp)
    80003284:	e426                	sd	s1,8(sp)
    80003286:	1000                	addi	s0,sp,32
    80003288:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000328a:	00014517          	auipc	a0,0x14
    8000328e:	aee50513          	addi	a0,a0,-1298 # 80016d78 <bcache>
    80003292:	ffffe097          	auipc	ra,0xffffe
    80003296:	9ca080e7          	jalr	-1590(ra) # 80000c5c <acquire>
  b->refcnt--;
    8000329a:	40bc                	lw	a5,64(s1)
    8000329c:	37fd                	addiw	a5,a5,-1
    8000329e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032a0:	00014517          	auipc	a0,0x14
    800032a4:	ad850513          	addi	a0,a0,-1320 # 80016d78 <bcache>
    800032a8:	ffffe097          	auipc	ra,0xffffe
    800032ac:	a64080e7          	jalr	-1436(ra) # 80000d0c <release>
}
    800032b0:	60e2                	ld	ra,24(sp)
    800032b2:	6442                	ld	s0,16(sp)
    800032b4:	64a2                	ld	s1,8(sp)
    800032b6:	6105                	addi	sp,sp,32
    800032b8:	8082                	ret

00000000800032ba <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032ba:	1101                	addi	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	e426                	sd	s1,8(sp)
    800032c2:	e04a                	sd	s2,0(sp)
    800032c4:	1000                	addi	s0,sp,32
    800032c6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032c8:	00d5d79b          	srliw	a5,a1,0xd
    800032cc:	0001c597          	auipc	a1,0x1c
    800032d0:	1885a583          	lw	a1,392(a1) # 8001f454 <sb+0x1c>
    800032d4:	9dbd                	addw	a1,a1,a5
    800032d6:	00000097          	auipc	ra,0x0
    800032da:	da4080e7          	jalr	-604(ra) # 8000307a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032de:	0074f713          	andi	a4,s1,7
    800032e2:	4785                	li	a5,1
    800032e4:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800032e8:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    800032ea:	90d9                	srli	s1,s1,0x36
    800032ec:	00950733          	add	a4,a0,s1
    800032f0:	05874703          	lbu	a4,88(a4)
    800032f4:	00e7f6b3          	and	a3,a5,a4
    800032f8:	c69d                	beqz	a3,80003326 <bfree+0x6c>
    800032fa:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032fc:	94aa                	add	s1,s1,a0
    800032fe:	fff7c793          	not	a5,a5
    80003302:	8f7d                	and	a4,a4,a5
    80003304:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003308:	00001097          	auipc	ra,0x1
    8000330c:	14e080e7          	jalr	334(ra) # 80004456 <log_write>
  brelse(bp);
    80003310:	854a                	mv	a0,s2
    80003312:	00000097          	auipc	ra,0x0
    80003316:	e98080e7          	jalr	-360(ra) # 800031aa <brelse>
}
    8000331a:	60e2                	ld	ra,24(sp)
    8000331c:	6442                	ld	s0,16(sp)
    8000331e:	64a2                	ld	s1,8(sp)
    80003320:	6902                	ld	s2,0(sp)
    80003322:	6105                	addi	sp,sp,32
    80003324:	8082                	ret
    panic("freeing free block");
    80003326:	00005517          	auipc	a0,0x5
    8000332a:	0fa50513          	addi	a0,a0,250 # 80008420 <etext+0x420>
    8000332e:	ffffd097          	auipc	ra,0xffffd
    80003332:	230080e7          	jalr	560(ra) # 8000055e <panic>

0000000080003336 <balloc>:
{
    80003336:	715d                	addi	sp,sp,-80
    80003338:	e486                	sd	ra,72(sp)
    8000333a:	e0a2                	sd	s0,64(sp)
    8000333c:	fc26                	sd	s1,56(sp)
    8000333e:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003340:	0001c797          	auipc	a5,0x1c
    80003344:	0fc7a783          	lw	a5,252(a5) # 8001f43c <sb+0x4>
    80003348:	10078263          	beqz	a5,8000344c <balloc+0x116>
    8000334c:	f84a                	sd	s2,48(sp)
    8000334e:	f44e                	sd	s3,40(sp)
    80003350:	f052                	sd	s4,32(sp)
    80003352:	ec56                	sd	s5,24(sp)
    80003354:	e85a                	sd	s6,16(sp)
    80003356:	e45e                	sd	s7,8(sp)
    80003358:	e062                	sd	s8,0(sp)
    8000335a:	8baa                	mv	s7,a0
    8000335c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000335e:	0001cb17          	auipc	s6,0x1c
    80003362:	0dab0b13          	addi	s6,s6,218 # 8001f438 <sb>
      m = 1 << (bi % 8);
    80003366:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003368:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000336a:	6c09                	lui	s8,0x2
    8000336c:	a049                	j	800033ee <balloc+0xb8>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000336e:	97ca                	add	a5,a5,s2
    80003370:	8e55                	or	a2,a2,a3
    80003372:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003376:	854a                	mv	a0,s2
    80003378:	00001097          	auipc	ra,0x1
    8000337c:	0de080e7          	jalr	222(ra) # 80004456 <log_write>
        brelse(bp);
    80003380:	854a                	mv	a0,s2
    80003382:	00000097          	auipc	ra,0x0
    80003386:	e28080e7          	jalr	-472(ra) # 800031aa <brelse>
  bp = bread(dev, bno);
    8000338a:	85a6                	mv	a1,s1
    8000338c:	855e                	mv	a0,s7
    8000338e:	00000097          	auipc	ra,0x0
    80003392:	cec080e7          	jalr	-788(ra) # 8000307a <bread>
    80003396:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003398:	40000613          	li	a2,1024
    8000339c:	4581                	li	a1,0
    8000339e:	05850513          	addi	a0,a0,88
    800033a2:	ffffe097          	auipc	ra,0xffffe
    800033a6:	9b2080e7          	jalr	-1614(ra) # 80000d54 <memset>
  log_write(bp);
    800033aa:	854a                	mv	a0,s2
    800033ac:	00001097          	auipc	ra,0x1
    800033b0:	0aa080e7          	jalr	170(ra) # 80004456 <log_write>
  brelse(bp);
    800033b4:	854a                	mv	a0,s2
    800033b6:	00000097          	auipc	ra,0x0
    800033ba:	df4080e7          	jalr	-524(ra) # 800031aa <brelse>
}
    800033be:	7942                	ld	s2,48(sp)
    800033c0:	79a2                	ld	s3,40(sp)
    800033c2:	7a02                	ld	s4,32(sp)
    800033c4:	6ae2                	ld	s5,24(sp)
    800033c6:	6b42                	ld	s6,16(sp)
    800033c8:	6ba2                	ld	s7,8(sp)
    800033ca:	6c02                	ld	s8,0(sp)
}
    800033cc:	8526                	mv	a0,s1
    800033ce:	60a6                	ld	ra,72(sp)
    800033d0:	6406                	ld	s0,64(sp)
    800033d2:	74e2                	ld	s1,56(sp)
    800033d4:	6161                	addi	sp,sp,80
    800033d6:	8082                	ret
    brelse(bp);
    800033d8:	854a                	mv	a0,s2
    800033da:	00000097          	auipc	ra,0x0
    800033de:	dd0080e7          	jalr	-560(ra) # 800031aa <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033e2:	015c0abb          	addw	s5,s8,s5
    800033e6:	004b2783          	lw	a5,4(s6)
    800033ea:	04fafa63          	bgeu	s5,a5,8000343e <balloc+0x108>
    bp = bread(dev, BBLOCK(b, sb));
    800033ee:	40dad59b          	sraiw	a1,s5,0xd
    800033f2:	01cb2783          	lw	a5,28(s6)
    800033f6:	9dbd                	addw	a1,a1,a5
    800033f8:	855e                	mv	a0,s7
    800033fa:	00000097          	auipc	ra,0x0
    800033fe:	c80080e7          	jalr	-896(ra) # 8000307a <bread>
    80003402:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003404:	004b2503          	lw	a0,4(s6)
    80003408:	84d6                	mv	s1,s5
    8000340a:	4701                	li	a4,0
    8000340c:	fca4f6e3          	bgeu	s1,a0,800033d8 <balloc+0xa2>
      m = 1 << (bi % 8);
    80003410:	00777693          	andi	a3,a4,7
    80003414:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003418:	41f7579b          	sraiw	a5,a4,0x1f
    8000341c:	01d7d79b          	srliw	a5,a5,0x1d
    80003420:	9fb9                	addw	a5,a5,a4
    80003422:	4037d79b          	sraiw	a5,a5,0x3
    80003426:	00f90633          	add	a2,s2,a5
    8000342a:	05864603          	lbu	a2,88(a2)
    8000342e:	00c6f5b3          	and	a1,a3,a2
    80003432:	dd95                	beqz	a1,8000336e <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003434:	2705                	addiw	a4,a4,1
    80003436:	2485                	addiw	s1,s1,1
    80003438:	fd471ae3          	bne	a4,s4,8000340c <balloc+0xd6>
    8000343c:	bf71                	j	800033d8 <balloc+0xa2>
    8000343e:	7942                	ld	s2,48(sp)
    80003440:	79a2                	ld	s3,40(sp)
    80003442:	7a02                	ld	s4,32(sp)
    80003444:	6ae2                	ld	s5,24(sp)
    80003446:	6b42                	ld	s6,16(sp)
    80003448:	6ba2                	ld	s7,8(sp)
    8000344a:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    8000344c:	00005517          	auipc	a0,0x5
    80003450:	fec50513          	addi	a0,a0,-20 # 80008438 <etext+0x438>
    80003454:	ffffd097          	auipc	ra,0xffffd
    80003458:	154080e7          	jalr	340(ra) # 800005a8 <printf>
  return 0;
    8000345c:	4481                	li	s1,0
    8000345e:	b7bd                	j	800033cc <balloc+0x96>

0000000080003460 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003460:	7179                	addi	sp,sp,-48
    80003462:	f406                	sd	ra,40(sp)
    80003464:	f022                	sd	s0,32(sp)
    80003466:	ec26                	sd	s1,24(sp)
    80003468:	e84a                	sd	s2,16(sp)
    8000346a:	e44e                	sd	s3,8(sp)
    8000346c:	1800                	addi	s0,sp,48
    8000346e:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003470:	47ad                	li	a5,11
    80003472:	02b7e563          	bltu	a5,a1,8000349c <bmap+0x3c>
    if((addr = ip->addrs[bn]) == 0){
    80003476:	02059793          	slli	a5,a1,0x20
    8000347a:	01e7d593          	srli	a1,a5,0x1e
    8000347e:	00b509b3          	add	s3,a0,a1
    80003482:	0509a483          	lw	s1,80(s3)
    80003486:	e8b5                	bnez	s1,800034fa <bmap+0x9a>
      addr = balloc(ip->dev);
    80003488:	4108                	lw	a0,0(a0)
    8000348a:	00000097          	auipc	ra,0x0
    8000348e:	eac080e7          	jalr	-340(ra) # 80003336 <balloc>
    80003492:	84aa                	mv	s1,a0
      if(addr == 0)
    80003494:	c13d                	beqz	a0,800034fa <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003496:	04a9a823          	sw	a0,80(s3)
    8000349a:	a085                	j	800034fa <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000349c:	ff45879b          	addiw	a5,a1,-12
    800034a0:	873e                	mv	a4,a5
    800034a2:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    800034a4:	0ff00793          	li	a5,255
    800034a8:	08e7e163          	bltu	a5,a4,8000352a <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800034ac:	08052483          	lw	s1,128(a0)
    800034b0:	ec81                	bnez	s1,800034c8 <bmap+0x68>
      addr = balloc(ip->dev);
    800034b2:	4108                	lw	a0,0(a0)
    800034b4:	00000097          	auipc	ra,0x0
    800034b8:	e82080e7          	jalr	-382(ra) # 80003336 <balloc>
    800034bc:	84aa                	mv	s1,a0
      if(addr == 0)
    800034be:	cd15                	beqz	a0,800034fa <bmap+0x9a>
    800034c0:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800034c2:	08a92023          	sw	a0,128(s2)
    800034c6:	a011                	j	800034ca <bmap+0x6a>
    800034c8:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800034ca:	85a6                	mv	a1,s1
    800034cc:	00092503          	lw	a0,0(s2)
    800034d0:	00000097          	auipc	ra,0x0
    800034d4:	baa080e7          	jalr	-1110(ra) # 8000307a <bread>
    800034d8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034da:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800034de:	02099713          	slli	a4,s3,0x20
    800034e2:	01e75593          	srli	a1,a4,0x1e
    800034e6:	97ae                	add	a5,a5,a1
    800034e8:	89be                	mv	s3,a5
    800034ea:	4384                	lw	s1,0(a5)
    800034ec:	cc99                	beqz	s1,8000350a <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800034ee:	8552                	mv	a0,s4
    800034f0:	00000097          	auipc	ra,0x0
    800034f4:	cba080e7          	jalr	-838(ra) # 800031aa <brelse>
    return addr;
    800034f8:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800034fa:	8526                	mv	a0,s1
    800034fc:	70a2                	ld	ra,40(sp)
    800034fe:	7402                	ld	s0,32(sp)
    80003500:	64e2                	ld	s1,24(sp)
    80003502:	6942                	ld	s2,16(sp)
    80003504:	69a2                	ld	s3,8(sp)
    80003506:	6145                	addi	sp,sp,48
    80003508:	8082                	ret
      addr = balloc(ip->dev);
    8000350a:	00092503          	lw	a0,0(s2)
    8000350e:	00000097          	auipc	ra,0x0
    80003512:	e28080e7          	jalr	-472(ra) # 80003336 <balloc>
    80003516:	84aa                	mv	s1,a0
      if(addr){
    80003518:	d979                	beqz	a0,800034ee <bmap+0x8e>
        a[bn] = addr;
    8000351a:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    8000351e:	8552                	mv	a0,s4
    80003520:	00001097          	auipc	ra,0x1
    80003524:	f36080e7          	jalr	-202(ra) # 80004456 <log_write>
    80003528:	b7d9                	j	800034ee <bmap+0x8e>
    8000352a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000352c:	00005517          	auipc	a0,0x5
    80003530:	f2450513          	addi	a0,a0,-220 # 80008450 <etext+0x450>
    80003534:	ffffd097          	auipc	ra,0xffffd
    80003538:	02a080e7          	jalr	42(ra) # 8000055e <panic>

000000008000353c <iget>:
{
    8000353c:	7179                	addi	sp,sp,-48
    8000353e:	f406                	sd	ra,40(sp)
    80003540:	f022                	sd	s0,32(sp)
    80003542:	ec26                	sd	s1,24(sp)
    80003544:	e84a                	sd	s2,16(sp)
    80003546:	e44e                	sd	s3,8(sp)
    80003548:	e052                	sd	s4,0(sp)
    8000354a:	1800                	addi	s0,sp,48
    8000354c:	892a                	mv	s2,a0
    8000354e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003550:	0001c517          	auipc	a0,0x1c
    80003554:	f0850513          	addi	a0,a0,-248 # 8001f458 <itable>
    80003558:	ffffd097          	auipc	ra,0xffffd
    8000355c:	704080e7          	jalr	1796(ra) # 80000c5c <acquire>
  empty = 0;
    80003560:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003562:	0001c497          	auipc	s1,0x1c
    80003566:	f0e48493          	addi	s1,s1,-242 # 8001f470 <itable+0x18>
    8000356a:	0001e697          	auipc	a3,0x1e
    8000356e:	99668693          	addi	a3,a3,-1642 # 80020f00 <log>
    80003572:	a809                	j	80003584 <iget+0x48>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003574:	e781                	bnez	a5,8000357c <iget+0x40>
    80003576:	00099363          	bnez	s3,8000357c <iget+0x40>
      empty = ip;
    8000357a:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000357c:	08848493          	addi	s1,s1,136
    80003580:	02d48763          	beq	s1,a3,800035ae <iget+0x72>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003584:	449c                	lw	a5,8(s1)
    80003586:	fef057e3          	blez	a5,80003574 <iget+0x38>
    8000358a:	4098                	lw	a4,0(s1)
    8000358c:	ff2718e3          	bne	a4,s2,8000357c <iget+0x40>
    80003590:	40d8                	lw	a4,4(s1)
    80003592:	ff4715e3          	bne	a4,s4,8000357c <iget+0x40>
      ip->ref++;
    80003596:	2785                	addiw	a5,a5,1
    80003598:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000359a:	0001c517          	auipc	a0,0x1c
    8000359e:	ebe50513          	addi	a0,a0,-322 # 8001f458 <itable>
    800035a2:	ffffd097          	auipc	ra,0xffffd
    800035a6:	76a080e7          	jalr	1898(ra) # 80000d0c <release>
      return ip;
    800035aa:	89a6                	mv	s3,s1
    800035ac:	a025                	j	800035d4 <iget+0x98>
  if(empty == 0)
    800035ae:	02098c63          	beqz	s3,800035e6 <iget+0xaa>
  ip->dev = dev;
    800035b2:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800035b6:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800035ba:	4785                	li	a5,1
    800035bc:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800035c0:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800035c4:	0001c517          	auipc	a0,0x1c
    800035c8:	e9450513          	addi	a0,a0,-364 # 8001f458 <itable>
    800035cc:	ffffd097          	auipc	ra,0xffffd
    800035d0:	740080e7          	jalr	1856(ra) # 80000d0c <release>
}
    800035d4:	854e                	mv	a0,s3
    800035d6:	70a2                	ld	ra,40(sp)
    800035d8:	7402                	ld	s0,32(sp)
    800035da:	64e2                	ld	s1,24(sp)
    800035dc:	6942                	ld	s2,16(sp)
    800035de:	69a2                	ld	s3,8(sp)
    800035e0:	6a02                	ld	s4,0(sp)
    800035e2:	6145                	addi	sp,sp,48
    800035e4:	8082                	ret
    panic("iget: no inodes");
    800035e6:	00005517          	auipc	a0,0x5
    800035ea:	e8250513          	addi	a0,a0,-382 # 80008468 <etext+0x468>
    800035ee:	ffffd097          	auipc	ra,0xffffd
    800035f2:	f70080e7          	jalr	-144(ra) # 8000055e <panic>

00000000800035f6 <fsinit>:
fsinit(int dev) {
    800035f6:	1101                	addi	sp,sp,-32
    800035f8:	ec06                	sd	ra,24(sp)
    800035fa:	e822                	sd	s0,16(sp)
    800035fc:	e426                	sd	s1,8(sp)
    800035fe:	e04a                	sd	s2,0(sp)
    80003600:	1000                	addi	s0,sp,32
    80003602:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003604:	4585                	li	a1,1
    80003606:	00000097          	auipc	ra,0x0
    8000360a:	a74080e7          	jalr	-1420(ra) # 8000307a <bread>
    8000360e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003610:	02000613          	li	a2,32
    80003614:	05850593          	addi	a1,a0,88
    80003618:	0001c517          	auipc	a0,0x1c
    8000361c:	e2050513          	addi	a0,a0,-480 # 8001f438 <sb>
    80003620:	ffffd097          	auipc	ra,0xffffd
    80003624:	794080e7          	jalr	1940(ra) # 80000db4 <memmove>
  brelse(bp);
    80003628:	8526                	mv	a0,s1
    8000362a:	00000097          	auipc	ra,0x0
    8000362e:	b80080e7          	jalr	-1152(ra) # 800031aa <brelse>
  if(sb.magic != FSMAGIC)
    80003632:	0001c717          	auipc	a4,0x1c
    80003636:	e0672703          	lw	a4,-506(a4) # 8001f438 <sb>
    8000363a:	102037b7          	lui	a5,0x10203
    8000363e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003642:	02f71163          	bne	a4,a5,80003664 <fsinit+0x6e>
  initlog(dev, &sb);
    80003646:	0001c597          	auipc	a1,0x1c
    8000364a:	df258593          	addi	a1,a1,-526 # 8001f438 <sb>
    8000364e:	854a                	mv	a0,s2
    80003650:	00001097          	auipc	ra,0x1
    80003654:	b80080e7          	jalr	-1152(ra) # 800041d0 <initlog>
}
    80003658:	60e2                	ld	ra,24(sp)
    8000365a:	6442                	ld	s0,16(sp)
    8000365c:	64a2                	ld	s1,8(sp)
    8000365e:	6902                	ld	s2,0(sp)
    80003660:	6105                	addi	sp,sp,32
    80003662:	8082                	ret
    panic("invalid file system");
    80003664:	00005517          	auipc	a0,0x5
    80003668:	e1450513          	addi	a0,a0,-492 # 80008478 <etext+0x478>
    8000366c:	ffffd097          	auipc	ra,0xffffd
    80003670:	ef2080e7          	jalr	-270(ra) # 8000055e <panic>

0000000080003674 <iinit>:
{
    80003674:	7179                	addi	sp,sp,-48
    80003676:	f406                	sd	ra,40(sp)
    80003678:	f022                	sd	s0,32(sp)
    8000367a:	ec26                	sd	s1,24(sp)
    8000367c:	e84a                	sd	s2,16(sp)
    8000367e:	e44e                	sd	s3,8(sp)
    80003680:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003682:	00005597          	auipc	a1,0x5
    80003686:	e0e58593          	addi	a1,a1,-498 # 80008490 <etext+0x490>
    8000368a:	0001c517          	auipc	a0,0x1c
    8000368e:	dce50513          	addi	a0,a0,-562 # 8001f458 <itable>
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	530080e7          	jalr	1328(ra) # 80000bc2 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000369a:	0001c497          	auipc	s1,0x1c
    8000369e:	de648493          	addi	s1,s1,-538 # 8001f480 <itable+0x28>
    800036a2:	0001e997          	auipc	s3,0x1e
    800036a6:	86e98993          	addi	s3,s3,-1938 # 80020f10 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036aa:	00005917          	auipc	s2,0x5
    800036ae:	dee90913          	addi	s2,s2,-530 # 80008498 <etext+0x498>
    800036b2:	85ca                	mv	a1,s2
    800036b4:	8526                	mv	a0,s1
    800036b6:	00001097          	auipc	ra,0x1
    800036ba:	e86080e7          	jalr	-378(ra) # 8000453c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036be:	08848493          	addi	s1,s1,136
    800036c2:	ff3498e3          	bne	s1,s3,800036b2 <iinit+0x3e>
}
    800036c6:	70a2                	ld	ra,40(sp)
    800036c8:	7402                	ld	s0,32(sp)
    800036ca:	64e2                	ld	s1,24(sp)
    800036cc:	6942                	ld	s2,16(sp)
    800036ce:	69a2                	ld	s3,8(sp)
    800036d0:	6145                	addi	sp,sp,48
    800036d2:	8082                	ret

00000000800036d4 <ialloc>:
{
    800036d4:	7139                	addi	sp,sp,-64
    800036d6:	fc06                	sd	ra,56(sp)
    800036d8:	f822                	sd	s0,48(sp)
    800036da:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800036dc:	0001c717          	auipc	a4,0x1c
    800036e0:	d6872703          	lw	a4,-664(a4) # 8001f444 <sb+0xc>
    800036e4:	4785                	li	a5,1
    800036e6:	06e7f463          	bgeu	a5,a4,8000374e <ialloc+0x7a>
    800036ea:	f426                	sd	s1,40(sp)
    800036ec:	f04a                	sd	s2,32(sp)
    800036ee:	ec4e                	sd	s3,24(sp)
    800036f0:	e852                	sd	s4,16(sp)
    800036f2:	e456                	sd	s5,8(sp)
    800036f4:	e05a                	sd	s6,0(sp)
    800036f6:	8aaa                	mv	s5,a0
    800036f8:	8b2e                	mv	s6,a1
    800036fa:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800036fc:	0001ca17          	auipc	s4,0x1c
    80003700:	d3ca0a13          	addi	s4,s4,-708 # 8001f438 <sb>
    80003704:	00495593          	srli	a1,s2,0x4
    80003708:	018a2783          	lw	a5,24(s4)
    8000370c:	9dbd                	addw	a1,a1,a5
    8000370e:	8556                	mv	a0,s5
    80003710:	00000097          	auipc	ra,0x0
    80003714:	96a080e7          	jalr	-1686(ra) # 8000307a <bread>
    80003718:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000371a:	05850993          	addi	s3,a0,88
    8000371e:	00f97793          	andi	a5,s2,15
    80003722:	079a                	slli	a5,a5,0x6
    80003724:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003726:	00099783          	lh	a5,0(s3)
    8000372a:	cf9d                	beqz	a5,80003768 <ialloc+0x94>
    brelse(bp);
    8000372c:	00000097          	auipc	ra,0x0
    80003730:	a7e080e7          	jalr	-1410(ra) # 800031aa <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003734:	0905                	addi	s2,s2,1
    80003736:	00ca2703          	lw	a4,12(s4)
    8000373a:	0009079b          	sext.w	a5,s2
    8000373e:	fce7e3e3          	bltu	a5,a4,80003704 <ialloc+0x30>
    80003742:	74a2                	ld	s1,40(sp)
    80003744:	7902                	ld	s2,32(sp)
    80003746:	69e2                	ld	s3,24(sp)
    80003748:	6a42                	ld	s4,16(sp)
    8000374a:	6aa2                	ld	s5,8(sp)
    8000374c:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000374e:	00005517          	auipc	a0,0x5
    80003752:	d5250513          	addi	a0,a0,-686 # 800084a0 <etext+0x4a0>
    80003756:	ffffd097          	auipc	ra,0xffffd
    8000375a:	e52080e7          	jalr	-430(ra) # 800005a8 <printf>
  return 0;
    8000375e:	4501                	li	a0,0
}
    80003760:	70e2                	ld	ra,56(sp)
    80003762:	7442                	ld	s0,48(sp)
    80003764:	6121                	addi	sp,sp,64
    80003766:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003768:	04000613          	li	a2,64
    8000376c:	4581                	li	a1,0
    8000376e:	854e                	mv	a0,s3
    80003770:	ffffd097          	auipc	ra,0xffffd
    80003774:	5e4080e7          	jalr	1508(ra) # 80000d54 <memset>
      dip->type = type;
    80003778:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000377c:	8526                	mv	a0,s1
    8000377e:	00001097          	auipc	ra,0x1
    80003782:	cd8080e7          	jalr	-808(ra) # 80004456 <log_write>
      brelse(bp);
    80003786:	8526                	mv	a0,s1
    80003788:	00000097          	auipc	ra,0x0
    8000378c:	a22080e7          	jalr	-1502(ra) # 800031aa <brelse>
      return iget(dev, inum);
    80003790:	0009059b          	sext.w	a1,s2
    80003794:	8556                	mv	a0,s5
    80003796:	00000097          	auipc	ra,0x0
    8000379a:	da6080e7          	jalr	-602(ra) # 8000353c <iget>
    8000379e:	74a2                	ld	s1,40(sp)
    800037a0:	7902                	ld	s2,32(sp)
    800037a2:	69e2                	ld	s3,24(sp)
    800037a4:	6a42                	ld	s4,16(sp)
    800037a6:	6aa2                	ld	s5,8(sp)
    800037a8:	6b02                	ld	s6,0(sp)
    800037aa:	bf5d                	j	80003760 <ialloc+0x8c>

00000000800037ac <iupdate>:
{
    800037ac:	1101                	addi	sp,sp,-32
    800037ae:	ec06                	sd	ra,24(sp)
    800037b0:	e822                	sd	s0,16(sp)
    800037b2:	e426                	sd	s1,8(sp)
    800037b4:	e04a                	sd	s2,0(sp)
    800037b6:	1000                	addi	s0,sp,32
    800037b8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037ba:	415c                	lw	a5,4(a0)
    800037bc:	0047d79b          	srliw	a5,a5,0x4
    800037c0:	0001c597          	auipc	a1,0x1c
    800037c4:	c905a583          	lw	a1,-880(a1) # 8001f450 <sb+0x18>
    800037c8:	9dbd                	addw	a1,a1,a5
    800037ca:	4108                	lw	a0,0(a0)
    800037cc:	00000097          	auipc	ra,0x0
    800037d0:	8ae080e7          	jalr	-1874(ra) # 8000307a <bread>
    800037d4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037d6:	05850793          	addi	a5,a0,88
    800037da:	40d8                	lw	a4,4(s1)
    800037dc:	8b3d                	andi	a4,a4,15
    800037de:	071a                	slli	a4,a4,0x6
    800037e0:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800037e2:	04449703          	lh	a4,68(s1)
    800037e6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800037ea:	04649703          	lh	a4,70(s1)
    800037ee:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800037f2:	04849703          	lh	a4,72(s1)
    800037f6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800037fa:	04a49703          	lh	a4,74(s1)
    800037fe:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003802:	44f8                	lw	a4,76(s1)
    80003804:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003806:	03400613          	li	a2,52
    8000380a:	05048593          	addi	a1,s1,80
    8000380e:	00c78513          	addi	a0,a5,12
    80003812:	ffffd097          	auipc	ra,0xffffd
    80003816:	5a2080e7          	jalr	1442(ra) # 80000db4 <memmove>
  log_write(bp);
    8000381a:	854a                	mv	a0,s2
    8000381c:	00001097          	auipc	ra,0x1
    80003820:	c3a080e7          	jalr	-966(ra) # 80004456 <log_write>
  brelse(bp);
    80003824:	854a                	mv	a0,s2
    80003826:	00000097          	auipc	ra,0x0
    8000382a:	984080e7          	jalr	-1660(ra) # 800031aa <brelse>
}
    8000382e:	60e2                	ld	ra,24(sp)
    80003830:	6442                	ld	s0,16(sp)
    80003832:	64a2                	ld	s1,8(sp)
    80003834:	6902                	ld	s2,0(sp)
    80003836:	6105                	addi	sp,sp,32
    80003838:	8082                	ret

000000008000383a <idup>:
{
    8000383a:	1101                	addi	sp,sp,-32
    8000383c:	ec06                	sd	ra,24(sp)
    8000383e:	e822                	sd	s0,16(sp)
    80003840:	e426                	sd	s1,8(sp)
    80003842:	1000                	addi	s0,sp,32
    80003844:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003846:	0001c517          	auipc	a0,0x1c
    8000384a:	c1250513          	addi	a0,a0,-1006 # 8001f458 <itable>
    8000384e:	ffffd097          	auipc	ra,0xffffd
    80003852:	40e080e7          	jalr	1038(ra) # 80000c5c <acquire>
  ip->ref++;
    80003856:	449c                	lw	a5,8(s1)
    80003858:	2785                	addiw	a5,a5,1
    8000385a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000385c:	0001c517          	auipc	a0,0x1c
    80003860:	bfc50513          	addi	a0,a0,-1028 # 8001f458 <itable>
    80003864:	ffffd097          	auipc	ra,0xffffd
    80003868:	4a8080e7          	jalr	1192(ra) # 80000d0c <release>
}
    8000386c:	8526                	mv	a0,s1
    8000386e:	60e2                	ld	ra,24(sp)
    80003870:	6442                	ld	s0,16(sp)
    80003872:	64a2                	ld	s1,8(sp)
    80003874:	6105                	addi	sp,sp,32
    80003876:	8082                	ret

0000000080003878 <ilock>:
{
    80003878:	1101                	addi	sp,sp,-32
    8000387a:	ec06                	sd	ra,24(sp)
    8000387c:	e822                	sd	s0,16(sp)
    8000387e:	e426                	sd	s1,8(sp)
    80003880:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003882:	c10d                	beqz	a0,800038a4 <ilock+0x2c>
    80003884:	84aa                	mv	s1,a0
    80003886:	451c                	lw	a5,8(a0)
    80003888:	00f05e63          	blez	a5,800038a4 <ilock+0x2c>
  acquiresleep(&ip->lock);
    8000388c:	0541                	addi	a0,a0,16
    8000388e:	00001097          	auipc	ra,0x1
    80003892:	ce8080e7          	jalr	-792(ra) # 80004576 <acquiresleep>
  if(ip->valid == 0){
    80003896:	40bc                	lw	a5,64(s1)
    80003898:	cf99                	beqz	a5,800038b6 <ilock+0x3e>
}
    8000389a:	60e2                	ld	ra,24(sp)
    8000389c:	6442                	ld	s0,16(sp)
    8000389e:	64a2                	ld	s1,8(sp)
    800038a0:	6105                	addi	sp,sp,32
    800038a2:	8082                	ret
    800038a4:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800038a6:	00005517          	auipc	a0,0x5
    800038aa:	c1250513          	addi	a0,a0,-1006 # 800084b8 <etext+0x4b8>
    800038ae:	ffffd097          	auipc	ra,0xffffd
    800038b2:	cb0080e7          	jalr	-848(ra) # 8000055e <panic>
    800038b6:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038b8:	40dc                	lw	a5,4(s1)
    800038ba:	0047d79b          	srliw	a5,a5,0x4
    800038be:	0001c597          	auipc	a1,0x1c
    800038c2:	b925a583          	lw	a1,-1134(a1) # 8001f450 <sb+0x18>
    800038c6:	9dbd                	addw	a1,a1,a5
    800038c8:	4088                	lw	a0,0(s1)
    800038ca:	fffff097          	auipc	ra,0xfffff
    800038ce:	7b0080e7          	jalr	1968(ra) # 8000307a <bread>
    800038d2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038d4:	05850593          	addi	a1,a0,88
    800038d8:	40dc                	lw	a5,4(s1)
    800038da:	8bbd                	andi	a5,a5,15
    800038dc:	079a                	slli	a5,a5,0x6
    800038de:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038e0:	00059783          	lh	a5,0(a1)
    800038e4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038e8:	00259783          	lh	a5,2(a1)
    800038ec:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038f0:	00459783          	lh	a5,4(a1)
    800038f4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038f8:	00659783          	lh	a5,6(a1)
    800038fc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003900:	459c                	lw	a5,8(a1)
    80003902:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003904:	03400613          	li	a2,52
    80003908:	05b1                	addi	a1,a1,12
    8000390a:	05048513          	addi	a0,s1,80
    8000390e:	ffffd097          	auipc	ra,0xffffd
    80003912:	4a6080e7          	jalr	1190(ra) # 80000db4 <memmove>
    brelse(bp);
    80003916:	854a                	mv	a0,s2
    80003918:	00000097          	auipc	ra,0x0
    8000391c:	892080e7          	jalr	-1902(ra) # 800031aa <brelse>
    ip->valid = 1;
    80003920:	4785                	li	a5,1
    80003922:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003924:	04449783          	lh	a5,68(s1)
    80003928:	c399                	beqz	a5,8000392e <ilock+0xb6>
    8000392a:	6902                	ld	s2,0(sp)
    8000392c:	b7bd                	j	8000389a <ilock+0x22>
      panic("ilock: no type");
    8000392e:	00005517          	auipc	a0,0x5
    80003932:	b9250513          	addi	a0,a0,-1134 # 800084c0 <etext+0x4c0>
    80003936:	ffffd097          	auipc	ra,0xffffd
    8000393a:	c28080e7          	jalr	-984(ra) # 8000055e <panic>

000000008000393e <iunlock>:
{
    8000393e:	1101                	addi	sp,sp,-32
    80003940:	ec06                	sd	ra,24(sp)
    80003942:	e822                	sd	s0,16(sp)
    80003944:	e426                	sd	s1,8(sp)
    80003946:	e04a                	sd	s2,0(sp)
    80003948:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000394a:	c905                	beqz	a0,8000397a <iunlock+0x3c>
    8000394c:	84aa                	mv	s1,a0
    8000394e:	01050913          	addi	s2,a0,16
    80003952:	854a                	mv	a0,s2
    80003954:	00001097          	auipc	ra,0x1
    80003958:	cbc080e7          	jalr	-836(ra) # 80004610 <holdingsleep>
    8000395c:	cd19                	beqz	a0,8000397a <iunlock+0x3c>
    8000395e:	449c                	lw	a5,8(s1)
    80003960:	00f05d63          	blez	a5,8000397a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003964:	854a                	mv	a0,s2
    80003966:	00001097          	auipc	ra,0x1
    8000396a:	c66080e7          	jalr	-922(ra) # 800045cc <releasesleep>
}
    8000396e:	60e2                	ld	ra,24(sp)
    80003970:	6442                	ld	s0,16(sp)
    80003972:	64a2                	ld	s1,8(sp)
    80003974:	6902                	ld	s2,0(sp)
    80003976:	6105                	addi	sp,sp,32
    80003978:	8082                	ret
    panic("iunlock");
    8000397a:	00005517          	auipc	a0,0x5
    8000397e:	b5650513          	addi	a0,a0,-1194 # 800084d0 <etext+0x4d0>
    80003982:	ffffd097          	auipc	ra,0xffffd
    80003986:	bdc080e7          	jalr	-1060(ra) # 8000055e <panic>

000000008000398a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000398a:	7179                	addi	sp,sp,-48
    8000398c:	f406                	sd	ra,40(sp)
    8000398e:	f022                	sd	s0,32(sp)
    80003990:	ec26                	sd	s1,24(sp)
    80003992:	e84a                	sd	s2,16(sp)
    80003994:	e44e                	sd	s3,8(sp)
    80003996:	1800                	addi	s0,sp,48
    80003998:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000399a:	05050493          	addi	s1,a0,80
    8000399e:	08050913          	addi	s2,a0,128
    800039a2:	a021                	j	800039aa <itrunc+0x20>
    800039a4:	0491                	addi	s1,s1,4
    800039a6:	01248d63          	beq	s1,s2,800039c0 <itrunc+0x36>
    if(ip->addrs[i]){
    800039aa:	408c                	lw	a1,0(s1)
    800039ac:	dde5                	beqz	a1,800039a4 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800039ae:	0009a503          	lw	a0,0(s3)
    800039b2:	00000097          	auipc	ra,0x0
    800039b6:	908080e7          	jalr	-1784(ra) # 800032ba <bfree>
      ip->addrs[i] = 0;
    800039ba:	0004a023          	sw	zero,0(s1)
    800039be:	b7dd                	j	800039a4 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039c0:	0809a583          	lw	a1,128(s3)
    800039c4:	ed99                	bnez	a1,800039e2 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039c6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039ca:	854e                	mv	a0,s3
    800039cc:	00000097          	auipc	ra,0x0
    800039d0:	de0080e7          	jalr	-544(ra) # 800037ac <iupdate>
}
    800039d4:	70a2                	ld	ra,40(sp)
    800039d6:	7402                	ld	s0,32(sp)
    800039d8:	64e2                	ld	s1,24(sp)
    800039da:	6942                	ld	s2,16(sp)
    800039dc:	69a2                	ld	s3,8(sp)
    800039de:	6145                	addi	sp,sp,48
    800039e0:	8082                	ret
    800039e2:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039e4:	0009a503          	lw	a0,0(s3)
    800039e8:	fffff097          	auipc	ra,0xfffff
    800039ec:	692080e7          	jalr	1682(ra) # 8000307a <bread>
    800039f0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039f2:	05850493          	addi	s1,a0,88
    800039f6:	45850913          	addi	s2,a0,1112
    800039fa:	a021                	j	80003a02 <itrunc+0x78>
    800039fc:	0491                	addi	s1,s1,4
    800039fe:	01248b63          	beq	s1,s2,80003a14 <itrunc+0x8a>
      if(a[j])
    80003a02:	408c                	lw	a1,0(s1)
    80003a04:	dde5                	beqz	a1,800039fc <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003a06:	0009a503          	lw	a0,0(s3)
    80003a0a:	00000097          	auipc	ra,0x0
    80003a0e:	8b0080e7          	jalr	-1872(ra) # 800032ba <bfree>
    80003a12:	b7ed                	j	800039fc <itrunc+0x72>
    brelse(bp);
    80003a14:	8552                	mv	a0,s4
    80003a16:	fffff097          	auipc	ra,0xfffff
    80003a1a:	794080e7          	jalr	1940(ra) # 800031aa <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a1e:	0809a583          	lw	a1,128(s3)
    80003a22:	0009a503          	lw	a0,0(s3)
    80003a26:	00000097          	auipc	ra,0x0
    80003a2a:	894080e7          	jalr	-1900(ra) # 800032ba <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a2e:	0809a023          	sw	zero,128(s3)
    80003a32:	6a02                	ld	s4,0(sp)
    80003a34:	bf49                	j	800039c6 <itrunc+0x3c>

0000000080003a36 <iput>:
{
    80003a36:	1101                	addi	sp,sp,-32
    80003a38:	ec06                	sd	ra,24(sp)
    80003a3a:	e822                	sd	s0,16(sp)
    80003a3c:	e426                	sd	s1,8(sp)
    80003a3e:	1000                	addi	s0,sp,32
    80003a40:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a42:	0001c517          	auipc	a0,0x1c
    80003a46:	a1650513          	addi	a0,a0,-1514 # 8001f458 <itable>
    80003a4a:	ffffd097          	auipc	ra,0xffffd
    80003a4e:	212080e7          	jalr	530(ra) # 80000c5c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a52:	4498                	lw	a4,8(s1)
    80003a54:	4785                	li	a5,1
    80003a56:	02f70263          	beq	a4,a5,80003a7a <iput+0x44>
  ip->ref--;
    80003a5a:	449c                	lw	a5,8(s1)
    80003a5c:	37fd                	addiw	a5,a5,-1
    80003a5e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a60:	0001c517          	auipc	a0,0x1c
    80003a64:	9f850513          	addi	a0,a0,-1544 # 8001f458 <itable>
    80003a68:	ffffd097          	auipc	ra,0xffffd
    80003a6c:	2a4080e7          	jalr	676(ra) # 80000d0c <release>
}
    80003a70:	60e2                	ld	ra,24(sp)
    80003a72:	6442                	ld	s0,16(sp)
    80003a74:	64a2                	ld	s1,8(sp)
    80003a76:	6105                	addi	sp,sp,32
    80003a78:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a7a:	40bc                	lw	a5,64(s1)
    80003a7c:	dff9                	beqz	a5,80003a5a <iput+0x24>
    80003a7e:	04a49783          	lh	a5,74(s1)
    80003a82:	ffe1                	bnez	a5,80003a5a <iput+0x24>
    80003a84:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003a86:	01048793          	addi	a5,s1,16
    80003a8a:	893e                	mv	s2,a5
    80003a8c:	853e                	mv	a0,a5
    80003a8e:	00001097          	auipc	ra,0x1
    80003a92:	ae8080e7          	jalr	-1304(ra) # 80004576 <acquiresleep>
    release(&itable.lock);
    80003a96:	0001c517          	auipc	a0,0x1c
    80003a9a:	9c250513          	addi	a0,a0,-1598 # 8001f458 <itable>
    80003a9e:	ffffd097          	auipc	ra,0xffffd
    80003aa2:	26e080e7          	jalr	622(ra) # 80000d0c <release>
    itrunc(ip);
    80003aa6:	8526                	mv	a0,s1
    80003aa8:	00000097          	auipc	ra,0x0
    80003aac:	ee2080e7          	jalr	-286(ra) # 8000398a <itrunc>
    ip->type = 0;
    80003ab0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ab4:	8526                	mv	a0,s1
    80003ab6:	00000097          	auipc	ra,0x0
    80003aba:	cf6080e7          	jalr	-778(ra) # 800037ac <iupdate>
    ip->valid = 0;
    80003abe:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ac2:	854a                	mv	a0,s2
    80003ac4:	00001097          	auipc	ra,0x1
    80003ac8:	b08080e7          	jalr	-1272(ra) # 800045cc <releasesleep>
    acquire(&itable.lock);
    80003acc:	0001c517          	auipc	a0,0x1c
    80003ad0:	98c50513          	addi	a0,a0,-1652 # 8001f458 <itable>
    80003ad4:	ffffd097          	auipc	ra,0xffffd
    80003ad8:	188080e7          	jalr	392(ra) # 80000c5c <acquire>
    80003adc:	6902                	ld	s2,0(sp)
    80003ade:	bfb5                	j	80003a5a <iput+0x24>

0000000080003ae0 <iunlockput>:
{
    80003ae0:	1101                	addi	sp,sp,-32
    80003ae2:	ec06                	sd	ra,24(sp)
    80003ae4:	e822                	sd	s0,16(sp)
    80003ae6:	e426                	sd	s1,8(sp)
    80003ae8:	1000                	addi	s0,sp,32
    80003aea:	84aa                	mv	s1,a0
  iunlock(ip);
    80003aec:	00000097          	auipc	ra,0x0
    80003af0:	e52080e7          	jalr	-430(ra) # 8000393e <iunlock>
  iput(ip);
    80003af4:	8526                	mv	a0,s1
    80003af6:	00000097          	auipc	ra,0x0
    80003afa:	f40080e7          	jalr	-192(ra) # 80003a36 <iput>
}
    80003afe:	60e2                	ld	ra,24(sp)
    80003b00:	6442                	ld	s0,16(sp)
    80003b02:	64a2                	ld	s1,8(sp)
    80003b04:	6105                	addi	sp,sp,32
    80003b06:	8082                	ret

0000000080003b08 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b08:	1141                	addi	sp,sp,-16
    80003b0a:	e406                	sd	ra,8(sp)
    80003b0c:	e022                	sd	s0,0(sp)
    80003b0e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b10:	411c                	lw	a5,0(a0)
    80003b12:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b14:	415c                	lw	a5,4(a0)
    80003b16:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b18:	04451783          	lh	a5,68(a0)
    80003b1c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b20:	04a51783          	lh	a5,74(a0)
    80003b24:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b28:	04c56783          	lwu	a5,76(a0)
    80003b2c:	e99c                	sd	a5,16(a1)
}
    80003b2e:	60a2                	ld	ra,8(sp)
    80003b30:	6402                	ld	s0,0(sp)
    80003b32:	0141                	addi	sp,sp,16
    80003b34:	8082                	ret

0000000080003b36 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b36:	457c                	lw	a5,76(a0)
    80003b38:	10d7e063          	bltu	a5,a3,80003c38 <readi+0x102>
{
    80003b3c:	7159                	addi	sp,sp,-112
    80003b3e:	f486                	sd	ra,104(sp)
    80003b40:	f0a2                	sd	s0,96(sp)
    80003b42:	eca6                	sd	s1,88(sp)
    80003b44:	e0d2                	sd	s4,64(sp)
    80003b46:	fc56                	sd	s5,56(sp)
    80003b48:	f85a                	sd	s6,48(sp)
    80003b4a:	f45e                	sd	s7,40(sp)
    80003b4c:	1880                	addi	s0,sp,112
    80003b4e:	8b2a                	mv	s6,a0
    80003b50:	8bae                	mv	s7,a1
    80003b52:	8a32                	mv	s4,a2
    80003b54:	84b6                	mv	s1,a3
    80003b56:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003b58:	9f35                	addw	a4,a4,a3
    return 0;
    80003b5a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b5c:	0cd76563          	bltu	a4,a3,80003c26 <readi+0xf0>
    80003b60:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003b62:	00e7f463          	bgeu	a5,a4,80003b6a <readi+0x34>
    n = ip->size - off;
    80003b66:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b6a:	0a0a8563          	beqz	s5,80003c14 <readi+0xde>
    80003b6e:	e8ca                	sd	s2,80(sp)
    80003b70:	f062                	sd	s8,32(sp)
    80003b72:	ec66                	sd	s9,24(sp)
    80003b74:	e86a                	sd	s10,16(sp)
    80003b76:	e46e                	sd	s11,8(sp)
    80003b78:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b7a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b7e:	5c7d                	li	s8,-1
    80003b80:	a82d                	j	80003bba <readi+0x84>
    80003b82:	020d1d93          	slli	s11,s10,0x20
    80003b86:	020ddd93          	srli	s11,s11,0x20
    80003b8a:	05890613          	addi	a2,s2,88
    80003b8e:	86ee                	mv	a3,s11
    80003b90:	963e                	add	a2,a2,a5
    80003b92:	85d2                	mv	a1,s4
    80003b94:	855e                	mv	a0,s7
    80003b96:	fffff097          	auipc	ra,0xfffff
    80003b9a:	ab0080e7          	jalr	-1360(ra) # 80002646 <either_copyout>
    80003b9e:	05850963          	beq	a0,s8,80003bf0 <readi+0xba>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ba2:	854a                	mv	a0,s2
    80003ba4:	fffff097          	auipc	ra,0xfffff
    80003ba8:	606080e7          	jalr	1542(ra) # 800031aa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bac:	013d09bb          	addw	s3,s10,s3
    80003bb0:	009d04bb          	addw	s1,s10,s1
    80003bb4:	9a6e                	add	s4,s4,s11
    80003bb6:	0559f963          	bgeu	s3,s5,80003c08 <readi+0xd2>
    uint addr = bmap(ip, off/BSIZE);
    80003bba:	00a4d59b          	srliw	a1,s1,0xa
    80003bbe:	855a                	mv	a0,s6
    80003bc0:	00000097          	auipc	ra,0x0
    80003bc4:	8a0080e7          	jalr	-1888(ra) # 80003460 <bmap>
    80003bc8:	85aa                	mv	a1,a0
    if(addr == 0)
    80003bca:	c539                	beqz	a0,80003c18 <readi+0xe2>
    bp = bread(ip->dev, addr);
    80003bcc:	000b2503          	lw	a0,0(s6)
    80003bd0:	fffff097          	auipc	ra,0xfffff
    80003bd4:	4aa080e7          	jalr	1194(ra) # 8000307a <bread>
    80003bd8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bda:	3ff4f793          	andi	a5,s1,1023
    80003bde:	40fc873b          	subw	a4,s9,a5
    80003be2:	413a86bb          	subw	a3,s5,s3
    80003be6:	8d3a                	mv	s10,a4
    80003be8:	f8e6fde3          	bgeu	a3,a4,80003b82 <readi+0x4c>
    80003bec:	8d36                	mv	s10,a3
    80003bee:	bf51                	j	80003b82 <readi+0x4c>
      brelse(bp);
    80003bf0:	854a                	mv	a0,s2
    80003bf2:	fffff097          	auipc	ra,0xfffff
    80003bf6:	5b8080e7          	jalr	1464(ra) # 800031aa <brelse>
      tot = -1;
    80003bfa:	59fd                	li	s3,-1
      break;
    80003bfc:	6946                	ld	s2,80(sp)
    80003bfe:	7c02                	ld	s8,32(sp)
    80003c00:	6ce2                	ld	s9,24(sp)
    80003c02:	6d42                	ld	s10,16(sp)
    80003c04:	6da2                	ld	s11,8(sp)
    80003c06:	a831                	j	80003c22 <readi+0xec>
    80003c08:	6946                	ld	s2,80(sp)
    80003c0a:	7c02                	ld	s8,32(sp)
    80003c0c:	6ce2                	ld	s9,24(sp)
    80003c0e:	6d42                	ld	s10,16(sp)
    80003c10:	6da2                	ld	s11,8(sp)
    80003c12:	a801                	j	80003c22 <readi+0xec>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c14:	89d6                	mv	s3,s5
    80003c16:	a031                	j	80003c22 <readi+0xec>
    80003c18:	6946                	ld	s2,80(sp)
    80003c1a:	7c02                	ld	s8,32(sp)
    80003c1c:	6ce2                	ld	s9,24(sp)
    80003c1e:	6d42                	ld	s10,16(sp)
    80003c20:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003c22:	854e                	mv	a0,s3
    80003c24:	69a6                	ld	s3,72(sp)
}
    80003c26:	70a6                	ld	ra,104(sp)
    80003c28:	7406                	ld	s0,96(sp)
    80003c2a:	64e6                	ld	s1,88(sp)
    80003c2c:	6a06                	ld	s4,64(sp)
    80003c2e:	7ae2                	ld	s5,56(sp)
    80003c30:	7b42                	ld	s6,48(sp)
    80003c32:	7ba2                	ld	s7,40(sp)
    80003c34:	6165                	addi	sp,sp,112
    80003c36:	8082                	ret
    return 0;
    80003c38:	4501                	li	a0,0
}
    80003c3a:	8082                	ret

0000000080003c3c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c3c:	457c                	lw	a5,76(a0)
    80003c3e:	10d7e963          	bltu	a5,a3,80003d50 <writei+0x114>
{
    80003c42:	7159                	addi	sp,sp,-112
    80003c44:	f486                	sd	ra,104(sp)
    80003c46:	f0a2                	sd	s0,96(sp)
    80003c48:	e8ca                	sd	s2,80(sp)
    80003c4a:	e0d2                	sd	s4,64(sp)
    80003c4c:	fc56                	sd	s5,56(sp)
    80003c4e:	f85a                	sd	s6,48(sp)
    80003c50:	f45e                	sd	s7,40(sp)
    80003c52:	1880                	addi	s0,sp,112
    80003c54:	8aaa                	mv	s5,a0
    80003c56:	8bae                	mv	s7,a1
    80003c58:	8a32                	mv	s4,a2
    80003c5a:	8936                	mv	s2,a3
    80003c5c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c5e:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c62:	00043737          	lui	a4,0x43
    80003c66:	0ef76763          	bltu	a4,a5,80003d54 <writei+0x118>
    80003c6a:	0ed7e563          	bltu	a5,a3,80003d54 <writei+0x118>
    80003c6e:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c70:	0c0b0863          	beqz	s6,80003d40 <writei+0x104>
    80003c74:	eca6                	sd	s1,88(sp)
    80003c76:	f062                	sd	s8,32(sp)
    80003c78:	ec66                	sd	s9,24(sp)
    80003c7a:	e86a                	sd	s10,16(sp)
    80003c7c:	e46e                	sd	s11,8(sp)
    80003c7e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c80:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c84:	5c7d                	li	s8,-1
    80003c86:	a091                	j	80003cca <writei+0x8e>
    80003c88:	020d1d93          	slli	s11,s10,0x20
    80003c8c:	020ddd93          	srli	s11,s11,0x20
    80003c90:	05848513          	addi	a0,s1,88
    80003c94:	86ee                	mv	a3,s11
    80003c96:	8652                	mv	a2,s4
    80003c98:	85de                	mv	a1,s7
    80003c9a:	953e                	add	a0,a0,a5
    80003c9c:	fffff097          	auipc	ra,0xfffff
    80003ca0:	a00080e7          	jalr	-1536(ra) # 8000269c <either_copyin>
    80003ca4:	05850e63          	beq	a0,s8,80003d00 <writei+0xc4>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ca8:	8526                	mv	a0,s1
    80003caa:	00000097          	auipc	ra,0x0
    80003cae:	7ac080e7          	jalr	1964(ra) # 80004456 <log_write>
    brelse(bp);
    80003cb2:	8526                	mv	a0,s1
    80003cb4:	fffff097          	auipc	ra,0xfffff
    80003cb8:	4f6080e7          	jalr	1270(ra) # 800031aa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cbc:	013d09bb          	addw	s3,s10,s3
    80003cc0:	012d093b          	addw	s2,s10,s2
    80003cc4:	9a6e                	add	s4,s4,s11
    80003cc6:	0569f263          	bgeu	s3,s6,80003d0a <writei+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003cca:	00a9559b          	srliw	a1,s2,0xa
    80003cce:	8556                	mv	a0,s5
    80003cd0:	fffff097          	auipc	ra,0xfffff
    80003cd4:	790080e7          	jalr	1936(ra) # 80003460 <bmap>
    80003cd8:	85aa                	mv	a1,a0
    if(addr == 0)
    80003cda:	c905                	beqz	a0,80003d0a <writei+0xce>
    bp = bread(ip->dev, addr);
    80003cdc:	000aa503          	lw	a0,0(s5)
    80003ce0:	fffff097          	auipc	ra,0xfffff
    80003ce4:	39a080e7          	jalr	922(ra) # 8000307a <bread>
    80003ce8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cea:	3ff97793          	andi	a5,s2,1023
    80003cee:	40fc873b          	subw	a4,s9,a5
    80003cf2:	413b06bb          	subw	a3,s6,s3
    80003cf6:	8d3a                	mv	s10,a4
    80003cf8:	f8e6f8e3          	bgeu	a3,a4,80003c88 <writei+0x4c>
    80003cfc:	8d36                	mv	s10,a3
    80003cfe:	b769                	j	80003c88 <writei+0x4c>
      brelse(bp);
    80003d00:	8526                	mv	a0,s1
    80003d02:	fffff097          	auipc	ra,0xfffff
    80003d06:	4a8080e7          	jalr	1192(ra) # 800031aa <brelse>
  }

  if(off > ip->size)
    80003d0a:	04caa783          	lw	a5,76(s5)
    80003d0e:	0327fb63          	bgeu	a5,s2,80003d44 <writei+0x108>
    ip->size = off;
    80003d12:	052aa623          	sw	s2,76(s5)
    80003d16:	64e6                	ld	s1,88(sp)
    80003d18:	7c02                	ld	s8,32(sp)
    80003d1a:	6ce2                	ld	s9,24(sp)
    80003d1c:	6d42                	ld	s10,16(sp)
    80003d1e:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d20:	8556                	mv	a0,s5
    80003d22:	00000097          	auipc	ra,0x0
    80003d26:	a8a080e7          	jalr	-1398(ra) # 800037ac <iupdate>

  return tot;
    80003d2a:	854e                	mv	a0,s3
    80003d2c:	69a6                	ld	s3,72(sp)
}
    80003d2e:	70a6                	ld	ra,104(sp)
    80003d30:	7406                	ld	s0,96(sp)
    80003d32:	6946                	ld	s2,80(sp)
    80003d34:	6a06                	ld	s4,64(sp)
    80003d36:	7ae2                	ld	s5,56(sp)
    80003d38:	7b42                	ld	s6,48(sp)
    80003d3a:	7ba2                	ld	s7,40(sp)
    80003d3c:	6165                	addi	sp,sp,112
    80003d3e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d40:	89da                	mv	s3,s6
    80003d42:	bff9                	j	80003d20 <writei+0xe4>
    80003d44:	64e6                	ld	s1,88(sp)
    80003d46:	7c02                	ld	s8,32(sp)
    80003d48:	6ce2                	ld	s9,24(sp)
    80003d4a:	6d42                	ld	s10,16(sp)
    80003d4c:	6da2                	ld	s11,8(sp)
    80003d4e:	bfc9                	j	80003d20 <writei+0xe4>
    return -1;
    80003d50:	557d                	li	a0,-1
}
    80003d52:	8082                	ret
    return -1;
    80003d54:	557d                	li	a0,-1
    80003d56:	bfe1                	j	80003d2e <writei+0xf2>

0000000080003d58 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d58:	1141                	addi	sp,sp,-16
    80003d5a:	e406                	sd	ra,8(sp)
    80003d5c:	e022                	sd	s0,0(sp)
    80003d5e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d60:	4639                	li	a2,14
    80003d62:	ffffd097          	auipc	ra,0xffffd
    80003d66:	0ca080e7          	jalr	202(ra) # 80000e2c <strncmp>
}
    80003d6a:	60a2                	ld	ra,8(sp)
    80003d6c:	6402                	ld	s0,0(sp)
    80003d6e:	0141                	addi	sp,sp,16
    80003d70:	8082                	ret

0000000080003d72 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d72:	711d                	addi	sp,sp,-96
    80003d74:	ec86                	sd	ra,88(sp)
    80003d76:	e8a2                	sd	s0,80(sp)
    80003d78:	e4a6                	sd	s1,72(sp)
    80003d7a:	e0ca                	sd	s2,64(sp)
    80003d7c:	fc4e                	sd	s3,56(sp)
    80003d7e:	f852                	sd	s4,48(sp)
    80003d80:	f456                	sd	s5,40(sp)
    80003d82:	f05a                	sd	s6,32(sp)
    80003d84:	ec5e                	sd	s7,24(sp)
    80003d86:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d88:	04451703          	lh	a4,68(a0)
    80003d8c:	4785                	li	a5,1
    80003d8e:	00f71f63          	bne	a4,a5,80003dac <dirlookup+0x3a>
    80003d92:	892a                	mv	s2,a0
    80003d94:	8aae                	mv	s5,a1
    80003d96:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d98:	457c                	lw	a5,76(a0)
    80003d9a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d9c:	fa040a13          	addi	s4,s0,-96
    80003da0:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003da2:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003da6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da8:	e79d                	bnez	a5,80003dd6 <dirlookup+0x64>
    80003daa:	a88d                	j	80003e1c <dirlookup+0xaa>
    panic("dirlookup not DIR");
    80003dac:	00004517          	auipc	a0,0x4
    80003db0:	72c50513          	addi	a0,a0,1836 # 800084d8 <etext+0x4d8>
    80003db4:	ffffc097          	auipc	ra,0xffffc
    80003db8:	7aa080e7          	jalr	1962(ra) # 8000055e <panic>
      panic("dirlookup read");
    80003dbc:	00004517          	auipc	a0,0x4
    80003dc0:	73450513          	addi	a0,a0,1844 # 800084f0 <etext+0x4f0>
    80003dc4:	ffffc097          	auipc	ra,0xffffc
    80003dc8:	79a080e7          	jalr	1946(ra) # 8000055e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dcc:	24c1                	addiw	s1,s1,16
    80003dce:	04c92783          	lw	a5,76(s2)
    80003dd2:	04f4f463          	bgeu	s1,a5,80003e1a <dirlookup+0xa8>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dd6:	874e                	mv	a4,s3
    80003dd8:	86a6                	mv	a3,s1
    80003dda:	8652                	mv	a2,s4
    80003ddc:	4581                	li	a1,0
    80003dde:	854a                	mv	a0,s2
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	d56080e7          	jalr	-682(ra) # 80003b36 <readi>
    80003de8:	fd351ae3          	bne	a0,s3,80003dbc <dirlookup+0x4a>
    if(de.inum == 0)
    80003dec:	fa045783          	lhu	a5,-96(s0)
    80003df0:	dff1                	beqz	a5,80003dcc <dirlookup+0x5a>
    if(namecmp(name, de.name) == 0){
    80003df2:	85da                	mv	a1,s6
    80003df4:	8556                	mv	a0,s5
    80003df6:	00000097          	auipc	ra,0x0
    80003dfa:	f62080e7          	jalr	-158(ra) # 80003d58 <namecmp>
    80003dfe:	f579                	bnez	a0,80003dcc <dirlookup+0x5a>
      if(poff)
    80003e00:	000b8463          	beqz	s7,80003e08 <dirlookup+0x96>
        *poff = off;
    80003e04:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003e08:	fa045583          	lhu	a1,-96(s0)
    80003e0c:	00092503          	lw	a0,0(s2)
    80003e10:	fffff097          	auipc	ra,0xfffff
    80003e14:	72c080e7          	jalr	1836(ra) # 8000353c <iget>
    80003e18:	a011                	j	80003e1c <dirlookup+0xaa>
  return 0;
    80003e1a:	4501                	li	a0,0
}
    80003e1c:	60e6                	ld	ra,88(sp)
    80003e1e:	6446                	ld	s0,80(sp)
    80003e20:	64a6                	ld	s1,72(sp)
    80003e22:	6906                	ld	s2,64(sp)
    80003e24:	79e2                	ld	s3,56(sp)
    80003e26:	7a42                	ld	s4,48(sp)
    80003e28:	7aa2                	ld	s5,40(sp)
    80003e2a:	7b02                	ld	s6,32(sp)
    80003e2c:	6be2                	ld	s7,24(sp)
    80003e2e:	6125                	addi	sp,sp,96
    80003e30:	8082                	ret

0000000080003e32 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e32:	711d                	addi	sp,sp,-96
    80003e34:	ec86                	sd	ra,88(sp)
    80003e36:	e8a2                	sd	s0,80(sp)
    80003e38:	e4a6                	sd	s1,72(sp)
    80003e3a:	e0ca                	sd	s2,64(sp)
    80003e3c:	fc4e                	sd	s3,56(sp)
    80003e3e:	f852                	sd	s4,48(sp)
    80003e40:	f456                	sd	s5,40(sp)
    80003e42:	f05a                	sd	s6,32(sp)
    80003e44:	ec5e                	sd	s7,24(sp)
    80003e46:	e862                	sd	s8,16(sp)
    80003e48:	e466                	sd	s9,8(sp)
    80003e4a:	e06a                	sd	s10,0(sp)
    80003e4c:	1080                	addi	s0,sp,96
    80003e4e:	84aa                	mv	s1,a0
    80003e50:	8b2e                	mv	s6,a1
    80003e52:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e54:	00054703          	lbu	a4,0(a0)
    80003e58:	02f00793          	li	a5,47
    80003e5c:	02f70363          	beq	a4,a5,80003e82 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e60:	ffffe097          	auipc	ra,0xffffe
    80003e64:	caa080e7          	jalr	-854(ra) # 80001b0a <myproc>
    80003e68:	15053503          	ld	a0,336(a0)
    80003e6c:	00000097          	auipc	ra,0x0
    80003e70:	9ce080e7          	jalr	-1586(ra) # 8000383a <idup>
    80003e74:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e76:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003e7a:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003e7c:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e7e:	4b85                	li	s7,1
    80003e80:	a87d                	j	80003f3e <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003e82:	4585                	li	a1,1
    80003e84:	852e                	mv	a0,a1
    80003e86:	fffff097          	auipc	ra,0xfffff
    80003e8a:	6b6080e7          	jalr	1718(ra) # 8000353c <iget>
    80003e8e:	8a2a                	mv	s4,a0
    80003e90:	b7dd                	j	80003e76 <namex+0x44>
      iunlockput(ip);
    80003e92:	8552                	mv	a0,s4
    80003e94:	00000097          	auipc	ra,0x0
    80003e98:	c4c080e7          	jalr	-948(ra) # 80003ae0 <iunlockput>
      return 0;
    80003e9c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e9e:	8552                	mv	a0,s4
    80003ea0:	60e6                	ld	ra,88(sp)
    80003ea2:	6446                	ld	s0,80(sp)
    80003ea4:	64a6                	ld	s1,72(sp)
    80003ea6:	6906                	ld	s2,64(sp)
    80003ea8:	79e2                	ld	s3,56(sp)
    80003eaa:	7a42                	ld	s4,48(sp)
    80003eac:	7aa2                	ld	s5,40(sp)
    80003eae:	7b02                	ld	s6,32(sp)
    80003eb0:	6be2                	ld	s7,24(sp)
    80003eb2:	6c42                	ld	s8,16(sp)
    80003eb4:	6ca2                	ld	s9,8(sp)
    80003eb6:	6d02                	ld	s10,0(sp)
    80003eb8:	6125                	addi	sp,sp,96
    80003eba:	8082                	ret
      iunlock(ip);
    80003ebc:	8552                	mv	a0,s4
    80003ebe:	00000097          	auipc	ra,0x0
    80003ec2:	a80080e7          	jalr	-1408(ra) # 8000393e <iunlock>
      return ip;
    80003ec6:	bfe1                	j	80003e9e <namex+0x6c>
      iunlockput(ip);
    80003ec8:	8552                	mv	a0,s4
    80003eca:	00000097          	auipc	ra,0x0
    80003ece:	c16080e7          	jalr	-1002(ra) # 80003ae0 <iunlockput>
      return 0;
    80003ed2:	8a4a                	mv	s4,s2
    80003ed4:	b7e9                	j	80003e9e <namex+0x6c>
  len = path - s;
    80003ed6:	40990633          	sub	a2,s2,s1
    80003eda:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003ede:	09ac5c63          	bge	s8,s10,80003f76 <namex+0x144>
    memmove(name, s, DIRSIZ);
    80003ee2:	8666                	mv	a2,s9
    80003ee4:	85a6                	mv	a1,s1
    80003ee6:	8556                	mv	a0,s5
    80003ee8:	ffffd097          	auipc	ra,0xffffd
    80003eec:	ecc080e7          	jalr	-308(ra) # 80000db4 <memmove>
    80003ef0:	84ca                	mv	s1,s2
  while(*path == '/')
    80003ef2:	0004c783          	lbu	a5,0(s1)
    80003ef6:	01379763          	bne	a5,s3,80003f04 <namex+0xd2>
    path++;
    80003efa:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003efc:	0004c783          	lbu	a5,0(s1)
    80003f00:	ff378de3          	beq	a5,s3,80003efa <namex+0xc8>
    ilock(ip);
    80003f04:	8552                	mv	a0,s4
    80003f06:	00000097          	auipc	ra,0x0
    80003f0a:	972080e7          	jalr	-1678(ra) # 80003878 <ilock>
    if(ip->type != T_DIR){
    80003f0e:	044a1783          	lh	a5,68(s4)
    80003f12:	f97790e3          	bne	a5,s7,80003e92 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003f16:	000b0563          	beqz	s6,80003f20 <namex+0xee>
    80003f1a:	0004c783          	lbu	a5,0(s1)
    80003f1e:	dfd9                	beqz	a5,80003ebc <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f20:	4601                	li	a2,0
    80003f22:	85d6                	mv	a1,s5
    80003f24:	8552                	mv	a0,s4
    80003f26:	00000097          	auipc	ra,0x0
    80003f2a:	e4c080e7          	jalr	-436(ra) # 80003d72 <dirlookup>
    80003f2e:	892a                	mv	s2,a0
    80003f30:	dd41                	beqz	a0,80003ec8 <namex+0x96>
    iunlockput(ip);
    80003f32:	8552                	mv	a0,s4
    80003f34:	00000097          	auipc	ra,0x0
    80003f38:	bac080e7          	jalr	-1108(ra) # 80003ae0 <iunlockput>
    ip = next;
    80003f3c:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003f3e:	0004c783          	lbu	a5,0(s1)
    80003f42:	01379763          	bne	a5,s3,80003f50 <namex+0x11e>
    path++;
    80003f46:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f48:	0004c783          	lbu	a5,0(s1)
    80003f4c:	ff378de3          	beq	a5,s3,80003f46 <namex+0x114>
  if(*path == 0)
    80003f50:	cf9d                	beqz	a5,80003f8e <namex+0x15c>
  while(*path != '/' && *path != 0)
    80003f52:	0004c783          	lbu	a5,0(s1)
    80003f56:	fd178713          	addi	a4,a5,-47
    80003f5a:	cb19                	beqz	a4,80003f70 <namex+0x13e>
    80003f5c:	cb91                	beqz	a5,80003f70 <namex+0x13e>
    80003f5e:	8926                	mv	s2,s1
    path++;
    80003f60:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003f62:	00094783          	lbu	a5,0(s2)
    80003f66:	fd178713          	addi	a4,a5,-47
    80003f6a:	d735                	beqz	a4,80003ed6 <namex+0xa4>
    80003f6c:	fbf5                	bnez	a5,80003f60 <namex+0x12e>
    80003f6e:	b7a5                	j	80003ed6 <namex+0xa4>
    80003f70:	8926                	mv	s2,s1
  len = path - s;
    80003f72:	4d01                	li	s10,0
    80003f74:	4601                	li	a2,0
    memmove(name, s, len);
    80003f76:	2601                	sext.w	a2,a2
    80003f78:	85a6                	mv	a1,s1
    80003f7a:	8556                	mv	a0,s5
    80003f7c:	ffffd097          	auipc	ra,0xffffd
    80003f80:	e38080e7          	jalr	-456(ra) # 80000db4 <memmove>
    name[len] = 0;
    80003f84:	9d56                	add	s10,s10,s5
    80003f86:	000d0023          	sb	zero,0(s10)
    80003f8a:	84ca                	mv	s1,s2
    80003f8c:	b79d                	j	80003ef2 <namex+0xc0>
  if(nameiparent){
    80003f8e:	f00b08e3          	beqz	s6,80003e9e <namex+0x6c>
    iput(ip);
    80003f92:	8552                	mv	a0,s4
    80003f94:	00000097          	auipc	ra,0x0
    80003f98:	aa2080e7          	jalr	-1374(ra) # 80003a36 <iput>
    return 0;
    80003f9c:	4a01                	li	s4,0
    80003f9e:	b701                	j	80003e9e <namex+0x6c>

0000000080003fa0 <dirlink>:
{
    80003fa0:	715d                	addi	sp,sp,-80
    80003fa2:	e486                	sd	ra,72(sp)
    80003fa4:	e0a2                	sd	s0,64(sp)
    80003fa6:	f84a                	sd	s2,48(sp)
    80003fa8:	ec56                	sd	s5,24(sp)
    80003faa:	e85a                	sd	s6,16(sp)
    80003fac:	0880                	addi	s0,sp,80
    80003fae:	892a                	mv	s2,a0
    80003fb0:	8aae                	mv	s5,a1
    80003fb2:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fb4:	4601                	li	a2,0
    80003fb6:	00000097          	auipc	ra,0x0
    80003fba:	dbc080e7          	jalr	-580(ra) # 80003d72 <dirlookup>
    80003fbe:	e129                	bnez	a0,80004000 <dirlink+0x60>
    80003fc0:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fc2:	04c92483          	lw	s1,76(s2)
    80003fc6:	cca9                	beqz	s1,80004020 <dirlink+0x80>
    80003fc8:	f44e                	sd	s3,40(sp)
    80003fca:	f052                	sd	s4,32(sp)
    80003fcc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fce:	fb040a13          	addi	s4,s0,-80
    80003fd2:	49c1                	li	s3,16
    80003fd4:	874e                	mv	a4,s3
    80003fd6:	86a6                	mv	a3,s1
    80003fd8:	8652                	mv	a2,s4
    80003fda:	4581                	li	a1,0
    80003fdc:	854a                	mv	a0,s2
    80003fde:	00000097          	auipc	ra,0x0
    80003fe2:	b58080e7          	jalr	-1192(ra) # 80003b36 <readi>
    80003fe6:	03351363          	bne	a0,s3,8000400c <dirlink+0x6c>
    if(de.inum == 0)
    80003fea:	fb045783          	lhu	a5,-80(s0)
    80003fee:	c79d                	beqz	a5,8000401c <dirlink+0x7c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ff0:	24c1                	addiw	s1,s1,16
    80003ff2:	04c92783          	lw	a5,76(s2)
    80003ff6:	fcf4efe3          	bltu	s1,a5,80003fd4 <dirlink+0x34>
    80003ffa:	79a2                	ld	s3,40(sp)
    80003ffc:	7a02                	ld	s4,32(sp)
    80003ffe:	a00d                	j	80004020 <dirlink+0x80>
    iput(ip);
    80004000:	00000097          	auipc	ra,0x0
    80004004:	a36080e7          	jalr	-1482(ra) # 80003a36 <iput>
    return -1;
    80004008:	557d                	li	a0,-1
    8000400a:	a0a9                	j	80004054 <dirlink+0xb4>
      panic("dirlink read");
    8000400c:	00004517          	auipc	a0,0x4
    80004010:	4f450513          	addi	a0,a0,1268 # 80008500 <etext+0x500>
    80004014:	ffffc097          	auipc	ra,0xffffc
    80004018:	54a080e7          	jalr	1354(ra) # 8000055e <panic>
    8000401c:	79a2                	ld	s3,40(sp)
    8000401e:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80004020:	4639                	li	a2,14
    80004022:	85d6                	mv	a1,s5
    80004024:	fb240513          	addi	a0,s0,-78
    80004028:	ffffd097          	auipc	ra,0xffffd
    8000402c:	e3e080e7          	jalr	-450(ra) # 80000e66 <strncpy>
  de.inum = inum;
    80004030:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004034:	4741                	li	a4,16
    80004036:	86a6                	mv	a3,s1
    80004038:	fb040613          	addi	a2,s0,-80
    8000403c:	4581                	li	a1,0
    8000403e:	854a                	mv	a0,s2
    80004040:	00000097          	auipc	ra,0x0
    80004044:	bfc080e7          	jalr	-1028(ra) # 80003c3c <writei>
    80004048:	1541                	addi	a0,a0,-16
    8000404a:	00a03533          	snez	a0,a0
    8000404e:	40a0053b          	negw	a0,a0
    80004052:	74e2                	ld	s1,56(sp)
}
    80004054:	60a6                	ld	ra,72(sp)
    80004056:	6406                	ld	s0,64(sp)
    80004058:	7942                	ld	s2,48(sp)
    8000405a:	6ae2                	ld	s5,24(sp)
    8000405c:	6b42                	ld	s6,16(sp)
    8000405e:	6161                	addi	sp,sp,80
    80004060:	8082                	ret

0000000080004062 <namei>:

struct inode*
namei(char *path)
{
    80004062:	1101                	addi	sp,sp,-32
    80004064:	ec06                	sd	ra,24(sp)
    80004066:	e822                	sd	s0,16(sp)
    80004068:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000406a:	fe040613          	addi	a2,s0,-32
    8000406e:	4581                	li	a1,0
    80004070:	00000097          	auipc	ra,0x0
    80004074:	dc2080e7          	jalr	-574(ra) # 80003e32 <namex>
}
    80004078:	60e2                	ld	ra,24(sp)
    8000407a:	6442                	ld	s0,16(sp)
    8000407c:	6105                	addi	sp,sp,32
    8000407e:	8082                	ret

0000000080004080 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004080:	1141                	addi	sp,sp,-16
    80004082:	e406                	sd	ra,8(sp)
    80004084:	e022                	sd	s0,0(sp)
    80004086:	0800                	addi	s0,sp,16
    80004088:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000408a:	4585                	li	a1,1
    8000408c:	00000097          	auipc	ra,0x0
    80004090:	da6080e7          	jalr	-602(ra) # 80003e32 <namex>
}
    80004094:	60a2                	ld	ra,8(sp)
    80004096:	6402                	ld	s0,0(sp)
    80004098:	0141                	addi	sp,sp,16
    8000409a:	8082                	ret

000000008000409c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000409c:	1101                	addi	sp,sp,-32
    8000409e:	ec06                	sd	ra,24(sp)
    800040a0:	e822                	sd	s0,16(sp)
    800040a2:	e426                	sd	s1,8(sp)
    800040a4:	e04a                	sd	s2,0(sp)
    800040a6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040a8:	0001d917          	auipc	s2,0x1d
    800040ac:	e5890913          	addi	s2,s2,-424 # 80020f00 <log>
    800040b0:	01892583          	lw	a1,24(s2)
    800040b4:	02892503          	lw	a0,40(s2)
    800040b8:	fffff097          	auipc	ra,0xfffff
    800040bc:	fc2080e7          	jalr	-62(ra) # 8000307a <bread>
    800040c0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040c2:	02c92603          	lw	a2,44(s2)
    800040c6:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040c8:	00c05f63          	blez	a2,800040e6 <write_head+0x4a>
    800040cc:	0001d717          	auipc	a4,0x1d
    800040d0:	e6470713          	addi	a4,a4,-412 # 80020f30 <log+0x30>
    800040d4:	87aa                	mv	a5,a0
    800040d6:	060a                	slli	a2,a2,0x2
    800040d8:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800040da:	4314                	lw	a3,0(a4)
    800040dc:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800040de:	0711                	addi	a4,a4,4
    800040e0:	0791                	addi	a5,a5,4
    800040e2:	fec79ce3          	bne	a5,a2,800040da <write_head+0x3e>
  }
  bwrite(buf);
    800040e6:	8526                	mv	a0,s1
    800040e8:	fffff097          	auipc	ra,0xfffff
    800040ec:	084080e7          	jalr	132(ra) # 8000316c <bwrite>
  brelse(buf);
    800040f0:	8526                	mv	a0,s1
    800040f2:	fffff097          	auipc	ra,0xfffff
    800040f6:	0b8080e7          	jalr	184(ra) # 800031aa <brelse>
}
    800040fa:	60e2                	ld	ra,24(sp)
    800040fc:	6442                	ld	s0,16(sp)
    800040fe:	64a2                	ld	s1,8(sp)
    80004100:	6902                	ld	s2,0(sp)
    80004102:	6105                	addi	sp,sp,32
    80004104:	8082                	ret

0000000080004106 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004106:	0001d797          	auipc	a5,0x1d
    8000410a:	e267a783          	lw	a5,-474(a5) # 80020f2c <log+0x2c>
    8000410e:	0cf05063          	blez	a5,800041ce <install_trans+0xc8>
{
    80004112:	715d                	addi	sp,sp,-80
    80004114:	e486                	sd	ra,72(sp)
    80004116:	e0a2                	sd	s0,64(sp)
    80004118:	fc26                	sd	s1,56(sp)
    8000411a:	f84a                	sd	s2,48(sp)
    8000411c:	f44e                	sd	s3,40(sp)
    8000411e:	f052                	sd	s4,32(sp)
    80004120:	ec56                	sd	s5,24(sp)
    80004122:	e85a                	sd	s6,16(sp)
    80004124:	e45e                	sd	s7,8(sp)
    80004126:	0880                	addi	s0,sp,80
    80004128:	8b2a                	mv	s6,a0
    8000412a:	0001da97          	auipc	s5,0x1d
    8000412e:	e06a8a93          	addi	s5,s5,-506 # 80020f30 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004132:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004134:	0001d997          	auipc	s3,0x1d
    80004138:	dcc98993          	addi	s3,s3,-564 # 80020f00 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000413c:	40000b93          	li	s7,1024
    80004140:	a00d                	j	80004162 <install_trans+0x5c>
    brelse(lbuf);
    80004142:	854a                	mv	a0,s2
    80004144:	fffff097          	auipc	ra,0xfffff
    80004148:	066080e7          	jalr	102(ra) # 800031aa <brelse>
    brelse(dbuf);
    8000414c:	8526                	mv	a0,s1
    8000414e:	fffff097          	auipc	ra,0xfffff
    80004152:	05c080e7          	jalr	92(ra) # 800031aa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004156:	2a05                	addiw	s4,s4,1
    80004158:	0a91                	addi	s5,s5,4
    8000415a:	02c9a783          	lw	a5,44(s3)
    8000415e:	04fa5d63          	bge	s4,a5,800041b8 <install_trans+0xb2>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004162:	0189a583          	lw	a1,24(s3)
    80004166:	014585bb          	addw	a1,a1,s4
    8000416a:	2585                	addiw	a1,a1,1
    8000416c:	0289a503          	lw	a0,40(s3)
    80004170:	fffff097          	auipc	ra,0xfffff
    80004174:	f0a080e7          	jalr	-246(ra) # 8000307a <bread>
    80004178:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000417a:	000aa583          	lw	a1,0(s5)
    8000417e:	0289a503          	lw	a0,40(s3)
    80004182:	fffff097          	auipc	ra,0xfffff
    80004186:	ef8080e7          	jalr	-264(ra) # 8000307a <bread>
    8000418a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000418c:	865e                	mv	a2,s7
    8000418e:	05890593          	addi	a1,s2,88
    80004192:	05850513          	addi	a0,a0,88
    80004196:	ffffd097          	auipc	ra,0xffffd
    8000419a:	c1e080e7          	jalr	-994(ra) # 80000db4 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000419e:	8526                	mv	a0,s1
    800041a0:	fffff097          	auipc	ra,0xfffff
    800041a4:	fcc080e7          	jalr	-52(ra) # 8000316c <bwrite>
    if(recovering == 0)
    800041a8:	f80b1de3          	bnez	s6,80004142 <install_trans+0x3c>
      bunpin(dbuf);
    800041ac:	8526                	mv	a0,s1
    800041ae:	fffff097          	auipc	ra,0xfffff
    800041b2:	0d0080e7          	jalr	208(ra) # 8000327e <bunpin>
    800041b6:	b771                	j	80004142 <install_trans+0x3c>
}
    800041b8:	60a6                	ld	ra,72(sp)
    800041ba:	6406                	ld	s0,64(sp)
    800041bc:	74e2                	ld	s1,56(sp)
    800041be:	7942                	ld	s2,48(sp)
    800041c0:	79a2                	ld	s3,40(sp)
    800041c2:	7a02                	ld	s4,32(sp)
    800041c4:	6ae2                	ld	s5,24(sp)
    800041c6:	6b42                	ld	s6,16(sp)
    800041c8:	6ba2                	ld	s7,8(sp)
    800041ca:	6161                	addi	sp,sp,80
    800041cc:	8082                	ret
    800041ce:	8082                	ret

00000000800041d0 <initlog>:
{
    800041d0:	7179                	addi	sp,sp,-48
    800041d2:	f406                	sd	ra,40(sp)
    800041d4:	f022                	sd	s0,32(sp)
    800041d6:	ec26                	sd	s1,24(sp)
    800041d8:	e84a                	sd	s2,16(sp)
    800041da:	e44e                	sd	s3,8(sp)
    800041dc:	1800                	addi	s0,sp,48
    800041de:	892a                	mv	s2,a0
    800041e0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041e2:	0001d497          	auipc	s1,0x1d
    800041e6:	d1e48493          	addi	s1,s1,-738 # 80020f00 <log>
    800041ea:	00004597          	auipc	a1,0x4
    800041ee:	32658593          	addi	a1,a1,806 # 80008510 <etext+0x510>
    800041f2:	8526                	mv	a0,s1
    800041f4:	ffffd097          	auipc	ra,0xffffd
    800041f8:	9ce080e7          	jalr	-1586(ra) # 80000bc2 <initlock>
  log.start = sb->logstart;
    800041fc:	0149a583          	lw	a1,20(s3)
    80004200:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004202:	0109a783          	lw	a5,16(s3)
    80004206:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004208:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000420c:	854a                	mv	a0,s2
    8000420e:	fffff097          	auipc	ra,0xfffff
    80004212:	e6c080e7          	jalr	-404(ra) # 8000307a <bread>
  log.lh.n = lh->n;
    80004216:	4d30                	lw	a2,88(a0)
    80004218:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000421a:	00c05f63          	blez	a2,80004238 <initlog+0x68>
    8000421e:	87aa                	mv	a5,a0
    80004220:	0001d717          	auipc	a4,0x1d
    80004224:	d1070713          	addi	a4,a4,-752 # 80020f30 <log+0x30>
    80004228:	060a                	slli	a2,a2,0x2
    8000422a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000422c:	4ff4                	lw	a3,92(a5)
    8000422e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004230:	0791                	addi	a5,a5,4
    80004232:	0711                	addi	a4,a4,4
    80004234:	fec79ce3          	bne	a5,a2,8000422c <initlog+0x5c>
  brelse(buf);
    80004238:	fffff097          	auipc	ra,0xfffff
    8000423c:	f72080e7          	jalr	-142(ra) # 800031aa <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004240:	4505                	li	a0,1
    80004242:	00000097          	auipc	ra,0x0
    80004246:	ec4080e7          	jalr	-316(ra) # 80004106 <install_trans>
  log.lh.n = 0;
    8000424a:	0001d797          	auipc	a5,0x1d
    8000424e:	ce07a123          	sw	zero,-798(a5) # 80020f2c <log+0x2c>
  write_head(); // clear the log
    80004252:	00000097          	auipc	ra,0x0
    80004256:	e4a080e7          	jalr	-438(ra) # 8000409c <write_head>
}
    8000425a:	70a2                	ld	ra,40(sp)
    8000425c:	7402                	ld	s0,32(sp)
    8000425e:	64e2                	ld	s1,24(sp)
    80004260:	6942                	ld	s2,16(sp)
    80004262:	69a2                	ld	s3,8(sp)
    80004264:	6145                	addi	sp,sp,48
    80004266:	8082                	ret

0000000080004268 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004268:	1101                	addi	sp,sp,-32
    8000426a:	ec06                	sd	ra,24(sp)
    8000426c:	e822                	sd	s0,16(sp)
    8000426e:	e426                	sd	s1,8(sp)
    80004270:	e04a                	sd	s2,0(sp)
    80004272:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004274:	0001d517          	auipc	a0,0x1d
    80004278:	c8c50513          	addi	a0,a0,-884 # 80020f00 <log>
    8000427c:	ffffd097          	auipc	ra,0xffffd
    80004280:	9e0080e7          	jalr	-1568(ra) # 80000c5c <acquire>
  while(1){
    if(log.committing){
    80004284:	0001d497          	auipc	s1,0x1d
    80004288:	c7c48493          	addi	s1,s1,-900 # 80020f00 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000428c:	4979                	li	s2,30
    8000428e:	a039                	j	8000429c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004290:	85a6                	mv	a1,s1
    80004292:	8526                	mv	a0,s1
    80004294:	ffffe097          	auipc	ra,0xffffe
    80004298:	f88080e7          	jalr	-120(ra) # 8000221c <sleep>
    if(log.committing){
    8000429c:	50dc                	lw	a5,36(s1)
    8000429e:	fbed                	bnez	a5,80004290 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042a0:	5098                	lw	a4,32(s1)
    800042a2:	2705                	addiw	a4,a4,1
    800042a4:	0027179b          	slliw	a5,a4,0x2
    800042a8:	9fb9                	addw	a5,a5,a4
    800042aa:	0017979b          	slliw	a5,a5,0x1
    800042ae:	54d4                	lw	a3,44(s1)
    800042b0:	9fb5                	addw	a5,a5,a3
    800042b2:	00f95963          	bge	s2,a5,800042c4 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800042b6:	85a6                	mv	a1,s1
    800042b8:	8526                	mv	a0,s1
    800042ba:	ffffe097          	auipc	ra,0xffffe
    800042be:	f62080e7          	jalr	-158(ra) # 8000221c <sleep>
    800042c2:	bfe9                	j	8000429c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800042c4:	0001d797          	auipc	a5,0x1d
    800042c8:	c4e7ae23          	sw	a4,-932(a5) # 80020f20 <log+0x20>
      release(&log.lock);
    800042cc:	0001d517          	auipc	a0,0x1d
    800042d0:	c3450513          	addi	a0,a0,-972 # 80020f00 <log>
    800042d4:	ffffd097          	auipc	ra,0xffffd
    800042d8:	a38080e7          	jalr	-1480(ra) # 80000d0c <release>
      break;
    }
  }
}
    800042dc:	60e2                	ld	ra,24(sp)
    800042de:	6442                	ld	s0,16(sp)
    800042e0:	64a2                	ld	s1,8(sp)
    800042e2:	6902                	ld	s2,0(sp)
    800042e4:	6105                	addi	sp,sp,32
    800042e6:	8082                	ret

00000000800042e8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042e8:	7139                	addi	sp,sp,-64
    800042ea:	fc06                	sd	ra,56(sp)
    800042ec:	f822                	sd	s0,48(sp)
    800042ee:	f426                	sd	s1,40(sp)
    800042f0:	f04a                	sd	s2,32(sp)
    800042f2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042f4:	0001d497          	auipc	s1,0x1d
    800042f8:	c0c48493          	addi	s1,s1,-1012 # 80020f00 <log>
    800042fc:	8526                	mv	a0,s1
    800042fe:	ffffd097          	auipc	ra,0xffffd
    80004302:	95e080e7          	jalr	-1698(ra) # 80000c5c <acquire>
  log.outstanding -= 1;
    80004306:	509c                	lw	a5,32(s1)
    80004308:	37fd                	addiw	a5,a5,-1
    8000430a:	893e                	mv	s2,a5
    8000430c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000430e:	50dc                	lw	a5,36(s1)
    80004310:	efb1                	bnez	a5,8000436c <end_op+0x84>
    panic("log.committing");
  if(log.outstanding == 0){
    80004312:	06091863          	bnez	s2,80004382 <end_op+0x9a>
    do_commit = 1;
    log.committing = 1;
    80004316:	0001d497          	auipc	s1,0x1d
    8000431a:	bea48493          	addi	s1,s1,-1046 # 80020f00 <log>
    8000431e:	4785                	li	a5,1
    80004320:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004322:	8526                	mv	a0,s1
    80004324:	ffffd097          	auipc	ra,0xffffd
    80004328:	9e8080e7          	jalr	-1560(ra) # 80000d0c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000432c:	54dc                	lw	a5,44(s1)
    8000432e:	08f04063          	bgtz	a5,800043ae <end_op+0xc6>
    acquire(&log.lock);
    80004332:	0001d517          	auipc	a0,0x1d
    80004336:	bce50513          	addi	a0,a0,-1074 # 80020f00 <log>
    8000433a:	ffffd097          	auipc	ra,0xffffd
    8000433e:	922080e7          	jalr	-1758(ra) # 80000c5c <acquire>
    log.committing = 0;
    80004342:	0001d797          	auipc	a5,0x1d
    80004346:	be07a123          	sw	zero,-1054(a5) # 80020f24 <log+0x24>
    wakeup(&log);
    8000434a:	0001d517          	auipc	a0,0x1d
    8000434e:	bb650513          	addi	a0,a0,-1098 # 80020f00 <log>
    80004352:	ffffe097          	auipc	ra,0xffffe
    80004356:	f2e080e7          	jalr	-210(ra) # 80002280 <wakeup>
    release(&log.lock);
    8000435a:	0001d517          	auipc	a0,0x1d
    8000435e:	ba650513          	addi	a0,a0,-1114 # 80020f00 <log>
    80004362:	ffffd097          	auipc	ra,0xffffd
    80004366:	9aa080e7          	jalr	-1622(ra) # 80000d0c <release>
}
    8000436a:	a825                	j	800043a2 <end_op+0xba>
    8000436c:	ec4e                	sd	s3,24(sp)
    8000436e:	e852                	sd	s4,16(sp)
    80004370:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004372:	00004517          	auipc	a0,0x4
    80004376:	1a650513          	addi	a0,a0,422 # 80008518 <etext+0x518>
    8000437a:	ffffc097          	auipc	ra,0xffffc
    8000437e:	1e4080e7          	jalr	484(ra) # 8000055e <panic>
    wakeup(&log);
    80004382:	0001d517          	auipc	a0,0x1d
    80004386:	b7e50513          	addi	a0,a0,-1154 # 80020f00 <log>
    8000438a:	ffffe097          	auipc	ra,0xffffe
    8000438e:	ef6080e7          	jalr	-266(ra) # 80002280 <wakeup>
  release(&log.lock);
    80004392:	0001d517          	auipc	a0,0x1d
    80004396:	b6e50513          	addi	a0,a0,-1170 # 80020f00 <log>
    8000439a:	ffffd097          	auipc	ra,0xffffd
    8000439e:	972080e7          	jalr	-1678(ra) # 80000d0c <release>
}
    800043a2:	70e2                	ld	ra,56(sp)
    800043a4:	7442                	ld	s0,48(sp)
    800043a6:	74a2                	ld	s1,40(sp)
    800043a8:	7902                	ld	s2,32(sp)
    800043aa:	6121                	addi	sp,sp,64
    800043ac:	8082                	ret
    800043ae:	ec4e                	sd	s3,24(sp)
    800043b0:	e852                	sd	s4,16(sp)
    800043b2:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800043b4:	0001da97          	auipc	s5,0x1d
    800043b8:	b7ca8a93          	addi	s5,s5,-1156 # 80020f30 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800043bc:	0001da17          	auipc	s4,0x1d
    800043c0:	b44a0a13          	addi	s4,s4,-1212 # 80020f00 <log>
    800043c4:	018a2583          	lw	a1,24(s4)
    800043c8:	012585bb          	addw	a1,a1,s2
    800043cc:	2585                	addiw	a1,a1,1
    800043ce:	028a2503          	lw	a0,40(s4)
    800043d2:	fffff097          	auipc	ra,0xfffff
    800043d6:	ca8080e7          	jalr	-856(ra) # 8000307a <bread>
    800043da:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043dc:	000aa583          	lw	a1,0(s5)
    800043e0:	028a2503          	lw	a0,40(s4)
    800043e4:	fffff097          	auipc	ra,0xfffff
    800043e8:	c96080e7          	jalr	-874(ra) # 8000307a <bread>
    800043ec:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800043ee:	40000613          	li	a2,1024
    800043f2:	05850593          	addi	a1,a0,88
    800043f6:	05848513          	addi	a0,s1,88
    800043fa:	ffffd097          	auipc	ra,0xffffd
    800043fe:	9ba080e7          	jalr	-1606(ra) # 80000db4 <memmove>
    bwrite(to);  // write the log
    80004402:	8526                	mv	a0,s1
    80004404:	fffff097          	auipc	ra,0xfffff
    80004408:	d68080e7          	jalr	-664(ra) # 8000316c <bwrite>
    brelse(from);
    8000440c:	854e                	mv	a0,s3
    8000440e:	fffff097          	auipc	ra,0xfffff
    80004412:	d9c080e7          	jalr	-612(ra) # 800031aa <brelse>
    brelse(to);
    80004416:	8526                	mv	a0,s1
    80004418:	fffff097          	auipc	ra,0xfffff
    8000441c:	d92080e7          	jalr	-622(ra) # 800031aa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004420:	2905                	addiw	s2,s2,1
    80004422:	0a91                	addi	s5,s5,4
    80004424:	02ca2783          	lw	a5,44(s4)
    80004428:	f8f94ee3          	blt	s2,a5,800043c4 <end_op+0xdc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000442c:	00000097          	auipc	ra,0x0
    80004430:	c70080e7          	jalr	-912(ra) # 8000409c <write_head>
    install_trans(0); // Now install writes to home locations
    80004434:	4501                	li	a0,0
    80004436:	00000097          	auipc	ra,0x0
    8000443a:	cd0080e7          	jalr	-816(ra) # 80004106 <install_trans>
    log.lh.n = 0;
    8000443e:	0001d797          	auipc	a5,0x1d
    80004442:	ae07a723          	sw	zero,-1298(a5) # 80020f2c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004446:	00000097          	auipc	ra,0x0
    8000444a:	c56080e7          	jalr	-938(ra) # 8000409c <write_head>
    8000444e:	69e2                	ld	s3,24(sp)
    80004450:	6a42                	ld	s4,16(sp)
    80004452:	6aa2                	ld	s5,8(sp)
    80004454:	bdf9                	j	80004332 <end_op+0x4a>

0000000080004456 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004456:	1101                	addi	sp,sp,-32
    80004458:	ec06                	sd	ra,24(sp)
    8000445a:	e822                	sd	s0,16(sp)
    8000445c:	e426                	sd	s1,8(sp)
    8000445e:	1000                	addi	s0,sp,32
    80004460:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004462:	0001d517          	auipc	a0,0x1d
    80004466:	a9e50513          	addi	a0,a0,-1378 # 80020f00 <log>
    8000446a:	ffffc097          	auipc	ra,0xffffc
    8000446e:	7f2080e7          	jalr	2034(ra) # 80000c5c <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004472:	0001d617          	auipc	a2,0x1d
    80004476:	aba62603          	lw	a2,-1350(a2) # 80020f2c <log+0x2c>
    8000447a:	47f5                	li	a5,29
    8000447c:	06c7c663          	blt	a5,a2,800044e8 <log_write+0x92>
    80004480:	0001d797          	auipc	a5,0x1d
    80004484:	a9c7a783          	lw	a5,-1380(a5) # 80020f1c <log+0x1c>
    80004488:	37fd                	addiw	a5,a5,-1
    8000448a:	04f65f63          	bge	a2,a5,800044e8 <log_write+0x92>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000448e:	0001d797          	auipc	a5,0x1d
    80004492:	a927a783          	lw	a5,-1390(a5) # 80020f20 <log+0x20>
    80004496:	06f05163          	blez	a5,800044f8 <log_write+0xa2>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000449a:	4781                	li	a5,0
    8000449c:	06c05663          	blez	a2,80004508 <log_write+0xb2>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044a0:	44cc                	lw	a1,12(s1)
    800044a2:	0001d717          	auipc	a4,0x1d
    800044a6:	a8e70713          	addi	a4,a4,-1394 # 80020f30 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800044aa:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044ac:	4314                	lw	a3,0(a4)
    800044ae:	04b68d63          	beq	a3,a1,80004508 <log_write+0xb2>
  for (i = 0; i < log.lh.n; i++) {
    800044b2:	2785                	addiw	a5,a5,1
    800044b4:	0711                	addi	a4,a4,4
    800044b6:	fef61be3          	bne	a2,a5,800044ac <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800044ba:	060a                	slli	a2,a2,0x2
    800044bc:	02060613          	addi	a2,a2,32
    800044c0:	0001d797          	auipc	a5,0x1d
    800044c4:	a4078793          	addi	a5,a5,-1472 # 80020f00 <log>
    800044c8:	97b2                	add	a5,a5,a2
    800044ca:	44d8                	lw	a4,12(s1)
    800044cc:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800044ce:	8526                	mv	a0,s1
    800044d0:	fffff097          	auipc	ra,0xfffff
    800044d4:	d72080e7          	jalr	-654(ra) # 80003242 <bpin>
    log.lh.n++;
    800044d8:	0001d717          	auipc	a4,0x1d
    800044dc:	a2870713          	addi	a4,a4,-1496 # 80020f00 <log>
    800044e0:	575c                	lw	a5,44(a4)
    800044e2:	2785                	addiw	a5,a5,1
    800044e4:	d75c                	sw	a5,44(a4)
    800044e6:	a835                	j	80004522 <log_write+0xcc>
    panic("too big a transaction");
    800044e8:	00004517          	auipc	a0,0x4
    800044ec:	04050513          	addi	a0,a0,64 # 80008528 <etext+0x528>
    800044f0:	ffffc097          	auipc	ra,0xffffc
    800044f4:	06e080e7          	jalr	110(ra) # 8000055e <panic>
    panic("log_write outside of trans");
    800044f8:	00004517          	auipc	a0,0x4
    800044fc:	04850513          	addi	a0,a0,72 # 80008540 <etext+0x540>
    80004500:	ffffc097          	auipc	ra,0xffffc
    80004504:	05e080e7          	jalr	94(ra) # 8000055e <panic>
  log.lh.block[i] = b->blockno;
    80004508:	00279693          	slli	a3,a5,0x2
    8000450c:	02068693          	addi	a3,a3,32
    80004510:	0001d717          	auipc	a4,0x1d
    80004514:	9f070713          	addi	a4,a4,-1552 # 80020f00 <log>
    80004518:	9736                	add	a4,a4,a3
    8000451a:	44d4                	lw	a3,12(s1)
    8000451c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000451e:	faf608e3          	beq	a2,a5,800044ce <log_write+0x78>
  }
  release(&log.lock);
    80004522:	0001d517          	auipc	a0,0x1d
    80004526:	9de50513          	addi	a0,a0,-1570 # 80020f00 <log>
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	7e2080e7          	jalr	2018(ra) # 80000d0c <release>
}
    80004532:	60e2                	ld	ra,24(sp)
    80004534:	6442                	ld	s0,16(sp)
    80004536:	64a2                	ld	s1,8(sp)
    80004538:	6105                	addi	sp,sp,32
    8000453a:	8082                	ret

000000008000453c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000453c:	1101                	addi	sp,sp,-32
    8000453e:	ec06                	sd	ra,24(sp)
    80004540:	e822                	sd	s0,16(sp)
    80004542:	e426                	sd	s1,8(sp)
    80004544:	e04a                	sd	s2,0(sp)
    80004546:	1000                	addi	s0,sp,32
    80004548:	84aa                	mv	s1,a0
    8000454a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000454c:	00004597          	auipc	a1,0x4
    80004550:	01458593          	addi	a1,a1,20 # 80008560 <etext+0x560>
    80004554:	0521                	addi	a0,a0,8
    80004556:	ffffc097          	auipc	ra,0xffffc
    8000455a:	66c080e7          	jalr	1644(ra) # 80000bc2 <initlock>
  lk->name = name;
    8000455e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004562:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004566:	0204a423          	sw	zero,40(s1)
}
    8000456a:	60e2                	ld	ra,24(sp)
    8000456c:	6442                	ld	s0,16(sp)
    8000456e:	64a2                	ld	s1,8(sp)
    80004570:	6902                	ld	s2,0(sp)
    80004572:	6105                	addi	sp,sp,32
    80004574:	8082                	ret

0000000080004576 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004576:	1101                	addi	sp,sp,-32
    80004578:	ec06                	sd	ra,24(sp)
    8000457a:	e822                	sd	s0,16(sp)
    8000457c:	e426                	sd	s1,8(sp)
    8000457e:	e04a                	sd	s2,0(sp)
    80004580:	1000                	addi	s0,sp,32
    80004582:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004584:	00850913          	addi	s2,a0,8
    80004588:	854a                	mv	a0,s2
    8000458a:	ffffc097          	auipc	ra,0xffffc
    8000458e:	6d2080e7          	jalr	1746(ra) # 80000c5c <acquire>
  while (lk->locked) {
    80004592:	409c                	lw	a5,0(s1)
    80004594:	cb89                	beqz	a5,800045a6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004596:	85ca                	mv	a1,s2
    80004598:	8526                	mv	a0,s1
    8000459a:	ffffe097          	auipc	ra,0xffffe
    8000459e:	c82080e7          	jalr	-894(ra) # 8000221c <sleep>
  while (lk->locked) {
    800045a2:	409c                	lw	a5,0(s1)
    800045a4:	fbed                	bnez	a5,80004596 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045a6:	4785                	li	a5,1
    800045a8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045aa:	ffffd097          	auipc	ra,0xffffd
    800045ae:	560080e7          	jalr	1376(ra) # 80001b0a <myproc>
    800045b2:	591c                	lw	a5,48(a0)
    800045b4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800045b6:	854a                	mv	a0,s2
    800045b8:	ffffc097          	auipc	ra,0xffffc
    800045bc:	754080e7          	jalr	1876(ra) # 80000d0c <release>
}
    800045c0:	60e2                	ld	ra,24(sp)
    800045c2:	6442                	ld	s0,16(sp)
    800045c4:	64a2                	ld	s1,8(sp)
    800045c6:	6902                	ld	s2,0(sp)
    800045c8:	6105                	addi	sp,sp,32
    800045ca:	8082                	ret

00000000800045cc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045cc:	1101                	addi	sp,sp,-32
    800045ce:	ec06                	sd	ra,24(sp)
    800045d0:	e822                	sd	s0,16(sp)
    800045d2:	e426                	sd	s1,8(sp)
    800045d4:	e04a                	sd	s2,0(sp)
    800045d6:	1000                	addi	s0,sp,32
    800045d8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045da:	00850913          	addi	s2,a0,8
    800045de:	854a                	mv	a0,s2
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	67c080e7          	jalr	1660(ra) # 80000c5c <acquire>
  lk->locked = 0;
    800045e8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045ec:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045f0:	8526                	mv	a0,s1
    800045f2:	ffffe097          	auipc	ra,0xffffe
    800045f6:	c8e080e7          	jalr	-882(ra) # 80002280 <wakeup>
  release(&lk->lk);
    800045fa:	854a                	mv	a0,s2
    800045fc:	ffffc097          	auipc	ra,0xffffc
    80004600:	710080e7          	jalr	1808(ra) # 80000d0c <release>
}
    80004604:	60e2                	ld	ra,24(sp)
    80004606:	6442                	ld	s0,16(sp)
    80004608:	64a2                	ld	s1,8(sp)
    8000460a:	6902                	ld	s2,0(sp)
    8000460c:	6105                	addi	sp,sp,32
    8000460e:	8082                	ret

0000000080004610 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004610:	7179                	addi	sp,sp,-48
    80004612:	f406                	sd	ra,40(sp)
    80004614:	f022                	sd	s0,32(sp)
    80004616:	ec26                	sd	s1,24(sp)
    80004618:	e84a                	sd	s2,16(sp)
    8000461a:	1800                	addi	s0,sp,48
    8000461c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000461e:	00850913          	addi	s2,a0,8
    80004622:	854a                	mv	a0,s2
    80004624:	ffffc097          	auipc	ra,0xffffc
    80004628:	638080e7          	jalr	1592(ra) # 80000c5c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000462c:	409c                	lw	a5,0(s1)
    8000462e:	ef91                	bnez	a5,8000464a <holdingsleep+0x3a>
    80004630:	4481                	li	s1,0
  release(&lk->lk);
    80004632:	854a                	mv	a0,s2
    80004634:	ffffc097          	auipc	ra,0xffffc
    80004638:	6d8080e7          	jalr	1752(ra) # 80000d0c <release>
  return r;
}
    8000463c:	8526                	mv	a0,s1
    8000463e:	70a2                	ld	ra,40(sp)
    80004640:	7402                	ld	s0,32(sp)
    80004642:	64e2                	ld	s1,24(sp)
    80004644:	6942                	ld	s2,16(sp)
    80004646:	6145                	addi	sp,sp,48
    80004648:	8082                	ret
    8000464a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000464c:	0284a983          	lw	s3,40(s1)
    80004650:	ffffd097          	auipc	ra,0xffffd
    80004654:	4ba080e7          	jalr	1210(ra) # 80001b0a <myproc>
    80004658:	5904                	lw	s1,48(a0)
    8000465a:	413484b3          	sub	s1,s1,s3
    8000465e:	0014b493          	seqz	s1,s1
    80004662:	69a2                	ld	s3,8(sp)
    80004664:	b7f9                	j	80004632 <holdingsleep+0x22>

0000000080004666 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004666:	1141                	addi	sp,sp,-16
    80004668:	e406                	sd	ra,8(sp)
    8000466a:	e022                	sd	s0,0(sp)
    8000466c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000466e:	00004597          	auipc	a1,0x4
    80004672:	f0258593          	addi	a1,a1,-254 # 80008570 <etext+0x570>
    80004676:	0001d517          	auipc	a0,0x1d
    8000467a:	9d250513          	addi	a0,a0,-1582 # 80021048 <ftable>
    8000467e:	ffffc097          	auipc	ra,0xffffc
    80004682:	544080e7          	jalr	1348(ra) # 80000bc2 <initlock>
}
    80004686:	60a2                	ld	ra,8(sp)
    80004688:	6402                	ld	s0,0(sp)
    8000468a:	0141                	addi	sp,sp,16
    8000468c:	8082                	ret

000000008000468e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000468e:	1101                	addi	sp,sp,-32
    80004690:	ec06                	sd	ra,24(sp)
    80004692:	e822                	sd	s0,16(sp)
    80004694:	e426                	sd	s1,8(sp)
    80004696:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004698:	0001d517          	auipc	a0,0x1d
    8000469c:	9b050513          	addi	a0,a0,-1616 # 80021048 <ftable>
    800046a0:	ffffc097          	auipc	ra,0xffffc
    800046a4:	5bc080e7          	jalr	1468(ra) # 80000c5c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046a8:	0001d497          	auipc	s1,0x1d
    800046ac:	9b848493          	addi	s1,s1,-1608 # 80021060 <ftable+0x18>
    800046b0:	0001e717          	auipc	a4,0x1e
    800046b4:	95070713          	addi	a4,a4,-1712 # 80022000 <disk>
    if(f->ref == 0){
    800046b8:	40dc                	lw	a5,4(s1)
    800046ba:	cf99                	beqz	a5,800046d8 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046bc:	02848493          	addi	s1,s1,40
    800046c0:	fee49ce3          	bne	s1,a4,800046b8 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046c4:	0001d517          	auipc	a0,0x1d
    800046c8:	98450513          	addi	a0,a0,-1660 # 80021048 <ftable>
    800046cc:	ffffc097          	auipc	ra,0xffffc
    800046d0:	640080e7          	jalr	1600(ra) # 80000d0c <release>
  return 0;
    800046d4:	4481                	li	s1,0
    800046d6:	a819                	j	800046ec <filealloc+0x5e>
      f->ref = 1;
    800046d8:	4785                	li	a5,1
    800046da:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046dc:	0001d517          	auipc	a0,0x1d
    800046e0:	96c50513          	addi	a0,a0,-1684 # 80021048 <ftable>
    800046e4:	ffffc097          	auipc	ra,0xffffc
    800046e8:	628080e7          	jalr	1576(ra) # 80000d0c <release>
}
    800046ec:	8526                	mv	a0,s1
    800046ee:	60e2                	ld	ra,24(sp)
    800046f0:	6442                	ld	s0,16(sp)
    800046f2:	64a2                	ld	s1,8(sp)
    800046f4:	6105                	addi	sp,sp,32
    800046f6:	8082                	ret

00000000800046f8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046f8:	1101                	addi	sp,sp,-32
    800046fa:	ec06                	sd	ra,24(sp)
    800046fc:	e822                	sd	s0,16(sp)
    800046fe:	e426                	sd	s1,8(sp)
    80004700:	1000                	addi	s0,sp,32
    80004702:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004704:	0001d517          	auipc	a0,0x1d
    80004708:	94450513          	addi	a0,a0,-1724 # 80021048 <ftable>
    8000470c:	ffffc097          	auipc	ra,0xffffc
    80004710:	550080e7          	jalr	1360(ra) # 80000c5c <acquire>
  if(f->ref < 1)
    80004714:	40dc                	lw	a5,4(s1)
    80004716:	02f05263          	blez	a5,8000473a <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000471a:	2785                	addiw	a5,a5,1
    8000471c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000471e:	0001d517          	auipc	a0,0x1d
    80004722:	92a50513          	addi	a0,a0,-1750 # 80021048 <ftable>
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	5e6080e7          	jalr	1510(ra) # 80000d0c <release>
  return f;
}
    8000472e:	8526                	mv	a0,s1
    80004730:	60e2                	ld	ra,24(sp)
    80004732:	6442                	ld	s0,16(sp)
    80004734:	64a2                	ld	s1,8(sp)
    80004736:	6105                	addi	sp,sp,32
    80004738:	8082                	ret
    panic("filedup");
    8000473a:	00004517          	auipc	a0,0x4
    8000473e:	e3e50513          	addi	a0,a0,-450 # 80008578 <etext+0x578>
    80004742:	ffffc097          	auipc	ra,0xffffc
    80004746:	e1c080e7          	jalr	-484(ra) # 8000055e <panic>

000000008000474a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000474a:	7139                	addi	sp,sp,-64
    8000474c:	fc06                	sd	ra,56(sp)
    8000474e:	f822                	sd	s0,48(sp)
    80004750:	f426                	sd	s1,40(sp)
    80004752:	0080                	addi	s0,sp,64
    80004754:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004756:	0001d517          	auipc	a0,0x1d
    8000475a:	8f250513          	addi	a0,a0,-1806 # 80021048 <ftable>
    8000475e:	ffffc097          	auipc	ra,0xffffc
    80004762:	4fe080e7          	jalr	1278(ra) # 80000c5c <acquire>
  if(f->ref < 1)
    80004766:	40dc                	lw	a5,4(s1)
    80004768:	04f05c63          	blez	a5,800047c0 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    8000476c:	37fd                	addiw	a5,a5,-1
    8000476e:	c0dc                	sw	a5,4(s1)
    80004770:	06f04463          	bgtz	a5,800047d8 <fileclose+0x8e>
    80004774:	f04a                	sd	s2,32(sp)
    80004776:	ec4e                	sd	s3,24(sp)
    80004778:	e852                	sd	s4,16(sp)
    8000477a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000477c:	0004a903          	lw	s2,0(s1)
    80004780:	0094c783          	lbu	a5,9(s1)
    80004784:	89be                	mv	s3,a5
    80004786:	689c                	ld	a5,16(s1)
    80004788:	8a3e                	mv	s4,a5
    8000478a:	6c9c                	ld	a5,24(s1)
    8000478c:	8abe                	mv	s5,a5
  f->ref = 0;
    8000478e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004792:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004796:	0001d517          	auipc	a0,0x1d
    8000479a:	8b250513          	addi	a0,a0,-1870 # 80021048 <ftable>
    8000479e:	ffffc097          	auipc	ra,0xffffc
    800047a2:	56e080e7          	jalr	1390(ra) # 80000d0c <release>

  if(ff.type == FD_PIPE){
    800047a6:	4785                	li	a5,1
    800047a8:	04f90563          	beq	s2,a5,800047f2 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047ac:	ffe9079b          	addiw	a5,s2,-2
    800047b0:	4705                	li	a4,1
    800047b2:	04f77b63          	bgeu	a4,a5,80004808 <fileclose+0xbe>
    800047b6:	7902                	ld	s2,32(sp)
    800047b8:	69e2                	ld	s3,24(sp)
    800047ba:	6a42                	ld	s4,16(sp)
    800047bc:	6aa2                	ld	s5,8(sp)
    800047be:	a02d                	j	800047e8 <fileclose+0x9e>
    800047c0:	f04a                	sd	s2,32(sp)
    800047c2:	ec4e                	sd	s3,24(sp)
    800047c4:	e852                	sd	s4,16(sp)
    800047c6:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800047c8:	00004517          	auipc	a0,0x4
    800047cc:	db850513          	addi	a0,a0,-584 # 80008580 <etext+0x580>
    800047d0:	ffffc097          	auipc	ra,0xffffc
    800047d4:	d8e080e7          	jalr	-626(ra) # 8000055e <panic>
    release(&ftable.lock);
    800047d8:	0001d517          	auipc	a0,0x1d
    800047dc:	87050513          	addi	a0,a0,-1936 # 80021048 <ftable>
    800047e0:	ffffc097          	auipc	ra,0xffffc
    800047e4:	52c080e7          	jalr	1324(ra) # 80000d0c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800047e8:	70e2                	ld	ra,56(sp)
    800047ea:	7442                	ld	s0,48(sp)
    800047ec:	74a2                	ld	s1,40(sp)
    800047ee:	6121                	addi	sp,sp,64
    800047f0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047f2:	85ce                	mv	a1,s3
    800047f4:	8552                	mv	a0,s4
    800047f6:	00000097          	auipc	ra,0x0
    800047fa:	3b4080e7          	jalr	948(ra) # 80004baa <pipeclose>
    800047fe:	7902                	ld	s2,32(sp)
    80004800:	69e2                	ld	s3,24(sp)
    80004802:	6a42                	ld	s4,16(sp)
    80004804:	6aa2                	ld	s5,8(sp)
    80004806:	b7cd                	j	800047e8 <fileclose+0x9e>
    begin_op();
    80004808:	00000097          	auipc	ra,0x0
    8000480c:	a60080e7          	jalr	-1440(ra) # 80004268 <begin_op>
    iput(ff.ip);
    80004810:	8556                	mv	a0,s5
    80004812:	fffff097          	auipc	ra,0xfffff
    80004816:	224080e7          	jalr	548(ra) # 80003a36 <iput>
    end_op();
    8000481a:	00000097          	auipc	ra,0x0
    8000481e:	ace080e7          	jalr	-1330(ra) # 800042e8 <end_op>
    80004822:	7902                	ld	s2,32(sp)
    80004824:	69e2                	ld	s3,24(sp)
    80004826:	6a42                	ld	s4,16(sp)
    80004828:	6aa2                	ld	s5,8(sp)
    8000482a:	bf7d                	j	800047e8 <fileclose+0x9e>

000000008000482c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000482c:	715d                	addi	sp,sp,-80
    8000482e:	e486                	sd	ra,72(sp)
    80004830:	e0a2                	sd	s0,64(sp)
    80004832:	fc26                	sd	s1,56(sp)
    80004834:	f052                	sd	s4,32(sp)
    80004836:	0880                	addi	s0,sp,80
    80004838:	84aa                	mv	s1,a0
    8000483a:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000483c:	ffffd097          	auipc	ra,0xffffd
    80004840:	2ce080e7          	jalr	718(ra) # 80001b0a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004844:	409c                	lw	a5,0(s1)
    80004846:	37f9                	addiw	a5,a5,-2
    80004848:	4705                	li	a4,1
    8000484a:	04f76a63          	bltu	a4,a5,8000489e <filestat+0x72>
    8000484e:	f84a                	sd	s2,48(sp)
    80004850:	f44e                	sd	s3,40(sp)
    80004852:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004854:	6c88                	ld	a0,24(s1)
    80004856:	fffff097          	auipc	ra,0xfffff
    8000485a:	022080e7          	jalr	34(ra) # 80003878 <ilock>
    stati(f->ip, &st);
    8000485e:	fb840913          	addi	s2,s0,-72
    80004862:	85ca                	mv	a1,s2
    80004864:	6c88                	ld	a0,24(s1)
    80004866:	fffff097          	auipc	ra,0xfffff
    8000486a:	2a2080e7          	jalr	674(ra) # 80003b08 <stati>
    iunlock(f->ip);
    8000486e:	6c88                	ld	a0,24(s1)
    80004870:	fffff097          	auipc	ra,0xfffff
    80004874:	0ce080e7          	jalr	206(ra) # 8000393e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004878:	46e1                	li	a3,24
    8000487a:	864a                	mv	a2,s2
    8000487c:	85d2                	mv	a1,s4
    8000487e:	0509b503          	ld	a0,80(s3)
    80004882:	ffffd097          	auipc	ra,0xffffd
    80004886:	e96080e7          	jalr	-362(ra) # 80001718 <copyout>
    8000488a:	41f5551b          	sraiw	a0,a0,0x1f
    8000488e:	7942                	ld	s2,48(sp)
    80004890:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004892:	60a6                	ld	ra,72(sp)
    80004894:	6406                	ld	s0,64(sp)
    80004896:	74e2                	ld	s1,56(sp)
    80004898:	7a02                	ld	s4,32(sp)
    8000489a:	6161                	addi	sp,sp,80
    8000489c:	8082                	ret
  return -1;
    8000489e:	557d                	li	a0,-1
    800048a0:	bfcd                	j	80004892 <filestat+0x66>

00000000800048a2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048a2:	7179                	addi	sp,sp,-48
    800048a4:	f406                	sd	ra,40(sp)
    800048a6:	f022                	sd	s0,32(sp)
    800048a8:	e84a                	sd	s2,16(sp)
    800048aa:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048ac:	00854783          	lbu	a5,8(a0)
    800048b0:	cbc5                	beqz	a5,80004960 <fileread+0xbe>
    800048b2:	ec26                	sd	s1,24(sp)
    800048b4:	e44e                	sd	s3,8(sp)
    800048b6:	84aa                	mv	s1,a0
    800048b8:	892e                	mv	s2,a1
    800048ba:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    800048bc:	411c                	lw	a5,0(a0)
    800048be:	4705                	li	a4,1
    800048c0:	04e78963          	beq	a5,a4,80004912 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048c4:	470d                	li	a4,3
    800048c6:	04e78f63          	beq	a5,a4,80004924 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048ca:	4709                	li	a4,2
    800048cc:	08e79263          	bne	a5,a4,80004950 <fileread+0xae>
    ilock(f->ip);
    800048d0:	6d08                	ld	a0,24(a0)
    800048d2:	fffff097          	auipc	ra,0xfffff
    800048d6:	fa6080e7          	jalr	-90(ra) # 80003878 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048da:	874e                	mv	a4,s3
    800048dc:	5094                	lw	a3,32(s1)
    800048de:	864a                	mv	a2,s2
    800048e0:	4585                	li	a1,1
    800048e2:	6c88                	ld	a0,24(s1)
    800048e4:	fffff097          	auipc	ra,0xfffff
    800048e8:	252080e7          	jalr	594(ra) # 80003b36 <readi>
    800048ec:	892a                	mv	s2,a0
    800048ee:	00a05563          	blez	a0,800048f8 <fileread+0x56>
      f->off += r;
    800048f2:	509c                	lw	a5,32(s1)
    800048f4:	9fa9                	addw	a5,a5,a0
    800048f6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048f8:	6c88                	ld	a0,24(s1)
    800048fa:	fffff097          	auipc	ra,0xfffff
    800048fe:	044080e7          	jalr	68(ra) # 8000393e <iunlock>
    80004902:	64e2                	ld	s1,24(sp)
    80004904:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004906:	854a                	mv	a0,s2
    80004908:	70a2                	ld	ra,40(sp)
    8000490a:	7402                	ld	s0,32(sp)
    8000490c:	6942                	ld	s2,16(sp)
    8000490e:	6145                	addi	sp,sp,48
    80004910:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004912:	6908                	ld	a0,16(a0)
    80004914:	00000097          	auipc	ra,0x0
    80004918:	428080e7          	jalr	1064(ra) # 80004d3c <piperead>
    8000491c:	892a                	mv	s2,a0
    8000491e:	64e2                	ld	s1,24(sp)
    80004920:	69a2                	ld	s3,8(sp)
    80004922:	b7d5                	j	80004906 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004924:	02451783          	lh	a5,36(a0)
    80004928:	03079693          	slli	a3,a5,0x30
    8000492c:	92c1                	srli	a3,a3,0x30
    8000492e:	4725                	li	a4,9
    80004930:	02d76b63          	bltu	a4,a3,80004966 <fileread+0xc4>
    80004934:	0792                	slli	a5,a5,0x4
    80004936:	0001c717          	auipc	a4,0x1c
    8000493a:	67270713          	addi	a4,a4,1650 # 80020fa8 <devsw>
    8000493e:	97ba                	add	a5,a5,a4
    80004940:	639c                	ld	a5,0(a5)
    80004942:	c79d                	beqz	a5,80004970 <fileread+0xce>
    r = devsw[f->major].read(1, addr, n);
    80004944:	4505                	li	a0,1
    80004946:	9782                	jalr	a5
    80004948:	892a                	mv	s2,a0
    8000494a:	64e2                	ld	s1,24(sp)
    8000494c:	69a2                	ld	s3,8(sp)
    8000494e:	bf65                	j	80004906 <fileread+0x64>
    panic("fileread");
    80004950:	00004517          	auipc	a0,0x4
    80004954:	c4050513          	addi	a0,a0,-960 # 80008590 <etext+0x590>
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	c06080e7          	jalr	-1018(ra) # 8000055e <panic>
    return -1;
    80004960:	57fd                	li	a5,-1
    80004962:	893e                	mv	s2,a5
    80004964:	b74d                	j	80004906 <fileread+0x64>
      return -1;
    80004966:	57fd                	li	a5,-1
    80004968:	893e                	mv	s2,a5
    8000496a:	64e2                	ld	s1,24(sp)
    8000496c:	69a2                	ld	s3,8(sp)
    8000496e:	bf61                	j	80004906 <fileread+0x64>
    80004970:	57fd                	li	a5,-1
    80004972:	893e                	mv	s2,a5
    80004974:	64e2                	ld	s1,24(sp)
    80004976:	69a2                	ld	s3,8(sp)
    80004978:	b779                	j	80004906 <fileread+0x64>

000000008000497a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000497a:	00954783          	lbu	a5,9(a0)
    8000497e:	12078d63          	beqz	a5,80004ab8 <filewrite+0x13e>
{
    80004982:	711d                	addi	sp,sp,-96
    80004984:	ec86                	sd	ra,88(sp)
    80004986:	e8a2                	sd	s0,80(sp)
    80004988:	e0ca                	sd	s2,64(sp)
    8000498a:	f456                	sd	s5,40(sp)
    8000498c:	f05a                	sd	s6,32(sp)
    8000498e:	1080                	addi	s0,sp,96
    80004990:	892a                	mv	s2,a0
    80004992:	8b2e                	mv	s6,a1
    80004994:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004996:	411c                	lw	a5,0(a0)
    80004998:	4705                	li	a4,1
    8000499a:	02e78a63          	beq	a5,a4,800049ce <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000499e:	470d                	li	a4,3
    800049a0:	02e78d63          	beq	a5,a4,800049da <filewrite+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049a4:	4709                	li	a4,2
    800049a6:	0ee79b63          	bne	a5,a4,80004a9c <filewrite+0x122>
    800049aa:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049ac:	0cc05663          	blez	a2,80004a78 <filewrite+0xfe>
    800049b0:	e4a6                	sd	s1,72(sp)
    800049b2:	fc4e                	sd	s3,56(sp)
    800049b4:	ec5e                	sd	s7,24(sp)
    800049b6:	e862                	sd	s8,16(sp)
    800049b8:	e466                	sd	s9,8(sp)
    int i = 0;
    800049ba:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800049bc:	6b85                	lui	s7,0x1
    800049be:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800049c2:	6785                	lui	a5,0x1
    800049c4:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800049c8:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049ca:	4c05                	li	s8,1
    800049cc:	a849                	j	80004a5e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800049ce:	6908                	ld	a0,16(a0)
    800049d0:	00000097          	auipc	ra,0x0
    800049d4:	250080e7          	jalr	592(ra) # 80004c20 <pipewrite>
    800049d8:	a85d                	j	80004a8e <filewrite+0x114>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049da:	02451783          	lh	a5,36(a0)
    800049de:	03079693          	slli	a3,a5,0x30
    800049e2:	92c1                	srli	a3,a3,0x30
    800049e4:	4725                	li	a4,9
    800049e6:	0cd76b63          	bltu	a4,a3,80004abc <filewrite+0x142>
    800049ea:	0792                	slli	a5,a5,0x4
    800049ec:	0001c717          	auipc	a4,0x1c
    800049f0:	5bc70713          	addi	a4,a4,1468 # 80020fa8 <devsw>
    800049f4:	97ba                	add	a5,a5,a4
    800049f6:	679c                	ld	a5,8(a5)
    800049f8:	c7e1                	beqz	a5,80004ac0 <filewrite+0x146>
    ret = devsw[f->major].write(1, addr, n);
    800049fa:	4505                	li	a0,1
    800049fc:	9782                	jalr	a5
    800049fe:	a841                	j	80004a8e <filewrite+0x114>
      if(n1 > max)
    80004a00:	2981                	sext.w	s3,s3
      begin_op();
    80004a02:	00000097          	auipc	ra,0x0
    80004a06:	866080e7          	jalr	-1946(ra) # 80004268 <begin_op>
      ilock(f->ip);
    80004a0a:	01893503          	ld	a0,24(s2)
    80004a0e:	fffff097          	auipc	ra,0xfffff
    80004a12:	e6a080e7          	jalr	-406(ra) # 80003878 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a16:	874e                	mv	a4,s3
    80004a18:	02092683          	lw	a3,32(s2)
    80004a1c:	016a0633          	add	a2,s4,s6
    80004a20:	85e2                	mv	a1,s8
    80004a22:	01893503          	ld	a0,24(s2)
    80004a26:	fffff097          	auipc	ra,0xfffff
    80004a2a:	216080e7          	jalr	534(ra) # 80003c3c <writei>
    80004a2e:	84aa                	mv	s1,a0
    80004a30:	00a05763          	blez	a0,80004a3e <filewrite+0xc4>
        f->off += r;
    80004a34:	02092783          	lw	a5,32(s2)
    80004a38:	9fa9                	addw	a5,a5,a0
    80004a3a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a3e:	01893503          	ld	a0,24(s2)
    80004a42:	fffff097          	auipc	ra,0xfffff
    80004a46:	efc080e7          	jalr	-260(ra) # 8000393e <iunlock>
      end_op();
    80004a4a:	00000097          	auipc	ra,0x0
    80004a4e:	89e080e7          	jalr	-1890(ra) # 800042e8 <end_op>

      if(r != n1){
    80004a52:	02999563          	bne	s3,s1,80004a7c <filewrite+0x102>
        // error from writei
        break;
      }
      i += r;
    80004a56:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004a5a:	015a5963          	bge	s4,s5,80004a6c <filewrite+0xf2>
      int n1 = n - i;
    80004a5e:	414a87bb          	subw	a5,s5,s4
    80004a62:	89be                	mv	s3,a5
      if(n1 > max)
    80004a64:	f8fbdee3          	bge	s7,a5,80004a00 <filewrite+0x86>
    80004a68:	89e6                	mv	s3,s9
    80004a6a:	bf59                	j	80004a00 <filewrite+0x86>
    80004a6c:	64a6                	ld	s1,72(sp)
    80004a6e:	79e2                	ld	s3,56(sp)
    80004a70:	6be2                	ld	s7,24(sp)
    80004a72:	6c42                	ld	s8,16(sp)
    80004a74:	6ca2                	ld	s9,8(sp)
    80004a76:	a801                	j	80004a86 <filewrite+0x10c>
    int i = 0;
    80004a78:	4a01                	li	s4,0
    80004a7a:	a031                	j	80004a86 <filewrite+0x10c>
    80004a7c:	64a6                	ld	s1,72(sp)
    80004a7e:	79e2                	ld	s3,56(sp)
    80004a80:	6be2                	ld	s7,24(sp)
    80004a82:	6c42                	ld	s8,16(sp)
    80004a84:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004a86:	034a9f63          	bne	s5,s4,80004ac4 <filewrite+0x14a>
    80004a8a:	8556                	mv	a0,s5
    80004a8c:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a8e:	60e6                	ld	ra,88(sp)
    80004a90:	6446                	ld	s0,80(sp)
    80004a92:	6906                	ld	s2,64(sp)
    80004a94:	7aa2                	ld	s5,40(sp)
    80004a96:	7b02                	ld	s6,32(sp)
    80004a98:	6125                	addi	sp,sp,96
    80004a9a:	8082                	ret
    80004a9c:	e4a6                	sd	s1,72(sp)
    80004a9e:	fc4e                	sd	s3,56(sp)
    80004aa0:	f852                	sd	s4,48(sp)
    80004aa2:	ec5e                	sd	s7,24(sp)
    80004aa4:	e862                	sd	s8,16(sp)
    80004aa6:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004aa8:	00004517          	auipc	a0,0x4
    80004aac:	af850513          	addi	a0,a0,-1288 # 800085a0 <etext+0x5a0>
    80004ab0:	ffffc097          	auipc	ra,0xffffc
    80004ab4:	aae080e7          	jalr	-1362(ra) # 8000055e <panic>
    return -1;
    80004ab8:	557d                	li	a0,-1
}
    80004aba:	8082                	ret
      return -1;
    80004abc:	557d                	li	a0,-1
    80004abe:	bfc1                	j	80004a8e <filewrite+0x114>
    80004ac0:	557d                	li	a0,-1
    80004ac2:	b7f1                	j	80004a8e <filewrite+0x114>
    ret = (i == n ? n : -1);
    80004ac4:	557d                	li	a0,-1
    80004ac6:	7a42                	ld	s4,48(sp)
    80004ac8:	b7d9                	j	80004a8e <filewrite+0x114>

0000000080004aca <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004aca:	7179                	addi	sp,sp,-48
    80004acc:	f406                	sd	ra,40(sp)
    80004ace:	f022                	sd	s0,32(sp)
    80004ad0:	ec26                	sd	s1,24(sp)
    80004ad2:	e052                	sd	s4,0(sp)
    80004ad4:	1800                	addi	s0,sp,48
    80004ad6:	84aa                	mv	s1,a0
    80004ad8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ada:	0005b023          	sd	zero,0(a1)
    80004ade:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ae2:	00000097          	auipc	ra,0x0
    80004ae6:	bac080e7          	jalr	-1108(ra) # 8000468e <filealloc>
    80004aea:	e088                	sd	a0,0(s1)
    80004aec:	cd49                	beqz	a0,80004b86 <pipealloc+0xbc>
    80004aee:	00000097          	auipc	ra,0x0
    80004af2:	ba0080e7          	jalr	-1120(ra) # 8000468e <filealloc>
    80004af6:	00aa3023          	sd	a0,0(s4)
    80004afa:	c141                	beqz	a0,80004b7a <pipealloc+0xb0>
    80004afc:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004afe:	ffffc097          	auipc	ra,0xffffc
    80004b02:	05a080e7          	jalr	90(ra) # 80000b58 <kalloc>
    80004b06:	892a                	mv	s2,a0
    80004b08:	c13d                	beqz	a0,80004b6e <pipealloc+0xa4>
    80004b0a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004b0c:	4985                	li	s3,1
    80004b0e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b12:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b16:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b1a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b1e:	00004597          	auipc	a1,0x4
    80004b22:	a9258593          	addi	a1,a1,-1390 # 800085b0 <etext+0x5b0>
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	09c080e7          	jalr	156(ra) # 80000bc2 <initlock>
  (*f0)->type = FD_PIPE;
    80004b2e:	609c                	ld	a5,0(s1)
    80004b30:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b34:	609c                	ld	a5,0(s1)
    80004b36:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b3a:	609c                	ld	a5,0(s1)
    80004b3c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b40:	609c                	ld	a5,0(s1)
    80004b42:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b46:	000a3783          	ld	a5,0(s4)
    80004b4a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b4e:	000a3783          	ld	a5,0(s4)
    80004b52:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b56:	000a3783          	ld	a5,0(s4)
    80004b5a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b5e:	000a3783          	ld	a5,0(s4)
    80004b62:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b66:	4501                	li	a0,0
    80004b68:	6942                	ld	s2,16(sp)
    80004b6a:	69a2                	ld	s3,8(sp)
    80004b6c:	a03d                	j	80004b9a <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b6e:	6088                	ld	a0,0(s1)
    80004b70:	c119                	beqz	a0,80004b76 <pipealloc+0xac>
    80004b72:	6942                	ld	s2,16(sp)
    80004b74:	a029                	j	80004b7e <pipealloc+0xb4>
    80004b76:	6942                	ld	s2,16(sp)
    80004b78:	a039                	j	80004b86 <pipealloc+0xbc>
    80004b7a:	6088                	ld	a0,0(s1)
    80004b7c:	c50d                	beqz	a0,80004ba6 <pipealloc+0xdc>
    fileclose(*f0);
    80004b7e:	00000097          	auipc	ra,0x0
    80004b82:	bcc080e7          	jalr	-1076(ra) # 8000474a <fileclose>
  if(*f1)
    80004b86:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b8a:	557d                	li	a0,-1
  if(*f1)
    80004b8c:	c799                	beqz	a5,80004b9a <pipealloc+0xd0>
    fileclose(*f1);
    80004b8e:	853e                	mv	a0,a5
    80004b90:	00000097          	auipc	ra,0x0
    80004b94:	bba080e7          	jalr	-1094(ra) # 8000474a <fileclose>
  return -1;
    80004b98:	557d                	li	a0,-1
}
    80004b9a:	70a2                	ld	ra,40(sp)
    80004b9c:	7402                	ld	s0,32(sp)
    80004b9e:	64e2                	ld	s1,24(sp)
    80004ba0:	6a02                	ld	s4,0(sp)
    80004ba2:	6145                	addi	sp,sp,48
    80004ba4:	8082                	ret
  return -1;
    80004ba6:	557d                	li	a0,-1
    80004ba8:	bfcd                	j	80004b9a <pipealloc+0xd0>

0000000080004baa <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004baa:	1101                	addi	sp,sp,-32
    80004bac:	ec06                	sd	ra,24(sp)
    80004bae:	e822                	sd	s0,16(sp)
    80004bb0:	e426                	sd	s1,8(sp)
    80004bb2:	e04a                	sd	s2,0(sp)
    80004bb4:	1000                	addi	s0,sp,32
    80004bb6:	84aa                	mv	s1,a0
    80004bb8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bba:	ffffc097          	auipc	ra,0xffffc
    80004bbe:	0a2080e7          	jalr	162(ra) # 80000c5c <acquire>
  if(writable){
    80004bc2:	02090b63          	beqz	s2,80004bf8 <pipeclose+0x4e>
    pi->writeopen = 0;
    80004bc6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bca:	21848513          	addi	a0,s1,536
    80004bce:	ffffd097          	auipc	ra,0xffffd
    80004bd2:	6b2080e7          	jalr	1714(ra) # 80002280 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bd6:	2204a783          	lw	a5,544(s1)
    80004bda:	e781                	bnez	a5,80004be2 <pipeclose+0x38>
    80004bdc:	2244a783          	lw	a5,548(s1)
    80004be0:	c78d                	beqz	a5,80004c0a <pipeclose+0x60>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004be2:	8526                	mv	a0,s1
    80004be4:	ffffc097          	auipc	ra,0xffffc
    80004be8:	128080e7          	jalr	296(ra) # 80000d0c <release>
}
    80004bec:	60e2                	ld	ra,24(sp)
    80004bee:	6442                	ld	s0,16(sp)
    80004bf0:	64a2                	ld	s1,8(sp)
    80004bf2:	6902                	ld	s2,0(sp)
    80004bf4:	6105                	addi	sp,sp,32
    80004bf6:	8082                	ret
    pi->readopen = 0;
    80004bf8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004bfc:	21c48513          	addi	a0,s1,540
    80004c00:	ffffd097          	auipc	ra,0xffffd
    80004c04:	680080e7          	jalr	1664(ra) # 80002280 <wakeup>
    80004c08:	b7f9                	j	80004bd6 <pipeclose+0x2c>
    release(&pi->lock);
    80004c0a:	8526                	mv	a0,s1
    80004c0c:	ffffc097          	auipc	ra,0xffffc
    80004c10:	100080e7          	jalr	256(ra) # 80000d0c <release>
    kfree((char*)pi);
    80004c14:	8526                	mv	a0,s1
    80004c16:	ffffc097          	auipc	ra,0xffffc
    80004c1a:	e3e080e7          	jalr	-450(ra) # 80000a54 <kfree>
    80004c1e:	b7f9                	j	80004bec <pipeclose+0x42>

0000000080004c20 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c20:	7159                	addi	sp,sp,-112
    80004c22:	f486                	sd	ra,104(sp)
    80004c24:	f0a2                	sd	s0,96(sp)
    80004c26:	eca6                	sd	s1,88(sp)
    80004c28:	e8ca                	sd	s2,80(sp)
    80004c2a:	e4ce                	sd	s3,72(sp)
    80004c2c:	e0d2                	sd	s4,64(sp)
    80004c2e:	fc56                	sd	s5,56(sp)
    80004c30:	1880                	addi	s0,sp,112
    80004c32:	84aa                	mv	s1,a0
    80004c34:	8aae                	mv	s5,a1
    80004c36:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c38:	ffffd097          	auipc	ra,0xffffd
    80004c3c:	ed2080e7          	jalr	-302(ra) # 80001b0a <myproc>
    80004c40:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c42:	8526                	mv	a0,s1
    80004c44:	ffffc097          	auipc	ra,0xffffc
    80004c48:	018080e7          	jalr	24(ra) # 80000c5c <acquire>
  while(i < n){
    80004c4c:	0f405063          	blez	s4,80004d2c <pipewrite+0x10c>
    80004c50:	f85a                	sd	s6,48(sp)
    80004c52:	f45e                	sd	s7,40(sp)
    80004c54:	f062                	sd	s8,32(sp)
    80004c56:	ec66                	sd	s9,24(sp)
    80004c58:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004c5a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c5c:	f9f40c13          	addi	s8,s0,-97
    80004c60:	4b85                	li	s7,1
    80004c62:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c64:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c68:	21c48c93          	addi	s9,s1,540
    80004c6c:	a099                	j	80004cb2 <pipewrite+0x92>
      release(&pi->lock);
    80004c6e:	8526                	mv	a0,s1
    80004c70:	ffffc097          	auipc	ra,0xffffc
    80004c74:	09c080e7          	jalr	156(ra) # 80000d0c <release>
      return -1;
    80004c78:	597d                	li	s2,-1
    80004c7a:	7b42                	ld	s6,48(sp)
    80004c7c:	7ba2                	ld	s7,40(sp)
    80004c7e:	7c02                	ld	s8,32(sp)
    80004c80:	6ce2                	ld	s9,24(sp)
    80004c82:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c84:	854a                	mv	a0,s2
    80004c86:	70a6                	ld	ra,104(sp)
    80004c88:	7406                	ld	s0,96(sp)
    80004c8a:	64e6                	ld	s1,88(sp)
    80004c8c:	6946                	ld	s2,80(sp)
    80004c8e:	69a6                	ld	s3,72(sp)
    80004c90:	6a06                	ld	s4,64(sp)
    80004c92:	7ae2                	ld	s5,56(sp)
    80004c94:	6165                	addi	sp,sp,112
    80004c96:	8082                	ret
      wakeup(&pi->nread);
    80004c98:	856a                	mv	a0,s10
    80004c9a:	ffffd097          	auipc	ra,0xffffd
    80004c9e:	5e6080e7          	jalr	1510(ra) # 80002280 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ca2:	85a6                	mv	a1,s1
    80004ca4:	8566                	mv	a0,s9
    80004ca6:	ffffd097          	auipc	ra,0xffffd
    80004caa:	576080e7          	jalr	1398(ra) # 8000221c <sleep>
  while(i < n){
    80004cae:	05495e63          	bge	s2,s4,80004d0a <pipewrite+0xea>
    if(pi->readopen == 0 || killed(pr)){
    80004cb2:	2204a783          	lw	a5,544(s1)
    80004cb6:	dfc5                	beqz	a5,80004c6e <pipewrite+0x4e>
    80004cb8:	854e                	mv	a0,s3
    80004cba:	ffffe097          	auipc	ra,0xffffe
    80004cbe:	832080e7          	jalr	-1998(ra) # 800024ec <killed>
    80004cc2:	f555                	bnez	a0,80004c6e <pipewrite+0x4e>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cc4:	2184a783          	lw	a5,536(s1)
    80004cc8:	21c4a703          	lw	a4,540(s1)
    80004ccc:	2007879b          	addiw	a5,a5,512
    80004cd0:	fcf704e3          	beq	a4,a5,80004c98 <pipewrite+0x78>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cd4:	86de                	mv	a3,s7
    80004cd6:	01590633          	add	a2,s2,s5
    80004cda:	85e2                	mv	a1,s8
    80004cdc:	0509b503          	ld	a0,80(s3)
    80004ce0:	ffffd097          	auipc	ra,0xffffd
    80004ce4:	ac4080e7          	jalr	-1340(ra) # 800017a4 <copyin>
    80004ce8:	05650463          	beq	a0,s6,80004d30 <pipewrite+0x110>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cec:	21c4a783          	lw	a5,540(s1)
    80004cf0:	0017871b          	addiw	a4,a5,1
    80004cf4:	20e4ae23          	sw	a4,540(s1)
    80004cf8:	1ff7f793          	andi	a5,a5,511
    80004cfc:	97a6                	add	a5,a5,s1
    80004cfe:	f9f44703          	lbu	a4,-97(s0)
    80004d02:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d06:	2905                	addiw	s2,s2,1
    80004d08:	b75d                	j	80004cae <pipewrite+0x8e>
    80004d0a:	7b42                	ld	s6,48(sp)
    80004d0c:	7ba2                	ld	s7,40(sp)
    80004d0e:	7c02                	ld	s8,32(sp)
    80004d10:	6ce2                	ld	s9,24(sp)
    80004d12:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004d14:	21848513          	addi	a0,s1,536
    80004d18:	ffffd097          	auipc	ra,0xffffd
    80004d1c:	568080e7          	jalr	1384(ra) # 80002280 <wakeup>
  release(&pi->lock);
    80004d20:	8526                	mv	a0,s1
    80004d22:	ffffc097          	auipc	ra,0xffffc
    80004d26:	fea080e7          	jalr	-22(ra) # 80000d0c <release>
  return i;
    80004d2a:	bfa9                	j	80004c84 <pipewrite+0x64>
  int i = 0;
    80004d2c:	4901                	li	s2,0
    80004d2e:	b7dd                	j	80004d14 <pipewrite+0xf4>
    80004d30:	7b42                	ld	s6,48(sp)
    80004d32:	7ba2                	ld	s7,40(sp)
    80004d34:	7c02                	ld	s8,32(sp)
    80004d36:	6ce2                	ld	s9,24(sp)
    80004d38:	6d42                	ld	s10,16(sp)
    80004d3a:	bfe9                	j	80004d14 <pipewrite+0xf4>

0000000080004d3c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d3c:	711d                	addi	sp,sp,-96
    80004d3e:	ec86                	sd	ra,88(sp)
    80004d40:	e8a2                	sd	s0,80(sp)
    80004d42:	e4a6                	sd	s1,72(sp)
    80004d44:	e0ca                	sd	s2,64(sp)
    80004d46:	fc4e                	sd	s3,56(sp)
    80004d48:	f852                	sd	s4,48(sp)
    80004d4a:	f456                	sd	s5,40(sp)
    80004d4c:	1080                	addi	s0,sp,96
    80004d4e:	84aa                	mv	s1,a0
    80004d50:	892e                	mv	s2,a1
    80004d52:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d54:	ffffd097          	auipc	ra,0xffffd
    80004d58:	db6080e7          	jalr	-586(ra) # 80001b0a <myproc>
    80004d5c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	ffffc097          	auipc	ra,0xffffc
    80004d64:	efc080e7          	jalr	-260(ra) # 80000c5c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d68:	2184a703          	lw	a4,536(s1)
    80004d6c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d70:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d74:	02f71b63          	bne	a4,a5,80004daa <piperead+0x6e>
    80004d78:	2244a783          	lw	a5,548(s1)
    80004d7c:	c3b1                	beqz	a5,80004dc0 <piperead+0x84>
    if(killed(pr)){
    80004d7e:	8552                	mv	a0,s4
    80004d80:	ffffd097          	auipc	ra,0xffffd
    80004d84:	76c080e7          	jalr	1900(ra) # 800024ec <killed>
    80004d88:	e50d                	bnez	a0,80004db2 <piperead+0x76>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d8a:	85a6                	mv	a1,s1
    80004d8c:	854e                	mv	a0,s3
    80004d8e:	ffffd097          	auipc	ra,0xffffd
    80004d92:	48e080e7          	jalr	1166(ra) # 8000221c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d96:	2184a703          	lw	a4,536(s1)
    80004d9a:	21c4a783          	lw	a5,540(s1)
    80004d9e:	fcf70de3          	beq	a4,a5,80004d78 <piperead+0x3c>
    80004da2:	f05a                	sd	s6,32(sp)
    80004da4:	ec5e                	sd	s7,24(sp)
    80004da6:	e862                	sd	s8,16(sp)
    80004da8:	a839                	j	80004dc6 <piperead+0x8a>
    80004daa:	f05a                	sd	s6,32(sp)
    80004dac:	ec5e                	sd	s7,24(sp)
    80004dae:	e862                	sd	s8,16(sp)
    80004db0:	a819                	j	80004dc6 <piperead+0x8a>
      release(&pi->lock);
    80004db2:	8526                	mv	a0,s1
    80004db4:	ffffc097          	auipc	ra,0xffffc
    80004db8:	f58080e7          	jalr	-168(ra) # 80000d0c <release>
      return -1;
    80004dbc:	59fd                	li	s3,-1
    80004dbe:	a88d                	j	80004e30 <piperead+0xf4>
    80004dc0:	f05a                	sd	s6,32(sp)
    80004dc2:	ec5e                	sd	s7,24(sp)
    80004dc4:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dc6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dc8:	faf40c13          	addi	s8,s0,-81
    80004dcc:	4b85                	li	s7,1
    80004dce:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dd0:	05505263          	blez	s5,80004e14 <piperead+0xd8>
    if(pi->nread == pi->nwrite)
    80004dd4:	2184a783          	lw	a5,536(s1)
    80004dd8:	21c4a703          	lw	a4,540(s1)
    80004ddc:	02f70c63          	beq	a4,a5,80004e14 <piperead+0xd8>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004de0:	0017871b          	addiw	a4,a5,1
    80004de4:	20e4ac23          	sw	a4,536(s1)
    80004de8:	1ff7f793          	andi	a5,a5,511
    80004dec:	97a6                	add	a5,a5,s1
    80004dee:	0187c783          	lbu	a5,24(a5)
    80004df2:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004df6:	86de                	mv	a3,s7
    80004df8:	8662                	mv	a2,s8
    80004dfa:	85ca                	mv	a1,s2
    80004dfc:	050a3503          	ld	a0,80(s4)
    80004e00:	ffffd097          	auipc	ra,0xffffd
    80004e04:	918080e7          	jalr	-1768(ra) # 80001718 <copyout>
    80004e08:	01650663          	beq	a0,s6,80004e14 <piperead+0xd8>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e0c:	2985                	addiw	s3,s3,1
    80004e0e:	0905                	addi	s2,s2,1
    80004e10:	fd3a92e3          	bne	s5,s3,80004dd4 <piperead+0x98>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e14:	21c48513          	addi	a0,s1,540
    80004e18:	ffffd097          	auipc	ra,0xffffd
    80004e1c:	468080e7          	jalr	1128(ra) # 80002280 <wakeup>
  release(&pi->lock);
    80004e20:	8526                	mv	a0,s1
    80004e22:	ffffc097          	auipc	ra,0xffffc
    80004e26:	eea080e7          	jalr	-278(ra) # 80000d0c <release>
    80004e2a:	7b02                	ld	s6,32(sp)
    80004e2c:	6be2                	ld	s7,24(sp)
    80004e2e:	6c42                	ld	s8,16(sp)
  return i;
}
    80004e30:	854e                	mv	a0,s3
    80004e32:	60e6                	ld	ra,88(sp)
    80004e34:	6446                	ld	s0,80(sp)
    80004e36:	64a6                	ld	s1,72(sp)
    80004e38:	6906                	ld	s2,64(sp)
    80004e3a:	79e2                	ld	s3,56(sp)
    80004e3c:	7a42                	ld	s4,48(sp)
    80004e3e:	7aa2                	ld	s5,40(sp)
    80004e40:	6125                	addi	sp,sp,96
    80004e42:	8082                	ret

0000000080004e44 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e44:	1141                	addi	sp,sp,-16
    80004e46:	e406                	sd	ra,8(sp)
    80004e48:	e022                	sd	s0,0(sp)
    80004e4a:	0800                	addi	s0,sp,16
    80004e4c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e4e:	0035151b          	slliw	a0,a0,0x3
    80004e52:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004e54:	8b89                	andi	a5,a5,2
    80004e56:	c399                	beqz	a5,80004e5c <flags2perm+0x18>
      perm |= PTE_W;
    80004e58:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e5c:	60a2                	ld	ra,8(sp)
    80004e5e:	6402                	ld	s0,0(sp)
    80004e60:	0141                	addi	sp,sp,16
    80004e62:	8082                	ret

0000000080004e64 <exec>:

int
exec(char *path, char **argv)
{
    80004e64:	de010113          	addi	sp,sp,-544
    80004e68:	20113c23          	sd	ra,536(sp)
    80004e6c:	20813823          	sd	s0,528(sp)
    80004e70:	20913423          	sd	s1,520(sp)
    80004e74:	21213023          	sd	s2,512(sp)
    80004e78:	1400                	addi	s0,sp,544
    80004e7a:	892a                	mv	s2,a0
    80004e7c:	dea43823          	sd	a0,-528(s0)
    80004e80:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e84:	ffffd097          	auipc	ra,0xffffd
    80004e88:	c86080e7          	jalr	-890(ra) # 80001b0a <myproc>
    80004e8c:	84aa                	mv	s1,a0

  begin_op();
    80004e8e:	fffff097          	auipc	ra,0xfffff
    80004e92:	3da080e7          	jalr	986(ra) # 80004268 <begin_op>

  if((ip = namei(path)) == 0){
    80004e96:	854a                	mv	a0,s2
    80004e98:	fffff097          	auipc	ra,0xfffff
    80004e9c:	1ca080e7          	jalr	458(ra) # 80004062 <namei>
    80004ea0:	c525                	beqz	a0,80004f08 <exec+0xa4>
    80004ea2:	fbd2                	sd	s4,496(sp)
    80004ea4:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ea6:	fffff097          	auipc	ra,0xfffff
    80004eaa:	9d2080e7          	jalr	-1582(ra) # 80003878 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004eae:	04000713          	li	a4,64
    80004eb2:	4681                	li	a3,0
    80004eb4:	e5040613          	addi	a2,s0,-432
    80004eb8:	4581                	li	a1,0
    80004eba:	8552                	mv	a0,s4
    80004ebc:	fffff097          	auipc	ra,0xfffff
    80004ec0:	c7a080e7          	jalr	-902(ra) # 80003b36 <readi>
    80004ec4:	04000793          	li	a5,64
    80004ec8:	00f51a63          	bne	a0,a5,80004edc <exec+0x78>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004ecc:	e5042703          	lw	a4,-432(s0)
    80004ed0:	464c47b7          	lui	a5,0x464c4
    80004ed4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ed8:	02f70e63          	beq	a4,a5,80004f14 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004edc:	8552                	mv	a0,s4
    80004ede:	fffff097          	auipc	ra,0xfffff
    80004ee2:	c02080e7          	jalr	-1022(ra) # 80003ae0 <iunlockput>
    end_op();
    80004ee6:	fffff097          	auipc	ra,0xfffff
    80004eea:	402080e7          	jalr	1026(ra) # 800042e8 <end_op>
  }
  return -1;
    80004eee:	557d                	li	a0,-1
    80004ef0:	7a5e                	ld	s4,496(sp)
}
    80004ef2:	21813083          	ld	ra,536(sp)
    80004ef6:	21013403          	ld	s0,528(sp)
    80004efa:	20813483          	ld	s1,520(sp)
    80004efe:	20013903          	ld	s2,512(sp)
    80004f02:	22010113          	addi	sp,sp,544
    80004f06:	8082                	ret
    end_op();
    80004f08:	fffff097          	auipc	ra,0xfffff
    80004f0c:	3e0080e7          	jalr	992(ra) # 800042e8 <end_op>
    return -1;
    80004f10:	557d                	li	a0,-1
    80004f12:	b7c5                	j	80004ef2 <exec+0x8e>
    80004f14:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004f16:	8526                	mv	a0,s1
    80004f18:	ffffd097          	auipc	ra,0xffffd
    80004f1c:	cb8080e7          	jalr	-840(ra) # 80001bd0 <proc_pagetable>
    80004f20:	8b2a                	mv	s6,a0
    80004f22:	2c050363          	beqz	a0,800051e8 <exec+0x384>
    80004f26:	ffce                	sd	s3,504(sp)
    80004f28:	f7d6                	sd	s5,488(sp)
    80004f2a:	efde                	sd	s7,472(sp)
    80004f2c:	ebe2                	sd	s8,464(sp)
    80004f2e:	e7e6                	sd	s9,456(sp)
    80004f30:	e3ea                	sd	s10,448(sp)
    80004f32:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f34:	e8845783          	lhu	a5,-376(s0)
    80004f38:	10078563          	beqz	a5,80005042 <exec+0x1de>
    80004f3c:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f40:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f42:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f44:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004f48:	6c85                	lui	s9,0x1
    80004f4a:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f4e:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004f52:	6a85                	lui	s5,0x1
    80004f54:	a0b5                	j	80004fc0 <exec+0x15c>
      panic("loadseg: address should exist");
    80004f56:	00003517          	auipc	a0,0x3
    80004f5a:	66250513          	addi	a0,a0,1634 # 800085b8 <etext+0x5b8>
    80004f5e:	ffffb097          	auipc	ra,0xffffb
    80004f62:	600080e7          	jalr	1536(ra) # 8000055e <panic>
    if(sz - i < PGSIZE)
    80004f66:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f68:	874a                	mv	a4,s2
    80004f6a:	009b86bb          	addw	a3,s7,s1
    80004f6e:	4581                	li	a1,0
    80004f70:	8552                	mv	a0,s4
    80004f72:	fffff097          	auipc	ra,0xfffff
    80004f76:	bc4080e7          	jalr	-1084(ra) # 80003b36 <readi>
    80004f7a:	26a91b63          	bne	s2,a0,800051f0 <exec+0x38c>
  for(i = 0; i < sz; i += PGSIZE){
    80004f7e:	009a84bb          	addw	s1,s5,s1
    80004f82:	0334f463          	bgeu	s1,s3,80004faa <exec+0x146>
    pa = walkaddr(pagetable, va + i);
    80004f86:	02049593          	slli	a1,s1,0x20
    80004f8a:	9181                	srli	a1,a1,0x20
    80004f8c:	95e2                	add	a1,a1,s8
    80004f8e:	855a                	mv	a0,s6
    80004f90:	ffffc097          	auipc	ra,0xffffc
    80004f94:	166080e7          	jalr	358(ra) # 800010f6 <walkaddr>
    80004f98:	862a                	mv	a2,a0
    if(pa == 0)
    80004f9a:	dd55                	beqz	a0,80004f56 <exec+0xf2>
    if(sz - i < PGSIZE)
    80004f9c:	409987bb          	subw	a5,s3,s1
    80004fa0:	893e                	mv	s2,a5
    80004fa2:	fcfcf2e3          	bgeu	s9,a5,80004f66 <exec+0x102>
    80004fa6:	8956                	mv	s2,s5
    80004fa8:	bf7d                	j	80004f66 <exec+0x102>
    sz = sz1;
    80004faa:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fae:	2d05                	addiw	s10,s10,1
    80004fb0:	e0843783          	ld	a5,-504(s0)
    80004fb4:	0387869b          	addiw	a3,a5,56
    80004fb8:	e8845783          	lhu	a5,-376(s0)
    80004fbc:	08fd5463          	bge	s10,a5,80005044 <exec+0x1e0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004fc0:	e0d43423          	sd	a3,-504(s0)
    80004fc4:	876e                	mv	a4,s11
    80004fc6:	e1840613          	addi	a2,s0,-488
    80004fca:	4581                	li	a1,0
    80004fcc:	8552                	mv	a0,s4
    80004fce:	fffff097          	auipc	ra,0xfffff
    80004fd2:	b68080e7          	jalr	-1176(ra) # 80003b36 <readi>
    80004fd6:	21b51b63          	bne	a0,s11,800051ec <exec+0x388>
    if(ph.type != ELF_PROG_LOAD)
    80004fda:	e1842783          	lw	a5,-488(s0)
    80004fde:	4705                	li	a4,1
    80004fe0:	fce797e3          	bne	a5,a4,80004fae <exec+0x14a>
    if(ph.memsz < ph.filesz)
    80004fe4:	e4043483          	ld	s1,-448(s0)
    80004fe8:	e3843783          	ld	a5,-456(s0)
    80004fec:	22f4e263          	bltu	s1,a5,80005210 <exec+0x3ac>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004ff0:	e2843783          	ld	a5,-472(s0)
    80004ff4:	94be                	add	s1,s1,a5
    80004ff6:	22f4e063          	bltu	s1,a5,80005216 <exec+0x3b2>
    if(ph.vaddr % PGSIZE != 0)
    80004ffa:	de843703          	ld	a4,-536(s0)
    80004ffe:	8ff9                	and	a5,a5,a4
    80005000:	20079e63          	bnez	a5,8000521c <exec+0x3b8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005004:	e1c42503          	lw	a0,-484(s0)
    80005008:	00000097          	auipc	ra,0x0
    8000500c:	e3c080e7          	jalr	-452(ra) # 80004e44 <flags2perm>
    80005010:	86aa                	mv	a3,a0
    80005012:	8626                	mv	a2,s1
    80005014:	85ca                	mv	a1,s2
    80005016:	855a                	mv	a0,s6
    80005018:	ffffc097          	auipc	ra,0xffffc
    8000501c:	49c080e7          	jalr	1180(ra) # 800014b4 <uvmalloc>
    80005020:	dea43c23          	sd	a0,-520(s0)
    80005024:	1e050f63          	beqz	a0,80005222 <exec+0x3be>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005028:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000502c:	00098863          	beqz	s3,8000503c <exec+0x1d8>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005030:	e2843c03          	ld	s8,-472(s0)
    80005034:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005038:	4481                	li	s1,0
    8000503a:	b7b1                	j	80004f86 <exec+0x122>
    sz = sz1;
    8000503c:	df843903          	ld	s2,-520(s0)
    80005040:	b7bd                	j	80004fae <exec+0x14a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005042:	4901                	li	s2,0
  iunlockput(ip);
    80005044:	8552                	mv	a0,s4
    80005046:	fffff097          	auipc	ra,0xfffff
    8000504a:	a9a080e7          	jalr	-1382(ra) # 80003ae0 <iunlockput>
  end_op();
    8000504e:	fffff097          	auipc	ra,0xfffff
    80005052:	29a080e7          	jalr	666(ra) # 800042e8 <end_op>
  p = myproc();
    80005056:	ffffd097          	auipc	ra,0xffffd
    8000505a:	ab4080e7          	jalr	-1356(ra) # 80001b0a <myproc>
    8000505e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005060:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005064:	6985                	lui	s3,0x1
    80005066:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005068:	99ca                	add	s3,s3,s2
    8000506a:	77fd                	lui	a5,0xfffff
    8000506c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005070:	4691                	li	a3,4
    80005072:	6609                	lui	a2,0x2
    80005074:	964e                	add	a2,a2,s3
    80005076:	85ce                	mv	a1,s3
    80005078:	855a                	mv	a0,s6
    8000507a:	ffffc097          	auipc	ra,0xffffc
    8000507e:	43a080e7          	jalr	1082(ra) # 800014b4 <uvmalloc>
    80005082:	8a2a                	mv	s4,a0
    80005084:	e115                	bnez	a0,800050a8 <exec+0x244>
    proc_freepagetable(pagetable, sz);
    80005086:	85ce                	mv	a1,s3
    80005088:	855a                	mv	a0,s6
    8000508a:	ffffd097          	auipc	ra,0xffffd
    8000508e:	be2080e7          	jalr	-1054(ra) # 80001c6c <proc_freepagetable>
  return -1;
    80005092:	557d                	li	a0,-1
    80005094:	79fe                	ld	s3,504(sp)
    80005096:	7a5e                	ld	s4,496(sp)
    80005098:	7abe                	ld	s5,488(sp)
    8000509a:	7b1e                	ld	s6,480(sp)
    8000509c:	6bfe                	ld	s7,472(sp)
    8000509e:	6c5e                	ld	s8,464(sp)
    800050a0:	6cbe                	ld	s9,456(sp)
    800050a2:	6d1e                	ld	s10,448(sp)
    800050a4:	7dfa                	ld	s11,440(sp)
    800050a6:	b5b1                	j	80004ef2 <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    800050a8:	75f9                	lui	a1,0xffffe
    800050aa:	95aa                	add	a1,a1,a0
    800050ac:	855a                	mv	a0,s6
    800050ae:	ffffc097          	auipc	ra,0xffffc
    800050b2:	638080e7          	jalr	1592(ra) # 800016e6 <uvmclear>
  stackbase = sp - PGSIZE;
    800050b6:	800a0b93          	addi	s7,s4,-2048
    800050ba:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    800050be:	e0043783          	ld	a5,-512(s0)
    800050c2:	6388                	ld	a0,0(a5)
  sp = sz;
    800050c4:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    800050c6:	4481                	li	s1,0
    ustack[argc] = sp;
    800050c8:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    800050cc:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    800050d0:	c135                	beqz	a0,80005134 <exec+0x2d0>
    sp -= strlen(argv[argc]) + 1;
    800050d2:	ffffc097          	auipc	ra,0xffffc
    800050d6:	e10080e7          	jalr	-496(ra) # 80000ee2 <strlen>
    800050da:	0015079b          	addiw	a5,a0,1
    800050de:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050e2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800050e6:	15796163          	bltu	s2,s7,80005228 <exec+0x3c4>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050ea:	e0043d83          	ld	s11,-512(s0)
    800050ee:	000db983          	ld	s3,0(s11)
    800050f2:	854e                	mv	a0,s3
    800050f4:	ffffc097          	auipc	ra,0xffffc
    800050f8:	dee080e7          	jalr	-530(ra) # 80000ee2 <strlen>
    800050fc:	0015069b          	addiw	a3,a0,1
    80005100:	864e                	mv	a2,s3
    80005102:	85ca                	mv	a1,s2
    80005104:	855a                	mv	a0,s6
    80005106:	ffffc097          	auipc	ra,0xffffc
    8000510a:	612080e7          	jalr	1554(ra) # 80001718 <copyout>
    8000510e:	10054f63          	bltz	a0,8000522c <exec+0x3c8>
    ustack[argc] = sp;
    80005112:	00349793          	slli	a5,s1,0x3
    80005116:	97e6                	add	a5,a5,s9
    80005118:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffdcec0>
  for(argc = 0; argv[argc]; argc++) {
    8000511c:	0485                	addi	s1,s1,1
    8000511e:	008d8793          	addi	a5,s11,8
    80005122:	e0f43023          	sd	a5,-512(s0)
    80005126:	008db503          	ld	a0,8(s11)
    8000512a:	c509                	beqz	a0,80005134 <exec+0x2d0>
    if(argc >= MAXARG)
    8000512c:	fb8493e3          	bne	s1,s8,800050d2 <exec+0x26e>
  sz = sz1;
    80005130:	89d2                	mv	s3,s4
    80005132:	bf91                	j	80005086 <exec+0x222>
  ustack[argc] = 0;
    80005134:	00349793          	slli	a5,s1,0x3
    80005138:	f9078793          	addi	a5,a5,-112
    8000513c:	97a2                	add	a5,a5,s0
    8000513e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005142:	00349693          	slli	a3,s1,0x3
    80005146:	06a1                	addi	a3,a3,8
    80005148:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000514c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005150:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80005152:	f3796ae3          	bltu	s2,s7,80005086 <exec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005156:	e9040613          	addi	a2,s0,-368
    8000515a:	85ca                	mv	a1,s2
    8000515c:	855a                	mv	a0,s6
    8000515e:	ffffc097          	auipc	ra,0xffffc
    80005162:	5ba080e7          	jalr	1466(ra) # 80001718 <copyout>
    80005166:	f20540e3          	bltz	a0,80005086 <exec+0x222>
  p->trapframe->a1 = sp;
    8000516a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000516e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005172:	df043783          	ld	a5,-528(s0)
    80005176:	0007c703          	lbu	a4,0(a5)
    8000517a:	cf11                	beqz	a4,80005196 <exec+0x332>
    8000517c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000517e:	02f00693          	li	a3,47
    80005182:	a029                	j	8000518c <exec+0x328>
  for(last=s=path; *s; s++)
    80005184:	0785                	addi	a5,a5,1
    80005186:	fff7c703          	lbu	a4,-1(a5)
    8000518a:	c711                	beqz	a4,80005196 <exec+0x332>
    if(*s == '/')
    8000518c:	fed71ce3          	bne	a4,a3,80005184 <exec+0x320>
      last = s+1;
    80005190:	def43823          	sd	a5,-528(s0)
    80005194:	bfc5                	j	80005184 <exec+0x320>
  safestrcpy(p->name, last, sizeof(p->name));
    80005196:	4641                	li	a2,16
    80005198:	df043583          	ld	a1,-528(s0)
    8000519c:	158a8513          	addi	a0,s5,344
    800051a0:	ffffc097          	auipc	ra,0xffffc
    800051a4:	d0c080e7          	jalr	-756(ra) # 80000eac <safestrcpy>
  oldpagetable = p->pagetable;
    800051a8:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800051ac:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800051b0:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800051b4:	058ab783          	ld	a5,88(s5)
    800051b8:	e6843703          	ld	a4,-408(s0)
    800051bc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800051be:	058ab783          	ld	a5,88(s5)
    800051c2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051c6:	85ea                	mv	a1,s10
    800051c8:	ffffd097          	auipc	ra,0xffffd
    800051cc:	aa4080e7          	jalr	-1372(ra) # 80001c6c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051d0:	0004851b          	sext.w	a0,s1
    800051d4:	79fe                	ld	s3,504(sp)
    800051d6:	7a5e                	ld	s4,496(sp)
    800051d8:	7abe                	ld	s5,488(sp)
    800051da:	7b1e                	ld	s6,480(sp)
    800051dc:	6bfe                	ld	s7,472(sp)
    800051de:	6c5e                	ld	s8,464(sp)
    800051e0:	6cbe                	ld	s9,456(sp)
    800051e2:	6d1e                	ld	s10,448(sp)
    800051e4:	7dfa                	ld	s11,440(sp)
    800051e6:	b331                	j	80004ef2 <exec+0x8e>
    800051e8:	7b1e                	ld	s6,480(sp)
    800051ea:	b9cd                	j	80004edc <exec+0x78>
    800051ec:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800051f0:	df843583          	ld	a1,-520(s0)
    800051f4:	855a                	mv	a0,s6
    800051f6:	ffffd097          	auipc	ra,0xffffd
    800051fa:	a76080e7          	jalr	-1418(ra) # 80001c6c <proc_freepagetable>
  if(ip){
    800051fe:	79fe                	ld	s3,504(sp)
    80005200:	7abe                	ld	s5,488(sp)
    80005202:	7b1e                	ld	s6,480(sp)
    80005204:	6bfe                	ld	s7,472(sp)
    80005206:	6c5e                	ld	s8,464(sp)
    80005208:	6cbe                	ld	s9,456(sp)
    8000520a:	6d1e                	ld	s10,448(sp)
    8000520c:	7dfa                	ld	s11,440(sp)
    8000520e:	b1f9                	j	80004edc <exec+0x78>
    80005210:	df243c23          	sd	s2,-520(s0)
    80005214:	bff1                	j	800051f0 <exec+0x38c>
    80005216:	df243c23          	sd	s2,-520(s0)
    8000521a:	bfd9                	j	800051f0 <exec+0x38c>
    8000521c:	df243c23          	sd	s2,-520(s0)
    80005220:	bfc1                	j	800051f0 <exec+0x38c>
    80005222:	df243c23          	sd	s2,-520(s0)
    80005226:	b7e9                	j	800051f0 <exec+0x38c>
  sz = sz1;
    80005228:	89d2                	mv	s3,s4
    8000522a:	bdb1                	j	80005086 <exec+0x222>
    8000522c:	89d2                	mv	s3,s4
    8000522e:	bda1                	j	80005086 <exec+0x222>

0000000080005230 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005230:	7179                	addi	sp,sp,-48
    80005232:	f406                	sd	ra,40(sp)
    80005234:	f022                	sd	s0,32(sp)
    80005236:	ec26                	sd	s1,24(sp)
    80005238:	e84a                	sd	s2,16(sp)
    8000523a:	1800                	addi	s0,sp,48
    8000523c:	892e                	mv	s2,a1
    8000523e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005240:	fdc40593          	addi	a1,s0,-36
    80005244:	ffffe097          	auipc	ra,0xffffe
    80005248:	a88080e7          	jalr	-1400(ra) # 80002ccc <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000524c:	fdc42703          	lw	a4,-36(s0)
    80005250:	47bd                	li	a5,15
    80005252:	02e7ec63          	bltu	a5,a4,8000528a <argfd+0x5a>
    80005256:	ffffd097          	auipc	ra,0xffffd
    8000525a:	8b4080e7          	jalr	-1868(ra) # 80001b0a <myproc>
    8000525e:	fdc42703          	lw	a4,-36(s0)
    80005262:	00371793          	slli	a5,a4,0x3
    80005266:	0d078793          	addi	a5,a5,208
    8000526a:	953e                	add	a0,a0,a5
    8000526c:	611c                	ld	a5,0(a0)
    8000526e:	c385                	beqz	a5,8000528e <argfd+0x5e>
    return -1;
  if(pfd)
    80005270:	00090463          	beqz	s2,80005278 <argfd+0x48>
    *pfd = fd;
    80005274:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005278:	4501                	li	a0,0
  if(pf)
    8000527a:	c091                	beqz	s1,8000527e <argfd+0x4e>
    *pf = f;
    8000527c:	e09c                	sd	a5,0(s1)
}
    8000527e:	70a2                	ld	ra,40(sp)
    80005280:	7402                	ld	s0,32(sp)
    80005282:	64e2                	ld	s1,24(sp)
    80005284:	6942                	ld	s2,16(sp)
    80005286:	6145                	addi	sp,sp,48
    80005288:	8082                	ret
    return -1;
    8000528a:	557d                	li	a0,-1
    8000528c:	bfcd                	j	8000527e <argfd+0x4e>
    8000528e:	557d                	li	a0,-1
    80005290:	b7fd                	j	8000527e <argfd+0x4e>

0000000080005292 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005292:	1101                	addi	sp,sp,-32
    80005294:	ec06                	sd	ra,24(sp)
    80005296:	e822                	sd	s0,16(sp)
    80005298:	e426                	sd	s1,8(sp)
    8000529a:	1000                	addi	s0,sp,32
    8000529c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000529e:	ffffd097          	auipc	ra,0xffffd
    800052a2:	86c080e7          	jalr	-1940(ra) # 80001b0a <myproc>
    800052a6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052a8:	0d050793          	addi	a5,a0,208
    800052ac:	4501                	li	a0,0
    800052ae:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052b0:	6398                	ld	a4,0(a5)
    800052b2:	cb19                	beqz	a4,800052c8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052b4:	2505                	addiw	a0,a0,1
    800052b6:	07a1                	addi	a5,a5,8
    800052b8:	fed51ce3          	bne	a0,a3,800052b0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052bc:	557d                	li	a0,-1
}
    800052be:	60e2                	ld	ra,24(sp)
    800052c0:	6442                	ld	s0,16(sp)
    800052c2:	64a2                	ld	s1,8(sp)
    800052c4:	6105                	addi	sp,sp,32
    800052c6:	8082                	ret
      p->ofile[fd] = f;
    800052c8:	00351793          	slli	a5,a0,0x3
    800052cc:	0d078793          	addi	a5,a5,208
    800052d0:	963e                	add	a2,a2,a5
    800052d2:	e204                	sd	s1,0(a2)
      return fd;
    800052d4:	b7ed                	j	800052be <fdalloc+0x2c>

00000000800052d6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052d6:	715d                	addi	sp,sp,-80
    800052d8:	e486                	sd	ra,72(sp)
    800052da:	e0a2                	sd	s0,64(sp)
    800052dc:	fc26                	sd	s1,56(sp)
    800052de:	f84a                	sd	s2,48(sp)
    800052e0:	f44e                	sd	s3,40(sp)
    800052e2:	f052                	sd	s4,32(sp)
    800052e4:	ec56                	sd	s5,24(sp)
    800052e6:	e85a                	sd	s6,16(sp)
    800052e8:	0880                	addi	s0,sp,80
    800052ea:	892e                	mv	s2,a1
    800052ec:	8a2e                	mv	s4,a1
    800052ee:	8ab2                	mv	s5,a2
    800052f0:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052f2:	fb040593          	addi	a1,s0,-80
    800052f6:	fffff097          	auipc	ra,0xfffff
    800052fa:	d8a080e7          	jalr	-630(ra) # 80004080 <nameiparent>
    800052fe:	84aa                	mv	s1,a0
    80005300:	14050b63          	beqz	a0,80005456 <create+0x180>
    return 0;

  ilock(dp);
    80005304:	ffffe097          	auipc	ra,0xffffe
    80005308:	574080e7          	jalr	1396(ra) # 80003878 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000530c:	4601                	li	a2,0
    8000530e:	fb040593          	addi	a1,s0,-80
    80005312:	8526                	mv	a0,s1
    80005314:	fffff097          	auipc	ra,0xfffff
    80005318:	a5e080e7          	jalr	-1442(ra) # 80003d72 <dirlookup>
    8000531c:	89aa                	mv	s3,a0
    8000531e:	c921                	beqz	a0,8000536e <create+0x98>
    iunlockput(dp);
    80005320:	8526                	mv	a0,s1
    80005322:	ffffe097          	auipc	ra,0xffffe
    80005326:	7be080e7          	jalr	1982(ra) # 80003ae0 <iunlockput>
    ilock(ip);
    8000532a:	854e                	mv	a0,s3
    8000532c:	ffffe097          	auipc	ra,0xffffe
    80005330:	54c080e7          	jalr	1356(ra) # 80003878 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005334:	4789                	li	a5,2
    80005336:	02f91563          	bne	s2,a5,80005360 <create+0x8a>
    8000533a:	0449d783          	lhu	a5,68(s3)
    8000533e:	37f9                	addiw	a5,a5,-2
    80005340:	17c2                	slli	a5,a5,0x30
    80005342:	93c1                	srli	a5,a5,0x30
    80005344:	4705                	li	a4,1
    80005346:	00f76d63          	bltu	a4,a5,80005360 <create+0x8a>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000534a:	854e                	mv	a0,s3
    8000534c:	60a6                	ld	ra,72(sp)
    8000534e:	6406                	ld	s0,64(sp)
    80005350:	74e2                	ld	s1,56(sp)
    80005352:	7942                	ld	s2,48(sp)
    80005354:	79a2                	ld	s3,40(sp)
    80005356:	7a02                	ld	s4,32(sp)
    80005358:	6ae2                	ld	s5,24(sp)
    8000535a:	6b42                	ld	s6,16(sp)
    8000535c:	6161                	addi	sp,sp,80
    8000535e:	8082                	ret
    iunlockput(ip);
    80005360:	854e                	mv	a0,s3
    80005362:	ffffe097          	auipc	ra,0xffffe
    80005366:	77e080e7          	jalr	1918(ra) # 80003ae0 <iunlockput>
    return 0;
    8000536a:	4981                	li	s3,0
    8000536c:	bff9                	j	8000534a <create+0x74>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000536e:	85ca                	mv	a1,s2
    80005370:	4088                	lw	a0,0(s1)
    80005372:	ffffe097          	auipc	ra,0xffffe
    80005376:	362080e7          	jalr	866(ra) # 800036d4 <ialloc>
    8000537a:	892a                	mv	s2,a0
    8000537c:	c531                	beqz	a0,800053c8 <create+0xf2>
  ilock(ip);
    8000537e:	ffffe097          	auipc	ra,0xffffe
    80005382:	4fa080e7          	jalr	1274(ra) # 80003878 <ilock>
  ip->major = major;
    80005386:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    8000538a:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    8000538e:	4785                	li	a5,1
    80005390:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005394:	854a                	mv	a0,s2
    80005396:	ffffe097          	auipc	ra,0xffffe
    8000539a:	416080e7          	jalr	1046(ra) # 800037ac <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000539e:	4705                	li	a4,1
    800053a0:	02ea0a63          	beq	s4,a4,800053d4 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800053a4:	00492603          	lw	a2,4(s2)
    800053a8:	fb040593          	addi	a1,s0,-80
    800053ac:	8526                	mv	a0,s1
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	bf2080e7          	jalr	-1038(ra) # 80003fa0 <dirlink>
    800053b6:	06054e63          	bltz	a0,80005432 <create+0x15c>
  iunlockput(dp);
    800053ba:	8526                	mv	a0,s1
    800053bc:	ffffe097          	auipc	ra,0xffffe
    800053c0:	724080e7          	jalr	1828(ra) # 80003ae0 <iunlockput>
  return ip;
    800053c4:	89ca                	mv	s3,s2
    800053c6:	b751                	j	8000534a <create+0x74>
    iunlockput(dp);
    800053c8:	8526                	mv	a0,s1
    800053ca:	ffffe097          	auipc	ra,0xffffe
    800053ce:	716080e7          	jalr	1814(ra) # 80003ae0 <iunlockput>
    return 0;
    800053d2:	bfa5                	j	8000534a <create+0x74>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053d4:	00492603          	lw	a2,4(s2)
    800053d8:	00003597          	auipc	a1,0x3
    800053dc:	20058593          	addi	a1,a1,512 # 800085d8 <etext+0x5d8>
    800053e0:	854a                	mv	a0,s2
    800053e2:	fffff097          	auipc	ra,0xfffff
    800053e6:	bbe080e7          	jalr	-1090(ra) # 80003fa0 <dirlink>
    800053ea:	04054463          	bltz	a0,80005432 <create+0x15c>
    800053ee:	40d0                	lw	a2,4(s1)
    800053f0:	00003597          	auipc	a1,0x3
    800053f4:	1f058593          	addi	a1,a1,496 # 800085e0 <etext+0x5e0>
    800053f8:	854a                	mv	a0,s2
    800053fa:	fffff097          	auipc	ra,0xfffff
    800053fe:	ba6080e7          	jalr	-1114(ra) # 80003fa0 <dirlink>
    80005402:	02054863          	bltz	a0,80005432 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005406:	00492603          	lw	a2,4(s2)
    8000540a:	fb040593          	addi	a1,s0,-80
    8000540e:	8526                	mv	a0,s1
    80005410:	fffff097          	auipc	ra,0xfffff
    80005414:	b90080e7          	jalr	-1136(ra) # 80003fa0 <dirlink>
    80005418:	00054d63          	bltz	a0,80005432 <create+0x15c>
    dp->nlink++;  // for ".."
    8000541c:	04a4d783          	lhu	a5,74(s1)
    80005420:	2785                	addiw	a5,a5,1
    80005422:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005426:	8526                	mv	a0,s1
    80005428:	ffffe097          	auipc	ra,0xffffe
    8000542c:	384080e7          	jalr	900(ra) # 800037ac <iupdate>
    80005430:	b769                	j	800053ba <create+0xe4>
  ip->nlink = 0;
    80005432:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80005436:	854a                	mv	a0,s2
    80005438:	ffffe097          	auipc	ra,0xffffe
    8000543c:	374080e7          	jalr	884(ra) # 800037ac <iupdate>
  iunlockput(ip);
    80005440:	854a                	mv	a0,s2
    80005442:	ffffe097          	auipc	ra,0xffffe
    80005446:	69e080e7          	jalr	1694(ra) # 80003ae0 <iunlockput>
  iunlockput(dp);
    8000544a:	8526                	mv	a0,s1
    8000544c:	ffffe097          	auipc	ra,0xffffe
    80005450:	694080e7          	jalr	1684(ra) # 80003ae0 <iunlockput>
  return 0;
    80005454:	bddd                	j	8000534a <create+0x74>
    return 0;
    80005456:	89aa                	mv	s3,a0
    80005458:	bdcd                	j	8000534a <create+0x74>

000000008000545a <sys_dup>:
{
    8000545a:	7179                	addi	sp,sp,-48
    8000545c:	f406                	sd	ra,40(sp)
    8000545e:	f022                	sd	s0,32(sp)
    80005460:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005462:	fd840613          	addi	a2,s0,-40
    80005466:	4581                	li	a1,0
    80005468:	4501                	li	a0,0
    8000546a:	00000097          	auipc	ra,0x0
    8000546e:	dc6080e7          	jalr	-570(ra) # 80005230 <argfd>
    return -1;
    80005472:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005474:	02054763          	bltz	a0,800054a2 <sys_dup+0x48>
    80005478:	ec26                	sd	s1,24(sp)
    8000547a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000547c:	fd843483          	ld	s1,-40(s0)
    80005480:	8526                	mv	a0,s1
    80005482:	00000097          	auipc	ra,0x0
    80005486:	e10080e7          	jalr	-496(ra) # 80005292 <fdalloc>
    8000548a:	892a                	mv	s2,a0
    return -1;
    8000548c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000548e:	00054f63          	bltz	a0,800054ac <sys_dup+0x52>
  filedup(f);
    80005492:	8526                	mv	a0,s1
    80005494:	fffff097          	auipc	ra,0xfffff
    80005498:	264080e7          	jalr	612(ra) # 800046f8 <filedup>
  return fd;
    8000549c:	87ca                	mv	a5,s2
    8000549e:	64e2                	ld	s1,24(sp)
    800054a0:	6942                	ld	s2,16(sp)
}
    800054a2:	853e                	mv	a0,a5
    800054a4:	70a2                	ld	ra,40(sp)
    800054a6:	7402                	ld	s0,32(sp)
    800054a8:	6145                	addi	sp,sp,48
    800054aa:	8082                	ret
    800054ac:	64e2                	ld	s1,24(sp)
    800054ae:	6942                	ld	s2,16(sp)
    800054b0:	bfcd                	j	800054a2 <sys_dup+0x48>

00000000800054b2 <sys_read>:
{
    800054b2:	7179                	addi	sp,sp,-48
    800054b4:	f406                	sd	ra,40(sp)
    800054b6:	f022                	sd	s0,32(sp)
    800054b8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054ba:	fd840593          	addi	a1,s0,-40
    800054be:	4505                	li	a0,1
    800054c0:	ffffe097          	auipc	ra,0xffffe
    800054c4:	82c080e7          	jalr	-2004(ra) # 80002cec <argaddr>
  argint(2, &n);
    800054c8:	fe440593          	addi	a1,s0,-28
    800054cc:	4509                	li	a0,2
    800054ce:	ffffd097          	auipc	ra,0xffffd
    800054d2:	7fe080e7          	jalr	2046(ra) # 80002ccc <argint>
  if(argfd(0, 0, &f) < 0)
    800054d6:	fe840613          	addi	a2,s0,-24
    800054da:	4581                	li	a1,0
    800054dc:	4501                	li	a0,0
    800054de:	00000097          	auipc	ra,0x0
    800054e2:	d52080e7          	jalr	-686(ra) # 80005230 <argfd>
    800054e6:	87aa                	mv	a5,a0
    return -1;
    800054e8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054ea:	0007cc63          	bltz	a5,80005502 <sys_read+0x50>
  return fileread(f, p, n);
    800054ee:	fe442603          	lw	a2,-28(s0)
    800054f2:	fd843583          	ld	a1,-40(s0)
    800054f6:	fe843503          	ld	a0,-24(s0)
    800054fa:	fffff097          	auipc	ra,0xfffff
    800054fe:	3a8080e7          	jalr	936(ra) # 800048a2 <fileread>
}
    80005502:	70a2                	ld	ra,40(sp)
    80005504:	7402                	ld	s0,32(sp)
    80005506:	6145                	addi	sp,sp,48
    80005508:	8082                	ret

000000008000550a <sys_write>:
{
    8000550a:	7179                	addi	sp,sp,-48
    8000550c:	f406                	sd	ra,40(sp)
    8000550e:	f022                	sd	s0,32(sp)
    80005510:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005512:	fd840593          	addi	a1,s0,-40
    80005516:	4505                	li	a0,1
    80005518:	ffffd097          	auipc	ra,0xffffd
    8000551c:	7d4080e7          	jalr	2004(ra) # 80002cec <argaddr>
  argint(2, &n);
    80005520:	fe440593          	addi	a1,s0,-28
    80005524:	4509                	li	a0,2
    80005526:	ffffd097          	auipc	ra,0xffffd
    8000552a:	7a6080e7          	jalr	1958(ra) # 80002ccc <argint>
  if(argfd(0, 0, &f) < 0)
    8000552e:	fe840613          	addi	a2,s0,-24
    80005532:	4581                	li	a1,0
    80005534:	4501                	li	a0,0
    80005536:	00000097          	auipc	ra,0x0
    8000553a:	cfa080e7          	jalr	-774(ra) # 80005230 <argfd>
    8000553e:	87aa                	mv	a5,a0
    return -1;
    80005540:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005542:	0007cc63          	bltz	a5,8000555a <sys_write+0x50>
  return filewrite(f, p, n);
    80005546:	fe442603          	lw	a2,-28(s0)
    8000554a:	fd843583          	ld	a1,-40(s0)
    8000554e:	fe843503          	ld	a0,-24(s0)
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	428080e7          	jalr	1064(ra) # 8000497a <filewrite>
}
    8000555a:	70a2                	ld	ra,40(sp)
    8000555c:	7402                	ld	s0,32(sp)
    8000555e:	6145                	addi	sp,sp,48
    80005560:	8082                	ret

0000000080005562 <sys_close>:
{
    80005562:	1101                	addi	sp,sp,-32
    80005564:	ec06                	sd	ra,24(sp)
    80005566:	e822                	sd	s0,16(sp)
    80005568:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000556a:	fe040613          	addi	a2,s0,-32
    8000556e:	fec40593          	addi	a1,s0,-20
    80005572:	4501                	li	a0,0
    80005574:	00000097          	auipc	ra,0x0
    80005578:	cbc080e7          	jalr	-836(ra) # 80005230 <argfd>
    return -1;
    8000557c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000557e:	02054563          	bltz	a0,800055a8 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005582:	ffffc097          	auipc	ra,0xffffc
    80005586:	588080e7          	jalr	1416(ra) # 80001b0a <myproc>
    8000558a:	fec42783          	lw	a5,-20(s0)
    8000558e:	078e                	slli	a5,a5,0x3
    80005590:	0d078793          	addi	a5,a5,208
    80005594:	953e                	add	a0,a0,a5
    80005596:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000559a:	fe043503          	ld	a0,-32(s0)
    8000559e:	fffff097          	auipc	ra,0xfffff
    800055a2:	1ac080e7          	jalr	428(ra) # 8000474a <fileclose>
  return 0;
    800055a6:	4781                	li	a5,0
}
    800055a8:	853e                	mv	a0,a5
    800055aa:	60e2                	ld	ra,24(sp)
    800055ac:	6442                	ld	s0,16(sp)
    800055ae:	6105                	addi	sp,sp,32
    800055b0:	8082                	ret

00000000800055b2 <sys_fstat>:
{
    800055b2:	1101                	addi	sp,sp,-32
    800055b4:	ec06                	sd	ra,24(sp)
    800055b6:	e822                	sd	s0,16(sp)
    800055b8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800055ba:	fe040593          	addi	a1,s0,-32
    800055be:	4505                	li	a0,1
    800055c0:	ffffd097          	auipc	ra,0xffffd
    800055c4:	72c080e7          	jalr	1836(ra) # 80002cec <argaddr>
  if(argfd(0, 0, &f) < 0)
    800055c8:	fe840613          	addi	a2,s0,-24
    800055cc:	4581                	li	a1,0
    800055ce:	4501                	li	a0,0
    800055d0:	00000097          	auipc	ra,0x0
    800055d4:	c60080e7          	jalr	-928(ra) # 80005230 <argfd>
    800055d8:	87aa                	mv	a5,a0
    return -1;
    800055da:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055dc:	0007ca63          	bltz	a5,800055f0 <sys_fstat+0x3e>
  return filestat(f, st);
    800055e0:	fe043583          	ld	a1,-32(s0)
    800055e4:	fe843503          	ld	a0,-24(s0)
    800055e8:	fffff097          	auipc	ra,0xfffff
    800055ec:	244080e7          	jalr	580(ra) # 8000482c <filestat>
}
    800055f0:	60e2                	ld	ra,24(sp)
    800055f2:	6442                	ld	s0,16(sp)
    800055f4:	6105                	addi	sp,sp,32
    800055f6:	8082                	ret

00000000800055f8 <sys_link>:
{
    800055f8:	7169                	addi	sp,sp,-304
    800055fa:	f606                	sd	ra,296(sp)
    800055fc:	f222                	sd	s0,288(sp)
    800055fe:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005600:	08000613          	li	a2,128
    80005604:	ed040593          	addi	a1,s0,-304
    80005608:	4501                	li	a0,0
    8000560a:	ffffd097          	auipc	ra,0xffffd
    8000560e:	702080e7          	jalr	1794(ra) # 80002d0c <argstr>
    return -1;
    80005612:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005614:	12054663          	bltz	a0,80005740 <sys_link+0x148>
    80005618:	08000613          	li	a2,128
    8000561c:	f5040593          	addi	a1,s0,-176
    80005620:	4505                	li	a0,1
    80005622:	ffffd097          	auipc	ra,0xffffd
    80005626:	6ea080e7          	jalr	1770(ra) # 80002d0c <argstr>
    return -1;
    8000562a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000562c:	10054a63          	bltz	a0,80005740 <sys_link+0x148>
    80005630:	ee26                	sd	s1,280(sp)
  begin_op();
    80005632:	fffff097          	auipc	ra,0xfffff
    80005636:	c36080e7          	jalr	-970(ra) # 80004268 <begin_op>
  if((ip = namei(old)) == 0){
    8000563a:	ed040513          	addi	a0,s0,-304
    8000563e:	fffff097          	auipc	ra,0xfffff
    80005642:	a24080e7          	jalr	-1500(ra) # 80004062 <namei>
    80005646:	84aa                	mv	s1,a0
    80005648:	c949                	beqz	a0,800056da <sys_link+0xe2>
  ilock(ip);
    8000564a:	ffffe097          	auipc	ra,0xffffe
    8000564e:	22e080e7          	jalr	558(ra) # 80003878 <ilock>
  if(ip->type == T_DIR){
    80005652:	04449703          	lh	a4,68(s1)
    80005656:	4785                	li	a5,1
    80005658:	08f70863          	beq	a4,a5,800056e8 <sys_link+0xf0>
    8000565c:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000565e:	04a4d783          	lhu	a5,74(s1)
    80005662:	2785                	addiw	a5,a5,1
    80005664:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005668:	8526                	mv	a0,s1
    8000566a:	ffffe097          	auipc	ra,0xffffe
    8000566e:	142080e7          	jalr	322(ra) # 800037ac <iupdate>
  iunlock(ip);
    80005672:	8526                	mv	a0,s1
    80005674:	ffffe097          	auipc	ra,0xffffe
    80005678:	2ca080e7          	jalr	714(ra) # 8000393e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000567c:	fd040593          	addi	a1,s0,-48
    80005680:	f5040513          	addi	a0,s0,-176
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	9fc080e7          	jalr	-1540(ra) # 80004080 <nameiparent>
    8000568c:	892a                	mv	s2,a0
    8000568e:	cd35                	beqz	a0,8000570a <sys_link+0x112>
  ilock(dp);
    80005690:	ffffe097          	auipc	ra,0xffffe
    80005694:	1e8080e7          	jalr	488(ra) # 80003878 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005698:	854a                	mv	a0,s2
    8000569a:	00092703          	lw	a4,0(s2)
    8000569e:	409c                	lw	a5,0(s1)
    800056a0:	06f71063          	bne	a4,a5,80005700 <sys_link+0x108>
    800056a4:	40d0                	lw	a2,4(s1)
    800056a6:	fd040593          	addi	a1,s0,-48
    800056aa:	fffff097          	auipc	ra,0xfffff
    800056ae:	8f6080e7          	jalr	-1802(ra) # 80003fa0 <dirlink>
    800056b2:	04054763          	bltz	a0,80005700 <sys_link+0x108>
  iunlockput(dp);
    800056b6:	854a                	mv	a0,s2
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	428080e7          	jalr	1064(ra) # 80003ae0 <iunlockput>
  iput(ip);
    800056c0:	8526                	mv	a0,s1
    800056c2:	ffffe097          	auipc	ra,0xffffe
    800056c6:	374080e7          	jalr	884(ra) # 80003a36 <iput>
  end_op();
    800056ca:	fffff097          	auipc	ra,0xfffff
    800056ce:	c1e080e7          	jalr	-994(ra) # 800042e8 <end_op>
  return 0;
    800056d2:	4781                	li	a5,0
    800056d4:	64f2                	ld	s1,280(sp)
    800056d6:	6952                	ld	s2,272(sp)
    800056d8:	a0a5                	j	80005740 <sys_link+0x148>
    end_op();
    800056da:	fffff097          	auipc	ra,0xfffff
    800056de:	c0e080e7          	jalr	-1010(ra) # 800042e8 <end_op>
    return -1;
    800056e2:	57fd                	li	a5,-1
    800056e4:	64f2                	ld	s1,280(sp)
    800056e6:	a8a9                	j	80005740 <sys_link+0x148>
    iunlockput(ip);
    800056e8:	8526                	mv	a0,s1
    800056ea:	ffffe097          	auipc	ra,0xffffe
    800056ee:	3f6080e7          	jalr	1014(ra) # 80003ae0 <iunlockput>
    end_op();
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	bf6080e7          	jalr	-1034(ra) # 800042e8 <end_op>
    return -1;
    800056fa:	57fd                	li	a5,-1
    800056fc:	64f2                	ld	s1,280(sp)
    800056fe:	a089                	j	80005740 <sys_link+0x148>
    iunlockput(dp);
    80005700:	854a                	mv	a0,s2
    80005702:	ffffe097          	auipc	ra,0xffffe
    80005706:	3de080e7          	jalr	990(ra) # 80003ae0 <iunlockput>
  ilock(ip);
    8000570a:	8526                	mv	a0,s1
    8000570c:	ffffe097          	auipc	ra,0xffffe
    80005710:	16c080e7          	jalr	364(ra) # 80003878 <ilock>
  ip->nlink--;
    80005714:	04a4d783          	lhu	a5,74(s1)
    80005718:	37fd                	addiw	a5,a5,-1
    8000571a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000571e:	8526                	mv	a0,s1
    80005720:	ffffe097          	auipc	ra,0xffffe
    80005724:	08c080e7          	jalr	140(ra) # 800037ac <iupdate>
  iunlockput(ip);
    80005728:	8526                	mv	a0,s1
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	3b6080e7          	jalr	950(ra) # 80003ae0 <iunlockput>
  end_op();
    80005732:	fffff097          	auipc	ra,0xfffff
    80005736:	bb6080e7          	jalr	-1098(ra) # 800042e8 <end_op>
  return -1;
    8000573a:	57fd                	li	a5,-1
    8000573c:	64f2                	ld	s1,280(sp)
    8000573e:	6952                	ld	s2,272(sp)
}
    80005740:	853e                	mv	a0,a5
    80005742:	70b2                	ld	ra,296(sp)
    80005744:	7412                	ld	s0,288(sp)
    80005746:	6155                	addi	sp,sp,304
    80005748:	8082                	ret

000000008000574a <sys_unlink>:
{
    8000574a:	7151                	addi	sp,sp,-240
    8000574c:	f586                	sd	ra,232(sp)
    8000574e:	f1a2                	sd	s0,224(sp)
    80005750:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005752:	08000613          	li	a2,128
    80005756:	f3040593          	addi	a1,s0,-208
    8000575a:	4501                	li	a0,0
    8000575c:	ffffd097          	auipc	ra,0xffffd
    80005760:	5b0080e7          	jalr	1456(ra) # 80002d0c <argstr>
    80005764:	1a054763          	bltz	a0,80005912 <sys_unlink+0x1c8>
    80005768:	eda6                	sd	s1,216(sp)
  begin_op();
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	afe080e7          	jalr	-1282(ra) # 80004268 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005772:	fb040593          	addi	a1,s0,-80
    80005776:	f3040513          	addi	a0,s0,-208
    8000577a:	fffff097          	auipc	ra,0xfffff
    8000577e:	906080e7          	jalr	-1786(ra) # 80004080 <nameiparent>
    80005782:	84aa                	mv	s1,a0
    80005784:	c165                	beqz	a0,80005864 <sys_unlink+0x11a>
  ilock(dp);
    80005786:	ffffe097          	auipc	ra,0xffffe
    8000578a:	0f2080e7          	jalr	242(ra) # 80003878 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000578e:	00003597          	auipc	a1,0x3
    80005792:	e4a58593          	addi	a1,a1,-438 # 800085d8 <etext+0x5d8>
    80005796:	fb040513          	addi	a0,s0,-80
    8000579a:	ffffe097          	auipc	ra,0xffffe
    8000579e:	5be080e7          	jalr	1470(ra) # 80003d58 <namecmp>
    800057a2:	14050963          	beqz	a0,800058f4 <sys_unlink+0x1aa>
    800057a6:	00003597          	auipc	a1,0x3
    800057aa:	e3a58593          	addi	a1,a1,-454 # 800085e0 <etext+0x5e0>
    800057ae:	fb040513          	addi	a0,s0,-80
    800057b2:	ffffe097          	auipc	ra,0xffffe
    800057b6:	5a6080e7          	jalr	1446(ra) # 80003d58 <namecmp>
    800057ba:	12050d63          	beqz	a0,800058f4 <sys_unlink+0x1aa>
    800057be:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057c0:	f2c40613          	addi	a2,s0,-212
    800057c4:	fb040593          	addi	a1,s0,-80
    800057c8:	8526                	mv	a0,s1
    800057ca:	ffffe097          	auipc	ra,0xffffe
    800057ce:	5a8080e7          	jalr	1448(ra) # 80003d72 <dirlookup>
    800057d2:	892a                	mv	s2,a0
    800057d4:	10050f63          	beqz	a0,800058f2 <sys_unlink+0x1a8>
    800057d8:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800057da:	ffffe097          	auipc	ra,0xffffe
    800057de:	09e080e7          	jalr	158(ra) # 80003878 <ilock>
  if(ip->nlink < 1)
    800057e2:	04a91783          	lh	a5,74(s2)
    800057e6:	08f05663          	blez	a5,80005872 <sys_unlink+0x128>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057ea:	04491703          	lh	a4,68(s2)
    800057ee:	4785                	li	a5,1
    800057f0:	08f70963          	beq	a4,a5,80005882 <sys_unlink+0x138>
  memset(&de, 0, sizeof(de));
    800057f4:	fc040993          	addi	s3,s0,-64
    800057f8:	4641                	li	a2,16
    800057fa:	4581                	li	a1,0
    800057fc:	854e                	mv	a0,s3
    800057fe:	ffffb097          	auipc	ra,0xffffb
    80005802:	556080e7          	jalr	1366(ra) # 80000d54 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005806:	4741                	li	a4,16
    80005808:	f2c42683          	lw	a3,-212(s0)
    8000580c:	864e                	mv	a2,s3
    8000580e:	4581                	li	a1,0
    80005810:	8526                	mv	a0,s1
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	42a080e7          	jalr	1066(ra) # 80003c3c <writei>
    8000581a:	47c1                	li	a5,16
    8000581c:	0af51863          	bne	a0,a5,800058cc <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005820:	04491703          	lh	a4,68(s2)
    80005824:	4785                	li	a5,1
    80005826:	0af70b63          	beq	a4,a5,800058dc <sys_unlink+0x192>
  iunlockput(dp);
    8000582a:	8526                	mv	a0,s1
    8000582c:	ffffe097          	auipc	ra,0xffffe
    80005830:	2b4080e7          	jalr	692(ra) # 80003ae0 <iunlockput>
  ip->nlink--;
    80005834:	04a95783          	lhu	a5,74(s2)
    80005838:	37fd                	addiw	a5,a5,-1
    8000583a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000583e:	854a                	mv	a0,s2
    80005840:	ffffe097          	auipc	ra,0xffffe
    80005844:	f6c080e7          	jalr	-148(ra) # 800037ac <iupdate>
  iunlockput(ip);
    80005848:	854a                	mv	a0,s2
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	296080e7          	jalr	662(ra) # 80003ae0 <iunlockput>
  end_op();
    80005852:	fffff097          	auipc	ra,0xfffff
    80005856:	a96080e7          	jalr	-1386(ra) # 800042e8 <end_op>
  return 0;
    8000585a:	4501                	li	a0,0
    8000585c:	64ee                	ld	s1,216(sp)
    8000585e:	694e                	ld	s2,208(sp)
    80005860:	69ae                	ld	s3,200(sp)
    80005862:	a065                	j	8000590a <sys_unlink+0x1c0>
    end_op();
    80005864:	fffff097          	auipc	ra,0xfffff
    80005868:	a84080e7          	jalr	-1404(ra) # 800042e8 <end_op>
    return -1;
    8000586c:	557d                	li	a0,-1
    8000586e:	64ee                	ld	s1,216(sp)
    80005870:	a869                	j	8000590a <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    80005872:	00003517          	auipc	a0,0x3
    80005876:	d7650513          	addi	a0,a0,-650 # 800085e8 <etext+0x5e8>
    8000587a:	ffffb097          	auipc	ra,0xffffb
    8000587e:	ce4080e7          	jalr	-796(ra) # 8000055e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005882:	04c92703          	lw	a4,76(s2)
    80005886:	02000793          	li	a5,32
    8000588a:	f6e7f5e3          	bgeu	a5,a4,800057f4 <sys_unlink+0xaa>
    8000588e:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005890:	4741                	li	a4,16
    80005892:	86ce                	mv	a3,s3
    80005894:	f1840613          	addi	a2,s0,-232
    80005898:	4581                	li	a1,0
    8000589a:	854a                	mv	a0,s2
    8000589c:	ffffe097          	auipc	ra,0xffffe
    800058a0:	29a080e7          	jalr	666(ra) # 80003b36 <readi>
    800058a4:	47c1                	li	a5,16
    800058a6:	00f51b63          	bne	a0,a5,800058bc <sys_unlink+0x172>
    if(de.inum != 0)
    800058aa:	f1845783          	lhu	a5,-232(s0)
    800058ae:	e7a5                	bnez	a5,80005916 <sys_unlink+0x1cc>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058b0:	29c1                	addiw	s3,s3,16
    800058b2:	04c92783          	lw	a5,76(s2)
    800058b6:	fcf9ede3          	bltu	s3,a5,80005890 <sys_unlink+0x146>
    800058ba:	bf2d                	j	800057f4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058bc:	00003517          	auipc	a0,0x3
    800058c0:	d4450513          	addi	a0,a0,-700 # 80008600 <etext+0x600>
    800058c4:	ffffb097          	auipc	ra,0xffffb
    800058c8:	c9a080e7          	jalr	-870(ra) # 8000055e <panic>
    panic("unlink: writei");
    800058cc:	00003517          	auipc	a0,0x3
    800058d0:	d4c50513          	addi	a0,a0,-692 # 80008618 <etext+0x618>
    800058d4:	ffffb097          	auipc	ra,0xffffb
    800058d8:	c8a080e7          	jalr	-886(ra) # 8000055e <panic>
    dp->nlink--;
    800058dc:	04a4d783          	lhu	a5,74(s1)
    800058e0:	37fd                	addiw	a5,a5,-1
    800058e2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058e6:	8526                	mv	a0,s1
    800058e8:	ffffe097          	auipc	ra,0xffffe
    800058ec:	ec4080e7          	jalr	-316(ra) # 800037ac <iupdate>
    800058f0:	bf2d                	j	8000582a <sys_unlink+0xe0>
    800058f2:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800058f4:	8526                	mv	a0,s1
    800058f6:	ffffe097          	auipc	ra,0xffffe
    800058fa:	1ea080e7          	jalr	490(ra) # 80003ae0 <iunlockput>
  end_op();
    800058fe:	fffff097          	auipc	ra,0xfffff
    80005902:	9ea080e7          	jalr	-1558(ra) # 800042e8 <end_op>
  return -1;
    80005906:	557d                	li	a0,-1
    80005908:	64ee                	ld	s1,216(sp)
}
    8000590a:	70ae                	ld	ra,232(sp)
    8000590c:	740e                	ld	s0,224(sp)
    8000590e:	616d                	addi	sp,sp,240
    80005910:	8082                	ret
    return -1;
    80005912:	557d                	li	a0,-1
    80005914:	bfdd                	j	8000590a <sys_unlink+0x1c0>
    iunlockput(ip);
    80005916:	854a                	mv	a0,s2
    80005918:	ffffe097          	auipc	ra,0xffffe
    8000591c:	1c8080e7          	jalr	456(ra) # 80003ae0 <iunlockput>
    goto bad;
    80005920:	694e                	ld	s2,208(sp)
    80005922:	69ae                	ld	s3,200(sp)
    80005924:	bfc1                	j	800058f4 <sys_unlink+0x1aa>

0000000080005926 <sys_open>:

uint64
sys_open(void)
{
    80005926:	7131                	addi	sp,sp,-192
    80005928:	fd06                	sd	ra,184(sp)
    8000592a:	f922                	sd	s0,176(sp)
    8000592c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000592e:	f4c40593          	addi	a1,s0,-180
    80005932:	4505                	li	a0,1
    80005934:	ffffd097          	auipc	ra,0xffffd
    80005938:	398080e7          	jalr	920(ra) # 80002ccc <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000593c:	08000613          	li	a2,128
    80005940:	f5040593          	addi	a1,s0,-176
    80005944:	4501                	li	a0,0
    80005946:	ffffd097          	auipc	ra,0xffffd
    8000594a:	3c6080e7          	jalr	966(ra) # 80002d0c <argstr>
    8000594e:	87aa                	mv	a5,a0
    return -1;
    80005950:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005952:	0a07cf63          	bltz	a5,80005a10 <sys_open+0xea>
    80005956:	f526                	sd	s1,168(sp)

  begin_op();
    80005958:	fffff097          	auipc	ra,0xfffff
    8000595c:	910080e7          	jalr	-1776(ra) # 80004268 <begin_op>

  if(omode & O_CREATE){
    80005960:	f4c42783          	lw	a5,-180(s0)
    80005964:	2007f793          	andi	a5,a5,512
    80005968:	cfdd                	beqz	a5,80005a26 <sys_open+0x100>
    ip = create(path, T_FILE, 0, 0);
    8000596a:	4681                	li	a3,0
    8000596c:	4601                	li	a2,0
    8000596e:	4589                	li	a1,2
    80005970:	f5040513          	addi	a0,s0,-176
    80005974:	00000097          	auipc	ra,0x0
    80005978:	962080e7          	jalr	-1694(ra) # 800052d6 <create>
    8000597c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000597e:	cd49                	beqz	a0,80005a18 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005980:	04449703          	lh	a4,68(s1)
    80005984:	478d                	li	a5,3
    80005986:	00f71763          	bne	a4,a5,80005994 <sys_open+0x6e>
    8000598a:	0464d703          	lhu	a4,70(s1)
    8000598e:	47a5                	li	a5,9
    80005990:	0ee7e263          	bltu	a5,a4,80005a74 <sys_open+0x14e>
    80005994:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005996:	fffff097          	auipc	ra,0xfffff
    8000599a:	cf8080e7          	jalr	-776(ra) # 8000468e <filealloc>
    8000599e:	892a                	mv	s2,a0
    800059a0:	cd65                	beqz	a0,80005a98 <sys_open+0x172>
    800059a2:	ed4e                	sd	s3,152(sp)
    800059a4:	00000097          	auipc	ra,0x0
    800059a8:	8ee080e7          	jalr	-1810(ra) # 80005292 <fdalloc>
    800059ac:	89aa                	mv	s3,a0
    800059ae:	0c054f63          	bltz	a0,80005a8c <sys_open+0x166>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059b2:	04449703          	lh	a4,68(s1)
    800059b6:	478d                	li	a5,3
    800059b8:	0ef70d63          	beq	a4,a5,80005ab2 <sys_open+0x18c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059bc:	4789                	li	a5,2
    800059be:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800059c2:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800059c6:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800059ca:	f4c42783          	lw	a5,-180(s0)
    800059ce:	0017f713          	andi	a4,a5,1
    800059d2:	00174713          	xori	a4,a4,1
    800059d6:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059da:	0037f713          	andi	a4,a5,3
    800059de:	00e03733          	snez	a4,a4
    800059e2:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059e6:	4007f793          	andi	a5,a5,1024
    800059ea:	c791                	beqz	a5,800059f6 <sys_open+0xd0>
    800059ec:	04449703          	lh	a4,68(s1)
    800059f0:	4789                	li	a5,2
    800059f2:	0cf70763          	beq	a4,a5,80005ac0 <sys_open+0x19a>
    itrunc(ip);
  }

  iunlock(ip);
    800059f6:	8526                	mv	a0,s1
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	f46080e7          	jalr	-186(ra) # 8000393e <iunlock>
  end_op();
    80005a00:	fffff097          	auipc	ra,0xfffff
    80005a04:	8e8080e7          	jalr	-1816(ra) # 800042e8 <end_op>

  return fd;
    80005a08:	854e                	mv	a0,s3
    80005a0a:	74aa                	ld	s1,168(sp)
    80005a0c:	790a                	ld	s2,160(sp)
    80005a0e:	69ea                	ld	s3,152(sp)
}
    80005a10:	70ea                	ld	ra,184(sp)
    80005a12:	744a                	ld	s0,176(sp)
    80005a14:	6129                	addi	sp,sp,192
    80005a16:	8082                	ret
      end_op();
    80005a18:	fffff097          	auipc	ra,0xfffff
    80005a1c:	8d0080e7          	jalr	-1840(ra) # 800042e8 <end_op>
      return -1;
    80005a20:	557d                	li	a0,-1
    80005a22:	74aa                	ld	s1,168(sp)
    80005a24:	b7f5                	j	80005a10 <sys_open+0xea>
    if((ip = namei(path)) == 0){
    80005a26:	f5040513          	addi	a0,s0,-176
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	638080e7          	jalr	1592(ra) # 80004062 <namei>
    80005a32:	84aa                	mv	s1,a0
    80005a34:	c90d                	beqz	a0,80005a66 <sys_open+0x140>
    ilock(ip);
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	e42080e7          	jalr	-446(ra) # 80003878 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a3e:	04449703          	lh	a4,68(s1)
    80005a42:	4785                	li	a5,1
    80005a44:	f2f71ee3          	bne	a4,a5,80005980 <sys_open+0x5a>
    80005a48:	f4c42783          	lw	a5,-180(s0)
    80005a4c:	d7a1                	beqz	a5,80005994 <sys_open+0x6e>
      iunlockput(ip);
    80005a4e:	8526                	mv	a0,s1
    80005a50:	ffffe097          	auipc	ra,0xffffe
    80005a54:	090080e7          	jalr	144(ra) # 80003ae0 <iunlockput>
      end_op();
    80005a58:	fffff097          	auipc	ra,0xfffff
    80005a5c:	890080e7          	jalr	-1904(ra) # 800042e8 <end_op>
      return -1;
    80005a60:	557d                	li	a0,-1
    80005a62:	74aa                	ld	s1,168(sp)
    80005a64:	b775                	j	80005a10 <sys_open+0xea>
      end_op();
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	882080e7          	jalr	-1918(ra) # 800042e8 <end_op>
      return -1;
    80005a6e:	557d                	li	a0,-1
    80005a70:	74aa                	ld	s1,168(sp)
    80005a72:	bf79                	j	80005a10 <sys_open+0xea>
    iunlockput(ip);
    80005a74:	8526                	mv	a0,s1
    80005a76:	ffffe097          	auipc	ra,0xffffe
    80005a7a:	06a080e7          	jalr	106(ra) # 80003ae0 <iunlockput>
    end_op();
    80005a7e:	fffff097          	auipc	ra,0xfffff
    80005a82:	86a080e7          	jalr	-1942(ra) # 800042e8 <end_op>
    return -1;
    80005a86:	557d                	li	a0,-1
    80005a88:	74aa                	ld	s1,168(sp)
    80005a8a:	b759                	j	80005a10 <sys_open+0xea>
      fileclose(f);
    80005a8c:	854a                	mv	a0,s2
    80005a8e:	fffff097          	auipc	ra,0xfffff
    80005a92:	cbc080e7          	jalr	-836(ra) # 8000474a <fileclose>
    80005a96:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005a98:	8526                	mv	a0,s1
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	046080e7          	jalr	70(ra) # 80003ae0 <iunlockput>
    end_op();
    80005aa2:	fffff097          	auipc	ra,0xfffff
    80005aa6:	846080e7          	jalr	-1978(ra) # 800042e8 <end_op>
    return -1;
    80005aaa:	557d                	li	a0,-1
    80005aac:	74aa                	ld	s1,168(sp)
    80005aae:	790a                	ld	s2,160(sp)
    80005ab0:	b785                	j	80005a10 <sys_open+0xea>
    f->type = FD_DEVICE;
    80005ab2:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005ab6:	04649783          	lh	a5,70(s1)
    80005aba:	02f91223          	sh	a5,36(s2)
    80005abe:	b721                	j	800059c6 <sys_open+0xa0>
    itrunc(ip);
    80005ac0:	8526                	mv	a0,s1
    80005ac2:	ffffe097          	auipc	ra,0xffffe
    80005ac6:	ec8080e7          	jalr	-312(ra) # 8000398a <itrunc>
    80005aca:	b735                	j	800059f6 <sys_open+0xd0>

0000000080005acc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005acc:	7175                	addi	sp,sp,-144
    80005ace:	e506                	sd	ra,136(sp)
    80005ad0:	e122                	sd	s0,128(sp)
    80005ad2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	794080e7          	jalr	1940(ra) # 80004268 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005adc:	08000613          	li	a2,128
    80005ae0:	f7040593          	addi	a1,s0,-144
    80005ae4:	4501                	li	a0,0
    80005ae6:	ffffd097          	auipc	ra,0xffffd
    80005aea:	226080e7          	jalr	550(ra) # 80002d0c <argstr>
    80005aee:	02054963          	bltz	a0,80005b20 <sys_mkdir+0x54>
    80005af2:	4681                	li	a3,0
    80005af4:	4601                	li	a2,0
    80005af6:	4585                	li	a1,1
    80005af8:	f7040513          	addi	a0,s0,-144
    80005afc:	fffff097          	auipc	ra,0xfffff
    80005b00:	7da080e7          	jalr	2010(ra) # 800052d6 <create>
    80005b04:	cd11                	beqz	a0,80005b20 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b06:	ffffe097          	auipc	ra,0xffffe
    80005b0a:	fda080e7          	jalr	-38(ra) # 80003ae0 <iunlockput>
  end_op();
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	7da080e7          	jalr	2010(ra) # 800042e8 <end_op>
  return 0;
    80005b16:	4501                	li	a0,0
}
    80005b18:	60aa                	ld	ra,136(sp)
    80005b1a:	640a                	ld	s0,128(sp)
    80005b1c:	6149                	addi	sp,sp,144
    80005b1e:	8082                	ret
    end_op();
    80005b20:	ffffe097          	auipc	ra,0xffffe
    80005b24:	7c8080e7          	jalr	1992(ra) # 800042e8 <end_op>
    return -1;
    80005b28:	557d                	li	a0,-1
    80005b2a:	b7fd                	j	80005b18 <sys_mkdir+0x4c>

0000000080005b2c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b2c:	7135                	addi	sp,sp,-160
    80005b2e:	ed06                	sd	ra,152(sp)
    80005b30:	e922                	sd	s0,144(sp)
    80005b32:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b34:	ffffe097          	auipc	ra,0xffffe
    80005b38:	734080e7          	jalr	1844(ra) # 80004268 <begin_op>
  argint(1, &major);
    80005b3c:	f6c40593          	addi	a1,s0,-148
    80005b40:	4505                	li	a0,1
    80005b42:	ffffd097          	auipc	ra,0xffffd
    80005b46:	18a080e7          	jalr	394(ra) # 80002ccc <argint>
  argint(2, &minor);
    80005b4a:	f6840593          	addi	a1,s0,-152
    80005b4e:	4509                	li	a0,2
    80005b50:	ffffd097          	auipc	ra,0xffffd
    80005b54:	17c080e7          	jalr	380(ra) # 80002ccc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b58:	08000613          	li	a2,128
    80005b5c:	f7040593          	addi	a1,s0,-144
    80005b60:	4501                	li	a0,0
    80005b62:	ffffd097          	auipc	ra,0xffffd
    80005b66:	1aa080e7          	jalr	426(ra) # 80002d0c <argstr>
    80005b6a:	02054b63          	bltz	a0,80005ba0 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b6e:	f6841683          	lh	a3,-152(s0)
    80005b72:	f6c41603          	lh	a2,-148(s0)
    80005b76:	458d                	li	a1,3
    80005b78:	f7040513          	addi	a0,s0,-144
    80005b7c:	fffff097          	auipc	ra,0xfffff
    80005b80:	75a080e7          	jalr	1882(ra) # 800052d6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b84:	cd11                	beqz	a0,80005ba0 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b86:	ffffe097          	auipc	ra,0xffffe
    80005b8a:	f5a080e7          	jalr	-166(ra) # 80003ae0 <iunlockput>
  end_op();
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	75a080e7          	jalr	1882(ra) # 800042e8 <end_op>
  return 0;
    80005b96:	4501                	li	a0,0
}
    80005b98:	60ea                	ld	ra,152(sp)
    80005b9a:	644a                	ld	s0,144(sp)
    80005b9c:	610d                	addi	sp,sp,160
    80005b9e:	8082                	ret
    end_op();
    80005ba0:	ffffe097          	auipc	ra,0xffffe
    80005ba4:	748080e7          	jalr	1864(ra) # 800042e8 <end_op>
    return -1;
    80005ba8:	557d                	li	a0,-1
    80005baa:	b7fd                	j	80005b98 <sys_mknod+0x6c>

0000000080005bac <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bac:	7135                	addi	sp,sp,-160
    80005bae:	ed06                	sd	ra,152(sp)
    80005bb0:	e922                	sd	s0,144(sp)
    80005bb2:	e14a                	sd	s2,128(sp)
    80005bb4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bb6:	ffffc097          	auipc	ra,0xffffc
    80005bba:	f54080e7          	jalr	-172(ra) # 80001b0a <myproc>
    80005bbe:	892a                	mv	s2,a0
  
  begin_op();
    80005bc0:	ffffe097          	auipc	ra,0xffffe
    80005bc4:	6a8080e7          	jalr	1704(ra) # 80004268 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bc8:	08000613          	li	a2,128
    80005bcc:	f6040593          	addi	a1,s0,-160
    80005bd0:	4501                	li	a0,0
    80005bd2:	ffffd097          	auipc	ra,0xffffd
    80005bd6:	13a080e7          	jalr	314(ra) # 80002d0c <argstr>
    80005bda:	04054d63          	bltz	a0,80005c34 <sys_chdir+0x88>
    80005bde:	e526                	sd	s1,136(sp)
    80005be0:	f6040513          	addi	a0,s0,-160
    80005be4:	ffffe097          	auipc	ra,0xffffe
    80005be8:	47e080e7          	jalr	1150(ra) # 80004062 <namei>
    80005bec:	84aa                	mv	s1,a0
    80005bee:	c131                	beqz	a0,80005c32 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bf0:	ffffe097          	auipc	ra,0xffffe
    80005bf4:	c88080e7          	jalr	-888(ra) # 80003878 <ilock>
  if(ip->type != T_DIR){
    80005bf8:	04449703          	lh	a4,68(s1)
    80005bfc:	4785                	li	a5,1
    80005bfe:	04f71163          	bne	a4,a5,80005c40 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c02:	8526                	mv	a0,s1
    80005c04:	ffffe097          	auipc	ra,0xffffe
    80005c08:	d3a080e7          	jalr	-710(ra) # 8000393e <iunlock>
  iput(p->cwd);
    80005c0c:	15093503          	ld	a0,336(s2)
    80005c10:	ffffe097          	auipc	ra,0xffffe
    80005c14:	e26080e7          	jalr	-474(ra) # 80003a36 <iput>
  end_op();
    80005c18:	ffffe097          	auipc	ra,0xffffe
    80005c1c:	6d0080e7          	jalr	1744(ra) # 800042e8 <end_op>
  p->cwd = ip;
    80005c20:	14993823          	sd	s1,336(s2)
  return 0;
    80005c24:	4501                	li	a0,0
    80005c26:	64aa                	ld	s1,136(sp)
}
    80005c28:	60ea                	ld	ra,152(sp)
    80005c2a:	644a                	ld	s0,144(sp)
    80005c2c:	690a                	ld	s2,128(sp)
    80005c2e:	610d                	addi	sp,sp,160
    80005c30:	8082                	ret
    80005c32:	64aa                	ld	s1,136(sp)
    end_op();
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	6b4080e7          	jalr	1716(ra) # 800042e8 <end_op>
    return -1;
    80005c3c:	557d                	li	a0,-1
    80005c3e:	b7ed                	j	80005c28 <sys_chdir+0x7c>
    iunlockput(ip);
    80005c40:	8526                	mv	a0,s1
    80005c42:	ffffe097          	auipc	ra,0xffffe
    80005c46:	e9e080e7          	jalr	-354(ra) # 80003ae0 <iunlockput>
    end_op();
    80005c4a:	ffffe097          	auipc	ra,0xffffe
    80005c4e:	69e080e7          	jalr	1694(ra) # 800042e8 <end_op>
    return -1;
    80005c52:	557d                	li	a0,-1
    80005c54:	64aa                	ld	s1,136(sp)
    80005c56:	bfc9                	j	80005c28 <sys_chdir+0x7c>

0000000080005c58 <sys_exec>:

uint64
sys_exec(void)
{
    80005c58:	7105                	addi	sp,sp,-480
    80005c5a:	ef86                	sd	ra,472(sp)
    80005c5c:	eba2                	sd	s0,464(sp)
    80005c5e:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c60:	e2840593          	addi	a1,s0,-472
    80005c64:	4505                	li	a0,1
    80005c66:	ffffd097          	auipc	ra,0xffffd
    80005c6a:	086080e7          	jalr	134(ra) # 80002cec <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c6e:	08000613          	li	a2,128
    80005c72:	f3040593          	addi	a1,s0,-208
    80005c76:	4501                	li	a0,0
    80005c78:	ffffd097          	auipc	ra,0xffffd
    80005c7c:	094080e7          	jalr	148(ra) # 80002d0c <argstr>
    80005c80:	87aa                	mv	a5,a0
    return -1;
    80005c82:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c84:	0e07ce63          	bltz	a5,80005d80 <sys_exec+0x128>
    80005c88:	e7a6                	sd	s1,456(sp)
    80005c8a:	e3ca                	sd	s2,448(sp)
    80005c8c:	ff4e                	sd	s3,440(sp)
    80005c8e:	fb52                	sd	s4,432(sp)
    80005c90:	f756                	sd	s5,424(sp)
    80005c92:	f35a                	sd	s6,416(sp)
    80005c94:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005c96:	e3040a13          	addi	s4,s0,-464
    80005c9a:	10000613          	li	a2,256
    80005c9e:	4581                	li	a1,0
    80005ca0:	8552                	mv	a0,s4
    80005ca2:	ffffb097          	auipc	ra,0xffffb
    80005ca6:	0b2080e7          	jalr	178(ra) # 80000d54 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005caa:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005cac:	89d2                	mv	s3,s4
    80005cae:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cb0:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cb4:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005cb6:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cba:	00391513          	slli	a0,s2,0x3
    80005cbe:	85d6                	mv	a1,s5
    80005cc0:	e2843783          	ld	a5,-472(s0)
    80005cc4:	953e                	add	a0,a0,a5
    80005cc6:	ffffd097          	auipc	ra,0xffffd
    80005cca:	f68080e7          	jalr	-152(ra) # 80002c2e <fetchaddr>
    80005cce:	02054a63          	bltz	a0,80005d02 <sys_exec+0xaa>
    if(uarg == 0){
    80005cd2:	e2043783          	ld	a5,-480(s0)
    80005cd6:	cbb1                	beqz	a5,80005d2a <sys_exec+0xd2>
    argv[i] = kalloc();
    80005cd8:	ffffb097          	auipc	ra,0xffffb
    80005cdc:	e80080e7          	jalr	-384(ra) # 80000b58 <kalloc>
    80005ce0:	85aa                	mv	a1,a0
    80005ce2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ce6:	cd11                	beqz	a0,80005d02 <sys_exec+0xaa>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ce8:	865a                	mv	a2,s6
    80005cea:	e2043503          	ld	a0,-480(s0)
    80005cee:	ffffd097          	auipc	ra,0xffffd
    80005cf2:	f92080e7          	jalr	-110(ra) # 80002c80 <fetchstr>
    80005cf6:	00054663          	bltz	a0,80005d02 <sys_exec+0xaa>
    if(i >= NELEM(argv)){
    80005cfa:	0905                	addi	s2,s2,1
    80005cfc:	09a1                	addi	s3,s3,8
    80005cfe:	fb791ee3          	bne	s2,s7,80005cba <sys_exec+0x62>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d02:	100a0a13          	addi	s4,s4,256
    80005d06:	6088                	ld	a0,0(s1)
    80005d08:	c525                	beqz	a0,80005d70 <sys_exec+0x118>
    kfree(argv[i]);
    80005d0a:	ffffb097          	auipc	ra,0xffffb
    80005d0e:	d4a080e7          	jalr	-694(ra) # 80000a54 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d12:	04a1                	addi	s1,s1,8
    80005d14:	ff4499e3          	bne	s1,s4,80005d06 <sys_exec+0xae>
  return -1;
    80005d18:	557d                	li	a0,-1
    80005d1a:	64be                	ld	s1,456(sp)
    80005d1c:	691e                	ld	s2,448(sp)
    80005d1e:	79fa                	ld	s3,440(sp)
    80005d20:	7a5a                	ld	s4,432(sp)
    80005d22:	7aba                	ld	s5,424(sp)
    80005d24:	7b1a                	ld	s6,416(sp)
    80005d26:	6bfa                	ld	s7,408(sp)
    80005d28:	a8a1                	j	80005d80 <sys_exec+0x128>
      argv[i] = 0;
    80005d2a:	0009079b          	sext.w	a5,s2
    80005d2e:	e3040593          	addi	a1,s0,-464
    80005d32:	078e                	slli	a5,a5,0x3
    80005d34:	97ae                	add	a5,a5,a1
    80005d36:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    80005d3a:	f3040513          	addi	a0,s0,-208
    80005d3e:	fffff097          	auipc	ra,0xfffff
    80005d42:	126080e7          	jalr	294(ra) # 80004e64 <exec>
    80005d46:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d48:	100a0a13          	addi	s4,s4,256
    80005d4c:	6088                	ld	a0,0(s1)
    80005d4e:	c901                	beqz	a0,80005d5e <sys_exec+0x106>
    kfree(argv[i]);
    80005d50:	ffffb097          	auipc	ra,0xffffb
    80005d54:	d04080e7          	jalr	-764(ra) # 80000a54 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d58:	04a1                	addi	s1,s1,8
    80005d5a:	ff4499e3          	bne	s1,s4,80005d4c <sys_exec+0xf4>
  return ret;
    80005d5e:	854a                	mv	a0,s2
    80005d60:	64be                	ld	s1,456(sp)
    80005d62:	691e                	ld	s2,448(sp)
    80005d64:	79fa                	ld	s3,440(sp)
    80005d66:	7a5a                	ld	s4,432(sp)
    80005d68:	7aba                	ld	s5,424(sp)
    80005d6a:	7b1a                	ld	s6,416(sp)
    80005d6c:	6bfa                	ld	s7,408(sp)
    80005d6e:	a809                	j	80005d80 <sys_exec+0x128>
  return -1;
    80005d70:	557d                	li	a0,-1
    80005d72:	64be                	ld	s1,456(sp)
    80005d74:	691e                	ld	s2,448(sp)
    80005d76:	79fa                	ld	s3,440(sp)
    80005d78:	7a5a                	ld	s4,432(sp)
    80005d7a:	7aba                	ld	s5,424(sp)
    80005d7c:	7b1a                	ld	s6,416(sp)
    80005d7e:	6bfa                	ld	s7,408(sp)
}
    80005d80:	60fe                	ld	ra,472(sp)
    80005d82:	645e                	ld	s0,464(sp)
    80005d84:	613d                	addi	sp,sp,480
    80005d86:	8082                	ret

0000000080005d88 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d88:	7139                	addi	sp,sp,-64
    80005d8a:	fc06                	sd	ra,56(sp)
    80005d8c:	f822                	sd	s0,48(sp)
    80005d8e:	f426                	sd	s1,40(sp)
    80005d90:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d92:	ffffc097          	auipc	ra,0xffffc
    80005d96:	d78080e7          	jalr	-648(ra) # 80001b0a <myproc>
    80005d9a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d9c:	fd840593          	addi	a1,s0,-40
    80005da0:	4501                	li	a0,0
    80005da2:	ffffd097          	auipc	ra,0xffffd
    80005da6:	f4a080e7          	jalr	-182(ra) # 80002cec <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005daa:	fc840593          	addi	a1,s0,-56
    80005dae:	fd040513          	addi	a0,s0,-48
    80005db2:	fffff097          	auipc	ra,0xfffff
    80005db6:	d18080e7          	jalr	-744(ra) # 80004aca <pipealloc>
    return -1;
    80005dba:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005dbc:	0c054763          	bltz	a0,80005e8a <sys_pipe+0x102>
  fd0 = -1;
    80005dc0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005dc4:	fd043503          	ld	a0,-48(s0)
    80005dc8:	fffff097          	auipc	ra,0xfffff
    80005dcc:	4ca080e7          	jalr	1226(ra) # 80005292 <fdalloc>
    80005dd0:	fca42223          	sw	a0,-60(s0)
    80005dd4:	08054e63          	bltz	a0,80005e70 <sys_pipe+0xe8>
    80005dd8:	fc843503          	ld	a0,-56(s0)
    80005ddc:	fffff097          	auipc	ra,0xfffff
    80005de0:	4b6080e7          	jalr	1206(ra) # 80005292 <fdalloc>
    80005de4:	fca42023          	sw	a0,-64(s0)
    80005de8:	06054a63          	bltz	a0,80005e5c <sys_pipe+0xd4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dec:	4691                	li	a3,4
    80005dee:	fc440613          	addi	a2,s0,-60
    80005df2:	fd843583          	ld	a1,-40(s0)
    80005df6:	68a8                	ld	a0,80(s1)
    80005df8:	ffffc097          	auipc	ra,0xffffc
    80005dfc:	920080e7          	jalr	-1760(ra) # 80001718 <copyout>
    80005e00:	02054063          	bltz	a0,80005e20 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e04:	4691                	li	a3,4
    80005e06:	fc040613          	addi	a2,s0,-64
    80005e0a:	fd843583          	ld	a1,-40(s0)
    80005e0e:	95b6                	add	a1,a1,a3
    80005e10:	68a8                	ld	a0,80(s1)
    80005e12:	ffffc097          	auipc	ra,0xffffc
    80005e16:	906080e7          	jalr	-1786(ra) # 80001718 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e1a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e1c:	06055763          	bgez	a0,80005e8a <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005e20:	fc442783          	lw	a5,-60(s0)
    80005e24:	078e                	slli	a5,a5,0x3
    80005e26:	0d078793          	addi	a5,a5,208
    80005e2a:	97a6                	add	a5,a5,s1
    80005e2c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e30:	fc042783          	lw	a5,-64(s0)
    80005e34:	078e                	slli	a5,a5,0x3
    80005e36:	0d078793          	addi	a5,a5,208
    80005e3a:	97a6                	add	a5,a5,s1
    80005e3c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005e40:	fd043503          	ld	a0,-48(s0)
    80005e44:	fffff097          	auipc	ra,0xfffff
    80005e48:	906080e7          	jalr	-1786(ra) # 8000474a <fileclose>
    fileclose(wf);
    80005e4c:	fc843503          	ld	a0,-56(s0)
    80005e50:	fffff097          	auipc	ra,0xfffff
    80005e54:	8fa080e7          	jalr	-1798(ra) # 8000474a <fileclose>
    return -1;
    80005e58:	57fd                	li	a5,-1
    80005e5a:	a805                	j	80005e8a <sys_pipe+0x102>
    if(fd0 >= 0)
    80005e5c:	fc442783          	lw	a5,-60(s0)
    80005e60:	0007c863          	bltz	a5,80005e70 <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005e64:	078e                	slli	a5,a5,0x3
    80005e66:	0d078793          	addi	a5,a5,208
    80005e6a:	97a6                	add	a5,a5,s1
    80005e6c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005e70:	fd043503          	ld	a0,-48(s0)
    80005e74:	fffff097          	auipc	ra,0xfffff
    80005e78:	8d6080e7          	jalr	-1834(ra) # 8000474a <fileclose>
    fileclose(wf);
    80005e7c:	fc843503          	ld	a0,-56(s0)
    80005e80:	fffff097          	auipc	ra,0xfffff
    80005e84:	8ca080e7          	jalr	-1846(ra) # 8000474a <fileclose>
    return -1;
    80005e88:	57fd                	li	a5,-1
}
    80005e8a:	853e                	mv	a0,a5
    80005e8c:	70e2                	ld	ra,56(sp)
    80005e8e:	7442                	ld	s0,48(sp)
    80005e90:	74a2                	ld	s1,40(sp)
    80005e92:	6121                	addi	sp,sp,64
    80005e94:	8082                	ret
	...

0000000080005ea0 <kernelvec>:
    80005ea0:	7111                	addi	sp,sp,-256
    80005ea2:	e006                	sd	ra,0(sp)
    80005ea4:	e40a                	sd	sp,8(sp)
    80005ea6:	e80e                	sd	gp,16(sp)
    80005ea8:	ec12                	sd	tp,24(sp)
    80005eaa:	f016                	sd	t0,32(sp)
    80005eac:	f41a                	sd	t1,40(sp)
    80005eae:	f81e                	sd	t2,48(sp)
    80005eb0:	fc22                	sd	s0,56(sp)
    80005eb2:	e0a6                	sd	s1,64(sp)
    80005eb4:	e4aa                	sd	a0,72(sp)
    80005eb6:	e8ae                	sd	a1,80(sp)
    80005eb8:	ecb2                	sd	a2,88(sp)
    80005eba:	f0b6                	sd	a3,96(sp)
    80005ebc:	f4ba                	sd	a4,104(sp)
    80005ebe:	f8be                	sd	a5,112(sp)
    80005ec0:	fcc2                	sd	a6,120(sp)
    80005ec2:	e146                	sd	a7,128(sp)
    80005ec4:	e54a                	sd	s2,136(sp)
    80005ec6:	e94e                	sd	s3,144(sp)
    80005ec8:	ed52                	sd	s4,152(sp)
    80005eca:	f156                	sd	s5,160(sp)
    80005ecc:	f55a                	sd	s6,168(sp)
    80005ece:	f95e                	sd	s7,176(sp)
    80005ed0:	fd62                	sd	s8,184(sp)
    80005ed2:	e1e6                	sd	s9,192(sp)
    80005ed4:	e5ea                	sd	s10,200(sp)
    80005ed6:	e9ee                	sd	s11,208(sp)
    80005ed8:	edf2                	sd	t3,216(sp)
    80005eda:	f1f6                	sd	t4,224(sp)
    80005edc:	f5fa                	sd	t5,232(sp)
    80005ede:	f9fe                	sd	t6,240(sp)
    80005ee0:	c19fc0ef          	jal	80002af8 <kerneltrap>
    80005ee4:	6082                	ld	ra,0(sp)
    80005ee6:	6122                	ld	sp,8(sp)
    80005ee8:	61c2                	ld	gp,16(sp)
    80005eea:	7282                	ld	t0,32(sp)
    80005eec:	7322                	ld	t1,40(sp)
    80005eee:	73c2                	ld	t2,48(sp)
    80005ef0:	7462                	ld	s0,56(sp)
    80005ef2:	6486                	ld	s1,64(sp)
    80005ef4:	6526                	ld	a0,72(sp)
    80005ef6:	65c6                	ld	a1,80(sp)
    80005ef8:	6666                	ld	a2,88(sp)
    80005efa:	7686                	ld	a3,96(sp)
    80005efc:	7726                	ld	a4,104(sp)
    80005efe:	77c6                	ld	a5,112(sp)
    80005f00:	7866                	ld	a6,120(sp)
    80005f02:	688a                	ld	a7,128(sp)
    80005f04:	692a                	ld	s2,136(sp)
    80005f06:	69ca                	ld	s3,144(sp)
    80005f08:	6a6a                	ld	s4,152(sp)
    80005f0a:	7a8a                	ld	s5,160(sp)
    80005f0c:	7b2a                	ld	s6,168(sp)
    80005f0e:	7bca                	ld	s7,176(sp)
    80005f10:	7c6a                	ld	s8,184(sp)
    80005f12:	6c8e                	ld	s9,192(sp)
    80005f14:	6d2e                	ld	s10,200(sp)
    80005f16:	6dce                	ld	s11,208(sp)
    80005f18:	6e6e                	ld	t3,216(sp)
    80005f1a:	7e8e                	ld	t4,224(sp)
    80005f1c:	7f2e                	ld	t5,232(sp)
    80005f1e:	7fce                	ld	t6,240(sp)
    80005f20:	6111                	addi	sp,sp,256
    80005f22:	10200073          	sret
    80005f26:	00000013          	nop
    80005f2a:	00000013          	nop
    80005f2e:	0001                	nop

0000000080005f30 <timervec>:
    80005f30:	34051573          	csrrw	a0,mscratch,a0
    80005f34:	e10c                	sd	a1,0(a0)
    80005f36:	e510                	sd	a2,8(a0)
    80005f38:	e914                	sd	a3,16(a0)
    80005f3a:	6d0c                	ld	a1,24(a0)
    80005f3c:	7110                	ld	a2,32(a0)
    80005f3e:	6194                	ld	a3,0(a1)
    80005f40:	96b2                	add	a3,a3,a2
    80005f42:	e194                	sd	a3,0(a1)
    80005f44:	4589                	li	a1,2
    80005f46:	14459073          	csrw	sip,a1
    80005f4a:	6914                	ld	a3,16(a0)
    80005f4c:	6510                	ld	a2,8(a0)
    80005f4e:	610c                	ld	a1,0(a0)
    80005f50:	34051573          	csrrw	a0,mscratch,a0
    80005f54:	30200073          	mret
    80005f58:	0001                	nop

0000000080005f5a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f5a:	1141                	addi	sp,sp,-16
    80005f5c:	e406                	sd	ra,8(sp)
    80005f5e:	e022                	sd	s0,0(sp)
    80005f60:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f62:	0c000737          	lui	a4,0xc000
    80005f66:	4785                	li	a5,1
    80005f68:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f6a:	c35c                	sw	a5,4(a4)
}
    80005f6c:	60a2                	ld	ra,8(sp)
    80005f6e:	6402                	ld	s0,0(sp)
    80005f70:	0141                	addi	sp,sp,16
    80005f72:	8082                	ret

0000000080005f74 <plicinithart>:

void
plicinithart(void)
{
    80005f74:	1141                	addi	sp,sp,-16
    80005f76:	e406                	sd	ra,8(sp)
    80005f78:	e022                	sd	s0,0(sp)
    80005f7a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f7c:	ffffc097          	auipc	ra,0xffffc
    80005f80:	b5a080e7          	jalr	-1190(ra) # 80001ad6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f84:	0085171b          	slliw	a4,a0,0x8
    80005f88:	0c0027b7          	lui	a5,0xc002
    80005f8c:	97ba                	add	a5,a5,a4
    80005f8e:	40200713          	li	a4,1026
    80005f92:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f96:	00d5151b          	slliw	a0,a0,0xd
    80005f9a:	0c2017b7          	lui	a5,0xc201
    80005f9e:	97aa                	add	a5,a5,a0
    80005fa0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005fa4:	60a2                	ld	ra,8(sp)
    80005fa6:	6402                	ld	s0,0(sp)
    80005fa8:	0141                	addi	sp,sp,16
    80005faa:	8082                	ret

0000000080005fac <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005fac:	1141                	addi	sp,sp,-16
    80005fae:	e406                	sd	ra,8(sp)
    80005fb0:	e022                	sd	s0,0(sp)
    80005fb2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fb4:	ffffc097          	auipc	ra,0xffffc
    80005fb8:	b22080e7          	jalr	-1246(ra) # 80001ad6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005fbc:	00d5151b          	slliw	a0,a0,0xd
    80005fc0:	0c2017b7          	lui	a5,0xc201
    80005fc4:	97aa                	add	a5,a5,a0
  return irq;
}
    80005fc6:	43c8                	lw	a0,4(a5)
    80005fc8:	60a2                	ld	ra,8(sp)
    80005fca:	6402                	ld	s0,0(sp)
    80005fcc:	0141                	addi	sp,sp,16
    80005fce:	8082                	ret

0000000080005fd0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005fd0:	1101                	addi	sp,sp,-32
    80005fd2:	ec06                	sd	ra,24(sp)
    80005fd4:	e822                	sd	s0,16(sp)
    80005fd6:	e426                	sd	s1,8(sp)
    80005fd8:	1000                	addi	s0,sp,32
    80005fda:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fdc:	ffffc097          	auipc	ra,0xffffc
    80005fe0:	afa080e7          	jalr	-1286(ra) # 80001ad6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fe4:	00d5179b          	slliw	a5,a0,0xd
    80005fe8:	0c201737          	lui	a4,0xc201
    80005fec:	97ba                	add	a5,a5,a4
    80005fee:	c3c4                	sw	s1,4(a5)
}
    80005ff0:	60e2                	ld	ra,24(sp)
    80005ff2:	6442                	ld	s0,16(sp)
    80005ff4:	64a2                	ld	s1,8(sp)
    80005ff6:	6105                	addi	sp,sp,32
    80005ff8:	8082                	ret

0000000080005ffa <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005ffa:	1141                	addi	sp,sp,-16
    80005ffc:	e406                	sd	ra,8(sp)
    80005ffe:	e022                	sd	s0,0(sp)
    80006000:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006002:	479d                	li	a5,7
    80006004:	04a7cc63          	blt	a5,a0,8000605c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006008:	0001c797          	auipc	a5,0x1c
    8000600c:	ff878793          	addi	a5,a5,-8 # 80022000 <disk>
    80006010:	97aa                	add	a5,a5,a0
    80006012:	0187c783          	lbu	a5,24(a5)
    80006016:	ebb9                	bnez	a5,8000606c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006018:	00451693          	slli	a3,a0,0x4
    8000601c:	0001c797          	auipc	a5,0x1c
    80006020:	fe478793          	addi	a5,a5,-28 # 80022000 <disk>
    80006024:	6398                	ld	a4,0(a5)
    80006026:	9736                	add	a4,a4,a3
    80006028:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    8000602c:	6398                	ld	a4,0(a5)
    8000602e:	9736                	add	a4,a4,a3
    80006030:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006034:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006038:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000603c:	97aa                	add	a5,a5,a0
    8000603e:	4705                	li	a4,1
    80006040:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006044:	0001c517          	auipc	a0,0x1c
    80006048:	fd450513          	addi	a0,a0,-44 # 80022018 <disk+0x18>
    8000604c:	ffffc097          	auipc	ra,0xffffc
    80006050:	234080e7          	jalr	564(ra) # 80002280 <wakeup>
}
    80006054:	60a2                	ld	ra,8(sp)
    80006056:	6402                	ld	s0,0(sp)
    80006058:	0141                	addi	sp,sp,16
    8000605a:	8082                	ret
    panic("free_desc 1");
    8000605c:	00002517          	auipc	a0,0x2
    80006060:	5cc50513          	addi	a0,a0,1484 # 80008628 <etext+0x628>
    80006064:	ffffa097          	auipc	ra,0xffffa
    80006068:	4fa080e7          	jalr	1274(ra) # 8000055e <panic>
    panic("free_desc 2");
    8000606c:	00002517          	auipc	a0,0x2
    80006070:	5cc50513          	addi	a0,a0,1484 # 80008638 <etext+0x638>
    80006074:	ffffa097          	auipc	ra,0xffffa
    80006078:	4ea080e7          	jalr	1258(ra) # 8000055e <panic>

000000008000607c <virtio_disk_init>:
{
    8000607c:	1101                	addi	sp,sp,-32
    8000607e:	ec06                	sd	ra,24(sp)
    80006080:	e822                	sd	s0,16(sp)
    80006082:	e426                	sd	s1,8(sp)
    80006084:	e04a                	sd	s2,0(sp)
    80006086:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006088:	00002597          	auipc	a1,0x2
    8000608c:	5c058593          	addi	a1,a1,1472 # 80008648 <etext+0x648>
    80006090:	0001c517          	auipc	a0,0x1c
    80006094:	09850513          	addi	a0,a0,152 # 80022128 <disk+0x128>
    80006098:	ffffb097          	auipc	ra,0xffffb
    8000609c:	b2a080e7          	jalr	-1238(ra) # 80000bc2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060a0:	100017b7          	lui	a5,0x10001
    800060a4:	4398                	lw	a4,0(a5)
    800060a6:	2701                	sext.w	a4,a4
    800060a8:	747277b7          	lui	a5,0x74727
    800060ac:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060b0:	16f71463          	bne	a4,a5,80006218 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060b4:	100017b7          	lui	a5,0x10001
    800060b8:	43dc                	lw	a5,4(a5)
    800060ba:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060bc:	4709                	li	a4,2
    800060be:	14e79d63          	bne	a5,a4,80006218 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060c2:	100017b7          	lui	a5,0x10001
    800060c6:	479c                	lw	a5,8(a5)
    800060c8:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060ca:	14e79763          	bne	a5,a4,80006218 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060ce:	100017b7          	lui	a5,0x10001
    800060d2:	47d8                	lw	a4,12(a5)
    800060d4:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060d6:	554d47b7          	lui	a5,0x554d4
    800060da:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060de:	12f71d63          	bne	a4,a5,80006218 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060e2:	100017b7          	lui	a5,0x10001
    800060e6:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ea:	4705                	li	a4,1
    800060ec:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ee:	470d                	li	a4,3
    800060f0:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060f2:	10001737          	lui	a4,0x10001
    800060f6:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800060f8:	c7ffe6b7          	lui	a3,0xc7ffe
    800060fc:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc61f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006100:	8f75                	and	a4,a4,a3
    80006102:	100016b7          	lui	a3,0x10001
    80006106:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006108:	472d                	li	a4,11
    8000610a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000610c:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006110:	439c                	lw	a5,0(a5)
    80006112:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006116:	8ba1                	andi	a5,a5,8
    80006118:	10078863          	beqz	a5,80006228 <virtio_disk_init+0x1ac>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000611c:	100017b7          	lui	a5,0x10001
    80006120:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006124:	43fc                	lw	a5,68(a5)
    80006126:	2781                	sext.w	a5,a5
    80006128:	10079863          	bnez	a5,80006238 <virtio_disk_init+0x1bc>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000612c:	100017b7          	lui	a5,0x10001
    80006130:	5bdc                	lw	a5,52(a5)
    80006132:	2781                	sext.w	a5,a5
  if(max == 0)
    80006134:	10078a63          	beqz	a5,80006248 <virtio_disk_init+0x1cc>
  if(max < NUM)
    80006138:	471d                	li	a4,7
    8000613a:	10f77f63          	bgeu	a4,a5,80006258 <virtio_disk_init+0x1dc>
  disk.desc = kalloc();
    8000613e:	ffffb097          	auipc	ra,0xffffb
    80006142:	a1a080e7          	jalr	-1510(ra) # 80000b58 <kalloc>
    80006146:	0001c497          	auipc	s1,0x1c
    8000614a:	eba48493          	addi	s1,s1,-326 # 80022000 <disk>
    8000614e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006150:	ffffb097          	auipc	ra,0xffffb
    80006154:	a08080e7          	jalr	-1528(ra) # 80000b58 <kalloc>
    80006158:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000615a:	ffffb097          	auipc	ra,0xffffb
    8000615e:	9fe080e7          	jalr	-1538(ra) # 80000b58 <kalloc>
    80006162:	87aa                	mv	a5,a0
    80006164:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006166:	6088                	ld	a0,0(s1)
    80006168:	10050063          	beqz	a0,80006268 <virtio_disk_init+0x1ec>
    8000616c:	0001c717          	auipc	a4,0x1c
    80006170:	e9c73703          	ld	a4,-356(a4) # 80022008 <disk+0x8>
    80006174:	cb75                	beqz	a4,80006268 <virtio_disk_init+0x1ec>
    80006176:	cbed                	beqz	a5,80006268 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80006178:	6605                	lui	a2,0x1
    8000617a:	4581                	li	a1,0
    8000617c:	ffffb097          	auipc	ra,0xffffb
    80006180:	bd8080e7          	jalr	-1064(ra) # 80000d54 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006184:	0001c497          	auipc	s1,0x1c
    80006188:	e7c48493          	addi	s1,s1,-388 # 80022000 <disk>
    8000618c:	6605                	lui	a2,0x1
    8000618e:	4581                	li	a1,0
    80006190:	6488                	ld	a0,8(s1)
    80006192:	ffffb097          	auipc	ra,0xffffb
    80006196:	bc2080e7          	jalr	-1086(ra) # 80000d54 <memset>
  memset(disk.used, 0, PGSIZE);
    8000619a:	6605                	lui	a2,0x1
    8000619c:	4581                	li	a1,0
    8000619e:	6888                	ld	a0,16(s1)
    800061a0:	ffffb097          	auipc	ra,0xffffb
    800061a4:	bb4080e7          	jalr	-1100(ra) # 80000d54 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061a8:	100017b7          	lui	a5,0x10001
    800061ac:	4721                	li	a4,8
    800061ae:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800061b0:	4098                	lw	a4,0(s1)
    800061b2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800061b6:	40d8                	lw	a4,4(s1)
    800061b8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800061bc:	649c                	ld	a5,8(s1)
    800061be:	0007869b          	sext.w	a3,a5
    800061c2:	10001737          	lui	a4,0x10001
    800061c6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800061ca:	9781                	srai	a5,a5,0x20
    800061cc:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800061d0:	689c                	ld	a5,16(s1)
    800061d2:	0007869b          	sext.w	a3,a5
    800061d6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800061da:	9781                	srai	a5,a5,0x20
    800061dc:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800061e0:	4785                	li	a5,1
    800061e2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800061e4:	00f48c23          	sb	a5,24(s1)
    800061e8:	00f48ca3          	sb	a5,25(s1)
    800061ec:	00f48d23          	sb	a5,26(s1)
    800061f0:	00f48da3          	sb	a5,27(s1)
    800061f4:	00f48e23          	sb	a5,28(s1)
    800061f8:	00f48ea3          	sb	a5,29(s1)
    800061fc:	00f48f23          	sb	a5,30(s1)
    80006200:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006204:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006208:	07272823          	sw	s2,112(a4)
}
    8000620c:	60e2                	ld	ra,24(sp)
    8000620e:	6442                	ld	s0,16(sp)
    80006210:	64a2                	ld	s1,8(sp)
    80006212:	6902                	ld	s2,0(sp)
    80006214:	6105                	addi	sp,sp,32
    80006216:	8082                	ret
    panic("could not find virtio disk");
    80006218:	00002517          	auipc	a0,0x2
    8000621c:	44050513          	addi	a0,a0,1088 # 80008658 <etext+0x658>
    80006220:	ffffa097          	auipc	ra,0xffffa
    80006224:	33e080e7          	jalr	830(ra) # 8000055e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006228:	00002517          	auipc	a0,0x2
    8000622c:	45050513          	addi	a0,a0,1104 # 80008678 <etext+0x678>
    80006230:	ffffa097          	auipc	ra,0xffffa
    80006234:	32e080e7          	jalr	814(ra) # 8000055e <panic>
    panic("virtio disk should not be ready");
    80006238:	00002517          	auipc	a0,0x2
    8000623c:	46050513          	addi	a0,a0,1120 # 80008698 <etext+0x698>
    80006240:	ffffa097          	auipc	ra,0xffffa
    80006244:	31e080e7          	jalr	798(ra) # 8000055e <panic>
    panic("virtio disk has no queue 0");
    80006248:	00002517          	auipc	a0,0x2
    8000624c:	47050513          	addi	a0,a0,1136 # 800086b8 <etext+0x6b8>
    80006250:	ffffa097          	auipc	ra,0xffffa
    80006254:	30e080e7          	jalr	782(ra) # 8000055e <panic>
    panic("virtio disk max queue too short");
    80006258:	00002517          	auipc	a0,0x2
    8000625c:	48050513          	addi	a0,a0,1152 # 800086d8 <etext+0x6d8>
    80006260:	ffffa097          	auipc	ra,0xffffa
    80006264:	2fe080e7          	jalr	766(ra) # 8000055e <panic>
    panic("virtio disk kalloc");
    80006268:	00002517          	auipc	a0,0x2
    8000626c:	49050513          	addi	a0,a0,1168 # 800086f8 <etext+0x6f8>
    80006270:	ffffa097          	auipc	ra,0xffffa
    80006274:	2ee080e7          	jalr	750(ra) # 8000055e <panic>

0000000080006278 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006278:	711d                	addi	sp,sp,-96
    8000627a:	ec86                	sd	ra,88(sp)
    8000627c:	e8a2                	sd	s0,80(sp)
    8000627e:	e4a6                	sd	s1,72(sp)
    80006280:	e0ca                	sd	s2,64(sp)
    80006282:	fc4e                	sd	s3,56(sp)
    80006284:	f852                	sd	s4,48(sp)
    80006286:	f456                	sd	s5,40(sp)
    80006288:	f05a                	sd	s6,32(sp)
    8000628a:	ec5e                	sd	s7,24(sp)
    8000628c:	e862                	sd	s8,16(sp)
    8000628e:	1080                	addi	s0,sp,96
    80006290:	89aa                	mv	s3,a0
    80006292:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006294:	00c52b83          	lw	s7,12(a0)
    80006298:	001b9b9b          	slliw	s7,s7,0x1
    8000629c:	1b82                	slli	s7,s7,0x20
    8000629e:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800062a2:	0001c517          	auipc	a0,0x1c
    800062a6:	e8650513          	addi	a0,a0,-378 # 80022128 <disk+0x128>
    800062aa:	ffffb097          	auipc	ra,0xffffb
    800062ae:	9b2080e7          	jalr	-1614(ra) # 80000c5c <acquire>
  for(int i = 0; i < NUM; i++){
    800062b2:	44a1                	li	s1,8
      disk.free[i] = 0;
    800062b4:	0001ca97          	auipc	s5,0x1c
    800062b8:	d4ca8a93          	addi	s5,s5,-692 # 80022000 <disk>
  for(int i = 0; i < 3; i++){
    800062bc:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800062be:	5c7d                	li	s8,-1
    800062c0:	a885                	j	80006330 <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800062c2:	00fa8733          	add	a4,s5,a5
    800062c6:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800062ca:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800062cc:	0207c563          	bltz	a5,800062f6 <virtio_disk_rw+0x7e>
  for(int i = 0; i < 3; i++){
    800062d0:	2905                	addiw	s2,s2,1
    800062d2:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800062d4:	07490263          	beq	s2,s4,80006338 <virtio_disk_rw+0xc0>
    idx[i] = alloc_desc();
    800062d8:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800062da:	0001c717          	auipc	a4,0x1c
    800062de:	d2670713          	addi	a4,a4,-730 # 80022000 <disk>
    800062e2:	4781                	li	a5,0
    if(disk.free[i]){
    800062e4:	01874683          	lbu	a3,24(a4)
    800062e8:	fee9                	bnez	a3,800062c2 <virtio_disk_rw+0x4a>
  for(int i = 0; i < NUM; i++){
    800062ea:	2785                	addiw	a5,a5,1
    800062ec:	0705                	addi	a4,a4,1
    800062ee:	fe979be3          	bne	a5,s1,800062e4 <virtio_disk_rw+0x6c>
    idx[i] = alloc_desc();
    800062f2:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    800062f6:	03205163          	blez	s2,80006318 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    800062fa:	fa042503          	lw	a0,-96(s0)
    800062fe:	00000097          	auipc	ra,0x0
    80006302:	cfc080e7          	jalr	-772(ra) # 80005ffa <free_desc>
      for(int j = 0; j < i; j++)
    80006306:	4785                	li	a5,1
    80006308:	0127d863          	bge	a5,s2,80006318 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    8000630c:	fa442503          	lw	a0,-92(s0)
    80006310:	00000097          	auipc	ra,0x0
    80006314:	cea080e7          	jalr	-790(ra) # 80005ffa <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006318:	0001c597          	auipc	a1,0x1c
    8000631c:	e1058593          	addi	a1,a1,-496 # 80022128 <disk+0x128>
    80006320:	0001c517          	auipc	a0,0x1c
    80006324:	cf850513          	addi	a0,a0,-776 # 80022018 <disk+0x18>
    80006328:	ffffc097          	auipc	ra,0xffffc
    8000632c:	ef4080e7          	jalr	-268(ra) # 8000221c <sleep>
  for(int i = 0; i < 3; i++){
    80006330:	fa040613          	addi	a2,s0,-96
    80006334:	4901                	li	s2,0
    80006336:	b74d                	j	800062d8 <virtio_disk_rw+0x60>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006338:	fa042503          	lw	a0,-96(s0)
    8000633c:	00451693          	slli	a3,a0,0x4

  if(write)
    80006340:	0001c797          	auipc	a5,0x1c
    80006344:	cc078793          	addi	a5,a5,-832 # 80022000 <disk>
    80006348:	00451713          	slli	a4,a0,0x4
    8000634c:	0a070713          	addi	a4,a4,160
    80006350:	973e                	add	a4,a4,a5
    80006352:	01603633          	snez	a2,s6
    80006356:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006358:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000635c:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006360:	6398                	ld	a4,0(a5)
    80006362:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006364:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80006368:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000636a:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000636c:	6390                	ld	a2,0(a5)
    8000636e:	00d60833          	add	a6,a2,a3
    80006372:	4741                	li	a4,16
    80006374:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006378:	4585                	li	a1,1
    8000637a:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    8000637e:	fa442703          	lw	a4,-92(s0)
    80006382:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006386:	0712                	slli	a4,a4,0x4
    80006388:	963a                	add	a2,a2,a4
    8000638a:	05898813          	addi	a6,s3,88
    8000638e:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006392:	0007b883          	ld	a7,0(a5)
    80006396:	9746                	add	a4,a4,a7
    80006398:	40000613          	li	a2,1024
    8000639c:	c710                	sw	a2,8(a4)
  if(write)
    8000639e:	001b3613          	seqz	a2,s6
    800063a2:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063a6:	8e4d                	or	a2,a2,a1
    800063a8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800063ac:	fa842603          	lw	a2,-88(s0)
    800063b0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800063b4:	00451813          	slli	a6,a0,0x4
    800063b8:	02080813          	addi	a6,a6,32
    800063bc:	983e                	add	a6,a6,a5
    800063be:	577d                	li	a4,-1
    800063c0:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800063c4:	0612                	slli	a2,a2,0x4
    800063c6:	98b2                	add	a7,a7,a2
    800063c8:	03068713          	addi	a4,a3,48
    800063cc:	973e                	add	a4,a4,a5
    800063ce:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800063d2:	6398                	ld	a4,0(a5)
    800063d4:	9732                	add	a4,a4,a2
    800063d6:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063d8:	4689                	li	a3,2
    800063da:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800063de:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063e2:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    800063e6:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063ea:	6794                	ld	a3,8(a5)
    800063ec:	0026d703          	lhu	a4,2(a3)
    800063f0:	8b1d                	andi	a4,a4,7
    800063f2:	0706                	slli	a4,a4,0x1
    800063f4:	96ba                	add	a3,a3,a4
    800063f6:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800063fa:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800063fe:	6798                	ld	a4,8(a5)
    80006400:	00275783          	lhu	a5,2(a4)
    80006404:	2785                	addiw	a5,a5,1
    80006406:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000640a:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000640e:	100017b7          	lui	a5,0x10001
    80006412:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006416:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    8000641a:	0001c917          	auipc	s2,0x1c
    8000641e:	d0e90913          	addi	s2,s2,-754 # 80022128 <disk+0x128>
  while(b->disk == 1) {
    80006422:	84ae                	mv	s1,a1
    80006424:	00b79c63          	bne	a5,a1,8000643c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006428:	85ca                	mv	a1,s2
    8000642a:	854e                	mv	a0,s3
    8000642c:	ffffc097          	auipc	ra,0xffffc
    80006430:	df0080e7          	jalr	-528(ra) # 8000221c <sleep>
  while(b->disk == 1) {
    80006434:	0049a783          	lw	a5,4(s3)
    80006438:	fe9788e3          	beq	a5,s1,80006428 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000643c:	fa042903          	lw	s2,-96(s0)
    80006440:	00491713          	slli	a4,s2,0x4
    80006444:	02070713          	addi	a4,a4,32
    80006448:	0001c797          	auipc	a5,0x1c
    8000644c:	bb878793          	addi	a5,a5,-1096 # 80022000 <disk>
    80006450:	97ba                	add	a5,a5,a4
    80006452:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006456:	0001c997          	auipc	s3,0x1c
    8000645a:	baa98993          	addi	s3,s3,-1110 # 80022000 <disk>
    8000645e:	00491713          	slli	a4,s2,0x4
    80006462:	0009b783          	ld	a5,0(s3)
    80006466:	97ba                	add	a5,a5,a4
    80006468:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000646c:	854a                	mv	a0,s2
    8000646e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006472:	00000097          	auipc	ra,0x0
    80006476:	b88080e7          	jalr	-1144(ra) # 80005ffa <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000647a:	8885                	andi	s1,s1,1
    8000647c:	f0ed                	bnez	s1,8000645e <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000647e:	0001c517          	auipc	a0,0x1c
    80006482:	caa50513          	addi	a0,a0,-854 # 80022128 <disk+0x128>
    80006486:	ffffb097          	auipc	ra,0xffffb
    8000648a:	886080e7          	jalr	-1914(ra) # 80000d0c <release>
}
    8000648e:	60e6                	ld	ra,88(sp)
    80006490:	6446                	ld	s0,80(sp)
    80006492:	64a6                	ld	s1,72(sp)
    80006494:	6906                	ld	s2,64(sp)
    80006496:	79e2                	ld	s3,56(sp)
    80006498:	7a42                	ld	s4,48(sp)
    8000649a:	7aa2                	ld	s5,40(sp)
    8000649c:	7b02                	ld	s6,32(sp)
    8000649e:	6be2                	ld	s7,24(sp)
    800064a0:	6c42                	ld	s8,16(sp)
    800064a2:	6125                	addi	sp,sp,96
    800064a4:	8082                	ret

00000000800064a6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800064a6:	1101                	addi	sp,sp,-32
    800064a8:	ec06                	sd	ra,24(sp)
    800064aa:	e822                	sd	s0,16(sp)
    800064ac:	e426                	sd	s1,8(sp)
    800064ae:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800064b0:	0001c497          	auipc	s1,0x1c
    800064b4:	b5048493          	addi	s1,s1,-1200 # 80022000 <disk>
    800064b8:	0001c517          	auipc	a0,0x1c
    800064bc:	c7050513          	addi	a0,a0,-912 # 80022128 <disk+0x128>
    800064c0:	ffffa097          	auipc	ra,0xffffa
    800064c4:	79c080e7          	jalr	1948(ra) # 80000c5c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800064c8:	100017b7          	lui	a5,0x10001
    800064cc:	53bc                	lw	a5,96(a5)
    800064ce:	8b8d                	andi	a5,a5,3
    800064d0:	10001737          	lui	a4,0x10001
    800064d4:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800064d6:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800064da:	689c                	ld	a5,16(s1)
    800064dc:	0204d703          	lhu	a4,32(s1)
    800064e0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800064e4:	04f70a63          	beq	a4,a5,80006538 <virtio_disk_intr+0x92>
    __sync_synchronize();
    800064e8:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800064ec:	6898                	ld	a4,16(s1)
    800064ee:	0204d783          	lhu	a5,32(s1)
    800064f2:	8b9d                	andi	a5,a5,7
    800064f4:	078e                	slli	a5,a5,0x3
    800064f6:	97ba                	add	a5,a5,a4
    800064f8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800064fa:	00479713          	slli	a4,a5,0x4
    800064fe:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80006502:	9726                	add	a4,a4,s1
    80006504:	01074703          	lbu	a4,16(a4)
    80006508:	e729                	bnez	a4,80006552 <virtio_disk_intr+0xac>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000650a:	0792                	slli	a5,a5,0x4
    8000650c:	02078793          	addi	a5,a5,32
    80006510:	97a6                	add	a5,a5,s1
    80006512:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006514:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006518:	ffffc097          	auipc	ra,0xffffc
    8000651c:	d68080e7          	jalr	-664(ra) # 80002280 <wakeup>

    disk.used_idx += 1;
    80006520:	0204d783          	lhu	a5,32(s1)
    80006524:	2785                	addiw	a5,a5,1
    80006526:	17c2                	slli	a5,a5,0x30
    80006528:	93c1                	srli	a5,a5,0x30
    8000652a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000652e:	6898                	ld	a4,16(s1)
    80006530:	00275703          	lhu	a4,2(a4)
    80006534:	faf71ae3          	bne	a4,a5,800064e8 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006538:	0001c517          	auipc	a0,0x1c
    8000653c:	bf050513          	addi	a0,a0,-1040 # 80022128 <disk+0x128>
    80006540:	ffffa097          	auipc	ra,0xffffa
    80006544:	7cc080e7          	jalr	1996(ra) # 80000d0c <release>
}
    80006548:	60e2                	ld	ra,24(sp)
    8000654a:	6442                	ld	s0,16(sp)
    8000654c:	64a2                	ld	s1,8(sp)
    8000654e:	6105                	addi	sp,sp,32
    80006550:	8082                	ret
      panic("virtio_disk_intr status");
    80006552:	00002517          	auipc	a0,0x2
    80006556:	1be50513          	addi	a0,a0,446 # 80008710 <etext+0x710>
    8000655a:	ffffa097          	auipc	ra,0xffffa
    8000655e:	004080e7          	jalr	4(ra) # 8000055e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
