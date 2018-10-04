
#include<stack>

#include "SaveData.h"

using namespace std;

void MakeName(char *file_name, int number)
{
    char File_Name[] = {"DataFile"};
    char File_extension[] = {".txt"};
    char File_Num[15];

    stack<char> st;
    while(number)
    {
        st.push(number%10);
        number/=10;
    }
    int count=0;

    while(!st.empty())
    {
        File_Num[count++]=st.top()+'0';st.pop();
    }
    File_Num[count]='\0';

    strcat(file_name, (const char*)File_Name);
    strcat(file_name, (const char*)File_Num);
    strcat(file_name, (const char*)File_extension);

    return;
}

int FileOpen(FILE *file)
{
    char file_name[50];
    LOG_INFO info;
    int system_check = system(file_path);
    if(system_check)system(create_folder);

    file = fopen("data.log","a+");
    bool LOG_ERROR = ReadLog(file, info);
    if(LOG_ERROR)return LOG_IS_ERROR;
    fclose(file);

    int number = info.version + 1;
    MakeName(file_name, number);

    file = fopen(file_name,"wt");
    if(file == NULL)return OPEN_ERROR;

    return 0;
}

bool ReadLog(FILE *file, LOG_INFO &info)
{
    if(file == NULL)return true;

    bool Newfile = false;

    long file_position = feof(file);
    if(!file_position)Newfile = true;

    if(Newfile)
    {
        info.version = 0;
    }
    else
    {
        fscanf(file,"%d",&info.version);
    }
    return false;
}

