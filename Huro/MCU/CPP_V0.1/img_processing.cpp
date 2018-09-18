#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <queue>
#include <stack>
#include <algorithm>

#include "img_processing.h"
#include "Color.h"

using namespace std;

int Robot_Head_position = 0;
int Robot_Head_front_position = 0;

bool Labeling_Area_Vaild(short& y, short& x, const Range& range)
{
    return (range.start_x<=x&&x<=range.end_x&&range.start_y<=y&&y<=range.end_y);
}

void ChangeColor(U16 *input, const int &color)
{
    short i,j;
    for(i=0;i<height;i++)
    {
        for(j=0;j<width;j++)
        {
            if(FindColor(input[pos(i,j)]) == color)
            {
                input[pos(i,j)] = 0xFFFF;
            }
            else
            {
                input[pos(i,j)] = 0x0000;
            }
        }
    }
    return;
}   

U16 ColorLabeling(const U16 &color, Labeling &area, const Range &range, U16 *input)
{
    int count = 0;
    short i,j,k;
    pair<short,short> now;
    const short dx[] = {-1,1,0,0};
    const short dy[] = {0,0,-1,1};

    queue<pair<short, short> > q;
    U32 area_sum = 0;
    U32 sum_x, sum_y;
    U32 max_area = 0;
    U16 temp_i=0;

    int *visit = (int*)malloc(4*height*width);
    memset(visit,0,sizeof(visit));

    POS pos_input;

    for(i=range.start_y;i<range.end_y;i++)
    {
        for(j=range.start_x;j<range.end_x;j++)
        {
            if(input[pos(i,j)]==color&&!visit[pos(i,j)])
            {
                ++count;
                area_sum = sum_x = sum_y = 0;
                q.push(mp(i,j));
                visit[pos(i,j)] = true;
                input[pos(i,j)] = count;
                
                while(!q.empty())
                {
                    ++area_sum;
                    now = q.front(); q.pop();

                    sum_x += now.second;
                    sum_y += now.first;

                    for(k=0;k<4;k++)
                    {
                        short qy = now.first + dy[k];
                        short qx = now.second + dx[k];
						
                        if(!Labeling_Area_Vaild(qy,qx,range))continue;
                        if(input[pos(qy,qx)]==color&&!visit[pos(qy,qx)])
                        {
                            visit[pos(qy,qx)] = true;
                            input[pos(qy,qx)] = count;
                            q.push(mp(qy,qx));
                        }
                    }
                }
                if(area_sum)
                {
                    pos_input.x = sum_x / area_sum;
                    pos_input.y = sum_y / area_sum;
                    if(max_area < area_sum)
                    {
                        max_area = area_sum;
                        temp_i = count;
                    }
                    area.push_back(mp(area_sum, pos_input));
                }
            }
            else if(!visit[pos(i,j)])
            {
                input[pos(i,j)] = color ? 0x0000 : 0xFFFF;
            }
        }
    }
    free(visit);
    return temp_i;
}

