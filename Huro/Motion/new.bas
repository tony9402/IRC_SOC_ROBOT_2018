7'Made by Minsang
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
DIM temp AS BYTE
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
보행횟수 = 4
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



'PRINT "VOLUME 200 !"
'PRINT "SOUND 12 !" '안녕하세요

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
    MOVE G6C,100,  35,  90,
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
    MOVE G6C,100,  30,  80, 	
    WAIT

    mode = 0
    RETURN
    '********************************************

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

머리바닥보기:
    SPEED 머리이동속도
    SERVO 16,10
    RETURN
    '******************************************
전방하향20도:
    SPEED 3
    SERVO 16,20

    RETURN

전방하향80도:

    SPEED 3
    SERVO 16, 80
    'ETX 9600,38
    RETURN
    '******************************************
전방하향60도:

    SPEED 3
    SERVO 16, 65
    'ETX 9600,38
    RETURN

전방하향30도:

    SPEED 3
    SERVO 16, 30
    'ETX 9600,38
    RETURN

전방보기:

    SPEED 3
    SERVO 16, 100
    SERVO 11, 100
    'ETX 9600, 38
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
        'ETX  9600,16
        GOSUB 뒤로일어나기

    ENDIF
    RETURN

기울기뒤:
    A = AD(앞뒤기울기AD포트)
    'IF A > MAX THEN GOSUB 뒤로일어나기
    IF A > MAX THEN
        'ETX  9600,15
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
    MOVE G6B,190, 170, 120
    MOVE G6C,190, 170, 120,,10
    WAIT

    SPEED 10
    MOVE G6A,100, 170,  70,  65, 100, 100
    MOVE G6D,100, 170,  70,  65, 100, 100
    MOVE G6B,190, 170, 120
    MOVE G6C,190, 170, 120,,10
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

    SPEED 12
    MOVE G6A,100, 170,  70,  15, 100, 100
    MOVE G6D,100, 170,  70,  15, 100, 100
    MOVE G6B,190, 155, 120
    MOVE G6C,190, 155, 120,,10
    WAIT

    SPEED 12
    MOVE G6A,100, 170,  70,  15, 100, 100
    MOVE G6D,100, 170,  70,  15, 100, 100
    MOVE G6B,190, 190, 100
    MOVE G6C,190, 190, 100,,10
    WAIT

    SPEED 12
    MOVE G6A,100, 175,  75,  30, 100, 100
    MOVE G6D,100, 175,  75,  30, 100, 100
    MOVE G6B,190, 190, 100
    MOVE G6C,190, 190, 100,,10
    WAIT

    SPEED 12
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
계단오른발내리기2cm2:
    '기본자세
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,100,
    WAIT

    SPEED 7
    MOVE G6A, 105,  76, 115, 133,  94,
    MOVE G6D,  85,  76, 115, 133, 114,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  95,  90,  ,  ,
    WAIT


    '    MOVE G6A,105,  76, 115,  133, 94, 100
    '    MOVE G6D,85,  76, 115, 133, 114, 100
    '    MOVE G6B,100,  30,  80,
    '    MOVE G6C,100,  30,  80,,100,
    '    WAIT


    SPEED 5
    MOVE G6A, 113,  95,  95, 128,  98,
    MOVE G6D,  90,  40, 175, 158, 114,
    MOVE G6B,  70,  50,  80,  ,  ,
    MOVE G6C, 105,  90,  90,  ,  ,
    WAIT


    '    MOVE G6A, 113,  95, 100, 128,  98,
    '    MOVE G6D,  90,  40, 175, 158, 114,
    '    MOVE G6B,  70,  50,  80,  ,  ,
    '    MOVE G6C, 105,  90,  90,  ,  ,
    '    WAIT


    '    MOVE G6D, 90,  30, 165, 158, 114,
    '    MOVE G6A,113,  95, 100,  128,  94
    '    MOVE G6B,70,50
    '    MOVE G6C,70,40
    '    WAIT

    SPEED 5
    MOVE G6A, 113, 115,  65, 144,  99,
    MOVE G6D,  90,  15, 175, 170, 114,
    MOVE G6B,  70,  50,  80,  ,  ,
    MOVE G6C, 100,  90,  90,  ,  ,
    WAIT


    'MOVE G6A, 113, 115,  65, 144,  94,
    '    MOVE G6D,  90,  15, 175, 170, 114,
    '    MOVE G6B,  70,  50,  80,  ,  ,
    '    MOVE G6C, 100,  90,  90,  ,  ,
    '    WAIT


    'MOVE G6D,  90, 10, 165, 170, 114,
    '    MOVE G6A,113,  115, 65,  144,  94
    '    MOVE G6B,70,50
    '    MOVE G6C,70,40
    '    WAIT

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

