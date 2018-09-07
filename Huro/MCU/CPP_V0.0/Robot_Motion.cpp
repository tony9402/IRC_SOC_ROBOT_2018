
#include"Robot_Motion.h"

void Motion_Command(U8 Message_Num)
{
    Send_Command(Message_Num);
    wait_for_stop();
}

void delay()
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
	