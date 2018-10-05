#ifndef __ROBOTICS_H
#define __ROBOTICS_H

#define MAX3(x,y,z)       (((x)>(y))?((x)>(z))?(x):(z):((y)>(z))?(y):(z))
#define MIN3(x,y,z)       (((x)>(y))?((y)>(z))?(z):(y):((x)>(z))?(z):(x))
#define MAX2(x,y)         ((x)>(y)?(x):(y))
#define MIN2(x,y)         ((x)>(y)?(y):(x))
#define exred(x)          (((x)&0xf800)>>11)
#define exgreen(x)        (((x)&0x07e0)>>5)
#define exblue(x)         (((x)&0x001f)>>0)
#define CONST_WIDTH       180
#define _height      120
#define _width       180
#define height       60
#define width        90
#define pos(y,x)          ((y)*_width+(x))
#define abs(x)            ((x)<0?-(x):(x))
#define gap_red_green(x)  (abs(exred(x) - exgreen(x)>>1))
#define gap_green_blue(x) (abs(exblue(x) - exgreen(x)>>1))
#define gap_blue_red(x)   (abs(exred(x)- exblue(x))

typedef unsigned char BYTE;
typedef unsigned short WORD;
typedef unsigned int DWORD;

typedef struct{
    BYTE H : 8;
    BYTE S : 8;
    BYTE V : 8;
}HSV;

typedef struct{
    BYTE red   : 8;
    BYTE green : 8;
    BYTE blue  : 8;
}_RGB888;

HSV RGB565toHSV888(U16 RGB)
{
    _RGB888 rgb = {(exred(RGB)<<3)|(exred(RGB)>>2), (exgreen(RGB)<<2)|(exgreen(RGB)>>4), (exblue(RGB)<<3)|(exblue(RGB)>>2)};
    HSV out;

    BYTE _max_, _min_;
    _max_ = MAX3(rgb.red, rgb.green, rgb.blue);
    _min_ = MIN3(rgb.red, rgb.green, rgb.blue);

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

    if(_max_ == rgb.red)
    {
        out.H = 0 + 43 * (rgb.green - rgb.blue) / (_max_ - _min_);
    }
    else if(_max_ == rgb.green)
    {
        out.H = 85 + 43 * (rgb.blue - rgb.red) / (_max_ - _min_);
    }
    else
    {
        out.H = 171 + 43 * (rgb.red - rgb.green) / (_max_ - _min_);
    }
    return out;
}

#endif