짚고내리기노란색:
    '기본자세
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,100,
    WAIT

    SPEED 5
    MOVE G6A, 103, 164,  29, 118,  98,
    MOVE G6D, 101, 166,  24, 122,  99,
    MOVE G6B, 102,  31,  82,  ,  ,
    MOVE G6C, 102,  32,  82,  ,  ,
    WAIT

    SPEED 5
    MOVE G6A, 104, 161,  28,  40,  96,
    MOVE G6D, 101, 165,  23,  41,  96,
    MOVE G6B,  17, 100,  41,  ,  ,
    MOVE G6C,  17,  92,  56,  ,  ,
    WAIT


    SPEED 5
    MOVE G6A, 104, 161,  28,  40,  96,
    MOVE G6D, 101, 159,  23, 130,  97,
    MOVE G6B,  17, 100,  41,  ,  ,
    MOVE G6C,  17,  92,  56,  ,  ,
    WAIT

    SPEED 5
    MOVE G6A, 104, 161,  28,  40,  96,
    MOVE G6D, 101,  63,  84,  80,  96,
    MOVE G6B,  17, 100,  41,  ,  ,
    MOVE G6C,  17,  92,  56,  ,  ,
    WAIT


    SPEED 5
    MOVE G6A, 103, 163,  32, 116, 104,
    MOVE G6D, 101,  63,  84,  80,  96,
    MOVE G6B,  17, 100,  41,  ,  ,
    MOVE G6C,  17,  92,  56,  ,  ,
    WAIT

    SPEED 5
    MOVE G6A, 101,  63,  84,  80,  96,
    MOVE G6D, 101,  63,  84,  80,  96,
    MOVE G6B,  17, 100,  41,  ,  ,
    MOVE G6C,  17,  92,  56,  ,  ,
    WAIT

    SPEED 5
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,100,
    WAIT

    RETURN



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
    MOVE G6C,100,  30,  80,,,
    WAIT	



    RETURN
    '*****************************************************
계단오른발오르기2cm:
    DELAY 1000
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
    MOVE G6A,111,  71, 155,  88,  94
    WAIT


    SPEED 12
    MOVE G6D, 85, 75, 100, 160, 114,
    MOVE G6A,109,  70, 155,  86,  94
    WAIT

    SPEED 12
    MOVE G6D, 85, 35, 145, 145, 110,
    MOVE G6A,109,  70, 155,  80,  98
    WAIT

    GOSUB Leg_motor_mode3

    SPEED 7
    MOVE G6D, 105, 55, 110, 165, 100,
    MOVE G6A,90,  92, 165,  70, 100
    MOVE G6C,160,50
    MOVE G6B,160,40
    WAIT

    SPEED 6
    MOVE G6D, 114, 90, 90, 158,100,
    MOVE G6A,90,  100, 160,  65, 105
    MOVE G6C,180,50
    MOVE G6B,180,30
    WAIT

    '****************************
    GOSUB Leg_motor_mode2	
    SPEED 8
    MOVE G6D, 112, 90, 100, 145,97,
    MOVE G6A,95,  130, 110,  80, 105
    WAIT

    SPEED 10
    MOVE G6D, 112, 90, 100, 138,95,
    MOVE G6A,90,  120, 40,  140, 108
    WAIT

    SPEED 10
    MOVE G6D, 114, 90, 110, 122,95,
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
    MOVE G6A, 98, 90, 110, 122,100,
    MOVE G6D,98,  90, 110,  125, 100
    MOVE G6B,110,40
    MOVE G6C,110,40
    WAIT

    SPEED 6
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80
    MOVE G6C,100,  30,  80
    WAIT

    DELAY 500

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
    GOSUB 기본자세2	
    GOSUB Leg_motor_mode1
    DELAY 400

    RETURN
    '******************************************
앞으로덤블링:
    'All_motor_mode3
    HIGHSPEED SETOFF

    SPEED 10
    MOVE G6A, 100, 140, 45, 140, 100, 100
    MOVE G6D, 100, 140, 45, 140, 100, 100
    MOVE G6B, 115, 30, 85
    MOVE G6C, 115, 30, 85,, 10

    'SPEED 10
    '    MOVE G6A,100, 155,  27, 125, 100, 100
    '    MOVE G6D,100, 155,  27, 125, 100, 100
    '    MOVE G6B,115,  30,  85
    '    MOVE G6C,115,  30,  85,,10
    '    WAIT

    SPEED 15
    'MOVE G6A,100, 155,  27, 125, 100, 100
    'MOVE G6D,100, 155,  27, 125, 100, 100
    MOVE G6B,115,  80,  85
    MOVE G6C,115,  80,  85,,10
    WAIT

    SPEED 15
    'MOVE G6A,100, 155,  27, 125, 100, 100
    'MOVE G6D,100, 155,  27, 125, 100, 100
    MOVE G6A, 100, 140, 45, 150, 100, 100
    MOVE G6D, 100, 140, 45, 150, 100, 100
    MOVE G6B,160,  40,  85
    MOVE G6C,160,  40,  85,,10
    WAIT

    SPEED 10
    MOVE G6A, 100, 145,  55, 165, 100, 100
    MOVE G6D, 100, 145,  55, 165, 100, 100
    MOVE G6B,185,  25, 100
    MOVE G6C,185,  25, 100,,10
    WAIT

    SPEED 10
    MOVE G6A,100, 140, 110, 140, 100, 100
    MOVE G6D,100, 140, 110, 140, 100, 100
    MOVE G6B,140,  70,  20
    MOVE G6C,140,  70,  20,,10
    WAIT

    SPEED 10
    MOVE G6A,100,  56, 100,  26, 100, 100
    MOVE G6D,100,  71, 160, 162, 100, 100
    MOVE G6B,170,  40,  70
    MOVE G6C,170,  40,  70,,10
    WAIT

    SPEED 15
    MOVE G6A,100,  60, 100,  15, 100, 100
    MOVE G6D,100,  70, 120, 30, 100, 100
    MOVE G6B,170,  40,  70
    MOVE G6C,170,  40,  70,,10
    WAIT

    SPEED 15
    MOVE G6A,100,  60, 100,  15, 100, 100
    MOVE G6D,100,  60, 100,  15, 100, 100
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
    MOVE G6B,190, 170, 120
    MOVE G6C,190, 170, 120,,10
    WAIT

    '상체부터세우기
    SPEED 10
    MOVE G6A,100, 170,  70,  55, 100, 100
    MOVE G6D,100, 170,  70,  55, 100, 100
    MOVE G6B,190, 170, 120
    MOVE G6C,190, 170, 120,,10
    WAIT

    '중간동작
    '	 SPEED 10
    '    MOVE G6A,100, 170,  70,  55, 100, 100
    '    MOVE G6D,100, 170,  70,  55, 100, 100
    '    MOVE G6B,190, 60, 60
    '    MOVE G6C,190, 60, 60,,10
    '    WAIT

    SPEED 10
    MOVE G6A,100, 170,  30,  110, 100, 100
    MOVE G6D,100, 170,  30,  110, 100, 100
    MOVE G6B,190,  40,  60
    MOVE G6C,190,  40,  60
    WAIT

    SPEED 12
    GOSUB 앉은자세

    SPEED 10
    GOSUB 기본자세2
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
바닥보고오른쪽옆으로20: '****
    MOTORMODE G6A,3,3,3,3,2
    MOTORMODE G6D,3,3,3,3,2


    SPEED 12
    MOVE G6D, 95,  90, 125, 100, 104, 100
    MOVE G6A,105,  76, 146,  93, 104, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,10,
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
    '********************************************

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
    '*****************************************