void WalkOnGreenBrigde(int &number)
{
    short i,j;

    U16 *input = (U16*)malloc(2*height*width);
    Labeling area;

    U32 max_area_temp = 0;

    area.clear();
    
    read_fpga_video_data(input);

    ChangeColor(input, IsGreen);

    Range range = {0,width,0,height};

    max_area_temp = ColorLabeling(0xFFFF, area, range, input);

    short L_MAX_Y = 0;
    short L_MIN_Y = 255;
    short MID_X = max_area_temp >= 1 ? area[max_area_temp - 1].second.x : 255;

    POS area_pos;
    area_pos.x = area[max_area_temp - 1].second.x;
    area_pos.y = area[max_area_temp - 1].second.y;

    for(i=0;i<height;i++)
    {
        for(j=0;j<width;j++)
        {
            if(max_area_temp&&(area_pos.x==j||area_pos.y==i))
            {
                input[pos(i,j)] = 0x07E0;
            }
            else if(max_area_temp&&input[pos(i,j)]==max_area_temp)
            {
                L_MAX_Y=max(L_MAX_Y,i);
                L_MIN_Y=min(L_MIN_Y,i);
                input[pos(i,j)]=0x0000;
            }
            else
            {
                input[pos(i,j)]=0xFFFF;
            }
        }
    } 

    U32 LINE_DOWN, LINE_UP_COUNT;
    U32 LINE_UP, LINE_DOWN_COUNT;
    U32 Mid_down, Mid_up;

    LINE_DOWN = LINE_UP_COUNT = LINE_UP = LINE_DOWN_COUNT = 0;

    if(L_MAX_Y - L_MIN_Y >= 10)
    {
        for(i=0;i<height;i++)
        {
            for(j=0;j<width;j++)
            {
                if(L_MAX_Y - i >= 5 && L_MAX_Y > i)
                {
                    if(!input[pos(i,j)]) //If pixel is black
                    {
                        LINE_UP+=j;
                        ++LINE_UP_COUNT;
                    }
                }
                else if(L_MIN_Y + 5 >= i)
                {
                    if(!input[pos(i,j)]) //If pixel is black
                    {
                        LINE_DOWN+=j;
                        ++LINE_DOWN_COUNT;
                    }
                }
            }
        }
        Mid_down = LINE_DOWN / LINE_DOWN_COUNT;
        Mid_up = LINE_UP / LINE_UP_COUNT;

        if(PRINT_GREEN_BRIDGE_INFO)
        {
            printf("MID_X : %d, Mid_down : %d, Mid_up : %d\n",MID_X, Mid_down, Mid_up);
        }

        //http://ssu-gongdoli.tistory.com/19
        //password : soc_ssurobotics
        if(83<=MID_X&&MID_X<=97)
        {
            if(abs(Mid_down-Mid_up)<=5)
            {
                if(PRINT_GREEN_BRIDGE_MOTION)
                {
                    printf("Number : %2d, Motion : Go Straight\n", 1);
                }
                Motion_Command(GOSTRAIGHT);
            }
            else
            {
                if(Mid_up <= MID_X&&MID_X<=Mid_down)
                {
                    if(PRINT_GREEN_BRIDGE_MOTION)
                    {
                        printf("Number : %2d, Motion : Turn Right\n", 2);
                    }
                    Motion_Command(TURNRIGHT);
                }
                else if(Mid_down <= MID_X && MID_X <= Mid_up)
                {
                    if(PRINT_GREEN_BRIDGE_MOTION)
                    {
                        printf("Number : %2d, Motion : Turn Left\n", 3);
                    }
                    Motion_Command(TURNLEFT);
                }
            }
        }
        else if(MID_X < 83)
        {
            if(Mid_down>MID_X&&Mid_up>MID_X)
            {
                if(MID_X>=60)
                {
                    if(PRINT_GREEN_BRIDGE_MOTION)
                    {
                        printf("Number : %2d, Motion : Turn Right\n", 4);
                    }
                    Motion_Command(TURNRIGHT);
                }
                else
                {
                    if(PRINT_GREEN_BRIDGE_MOTION)
                    {
                        printf("Number : %2d, Motion : Go Right\n", 5);
                    }
                    Motion_Command(GORIGHT);
                }
            }
            else if(abs(Mid_down - Mid_up)<=8)
            {
                if(PRINT_GREEN_BRIDGE_MOTION)
                {
                    printf("Number : %2d, Motion : Go Right\n", 6);
                }
                Motion_Command(GORIGHT);
            }
            else
            {
                if(Mid_down > Mid_up)
                {
                    if(PRINT_GREEN_BRIDGE_MOTION)
                    {
                        printf("Number : %2d, Motion : Turn Right\n", 7);
                    }
                    Motion_Command(TURNRIGHT);
                }
                else
                {
                    if(abs(MID_X-Mid_down)-abs(MID_X-Mid_up)<=3)
                    {
                        if(PRINT_GREEN_BRIDGE_MOTION)
                        {
                            printf("Number : %2d, Motion : Go Right\n", 8);
                        }
                        Motion_Command(GORIGHT);
                    }
                    else
                    {
                        if(PRINT_GREEN_BRIDGE_MOTION)
                        {
                            printf("Number : %2d, Motion : NONE\n", 9);
                        }
                    }
                }
            }
        }
        else
        {
            if(Mid_down<MID_X&&Mid_up<MID_X)
            {
                if(MID_X<=123)
                {
                    if(PRINT_GREEN_BRIDGE_MOTION)
                    {
                        printf("Number : %2d, Motion : Turn Left\n", 10);
                    }
                    Motion_Command(TURNLEFT);
                }
                else
                {
                    if(PRINT_GREEN_BRIDGE_MOTION)
                    {
                        printf("Number : %2d, Motion : Go Right\n", 11);
                    }
                    Motion_Command(GORIGHT);
                }
            }
            else if(abs(Mid_down-Mid_up)<=8)
            {
                if(PRINT_GREEN_BRIDGE_MOTION)
                {
                    printf("Number : %2d, Motion : Go Left\n", 12);
                }
                Motion_Command(GOLEFT);
            }
            else
            {
                if(Mid_down < Mid_up)
                {
                    if(PRINT_GREEN_BRIDGE_MOTION)
                    {
                        printf("Number : %2d, Motion : Turn Left\n",13);
                    }
                    Motion_Command(TURNLEFT);
                }
                else
                {
                    if(abs(MID_X-Mid_down)-abs(MID_X-Mid_up)<=3)
                    {
                        if(PRINT_GREEN_BRIDGE_MOTION)
                        {
                            printf("Number : %2d, Motion : Go Left\n",14);
                        }
                        Motion_Command(GOLEFT);
                    }
                    else
                    {
                        if(PRINT_GREEN_BRIDGE_MOTION)
                        {
                            printf("Number : %2d, Motion : NONE\n", 15);
                        }
                    }
                }
            }

            for(i=0;i<height;i++)
            {
                input[pos(i,Mid_down)]=0xF800;
                input[pos(i,Mid_up)]=0x001F;
            }
        }
        draw_fpga_video_data_full(input);
        flip();
        free(input);
        return;
    }
}

