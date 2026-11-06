/* Display task only. PCF8574T at 0x27, P0 RS, P1 R/W, P2 E, P3 backlight. */
#include "board_port.h"
#include "main.h"
#include "FreeRTOS.h"
#include "task.h"

static bool ready;
#define LCD_ADDR 0x27u
#define LCD_BACKLIGHT 8u
#define LCD_ENABLE 4u

static void bus_init(void) {
    __HAL_RCC_GPIOB_CLK_ENABLE();
    __HAL_RCC_I2C1_CLK_ENABLE();
    __HAL_RCC_I2C1_FORCE_RESET();
    __HAL_RCC_I2C1_RELEASE_RESET();
    GPIO_InitTypeDef cfg = {.Pin = GPIO_PIN_6 | GPIO_PIN_7, .Mode = GPIO_MODE_AF_OD,
        .Alternate = GPIO_AF4_I2C1, .Speed = GPIO_SPEED_FREQ_HIGH};
    HAL_GPIO_Init(GPIOB, &cfg);
    uint32_t mhz = HAL_RCC_GetPCLK1Freq() / 1000000u;
    I2C1->CR2 = mhz;
    I2C1->CCR = mhz * 5u; /* standard mode, 100 kHz */
    I2C1->TRISE = mhz + 1u;
    I2C1->CR1 = I2C_CR1_PE;
}

static bool wait_flag(uint32_t flag, uint32_t start) {
    for (;;) {
        uint32_t status = I2C1->SR1;
        if ((status & (I2C_SR1_AF | I2C_SR1_ARLO | I2C_SR1_BERR)) ||
            HAL_GetTick() - start >= 5u) return false;
        if (status & flag) return true;
    }
}

static bool send_bytes(const uint8_t *data, unsigned count) {
    uint32_t start = HAL_GetTick();
    while (I2C1->SR2 & I2C_SR2_BUSY)
        if (HAL_GetTick() - start >= 5u) return false;
    I2C1->CR1 |= I2C_CR1_START;
    bool ok = wait_flag(I2C_SR1_SB, start);
    if (ok) {
        I2C1->DR = LCD_ADDR << 1;
        ok = wait_flag(I2C_SR1_ADDR, start);
        if (ok) (void)I2C1->SR2;
    }
    for (unsigned i = 0; ok && i < count; ++i) {
        ok = wait_flag(I2C_SR1_TXE, start);
        if (ok) I2C1->DR = data[i];
    }
    ok = ok && wait_flag(I2C_SR1_BTF, start);
    I2C1->CR1 |= I2C_CR1_STOP;
    return ok;
}

static bool nibble(uint8_t high_bits, bool rs) {
    uint8_t base = high_bits | LCD_BACKLIGHT | (rs ? 1u : 0u);
    uint8_t pulse[] = {base, base | LCD_ENABLE, base};
    return send_bytes(pulse, sizeof pulse);
}

static bool lcd_byte(uint8_t value, bool rs) {
    return nibble(value & 0xf0u, rs) && nibble((uint8_t)(value << 4), rs);
}

static bool lcd_init(void) {
    bus_init();
    vTaskDelay(pdMS_TO_TICKS(50));
    for (unsigned i = 0; i < 3; ++i) {
        if (!nibble(0x30, false)) return false;
        vTaskDelay(pdMS_TO_TICKS(6));
    }
    return nibble(0x20, false) && lcd_byte(0x28, false) &&
           lcd_byte(0x06, false) && lcd_byte(0x0c, false);
}

static bool row(uint8_t address, const char *text) {
    if (!lcd_byte(address, false)) return false;
    for (unsigned i = 0; i < 16; ++i)
        if (!lcd_byte((uint8_t)text[i], true)) return false;
    return true;
}

void board_lcd_write(const char *row0, const char *row1) {
    if (!ready && !lcd_init()) return;
    ready = row(0x80, row0) && row(0xc0, row1);
}
