#ifndef KIT_SIGNALS_H
#define KIT_SIGNALS_H
#include "inputs.h"
#include "motor.h"

#define KIT_STANDBY_BIT (1u << 14)
#define KIT_CALL_PINS ((1u << 3) | (1u << 4) | (1u << 15)) /* port B, NO to ground */
#define KIT_DIRECTION_BITS ((1u << 12) | (1u << 13))
#define KIT_PWM_COUNTS 4800u /* TIM1 at 96 MHz, 20 kHz */
/* Door servo on TIM10_CH1 (PB8): 1 MHz tick, 50 Hz frame, compare in microseconds.
 * Provisional end points; calibrate with the real servo and door. */
#define KIT_SERVO_PRESCALER 96u /* TIM10 at 96 MHz */
#define KIT_SERVO_PERIOD_US 20000u
#define KIT_SERVO_CLOSED_US 1000u
#define KIT_SERVO_OPEN_US 2000u
typedef struct { uint32_t port_b_bsrr, compare; } KitSignals;
RawInputs kit_decode(uint32_t port_a, uint32_t port_b, uint16_t adc, bool fresh);
KitSignals kit_signals(MotorOutput command);
uint32_t kit_servo_compare(bool open);
#endif
