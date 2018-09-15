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

#define PRINT_GREEN_BRIDGE_INFO   false
#define PRINT_GREEN_BRIDGE_MOTION true

#define DATA_SAVE_TXT             true

#define MINE_AREA_MIN 0
#define MINE_AREA_MAX 10000

#define Labeling      vector<pair<U32, POS> >
#define pss           pair<short, short>
#define mp(x,y)       make_pair(x,y)

#define pos(y,x)      ((y)*width+(x))
#define abs(x)        ((x)<0?-(x):(x))
#ifdef min(x,y)
    #undef min(x,y)
    #define min(x,y)  ((x)>(y)?(y):(x))
#endif
#ifdef max(x,y)
    #undef max(x,y)
    #define max(x,y)  ((x)>(y)?(x):(y))
#endif
#define height        120
#define width         180

using namespace std;

typedef U8 BYTE;

typedef struct{
    BYTE red;
    BYTE green;
    BYTE blue;
}RGB, RGB888;

typedef struct{
    BYTE H;
    BYTE S;
    BYTE V;
}HSV;

typedef struct{
    BYTE x;
    BYTE y;
}POS;

typedef struct{
    BYTE start_x;
    BYTE end_x;
    BYTE start_y;
    BYTE end_y;
}Range;

typedef struct{
    BYTE DOWN_MAX;
    BYTE DOWN_MIN;
    BYTE UP_MAX;
    BYTE UP_MIN;
}POS_MID;

bool Labeling_Area_Vaild(short& y, short& x, Range& range);
void ChangeColor(U16 *input, const int &color);
U16 ColorLabeling(const U16 &color, Labeling &area, Range &range, U16 *input);
void WalkOnGreenBrigde(int &number);
void BeforeStart(int &Stage);
void StartBarigate(int &Stage);
void Red_Stair(int &Stage);
void Up_Red_Stair(int &Stage);
void Go_Down_Red_Stair(int &Stage);
void Find_Mine(int &Stage);
void Blue_Hurdle(int &Stage);
void Line_Search(U16 *input);
void Line_Match();

#endif