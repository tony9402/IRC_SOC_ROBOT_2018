
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
#define GOLEFT_GREEN           7
#define GORIGHT_GREEN          8
#define GO_UP                  9
#define GO_DOWN                10
//#define �������ũ�� 11
#define GOLEFT                 12
#define GORIGHT                13
#define GOSTRAIGHT_GREEN       14
#define GO_A_LITTLE            15
#define GO_A_LITTLE_60         16

#define MOTION_RETURN          20
#define LOOK_RIGHT_90_W_A      21
#define BIBIGI                 22
#define TURNLEFT               23
#define TURNRIGHT              24
#define LOOK_FORWARD           25
#define HEAD_DOWN_30           26
#define HEAD_DOWN_60           27
#define HEAD_DOWN_90           28
#define HEAD_MID_90            29
#define HEAD_RIGHT_90          30
#define HEAD_LEFT_90           31
#define SoundPlay              32
//#define 
#define GOSTRAIGHT4            34

void Motion_Command(const U8 Message_Num);
void wait_for_stop();
void delay();
void delay_for_LOOK_FORWARD();
void bibigi_delay();
void delay_for_walk();
