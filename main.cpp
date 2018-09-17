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

int main()
{
    short i, j;
    int ret;
    int Stage = 6;
	int SoundStage = 6;
    init_console();
	ret = uart_open();
	if (ret < 0) return EXIT_FAILURE;
	
    uart_config(UART1, 9600, 8, UART_PARNONE, 1);
	if (open_graphic() < 0) {
		return -1;	
	}
	direct_camera_display_off();
	clear_screen();
	while (1)
	{
		if (Stage == 0) {
			if (SoundStage == 0)
			{
				Send_Command(SoundPlay);
				SoundStage++;
			}
			BeforeStart(Stage);
		}
		else if (Stage == 1) {
			if (SoundStage == 1)
			{
				Send_Command(SoundPlay);
				SoundStage++;
			}
			StartBarigate(Stage);
		}
		else if (Stage == 2) {
			if (SoundStage == 2)
			{
				Send_Command(SoundPlay);
				SoundStage++;
			}
			Red_Stair(Stage);
		}
		else if (Stage == 3) {
			if (SoundStage == 3)
			{
				Send_Command(SoundPlay);
				SoundStage++;
			}
			Up_Red_Stair(Stage);
		}
		else if (Stage == 4) {
			if (SoundStage == 4)
			{
				Send_Command(SoundPlay);
				SoundStage++;
			}
			Go_Down_Red_Stair(Stage);
		}
		else if (Stage == 5) {
			if (SoundStage == 5)
			{
				Send_Command(SoundPlay);
				SoundStage++;
			}
			Find_Mine(Stage);
		}
		else if (Stage == 6) {
			if (SoundStage == 6)
			{
				Send_Command(SoundPlay);
				SoundStage++;
			}
			Yellow_Trap(Stage);
		}
		else if (Stage == 7) {
			if (SoundStage == 7)
			{
				Send_Command(SoundPlay);
				SoundStage++;
			}
			Up_Yellow_Stair(Stage);
		}
	}
	 uart_close();
	close_graphic();
    return 0;
}
