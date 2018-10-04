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
int Mine_Distance_Save = 0;

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
        Robot_Head_front_position = HEAD_MID_90;
        Motion_Command(HEAD_DOWN_60);
        Motion_Command(HEAD_MID_90);
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
    
    if(Robot_Head_position != HEAD_DOWN_60)
    {
        Motion_Command(HEAD_DOWN_60);
        Robot_Head_position = HEAD_DOWN_60;
    }
    if(Robot_Head_front_position != HEAD_MID_90)
    {
        Motion_Command(HEAD_MID_90);
        Robot_Head_front_position = HEAD_MID_90;
    }

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

    if(YellowCnt < 700)
    {
        for(i=0;i<3;i++)
        {
            Motion_Command(GOSTRAIGHT);
        }
        Robot_Head_front_position = HEAD_DOWN_60;
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
    
    if(Robot_Head_front_position != HEAD_MID_90)
    {
        Motion_Command(HEAD_MID_90);
        Robot_Head_front_position = HEAD_MID_90;
    }
    
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
                
                ++Stage;
                free(input);

                if(Robot_Head_position != HEAD_DOWN_60)
                {
                    Robot_Head_position = HEAD_DOWN_60;
                    Motion_Command(HEAD_DOWN_60);
                }
                while(Line_Matching());
                return;
            }
        }
        else
        {
            Motion_Command(GOSTRAIGHT_LOOKDOWN90);
            if(Robot_Head_position != HEAD_DOWN_90)
            {
                Robot_Head_position = HEAD_DOWN_90;
            }
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

    if(Robot_Head_position != HEAD_DOWN_90)
    {
        Motion_Command(HEAD_DOWN_90);
        Robot_Head_position = HEAD_DOWN_90;
    }
    if(Robot_Head_front_position != HEAD_MID_90)
    {
        Motion_Command(HEAD_MID_90);
        Robot_Head_front_position = HEAD_MID_90;
    }

    read_fpga_video_data(input);

    draw_fpga_video_data_full(input);
    flip();
    
	Motion_Command(GOSTRAIGHT_LOOKDOWN90);
	Motion_Command(GOSTRAIGHT_LOOKDOWN90);

    Motion_Command(RED_DUMBLING);
    
    ++Stage;

    free(input);
    return;
}

void Go_Down_Red_Stair(int &Stage)
{
    U16 *input = (U16*)malloc(2*height*width);
    short i,j;

    if(Robot_Head_position != HEAD_DOWN_90)
    {
        Robot_Head_position = HEAD_DOWN_90;
        Motion_Command(HEAD_DOWN_90);
    }
    if(Robot_Head_front_position != HEAD_MID_90)
    {
        Robot_Head_front_position = HEAD_MID_90;
        Motion_Command(HEAD_MID_90);
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
            Motion_Command(GOSTRAIGHT);
            free(input);
            return;
        }
    }

    Motion_Command(GOSTRAIGHT_LOOKDOWN90);
    
    free(input);
    return;
}

