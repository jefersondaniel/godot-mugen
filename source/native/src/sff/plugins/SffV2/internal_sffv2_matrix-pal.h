Palette _sffv2_matrixToPal (ByteArray &src, int dim) {
  Palette palette;
  ByteArrayStream in(src);
  uint8_t r, g, b, skip;
  for(int a = 0; a < dim; a++) {
    in>>r; in>>g; in>>b; in>>skip;
    palette.colors.push_back(RawColor(r, g, b, a == 0 ? 0 : 255));
  }
  return palette;
}
