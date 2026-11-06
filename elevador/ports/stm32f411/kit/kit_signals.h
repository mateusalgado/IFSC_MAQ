#ifndef KIT_SIGNALS_H
#define KIT_SIGNALS_H
#include "inputs.h"
#include "motor.h"

#define KIT_STANDBY_BIT (1u << 14)
#define KIT_DIRECTION_BITS ((1u << 12) | (1u << 13))
#define KIT_PWM_COUNTS 4800u /* TIM1 at 96 MHz, 20 kHz */
typedef struct { uint32_t port_b_bsrr, compare; } KitSignals;
RawInputs kit_decode(uint32_t port_a, uint32_t port_b, uint16_t adc, bool fresh);
KitSignals kit_signals(MotorOutput command);
#endif
