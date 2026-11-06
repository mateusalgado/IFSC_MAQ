# Retomada MAQ · 04/11/2026

A etapa 1 reproduziu os resultados de [27/10/2026](VALIDACAO.md). Os mesmos 24 grupos passaram nas duas execuções. A compilação ARM ligou 51 objetos e repetiu os tamanhos das três seções. O trabalho foi feito na raiz de `MAQ/elevador`, com o código ativo e sem gravar a placa.

## Testes no computador

No Ubuntu 26.04 LTS via WSL, com GCC 15.2.0 e GNU Make 4.4.1, executar na raiz do elevador:

```sh
make -B test
make sanitize
```

O primeiro comando forçou a recompilação em C11, com as asserções habilitadas e `-Wall -Wextra -Werror -pedantic`. As duas execuções terminaram com `24 test groups passed` e código de saída zero. AddressSanitizer e UndefinedBehaviorSanitizer não emitiram diagnósticos.

Conferência de [testes](../tests/test_elevator.c), [estados](../src/elevator.c) e [motor](../src/motor.c):

- A partida exige referência. Os testes cobrem a busca do térreo, o início já sobre seu sensor e a viagem térreo → 2º → térreo com passagem pelo 1º andar.
- Parada e limites têm prioridade sobre pedidos. Há casos para referência vencida (15 s), viagem vencida (20 s), sensores simultâneos, andar pulado e sensor de partida preso (2 s).
- A falha zera a saída e invalida a referência. Com a causa removida, uma nova pressão longa reconhece a falha. Outra pressão longa solicita referência. Uma pressão iniciada antes da falha é descartada.
- Na reversão, o PWM cai a zero no sentido original. O teste verifica os 300 ms de espera em zero antes do primeiro comando no sentido oposto.
- A tarefa FreeRTOS [Control](../ports/stm32f411/elevator_rtos.c) é a única que chama `board_motor_write`. O [port compilado](../ports/stm32f411/board_unconfigured.c) descarta a escrita e devolve amostras com `valid=false`, condição de falha de entrada. Inicialização e panic têm funções separadas para inibir a saída.

## Compilação ARM

No PowerShell, a partir da mesma raiz, com Python 3.12.14 e GNU Tools for STM32 14.3.rel1 (GCC 14.3.1):

```powershell
$pyExe = "$env:USERPROFILE\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
$armCc = 'C:\ST\STM32CubeIDE_2.2.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.14.3.rel1.win32_1.0.100.202602081740\tools\bin\arm-none-eabi-gcc.exe'
& $pyExe scripts/build_f411.py --cc $armCc --base '..\..\MIC2\labRTOS\ex_Barry_USB_STM32F411CE' *> build/retomada-arm.log
```

Compilação e ligação concluídas com saída zero. O cabeçalho de `build/f411/elevador-unconfigured.elf` confirma ELF32, ARM, EABI5 e hard-float. O log contém 20 avisos de parâmetros não usados nas dependências. As fontes do elevador passaram com `-Werror`.

- **Ligação em 27/10 e em 04/11.** 51 objetos, `text=24732`, `data=332`, `bss=20264` bytes. Diferença de 0 bytes em cada seção.
- **Dependência.** O repositório local `MIC2/labRTOS` passou da revisão registrada `278dc298ca86d6c2ff089cdee511aa2cb771fd05` para `80b3a9eb56bf1f76ea6f50ca951cd7b02d7fdb69`. A árvore Git de `ex_Barry_USB_STM32F411CE` é idêntica nas duas (`aee64b8ddbd633ada8ef935d13ce038a794a647a`) e o diretório estava limpo.
- **Identificação local.** A pasta MAQ não tem commit próprio. No WSL, `sha256sum Makefile scripts/build_f411.py src/*.c include/*.h ports/stm32f411/*.c ports/stm32f411/*.h tests/*.c | sha256sum` resultou em `d1801c0b438a921463c1926b368ea69f9039fd04ea271e36f7ddfd3af68b0f34`. O SHA-256 do ELF gerado foi `fcbdc6c871b255f62411ebeb381fc803aac797d2ff87b76bac4cc57c68bece14`. O registro anterior permite comparar tamanhos, mas não informa um hash do ELF.

O acionamento físico continua inativo. Corrente, torque, retenção e distância de parada permanecem pendentes de dimensionamento e ensaio. O histórico em `arquivo/publicacao-mic2/` foi preservado.

## Levantamento para escolher o acionamento

Para cada peça disponível, anotar modelo e anexar foto da etiqueta ou ficha técnica. Para cada valor, indicar se veio do desenho, de medição ou de uma meta de projeto.

- [ ] **Cabine, guias e carga.** Massa móvel completa em vazio, carga útil máxima e massa de eventual contrapeso (kg). Se já houver guias montadas, levantar a força para iniciar e manter o movimento nos dois sentidos (N), com a cabine sustentada e sem ligar o motor.
- [ ] **Percurso e uso.** Distâncias térreo–1º e 1º–2º (mm), curso útil total, folgas até os batentes, tempo desejado por trecho (s) e viagens por minuto. Localizar os três sensores, os dois fins de curso e a parada independente.
- [ ] **Transmissão e retenção.** Identificar o mecanismo do modelo 3D. Para tambor, medir diâmetro do cabo e raios efetivos mínimo e máximo (mm). Para correia, anotar passo e dentes das polias. Para fuso, medir avanço por volta (mm/volta). Levantar redução, rendimento disponível e o mecanismo que sustenta a cabine sem energia.
- [ ] **Motor e fixação.** Levantar furação entre centros, espaço livre, diâmetro e comprimento útil do eixo e acoplamento (mm). Conferir o encaixe NEMA 17 do modelo de referência e o espaço para eventual motor CC com redutor. Registrar rotação sob carga (rpm), torque contínuo na saída (N·m) e relação de redução.
- [ ] **Dados elétricos do motor.** Para CC, levantar tensão (V) e correntes em vazio, nominal, de partida e de bloqueio (A) pela ficha técnica. Para motor de passo, levantar corrente por fase, indutância e curva torque × rotação. A escolha entre CC e passo determina o tipo de driver e a interface de comando.
- [ ] **Driver, placa e fonte.** Identificar a placa e a tensão lógica. Para cada driver candidato, levantar faixa de tensão do motor, corrente contínua com a dissipação prevista, pico e duração admissível, compatibilidade com lógica de 3,3 V, frenagem e proteções. Para cada fonte, registrar tensão de saída, corrente contínua, pico e duração, limite de corrente e consumo da lógica se ela compartilhar a alimentação.
