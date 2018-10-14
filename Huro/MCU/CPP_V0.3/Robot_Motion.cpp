
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
	case GOSTRAIGHT:
	case GOSTRAIGHT4:
	case GOSTRAIGHT_LOOKDOWN90:
	case GO_A_LITTLE:
	case GO_A_LITTLE_60:
		delay_for_walk();
		break;
	default:
		return;
	}
	return;
}

void delay_for_walk()
{
	DelayLoop(25000000);
	return;
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

void bibigi_delay()
{
    DelayLoop(10000000);
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
	