'Made by Minsang
'Date : 2018-07-26
'기본 프로그램 틀 제작

'RX_EXIT
'GOSUB_RX_EXIT

DIM I AS BYTE
DIM J AS BYTE
DIM MODE AS BYTE
DIM A AS BYTE
DIM A_old AS BYTE
DIM B AS BYTE
DIM C AS BYTE
DIM 보행속도 AS BYTE
DIM 좌우속도 AS BYTE
DIM 좌우속도2 AS BYTE
DIM 보행순서 AS BYTE
DIM 현재전압 AS BYTE
DIM 반전체크 AS BYTE
DIM 모터ONOFF AS BYTE
DIM 자이로ONOFF AS BYTE
DIM 기울기앞뒤 AS INTEGER
DIM 기울기좌우 AS INTEGER

DIM 곡선방향 AS BYTE

DIM 넘어진확인 AS BYTE
DIM 기울기확인횟수 AS BYTE
DIM 보행횟수 AS BYTE
DIM 보행COUNT AS BYTE

DIM 적외선거리값  AS BYTE

DIM S11  AS BYTE
DIM S16  AS BYTE
'************************************************
DIM NO_0 AS BYTE
DIM NO_1 AS BYTE
DIM NO_2 AS BYTE
DIM NO_3 AS BYTE
DIM NO_4 AS BYTE

DIM NUM AS BYTE

DIM BUTTON_NO AS INTEGER
DIM SOUND_BUSY AS BYTE
DIM TEMP_INTEGER AS INTEGER

CONST 앞뒤기울기AD포트 = 0
CONST 좌우기울기AD포트 = 1
CONST 기울기확인시간 = 20  'ms


CONST min = 61	'뒤로넘어졌을때
CONST max = 107	'앞으로넘어졌을때
CONST COUNT_MAX = 3


CONST 머리이동속도 = 10
'************************************************



PTP SETON 				'단위그룹별 점대점동작 설정
PTP ALLON				'전체모터 점대점 동작 설정

DIR G6A,1,0,0,1,0,0		'모터0~5번
DIR G6D,0,1,1,0,1,1		'모터18~23번
DIR G6B,1,1,1,1,1,1		'모터6~11번
DIR G6C,0,0,0,0,1,0		'모터12~17번

'************************************************

OUT 52,0	'머리 LED 켜기
'***** 초기선언 '************************************************

보행순서 = 0
반전체크 = 0
기울기확인횟수 = 0
보행횟수 = 5
모터ONOFF = 0

'****초기위치 피드백*****************************


TEMPO 230
MUSIC "cdefg"



SPEED 5
GOSUB MOTOR_ON

S11 = MOTORIN(11)
S16 = MOTORIN(16)

SERVO 11, 100
SERVO 16, S16



GOSUB 전원초기자세
GOSUB 기본자세


GOSUB 자이로INIT
GOSUB 자이로MID
GOSUB 자이로ON



PRINT "VOLUME 200 !"
PRINT "SOUND 12 !" '안녕하세요

GOSUB All_motor_mode3



GOTO MAIN	'시리얼 수신 루틴으로 가기

시작음:
    TEMPO 220
    MUSIC "O23EAB7EA>3#C"
    RETURN
    '************************************************
종료음:
    TEMPO 220
    MUSIC "O38GD<BGD<BG"
    RETURN
    '************************************************
에러음:
    TEMPO 250
    MUSIC "FFF"
    RETURN
    '************************************************
    '************************************************
MOTOR_ON: '전포트서보모터사용설정

    GOSUB MOTOR_GET

    MOTOR G6B
    DELAY 50
    MOTOR G6C
    DELAY 50
    MOTOR G6A
    DELAY 50
    MOTOR G6D

    모터ONOFF = 0
    GOSUB 시작음			
    RETURN

    '************************************************
    '전포트서보모터사용설정
MOTOR_OFF:

    MOTOROFF G6B
    MOTOROFF G6C
    MOTOROFF G6A
    MOTOROFF G6D
    모터ONOFF = 1	
    GOSUB MOTOR_GET	
    GOSUB 종료음	
    RETURN
    '************************************************
    '위치값피드백
MOTOR_GET:
    GETMOTORSET G6A,1,1,1,1,1,0
    GETMOTORSET G6B,1,1,1,0,0,1
    GETMOTORSET G6C,1,1,1,0,1,0
    GETMOTORSET G6D,1,1,1,1,1,0
    RETURN

    '************************************************
    '위치값피드백
MOTOR_SET:
    GETMOTORSET G6A,1,1,1,1,1,0
    GETMOTORSET G6B,1,1,1,0,0,1
    GETMOTORSET G6C,1,1,1,0,1,0
    GETMOTORSET G6D,1,1,1,1,1,0
    RETURN

    '************************************************
All_motor_Reset:

    MOTORMODE G6A,1,1,1,1,1,1
    MOTORMODE G6D,1,1,1,1,1,1
    MOTORMODE G6B,1,1,1,,,1
    MOTORMODE G6C,1,1,1,,1

    RETURN
    '************************************************
All_motor_mode2:

    MOTORMODE G6A,2,2,2,2,2
    MOTORMODE G6D,2,2,2,2,2
    MOTORMODE G6B,2,2,2,,,2
    MOTORMODE G6C,2,2,2,,2

    RETURN
    '************************************************
All_motor_mode3:

    MOTORMODE G6A,3,3,3,3,3
    MOTORMODE G6D,3,3,3,3,3
    MOTORMODE G6B,3,3,3,,,3
    MOTORMODE G6C,3,3,3,,3

    RETURN
    '************************************************
Leg_motor_mode1:
    MOTORMODE G6A,1,1,1,1,1
    MOTORMODE G6D,1,1,1,1,1
    RETURN
    '************************************************
Leg_motor_mode2:
    MOTORMODE G6A,2,2,2,2,2
    MOTORMODE G6D,2,2,2,2,2
    RETURN

    '************************************************
Leg_motor_mode3:
    MOTORMODE G6A,3,3,3,3,3
    MOTORMODE G6D,3,3,3,3,3
    RETURN
    '************************************************
Leg_motor_mode4:
    MOTORMODE G6A,3,2,2,1,3
    MOTORMODE G6D,3,2,2,1,3
    RETURN
    '************************************************
Leg_motor_mode5:
    MOTORMODE G6A,3,2,2,1,2
    MOTORMODE G6D,3,2,2,1,2
    RETURN
    '************************************************
Arm_motor_mode1:
    MOTORMODE G6B,1,1,1,,,1
    MOTORMODE G6C,1,1,1,,1
    RETURN
    '************************************************
Arm_motor_mode2:
    MOTORMODE G6B,2,2,2,,,2
    MOTORMODE G6C,2,2,2,,2
    RETURN

    '************************************************
Arm_motor_mode3:
    MOTORMODE G6B,3,3,3,,,3
    MOTORMODE G6C,3,3,3,,3
    RETURN
    '************************************************
    '***********************************************
    '***********************************************
    '**** 자이로감도 설정 ****
자이로INIT:

    GYRODIR G6A, 0, 0, 1, 0,0
    GYRODIR G6D, 1, 0, 1, 0,0

    GYROSENSE G6A,200,150,30,150,0
    GYROSENSE G6D,200,150,30,150,0

    RETURN
    '***********************************************
    '**** 자이로감도 설정 ****
자이로MAX:

    GYROSENSE G6A,250,180,30,180,0
    GYROSENSE G6D,250,180,30,180,0

    RETURN
    '***********************************************
