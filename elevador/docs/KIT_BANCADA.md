# Montar e testar a bancada de sinais

Esta montagem permite percorrer os três andares à mão, acionando os sensores enquanto o LCD e o diagnóstico USB mostram a resposta do firmware. Use a imagem **kit-bancada**. A imagem **unconfigured** da etapa 1 devolve entrada inválida por projeto.

Para montar pela primeira vez em outro computador, siga o [passo a passo do colega](INSTRUCOES_COLEGA.md). O repositório inclui um [HEX pronto para gravar](../firmware/kit-bancada/README.md).

## 1. Separar e conferir as peças

- Placa tipo Black Pill com **STM32F411CEU6**, cristal externo de **25 MHz**, USB de dados e acesso a SWD. Confira a marcação do chip, o cristal e os nomes dos pinos no esquema da sua placa. Use ST-LINK para gravar e um cabo USB de dados para o diagnóstico. O perfil usa o clock do projeto MAQ. [Hardware](HARDWARE.md)
- Um joystick analógico tipo KY-023 com botão, três microchaves com contato normalmente aberto (NA) para representar os andares, duas microchaves com contato normalmente fechado (NF) para limites e um botão de parada com contato NF. Nos testes manuais, cada chave de andar também pode ser um botão NA. O corte da potência na futura montagem requer contato ou dispositivo independente do sinal lido pelo MCU. [Roteiro](BANCADA.md)
- Um LCD 1602 compatível com HD44780, backpack **PCF8574T**, conversor de nível I²C bidirecional 3,3/5 V e pull-ups em cada lado. O perfil assume endereço de 7 bits **0x27**, P0=RS, P1=RW, P2=E, P3=luz ativa alta e P4–P7=D4–D7. Confira marcação, pontes de endereço e trilhas. Outros backpacks exigem ajustar o driver. [NXP, PCF8574](https://www.nxp.com/docs/en/data-sheet/PCF8574_PCF8574A.pdf) · [Mapeamentos de backpacks](https://github.com/enjoyneering/LiquidCrystal_I2C)
- Para o ensaio de sinais da ponte, basta um osciloscópio ou analisador lógico com entradas compatíveis com 3,3 V. A referência futura é o canal A do TB6612FNG e um motor CC TT. Deixe motor e alimentação VM **desconectados** durante todo este roteiro. A lógica STBY baixa mantém as saídas da ponte desabilitadas. [Tabela de operação da Toshiba](https://toshiba.semicon-storage.com/info/datasheet_en_20141001.pdf?did=10660)

## 2. Fazer as ligações com a alimentação desligada

[Abrir o diagrama pino a pino em tamanho completo](DIAGRAMA_KIT_BANCADA.svg)

![Ligações da protoboard para o percurso manual dos três andares, com joystick, seis chaves, LCD e pontos de prova.](DIAGRAMA_KIT_BANCADA.svg)

Na protoboard, deixe os dois lados da placa em grupos de furos isolados pela canaleta central ou use jumpers nos headers. Reserve trilhos distintos para 3,3 V, 5 V e GND. Identifique COM, NA e NF por continuidade com as chaves em repouso. Nos botões tácteis de quatro pernas usados para os andares, escolha dois terminais que só apresentem continuidade quando pressionados.

Os nomes são os pinos do **STM32**, independentemente da posição nos conectores. Use o GND da lógica como referência. Alimente a placa por uma única entrada apropriada ao seu modelo. Para SWD use SWDIO/PA13, SWCLK/PA14, GND e a referência de tensão do programador conforme seu modelo. Preserve PA11/PA12 para o USB.

| Função | Pino do STM32 | Ligação e leitura esperada |
|---|---|---|
| Joystick | PA0 (VRy ou VRx), PA2 (SW) | Alimente o joystick a **3,3 V**. Escolha o eixo cuja leitura cresce em “subir”. SW fecha para GND. Eixo livre perto de 2048 em 12 bits. |
| Térreo, 1º e 2º | PA3, PA4, PA5 | Contatos NA individuais para GND. Em repouso abertos. Uma chave fechada produz máscara USB 1, 2 ou 4. |
| Limites inferior e superior | PB0, PB1 | Cada contato NF entre entrada e GND. Em repouso fechado. Ao abrir, o limite acusa 1. |
| Parada | PB10 | Contato NF de diagnóstico para GND. Ao abrir, acusa 1. Limites e parada usam pull-up interno. |
| LCD | PB6=SCL, PB7=SDA | Lado de 3,3 V do conversor voltado ao STM32. Lado de 5 V ao backpack alimentado a 5 V. GND comum. Conferir as tensões de repouso antes de ligar ao MCU. |
| Servo da porta | PB8 | Sinal de 50 Hz para o fio de comando do servo. Pulso de 1,0 ms com a porta fechada e 2,0 ms com a porta aberta. Para só medir, ligue o instrumento em PB8 e GND. Para ligar um servo, alimente-o em 5 V por fonte própria com GND comum. |
| Indicadores | PC13, PB5 | LED da placa ativo baixo indica PARADO, se a variante tiver esse LED. PB5 sobe em FALHA. Buzzer ativo opcional via estágio de acionamento adequado ao módulo. |
| Sinais para instrumento | PA8=PWMA, PB12=AIN1, PB13=AIN2, PB14=STBY | Comece com a ponte desconectada. Referência do instrumento em GND. STBY deve permanecer baixo em todas as etapas. |

Para conferir a interface lógica com um módulo TB6612FNG identificado, use VCC lógico em 3,3 V e GND comum. Confira que STBY não tem jumper para VCC e preveja pull-down externo, inclusive durante reset. Mantenha VM e A01/A02 sem ligação de potência. O motor TT, o tambor, a retenção e a fonte só entram depois do dimensionamento da [ficha](FICHA_LEVANTAMENTO_ETAPA_2.md).

## 3. Carregar a aplicação de bancada

1. Use o arquivo local `build/f411/kit-bancada/elevador-kit-bancada.elf`. Para recompilar a partir da raiz, execute `python scripts/build_f411.py --profile kit-bancada`. Caso o compilador esteja fora do PATH, use o argumento `--cc` conforme o [guia de integração](INTEGRACAO.md).
2. Com VM e motor desconectados, conecte o ST-LINK e confira em STM32CubeProgrammer que o dispositivo detectado corresponde ao F411 da montagem. Abra o ELF de bancada, programe por SWD, verifique a gravação e reinicie a placa.
3. Conecte o USB de dados do STM32 e abra a porta serial CDC correspondente em um terminal. A aplicação transmite mudanças e um resumo periódico. Os campos `adc`, `btn`, `floors`, `low`, `high`, `stop` e `valid` permitem conferir cada entrada. O campo `pwm` é o comando lógico em percentual.

## 4. Primeiro percurso sem motor

| Ação manual | Resultado esperado |
|---|---|
| Soltar o joystick, fechar os três contatos NF e iniciar com as chaves de andar livres | INICIO; PWM zero, STBY baixo, `valid=1`, limites e parada em zero. Se iniciou com um NF aberto, corrigir e reconhecer a falha. |
| Manter a chave do térreo fechada. Segurar SW por mais de 1 s e soltar | A referência encontra o térreo. Após confirmação, PARADO no andar 0 e a porta abre: pulso de 2,0 ms em PB8 e `door=1` no USB. |
| Mover o joystick para cima e voltar ao centro duas vezes. Dar um clique curto | Destino 2. A porta fecha (FECHANDO, pulso de 1,0 ms) e, 0,8 s depois, aparece SUBIDA. Manter a chave do térreo fechada enquanto FECHANDO e abri-la em menos de 2 s depois de SUBIDA. No instrumento, trem PWM em PA8, PB12 alto durante comando de subida e PB14 baixo. |
| Acionar e liberar a chave do 1º por cerca de 0,2 s e fechar a do 2º antes do timeout de 20 s | O 1º é registrado como passagem. No 2º, PWM zero. Manter a chave final fechada por mais de 300 ms e enquanto PARADO. |
| Selecionar o térreo com duas excursões para baixo, confirmar e repetir a sequência inversa | DESCIDA com PB13 alto durante comando, passagem pelo 1º e parada no térreo. |
| Em nova viagem, abrir o contato de parada e depois fechá-lo | FALHA de parada e PWM zero. Uma pressão longa reconhece e volta a INICIO. Outra solicita referência. |
| Repetir abrindo cada limite e depois fechando duas chaves de andar simultaneamente | FALHA de fim de curso ou de sensor, respectivamente. Recuperar entre casos. STBY continua baixo. |

**Registro da primeira montagem.** Data ____ · placa/cristal ____ · LCD/endereço ____ · fotos das ligações ____ · arquivo de log USB ____ · captura PA8/PB12/PB13/PB14 ____ · resultado por ação e divergências ____.

Se USB funcionar e o LCD ficar vazio, confira contraste, alimentação, endereço e mapeamento. Se aparecer falha de limite ou parada logo ao ligar, confira o campo USB correspondente e a continuidade do contato NF. Antes de ensaiar potência, feche transmissão, retenção, corrente, fonte e corte independente na [ficha da etapa 2](FICHA_LEVANTAMENTO_ETAPA_2.md). Este firmware mantém STBY baixo inclusive durante viagens simuladas.
