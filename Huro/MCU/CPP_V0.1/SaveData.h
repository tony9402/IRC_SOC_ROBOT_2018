#ifndef __SaveData_H
#define __SaveData_H

#include<cstdio>
#include<cstring>
#include<vector>
#include<iostream>
#include<cstdlib>

using namespace std;

#define LOG_IS_ERROR 2
#define OPEN_ERROR   3

//FILE SAVE SYSTEM
typedef struct{
    int version;
    char path[25];
}LOG_INFO;

const char file_path[] = "cd /mnt/f0/DataFolder";
const char create_folder[] = "mkdir /mnt/f0/DataFolder && cd /mnt/f0/DataFolder";

void MakeName(char *file_name, int number);
int FileOpen(FILE *file);
bool ReadLog(FILE *file, LOG_INFO &info);

#endif;