자이로MID:

    GYROSENSE G6A,200,150,30,150,0
    GYROSENSE G6D,200,150,30,150,0

    RETURN
    '***********************************************
자이로MIN:

    GYROSENSE G6A,200,100,30,100,0
    GYROSENSE G6D,200,100,30,100,0
    RETURN
    '***********************************************
자이로ON:


    GYROSET G6A, 4, 3, 3, 3, 0
    GYROSET G6D, 4, 3, 3, 3, 0


    자이로ONOFF = 1

    RETURN
    '***********************************************
자이로OFF:

    GYROSET G6A, 0, 0, 0, 0, 0
    GYROSET G6D, 0, 0, 0, 0, 0


    자이로ONOFF = 0
    RETURN

    '************************************************
전원초기자세:
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  35,  90,
    MOVE G6C,100,  35,  90
    WAIT
    mode = 0
    RETURN
    '************************************************
안정화자세:
    MOVE G6A,98,  76, 145,  93, 101, 100
    MOVE G6D,98,  76, 145,  93, 101, 100
    MOVE G6B,100,  35,  90,
    MOVE G6C,100,  35,  90
    WAIT
    mode = 0

    RETURN
    '******************************************	


    '************************************************
기본자세:


    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT

    mode = 0

    RETURN
    '******************************************	
기본자세2:
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80
    WAIT

    mode = 0
    RETURN
    '********************************************
기본자세3:

    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,,
    WAIT

	RETURN
    '******************************************	
차렷자세:
    MOVE G6A,100, 56, 182, 76, 100, 100
    MOVE G6D,100, 56, 182, 76, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80
    WAIT
    mode = 2
    RETURN
    '******************************************
앉은자세:
    GOSUB 자이로OFF
    MOVE G6A,100, 145,  28, 145, 100, 100
    MOVE G6D,100, 145,  28, 145, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80
    WAIT
    mode = 1

    RETURN
    '******************************************


    '******************************************
    '**********************************************
    '**********************************************
RX_EXIT:

    ERX 9600, A, MAIN

    GOTO RX_EXIT
    '**********************************************
GOSUB_RX_EXIT:

    ERX 9600, A, GOSUB_RX_EXIT2

    GOTO GOSUB_RX_EXIT

GOSUB_RX_EXIT2:
    RETURN
    '**********************************************

뒤로일어나기:

    HIGHSPEED SETOFF
    PTP SETON 				
    PTP ALLON		

    GOSUB 자이로OFF

    GOSUB All_motor_Reset

    SPEED 15
    GOSUB 기본자세

    MOVE G6A,90, 130, ,  80, 110, 100
    MOVE G6D,90, 130, 120,  80, 110, 100
    MOVE G6B,150, 160,  10, 100, 100, 100
    MOVE G6C,150, 160,  10, 100, 100, 100
    WAIT

    MOVE G6B,170, 140,  10, 100, 100, 100
    MOVE G6C,170, 140,  10, 100, 100, 100
    WAIT

    MOVE G6B,185,  20, 70,  100, 100, 100
    MOVE G6C,185,  20, 70,  100, 100, 100
    WAIT
    SPEED 10
    MOVE G6A, 80, 155,  85, 150, 150, 100
    MOVE G6D, 80, 155,  85, 150, 150, 100
    MOVE G6B,185,  20, 70,  100, 100, 100
    MOVE G6C,185,  20, 70,  100, 100, 100
    WAIT



    MOVE G6A, 75, 162,  55, 162, 155, 100
    MOVE G6D, 75, 162,  59, 162, 155, 100
    MOVE G6B,188,  10, 100, 100, 100, 100
    MOVE G6C,188,  10, 100, 100, 100, 100
    WAIT

    SPEED 10
    MOVE G6A, 60, 162,  30, 162, 145, 100
    MOVE G6D, 60, 162,  30, 162, 145, 100
    MOVE G6B,170,  10, 100, 100, 100, 100
    MOVE G6C,170,  10, 100, 100, 100, 100
    WAIT
    GOSUB Leg_motor_mode3	
    MOVE G6A, 60, 150,  28, 155, 140, 100
    MOVE G6D, 60, 150,  28, 155, 140, 100
    MOVE G6B,150,  60,  90, 100, 100, 100
    MOVE G6C,150,  60,  90, 100, 100, 100
    WAIT

    MOVE G6A,100, 150,  28, 140, 100, 100
    MOVE G6D,100, 150,  28, 140, 100, 100
    MOVE G6B,130,  50,  85, 100, 100, 100
    MOVE G6C,130,  50,  85, 100, 100, 100
    WAIT
    DELAY 100

    MOVE G6A,100, 150,  33, 140, 100, 100
    MOVE G6D,100, 150,  33, 140, 100, 100
    WAIT
    SPEED 10
    GOSUB 기본자세

    넘어진확인 = 1

    DELAY 200
    GOSUB 자이로ON

    RETURN


    '**********************************************
앞으로일어나기:


    HIGHSPEED SETOFF
    PTP SETON 				
    PTP ALLON

    GOSUB 자이로OFF

    HIGHSPEED SETOFF

    GOSUB All_motor_Reset

    SPEED 15
    MOVE G6A,100, 15,  70, 140, 100,
    MOVE G6D,100, 15,  70, 140, 100,
    MOVE G6B,20,  140,  15
    MOVE G6C,20,  140,  15
    WAIT

    SPEED 12
    MOVE G6A,100, 136,  35, 80, 100,
    MOVE G6D,100, 136,  35, 80, 100,
    MOVE G6B,20,  30,  80
    MOVE G6C,20,  30,  80
    WAIT

    SPEED 12
    MOVE G6A,100, 165,  70, 30, 100,
    MOVE G6D,100, 165,  70, 30, 100,
    MOVE G6B,30,  20,  95
    MOVE G6C,30,  20,  95
    WAIT

    GOSUB Leg_motor_mode3

    SPEED 10
    MOVE G6A,100, 165,  45, 90, 100,
    MOVE G6D,100, 165,  45, 90, 100,
    MOVE G6B,130,  50,  60
    MOVE G6C,130,  50,  60
    WAIT

    SPEED 6
    MOVE G6A,100, 145,  45, 130, 100,
    MOVE G6D,100, 145,  45, 130, 100,
    WAIT


    SPEED 8
    GOSUB All_motor_mode2
    GOSUB 기본자세
    넘어진확인 = 1

    '******************************
    DELAY 200
    GOSUB 자이로ON
    RETURN

    '******************************************
    '******************************************
    '******************************************
    '**************************************************

    '******************************************
    '******************************************	
    '**********************************************

머리왼쪽30도:
    SPEED 머리이동속도
    SERVO 11,70
    RETURN

머리왼쪽45도:
    SPEED 머리이동속도
    SERVO 11,55
    RETURN

머리왼쪽60도:
    SPEED 머리이동속도
    SERVO 11,40
    RETURN

머리왼쪽90도:
    SPEED 머리이동속도
    SERVO 11,10
    RETURN

머리오른쪽30도:
    SPEED 머리이동속도
    SERVO 11,130
    RETURN

머리오른쪽45도:
    SPEED 머리이동속도
    SERVO 11,145
    RETURN	

머리오른쪽60도:
    SPEED 머리이동속도
    SERVO 11,160
    RETURN

머리오른쪽90도:
    SPEED 머리이동속도
    SERVO 11,190
    RETURN

