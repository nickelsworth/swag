
{ Detection of ZIP and ARJ SFX files }

{$S-,V-,D+,I-}
USES DOS;


TYPE
  ArchiveTypes = (NONE,ARJ,PKZIP);
  Header = RECORD
           HeadId  : WORD;                                      { 60000 }
           SIG1    : WORD;                          { Basic Header Size }
  END;

VAR

   ArchiveName   : PathStr;
   ArchiveSize   : LongInt;  { actual size of archive }
   ArchiveOffset : LongInt;  { bytes to skip in header if SFX }
   ArchiveKind   : ArchiveTypes;

  FUNCTION CheckSfx(SfxName : PathStr) : BOOLEAN;

  {-check for self-extracting archive}
  {-if Sfx Exe: set ArchiveName and ArchiveOffset}
  Var ImageInfo : Record
                    ExeId : Array[0..1] Of Char;
                    Remainder,
                    size : Word
                  End;
    SfxExe : File;
    H  : Header;
    rd : Word;
    Err : Boolean;
    AOffset : LongInt;
    ExeId : Array[0..1] Of Char;

  Begin

    CheckSFX := FALSE;
    Assign(SfxExe, SfxName); Reset(SfxExe, 1);
    If IoResult > 0 Then Exit;

    ArchiveName   := SfxName;
    ArchiveOffset := 0;
    ArchiveSize   := Filesize(SfxExe);
    BlockRead(SfxExe, ImageInfo, SizeOf(ImageInfo));
    If ImageInfo.ExeId <> 'MZ' Then Exit;
    AOffset := LongInt(ImageInfo.size-1)*512+ImageInfo.Remainder;
    Seek(SfxExe, AOffset);
    If IoResult > 0 Then Exit;
    BlockRead(SfxExe, H, SizeOf(H), rd);
    Err := (IoResult > 0) Or (rd < SizeOf(Header));
    Close(SfxExe);
    If Err Then Exit;
    ArchiveName   := SfxName;
    ArchiveOffset := AOffset + (ORD(BOOLEAN(H.Sig1 = $EA60)) * 2); { add 2 bytes for ARJ241}
    ArchiveKind   := ArchiveTypes(ORD(ArchiveOffset > 0) + ORD(BOOLEAN(H.Sig1 <> $EA60)));
    CheckSfx      := (ArchiveOffset > 0);
  End;

                                                
BEGIN
ArchiveName := ParamStr(1);
CheckSfx(archivename);
END.