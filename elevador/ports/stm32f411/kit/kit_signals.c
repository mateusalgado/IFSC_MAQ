#include "kit_signals.h"
#include "elevator_config.h"

RawInputs kit_decode(uint32_t port_a, uint32_t port_b, uint16_t adc, bool fresh) {
    return (RawInputs){
        .joystick = adc, .valid = fresh,
        .button = !(port_a & (1u << 2)),
        .floors = (uint8_t)((~port_a >> 3) & 7u), /* NO to ground */
        .lower_limit = (port_b & (1u << 0)) != 0,
        .upper_limit = (port_b & (1u << 1)) != 0,
        .stop = (port_b & (1u << 10)) != 0 /* NC to ground */
    };
}

KitSignals kit_signals(MotorOutput command) {
    uint32_t direction = 0, compare = 0;
    if ((command.direction == 1 || command.direction == -1) &&
        command.pwm && command.pwm <= EL_PWM_MAX &&
        (command.stop == MOTOR_NORMAL || command.stop == MOTOR_REVERSAL)) {
        direction = command.direction == 1 ? (1u << 12) : (1u << 13);
        compare = (uint32_t)command.pwm * KIT_PWM_COUNTS / 1000u;
    }
    /* BSRR high half clears pins. STBY is cleared in every possible state. */
    return (KitSignals){((KIT_STANDBY_BIT | (KIT_DIRECTION_BITS ^ direction)) << 16)
                         | direction, compare};
}

uint32_t kit_servo_compare(bool open) {
    return open ? KIT_SERVO_OPEN_US : KIT_SERVO_CLOSED_US;
}