//Start => Yellow BriGate
void BeforeStart(int &Stage)
{
    short i, j;
    U16 *input = (U16*)malloc(2*height*width);
    read_fpga_video_data(input);
    short YellowCnt = 0;
    static bool Head_Check = false;
    if(!Head_Check)
    {
        Robot_Head_position = HEAD_DOWN_60;
        Head_Check = true;
    }


    for(i=0;i<height;i++)
    {
        for(j=0;j<width;j++)
        {
            if(FindColor(input[pos(i,j)])==IsYellow)
            {
                input[pos(i,j)] = 0xFFE0;
                ++YellowCnt;
            }
            else
            {
                input[pos(i,j)] = 0x0000;
            }
        }
    }

    if(YellowCnt > 1500)
    {
        ++Stage;
    }

    draw_fpga_video_data_full(input);
    flip();
    free(input);
}

//Checking YellowGate until Yellow gate is gone
void StartBarigate(int &Stage)
{
    short i, j;
    short YellowCnt = 0;
    
    U16 *input = (U16*)malloc(2*height*width);
    read_fpga_video_data(input);

    for(i=0;i<height;i++)
    {
        for(j=0;j<width;j++)
        {
            if(FindColor(input[pos(i,j)])==IsYellow)
            {
                input[pos(i,j)] = 0xFFE0;
                ++YellowCnt;
            }
            else
            {
                input[pos(i,j)] = 0x0000;
            }
        }
    }

    if(YellowCnt < 1500)
    {
        for(i=0;i<3;i++)
        {
            Motion_Command(GOSTRAIGHT);
        }
        Robot_Head_front_position == HEAD_DOWN_60;
        ++Stage;
    }
    
    YellowCnt = 0;
    draw_fpga_video_data_full(input);
    flip();
    free(input);
}

