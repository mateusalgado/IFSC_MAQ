<img src="docs/assets/ifsc-logo.png" alt="IFSC" width="30%">

# 2. Projeto do sistema

> Página 2 de 4 · [Sumário](README.md)

## Caminho de um comando

1. O joystick e os contatos entram no controlador como uma amostra. O filtro normaliza a seleção, confirma os sensores de andar e separa clique de pressão longa.
2. A máquina de estados decide referência, subida, descida, chegada ou falha. O módulo do motor aplica teto, rampa e espera para reversão. O diagrama reúne os sete estados e suas transições. [Arquitetura](docs/ARQUITETURA.md)
3. A tarefa **Control** envia o comando de motor. **Display** e **USBLog** recebem cópias do estado por filas, cada uma com seu próprio periférico. A parada e os limites podem inibir os sinais pelo tratamento de interrupção.

## Duas montagens a distinguir

**Bancada de sinais.** O STM32 recebe o joystick em 3,3 V, três contatos de andar normalmente abertos e três contatos normalmente fechados para os dois limites e a parada. A tela é um LCD 1602 I²C. O usuário simula a posição da cabine à mão. A direção e o PWM podem ser medidos com a ponte desabilitada. [Pinagem e ligações](docs/KIT_BANCADA.md)

**Protótipo mecânico.** A referência de estrutura cita NEMA 17. Para MAQ, o candidato inicial é um motor CC com redutor TT e ponte TB6612FNG. O encaixe, a transmissão, a sustentação sem energia e a capacidade de corrente precisam fechar para a mesma cabine. A geometria usada no cálculo deve corresponder à transmissão construída. [Ficha de levantamento](docs/FICHA_LEVANTAMENTO_ETAPA_2.md)

[← Retroceder](analise.md) · [Sumário](README.md) · [Avançar →](implementacao.md)
