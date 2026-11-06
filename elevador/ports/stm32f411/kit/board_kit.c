/* Bench image never enables STBY. Power builds require a separate hardware record. */
#include "board_port.h"
#include "elevator_config.h"
#include "main.h"
#include "kit_signals.h"

#define DIRECTION_PINS (GPIO_PIN_12 | GPIO_PIN_13)
#define STANDBY GPIO_PIN_14
#define SAFETY_PINS (GPIO_PIN_0 | GPIO_PIN_1 | GPIO_PIN_10)
static uint32_t sample_started;
static volatile uint32_t safety_edges;

static void pins(GPIO_TypeDef *port, uint32_t mask, uint32_t mode, uint32_t pull) {
    GPIO_InitTypeDef cfg = {.Pin = mask, .Mode = mode, .Pull = pull};
    HAL_GPIO_Init(port, &cfg);
}

void board_safe_init(void) {
    __HAL_RCC_GPIOB_CLK_ENABLE();
    HAL_GPIO_WritePin(GPIOB, DIRECTION_PINS | STANDBY | GPIO_PIN_5, GPIO_PIN_RESET);
    pins(GPIOB, DIRECTION_PINS | STANDBY | GPIO_PIN_5, GPIO_MODE_OUTPUT_PP, GPIO_NOPULL);
}

void board_peripherals_init(void) {
    __HAL_RCC_GPIOA_CLK_ENABLE();
    __HAL_RCC_GPIOC_CLK_ENABLE();
    HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);
    pins(GPIOC, GPIO_PIN_13, GPIO_MODE_OUTPUT_PP, GPIO_NOPULL);
    pins(GPIOA, GPIO_PIN_0, GPIO_MODE_ANALOG, GPIO_NOPULL);
    pins(GPIOA, GPIO_PIN_2 | GPIO_PIN_3 | GPIO_PIN_4 | GPIO_PIN_5, GPIO_MODE_INPUT, GPIO_PULLUP);
    pins(GPIOB, SAFETY_PINS, GPIO_MODE_IT_RISING, GPIO_PULLUP);
    HAL_NVIC_SetPriority(EXTI0_IRQn, 4, 0);
    HAL_NVIC_SetPriority(EXTI1_IRQn, 4, 0);
    HAL_NVIC_SetPriority(EXTI15_10_IRQn, 4, 0);
    HAL_NVIC_EnableIRQ(EXTI0_IRQn);
    HAL_NVIC_EnableIRQ(EXTI1_IRQn);
    HAL_NVIC_EnableIRQ(EXTI15_10_IRQn);

    __HAL_RCC_TIM1_CLK_ENABLE();
    TIM1->ARR = KIT_PWM_COUNTS - 1u;
    TIM1->CCR1 = 0;
    TIM1->CCMR1 = TIM_CCMR1_OC1M_2 | TIM_CCMR1_OC1M_1; /* PWM mode 1 */
    TIM1->EGR = TIM_EGR_UG;
    TIM1->CCER = TIM_CCER_CC1E;
    TIM1->BDTR = TIM_BDTR_MOE;
    TIM1->CR1 = TIM_CR1_CEN;
    GPIO_InitTypeDef pwm = {.Pin = GPIO_PIN_8, .Mode = GPIO_MODE_AF_PP, .Alternate = GPIO_AF1_TIM1};
    HAL_GPIO_Init(GPIOA, &pwm);

    __HAL_RCC_ADC1_CLK_ENABLE();
    ADC1_COMMON->CCR = ADC_CCR_ADCPRE_0; /* APB2 / 4 = 24 MHz */
    ADC1->SMPR2 = ADC_SMPR2_SMP0; /* channel 0, 480 cycles */
    ADC1->CR2 = ADC_CR2_ADON;
    HAL_Delay(1);
    ADC1->CR2 |= ADC_CR2_SWSTART;
    sample_started = HAL_GetTick();

    /* Independent reset if Control stops. Nominal 1 s at LSI = 32 kHz. */
    IWDG->KR = 0xCCCCu;
    IWDG->KR = 0x5555u;
    IWDG->PR = 3u;
    IWDG->RLR = 999u;
    uint32_t start = HAL_GetTick();
    while (IWDG->SR) {
        if (HAL_GetTick() - start > 50u) Error_Handler();
    }
    IWDG->KR = 0xAAAAu;
}