void Red_Stair(int &Stage)
{
    U16 *input = (U16*)malloc(2*height*width);
    read_fpga_video_data(input);
    
    short i,j;

    ChangeColor(input, IsRed);

    Labeling area;
    Range range;

    if(Robot_Head_position == HEAD_DOWN_60)
    {
		range.start_x = 0;
        range.end_x = width;
        range.start_y = 0;
        range.end_y = height;
        printf("60\n");
    }
    else if(Robot_Head_position == HEAD_DOWN_90)
    {
        //x : 0 ~ width
        //y : height/2 ~ height
        range.start_x=0;
        range.end_x=width;
        range.start_y=60;
        range.end_y=height;
        printf("90\n");
    }

    U16 temp_i = ColorLabeling(0xFFFF, area, range, input);
    printf("temp : %d\n",temp_i);
    U32 max_area=0;
    POS pos;

    if(Robot_Head_position == HEAD_DOWN_60){
        if(temp_i)
        {
            max_area = area[temp_i - 1].first;
			for (i = 0; i<height; i++)
			{
				for (j = 0; j<width; j++)
				{
					if (input[pos(i, j)] == temp_i)
					{
						input[pos(i, j)] = 0xF800;
					}
					else
					{
						input[pos(i, j)] = 0x0000;
					}
				}
			}
            if(max_area >= 2000)
            {
                pos = area[temp_i - 1].second;

                if(pos.y >= 80)
                {
					Motion_Command(SoundPlay);
					Motion_Command(SoundPlay);
                    Motion_Command(GOSTRAIGHT);
                }
                else
                {
                    Motion_Command(SoundPlay);
                    Motion_Command(HEAD_DOWN_90);
                    delay();
                    
                    Robot_Head_position = HEAD_DOWN_90;
                    read_fpga_video_data(input);
                    draw_fpga_video_data_full(input);
                    flip();
                    free(input);
                    return;
                }
            }
            else
            {
                Motion_Command(GOSTRAIGHT);
				
                draw_fpga_video_data_full(input);
                flip();
                free(input);
                return;
            }
        }
    }
    else if(Robot_Head_position == HEAD_DOWN_90)
    {
        if(temp_i)
        {
			Motion_Command(SoundPlay);
			max_area = area[temp_i - 1].first;
			for (i = 0; i < height; i++)
			{
				for (j = 0; j < width; j++)
				{
					if (input[pos(i, j)] == temp_i)
					{
						input[pos(i, j)] = 0xF800;
					}
					else
					{
						input[pos(i, j)] = 0x0000;
					}
				}
			}

			printf("area : %d\n", max_area);
            if(max_area <= 2600) //3600 //3000 // 3350
            {
                Motion_Command(GOSTRAIGHT_LOOKDOWN90);
            }
            else
            {
                draw_fpga_video_data_full(input);
                flip();
                Motion_Command(SoundPlay);
                /*Motion_Command(HEAD_DOWN_60);
                delay();*/
                Robot_Head_position = HEAD_DOWN_60;
                ++Stage;
                free(input);
                return;
            }
        }
        else
        {
            Motion_Command(GOSTRAIGHT_LOOKDOWN90);
        }
    }

    draw_fpga_video_data_full(input);
    flip();
    free(input);
    return;
}

void Up_Red_Stair(int &Stage)
{
    U16 *input = (U16*)malloc(2*height*width);
    read_fpga_video_data(input);

    draw_fpga_video_data_full(input);
    flip();
    
	Motion_Command(GOSTRAIGHT_LOOKDOWN90);
	Motion_Command(GOSTRAIGHT_LOOKDOWN90);

    Motion_Command(RED_DUMBLING);
    //Robot_Head_position = HEAD_DOWN_60;
    
    ++Stage;

    free(input);
    return;
}

void Go_Down_Red_Stair(int &Stage)
{
    U16 *input = (U16*)malloc(2*height*width);
    short i,j;

    if(Robot_Head_position == HEAD_DOWN_90)
    {
        Robot_Head_position = HEAD_DOWN_60;
        Motion_Command(HEAD_DOWN_60);
        delay();
        read_fpga_video_data(input);
        draw_fpga_video_data_full(input);
        flip();
        free(input);
        return;
    }

    read_fpga_video_data(input);

    Range range = {0,width,60,height};

    ChangeColor(input, IsRed);

    Labeling area;
    
    U16 temp_i = ColorLabeling(0xFFFF, area, range, input);
    U32 max_area;

    if(temp_i)
    {
        max_area = area[temp_i - 1].first;
        for(i=0;i<height;i++)
        {
            for(j=0;j<width;j++)
            {
                if(input[pos(i,j)]==temp_i)
                {
                    input[pos(i,j)] = 0xF800;
                }
                else
                {
                    input[pos(i,j)] = 0x0000;
                }
            }
        }

        draw_fpga_video_data_full(input);
        flip();

        if(max_area <= 2600)
        {
            Motion_Command(RED_DOWN);
            Robot_Head_position = HEAD_DOWN_90;
            ++Stage;
            free(input);
            return;
        }
    }

    Motion_Command(GOSTRAIGHT_LOOKDOWN90);
    
    free(input);
    return;
}

