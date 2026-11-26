#include "kit_signals.h"
#include "elevator_config.h"
#include <assert.h>
#include <stdio.h>

int main(void) {
    /* Verify all three NO sensors and the three independent NC safety contacts. */
    for (unsigned mask = 0; mask < 8; ++mask) {
        unsigned pa = (~mask & 7u) << 3;
        unsigned pb = (mask & 3u) | ((mask & 4u) << 8);
        RawInputs raw = kit_decode(pa | 4u, pb | KIT_CALL_PINS, 2050u, true);
        assert(raw.calls == 0);
        assert(raw.floors == mask && raw.joystick == 2050u && raw.valid && !raw.button);
        assert(raw.lower_limit == !!(mask & 1u) && raw.upper_limit == !!(mask & 2u));
        assert(raw.stop == !!(mask & 4u));
    }
    RawInputs stale = kit_decode(0, 0, 0, false);
    assert(!stale.valid && stale.button);
    for (int dir = -2; dir <= 2; ++dir) {
        for (unsigned pwm = 0; pwm <= 1000u; ++pwm) {
            for (int stop = MOTOR_NORMAL; stop <= MOTOR_FAULT; ++stop) {
                KitSignals s = kit_signals((MotorOutput){dir, (uint16_t)pwm, (MotorStop)stop});
                assert(!(s.port_b_bsrr & (1u << 14)) && (s.port_b_bsrr & (1u << 30)));
                unsigned pins = 0;
                if ((dir == 1 || dir == -1) && pwm && pwm <= EL_PWM_MAX && stop != MOTOR_FAULT)
                    pins = dir == 1 ? (1u << 12) : (1u << 13);
                assert((s.port_b_bsrr & 0xffffu) == pins);
                assert((s.port_b_bsrr >> 16) == ((7u << 12) ^ pins));
                assert(s.compare == (pins ? pwm * 4800u / 1000u : 0u));
            }
        }
    }
    /* HMI floor buttons: each NO contact to ground maps to one bit. */
    for (unsigned mask = 0; mask < 8; ++mask) {
        unsigned pb = KIT_CALL_PINS;
        if (mask & 1u) pb &= ~(1u << 3);
        if (mask & 2u) pb &= ~(1u << 4);
        if (mask & 4u) pb &= ~(1u << 15);
        assert(kit_decode(4u, pb, 2048u, true).calls == mask);
    }
    /* Door servo: both pulses inside the usual 0.5-2.5 ms range of a 20 ms frame. */
    assert(kit_servo_compare(false) == KIT_SERVO_CLOSED_US && kit_servo_compare(true) == KIT_SERVO_OPEN_US);
    assert(KIT_SERVO_CLOSED_US >= 500u && KIT_SERVO_OPEN_US <= 2500u);
    assert(KIT_SERVO_CLOSED_US != KIT_SERVO_OPEN_US && KIT_SERVO_PERIOD_US == 20000u);
    puts("PASS kit contacts, ADC validity, PWM, direction, STBY inhibit, door servo pulses and HMI floor buttons");
}