머리좌우중앙:
    SPEED 머리이동속도
    SERVO 11,100
    RETURN

머리상하정면:
    SPEED 머리이동속도
    SERVO 11,100	
    SPEED 5
    GOSUB 기본자세
    RETURN

    '******************************************
전방하향80도:

    SPEED 3
    SERVO 16, 80
    ETX 9600,35
    RETURN
    '******************************************
전방하향60도:

    SPEED 3
    SERVO 16, 65
    ETX 9600,36
    RETURN

    '******************************************


앞뒤기울기측정:
    FOR i = 0 TO COUNT_MAX
        A = AD(앞뒤기울기AD포트)	'기울기 앞뒤
        IF A > 250 OR A < 5 THEN RETURN
        IF A > MIN AND A < MAX THEN RETURN
        DELAY 기울기확인시간
    NEXT i

    IF A < MIN THEN
        GOSUB 기울기앞
    ELSEIF A > MAX THEN
        GOSUB 기울기뒤
    ENDIF

    RETURN
    '**************************************************
기울기앞:
    A = AD(앞뒤기울기AD포트)
    'IF A < MIN THEN GOSUB 앞으로일어나기
    IF A < MIN THEN
        ETX  9600,16
        GOSUB 뒤로일어나기

    ENDIF
    RETURN

기울기뒤:
    A = AD(앞뒤기울기AD포트)
    'IF A > MAX THEN GOSUB 뒤로일어나기
    IF A > MAX THEN
        ETX  9600,15
        GOSUB 앞으로일어나기
    ENDIF
    RETURN
    '**************************************************
좌우기울기측정:
    FOR i = 0 TO COUNT_MAX
        B = AD(좌우기울기AD포트)	'기울기 좌우
        IF B > 250 OR B < 5 THEN RETURN
        IF B > MIN AND B < MAX THEN RETURN
        DELAY 기울기확인시간
    NEXT i

    IF B < MIN OR B > MAX THEN
        SPEED 8
        MOVE G6B,140,  40,  80
        MOVE G6C,140,  40,  80
        WAIT
        GOSUB 기본자세	
    ENDIF
    RETURN
    '******************************************
DumblingForward:
    'All_motor_mode3

    GOSUB 자이로OFF
    SPEED 15
    MOVE G6A,100, 155,  27, 140, 100, 100
    MOVE G6D,100, 155,  27, 140, 100, 100
    MOVE G6B,130,  30,  85, , , 100
    MOVE G6C,130,  30,  85,,10
    WAIT

    SPEED 10
    MOVE G6A,100, 155,  27, 140, 100, 100
    MOVE G6D,100, 155,  27, 140, 100, 100
    MOVE G6B, 187,  41, 101,  ,  ,
    MOVE G6C, 185,  45, 100,  ,  ,
    WAIT

    SPEED 7
    MOVE G6A, 100, 165,  55, 165, 100,
    MOVE G6D, 100, 165,  55, 165, 100,
    MOVE G6B, 187,  41, 101,  ,  ,
    MOVE G6C, 185,  45, 100,  ,  ,
    WAIT

    SPEED 15
    MOVE G6A, 100, 160, 110, 140, 100,
    MOVE G6D, 100, 160, 110, 140, 100,
    MOVE G6B, 144,  87,  51,  ,  ,
    MOVE G6C, 147,  77,  60,  ,  ,
    WAIT

    SPEED 15
    MOVE G6A, 100,  56, 110,  26, 100,
    MOVE G6D, 100,  71, 177, 162, 100,
    MOVE G6B, 190,  68,  62,  ,  ,
    MOVE G6C, 190,  68,  62,  ,  ,
    WAIT

    SPEED 15
    MOVE G6A,100,  60, 110,  15, 100, 100
    MOVE G6D,100,  70, 120, 30, 100, 100
    MOVE G6B, 190,  68,  62,  ,  ,
    MOVE G6C, 190,  68,  62,  ,  ,
    WAIT

    SPEED 15
    MOVE G6A,100,  60, 110,  15, 100, 100
    MOVE G6D,100,  60, 110,  15, 100, 100
    MOVE G6B,190,  68,  62
    MOVE G6C,190,  68,  62,,10
    WAIT
    DELAY 50

    SPEED 15
    MOVE G6A,100, 110, 70,  65, 100, 100
    MOVE G6D,100, 110, 70,  65, 100, 100
    MOVE G6B,190, 160, 115
    MOVE G6C,190, 160, 115,,10
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  70,  15, 100, 100
    MOVE G6D,100, 170,  70,  15, 100, 100
    MOVE G6B,190, 155, 120
    MOVE G6C,190, 155, 120,,10
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  30,  110, 100, 100
    MOVE G6D,100, 170,  30,  110, 100, 100
    MOVE G6B,190,  40,  60
    MOVE G6C,190,  40,  60
    WAIT

    SPEED 12
    GOSUB 앉은자세
    GOSUB 자이로ON
    SPEED 10
    GOSUB 기본자세
    '=============================================================
    '   GOSUB 뒤로일어나기



    RETURN
    '************************************************************
DumblingForward_BLUE:
    'All_motor_mode3
    GOSUB 자이로OFF

    SPEED 10
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  100,  80,
    MOVE G6C,100,  100,  80,,10,
    WAIT


    SPEED 10
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,  15, 155, 140,  ,  ,
    MOVE G6C,  15, 155, 140,  ,  ,
    WAIT




    '    SPEED 15
    '    MOVE G6A,100,  76, 145,  93, 100, 100
    '    MOVE G6D,100,  76, 145,  93, 100, 100
    '    MOVE G6B,170,  90,  35, , , 100
    '    MOVE G6C,170,  90,  35,,10
    '    WAIT

    SPEED 10
    MOVE G6A,100,  76, 145,  110, 100, 100
    MOVE G6D,100,  76, 145,  110, 100, 100
    MOVE G6B,  15, 130, 140,  ,  ,
    MOVE G6C,  15, 130, 140,  ,  ,
    WAIT


    SPEED 15
    MOVE G6A,100,  76, 145,  160, 100, 100
    MOVE G6D,100,  76, 145,  160, 100, 100
    MOVE G6B, 15,  130, 140,  ,  ,
    MOVE G6C, 15,  130, 140,  ,  ,
    WAIT


    'DELAY 200

    '============================================
    '    SPEED 10
    '    MOVE G6A,100,  76, 145,  160, 100, 100
    '    MOVE G6D,100,  76, 145,  160, 100, 100
    '    MOVE G6B, 187,  41, 101,  ,  ,
    '    MOVE G6C, 185,  45, 100,  ,  ,
    '    WAIT

    '    SPEED 7
    '    MOVE G6A, 100, 165,  55, 165, 100,
    '    MOVE G6D, 100, 165,  55, 165, 100,
    '    MOVE G6B, 187,  41, 101,  ,  ,
    '    MOVE G6C, 185,  45, 100,  ,  ,
    '    WAIT

    '    SPEED 15
    '    MOVE G6A, 100, 160, 110, 140, 100,
    '    MOVE G6D, 100, 160, 110, 140, 100,
    '    MOVE G6B, 144,  87,  51,  ,  ,
    '    MOVE G6C, 147,  77,  60,  ,  ,
    '    WAIT

    SPEED 15
    MOVE G6A, 100,  56, 110,  10, 100,
    MOVE G6D, 100,  71, 177, 162, 100,
    MOVE G6B, 20,  130,  140,  ,  ,
    MOVE G6C, 20,  130,  140,  ,  ,
    WAIT

    SPEED 15
    MOVE G6A,100,  60, 110,  10, 100, 100
    MOVE G6D,100,  70, 120, 30, 100, 100
    MOVE G6B, 20,  130,  140,  ,  ,
    MOVE G6C, 20,  130,  140,  ,  ,
    WAIT

    SPEED 15
    MOVE G6A,100,  60, 110,  10, 100, 100
    MOVE G6D,100,  60, 110,  10, 100, 100
    MOVE G6B,20,  130,  140
    MOVE G6C,20,  130,  140,,10
    WAIT

    'MOVE G6B,190, 100, 100
    'MOVE G6C,190, 100, 100,,10
    'WAIT


    DELAY 50

    SPEED 15
    MOVE G6A,100, 110, 70,  45, 100, 100
    MOVE G6D,100, 110, 70,  45, 100, 100
    MOVE G6B,190, 160, 115
    MOVE G6C,190, 160, 115,,10
    WAIT

    SPEED 15
    MOVE G6A,100, 90, 70,  65, 100, 100
    MOVE G6D,100, 90, 70,  65, 100, 100
    MOVE G6B,190, 180, 105
    MOVE G6C,190, 180, 105,,10
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  70,  15, 100, 100
    MOVE G6D,100, 170,  70,  15, 100, 100
    MOVE G6B,190, 155, 120
    MOVE G6C,190, 155, 120,,10
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  70,  15, 100, 100
    MOVE G6D,100, 170,  70,  15, 100, 100
    MOVE G6B,190, 190, 100
    MOVE G6C,190, 190, 100,,10
    WAIT

    SPEED 10
    MOVE G6A,100, 175,  75,  30, 100, 100
    MOVE G6D,100, 175,  75,  30, 100, 100
    MOVE G6B,190, 190, 100
    MOVE G6C,190, 190, 100,,10
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  30,  110, 100, 100
    MOVE G6D,100, 170,  30,  110, 100, 100
    MOVE G6B,190,  40,  60
    MOVE G6C,190,  40,  60
    WAIT

    SPEED 12
    GOSUB 앉은자세

    SPEED 10
    GOSUB 기본자세
    GOSUB 자이로ON
    RETURN

    '**********************************
