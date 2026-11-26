<img src="docs/assets/ifsc-logo.png" alt="IFSC" width="30%">

# 2. Projeto do sistema

> Página 2 de 4 · [Sumário](README.md)

## Caminho de um comando

1. O joystick, os botões de andar da IHM e os contatos entram no controlador como uma amostra. O filtro normaliza a seleção, confirma os sensores de andar e separa clique de pressão longa.
2. A máquina de estados decide referência, fechamento da porta, subida, descida, chegada ou falha. O módulo do motor aplica teto, rampa e espera para reversão. O diagrama reúne os oito estados e suas transições. [Arquitetura](docs/ARQUITETURA.md)
3. A tarefa **Control** envia o comando do motor da cabine e a posição do servo da porta. **Display** e **USBLog** recebem cópias do estado por filas, cada uma com seu próprio periférico. A parada e os limites podem inibir os sinais pelo tratamento de interrupção.

## Duas montagens a distinguir

**Bancada de sinais.** O STM32 recebe o joystick em 3,3 V, três contatos de andar normalmente abertos e três contatos normalmente fechados para os dois limites e a parada. A tela é um LCD 1602 I²C. O usuário simula a posição da cabine à mão. A direção e o PWM podem ser medidos com a ponte desabilitada, e o pulso do servo da porta pode ser medido em PB8. [Pinagem e ligações](docs/KIT_BANCADA.md)

**Protótipo mecânico.** Há dois modelos para impressão 3D, um com [varões de 8 mm](mecanica/README.md) e outro com [estrutura toda impressa](mecanica-impressa/README.md). Ambos usam um motor CC com redutor TT e ponte TB6612FNG para a cabine, e um servo tipo SG90 para a porta. A eletrônica e o painel de comando ficam na [IHM impressa](ihm/README.md), ao lado da torre. O encaixe, a transmissão, a sustentação sem energia e a capacidade de corrente precisam fechar para a mesma cabine. A geometria usada no cálculo deve corresponder à transmissão construída. [Ficha de levantamento](docs/FICHA_LEVANTAMENTO_ETAPA_2.md)

[← Retroceder](analise.md) · [Sumário](README.md) · [Avançar →](implementacao.md)
