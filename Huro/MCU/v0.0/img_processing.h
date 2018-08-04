#ifndef __IMG_PROCESSING_H
#define __IMG_PROCESSING_H

#define bool int
#define false 0
#define true 1

#define MAX3(x,y,z)   (((x)>(y))?((x)>(z))?(x):(z):((y)>(z))?(y):(z))
#define MIN3(x,y,z)   (((x)>(y))?((y)>(z))?(z):(y):((x)>(z))?(z):(x))
#define max2(x,y)      ((x)>(y)?(x):(y))
#define min2(x,y)      ((x)>(y)?(y):(x))
#define pos(y,x)     ((y)*180+(x))
#define abs(x)       ((x)<0?-(x):(x))

#endif