계단오른발내리기2cm:
    '기본자세
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,100,
    WAIT

    MOVE G6A,105,  76, 115,  133, 94, 100
    MOVE G6D,85,  76, 115, 133, 114, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,100,
    WAIT

    SPEED 7
    MOVE G6D, 90,  30, 165, 158, 114,
    MOVE G6A,113,  95, 100,  128,  94
    MOVE G6B,70,50
    MOVE G6C,70,40
    WAIT

    SPEED 7
    MOVE G6D,  90, 10, 165, 170, 114,
    MOVE G6A,113,  115, 65,  144,  94
    MOVE G6B,70,50
    MOVE G6C,70,40
    WAIT

    GOSUB Leg_motor_mode3
    SPEED 5
    MOVE G6D,90, 10, 170, 150, 105
    MOVE G6A,115,  155, 35, 125,100
    MOVE G6C,100,50
    MOVE G6B,140,40
    WAIT

    '****************************
    SPEED 8
    MOVE G6D,95, 30, 150, 150, 100
    MOVE G6A,108,  155, 60,  110,100
    MOVE G6C,140,50
    MOVE G6B,100,40
    WAIT

    SPEED 8
    MOVE G6D,100, 30, 150, 150, 100
    MOVE G6A,100,  155, 70,  100,100
    MOVE G6C,140,50
    MOVE G6B,100,40
    WAIT

    SPEED 10
    MOVE G6D,100, 50, 130, 135, 94
    MOVE G6A,90,  135, 130,  55,114
    MOVE G6C,170,50
    MOVE G6B,100,40
    WAIT

    GOSUB Leg_motor_mode2	
    SPEED 10
    MOVE G6D,114, 70, 130, 140, 94
    MOVE G6A,90,  125, 50,  140,114
    WAIT

    SPEED 10
    MOVE G6D,114, 70, 130, 135, 94
    MOVE G6A,90,  125, 50,  135,114
    WAIT

    SPEED 9
    MOVE G6D,114, 75, 130, 122, 94
    MOVE G6A,90,  85, 90,  152,114
    WAIT

    SPEED 8
    MOVE G6D,112, 80, 130, 110, 94
    MOVE G6A,90,  75,130,  115,114
    MOVE G6C,130,50
    MOVE G6B,100,40
    WAIT

    SPEED 6
    MOVE G6D, 98, 80, 130, 105,99,
    MOVE G6A,98,  80, 130,  105, 99
    MOVE G6B,110,40
    MOVE G6C,110,40
    WAIT

    SPEED 4
    GOSUB 기본자세

    RETURN
    '********************************************************

계단오른발내리기4cm:
    '기본자세
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,100,
    WAIT	

    '앉기
    SPEED 4
    MOVE G6A,100, 145,  28, 145, 100, 100
    MOVE G6D,100, 145,  28, 145, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80
    WAIT

    SPEED 4
    MOVE G6A,100, 145,  28, 145, 100, 100
    MOVE G6D,100, 145,  28, 145, 100, 100
    MOVE G6B,50,  30,  80,
    MOVE G6C,50,  30,  80
    WAIT

    SPEED 4
    MOVE G6A,100, 105,  28, 145, 100, 100
    MOVE G6D,100, 105,  28, 145, 100, 100
    MOVE G6B,50,  30,  80,
    MOVE G6C,50,  30,  80
    WAIT

    SPEED 5
    MOVE G6A,100, 105,  28, 145, 100, 100
    MOVE G6D,100, 50,  28, 175, 100, 100
    MOVE G6B,50,  30,  80,
    MOVE G6C,50,  30,  80
    WAIT

    SPEED 5
    MOVE G6A,100, 105,  28, 145, 100, 100
    MOVE G6D,100, 50,  128, 175, 100, 100
    MOVE G6B,50,  30,  80,
    MOVE G6C,50,  30,  80
    WAIT

    SPEED 5
    MOVE G6A,100, 105,  28, 145, 100, 100
    MOVE G6D,100, 55,  128, 128, 100, 100
    MOVE G6B,50,  30,  80,
    MOVE G6C,50,  30,  80
    WAIT

    SPEED 5
    MOVE G6A,100, 55,  28, 175, 100, 100
    MOVE G6D,100, 55,  128, 115, 100, 100
    MOVE G6B,50,  30,  80,
    MOVE G6C,50,  30,  80
    WAIT

    SPEED 5
    MOVE G6A,100, 55,  128, 175, 100, 100
    MOVE G6D,100, 55,  128, 115, 100, 100
    MOVE G6B,50,  30,  80,
    MOVE G6C,50,  30,  80
    WAIT

    SPEED 5
    MOVE G6A,100, 55,  128, 115, 100, 100
    MOVE G6D,100, 55,  128, 115, 100, 100
    MOVE G6B,50,  30,  80,
    MOVE G6C,50,  30,  80
    WAIT

    '	SPEED 4
    '	MOVE G6A,95, 35,  90, 155, 100, 100
    '    MOVE G6D,100, 55,  128, 155, 100, 100
    '    MOVE G6B,30,  30,  80,
    '    MOVE G6C,30,  30,  80
    '    WAIT

    SPEED 5
    MOVE G6A,95, 35,  90, 155, 100, 100
    MOVE G6D,100, 35,  90, 155, 100, 100
    MOVE G6B,30,  30,  80,
    MOVE G6C,30,  30,  80
    WAIT

    SPEED 5
    MOVE G6A,95, 35,  90, 155, 100, 100
    MOVE G6D,100, 35,  90, 155, 100, 100
    MOVE G6B,60,  30,  80,
    MOVE G6C,60,  30,  80
    WAIT

    SPEED 5
    MOVE G6A,95, 35,  90, 170, 100, 100
    MOVE G6D,100, 35,  90, 170, 100, 100
    MOVE G6B,60,  30,  80,
    MOVE G6C,60,  30,  80
    WAIT

    SPEED 5
    MOVE G6A,95, 80,  50, 170, 100, 100
    MOVE G6D,100, 80,  50, 170, 100, 100
    MOVE G6B,60,  30,  80,
    MOVE G6C,60,  30,  80
    WAIT

    '앉기
    SPEED 4
    MOVE G6A,100, 145,  28, 145, 100, 100
    MOVE G6D,100, 145,  28, 145, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80
    WAIT

    '기본자세
    SPEED 4
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,100,
    WAIT	



    RETURN
    '*****************************************************