바닥보고왼쪽옆으로20: '****
    MOTORMODE G6A,3,3,3,3,2
    MOTORMODE G6D,3,3,3,3,2

    SPEED 12
    MOVE G6A, 95,  90, 125, 100, 104, 100
    MOVE G6D,105,  76, 145,  93, 104, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,10,
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
    보행COUNT = 2
    GOSUB Leg_motor_mode3

    IF 보행순서 = 0 THEN
        보행순서 = 1
        SPEED 4
        '오른쪽기울기
        MOVE G6A, 86,  71, 152,  91, 110
        MOVE G6D,106,  76, 146,  93,  94
        MOVE G6B,100,35
        MOVE G6C,100,35
        WAIT

        SPEED 10'보행속도
        '왼발들기
        MOVE G6A, 90, 100, 115, 105, 114
        MOVE G6D,113,  78, 146,  91,  94
        MOVE G6B,90
        MOVE G6C,110
        WAIT

        GOTO 전진보행50_1
    ELSE
        보행순서=0
        SPEED 4
        '왼쪽기울기2
        MOVE G6A, 106,  76, 146,  93,  96		
        MOVE G6D,  88,  71, 152,  91, 106
        MOVE G6B, 100,35
        MOVE G6C, 100,35
        WAIT	

        SPEED 10
        '오른발들기10
        MOVE G6A,108,  77, 146,  92, 94
        MOVE G6D,90, 100, 105, 110, 114
        MOVE G6B,110
        MOVE G6C,90
        WAIT

        GOTO 전진보행50_2
    ENDIF



전진보행50_1:

    SPEED 10
    '왼발뻣어착지
    MOVE G6A, 85,  42, 163, 113, 114
    MOVE G6D,110,  77, 146,  90,  94
    WAIT

    SPEED 4
    '왼발중심이동
    MOVE G6A,106,  76, 144, 96,  93
    MOVE G6D,90, 93, 155,  71, 112
    WAIT

    SPEED 10
    '오른발들기10
    MOVE G6A,109,  77, 146,  92, 94
    MOVE G6D,90, 100, 105, 110, 114
    MOVE G6B,110
    MOVE G6C,90
    WAIT

    'ERX 4800,A, 전진보행50_2
    'IF A <> A_old THEN
    '    HIGHSPEED SETOFF
    '    SPEED 5
    '왼쪽기울기2
    '    MOVE G6A, 106,  76, 146,  93,  96		
    '    MOVE G6D,  88,  71, 152,  91, 106
    '    MOVE G6B, 100,35
    '    MOVE G6C, 100,35
    '    WAIT	

    '    SPEED 3
    '    GOSUB 기본자세
    '    GOSUB Leg_motor_mode1

    '    GOTO MAIN
    'ENDIF
    보행COUNT = 보행COUNT + 1
    IF 보행COUNT > 보행횟수 THEN  GOTO 기본자세
    '**********


전진보행50_2:

    SPEED 10
    '오른발뻣어착지
    MOVE G6D,89,  44, 165, 113, 114
    MOVE G6A,108,  77, 146,  93,  94
    WAIT

    SPEED 4
    '오른발중심이동
    MOVE G6D,106,  76, 144, 97,  93
    MOVE G6A, 90, 93, 155,  70, 112
    WAIT

    SPEED 10
    '왼발들기10
    MOVE G6A, 90, 100, 105, 110, 114
    MOVE G6D,111,  77, 146,  93,  94
    MOVE G6B, 90
    MOVE G6C,110
    WAIT

    'ERX 4800,A, 전진보행50_1
    'IF A <> A_old THEN
    '    HIGHSPEED SETOFF
    '    SPEED 5
    '오른쪽기울기2
    '    MOVE G6D, 106,  76, 146,  93,  96		
    '    MOVE G6A,  88,  71, 152,  91, 106
    '    MOVE G6C, 100,35
    '    MOVE G6B, 100,35
    '    WAIT

    '    SPEED 3
    '    GOSUB 기본자세
    '    GOSUB Leg_motor_mode1
    '    GOTO MAIN
    'ENDIF
    보행COUNT = 보행COUNT + 1
    IF 보행COUNT > 보행횟수 THEN  GOTO 기본자세


    GOTO 전진보행50_1
    '************************************************

    '************************************************
전진종종걸음:
    넘어진확인 = 0
    보행COUNT = 0
    DELAY 200
    SPEED 10
    HIGHSPEED SETON
    GOSUB All_motor_mode3

    IF 보행순서 = 0 THEN
        보행순서 = 1
        MOVE G6A,95,  76, 145,  93, 101
        MOVE G6D,101,  77, 145,  93, 98
        MOVE G6B,100,  35
        MOVE G6C,100,  35, ,,100
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
    GOSUB 기본자세2

    DELAY 400

    GOSUB Leg_motor_mode1
    RETURN


    '***************************************************
