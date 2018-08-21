#ifndef __IMG_PROCESSING_H
#define __IMG_PROCESSING_H

#include<cstdio>
#include<cstdlib>
#include<memory.h>
#include<cstring>
#include<queue>
#include<stack>
#include<vector>

#include "amazon2_sdk.h"
#include "graphic_api.h"
#include "uart_api.h"
#include "robot_protocol.h"

#define MAX3(x,y,z)   (((x)>(y))?((x)>(z))?(x):(z):((y)>(z))?(y):(z))
#define MIN3(x,y,z)   (((x)>(y))?((y)>(z))?(z):(y):((x)>(z))?(z):(x))
#define abs(x)        ((x)<0?-(x):(x))
#define height        120
#define width         180
#define pos(y,x)      ((y)*width+(x))
#define red5(x)       (((x)&0xF800)>>11)
#define green6(x)     (((x)&0x07E0)>>5)
#define blue5(x)      (((x)&0x001F))

#define IsBlack       1
#define IsRed         2
#define IsGreen       3
#define IsBlue        4
#define IsYellow      5
#define IsOrange      6

using namespace std;

typedef U8 BYTE;

typedef struct
{
    BYTE red : 5;
    BYTE green : 6;
    BYTE blue : 5;
}RGB;

typedef struct
{
    BYTE red;
    BYTE green;
    BYTE blue;
}RGB888;

typedef struct
{
    BYTE H : 8;
    BYTE S : 8;
    BYTE V : 8;
}HSV;

typedef struct
{
    BYTE x;
    BYTE y;
}POS;

typedef struct
{
    BYTE start_x;
    BYTE end_x;
    BYTE start_y;
    BYTE end_y;
}Range;

/*
typedef struct
{
    BYTE min_x;
    BYTE max_x;
    BYTE min_y;
    BYTE 
}*/

HSV ChangetoHSV(U16 rgb);
int FindColor(HSV hsv, U16 rgb);
int ColorLabelingFULL(U16 color, vector<pair<pair<U32, POS>, Range> > &area, U16 *input);
int ColorLabeling(U16 color, vector<pair<U32, POS> > &area, Range &range, U16 *input);
bool ISYELLOW(U16 rgb);
bool ISRED(U16 rgb);
bool ISGREEN(U16 rgb);

#endif