계단오른발오르기2cm:
    'GOSUB All_motor_mode3
    '기본자세
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,100,
    WAIT

    '    SPEED 4
    '    MOVE G6D, 88,  71, 152,  91, 110
    '    MOVE G6A,108,  77, 146,  93,  94
    '    MOVE G6B,100,40
    '    MOVE G6C,100,40
    '    WAIT

    SPEED 4
    MOVE G6D, 87,  70, 152,  91, 110
    MOVE G6A,106,  77, 146,  93,  94
    MOVE G6B,100,40
    MOVE G6C,100,40
    WAIT

    SPEED 8
    MOVE G6D, 90, 110, 100, 103, 114
    MOVE G6A,111,  78, 146,  90,  94
    WAIT

    GOSUB Leg_motor_mode2

    SPEED 8
    MOVE G6D, 90, 140, 35, 135, 114
    MOVE G6A,111,  71, 155,  87,  94
    WAIT


    SPEED 12
    MOVE G6D, 85, 75, 100, 160, 114,
    MOVE G6A,109,  70, 155,  86,  94
    WAIT

    SPEED 12
    MOVE G6D, 85, 35, 145, 145, 110,
    MOVE G6A,109,  70, 155,  78,  98
    WAIT

    GOSUB Leg_motor_mode3

    SPEED 7
    MOVE G6D, 105, 55, 110, 165, 100,
    MOVE G6A,90,  92, 165,  70, 100
    MOVE G6C,160,50
    MOVE G6B,160,40
    WAIT

    SPEED 6
    MOVE G6D, 114, 90, 90, 155,100,
    MOVE G6A,90,  100, 165,  65, 105
    MOVE G6C,180,50
    MOVE G6B,180,30
    WAIT

    '****************************
    GOSUB Leg_motor_mode2	
    SPEED 8
    MOVE G6D, 112, 90, 100, 145,97,
    MOVE G6A,95,  130, 110,  90, 105
    WAIT

    SPEED 12
    MOVE G6D, 112, 90, 100, 140,95,
    MOVE G6A,90,  120, 40,  140, 108
    WAIT

    SPEED 10
    MOVE G6D, 114, 90, 110, 120,95,
    MOVE G6A,90,  95, 90,  145, 108
    MOVE G6C,140,50
    MOVE G6B,140,30
    WAIT

    SPEED 10
    MOVE G6D, 110, 90, 110, 120,95,
    MOVE G6A,80,  85, 110,  135, 108
    MOVE G6B,110,40
    MOVE G6C,110,40
    WAIT

    SPEED 5
    MOVE G6A, 98, 90, 110, 122,99,
    MOVE G6D,98,  90, 110,  125, 99
    MOVE G6B,110,40
    MOVE G6C,110,40
    WAIT

    SPEED 6
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80
    MOVE G6C,100,  30,  80
    WAIT

    RETURN
    '***********************************************
공차기:
    '기본자세
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,100,
    WAIT


    GOSUB Leg_motor_mode3
    SPEED 4

    MOVE G6A,108,  77, 145,  93,  92, 100	
    MOVE G6D, 85,  71, 152,  91, 114, 100
    MOVE G6C,100,  40,  80, , , ,
    MOVE G6B,100,  40,  80, , , ,	
    WAIT

    SPEED 10
    MOVE G6A,108,  75, 145,  100,  95	
    MOVE G6D, 83,  85, 122,  105, 114
    WAIT

    GOSUB Leg_motor_mode2
    HIGHSPEED SETON

    SPEED 10
    MOVE G6A,108,  73, 148,  90,  95	
    MOVE G6D, 83,  20, 155,  135, 114
    MOVE G6C,50
    MOVE G6B,150
    WAIT


    DELAY 200

    HIGHSPEED SETOFF


    SPEED 10
    MOVE G6A,108,  72, 145,  97,  95
    MOVE G6D, 83,  58, 122,  130, 114
    MOVE G6C,100,  40,  80, , , ,
    MOVE G6B,100,  40,  80, , , ,	
    WAIT	

    SPEED 8
    MOVE G6A,108,  77, 145,  95,  95	
    MOVE G6D, 80,  80, 142,  95, 114
    MOVE G6C,100,  40,  80, , , ,
    MOVE G6B,100,  40,  80, , , ,
    WAIT	

    SPEED 8
    MOVE G6A,108,  77, 145,  93,  93, 100	
    MOVE G6D, 80,  71, 152,  91, 114, 100
    WAIT


    SPEED 3
    GOSUB 기본자세	
    GOSUB Leg_motor_mode1
    DELAY 400

    RETURN
    '******************************************
앞으로덤블링:
    'All_motor_mode3


    SPEED 15
    MOVE G6A,100, 155,  27, 140, 100, 100
    MOVE G6D,100, 155,  27, 140, 100, 100
    MOVE G6B,130,  30,  85
    MOVE G6C,130,  30,  85,,10
    WAIT

    SPEED 10
    MOVE G6A, 100, 165,  55, 165, 100, 100
    MOVE G6D, 100, 165,  55, 165, 100, 100
    MOVE G6B,185,  10, 100
    MOVE G6C,185,  10, 100,,10
    WAIT

    SPEED 15
    MOVE G6A,100, 160, 110, 140, 100, 100
    MOVE G6D,100, 160, 110, 140, 100, 100
    MOVE G6B,140,  70,  20
    MOVE G6C,140,  70,  20,,10
    WAIT

    SPEED 15
    MOVE G6A,100,  56, 110,  26, 100, 100
    MOVE G6D,100,  71, 177, 162, 100, 100
    MOVE G6B,170,  40,  70
    MOVE G6C,170,  40,  70,,10
    WAIT

    SPEED 15
    MOVE G6A,100,  60, 110,  15, 100, 100
    MOVE G6D,100,  70, 120, 30, 100, 100
    MOVE G6B,170,  40,  70
    MOVE G6C,170,  40,  70,,10
    WAIT

    SPEED 15
    MOVE G6A,100,  60, 110,  15, 100, 100
    MOVE G6D,100,  60, 110,  15, 100, 100
    MOVE G6B,190,  40,  70
    MOVE G6C,190,  40,  70,,10
    WAIT
    DELAY 50

    SPEED 15
    MOVE G6A,100, 110, 70,  65, 100, 100
    MOVE G6D,100, 110, 70,  65, 100, 100
    MOVE G6B,190, 160, 115
    MOVE G6C,190, 160, 115,,10
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  70,  15, 100, 100
    MOVE G6D,100, 170,  70,  15, 100, 100
    MOVE G6B,190, 155, 120
    MOVE G6C,190, 155, 120,,10
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  30,  110, 100, 100
    MOVE G6D,100, 170,  30,  110, 100, 100
    MOVE G6B,190,  40,  60
    MOVE G6C,190,  40,  60
    WAIT

    SPEED 12
    GOSUB 앉은자세

    SPEED 10
    GOSUB 기본자세
    '=============================================================
    '   GOSUB 뒤로일어나기



    RETURN


    '****************************************
