# Compilar e integrar no STM32CubeIDE

## Perfis disponíveis desde 04/11/2026

- **unconfigured** é o padrão. Gera `build/f411/elevador-unconfigured.elf` usando `board_unconfigured.c`.
- **kit-bancada** substitui esse arquivo pelos fontes em `ports/stm32f411/kit/`. Gera `build/f411/kit-bancada/elevador-kit-bancada.elf` com ADC, GPIO, LCD, watchdog e sinais PWM/direção. O firmware mantém STBY baixo. Use o [roteiro de montagem](KIT_BANCADA.md).
- **kit-operacao** é reservado ao TB6612FNG com a placa, as ligações e os sinais do kit já conferidos. É o único perfil com código para elevar STBY. As duas imagens entregues são as anteriores.

Para reproduzir a imagem de bancada neste computador, na raiz do elevador:

```powershell
$cc = (Get-ChildItem C:\ST -Recurse -Filter arm-none-eabi-gcc.exe | Select-Object -First 1).FullName
$py = "$env:USERPROFILE\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $py scripts/build_f411.py --cc $cc --profile kit-bancada
```

**Após fechar o hardware.** O comando de compilação do perfil de potência é `python scripts/build_f411.py --profile kit-operacao --hardware <arquivo.json>`, com o mesmo `--cc` se necessário. O arquivo JSON deve registrar o conjunto efetivamente conferido. A ficha preenchida e o registro do ensaio dão significado a esses campos. A compilação só verifica a presença e os intervalos dos parâmetros.

| Chaves do JSON | Conteúdo exigido |
|---|---|
| `perfil_verificado` | Identificação exata `F411CEU6-25MHz-TB6612FNG-20kHz` após conferir placa, frequência e interface em bancada. |
| `motor`, `transmissao`, `fonte`, `retencao`, `corte_independente` | Texto identificando cada peça ou montagem real, com referência à ficha. |
| `registro_bancada` | Referência ao ensaio de sinais e aos limites adotados para iniciar com o motor desacoplado. |
| `referencia_pct`, `viagem_pct`, `teto_pct` | Percentuais inteiros de 1 a 100. Referência e viagem limitadas pelo teto dimensionado para o conjunto. |
| `rampa_pct_s`, `reversao_ms` | Rampa em pontos percentuais por segundo (inteiro de 1 a 100) e espera mínima em zero antes de inverter (inteiro de 1 a 60000 ms). |

Esse perfil grava sua imagem exclusivamente em `build/f411/kit-operacao/`. A liberação para ensaio com potência exige dimensionamento, retenção, proteção de corrente e corte independente verificados. O primeiro ensaio é com motor fixado e desacoplado. [Sequência de bancada](BANCADA.md)

## Dependências e alvo

Desde a publicação em 06/11/2026, o script usa primeiro a cópia de leitura em
`arquivo/publicacao-mic2/ex_Barry_USB_STM32F411CE`, que acompanha o download.
O conteúdo de suas 159 fontes e arquivos de projeto foi comparado com a base
local de MIC2, com igualdade após normalizar fins de linha. `--base` continua
disponível para escolher explicitamente outra cópia. O script gera ELF e HEX.
O [roteiro do colega](INSTRUCOES_COLEGA.md) explica a instalação em outro computador
e o uso do [HEX de bancada distribuído](../firmware/kit-bancada/README.md).

Núcleo: C11 e biblioteca C. Host: GCC/Make, sem HAL. ARM: GNU Arm Embedded,
Python 3.9+, HAL STM32F4/CMSIS/USB e FreeRTOS 10.3.1 presentes na base Barry.
O script não baixa dependências e não modifica nem grava o laboratório.
Use a revisão da base registrada em [VALIDACAO.md](VALIDACAO.md).

## Build ARM reproduzível

Da pasta `elevador`, com o compilador no PATH:

```sh
python3 scripts/build_f411.py
```

Se as ferramentas estiverem fora do PATH, passar os caminhos explicitamente:

```powershell
python scripts/build_f411.py --cc 'C:\caminho\tools\bin\arm-none-eabi-gcc.exe' --base '..\..\MIC2\labRTOS\ex_Barry_USB_STM32F411CE'
```

Após a transferência para MAQ, a dependência local continua em MIC2, no caminho
acima. Na estrutura histórica do GitHub, `--base` era `..\ex_Barry_USB_STM32F411CE`.
O script reconhece o layout atual e os anteriores se o argumento for omitido. Saída:
`build/f411/elevador-unconfigured.elf` e mapa de memória. Não é imagem autorizada
para movimentar a maquete: o port físico é deliberadamente inativo.

As fontes de laboratório usadas incluem startup F411, linker F411, timebase
TIM4, interrupções, sistema, syscalls, HAL, FreeRTOS e USB. Não são incluídos
`main.c`, `lab_examples.c`, `main1_1_4_ex1.c` nem `freertos.c` do laboratório.
As tarefas e o callback de memória idle desta entrega substituem os do exemplo.
Manter avisos de fontes externas visíveis; código novo é compilado com `-Werror`.

## Projeto no CubeIDE