밑에보고종종걸음:
    넘어진확인 = 0
    보행COUNT = 0

    SPEED 4
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80, 100, 100, 100
    MOVE G6C,100,  30,  80, 100, 65, 100
    WAIT

    SPEED 10
    HIGHSPEED SETON
    GOSUB All_motor_mode3

    IF 보행순서 = 0 THEN
        보행순서 = 1
        MOVE G6A,95,  76, 145,  93, 101
        MOVE G6D,101,  77, 145,  93, 98
        MOVE G6B,100,  35
        MOVE G6C,100,  35
        WAIT

        GOTO 밑에보고종종걸음_1
    ELSE
        보행순서 = 0
        MOVE G6D,95,  76, 145,  93, 101
        MOVE G6A,101,  77, 145,  93, 98
        MOVE G6B,100,  35
        MOVE G6C,100,  35
        WAIT

        GOTO 밑에보고종종걸음_4
    ENDIF


    '**********************

밑에보고종종걸음_1:
    MOVE G6A,95,  95, 120, 100, 104
    MOVE G6D,104,  77, 146,  91,  102
    MOVE G6B, 80
    MOVE G6C,120
    WAIT


밑에보고종종걸음_2:
    MOVE G6A,95,  85, 130, 103, 104
    MOVE G6D,104,  79, 146,  89,  100
    WAIT

밑에보고종종걸음_3:
    MOVE G6A,103,   85, 130, 103,  100
    MOVE G6D, 95,  79, 146,  89, 102
    WAIT

    'GOSUB 앞뒤기울기측정
    'IF 넘어진확인 = 1 THEN
    '    넘어진확인 = 0
    '    GOTO MAIN
    'ENDIF

    'ERX 4800,A, 전진종종걸음_4
    'IF A <> A_old THEN  GOTO 전진종종걸음_멈춤
    보행COUNT = 보행COUNT + 1
    IF 보행COUNT > 보행횟수 THEN  GOTO 밑에보고종종걸음_멈춤
    '*********************************

밑에보고종종걸음_4:
    MOVE G6D,95,  95, 120, 100, 104
    MOVE G6A,104,  77, 146,  91,  102
    MOVE G6C, 80
    MOVE G6B,120
    WAIT


밑에보고종종걸음_5:
    MOVE G6D,95,  85, 130, 103, 104
    MOVE G6A,104,  79, 146,  89,  100
    WAIT

밑에보고종종걸음_6:
    MOVE G6D,103,   85, 130, 103,  100
    MOVE G6A, 95,  79, 146,  89, 102
    WAIT

    'GOSUB 앞뒤기울기측정
    'IF 넘어진확인 = 1 THEN
    '    넘어진확인 = 0
    '    GOTO MAIN
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
    GOSUB 기본자세2

    DELAY 400

    GOSUB Leg_motor_mode1
    GOTO RX_EXIT
    '*****************************************************
바닥보고종종걸음:
    넘어진확인 = 0
    보행COUNT = 0

    SPEED 4
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80, 100, 100, 100
    MOVE G6C,100,  30,  80, 100, 10, 100
    WAIT

    SPEED 10
    HIGHSPEED SETON
    GOSUB All_motor_mode3

    IF 보행순서 = 0 THEN
        보행순서 = 1
        MOVE G6A,95,  76, 145,  93, 101
        MOVE G6D,101,  77, 145,  93, 98
        MOVE G6B,100,  35
        MOVE G6C,100,  35
        WAIT

        GOTO 바닥보고종종걸음_1
    ELSE
        보행순서 = 0
        MOVE G6D,95,  76, 145,  93, 101
        MOVE G6A,101,  77, 145,  93, 98
        MOVE G6B,100,  35
        MOVE G6C,100,  35
        WAIT

        GOTO 바닥보고종종걸음_4
    ENDIF


    '**********************

바닥보고종종걸음_1:
    MOVE G6A,95,  95, 120, 100, 104
    MOVE G6D,104,  77, 146,  91,  102
    MOVE G6B, 80
    MOVE G6C,120
    WAIT


바닥보고종종걸음_2:
    MOVE G6A,95,  85, 130, 103, 104
    MOVE G6D,104,  79, 146,  89,  100
    WAIT

바닥보고종종걸음_3:
    MOVE G6A,103,   85, 130, 103,  100
    MOVE G6D, 95,  79, 146,  89, 102
    WAIT

    'GOSUB 앞뒤기울기측정
    'IF 넘어진확인 = 1 THEN
    '    넘어진확인 = 0
    '    GOTO MAIN
    'ENDIF

    'ERX 4800,A, 전진종종걸음_4
    'IF A <> A_old THEN  GOTO 전진종종걸음_멈춤
    보행COUNT = 보행COUNT + 1
    IF 보행COUNT > 보행횟수 THEN  GOTO 바닥보고종종걸음_멈춤
    '*********************************

바닥보고종종걸음_4:
    MOVE G6D,95,  95, 120, 100, 104
    MOVE G6A,104,  77, 146,  91,  102
    MOVE G6C, 80
    MOVE G6B,120
    WAIT


바닥보고종종걸음_5:
    MOVE G6D,95,  85, 130, 103, 104
    MOVE G6A,104,  79, 146,  89,  100
    WAIT

