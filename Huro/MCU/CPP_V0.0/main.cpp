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
    int Stage = 0;
	int SoundStage = 0;
    init_console();
	ret = uart_open();
	if (ret < 0) return EXIT_FAILURE;
	
    uart_config(UART1, 9600, 8, UART_PARNONE, 1);
	if (open_graphic() < 0) {
		return -1;	
	}
	direct_camera_display_off();
	clear_screen();
    U16 *input = (U16*)malloc(2*180*120);
    while(1)
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
         Up_Red_Stair(Stage);
      }
      else if (Stage == 3) {
         if (SoundStage == 3)
         {
            Send_Command(SoundPlay);
            SoundStage++;
         }
         Go_Down_Red_Stair(Stage);
	  }
	}
	free(input);
    uart_close();
	close_graphic();
    return 0;
}
