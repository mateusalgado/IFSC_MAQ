#ifndef EL_INPUTS_H
#define EL_INPUTS_H
#include <stdbool.h>
#include <stdint.h>
typedef struct {
    uint8_t floors; /* active-high normalized bits 0..2 */
    uint8_t calls;  /* HMI floor buttons T, 1, 2: active-high bits 0..2 */
    bool lower_limit, upper_limit, stop, button, valid;
    uint16_t joystick;
} RawInputs;
typedef struct { bool stable, candidate; uint32_t since; } Debounce;
typedef struct {
    uint8_t floors;
    bool lower_limit, upper_limit, stop, valid, coherent, ready;
} Sensors;
/* EV_CALL0..2: the HMI button of floor 0..2 was pressed. */
typedef enum { EV_NONE, EV_UP, EV_DOWN, EV_CONFIRM, EV_LONG,
    EV_CALL0, EV_CALL1, EV_CALL2, EV_COUNT } InputEvent;
typedef struct {
    Debounce floors[3], calls[3], button;
    uint32_t boot_ms, pressed_ms;
    int32_t filtered;
    uint8_t pending_calls; /* debounced presses not yet delivered */
    bool centered, released, pressing;
} Inputs;
void inputs_init(Inputs *i, uint32_t now);
InputEvent inputs_step(Inputs *i, const RawInputs *r, uint32_t now, Sensors *s);
#endif