바닥보고종종걸음_6:
    MOVE G6D,103,   85, 130, 103,  100
    MOVE G6A, 95,  79, 146,  89, 102
    WAIT

    'GOSUB 앞뒤기울기측정
    'IF 넘어진확인 = 1 THEN
    '    넘어진확인 = 0
    '    GOTO MAIN
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
    GOSUB 기본자세2

    DELAY 400

    GOSUB Leg_motor_mode1
    RETURN


    '*****************************************
우많이:

    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT



    SPEED 10
    MOVE G6A,  96,  76, 144,  93, 107,
    MOVE G6D,  94,  90, 128,  99, 103,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 101,  47,  81,  ,  ,
    WAIT



    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT

    RETURN

우조금:

    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT



    ' SPEED 10
    '    MOVE G6A,  96,  76, 144,  93, 107,
    '    MOVE G6D,  94,  90, 128,  99, 103,
    '    MOVE G6B, 100,  30,  80,  ,  ,
    '    MOVE G6C, 101,  47,  81,  ,  ,
    '    WAIT

    SPEED 10
    MOVE G6A,  96,  76, 144,  93, 103,
    MOVE G6D, 100,  90, 128,  99, 103,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 101,  47,  81,  ,  ,
    WAIT




    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT

    RETURN

좌조금:
    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT



    SPEED 10
    MOVE G6A, 100,  90, 128,  99, 103,
    MOVE G6D, 96,  76, 144,  93, 103,
    MOVE G6B, 101,  47,  81,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT



    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT

    RETURN


마니앞:

    SPEED 5
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT

    'SPEED 5
    '    MOVE G6A, 100,  76, 145,  93, 101,
    '    MOVE G6D, 100,  82, 118, 126, 105,
    '    MOVE G6B, 143,  31,  86,  ,  ,
    '    MOVE G6C,  87,  38,  82,  ,  ,
    '    WAIT

    SPEED 5
    MOVE G6A,  94,  76, 145,  93, 101,
    MOVE G6D, 100,  82, 118, 126, 105,
    MOVE G6B, 143,  31,  86,  ,  ,
    MOVE G6C,  87,  38,  82,  ,  ,
    WAIT

    SPEED 5
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT


    SPEED 5
    MOVE G6A, 100,  82, 118, 126, 105,
    MOVE G6D, 94,  76, 145,  93, 101,
    MOVE G6B,  87,  38,  82,  ,  ,
    MOVE G6C, 143,  31,  86,  ,  ,
    WAIT

    RETURN

좌살짝:

    SPEED 5
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT

    SPEED 5
    MOVE G6A, 100,  76, 145,  93, 105,
    MOVE G6D, 110,  76, 145,  93, 100,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    SPEED 5
    MOVE G6A, 100,  76, 145,  93, 105,
    MOVE G6D, 100,  76, 145,  93, 100,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    SPEED 5
    MOVE G6A, 100,  76, 145,  93, 105,
    MOVE G6D, 100,  76, 145,  93,  90,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    SPEED 5
    MOVE G6A, 100,  76, 145,  93,  90,
    MOVE G6D, 100,  76, 145,  93,  90,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    SPEED 5
    MOVE G6A, 100,  76, 145,  93,  95,
    MOVE G6D, 100,  76, 145,  93, 100,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    RETURN

우살짝:

    SPEED 5
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT

    SPEED 5
    MOVE G6D, 100,  76, 145,  93, 105,
    MOVE G6A, 110,  76, 145,  93, 100,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    SPEED 5
    MOVE G6D, 100,  76, 145,  93, 105,
    MOVE G6A, 100,  76, 145,  93, 100,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    SPEED 5
    MOVE G6D, 100,  76, 145,  93, 105,
    MOVE G6A, 100,  76, 145,  93,  90,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    SPEED 5
    MOVE G6D, 100,  76, 145,  93,  90,
    MOVE G6A, 100,  76, 145,  93,  90,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    SPEED 5
    MOVE G6D, 100,  76, 145,  93,  95,
    MOVE G6A, 100,  76, 145,  93, 100,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    RETURN

Rturn:
    SPEED 8
    MOVE G6A,  97,  74, 145,  93, 100,
    MOVE G6D,  96,  93, 145,  98, 100,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,

    GOSUB 기본자세

    RETURN

kick:
    GOSUB 자이로OFF
    SPEED 7
    MOVE G6A, 114, 116,  53, 138, 102,
    MOVE G6D,  88,  72,  78, 162,  96,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    'MOVE G6A, 121, 106,  61, 146, 105,
    'MOVE G6D,  88,  72,  78, 162,  96,
    'MOVE G6B, 100,  30,  80,  ,  ,
    'MOVE G6C, 100,  30,  80,  ,  ,
    'WAIT

    ' MOVE G6A, 113, 111,  67, 146, 101,
    'MOVE G6D,  92,  83,  55, 162, 104,
    'MOVE G6B, 100,  30,  80,  ,  ,
    'MOVE G6C, 100,  30,  80,  ,  ,
    'WAIT


    SPEED 7
    MOVE G6A, 113, 111,  67, 143,  98,
    MOVE G6D,  92,  15, 140, 162, 107,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    'MOVE G6A, 113, 111,  67, 132,  95,
    '    MOVE G6D,  80,  15, 140, 157, 106,
    '    MOVE G6B, 100,  30,  80,  ,  ,
    '    MOVE G6C, 100,  30,  80,  ,  ,
    '    WAIT
    SPEED 7

    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT

    RETURN




