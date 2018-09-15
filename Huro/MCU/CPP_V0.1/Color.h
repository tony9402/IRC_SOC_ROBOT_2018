
#ifndef __COLOR_H
#define __COLOR_H

#include "img_processing.h"

#define IsBlack       1
#define IsRed         2
#define IsGreen       3
#define IsBlue        4
#define IsYellow      5
#define IsOrange      6

#define red5(x)       (((x)&0xF800)>>11)
#define green6(x)     (((x)&0x07E0)>>5)
#define blue5(x)      (((x)&0x001F))

#define MAX3(x,y,z)   (((x)>(y))?((x)>(z))?(x):(z):((y)>(z))?(y):(z))
#define MIN3(x,y,z)   (((x)>(y))?((y)>(z))?(z):(y):((x)>(z))?(z):(x))

#define max3(x, y, z) ((x)>(y)?(x):(y))>(z)?((x)>(y)?(x):(y)):(z)
#define min3(x, y, z) ((x)>(y)?(y):(x))>(z)?(z):((x)>(y)?(y):(x))

HSV ChangetoHSV(U16 buf);
int FindColor(U16 rgb);
bool ISBLACK(U16 rgb);
bool ISRED(U16 rgb);
bool ISGREEN(U16 rgb);
bool ISBLUE(U16 rgb);
bool ISYELLOW(U16 rgb);
bool ISORANGE(U16 rgb);

#endif