//Find mine
//양 옆 거리 측정하는 소스 짜기
void Find_Mine(int &Stage)
{
	static bool IsCloseRight = false;
	static bool IsCloseLeft = false;

    short i,j;
    U16 *input = (U16*)malloc(2*height*width);
	U16 *blue = (U16*)malloc(2*height*width);
	if (Robot_Head_position != HEAD_DOWN_90)
	{
		Robot_Head_position = HEAD_DOWN_90;
		Motion_Command(HEAD_DOWN_90);
		delay();
	}

    read_fpga_video_data(input);
	memcpy(blue, input, sizeof(input));

	Range blue_range = { 0,180,60,120 };
	Labeling area;

	for (i = 0; i < height; i++)
	{
		for (j = 0; j < width; j++)
		{
			input[pos(i, j)] = FindColor(input[pos(i, j)]) == IsBlack ? 0xFFFF : 0x0000;
			blue[pos(i, j)] = FindColor(input[pos(i, j)]) == IsBlue ? 0xFFFF : 0x0000;
		}
	}

	U16 Blue_exist = ColorLabeling(0xFFFF, area, blue_range, blue);

	if (Blue_exist)
	{
		if (area[Blue_exist - 1].first > 1300)
		{
			++Stage;
			for (i = 0; i < height; i++)
			{
				for (j = 0; j < width; j++)
				{
					if (blue[pos(i, j)] == Blue_exist)
					{
						blue[pos(i, j)] = Blue_exist;
					}
				}
			}
			draw_fpga_video_data_full(blue);
			flip();
			Motion_Command(SoundPlay);
			Motion_Command(HEAD_DOWN_60);
			Robot_Head_position = HEAD_DOWN_60;

			free(input);
			free(blue);
			return;
		}
	}

	free(blue);
	area.clear();

    Range range = {40,140,40,90};

    ChangeColor(input,IsBlack);
    U16 mine_exist = ColorLabeling(0xFFFF,area,range,input);

    vector<POS> mine;
	POS pos_mine;
	U16 min_y;

	for (i = 0; i < area.size(); i++)
	{
		U32 mine_area = area[i].first;
		if (MINE_AREA_MIN <= mine_area && mine_area <= MINE_AREA_MAX)
		{
			mine.push_back(area[i].second);
		}
	}

	min_y = 255;
	if (!mine.size())
	{
		for (i = 0; i < height; i++)
		{
			for (j = 0; j < width; j++)
			{
				input[pos(i, j)] = 0xFFFF;
			}
		}
		draw_fpga_video_data_full(input);
		flip();
		free(input);
		free(blue);
		return;
	}
	else
	{
		for (i = 0; i < mine.size(); i++)
		{
			if (min_y > mine[i].y)
			{
				min_y = mine[i].y;
				pos_mine = mine[i];
			}
		}


		if (pos_mine.x <= 90)
		{
			//Go Right
			Motion_Command(GORIGHT);
		}
		else
		{
			Motion_Command(GOLEFT);
			//Go Left
		}
	}

	draw_fpga_video_data_full(input);
	flip();
	free(input);
	return;
}


void Blue_Hurdle(int &Stage)
{
    short i, j;

    if(Robot_Head_position != HEAD_DOWN_90)
    {
        Robot_Head_position = HEAD_DOWN_90;
        Motion_Command(HEAD_DOWN_90);
        delay();
    }

    U16 *input = (U16*)malloc(2*height*width);
    read_fpga_video_data(input);
    
    Range range = {0,width,65,height};

    ChangeColor(input,IsBlue);

    Labeling area;
    U16 temp_i = ColorLabeling(0xFFFF,area,range,input);
    U32 max_area;

    if(temp_i)
    {
        max_area = area[temp_i - 1].first;
        for(i=range.start_y;i<range.end_y;i++)
        {
            for(j=range.start_x;j<range.end_x;j++)
            {
                if(input[pos(i,j)]==temp_i)
                {
                    input[pos(i,j)] = 0x001F;
                }
                else
                {
                    input[pos(i,j)] = 0x0000;
                }
            }
        }

        if(max_area >= 1000)
        {
            ++Stage;
            Motion_Command(SoundPlay);
            Motion_Command(GOSTRAIGHT_LOOKDOWN90);
            Motion_Command(GOSTRAIGHT_LOOKDOWN90);
            Motion_Command(HEAD_DOWN_60);
            delay();
            read_fpga_video_data(input);
        }
        else
        {
            Motion_Command(GOSTRAIGHT_LOOKDOWN90);
        }
    }

    draw_fpga_video_data_full(input);
    flip();
    free(input);
}

void Line_Search(U16 *input)
{
    short i, j;
    if(Robot_Head_front_position != HEAD_LEFT_90)
    {
        Robot_Head_front_position = HEAD_LEFT_90;
        Motion_Command(HEAD_LEFT_90);
        delay();
    }
	else if(Robot_Head_position != HEAD_DOWN_60)
    {
        Robot_Head_position = HEAD_DOWN_60;
        Motion_Command(HEAD_DOWN_60);
        delay();
    }
    
    read_fpga_video_data(input);

    //TO DO

    return;
}

void Line_Match()
{
    short i, j;
    U16 *input = (U16*)malloc(2*height*width);
    Line_Search(input);
    
    //TO DO

    draw_fpga_video_data_full(input);
    flip();
    free(input);
    return;
}