msmssh:

    SPEED 10
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT

    SPEED 7
    MOVE G6A, 100,  76, 145,  93, 109,
    MOVE G6D, 100,  89, 104, 117,  98,
    MOVE G6B, 100,  47,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,
    WAIT

    SPEED 7
    MOVE G6A, 100,  , 145,  84, 109,
    MOVE G6D, 100,  62, 141, 128,  97,
    MOVE G6B, 144,  33,  81,  ,  ,
    MOVE G6C,  69,  38,  81,  ,  ,
    WAIT

    SPEED 7
    MOVE G6A, 104,  73, 111, 137,  97,
    MOVE G6D, 100,  62, 141, 128, 112,
    MOVE G6B, 110,  22,  81,  ,  ,
    MOVE G6C, 117,  57,  82,  ,  ,
    WAIT

    SPEED 7
    MOVE G6A, 105,  37, 164, 119,  94,
    MOVE G6D,  ,  , 141,  88, 111,
    MOVE G6B,  85,  23,  81,  ,  ,
    MOVE G6C, 154,  49,  82,  ,  ,
    WAIT

    SPEED 7
    MOVE G6A, 105,  37, 164, 129, 108,
    MOVE G6D,  94,  71, 129, 138,  100,
    MOVE G6B, 125,  32,  83,  ,  ,
    MOVE G6C, 125,  28,  83,  ,  ,
    WAIT

    SPEED 7
    MOVE G6A,100,  76, 145,  93, 100, 100
    MOVE G6D,100,  76, 145,  93, 100, 100
    MOVE G6B,100,  30,  80,
    MOVE G6C,100,  30,  80,,65,
    WAIT


    RETURN

계단왼발오르기3cm2:
    GOSUB All_motor_mode3

    SPEED 4
    MOVE G6A, 88,  71, 152,  91, 110
    MOVE G6D,108,  76, 146,  93,  94
    MOVE G6B,100,40
    MOVE G6C,100,40
    WAIT

    SPEED 10
    MOVE G6A, 90, 100, 110, 100, 114
    MOVE G6D,113,  78, 146,  93,  94
    WAIT

    GOSUB Leg_motor_mode2

    SPEED 15
    MOVE G6A,  90, 140,  35, 130, 114,
    MOVE G6D, 113,  73, 155,  90,  94,
    MOVE G6B, 100,  95,  80,  ,  ,
    MOVE G6C, 100,  40,  95,  ,  ,
    WAIT

    SPEED 14
    MOVE G6A,  85,  40, 120, 170, 114,
    MOVE G6D, 113,  70, 155,  90,  94,
    MOVE G6B, 100,  40,  80,  ,  ,
    MOVE G6C, 100,  40,  80,  ,  ,
    WAIT

    GOSUB Leg_motor_mode3

    SPEED 7
    MOVE G6A, 105, 70, 100, 160, 100,
    MOVE G6D,80,  90, 165,  70, 100
    MOVE G6B,160,50
    MOVE G6C,160,40
    WAIT

    SPEED 6
    MOVE G6A, 113,  90,  80, 175,  95,
    MOVE G6D,  70,  95, 170,  45, 105,
    MOVE G6B, 180,  50,  80,  ,  ,
    MOVE G6C, 180,  30,  80,  ,  ,
    WAIT

    GOSUB Leg_motor_mode3
    SPEED 8
    MOVE G6A, 114,  90, 100, 150,  95,
    MOVE G6D,  75,  85, 160,  65, 105,
    MOVE G6B, 140,  50,  80,  ,  ,
    MOVE G6C, 140,  30,  80,  ,  ,
    WAIT

    SPEED 12
    MOVE G6A, 114, 90, 100, 150,95,
    MOVE G6D,90,  120, 40,  140, 108
    WAIT

    SPEED 10
    MOVE G6A, 114,  90, 110, 125,  90,
    MOVE G6D,  90,  95,  90, 145, 118,
    MOVE G6B,  50,  30,  80,  ,  ,
    MOVE G6C, 115,  90,  95,  ,  ,
    WAIT


    SPEED 10
    MOVE G6A, 110,  90, 110, 125,  95,
    MOVE G6D,  80,  85, 110, 135, 118,
    MOVE G6B,  80,  40,  80,  ,  ,
    MOVE G6C, 100,  85, 100,  ,  ,
    WAIT


    SPEED 5
    MOVE G6D, 98, 90, 110, 125,99,
    MOVE G6A,98,  90, 110,  125, 99
    MOVE G6B,110,40
    MOVE G6C,110,40
    WAIT

    SPEED 6
    GOSUB 기본자세

    GOTO RX_EXIT

