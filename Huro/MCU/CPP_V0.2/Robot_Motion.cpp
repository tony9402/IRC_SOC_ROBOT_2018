
#include"Robot_Motion.h"

void Motion_Command(const U8 Message_Num)
{
	Send_Command(Message_Num);
	wait_for_stop();
	switch (Message_Num)
	{
	case HEAD_DOWN_30:
	case HEAD_DOWN_60:
	case HEAD_DOWN_90:
	case HEAD_LEFT_90:
	case HEAD_MID_90:
	case HEAD_RIGHT_90:
		delay();
		break;
	case LOOK_FORWARD:
		delay_for_LOOK_FORWARD();
		break;
	default:
		return;
	}
}

void delay_for_LOOK_FORWARD()
{
	DelayLoop(40000000);
	return;
}

void delay()
{
    DelayLoop(30000000);
	return;
}

void wait_for_stop()
{
	unsigned char buf[1] = { 0, };
	while (1)
	{
		uart_read(UART1, buf, 1);
		if (buf[0] == 38)break;
	}
}
	