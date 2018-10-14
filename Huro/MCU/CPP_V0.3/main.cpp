#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>

#include "SaveData.h"
#include "amazon2_sdk.h"
#include "graphic_api.h"
#include "uart_api.h"
#include "robot_protocol.h"
#include "img_processing.h"
#include "Robot_Motion.h"
#include "init.h"

int main()
{
	int ret;
	init_console();
	ret = uart_open();
	if (ret < 0) return EXIT_FAILURE;

	uart_config(UART1, 9600, 8, UART_PARNONE, 1);

	if (open_graphic() < 0) {
		return -1;
	}

	direct_camera_display_off();
	clear_screen();

	int Stage = 0;
	int Sound_Stage = 0;

	FILE *file;
	if (DATA_SAVE_TXT)
	{
		int returnValue = FileOpen(file);
		if (returnValue)
		{
			if (returnValue == LOG_IS_ERROR)return !printf("LOG_IS_ERROR\n");
			if (returnValue == OPEN_ERROR)return !printf("LOG_OPEN_ERROR\n");
		}
	}

	while (1)
	{
		//Line_Matching_();
		//Test_RED();
		//Last_Barrier_Line();
		//Test_Find_Mine(Stage);
		//Line_Matching();
		//WalkOnGreenBrigde(Stage);
		//Green_Bridge_Last(Stage);
		//Green_Mid();
		//if(1)continue;
		if (Stage == 0)
		{
			if (Sound_Stage == 0)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			BeforeStart(Stage);
		}
		else if (Stage == 1)
		{
			if (Sound_Stage == 1)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			//StartBarigate(Stage);
			StartBarigate_(Stage);
			if (Stage == 2)
			{
				Motion_Command(GOSTRAIGHT);
				//Motion_Command(GOSTRAIGHT);
				//Motion_Command(GOSTRAIGHT);
			}
		}
		else if (Stage == 2)
		{
			if (Sound_Stage == 2)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			Red_Stair(Stage);
		}
		else if (Stage == 3)
		{
			if (Sound_Stage == 3)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			
			Up_Red_Stair(Stage);
		}
		else if (Stage == 4)
		{
			if (Sound_Stage == 4)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			Go_Down_Red_Stair(Stage);
			if (Stage == 5)while (Line_Matching());
		}
		else if (Stage == 5)
		{
			if (Sound_Stage == 5)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			Test_Find_Mine(Stage);
		}
		else if (Stage == 6)
		{
			if (Sound_Stage == 6)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			Blue_Hurdle(Stage);
		}
		else if (Stage == 7)
		{
			if (Sound_Stage == 7)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			Go_to_Green(Stage);
		}
		else if (Stage == 8)
		{
			if (Sound_Stage == 8)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			WalkOnGreenBrigde(Stage);
		}
		else if (Stage == 9)
		{
			if (Sound_Stage == 9)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			Green_Bridge_Last(Stage);
			short cnt;
			for(cnt=0;cnt<=4;cnt++)
			{
				Motion_Command(GOSTRAIGHT);
			}
			Motion_Command(TURNLEFT_90);
			while(Line_Matching_());
			for(cnt=0;cnt<=2;cnt++)
			{
				Motion_Command(GOSTRAIGHT);
			}
		}
		else if (Stage == 10)
		{
			if (Sound_Stage == 10)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			Yellow_Trap(Stage);
		}
		else if (Stage == 11)
		{
			if (Sound_Stage == 11)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			Up_Yellow_Stair(Stage);
		}
		else if(Stage == 12)
		{
			if(Sound_Stage == 12)
			{
				++Sound_Stage;
				Motion_Command(SoundPlay);
			}
			Go_Down_Yellow_Stair(Stage);
		}
		

	}
	uart_close();
	close_graphic();
	return 0;
}