//Find mine
//�� �� �Ÿ� �����ϴ� �ҽ� ¥��
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
	}
    if(Robot_Head_front_position != HEAD_MID_90)
    {
        Robot_Head_front_position = HEAD_MID_90;
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
    }
    if(Robot_Head_front_position != HEAD_MID_90)
    {
        Robot_Head_front_position = HEAD_MID_90;
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
    }
	else if(Robot_Head_position != HEAD_DOWN_60)
    {
        Robot_Head_position = HEAD_DOWN_60;
        Motion_Command(HEAD_DOWN_60);
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

//FINE_MINE______2018_09_22
//============================================================================================================
void FIND_MINE(int &Stage)
{
    const U32 MINE_MIN_AREA = 200;
    const U32 MINE_MAX_AREA = 1200;

    static int BEFORE_GO_LEFT_RIGHT = BEFORE_GO_LEFT;
    static int MOVE_COUNT = 0;

    if(Robot_Head_front_position != HEAD_MID_90)
    {
        Robot_Head_front_position = HEAD_MID_90;
        Motion_Command(HEAD_MID_90);
    }
    if(Robot_Head_position != HEAD_DOWN_90)
    {
        Robot_Head_position = HEAD_DOWN_90;
        Motion_Command(HEAD_DOWN_90);
    }

    U16 *input = (U16*)malloc(2*180*120);
    U16 *Mine = (U16*)malloc(2*180*120);
    U8 *gray = (U8*)malloc(180*120);
    short i,j,m,n;

    memcpy(Mine,input, 2*180*120);
    Range range = {0,180,60,120};
    U32 count_pixels = 0;
    U32 area_sum = 0;
    U32 gray_sum = 0;
    U32 gray_count = 0;

    for(i=range.start_y;i<range.end_y;i++)
    {
        for(j=range.start_x;j<range.end_x;j++)
        {
            count_pixels = 0;
            area_sum = 0;
            for(m=-10;m<=10;m++)
            {
                for(n=-10;n<=10;n++)
                {
                    short dy = i + m;
                    short dx = j + n;
                    if(!Labeling_Area_Vaild(dy, dx, range))continue;
                    count_pixels++;
                    area_sum += Mine[pos(dy,dx)];
                }
            }
            input[pos(i,j)] = (255 - area_sum / count_pixels + input[pos(i,j)]) / 2;
            gray[pos(i,j)] = Make_Gray(input[pos(i,j)]);
            gray_sum += gray[pos(i,j)];
            ++gray_count;
        }
    }

    Range blue_range = {0,180,60,120};

    for(i=blue_range.start_y;i<blue_range.end_y;i++)
    {
        for(j=blue_range.start_x;j<blue_range.end_x;j++)
        {
            if(FindColor(Mine[pos(i,j)]) == IsBlue)
            {
                Mine[pos(i,j)] = 0xFFFF;
            }
            else
            {
                Mine[pos(i,j)] = 0x0000;
            }
        }
    }

    Labeling blue_vector;
    U16 blue_temp = ColorLabeling(0xFFFF,blue_vector,blue_range, Mine);
    const U32 BLUE_AREA_MIN = 300;
    const U32 BLUE_AREA_MAX = 2000;
    if(blue_temp)
    {
        for(i=0;i<blue_temp;i++)
        {
            if(BLUE_AREA_MIN <= blue_vector[i].first && blue_vector[i].first <= BLUE_AREA_MAX)
            {           
                draw_fpga_video_data_full(Mine);
                flip();
                free(Mine);
                free(input);
                free(gray);
                ++Stage;
                return;
            }
        }
    }

    U16 Gray_T = gray_sum / gray_count;
    Gray_T = Gray_T >= 245 ? 255 : Gray_T + 10;
    for(i=range.start_y;i<range.end_y;i++)
    {
        for(j=range.start_x;j<range.end_x;j++)
        {
            if(Gray_T > input[pos(i,j)])input[pos(i,j)] = 0xFFFF;
            else input[pos(i,j)] = 0x0000;
        }
    }

    Labeling area;
    U16 temp_i = ColorLabeling(0xFFFF, area, range, input);

    if(temp_i == 0)
    {
        draw_fpga_video_data_full(input);
        flip();
        Motion_Command(GOSTRAIGHT_LOOKDOWN90);
        free(Mine);
        free(gray);
        free(input);
        return;
    }

    U16 Mine_temp = 0;
    U16 Mine_Min_Y = 255;
    POS Mine_pos;
    for(i=0;i<area.size();i++)
    {
        U32 mine_area = area[i].first;
        if(MINE_AREA_MIN <= mine_area && mine_area <= MINE_AREA_MAX)
        {
            if(Mine_Min_Y > area[i].second.y)
            {
                Mine_Min_Y = area[i].second.y;
                Mine_pos = area[i].second;
            }
        }
    }

    if(!Mine_temp)
    {
        draw_fpga_video_data_full(input);
        flip();
        free(Mine);
        free(input);
        free(gray);
        return;
    }

    short mine_x = Mine_pos.x;
    const U16 Mine_mid = (range.start_x + range.end_x) >> 1;
    if(abs(Mine_mid - mine_x) <= 4)
    {
        if(BEFORE_GO_LEFT_RIGHT == BEFORE_GO_LEFT)
        {
            if(MOVE_COUNT == 7)
            {
                MOVE_COUNT = 0;
                BEFORE_GO_LEFT_RIGHT = BEFORE_GO_RIGHT;
            }   
            Motion_Command(GOLEFT);
        }
        else if(BEFORE_GO_LEFT_RIGHT == BEFORE_GO_RIGHT)
        {
            if(MOVE_COUNT == 7)
            {
                MOVE_COUNT = 0;
                BEFORE_GO_LEFT_RIGHT = BEFORE_GO_LEFT;
            }
            Motion_Command(GORIGHT);
        }
    }
    else if(Mine_mid < mine_x)
    {
        Motion_Command(GORIGHT);
    }
    else
    {
        Motion_Command(GOLEFT);
    }

    draw_fpga_video_data_full(input);
    flip();    
    free(Mine);
    free(input);
    free(gray);
    return;
}

U16 Make_Gray_16(U8 input)
{
    return ((((input >> 3) & 0x001F) << 11) | (((input >> 2) & 0x003F) << 5) | ((input >> 3) & 0x001F));
}

U8 Make_Gray_8(U16 input)
{
    U8 red = (input & 0xF800) >> 11;
    U8 green = (input & 0x07E0) >> 5;
    U8 blue = (input & 0x001F);
    red = red << 3 | red >> 2;
    green = green << 2 | green >> 4;
    blue = blue << 3 | blue >> 2;
    return (red + green + blue) / 3;
}

U16 Gaussian[180*120];
U8 Line_Gray[180*120];
short Line_Min[180];

int Line_Matching()
{
    static int return_count = 0;
    if(Robot_Head_position != HEAD_DOWN_60)
    {
        Robot_Head_position = HEAD_DOWN_60;
        Motion_Command(HEAD_DOWN_60);
    }
    if(Robot_Head_front_position != HEAD_RIGHT_90)
    {
        Robot_Head_front_position = HEAD_RIGHT_90;
        Motion_Command(HEAD_RIGHT_90);
    }
    //Gaussian filtering => Binary Threshold(60 ~ 70) => Labeling
    short i,j;
    short m,n;
    //const U8 filter[5][5]  = {{1,4,7,4,1},{4,16,26,16,4},{7,26,41,26,7},{4,16,26,16,4},{1,4,7,4,1}};
    const U8 filter[5][5] = {{2,4,5,4,2},{4,9,12,9,4},{5,12,15,12,5},{4,9,12,9,4},{2,4,5,4,2}};
    //const U8 filter[5][5] = {{2,7,12,7,2},{7,31,52,31,7},{12,52,127,52,12},{7,31,52,31,7},{2,7,12,7,2}};
    //const U8 filter[5][5] = {{1,5,9,5,1},{5,25,40,25,5},{9,37,68,37,9},{5,25,40,25,5},{1,5,9,5,1}};
    const short filter_dx[3][3] = {{-1,-1,-1},{0,0,0},{1,1,1}};
    const short filter_dy[3][3] = {{-1,0,1},{-1,0,1},{-1,0,1}};
    const Range _IsVaild_ = {140,170,0,120};
    U16 *input = (U16*)malloc(2*180*120);
    read_fpga_video_data(input);

    U32 Gray_Sum_ = 0;
    for(i=_IsVaild_.start_y;i<_IsVaild_.end_y;i++)
    {
        for(j=_IsVaild_.start_x;j<_IsVaild_.end_x;j++)
        {
            if(i == _IsVaild_.start_y)
            {
                Line_Min[j] = 255;
            }
            U32 Gaussian_Cnt = 0;
            U32 Gaussian_Sum = 0;
            for(m=-2;m<=2;m++)
            {
                for(n=-2;n<=2;n++)
                {
                    short dy = i + m;
                    short dx = j + n;

                    if(!Labeling_Area_Vaild(dy,dx,_IsVaild_))continue;

                    Gaussian_Cnt+=filter[m+2][n+2];
                    Gaussian_Sum+=filter[m+2][n+2]*Make_Gray_8(input[pos(dy,dx)]);
                }
            }
            Line_Gray[pos(i,j)]=Gaussian_Sum / Gaussian_Cnt;
            Gray_Sum_ += Line_Gray[pos(i,j)];
        }
    }

    //U32 Line_Area_ = (_IsVaild_.end_x - _IsVaild_.start_x) * (_IsVaild_.end_y - _IsVaild_.start_y);
    //Strange
    U8 Threshold_Gray = Gray_Sum_ / (height * width) + 33;
    //U8 Threshold_Gray = Gray_Sum_ / Line_Area_;

    if(PRINT_THRESHOLD_ABOUT_LINE)printf("Threshold : %d\n",Threshold_Gray);
    U32 pos_y = 0;
    U32 pos_cnt = 0;
    short line_min_x=255, line_max_x=0;
    for(i=_IsVaild_.start_y;i<_IsVaild_.end_y;i++)
    {
        for(j=_IsVaild_.start_x;j<_IsVaild_.end_x;j++)
        {
            if(Line_Gray[pos(i,j)] < Threshold_Gray)
            {
                input[pos(i,j)] = 0xFFFF;
                if(Line_Min[j] > i && i >= 5)Line_Min[j]=i;
            }
            else
            {
                input[pos(i,j)] = 0x0000;
            }
            if(i == _IsVaild_.end_y - 1)
            {
                if(Line_Min[j] != 255)
                {
                    line_min_x = min(line_min_x,j);
                    line_max_x = max(line_max_x,j);
                    pos_cnt++;
                    pos_y += Line_Min[j];
                }
            }
        }
    }

    //printf("%d\n",pos_y);
    pos_y = pos_y / pos_cnt;

    int mid = (line_max_x - line_min_x) >> 1;
    if(PRINT_THRESHOLD_ABOUT_LINE)printf("%d %d\n",line_max_x, line_min_x);
    int degree = 0;

    /*for(i=line_min_x;i<line_max_x;i++)
    {
        if(Line_Min[j] == pos_y)
        {
            mid = j;
            break;
        }
    }
    */
    for(i=line_min_x;i<line_max_x;i++)
    {
        if(mid < i) // + 
        {
            degree+=(Line_Min[i] - pos_y);
        }
        else  // -
        {
            degree-=(pos_y - Line_Min[i]);
        }
    }
    
    for(i=_IsVaild_.start_x;i<_IsVaild_.end_x;i++)
    {
        input[pos(Line_Min[i],i)]=0x07E0;
        input[pos(pos_y,i)]=0xF800;
    }    

    if(PRINT_THRESHOLD_ABOUT_LINE)printf("pos_y : %d\n",pos_y);
    if(pos_y <= 10)
    {
        Motion_Command(GOLEFT);
    }
    else if(abs(Line_Min[line_min_x] - Line_Min[line_max_x])<=1)
    {
        if(pos_y<42)
        {
            Motion_Command(GOLEFT);
        }
        else if(pos_y>48)
        {
            Motion_Command(GORIGHT);
        }
        else
        {
            Motion_Command(SoundPlay);
            
            if(return_count)
            {
                return_count = 0;
                Motion_Command(LOOK_FORWARD);
                return 0;
            }
            else
            {
                return_count++;
            }
        }
    }
    else if(Line_Min[line_min_x] > Line_Min[line_max_x])
    {
        Motion_Command(TURNLEFT);
    }
    else
    {
        Motion_Command(TURNRIGHT);
    }

    /*printf("%d\n", degree);

    if(-4<degree&&degree<4)
    {
        Motion_Command(SoundPlay);
    }
    else if(degree > 0)
    {
        Motion_Command(TURNRIGHT);
    }
    else if(degree < 0)
    {
        Motion_Command(TURNLEFT);
    }*/


    //Labeling_ 라인 전용 라벨링을 만들어야 함
    /*Labeling area;
    ColorLabeling(0xFFFF, area, _IsVaild_, input);

    U32 temp_i;
    printf("=========================================\n");
    for(i=0;i<area.size();i++)
    {
        printf("i : %d => %d\n",i,area[i].first);
        if(500<=area[i].first&&area[i].first<=2500)
        {
            temp_i = i + 1;
        }
    }

    for(i=_IsVaild_.start_y;i<_IsVaild_.end_y;i++)
    {
        for(j=_IsVaild_.start_x;j<_IsVaild_.end_x;j++)
        {
            if(input[pos(i,j)])input[pos(i,j)]=0xFFFF;
        }
    }*/

    draw_fpga_video_data_full(input);
    flip();
    free(input);

    return 1;
}

int Line_Forward(int &Stage)
{
    U16 *input = (U16*)malloc(2*180*120);
    
    if(Robot_Head_position != HEAD_DOWN_60)
    {
        Robot_Head_position = HEAD_DOWN_60;
        Motion_Command(HEAD_DOWN_60);
    }

    if(Robot_Head_front_position != HEAD_MID_90)
    {
        Robot_Head_front_position = HEAD_MID_90;
        Motion_Command(HEAD_MID_90);
    }

    read_fpga_video_data(input);

    

    draw_fpga_video_data_full(input);
    flip();
    free(input);
    return 1;
}

int Red_Mid()
{
    if(Robot_Head_position != HEAD_DOWN_90)
    {
        Robot_Head_position = HEAD_DOWN_90;
        Motion_Command(HEAD_DOWN_90);
    }

    short i, j;
    U16 *input = (U16*)malloc(2*180*120);

    read_fpga_video_data(input);

    ChangeColor(input, IsRed);

    Labeling area;
    Range range = {0,180,60,120};

    U16 temp_i = ColorLabeling(0xFFFF, area,range,input);

    U32 max_area = area[temp_i - 1].first;
    POS pos = area[temp_i - 1].second;

    for(i=0;i<height;i++)
    {
        for(j=0;j<width;j++)
        {
            if(input[pos(i,j)] == temp_i)
            {
                input[pos(i,j)] = 0xF800;
            }
            else
            {
                input[pos(i,j)] = 0x0000;
            }
        }
    }

    for(i=0;i<height;i++)
    {
        input[pos(i,pos.x)] = 0x07E0;
    }

    if(pos.x >= 95)
    {
        Motion_Command(GOLEFT);
    }
    else if(pos.x <= 85)
    {
        Motion_Command(GORIGHT);
    }
    else
    {
        draw_fpga_video_data_full(input);
        flip();
        free(input);
        return 0;
    }

    draw_fpga_video_data_full(input);
    flip();
    free(input);
    return 1;
}

void Test_Find_Mine(int &Stage)
{
    static int Line_Check_cnt = 0;
    U16 *input = (U16*)malloc(2*180*120);
    U16 *Mine = (U16*)malloc(2*180*120);
    U16 *Save_Mine = (U16*)malloc(2*180*120);
    U16 *blue = (U16*)malloc(2*180*120);

    const U8 filter[5][5] = {{2,4,5,4,2},{4,9,12,9,4},{5,12,15,12,5},{4,9,12,9,4},{2,4,5,4,2}};
    

    short i, j;
    short m, n;
    if(Robot_Head_position != HEAD_DOWN_90)
    {
        Robot_Head_position = HEAD_DOWN_90;
        Motion_Command(HEAD_DOWN_90);
    }
    if(Robot_Head_front_position != HEAD_MID_90)
    {
        Robot_Head_front_position = HEAD_MID_90;
        Motion_Command(HEAD_MID_90);
    }

    read_fpga_video_data(blue);
    read_fpga_video_data(Mine);

    Range blue_range = {0,180,0,120};
    Range mine_range = {40,140,50,90};

    //ChangeColor(blue, IsBlue);
    
    U32 Gray_Sum_ = 0;

    for(i=mine_range.start_y;i<mine_range.end_y;i++)
    {
        for(j=mine_range.start_x;j<mine_range.end_x;j++)
        {
            U32 Gaussian_Cnt = 0;
            U32 Gaussian_Sum = 0;
            for(m=-2;m<=2;m++)
            {
                for(n=-2;n<=2;n++)
                {
                    short dy = i + m;
                    short dx = j + n;

                    if(!Labeling_Area_Vaild(dy,dx,mine_range))continue;

                    Gaussian_Cnt += filter[m+2][n+2];
                    Gaussian_Sum += filter[m+2][n+2]*Make_Gray_8(Mine[pos(dy,dx)]);
                }
            }
            Save_Mine[pos(i,j)] = Gaussian_Sum / Gaussian_Cnt;
            Gray_Sum_ += Save_Mine[pos(i,j)];
        }
    }
    
    U32 GRAY_AREA = (mine_range.end_y - mine_range.start_y) * (mine_range.end_x - mine_range.start_x); 
    U8 Threshold_Gray = Gray_Sum_ / GRAY_AREA;
    Threshold_Gray -= 35;

    printf("Threshold : %d\n",Threshold_Gray);

    for(i=mine_range.start_y;i<mine_range.end_y;i++)
    {
        for(j=mine_range.start_x;j<mine_range.end_x;j++)
        {
            if(Save_Mine[pos(i,j)] < Threshold_Gray)
            {
                Save_Mine[pos(i,j)] = 0xFFFF;
            }
            else
            {
                Save_Mine[pos(i,j)] = 0x0000;
            }
        }
    }
    
    Labeling area;
    U16 temp_i = ColorLabeling(0xFFFF, area, mine_range, Save_Mine);

    const U32 mine_min_area = 60;
    const U32 mine_max_area = 200;

    if(area.size() != 0)
    {
        for(i=0;i<area.size();i++)
        {
            if(50 <= area[i].first && area[i].first <= 100)
            {
                temp_i = i + 1;
            }
        }

        printf("Area : %d Pos_x : %d Pos_y : %d\n",area[temp_i-1].first,area[temp_i-1].second.x,area[temp_i-1].second.y);
        for(i=mine_range.start_y;i<mine_range.end_y;i++)
        {
            for(j=mine_range.start_x;j<mine_range.end_x;j++)
            {
                if(i == area[temp_i - 1].second.y || j == area[temp_i - 1].second.x)
                {
                    Save_Mine[pos(i,j)] = 0x07E0;
                }
                else if(Save_Mine[pos(i,j)] == temp_i)
                {
                    Save_Mine[pos(i,j)] = 0xFFFF;
                }
                else
                {
                    Save_Mine[pos(i,j)] = 0x0000;
                }
            }
        }
        U16 pos_x = area[temp_i-1].second.x;
        U16 pos_y = area[temp_i-1].second.y;
        
        if(pos_x <= 90)//45<=pos_x&&
        {
            Motion_Command(GOLEFT);
        }
        else if(90< pos_x)//&&pos_x <= 130
        {
            Motion_Command(GORIGHT);
        }
        else
        {
            Motion_Command(GOSTRAIGHT_LOOKDOWN90);
            ++Line_Check_cnt;
            if(Line_Check_cnt >= 3)
            {
                Line_Check_cnt = 0;
                while(Line_Matching_Only_Turn());
            }
        }
    }
    else
    {
        Motion_Command(GOSTRAIGHT_LOOKDOWN90);
        Motion_Command(HEAD_DOWN_90);
        ++Line_Check_cnt;
        if(Line_Check_cnt >= 3)
        {
            Line_Check_cnt = 0;
            while(Line_Matching());
        }
    }
    


    draw_fpga_video_data_full(Save_Mine);
    flip();

    free(input);
    free(Mine);
    free(blue);

    return;
}

int Line_Matching_Only_Turn()
{
    static int return_count = 0;
    if(Robot_Head_position != HEAD_DOWN_60)
    {
        Robot_Head_position = HEAD_DOWN_60;
        Motion_Command(HEAD_DOWN_60);
    }
    if(Robot_Head_front_position != HEAD_RIGHT_90)
    {
        Robot_Head_front_position = HEAD_RIGHT_90;
        Motion_Command(HEAD_RIGHT_90);
    }
    //Gaussian filtering => Binary Threshold(60 ~ 70) => Labeling
    short i,j;
    short m,n;
    //const U8 filter[5][5]  = {{1,4,7,4,1},{4,16,26,16,4},{7,26,41,26,7},{4,16,26,16,4},{1,4,7,4,1}};
    const U8 filter[5][5] = {{2,4,5,4,2},{4,9,12,9,4},{5,12,15,12,5},{4,9,12,9,4},{2,4,5,4,2}};
    //const U8 filter[5][5] = {{2,7,12,7,2},{7,31,52,31,7},{12,52,127,52,12},{7,31,52,31,7},{2,7,12,7,2}};
    //const U8 filter[5][5] = {{1,5,9,5,1},{5,25,40,25,5},{9,37,68,37,9},{5,25,40,25,5},{1,5,9,5,1}};
    const short filter_dx[3][3] = {{-1,-1,-1},{0,0,0},{1,1,1}};
    const short filter_dy[3][3] = {{-1,0,1},{-1,0,1},{-1,0,1}};
    const Range _IsVaild_ = {140,170,0,120};
    U16 *input = (U16*)malloc(2*180*120);
    read_fpga_video_data(input);

    U32 Gray_Sum_ = 0;
    for(i=_IsVaild_.start_y;i<_IsVaild_.end_y;i++)
    {
        for(j=_IsVaild_.start_x;j<_IsVaild_.end_x;j++)
        {
            if(i == _IsVaild_.start_y)
            {
                Line_Min[j] = 255;
            }
            U32 Gaussian_Cnt = 0;
            U32 Gaussian_Sum = 0;
            for(m=-2;m<=2;m++)
            {
                for(n=-2;n<=2;n++)
                {
                    short dy = i + m;
                    short dx = j + n;

                    if(!Labeling_Area_Vaild(dy,dx,_IsVaild_))continue;

                    Gaussian_Cnt+=filter[m+2][n+2];
                    Gaussian_Sum+=filter[m+2][n+2]*Make_Gray_8(input[pos(dy,dx)]);
                }
            }
            Line_Gray[pos(i,j)]=Gaussian_Sum / Gaussian_Cnt;
            Gray_Sum_ += Line_Gray[pos(i,j)];
        }
    }

    //U32 Line_Area_ = (_IsVaild_.end_x - _IsVaild_.start_x) * (_IsVaild_.end_y - _IsVaild_.start_y);
    //Strange
    U8 Threshold_Gray = Gray_Sum_ / (height * width) + 40;
    //U8 Threshold_Gray = Gray_Sum_ / Line_Area_;

    if(PRINT_THRESHOLD_ABOUT_LINE)printf("Threshold : %d\n",Threshold_Gray);
    U32 pos_y = 0;
    U32 pos_cnt = 0;
    short line_min_x=255, line_max_x=0;
    for(i=_IsVaild_.start_y;i<_IsVaild_.end_y;i++)
    {
        for(j=_IsVaild_.start_x;j<_IsVaild_.end_x;j++)
        {
            if(Line_Gray[pos(i,j)] < Threshold_Gray)
            {
                input[pos(i,j)] = 0xFFFF;
                if(Line_Min[j] > i && i >= 5)Line_Min[j]=i;
            }
            else
            {
                input[pos(i,j)] = 0x0000;
            }
            if(i == _IsVaild_.end_y - 1)
            {
                if(Line_Min[j] != 255)
                {
                    line_min_x = min(line_min_x,j);
                    line_max_x = max(line_max_x,j);
                    pos_cnt++;
                    pos_y += Line_Min[j];
                }
            }
        }
    }

    pos_y = pos_y / pos_cnt;

    int mid = (line_max_x - line_min_x) >> 1;
    printf("%d %d\n",line_max_x, line_min_x);
    int degree = 0;

    for(i=line_min_x;i<line_max_x;i++)
    {
        if(mid < i) // + 
        {
            degree+=(Line_Min[i] - pos_y);
        }
        else  // -
        {
            degree-=(pos_y - Line_Min[i]);
        }
    }
    
    for(i=_IsVaild_.start_x;i<_IsVaild_.end_x;i++)
    {
        input[pos(Line_Min[i],i)]=0x07E0;
        input[pos(pos_y,i)]=0xF800;
    }    

    printf("pos_y : %d\n",pos_y);
    if(pos_y <= 10)
    {
        Mine_Distance_Save = GOLEFT;
        //Motion_Command(GOLEFT);
    }
    if(abs(Line_Min[line_min_x] - Line_Min[line_max_x])<=1)
    {
        if(pos_y<42)
        {
            Mine_Distance_Save = GOLEFT;
            //Motion_Command(GOLEFT);
        }
        else if(pos_y>48)
        {
            Mine_Distance_Save = GORIGHT;
            //Motion_Command(GORIGHT);
        }
        Motion_Command(SoundPlay);
        
        if(return_count)
        {
            return_count = 0;
            Motion_Command(LOOK_FORWARD);
            return 0;
        }
        else
        {
            return_count++;
        }
    }
    else if(Line_Min[line_min_x] > Line_Min[line_max_x])
    {
        Motion_Command(TURNLEFT);
    }
    else
    {
        Motion_Command(TURNRIGHT);
    }

    draw_fpga_video_data_full(input);
    flip();
    free(input);

    return 1;
}

int Red_Mid_() //Test
{
    if(Robot_Head_position != HEAD_DOWN_60)
    {
        Robot_Head_position = HEAD_DOWN_60;
        Motion_Command(HEAD_DOWN_60);
    }

    if(Robot_Head_position != HEAD_MID_90)
    {
        Robot_Head_front_position = HEAD_MID_90;
        Motion_Command(HEAD_MID_90);
    }

    U16 *input = (U16*)malloc(2*180*120);
    read_fpga_video_data(input);

    short i,j;
    

    draw_fpga_video_data_full(input);
    flip();
    free(input);
    return 0;
}

