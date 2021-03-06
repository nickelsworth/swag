{
> I have seen several posts in the past few months on how to read input
> not to exceed a specified input length. Here is something that I have
> wrote a couple of years back to help me, and I still use it to date.

Hmmm, i think starting from today, you will use the following routine:
}

Program MaxInputDemo;
{ Released for SWAG; Public Domain, written by Andrew Eigus
  Internet: aeigus@fgate.castle.riga.lv, aeigus@kristin.cclu.lv
  Fidonet: 2:5100/33 }

Procedure lReadLn(var Str : string; MaxLength : byte); assembler;
{ Buffered string input from a standard console device }
Asm
  push ds
  lds si,Str
  mov dx,si
  mov ah,0Ah
  mov bl,MaxLength
  inc bl
  mov [si],bl
  int 21h
  les di,Str
  cld
  inc si
  lodsb
  mov cl,al
  stosb
  xor ch,ch
  jcxz @@1
  rep movsb
@@1:
  pop ds
End; { lReadLn }

var S : string;

Begin
  Write('Enter a string (max 10 characters) : ');
  lReadln(S, 10);
  WriteLn;
  WriteLn('Entered string is "', S, '"')
End.
