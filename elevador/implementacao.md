<img src="docs/assets/ifsc-logo.png" alt="IFSC" width="30%">

# 3. Implementação em C e FreeRTOS

> Página 3 de 4 · [Sumário](README.md)

## Onde está cada parte

- **Entrada e regras de viagem.** O controlador compõe a leitura filtrada com a máquina de estados. A mudança de estado cancela uma pressão iniciada antes da falha ou da chegada. [Controlador](src/controller.c) · [Entradas](src/inputs.c) · [Estados](src/elevator.c)
- **Comando do motor.** A rampa trabalha em milésimos do comando. Antes de inverter, o comando cai a zero e aguarda o intervalo configurado. Parada por falha zera a saída imediatamente. [Motor](src/motor.c) · [Parâmetros](include/elevator_config.h)
- **STM32 e kit.** O port amostra ADC1 e GPIO, captura abertura dos contatos de segurança por interrupção e atualiza TIM1. A tarefa de controle alimenta o watchdog. A tarefa de display envia duas linhas pelo I²C1 e tenta reinicializar o LCD após falha de comunicação. [Port do kit](ports/stm32f411/kit/board_kit.c) · [LCD](ports/stm32f411/kit/lcd_1602.c)
- **Diagnóstico USB.** O registro traz estado, falha, último andar, destino, PWM e entradas. Eventos perdidos são contados quando USB ou fila estão ocupadas. [Tarefas](ports/stm32f411/elevator_rtos.c)

## Escolher a imagem

Na raiz do projeto, com Python 3 e o compilador ARM disponível:

```sh
python3 scripts/build_f411.py
python3 scripts/build_f411.py --profile kit-bancada
```

A primeira imagem preserva o port inativo da etapa 1. A segunda configura os periféricos do kit e mantém STBY baixo. Os artefatos têm nomes e diretórios diferentes. O perfil de operação requer um registro explícito do hardware e parâmetros de comando dimensionados. [Dependências, saídas e perfis](docs/INTEGRACAO.md)

[← Retroceder](projeto.md) · [Sumário](README.md) · [Avançar →](testes.md)