오른쪽옆으로20: '****
    MOTORMODE G6A,3,3,3,3,2
    MOTORMODE G6D,3,3,3,3,2

    SPEED 12
    MOVE G6D, 95,  90, 125, 100, 104, 100
    MOVE G6A,105,  76, 146,  93, 104, 100
    WAIT

    SPEED 12
    MOVE G6D, 102,  77, 145, 93, 100, 100
    MOVE G6A,90,  80, 140,  95, 107, 100
    WAIT

    SPEED 10
    MOVE G6D,95,  76, 145,  93, 102, 100
    MOVE G6A,95,  76, 145,  93, 102, 100
    WAIT

    SPEED 8
    GOSUB 기본자세2
    GOSUB All_motor_mode3
    RETURN
    '*************

왼쪽옆으로20: '****
    MOTORMODE G6A,3,3,3,3,2
    MOTORMODE G6D,3,3,3,3,2

    SPEED 12
    MOVE G6A, 95,  90, 125, 100, 104, 100
    MOVE G6D,105,  76, 145,  93, 104, 100
    WAIT

    SPEED 12
    MOVE G6A, 102,  77, 145, 93, 100, 100
    MOVE G6D,90,  80, 140,  95, 107, 100
    WAIT

    SPEED 10
    MOVE G6A,95,  76, 145,  93, 102, 100
    MOVE G6D,95,  76, 145,  93, 102, 100
    WAIT

    SPEED 8
    GOSUB 기본자세2
    GOSUB All_motor_mode3
    RETURN

    '**********************************************
왼쪽턴10:
    MOTORMODE G6A,3,3,3,3,2
    MOTORMODE G6D,3,3,3,3,2
    SPEED 5
    MOVE G6A,97,  86, 145,  83, 103, 100
    MOVE G6D,97,  66, 145,  103, 103, 100
    WAIT

    SPEED 12
    MOVE G6A,94,  86, 145,  83, 101, 100
    MOVE G6D,94,  66, 145,  103, 101, 100
    WAIT

    SPEED 6
    MOVE G6A,101,  76, 146,  93, 98, 100
    MOVE G6D,101,  76, 146,  93, 98, 100
    WAIT

    GOSUB 기본자세2
    RETURN
    '**********************************************
오른쪽턴10:
    MOTORMODE G6A,3,3,3,3,2
    MOTORMODE G6D,3,3,3,3,2
    SPEED 5
    MOVE G6A,97,  66, 145,  103, 103, 100
    MOVE G6D,97,  86, 145,  83, 103, 100
    WAIT

    SPEED 12
    MOVE G6A,94,  66, 145,  103, 101, 100
    MOVE G6D,94,  86, 145,  83, 101, 100
    WAIT
    SPEED 6
    MOVE G6A,101,  76, 146,  93, 98, 100
    MOVE G6D,101,  76, 146,  93, 98, 100
    WAIT

    GOSUB 기본자세2

    RETURN
    '**********************************************
왼쪽턴60:
    MOTORMODE G6A,3,3,3,3,2
    MOTORMODE G6D,3,3,3,3,2
왼쪽턴60_LOOP:

    SPEED 15
    MOVE G6A,95,  116, 145,  53, 105, 100
    MOVE G6D,95,  36, 145,  133, 105, 100
    WAIT

    SPEED 15
    MOVE G6A,90,  116, 145,  53, 105, 100
    MOVE G6D,90,  36, 145,  133, 105, 100
    WAIT

    SPEED 10
    GOSUB 기본자세2
    '  DELAY 50
    '    GOSUB 앞뒤기울기측정
    '    IF 넘어진확인 = 1 THEN
    '        넘어진확인 = 0
    '        GOTO RX_EXIT
    '    ENDIF
    '    ERX 4800,A,왼쪽턴60_LOOP
    '    IF A_old = A THEN GOTO 왼쪽턴60_LOOP

    RETURN

    '**********************************************
오른쪽턴60:
    MOTORMODE G6A,3,3,3,3,2
    MOTORMODE G6D,3,3,3,3,2
오른쪽턴60_LOOP:

    SPEED 15
    MOVE G6A,95,  36, 145,  133, 105, 100
    MOVE G6D,95,  116, 145,  53, 105, 100
    WAIT

    SPEED 15
    MOVE G6A,90,  36, 145,  133, 105, 100
    MOVE G6D,90,  116, 145,  53, 105, 100

    WAIT

    SPEED 10
    GOSUB 기본자세2
    ' DELAY 50
    '    GOSUB 앞뒤기울기측정
    '    IF 넘어진확인 = 1 THEN
    '        넘어진확인 = 0
    '        GOTO RX_EXIT
    '    ENDIF
    '    ERX 4800,A,오른쪽턴60_LOOP
    '    IF A_old = A THEN GOTO 오른쪽턴60_LOOP

    RETURN
    '****************************************
전진보행50:
    GOSUB Leg_motor_mode3

    보행COUNT = 0

    SPEED 4
    '오른쪽기울기
    MOVE G6A, 88,  71, 152,  91, 110
    MOVE G6D,108,  76, 146,  93,  94
    MOVE G6B,100,35
    MOVE G6C,100,35
    WAIT

    SPEED 10'보행속도
    '왼발들기
    MOVE G6A, 90, 100, 115, 105, 114
    MOVE G6D,113,  78, 146,  90,  94
    MOVE G6B,90
    MOVE G6C,110
    WAIT


전진보행50_1:

    SPEED 10
    '왼발뻣어착지
    MOVE G6A, 92,  44, 165, 113, 114
    MOVE G6D,110,  77, 146,  91,  94
    WAIT

    SPEED 4
    '왼발중심이동
    MOVE G6A,110,  76, 144, 95,  93
    MOVE G6D,90, 94, 155,  71, 112
    WAIT

    SPEED 10
    '오른발들기10
    MOVE G6A,111,  77, 146,  88, 94
    MOVE G6D,90, 100, 105, 110, 114
    MOVE G6B,110
    MOVE G6C,90
    WAIT

    보행COUNT = 보행COUNT + 1
    IF 보행COUNT > 보행횟수 THEN  GOTO 전진보행50_1_stop


    'ERX 9600,A, 전진보행50_2
    IF A <> A_old THEN
전진보행50_1_stop:
        HIGHSPEED SETOFF
        SPEED 5
        '왼쪽기울기2
        MOVE G6A, 106,  76, 146,  93,  96		
        MOVE G6D,  88,  71, 152,  91, 106
        MOVE G6B, 100,35
        MOVE G6C, 100,35
        WAIT	

        SPEED 3
        GOSUB 기본자세
        GOSUB Leg_motor_mode1

        RETURN
    ENDIF
    '**********


