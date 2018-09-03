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
#include "Robot_Motion.h"
#include "init.h"

#define MAX3(x,y,z)   (((x)>(y))?((x)>(z))?(x):(z):((y)>(z))?(y):(z))
#define MIN3(x,y,z)   (((x)>(y))?((y)>(z))?(z):(y):((x)>(z))?(z):(x))

#define max3(x, y, z) ((x) > (y) ? (x) : (y)) > (z) ? ((x) > (y) ? (x) : (y)) : (z)
#define min3(x, y, z) ((x) > (y) ? (y) : (x)) > (z) ? (z) : ((x) > (y) ? (y) : (x))

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
    BYTE red;
    BYTE green;
    BYTE blue;
}RGB;

typedef struct
{
    BYTE red;
    BYTE green;
    BYTE blue;
}RGB888;

typedef struct
{
    BYTE H;
    BYTE S;
    BYTE V;
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

HSV ChangetoHSV(U16 rgb);
int FindColor(U16 rgb); 
int ColorLabelingFULL(U16 color, vector<pair<pair<U32, POS>, Range> > &area, U16 *input);
int ColorLabeling(U16 color, vector<pair<U32, POS> > &area, Range &range, U16 *input);
bool ISBLACK(U16 rgb);
bool ISYELLOW(U16 rgb);
bool ISRED(U16 rgb);
bool ISBLUE(U16 rgb);
bool ISGREEN(U16 rgb);
bool ISORANGE(U16 rgb);
void WalkOnGreenBrigde(int &number);
void YellowGate(int &number);
void Red_Stair(int &number);
void Up_Red_Stair(int &number);
void Go_Down_Red_Stair(int &number);
void Blue_Hurdle(int &number);

#endif