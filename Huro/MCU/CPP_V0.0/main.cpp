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
#include "init.h"

#define LINE_AREA_MAX 3500


vector<pair<pair<U32, POS>, Range> > area;

int main()
{
    short i, j;
    int ret;
    HSV hsv;
    U16 *input = (U16*)malloc(2*180*120);
    //init_console();
	//ret = uart_open();
	//if (ret < 0) return EXIT_FAILURE;
	
    //uart_config(UART1, 9600, 8, UART_PARNONE, 1);
	if (open_graphic() < 0) {
		return -1;	
	}
	direct_camera_display_off();
	clear_screen();
   
    U32 area_sum = 0;
    U32 temp_i;

    Range range = {90, 180, 0,120};
    vector<Range> Pos_range;
    Range pos_range;
	while(1)
	{
        area.clear();
        area_sum = 0;
        temp_i = 0;     

        read_fpga_video_data(input);
        
        for(i=0;i<height;i++)
        {
            for(j=0;j<width;j++)
            {
                //hsv = ChangetoHSV(input[pos(i,j)]);
                if(ISGREEN(input[pos(i,j)]))
                {
                    input[pos(i,j)] = 0xFFFF;
                }
                else
                {
                    input[pos(i,j)] = 0x0000;
                }
            }
        }
        
        ColorLabelingFULL(0xFFFF, area, input);

        for(i=0;i<area.size();i++)
        {
            if(area_sum < area[i].first.first)
            {
                area_sum = area[i].first.first;
                temp_i = i + 1;
            }
        }

        printf("%d\n",temp_i);

        for(i=0;i<height;i++)
        {
            for(j=0;j<width;j++)
            {
                if(temp_i >= 1 && (area[temp_i - 1].first.second.x == j || area[temp_i - 1].first.second.y == i)) input[pos(i,j)] = 0x07E0;
                else if(temp_i >= 1 && input[pos(i,j)] == temp_i)
                {
                    input[pos(i,j)] = 0x0000;
                }
                else
                {
                    input[pos(i,j)] = 0xFFFF;
                }
                if(temp_i >= 1){
                    pos_range = area[temp_i - 1].second;
                    if(pos_range.start_x == j)input[pos(i,j)] = 0xF800;
                    if(pos_range.start_y == i)input[pos(i,j)] = 0xF800;
                    if(pos_range.end_x == j)input[pos(i,j)] = 0xF800;
                    if(pos_range.end_y == i)input[pos(i,j)] = 0xF800;
                }
            }
        }

        draw_fpga_video_data_full(input);
        flip();
	}
	
    free(input);
    //uart_close();
	close_graphic();
    return 0;
}
