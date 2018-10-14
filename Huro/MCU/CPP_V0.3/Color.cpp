
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

U16 ChangetoRGB(HSV hsv)
{
    BYTE region, remainder, p, q, t;
    U8 red, green, blue;
    U16 output;
	if (!hsv.S)
	{
        red = green = blue = hsv.V;
        output = (((red >> 3) & 0x001F) << 11) | (((green >> 2) & 0x003F) << 5) | ((blue >> 3) & 0x001F);
        return output;
	}

    region = hsv.H / 43;
    remainder = (hsv.H - (region * 43)) * 6;
    
    p = (hsv.V * (255 - hsv.S)) >> 8;
    q = (hsv.V * (255 - (hsv.S * remainder) >> 8)) >> 8;
    t = (hsv.V * (255 - (hsv.S * (255 - remainder)) >> 8)) >> 8;
    
	switch (region)
	{
	case 0:
        red = hsv.V;
        green = t;
        blue = p;
		break;
	case 1:
        red = q;
        green = hsv.V;
        blue = p;
		break;
	case 2:
        red = p;
        green = hsv.V;
        blue = t;
		break;
	case 3:
        red = p;
        green = q;
        blue = hsv.V;
        break;
	case 4:
        red = t;
        green = p;
        blue = hsv.V;
		break;
	default:
        red = hsv.V;
        green = p;
        blue = q;
        break;
	}
    
    output = (((red >> 3) & 0x001F) << 11) | (((green >> 2) & 0x003F) << 5) | ((blue >> 3) & 0x001F);
    return output;
}

int FindColor(U16 rgb)
{
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
    //return (hsv.H <= 30 || hsv.H >= 210);  //220~20
    return (hsv.H <= 30 || hsv.H >= 210);  //220~20
    
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

U8 Make_Gray(U16 input)
{
    U8 red, green, blue;

    red   = (input & 0xF800) >> 11;
    green = (input & 0x07E0) >> 5;
    blue  = (input & 0x001F);

    red   =  red << 3 | red >> 2;
    green =  green << 2 | green >> 4;
    blue  =  blue << 3 | blue >> 2;
    return (red + green + blue) / 3;
}

bool IS_RED(U16 input)
{
    
}