1. Fazer uma cópia de trabalho do projeto Barry com outro nome, fora do original.
   Importar como projeto existente e confirmar STM32F411CEU6, Cortex-M4F,
   `STM32F411xE`, `USE_HAL_DRIVER`, hard-float e linker `STM32F411CEUX_FLASH.ld`.
2. Excluir do build o `main.c` original, `main1_1_4_ex1.c`, `lab_examples.c`
   e `freertos.c`. Garantir somente um `main`, um conjunto de hooks e uma
   definição da tarefa idle. Outros exemplos não devem iniciar tarefas.
3. Para o perfil inativo, adicionar fontes de `src/` e apenas os arquivos diretamente em `ports/stm32f411/`. Excluir a subpasta `kit/` desse build para evitar duas implementações de placa. Para o kit, usar o script acima, que seleciona também os handlers de falha correspondentes. Adicionar `include/` e
   `ports/stm32f411/` aos includes. **Usar uma única configuração FreeRTOS**:
   substituir a cópia do `Core/Inc/FreeRTOSConfig.h` na cópia do projeto pela
   configuração desta entrega; não deixar duas versões concorrendo.
4. Preservar startup, linker, USB, MSP, timebase e interrupções do F411. O `main`
   desta entrega inicializa HAL/clock, cria tarefas e chama `vTaskStartScheduler`.
   USB inicia dentro da tarefa `USBLog`, após o scheduler.
5. Compilar o port inativo. Verificar mapa de memória, ausência de símbolos
   duplicados e presença dos hooks. Não esperar LCD, ADC ou motor funcionais.
6. Quando hardware estiver definido, gerar/configurar ADC, GPIO, I²C e TIM1 na
   cópia do `.ioc`, revisar alterações e substituir `board_unconfigured.c`
   por implementação concreta de `board_port.h`.
7. A regeneração CubeMX não deve restaurar tarefas de laboratório, segundo
   `main` ou configurações de F103. Revisar o diff e repetir testes/build.

Não foi gerado `.ioc` com periféricos fictícios nem validada a importação pela
interface gráfica do CubeIDE. O build reproduzível prova compilação/ligação ARM
contra as dependências reais do laboratório, e não a configuração física futura.

## Contratos do port e verificações na placa

A lista abaixo descreve os requisitos originais. No kit, ADC1 faz uma conversão por ciclo, a leitura seguinte verifica conclusão e idade, e a aplicação usa contatos secos de polaridades conhecidas. Aberturas de parada e limites geram EXTI e ficam registradas até a leitura por Control. O LCD usa transações limitadas por tempo na tarefa Display. O perfil de bancada mantém a habilitação baixa mesmo quando os pontos de teste apresentam comando. O funcionamento real de cada periférico e do corte externo deve ser verificado na montagem.

- `board_safe_init`: logo após HAL_Init e antes da configuração de clock/RTOS,
  aplicar níveis de inibição seguros. Pull-down/up externos devem garantir
  inibição durante reset, boot, programação e MCU desconectado.
- `board_read_inputs`: leitura limitada e não bloqueante de GPIO + amostra ADC
  coerente, preferencialmente DMA. Definir validade e idade máxima da amostra;
  ADC antigo, DMA com erro ou amostra incompleta devem produzir `valid=false`.
- `board_motor_write`: única tarefa proprietária. Comutar direção somente com
  PWM/enable inativos e cumprir a tabela-verdade da ponte. Diferenciar parada
  normal, reversão e falha. Medir os sinais com analisador antes de ligar o motor.
- `board_lcd_write`: executar apenas na tarefa Display. Timeout I²C limitado,
  preferir envio incremental/IT/DMA. Falha no display não pode segurar o controle.
- `board_indicators`: LED conforme estado e buzzer de falha, sem atrasos.
- `board_fault_disable`: corte imediato para assert/panic. Acrescentar chamada
  nos handlers HardFault, MemManage, BusFault e UsageFault da cópia do projeto.
  Os handlers originais do laboratório apenas ficam em laço; isso permanece
  pendente até o port físico.
- `board_watchdog_refresh`: configurar IWDG independente e alimentá-lo somente
  depois de um ciclo de controle válido. Avaliar falta de execução, não apenas
  repetição de tick. Não alimentar dentro do idle hook ou da ISR de tick.

Configuração local habilita detecção de stack overflow e malloc failed, ambas
indo a panic. Pilhas e heap ainda exigem medição real. Configurar prioridades
NVIC: APIs RTOS `FromISR` só em prioridades permitidas por
`configLIBRARY_MAX_SYSCALL_INTERRUPT_PRIORITY=5`. Número NVIC menor significa
maior prioridade; não confundir com prioridades de tarefa FreeRTOS.

## USB CDC

A implementação usa `CDC_Transmit_FS`, `hUsbDeviceFS` e `TxState` da base.
Não usar `_write`/`printf` do laboratório como outro produtor CDC. Somente
USBLog transmite. Registros contêm tempo, estado, falha, último sensor, destino,
PWM percentual, aviso e contadores de descarte. Mensagens perdidas não são
reenviadas após reconectar; registrar o ensaio desde antes do início da viagem.
Reconexão, ocupação e prioridade real da IRQ ainda precisam de teste físico.
