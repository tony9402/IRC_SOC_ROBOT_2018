
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

#define GOSTRAIGHT      15
#define GOLEFT          8
#define GORIGHT         7
#define TURNLEFT        11
#define TURNRIGHT       10
#define SoundPlay       

void Motion_Command(U8 Message_Num);
void wait_for_stop();