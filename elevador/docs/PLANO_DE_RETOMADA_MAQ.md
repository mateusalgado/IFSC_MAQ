# Mini elevador didático de três paradas

Plano de retomada para Máquinas e Acionamentos · 04/11/2026

## Onde trabalhar

Abra a pasta `MAQ/elevador` como raiz do projeto. O código ativo está em
[`src/`](../src), [`include/`](../include), [`ports/stm32f411/`](../ports/stm32f411)
e [`tests/`](../tests). A pasta `arquivo/publicacao-mic2/` é histórica.
Trate a base de HAL, FreeRTOS e USB em `../../MIC2/labRTOS/ex_Barry_USB_STM32F411CE`
como dependência de leitura. A pasta local do elevador ainda não é um repositório
Git. Antes de publicar futuramente, conferir o destino de MAQ e o conteúdo a incluir.

Atualização de 06/11/2026 — o destino escolhido é
[IFSC_MAQ](https://github.com/mateusalgado/IFSC_MAQ). O projeto é publicado sob
`elevador/` e a cópia histórica fornece a base de leitura para a compilação
em outros computadores. Consulte o [roteiro de montagem e gravação](INSTRUCOES_COLEGA.md).

## Objetivo da maquete

Mover uma cabine entre térreo, primeiro e segundo andar. O operador seleciona
um único destino no joystick e confirma pelo botão. O LCD mostra o último
andar confirmado, o destino e “entre andares” durante o percurso. A partida
exige referência inicial. Parada ou falha tem prioridade sobre pedidos de viagem.

Para MAQ, a pergunta experimental é como a carga e o sentido da viagem afetam
a corrente do motor, o tempo de percurso e a distância que a cabine percorre
após detectar o andar. O percentual de PWM representa o comando aplicado.

## 1. Primeira sessão do agente — reproduzir a base

1. Ler o [README](../README.md), a [arquitetura](ARQUITETURA.md), a
   [integração](INTEGRACAO.md) e o [registro anterior](VALIDACAO.md).
2. Conferir código e testes de referência, viagens nos dois sentidos, parada,
   timeout, sensores incoerentes, reconhecimento de falhas e reversão.
   Identificar a única tarefa autorizada a comandar a saída do motor.
3. Executar, da raiz do elevador, em Linux/WSL com GCC e Make:

   ~~~sh
   make test
   make sanitize
   ~~~

4. Recompilar o port inativo com `python3 scripts/build_f411.py`, usando
   `--cc` e `--base` conforme o guia de integração se necessário. Confirmar
   a geração de `build/f411/elevador-unconfigured.elf`.
5. Comparar com o registro de 27/10/2026, que informa 24 grupos aprovados
   e compilação ARM bem-sucedida. Registrar a nova execução separadamente,
   com comandos, resultado e divergências.

**Entrega da sessão.** Um registro reproduzível da base e uma lista curta das
medidas e peças necessárias para fechar o acionamento. Avançar no software e
na preparação dos ensaios enquanto a estrutura 3D está em definição.

## 2. Fechar a mecânica e dimensionar o acionamento

- Conferir placa, motor disponível, redução, transmissão, curso entre andares,
  massa da cabine vazia, carga prevista e método de retenção da cabine.
- Conferir o encaixe do motor e a transmissão do modelo 3D. A referência
  original previa NEMA 17, enquanto a hipótese de MAQ é motor CC com redução.
  Registrar qual conjunto será construído antes de definir o driver.
- Para tambor, usar massa e raio efetivo para estimar o torque no eixo de
  saída. Se for escolhida outra transmissão, usar sua geometria. Documentar
  redução, perdas, margem de partida e os dados de placa ou datasheet.
- Confrontar tensão e correntes nominal, de partida e de bloqueio com limites
  do driver, da fonte e das proteções. Consultar
  `../PWM/DriverDeMotor.pdsprj` como referência para o circuito de potência.
- Fechar [hardware e pinagem](HARDWARE.md) após escolher os componentes e
  verificar níveis lógicos e conflitos com USB, SWD, ADC, I²C e timer PWM.

**Critério para avançar.** Conjunto mecânico, motor, driver, alimentação,
sensores, parada e retenção identificados, com valores e fontes registrados.

## 3. Integrar a eletrônica por etapas

1. Com a potência do motor desligada, validar joystick, LCD, três sensores de
   andar, dois fins de curso, botão de parada e diagnóstico USB.
2. Implementar o port físico a partir de `board_port.h` e manter o port
   inativo disponível para compilação. Conferir PWM e sentido no instrumento
   antes de conectar o motor.
3. Ensaiar o motor desacoplado. Verificar subida gradual do comando, teto de
   PWM, retorno a zero antes de inverter, intervalo de reversão, corte por
   falha e ausência de partida automática após reset.

**Critério para acoplar.** Sentidos de giro, entradas de parada, limites e
estado das saídas em falha validados e registrados em bancada.

## 4. Ensaiar a cabine e fechar o relatório

Seguir o [roteiro de bancada](BANCADA.md). Começar com cabine vazia,
retenção verificada e referência em baixa velocidade. Validar primeiro um
trecho entre andares vizinhos, depois as viagens nos dois sentidos e a
parada nos três andares. Confirmar que a recuperação de falha exige
reconhecimento e nova referência quando a posição foi perdida.

Comparar subida e descida no mesmo trecho, primeiro com cabine vazia e depois
com uma carga conhecida dentro do limite dimensionado. Registrar massa,
sentido, comando PWM, tensão, corrente, tempo e deslocamento após o sensor.
Incluir instrumentos, repetições e fotos no [relatório](RELATORIO.md).
A medição inicial pode ser feita com instrumentos de bancada. Encoder,
medição embarcada de corrente e controle PI ficam para uma etapa posterior.
