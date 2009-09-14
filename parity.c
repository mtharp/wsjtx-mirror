extern unsigned char Partab[];  /* Parity lookup table */

int parity(int x)
{
  x ^= (x >> 16);
  x ^= (x >> 8);
  return Partab[x & 0xff];
}