계단왼발오르기3cm:
    GOSUB All_motor_mode3

    SPEED 4
    MOVE G6A, 88,  71, 152,  91, 110
    MOVE G6D,108,  76, 146,  93,  94
    MOVE G6B,100,40
    MOVE G6C,100,40
    WAIT

    SPEED 10
    MOVE G6A, 90, 100, 110, 100, 114
    MOVE G6D,113,  78, 146,  93,  94
    WAIT

    GOSUB Leg_motor_mode2

    SPEED 15
    MOVE G6A,  90, 140,  35, 130, 114,
    MOVE G6D, 113,  73, 155,  90,  94,
    MOVE G6B, 100,  95,  80,  ,  ,
    MOVE G6C, 100,  40,  95,  ,  ,
    WAIT

    SPEED 14
    MOVE G6A,  85,  40, 120, 170, 114,
    MOVE G6D, 113,  70, 155,  90,  94,
    MOVE G6B, 100,  40,  80,  ,  ,
    MOVE G6C, 100,  40,  80,  ,  ,
    WAIT

    GOSUB Leg_motor_mode3

    SPEED 7
    MOVE G6A, 105, 70, 100, 160, 100,
    MOVE G6D,80,  90, 165,  70, 100
    MOVE G6B,160,50
    MOVE G6C,160,40
    WAIT

    SPEED 6
    MOVE G6A, 113,  90,  80, 175,  95,
    MOVE G6D,  70,  95, 170,  45, 105,
    MOVE G6B, 180,  50,  80,  ,  ,
    MOVE G6C, 180,  30,  80,  ,  ,
    WAIT

    GOSUB Leg_motor_mode3
    SPEED 8
    MOVE G6A, 114,  90, 100, 150,  95,
    MOVE G6D,  75,  85, 160,  65, 105,
    MOVE G6B, 140,  50,  80,  ,  ,
    MOVE G6C, 140,  30,  80,  ,  ,
    WAIT

    SPEED 12
    MOVE G6A, 114, 90, 100, 150,95,
    MOVE G6D,90,  120, 40,  140, 108
    WAIT

    SPEED 10
    MOVE G6A, 114,  90, 110, 125,  90,
    MOVE G6D,  90,  95,  90, 145, 118,
    MOVE G6B,  50,  30,  80,  ,  ,
    MOVE G6C, 115,  90,  95,  ,  ,
    WAIT


    SPEED 10
    MOVE G6A, 110,  90, 110, 125,  95,
    MOVE G6D,  80,  85, 110, 135, 118,
    MOVE G6B,  80,  40,  80,  ,  ,
    MOVE G6C, 100,  85, 100,  ,  ,
    WAIT


    SPEED 5
    MOVE G6D, 98, 90, 110, 125,99,
    MOVE G6A,98,  90, 110,  125, 99
    MOVE G6B,110,40
    MOVE G6C,110,40
    WAIT

    SPEED 6
    GOSUB 기본자세

    GOTO RX_EXIT



노랑초록:
    GOSUB All_motor_mode3

    SPEED 4
    MOVE G6A, 88,  71, 152,  91, 110
    MOVE G6D,108,  76, 146,  93,  94
    MOVE G6B,100,40
    MOVE G6C,100,40
    WAIT

    SPEED 10
    MOVE G6A, 90, 100, 110, 100, 114
    MOVE G6D,113,  78, 146,  93,  94
    WAIT

    GOSUB Leg_motor_mode2

    SPEED 15
    MOVE G6A,  90, 140,  35, 130, 114,
    MOVE G6D, 113,  73, 155,  90,  94,
    MOVE G6B, 100,  95,  80,  ,  ,
    MOVE G6C, 100,  40,  95,  ,  ,
    WAIT

    SPEED 14
    MOVE G6A,  85,  40, 120, 150, 114,
    MOVE G6D, 113,  70, 155,  90,  94,
    MOVE G6B, 100,  40,  80,  ,  ,
    MOVE G6C, 100,  40,  80,  ,  ,
    WAIT

    GOSUB Leg_motor_mode3

    SPEED 7
    MOVE G6A, 105, 60, 100, 160, 100,
    MOVE G6D,80,  95, 165,  70, 100
    MOVE G6B,160,50
    MOVE G6C,160,40
    WAIT

    SPEED 6
    MOVE G6A, 113,  90,  80, 175,  95,
    MOVE G6D,  70,  95, 160,  45, 105,
    MOVE G6B, 180,  50,  80,  ,  ,
    MOVE G6C, 180,  30,  80,  ,  ,
    WAIT

    GOSUB Leg_motor_mode3
    SPEED 8
    MOVE G6A, 114,  90, 100, 150,  95,
    MOVE G6D,  75,  85, 160,  65, 105,
    MOVE G6B, 140,  50,  80,  ,  ,
    MOVE G6C, 140,  30,  80,  ,  ,
    WAIT

    SPEED 12
    MOVE G6A, 114, 90, 100, 150,95,
    MOVE G6D,90,  120, 40,  140, 108
    WAIT

    SPEED 10
    MOVE G6A, 114,  90, 110, 125,  90,
    MOVE G6D,  90,  95,  90, 145, 118,
    MOVE G6B,  50,  30,  80,  ,  ,
    MOVE G6C, 115,  90,  95,  ,  ,
    WAIT


    SPEED 10
    MOVE G6A, 110,  90, 110, 125,  95,
    MOVE G6D,  80,  85, 110, 135, 118,
    MOVE G6B,  80,  40,  80,  ,  ,
    MOVE G6C, 100,  85, 100,  ,  ,
    WAIT


    SPEED 5
    MOVE G6D, 98, 90, 110, 125,99,
    MOVE G6A,98,  90, 110,  125, 99
    MOVE G6B,110,40
    MOVE G6C,110,40
    WAIT

    SPEED 6
    GOSUB 기본자세

    GOTO RX_EXIT

GO_A_LITTLE:
    SPEED 13
    MOVE G6A,  98,  73, 153,  94, 100,
    MOVE G6D, 104,  62, 150, 110,  99,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,

    WAIT


    MOVE G6A,  99,  56, 156, 109,  99,
    MOVE G6D, 100,  74, 153,  92, 100,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,

    WAIT

    GOSUB 기본자세

    RETURN

MYTURN:
    SPEED 8
    MOVE G6A, 105,  91, 145,  89, 100,
    MOVE G6D,  104,  75, 145,  89, 100,
    MOVE G6B, 100,  30,  80,  ,  ,
    MOVE G6C, 100,  30,  80,  ,  ,



    WAIT


    GOSUB 기본자세
    RETURN