전진보행50_2:

    SPEED 10
    '오른발뻣어착지
    MOVE G6D,85,  54, 165, 110, 114
    MOVE G6A,110,  77, 146,  90,  94
    WAIT

    SPEED 4
    '오른발중심이동
    MOVE G6D,110,  76, 144, 99,  93
    MOVE G6A, 85, 93, 155,  70, 112
    WAIT

    SPEED 10
    '왼발들기10
    MOVE G6A, 90, 100, 105, 110, 114
    MOVE G6D,111,  77, 146,  93,  94
    MOVE G6B, 90
    MOVE G6C,110
    WAIT

    보행COUNT = 보행COUNT + 1
    IF 보행COUNT > 보행횟수 THEN  GOTO 전진보행50_2_stop

    'ERX 9600,A, 전진보행50_1
    IF A <> A_old THEN
전진보행50_2_stop:
        HIGHSPEED SETOFF
        SPEED 5
        '오른쪽기울기2
        MOVE G6D, 106,  76, 146,  93,  96		
        MOVE G6A,  88,  71, 152,  91, 106
        MOVE G6C, 100,35
        MOVE G6B, 100,35
        WAIT

        SPEED 3
        GOSUB 기본자세
        GOSUB Leg_motor_mode1
        RETURN
    ENDIF


    GOTO 전진보행50_1
    '************************************************
전진종종걸음:
    넘어진확인 = 0
    보행COUNT = 0
    SPEED 10
    HIGHSPEED SETON
    GOSUB All_motor_mode3

    IF 보행순서 = 0 THEN
        보행순서 = 1
        MOVE G6A,95,  76, 145,  93, 101
        MOVE G6D,101,  77, 145,  93, 98
        MOVE G6B,100,  35
        MOVE G6C,100,  35, ,100
        WAIT

        GOTO 전진종종걸음_1
    ELSE
        보행순서 = 0
        MOVE G6D,95,  76, 145,  93, 101
        MOVE G6A,101,  77, 145,  93, 98
        MOVE G6B,100,  35
        MOVE G6C,100,  35
        WAIT

        GOTO 전진종종걸음_4
    ENDIF


    '**********************

전진종종걸음_1:
    MOVE G6A,95,  95, 120, 100, 104
    MOVE G6D,106,  77, 146,  95,  102
    MOVE G6B, 80
    MOVE G6C,120
    WAIT


전진종종걸음_2:
    MOVE G6A,95,  85, 130, 103, 104
    MOVE G6D,106,  79, 146,  90,  100
    WAIT

전진종종걸음_3:
    MOVE G6A,103,   85, 130, 105,  100
    MOVE G6D, 95,  80, 146,  90, 102
    WAIT

    'GOSUB 앞뒤기울기측정
    'IF 넘어진확인 = 1 THEN
    '    넘어진확인 = 0
    '    RETURN
    'ENDIF

    'ERX 4800,A, 전진종종걸음_4
    'IF A <> A_old THEN  GOTO 전진종종걸음_멈춤
    보행COUNT = 보행COUNT + 1
    IF 보행COUNT > 보행횟수 THEN  GOTO 전진종종걸음_멈춤
    '*********************************

전진종종걸음_4:
    MOVE G6D,95,  95, 120, 100, 104
    MOVE G6A,106,  77, 146,  95,  102
    MOVE G6C, 80
    MOVE G6B,120
    WAIT


전진종종걸음_5:
    MOVE G6D,95,  85, 130, 103, 104
    MOVE G6A,106,  79, 146,  90,  100
    WAIT

전진종종걸음_6:
    MOVE G6D,103,   85, 130, 105,  100
    MOVE G6A, 95,  80, 146,  90, 102
    WAIT

    'GOSUB 앞뒤기울기측정
    'IF 넘어진확인 = 1 THEN
    '    넘어진확인 = 0
    '    RETURN
    'ENDIF

    'ERX 4800,A, 전진종종걸음_1
    'IF A <> A_old THEN  GOTO 전진종종걸음_멈춤
    보행COUNT = 보행COUNT + 1
    IF 보행COUNT > 보행횟수 THEN  GOTO 전진종종걸음_멈춤

    GOTO 전진종종걸음_1


전진종종걸음_멈춤:
    HIGHSPEED SETOFF
    SPEED 15
    GOSUB 안정화자세
    SPEED 10
    GOSUB 기본자세

    DELAY 400

    GOSUB Leg_motor_mode1
    GOTO RX_EXIT


    '***************************************************
밑에보고종종걸음:
    넘어진확인 = 0
    보행COUNT = 0
    SPEED 10
    HIGHSPEED SETON
    GOSUB All_motor_mode3

    IF 보행순서 = 0 THEN
        보행순서 = 1
        MOVE G6A,95,  76, 145,  90, 101
        MOVE G6D,101,  77, 145,  90, 98
        MOVE G6B,100,  35
        MOVE G6C,100,  35
        WAIT

        GOTO 밑에보고종종걸음_1
    ELSE
        보행순서 = 0
        MOVE G6D,95,  76, 145,  90, 101
        MOVE G6A,101,  77, 145,  90, 98
        MOVE G6B,100,  35
        MOVE G6C,100,  35
        WAIT

        GOTO 밑에보고종종걸음_4
    ENDIF


    '**********************

밑에보고종종걸음_1:
    MOVE G6A,95,  95, 120, 100, 104
    MOVE G6D,106,  77, 146,  90,  102
    MOVE G6B, 80
    MOVE G6C,120
    WAIT


밑에보고종종걸음_2:
    MOVE G6A,95,  85, 130, 103, 104
    MOVE G6D,106,  79, 146,  88,  100
    WAIT

밑에보고종종걸음_3:
    MOVE G6A,103,   85, 130, 102,  100
    MOVE G6D, 95,  80, 146,  87, 102
    WAIT

    'GOSUB 앞뒤기울기측정
    'IF 넘어진확인 = 1 THEN
    '    넘어진확인 = 0
    '    RETURN
    'ENDIF

    'ERX 4800,A, 전진종종걸음_4
    'IF A <> A_old THEN  GOTO 전진종종걸음_멈춤
    보행COUNT = 보행COUNT + 1
    IF 보행COUNT > 보행횟수 THEN  GOTO 밑에보고종종걸음_멈춤
    '*********************************

밑에보고종종걸음_4:
    MOVE G6D,95,  95, 120, 100, 104
    MOVE G6A,106,  77, 146,  90,  102
    MOVE G6C, 80
    MOVE G6B,120
    WAIT


밑에보고종종걸음_5:
    MOVE G6D,95,  85, 130, 103, 104
    MOVE G6A,106,  79, 146,  88,  100
    WAIT

밑에보고종종걸음_6:
    MOVE G6D,105,   85, 130, 102,  100
    MOVE G6A, 92,  80, 146,  87, 102
    WAIT

    'GOSUB 앞뒤기울기측정
    'IF 넘어진확인 = 1 THEN
    '    넘어진확인 = 0
    '    RETURN
    'ENDIF

    'ERX 4800,A, 전진종종걸음_1
    'IF A <> A_old THEN  GOTO 전진종종걸음_멈춤
    보행COUNT = 보행COUNT + 1
    IF 보행COUNT > 보행횟수 THEN  GOTO 밑에보고종종걸음_멈춤

    GOTO 밑에보고종종걸음_1


밑에보고종종걸음_멈춤:
    HIGHSPEED SETOFF
    SPEED 15
    GOSUB 안정화자세
    SPEED 10
    GOSUB 기본자세

    DELAY 400

    GOSUB Leg_motor_mode1
    RETURN
    '*****************************************************8
