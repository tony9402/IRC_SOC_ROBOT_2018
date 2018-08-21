
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <queue>
#include <stack>
#include "img_processing.h"

using namespace std;

HSV ChangetoHSV(U16 buf)
{
    RGB rgb;

    rgb.red = red5(buf);
    rgb.green = green6(buf);
    rgb.blue = blue5(buf);

    //It don't exist about changing 565bit to 888bit
    
    RGB888 rgb888;
    rgb888.red = rgb.red << 3 | rgb.red >> 2;
    rgb888.green = rgb.green << 2 | rgb.green >> 4;
    rgb888.blue = rgb.blue << 3 | rgb.blue >> 2;
    
    HSV out;

    BYTE _max_, _min_;

    _max_ = MAX3(rgb888.red, rgb888.green, rgb888.blue);
    _min_ = MIN3(rgb888.red, rgb888.green, rgb888.blue);

    out.V = _max_;
    if(!out.V)
    {
        out.H = 0;
        out.S = 0;
        return out;
    }
    
    out.S = 255 * (long)(_max_ - _min_) / out.V;
    if(!out.S)
    {
        out.H = 0;
        return out;
    }

    if(_max_ == rgb888.red)
    {
        out.H = 0 + 43 * (rgb888.green - rgb888.blue) / (_max_ - _min_);
    }
    else if(_max_ == rgb888.green)
    {
        out.H = 85 + 43 * (rgb888.blue - rgb888.red) / (_max_ - _min_);
    }
    else
    {
        out.H = 171 + 43 * (rgb888.red - rgb888.green) / (_max_ - _min_);
    }
    return out;
}

//아직 색상 값 범위 맞춰야 함
//
int FindColor(HSV hsv, U16 rgb)
{
    BYTE red = red5(rgb);
    BYTE green = green6(rgb);
    BYTE blue = blue5(rgb);

    if(abs(blue-red) <= 2 && abs((green>>1) - blue) <= 3 && abs((red - (green>>1)) <= 3) && red < 8 && green < 15 && blue < 8)
    {
        return IsBlack;
    }
    if(hsv.H <= 30 || hsv.H > 220)
    {
        return IsRed;
    }
    if(70<=hsv.H && hsv.H <= 120)
    {
        return IsGreen;
    }   
    if(125 <= hsv.H && hsv.H <= 190)
    {
        return IsBlue;
    }
    if(15  <= hsv.H && hsv.H <= 25)
    {
        return IsOrange;
    }
    if(35  <= hsv.H && hsv.H <= 70)
    {
        return IsYellow;
    }
    return 0;
}

//다리는 인식, 하지만 값을 조금 더 수정해야함
bool ISGREEN(U16 rgb)
{
    HSV hsv = ChangetoHSV(rgb); 
    return (60<=hsv.H&&hsv.H<=120&&25<=hsv.S&&25<=hsv.V&&hsv.V<=245);
}

