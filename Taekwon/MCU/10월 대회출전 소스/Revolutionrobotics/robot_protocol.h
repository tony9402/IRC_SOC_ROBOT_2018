#ifndef __ROBOT_PROTOCOL_H__
#define __ROBOT_PROTOCOL_H__

#define SCI_BUF_SIZE   4

#define START_CODE    0xFF
#define START_CODE1   0x55
#define Hdata	      0x00
#define Hdata1        0xFF

#define CONT_FWD_LEFT	0x01 /* Left Motor move foward Continuously */ 
#define CONT_FWD_RIGHT  0x02 /* Right Motor move foward Continuously */ 
#define CONT_FWD_ALL	0x03 /* All Motor move foward Continuously */ 
#define CONT_BWD_LEFT   0x04 /* Left Motor move backward Continuously */ 
#define CONT_BWD_RIGHT  0x05 /* Right Motor move backward Continuously */ 
#define CONT_BWD_ALL	0x06 /* All Motor move backward Continuously */
#define CONT_STOP		0x07 /* All Motor stop */

//#define SET_STEP_LEFT   0x08 /* Left Motor Setting steps */
//#define SET_STEP_RIGHT  0x09 /* Right Motor Setting steps */
//#define SET_STEP_ALL	0x0a /* All Motor Setting steps */
//#define GET_STEP_LEFT   0x0b
//#define GET_STEP_RIGHT  0x0c
//#define GET_STEP_ALL	0x0d
//#define STEP_FWD_LEFT   0x0e
//#define STEP_FWD_RIGHT  0x0f
//#define STEP_FWD_ALL	0x10
//#define STEP_BWD_LEFT   0x11
//#define STEP_BWD_RIGHT	0x12
//#define STEP_BWD_ALL	0x13

#define LASER_SHOOT		0x14 /* Shoot the laser pointer */
#define GET_ENERGY		0x15 /* Get the remains energy */
#define GET_SHOT		0x16 /* Get the remains bullet number */

#define SET_V_LEFT		0x17
#define SET_V_RIGHT		0x18
#define SET_V_ALL		0x19
#define GET_V_LEFT		0x1a
#define GET_V_RIGHT		0x1b

#define GET_V_ALL		0x1c

//#define DAMAGE_ALERT	0xFE

#define CHECK_BOTTOM	0x20		
#define CHECK_DAMAGE_POINT	0x30	
#define LASER_READY	0x40	

#define MOTOR_ALARM	0x41
#define GAME_OVER	0x42
#define DEAD 0x44

void DelayLoop(int delay_time);
void Send_Command(unsigned char Ldata, unsigned char Ldata1);
unsigned char Receive_Ack(void);
void init();
void InitSlow();

#endif // __ROBOT_PROTOCOL_H__