YOURTURN:

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


    'GOSUB 앞뒤기울기측정
    'GOSUB 좌우기울기측정

    'GOSUB 적외선거리센서확인
    'GOSUB 자이로OFF
    'DELAY 3000
    'GOSUB 계단오른발오르기2cm
    'DELAY 500
    'DELAY 4000
    'GOSUB 계단왼발오르기3cm2
    'GOSUB 계단오른발내리기2cm2
    'DIM zxc AS BYTE
    '     FOR zxc = 0 TO 2
    '      GOSUB 바닥보고종종걸음
    '     NEXT zxc
    '    DIM asd AS BYTE
    '     FOR asd = 0 TO 1
    '      GOSUB 왼쪽턴1033
    '     NEXT asd
    'GOSUB DumblingForward_BLUE
    'GOSUB 계단오른발내리기2cm
    'GOSUB 짚고내리기노란색
    'DIM uu AS BYTE
    '         FOR uu = 0 TO 1
    '          GOSUB 좌조금
    '         NEXT uu
    'GOSUB 오른쪽턴60
    'GOSUB 우살짝
    'GOSUB Rturn
    'GOSUB GO_A_LITTLE
    'GOSUB MYTURN

    GOTO MAIN	
    '*******************************************
    '		MAIN 라벨로 가기
    '*******************************************



KEY1:
    'ETX  9600,1
    GOTO 밑에보고종종걸음

    GOTO MAIN
    '***************	
KEY2:
    'ETX  9600,2
    GOSUB 바닥보고종종걸음

    GOTO MAIN
    '***************
KEY3:
    'ETX  9600,3
    GOSUB 머리바닥보기
    DELAY 800
    GOSUB 앞으로덤블링

    GOTO MAIN
    '***************
KEY4:
    'ETX  9600,4
    GOSUB 계단오른발내리기4cm


    GOTO MAIN
    '***************
KEY5:
    'ETX  9600,5
    GOSUB DumblingForward_BLUE	

    GOTO MAIN
    '***************
KEY6:
    'ETX  9600,6
    GOSUB 왼쪽턴60
    DIM turnCOUNT AS BYTE
    FOR turnCOUNT = 0 TO 4
        GOSUB 왼쪽턴10
    NEXT turnCOUNT

    '    GOSUB 머리오른쪽90도
    '    GOSUB 전방하향60도
    '    SPEED 15
    '    SERVO 6, 10
    '    SERVO 12, 10
    '    DELAY 1000
    '
    GOTO MAIN
    '***************
KEY7:
    'ETX  9600,7

    GOSUB 좌살짝

    GOTO MAIN
    '***************
KEY8:
    'ETX  9600,8

    GOSUB 우살짝


    GOTO MAIN
    '***************
KEY9:
    'ETX  9600,9
    GOSUB 계단왼발오르기3cm2

    GOTO MAIN
    '***************
KEY10: '0
    'ETX  9600,10

    GOSUB 계단오른발내리기2cm2

    GOTO MAIN
    '***************
KEY11: ' ▲
    'ETX  9600,11

    GOSUB 왼쪽턴10
    DELAY 400

    GOTO MAIN
    '***************
KEY12: ' ▼
    'ETX  9600,12
    GOSUB 오른쪽턴10
    DELAY 400
    'GOSUB 머리오른쪽90도

    GOTO MAIN
    '***************
KEY13: '▶
    'ETX  9600,13
    GOSUB 머리바닥보기
    'DELAY 600

    GOTO MAIN
    '***************
KEY14: ' ◀
    'ETX  9600,14
    GOSUB 전진종종걸음
    DELAY 400

    GOTO MAIN
    '***************
KEY15: ' A
    'ETX  9600,15
    GOSUB 밑에보고종종걸음

    GOTO MAIN
    '***************
KEY16: ' POWER
    'ETX  9600,16
    보행횟수 = 4
    GOSUB 바닥보고종종걸음

    GOTO MAIN
    '***************
KEY17: ' C
    'ETX  9600,17
    GOSUB 앞으로덤블링

    GOTO MAIN
    '***************
KEY18: ' E
    'ETX  9600,18	
    GOSUB 계단오른발내리기4cm

    GOTO MAIN
    '***************
KEY19: ' P2
    'ETX  9600,19

    GOSUB 전방하향60도

    GOTO MAIN
    '***************
KEY20: ' B	
    'ETX  9600,20

    GOSUB 전방하향60도
    GOSUB 왼쪽옆으로20

    GOTO MAIN
    '***************
KEY21: ' △
    'ETX  9600,21

    GOSUB 전방하향60도
    GOSUB 오른쪽옆으로20


    GOTO MAIN
    '***************
KEY22: ' *	
    'ETX  9600,22

    GOSUB 전방보기

    GOTO MAIN
    '***************
KEY23: ' G
    'ETX  9600,23

    GOSUB 왼쪽턴10

    GOTO MAIN
    '***************
KEY24: ' #
    'ETX  9600,24

    GOSUB 오른쪽턴10

    GOTO MAIN
    '***************
KEY25: ' P1
    'ETX  9600,25

    GOSUB 전방보기

    GOTO MAIN
    '***************
KEY26: ' ■
    'ETX  9600,26

    GOSUB 전방하향30도

    GOTO MAIN
    '***************
KEY27: ' D
    'ETX  9600,27

    GOSUB 전방하향60도

    GOTO MAIN
    '***************
KEY28: ' ◁
    'ETX  9600,28

    GOSUB 전방하향20도

    GOTO MAIN
    '***************
KEY29: ' □
    'ETX  9600,29

    GOSUB 머리좌우중앙

    GOTO MAIN
    '***************
KEY30: ' ▷
    'ETX  9600,30

    GOSUB 머리오른쪽90도

    GOTO MAIN
    '***************
KEY31: ' ▽
    'ETX  9600,31

    GOSUB 머리왼쪽90도

    GOTO MAIN
    '***************

KEY32: ' F
    'ETX  9600,32

    MUSIC "DFDF"

    GOTO MAIN
    '***************