바닥보고종종걸음:
    넘어진확인 = 0
    보행COUNT = 0
    SPEED 10
    HIGHSPEED SETON
    GOSUB All_motor_mode3

    IF 보행순서 = 0 THEN
        보행순서 = 1
        MOVE G6A,95,  76, 145,  90, 101
        MOVE G6D,101,  77, 145,  90, 98
        MOVE G6B,100,  35
        MOVE G6C,100,  35, , ,10 ,
        WAIT

        GOTO 바닥보고종종걸음_1
    ELSE
        보행순서 = 0
        MOVE G6D,95,  76, 145,  90, 101
        MOVE G6A,101,  77, 145,  90, 98
        MOVE G6B,100,  35
        MOVE G6C,100,  35, , ,10,
        WAIT

        GOTO 바닥보고종종걸음_4
    ENDIF


    '**********************

바닥보고종종걸음_1:
    MOVE G6A,95,  95, 120, 100, 104
    MOVE G6D,106,  77, 146,  89,  102
    MOVE G6B, 80
    MOVE G6C,120, , , , ,

    WAIT


바닥보고종종걸음_2:
    MOVE G6A,95,  85, 130, 103, 104
    MOVE G6D,106,  79, 146,  87,  100
    WAIT

바닥보고종종걸음_3:
    MOVE G6A,103,   85, 130, 102,  100
    MOVE G6D, 95,  80, 146,  87, 102
    WAIT

    'GOSUB 앞뒤기울기측정
    'IF 넘어진확인 = 1 THEN
    '    넘어진확인 = 0
    '    RETURN
    'ENDIF

    'ERX 4800,A, 전진종종걸음_4
    'IF A <> A_old THEN  GOTO 전진종종걸음_멈춤
    보행COUNT = 보행COUNT + 1
    IF 보행COUNT > 보행횟수 THEN  GOTO 바닥보고종종걸음_멈춤
    '*********************************

바닥보고종종걸음_4:
    MOVE G6D,95,  95, 120, 100, 104
    MOVE G6A,106,  77, 146,  88,  102
    MOVE G6C, 80
    MOVE G6B,120
    WAIT


바닥보고종종걸음_5:
    MOVE G6D,95,  85, 130, 103, 104
    MOVE G6A,106,  79, 146,  87,  100
    WAIT

바닥보고종종걸음_6:
    MOVE G6D,105,   85, 130, 102,  100
    MOVE G6A, 92,  80, 146,  87, 102
    WAIT

    'GOSUB 앞뒤기울기측정
    'IF 넘어진확인 = 1 THEN
    '    넘어진확인 = 0
    '    RETURN
    'ENDIF

    'ERX 4800,A, 전진종종걸음_1
    'IF A <> A_old THEN  GOTO 전진종종걸음_멈춤
    보행COUNT = 보행COUNT + 1
    IF 보행COUNT > 보행횟수 THEN  GOTO 바닥보고종종걸음_멈춤

    GOTO 바닥보고종종걸음_1


바닥보고종종걸음_멈춤:
    HIGHSPEED SETOFF
    SPEED 15
    GOSUB 안정화자세
    SPEED 10
    GOSUB 기본자세3

    DELAY 400

    GOSUB Leg_motor_mode1
    RETURN







    '************************************************
MAIN: '라벨설정

    ETX 9600, 38 ' 동작 멈춤 확인 송신 값

MAIN_2:

    ERX 9600,A,MAIN_2	

    A_old = A


    '**** 입력된 A값이 0 이면 MAIN 라벨로 가고
    '**** 1이면 KEY1 라벨, 2이면 key2로... 가는문
    ON A GOTO MAIN,KEY1,KEY2,KEY3,KEY4,KEY5,KEY6,KEY7,KEY8,KEY9,KEY10,KEY11,KEY12,KEY13,KEY14,KEY15,KEY16,KEY17,KEY18 ,KEY19,KEY20,KEY21,KEY22,KEY23,KEY24,KEY25,KEY26,KEY27,KEY28 ,KEY29,KEY30,KEY31,KEY32


    GOSUB 앞뒤기울기측정
    GOSUB 좌우기울기측정

    'GOSUB 적외선거리센서확인
    'GOSUB 자이로OFF
    'DELAY 3000
    'GOSUB DumblingForward_BLUE
    'DELAY 500

    GOTO MAIN	
    '*******************************************
    '		MAIN 라벨로 가기
    '*******************************************



KEY1:
    ETX  9600,1
    GOTO 밑에보고종종걸음

    GOTO MAIN
    '***************	
KEY2:
    ETX  9600,2
    GOTO 앞으로덤블링

    GOTO MAIN
    '***************
KEY3:
    ETX  9600,3
    GOTO 계단오른발내리기4cm

    GOTO MAIN
    '***************
KEY4:
    ETX  9600,4
    GOTO 전진종종걸음

    GOTO MAIN
    '***************
KEY5:
    ETX  9600,5
    보행횟수 = 3
    GOTO 바닥보고종종걸음

    GOTO MAIN
    '***************
KEY6:
    ETX  9600,6


    GOTO MAIN
    '***************
KEY7:
    ETX  9600,7


    GOTO MAIN
    '***************
KEY8:
    ETX  9600,8
	GOSUB DumblingForward_BLUE

    GOTO MAIN
    '***************
KEY9:
    ETX  9600,9


    GOTO MAIN
    '***************
KEY10: '0
    ETX  9600,10


    GOTO MAIN
    '***************
KEY11: ' ▲
    ETX  9600,11


    GOTO MAIN
    '***************
KEY12: ' ▼
    ETX  9600,12


    GOTO MAIN
    '***************
KEY13: '▶
    ETX  9600,13



    GOTO MAIN
    '***************
KEY14: ' ◀
    ETX  9600,14



    GOTO MAIN
    '***************
KEY15: ' A
    ETX  9600,15


    GOTO MAIN
    '***************
KEY16: ' POWER
    ETX  9600,16


    GOTO MAIN
    '***************
KEY17: ' C
    ETX  9600,17


    GOTO MAIN
    '***************
KEY18: ' E
    ETX  9600,18	


    GOTO MAIN
    '***************
KEY19: ' P2
    ETX  9600,19


    GOTO MAIN
    '***************
KEY20: ' B	
    ETX  9600,20


    GOTO MAIN
    '***************
KEY21: ' △
    ETX  9600,21


    GOTO MAIN
    '***************
KEY22: ' *	
    ETX  9600,22


    GOTO MAIN
    '***************
KEY23: ' G
    ETX  9600,23


    GOTO MAIN
    '***************
KEY24: ' #
    ETX  9600,24


    GOTO MAIN
    '***************
KEY25: ' P1
    ETX  9600,25


    GOTO MAIN
    '***************
KEY26: ' ■
    ETX  9600,26


    GOTO MAIN
    '***************
KEY27: ' D
    ETX  9600,27


    GOTO MAIN
    '***************
KEY28: ' ◁
    ETX  9600,28


    GOTO MAIN
    '***************
KEY29: ' □
    ETX  9600,29


    GOTO MAIN
    '***************
KEY30: ' ▷
    ETX  9600,30


    GOTO MAIN
    '***************
KEY31: ' ▽
    ETX  9600,31


    GOTO MAIN
    '***************

KEY32: ' F
    ETX  9600,32


    GOTO MAIN
    '***************
