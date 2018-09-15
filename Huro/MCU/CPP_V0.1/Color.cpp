
#include "Color.h"

HSV ChangetoHSV(U16 buf)
{
    RGB rgb;

    rgb.red = red5(buf);
    rgb.green = green6(buf);
    rgb.blue = blue5(buf);

    BYTE RED = rgb.red << 3 | rgb.red >> 2;
    BYTE GREEN = rgb.green << 2 | rgb.green >> 4;
    BYTE BLUE = rgb.blue << 3 | rgb.blue >> 2;

    HSV out;

    BYTE _max_, _min_;

    _max_ = max3(RED, GREEN, BLUE);
    _min_ = min3(RED, GREEN, BLUE);

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

    if(_max_ == RED)
    {
        out.H = 0 + 43 * (GREEN - BLUE) / (_max_ - _min_);
    }
    else if(_max_ == GREEN)
    {
        out.H = 85 + 43 * (BLUE - RED) / (_max_ - _min_);
    }
    else
    {
        out.H = 171 + 43 * (RED - GREEN) / (_max_ - _min_);
    }
    return out;
}

int FindColor(U16 rgb)
{
    if(ISBLACK(rgb))return IsBlack;
    if(ISRED(rgb))return IsRed;
    if(ISGREEN(rgb))return IsGreen;
    if(ISBLUE(rgb))return IsBlue;
    if(ISYELLOW(rgb))return IsYellow;
    if(ISORANGE(rgb))return IsOrange;
}

bool ISBLACK(U16 rgb)
{
    BYTE red = red5(rgb);
    BYTE green = green6(rgb);
    BYTE blue = blue5(rgb);

    if(abs(blue-red)<=4&&abs((green>>1)-blue)<=7&&abs(red-(green>>1))<=7&&red<24&&green<48&&blue<24)
    {
        return true;
    }
    return false;
}

//RED_CHECK
//NOT_YET
bool ISRED(U16 rgb)
{
    HSV hsv = ChangetoHSV(rgb);
    return (hsv.H <= 10 || hsv.H >= 225);
}

//GREEN_CHECK
bool ISGREEN(U16 rgb)
{
    HSV hsv = ChangetoHSV(rgb); 
    return (55<=hsv.H&&hsv.H<=120&&25<=hsv.S&&25<=hsv.V);
}

//BLUE_CHECK
bool ISBLUE(U16 rgb)
{
    HSV hsv = ChangetoHSV(rgb);
    return (120<=hsv.H&&hsv.H<=165&&35<=hsv.S&&30<=hsv.V&&hsv.V<=250);
}

//YELLOW_CHECK
bool ISYELLOW(U16 rgb)
{
    HSV hsv = ChangetoHSV(rgb);
    return (25<=hsv.H&&hsv.H<=55&&50<=hsv.S&&30<=hsv.V&&hsv.V<=250);
}

//ORANGE_CHECK
//NOT_YET
bool ISORANGE(U16 rgb)
{
    HSV hsv = ChangetoHSV(rgb);
    return ((230<=hsv.H||hsv.H<=15)&&hsv.H<=180);
}