RawInputs board_read_inputs(void) {
    uint32_t mask = __get_PRIMASK();
    __disable_irq();
    uint32_t pa = GPIOA->IDR, pb = GPIOB->IDR | safety_edges;
    safety_edges = 0;
    __set_PRIMASK(mask);
    uint32_t status = ADC1->SR, now = HAL_GetTick();
    bool fresh = (status & ADC_SR_EOC) && !(status & ADC_SR_OVR) &&
                 now - sample_started <= EL_MAX_GAP_MS;
    RawInputs raw = kit_decode(pa, pb, (uint16_t)ADC1->DR, fresh);
    ADC1->SR = 0;
    ADC1->CR2 |= ADC_CR2_SWSTART;
    sample_started = now;
    return raw;
}

void board_fault_disable(void) {
    GPIOB->BSRR = (uint32_t)(STANDBY | DIRECTION_PINS) << 16;
    if (RCC->APB2ENR & RCC_APB2ENR_TIM1EN) TIM1->CCR1 = 0;
}

static void safety_edge(uint32_t pin) {
    if (EXTI->PR & pin) {
        EXTI->PR = pin;
        safety_edges |= pin;
        board_fault_disable();
    }
}
void EXTI0_IRQHandler(void) { safety_edge(GPIO_PIN_0); }
void EXTI1_IRQHandler(void) { safety_edge(GPIO_PIN_1); }
void EXTI15_10_IRQHandler(void) { safety_edge(GPIO_PIN_10); }

void board_motor_write(MotorOutput output) {
    KitSignals signals = kit_signals(output);
    uint32_t mask = __get_PRIMASK();
    __disable_irq();
    if (safety_edges || ((GPIOB->IDR | EXTI->PR) & SAFETY_PINS)) {
        safety_edges |= (GPIOB->IDR | EXTI->PR) & SAFETY_PINS;
        board_fault_disable();
        __set_PRIMASK(mask);
        return;
    }
    if ((GPIOB->ODR & DIRECTION_PINS) != (signals.port_b_bsrr & DIRECTION_PINS)) {
        GPIOB->BSRR = (uint32_t)STANDBY << 16;
        TIM1->CCR1 = 0;
    }
#ifdef KIT_POWER_COMMISSIONED
    /* During motion keep STBY stable across updates in the same direction.
       Enable last, with direction and duty established, and only on a fresh
       read of the normally closed stop/limit chain. */
    if (signals.compare) {
        GPIOB->BSRR = signals.port_b_bsrr & ~((uint32_t)STANDBY << 16);
        TIM1->CCR1 = signals.compare;
        GPIOB->BSRR = STANDBY;
        __set_PRIMASK(mask);
        return;
    }
#endif
    GPIOB->BSRR = signals.port_b_bsrr;
    TIM1->CCR1 = signals.compare;
    __set_PRIMASK(mask);
}

void board_indicators(ElState state) {
    HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, state == EL_IDLE ? GPIO_PIN_RESET : GPIO_PIN_SET);
    HAL_GPIO_WritePin(GPIOB, GPIO_PIN_5, state == EL_FAULT ? GPIO_PIN_SET : GPIO_PIN_RESET);
}

void board_watchdog_refresh(void) { IWDG->KR = 0xAAAAu; }

static void halt_on_fault(void) {
    __disable_irq();
    board_fault_disable();
    for (;;) { } /* IWDG resets the board once started. */
}

void NMI_Handler(void) { halt_on_fault(); }
void HardFault_Handler(void) { halt_on_fault(); }
void MemManage_Handler(void) { halt_on_fault(); }
void BusFault_Handler(void) { halt_on_fault(); }
void UsageFault_Handler(void) { halt_on_fault(); }