//전체화면 라벨링
//vector<pair<pair<U32,POS>, Range> > &area
// -> U32에 해당하는건 넓이, POS는 (무게)중심 좌표
// -> Range는 각 라벨링 된 것의 x,y의 최대값과 최솟값
int ColorLabelingFULL(U16 color, vector<pair<pair<U32, POS>, Range> > &area, U16 *input)
{
   
    int count = 0;
    short i, j, k;
    pair<short, short> now;
    const int dx[] = {-1,1,0,0};
    const int dy[] = {0,0,-1,1};

    queue<pair<short, short> > q;
    U32 area_cal = 0, sum_x, sum_y;
    int *visit = (int*)malloc(sizeof(int)*height*width);
    memset(visit, 0, sizeof(visit));

    POS pos_input;
    Range range;
    BYTE MIN_X, MAX_X, MIN_Y, MAX_Y;

    for(i=0;i<height;i++)
    {
        for(j=0;j<width;j++)
        {
            MIN_X = MIN_Y = 255;
            MAX_X = MAX_Y = 0;
            if(input[pos(i,j)] == color && visit[pos(i,j)] == false)
            {
                ++count;
                area_cal = sum_x = sum_y = 0;
                q.push(make_pair(i,j));
                visit[pos(i,j)] = true;
                input[pos(i,j)] = count; // count
                while(!q.empty())
                {
                    ++area_cal;
                    now = q.front();
                    if(now.first < MIN_Y)MIN_Y = now.first;
                    if(now.first > MAX_Y)MAX_Y = now.first;
                    if(now.second < MIN_X)MIN_X = now.second;
                    if(now.second > MAX_X)MAX_X = now.second;
                    sum_x += now.second;
                    sum_y += now.first;
                    q.pop();
                    for(k=0;k<4;k++)
                    {
                        if(now.first + dy[k] < 0 || now.first + dy[k] >= height || now.second + dx[k] < 0 || now.second + dx[k] >= width)continue;
                        if(input[pos(now.first + dy[k],now.second + dx[k])] == color && visit[pos(now.first + dy[k],now.second + dx[k])] == false)
                        {
                            visit[pos(now.first + dy[k], now.second + dx[k])] = true;
                            input[pos(now.first + dy[k], now.second + dx[k])] = count; //count
                            q.push(make_pair(now.first + dy[k], now.second + dx[k]));
                        }
                    }
                }
                if(area_cal != 0){
                    pos_input.x = sum_x / area_cal;
                    pos_input.y = sum_y / area_cal;
                    range.start_x = MIN_X;
                    range.end_x = MAX_X;
                    range.start_y = MIN_Y;
                    range.end_y = MAX_Y;
                    area.push_back(make_pair(make_pair(area_cal, pos_input), range));
                }
            }
            else if(visit[pos(i,j)] == false)
            {
                if(color == 0x0000)
                    input[pos(i,j)] = 0xFFFF;
                else
                    input[pos(i,j)] = 0x0000;
            }
        }
    }

    free(visit);
    return count;
}

int ColorLabeling(U16 color, vector<pair<U32, POS> > &area, Range &range, U16 *input)
{
    int count = 0;
    short i, j, k;
    pair<short, short> now;
    const int dx[] = {-1,1,0,0};
    const int dy[] = {0,0,-1,1};

    queue<pair<short, short> > q;
    U32 area_cal = 0, sum_x, sum_y;
    int *visit = (int*)malloc(sizeof(int)*height*width);
    memset(visit,0,sizeof(visit));

    POS pos_input;

    for(i=range.start_y;i<range.end_y;i++)
    {
        for(j=range.start_x;j<range.end_x;j++)
        {
            if(input[pos(i,j)] == color && visit[pos(i,j)] == false)
            {
                ++count;
                area_cal = sum_x = sum_y = 0;
                q.push(make_pair(i,j));
                visit[pos(i,j)] = true;
                input[pos(i,j)] = count;
                while(!q.empty())
                {
                    ++area_cal;
                    now = q.front();
                    sum_x += now.second;
                    sum_y += now.first;
                    q.pop();
                    for(k=0;k<4;k++)
                    {
                        if(now.first + dy[k] < range.start_y || now.first + dy[k] >= range.end_y || now.second + dx[k] < range.start_x || now.second + dx[k] >= range.end_x)continue;
                        if(input[pos(now.first + dy[k],now.second + dx[k])] == color && visit[pos(now.first + dy[k],now.second + dx[k])] == false)
                        {
                            input[pos(now.first + dy[k], now.second + dx[k])] = count;
                            visit[pos(now.first + dy[k], now.second + dx[k])] = true;
                            q.push(make_pair(now.first + dy[k], now.second + dx[k]));
                        }
                    }
                }
                if(area_cal != 0){
                    pos_input.x = sum_x / area_cal;
                    pos_input.y = sum_y / area_cal;
                    area.push_back(make_pair(area_cal, pos_input));
                }
            }
            else if(visit[pos(i,j)] == false)
            {
                if(color == 0x0000)
                    input[pos(i,j)] = 0xFFFF;
                else
                    input[pos(i,j)] = 0x0000;
            }
        }
    }

    free(visit);
    return count;
}

