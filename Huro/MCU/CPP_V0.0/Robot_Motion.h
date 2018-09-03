
#include<cstdio>
#include<cstdlib>
#include<memory.h>
#include<cstring>
#include<queue>
#include<stack>
#include<vector>

#include "robot_protocol.h"
#include "graphic_api.h"
#include "robot_protocol.h"
#include "init.h"
#include "amazon2_sdk.h"
#include "uart_api.h"

#define GOSTRAIGHT             1
#define GOSTRAIGHT_LOOKDOWN90  2
#define RED_DUMBLING           3
#define RED_DOWN               4
#define BLUE_DUMBLING          5
#define TURNLEFT_90            6
#define GOLEFT                 8
#define GORIGHT                7
#define TURNLEFT               11
#define TURNRIGHT              10
#define LOOKDOWN90             13
#define SoundPlay              24
#define UP_RED_STAIR           27

void Motion_Command(U8 Message_Num);
void wait_for_stop();