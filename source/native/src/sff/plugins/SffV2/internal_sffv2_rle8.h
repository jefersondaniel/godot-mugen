void _sffv2_rle8Decode( ByteArray &src )
{
  ByteArrayStream in(src);
  ByteArray dest;
  unsigned char ch, color;
  {uint32_t i; in>>i; } //undocumented: first 4 bytes = len of image

  while(!in.atEnd()) {
    in>>ch;
    if((ch & 0xc0) == 0x40) { //=0x40
	  in>>color;
	  for(unsigned char a=0; a< ((ch & 0x3f)); a++) { dest.append(color); }
    }
    if((ch & 0xc0) != 0x40) { dest.append(ch); }
  }
  src = dest;
}
