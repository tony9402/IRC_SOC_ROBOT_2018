#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>

#include "amazon2_sdk.h"
#include "graphic_api.h"
#include "uart_api.h"
#include "robot_protocol.h"
#include "img_processing.h"
#include "Robot_Motion.h"
#include "init.h"

#define LINE_AREA_MAX 3500

int main()
{
    short i, j;
    int ret;
    int Stage = 0;
    init_console();
	ret = uart_open();
	if (ret < 0) return EXIT_FAILURE;
	
    uart_config(UART1, 9600, 8, UART_PARNONE, 1);
	if (open_graphic() < 0) {
		return -1;	
	}
	direct_camera_display_off();
	clear_screen();
   
    while(1)
	{
        WalkOnGreenBrigde(Stage);
	}
	
    uart_close();
	close_graphic();
    return 0;
}
