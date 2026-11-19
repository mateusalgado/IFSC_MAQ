# Ficha de levantamento · Mini elevador de três andares

**Etapa 2 — escolha da transmissão, do motor, do driver e da fonte**

Revisão documental 04/11/2026 · Data da coleta __________ · Responsável ____________________ · Versão da maquete ____________________

Preencha com a potência do motor desligada. Use **pendente** para um dado desconhecido e **N/A** para uma peça que a montagem dispensa. Para cada valor, guarde a referência que permita conferi-lo. Preencha apenas as opções de transmissão e motor que estiver considerando.

## 1. Quais peças estão disponíveis?

Os IDs abaixo identificam **candidatos de projeto**. A coluna de estoque só deve ser preenchida após ver a peça. Anote fabricante, código, quantidade e foto ao lado do ID.

| Peça | Referência já documentada ou adotada para a bancada | Estoque, modelo real e foto |
|---|---|---|
| Cabine e guias | Cabine leve com paradas no térreo, 1º e 2º. Uso de contrapeso pendente. [Plano](PLANO_DE_RETOMADA_MAQ.md) | Pendente |
| T1 · transmissão | Tambor/cabo, correia ou fuso dependem da estrutura escolhida. Mancais e acoplamento pendentes. [Mecânica](HARDWARE.md) | Pendente |
| M1 · motor/redutor | Proposta MAQ de motor CC com redução. Candidato de kit TT 3–6 V. [Plano](PLANO_DE_RETOMADA_MAQ.md) · [Exemplar de referência 3777](https://www.adafruit.com/product/3777) | Pendente |
| M2 · servo da porta | Servomotor de posição tipo SG90, 5 V, sinal em PB8. Porta e suporte nos modelos de [impressão 3D](../mecanica/README.md). [Hardware](HARDWARE.md) | Pendente |
| R1 · retenção | Deve sustentar a cabine sem alimentação. Mecanismo e capacidade pendentes. [Bancada](BANCADA.md) | Pendente |
| C1 · controle | Alvo STM32F411CEU6, HSE 25 MHz, com SWD e USB. Conferir marcação, cristal, regulador e pinos expostos. [Hardware](HARDWARE.md) · [Clock do firmware](../ports/stm32f411/main.c) | Pendente |
| D1 · driver | Perfil TB6612FNG, canal A, lógica prevista de 3,3 V. [Perfil de bancada](KIT_BANCADA.md) | Pendente |
| F1 · fonte | Lógica regulada e alimentação de motor a dimensionar por corrente de partida, bloqueio e dissipação. [Plano](PLANO_DE_RETOMADA_MAQ.md) | Pendente |
| S0/S1/S2 e LI/LS | Necessários 3 sensores de andar e 2 fins de curso independentes. Perfil de bancada com contatos secos. [Hardware](HARDWARE.md) · [Perfil](KIT_BANCADA.md) | Pendente |
| P1 · parada | Botão acessível, contato de diagnóstico e corte da potência independente do software. [Hardware](HARDWARE.md) | Pendente |
| J1 / LCD1 | Joystick analógico com botão e LCD 16×2. Para o kit, joystick tipo KY-023 e backpack PCF8574T. [Hardware](HARDWARE.md) · [Perfil](KIT_BANCADA.md) | Pendente |
| Indicadores | LED e buzzer ativo com acionamento compatível. [Hardware](HARDWARE.md) | Pendente |

## 2. O que medir na maquete

Use a altura do piso da cabine alinhada ao térreo como zero. Registre o instrumento e as condições de cada medição. Para medir força manualmente, mantenha a cabine protegida contra queda e anote a carga, o contrapeso e se a transmissão estava acoplada.

| Medição física | Valor medido | Instrumento e condição |
|---|---|---|
| Massa móvel em vazio, incluindo cabine, suporte e ferragens (kg) | Pendente | |
| Massa da carga disponível para ensaio / massa do contrapeso (kg) | Pendente | |
| Distância entre paradas, térreo → 1º / 1º → 2º (mm) | Pendente | |
| Curso útil térreo → 2º (mm) | Pendente | |
| Altura de atuação dos sensores, térreo / 1º / 2º (mm) | Pendente | |
| Altura de atuação dos fins de curso, inferior / superior (mm) | Pendente | |
| Folga entre atuação do fim de curso e batente, inferior / superior (mm) | Pendente | |
| Força para iniciar / manter a subida (N) | Pendente | |
| Força para iniciar / manter a descida (N) | Pendente | Indicar sentido da força aplicada |
| Espaço livre para motor + redutor, comprimento × largura × altura (mm) | Pendente | |
| Furação do suporte, entre centros X × Y / diâmetro dos furos (mm) | Pendente | |
| Eixo de saída, diâmetro / comprimento útil (mm), e tipo de encaixe | Pendente | |

**Geometria da transmissão disponível — pendente de identificação e medição** · ID __________ · Instrumento __________

- **Tambor e cabo.** Diâmetro do cabo ____ mm. Raio efetivo até o centro do cabo na primeira / última camada útil ____ / ____ mm.
- **Correia e polias.** Passo ____ mm. Dentes da polia motora / movida ____ / ____. Qual polia desloca a cabine? __________
- **Fuso e porca.** Avanço axial da cabine em uma volta completa do fuso ____ mm/volta. Comprimento útil ____ mm.

## 3. O que consultar no desenho

Referência publicada: *Elevator Lift Arduino*, descrita com motor de passo NEMA 17. O projeto registra que os STLs e o acoplamento não foram inspecionados. Arquivo, revisão e unidade do CAD adotado: **pendentes**. [Registro da referência mecânica](HARDWARE.md#referência-mecânica)

| Cota ou detalhe previsto | Valor do desenho | Vista ou peça de referência |
|---|---|---|
| Distâncias térreo–1º / 1º–2º e folgas até os batentes (mm) | Pendente | |
| Tipo de transmissão e geometria nominal (raio do tambor, passo e dentes ou avanço do fuso) | Pendente | |
| Motor previsto, furação entre centros e espaço para redutor/acoplamento (mm) | Referência NEMA 17. Cotas e adaptação ao TT pendentes. [Hardware](HARDWARE.md) | |
| Posição das guias, dos três sensores e dos dois fins de curso (mm) | Pendente | |
| Fixação da cabine e mecanismo previsto para sustentá-la sem energia | Pendente | |

Diferenças entre o desenho e as peças medidas, inclusive eventual adaptação do suporte NEMA 17 para motor CC com redutor: ________________________________________

## 4. O que copiar da placa, etiqueta ou datasheet

Preencha uma linha por modelo e cite a foto ou a página da ficha técnica. Copie as condições associadas aos valores, em especial tensão, duração dos picos, dissipação e eixo ao qual o torque se refere. Levante as correntes de partida e de bloqueio por documentação, sem travar nem energizar o motor.

**Referências para comparação.** O fornecedor do exemplar TT 3777 informa redução 48:1 e operação de 3 a 6 V. Em um exemplar a 4,5 V, o fornecedor mediu 155 mA e 185 rpm em vazio e 1,2 A em bloqueio. Copie os valores do motor disponível nos campos abaixo após identificar o modelo. Corrente nominal sob carga, torque contínuo e rendimento seguem pendentes. [Adafruit 3777](https://www.adafruit.com/product/3777)

O perfil D1 usa PWMA, AIN1, AIN2 e STBY. Com STBY baixo, a ponte fica em espera. A corrente admissível da placa montada, a proteção e a fonte exigem a identificação do módulo e da carga. O projeto Proteus de MAQ registra um modelo de motor CC, sem confirmação da ponte utilizada. [Toshiba, TB6612FNG](https://toshiba.semicon-storage.com/info/datasheet_en_20141001.pdf?did=10660) · [Inspeção do material MAQ](HARDWARE.md#uso-do-material-de-maq)

**Campos da peça real — todos pendentes de etiqueta, foto ou datasheet do modelo.**

| Componente e ID | Dados a preencher | Foto ou documento e página |
|---|---|---|
| Motor CC ____ | Tensão ____ V · Corrente em vazio ____ A · nominal ____ A · partida ____ A · bloqueio ____ A | |
| Motor CC com redutor ____ | Redução ____:1 · rendimento ____ % · rotação sob carga na saída ____ rpm · torque contínuo na saída ____ N·m | |
| Servo da porta ____ | Tensão ____ V · corrente em movimento / travado ____ / ____ A · curso ____ ° · pulso mínimo / máximo ____ / ____ ms · tempo para 60° ____ s | |
| Motor de passo ____ | Corrente ____ A/fase · indutância ____ mH/fase · ângulo ____ °/passo · torque disponível ____ N·m a ____ rpm, conforme curva do fabricante | |
| Placa de controle ____ | Modelo do MCU ____ · nível lógico ____ V · alimentação da placa ____ V | |
| Driver ____ | Tipo/interface de comando ____ · alimentação do motor ____ a ____ V · níveis lógicos aceitos ____ V · corrente contínua ____ A · pico ____ A por ____ ms · dissipação exigida ____ | |
| Driver ____ | Ajuste/limite de corrente ____ A · comportamento ao desabilitar ____ · frenagem e proteções disponíveis ____ | |
| Fonte ____ | Saída ____ V · corrente contínua ____ A · pico ____ A por ____ ms · comportamento no limite de corrente ____ | |
| Alimentação da lógica ____ | Fonte separada ou compartilhada ____ · tensão ____ V · consumo previsto ____ A | |
| Sensores / fins de curso / parada ____ | Tipo e polaridade ou contato ____ · alimentação ____ V · dispositivo que interrompe a potência ____ · capacidade do contato em CC ____ V / ____ A | |
| Retenção ____ | Princípio de retenção sem energia ____ · capacidade declarada e unidade ____ | |

## 5. Metas e decisão

**Objetivo documentado.** Comparar subida e descida no mesmo trecho com cabine vazia e carga conhecida, registrando corrente, tempo e deslocamento após o sensor. [Plano MAQ](PLANO_DE_RETOMADA_MAQ.md)

**Metas numéricas pendentes de definição.** Carga útil máxima pretendida ____ kg · tempo desejado térreo–1º / 1º–2º ____ / ____ s · viagens por minuto ____ · tolerância de parada ____ mm.

**Parâmetros disponíveis para o teste de sinais.** O perfil de bancada usa comando de referência de 15%, viagem de 25%, teto de 30%, rampa de 20 pontos percentuais/s e espera de 300 ms em zero na reversão. Os timeouts de busca e viagem são 15 e 20 s. Esses valores pertencem à simulação de comando e ao firmware de bancada. As metas de tempo, os limites de corrente e os parâmetros da cabine continuam pendentes. [Configuração do núcleo](../include/elevator_config.h) · [Interface do kit](KIT_BANCADA.md)

**Dimensionamento pendente das medições.** Eixo de referência ____ · rotação necessária ____ rpm · torque contínuo necessário ____ N·m · torque de partida necessário ____ N·m · perdas e margem adotadas, com justificativa ____________________.

**Verificação elétrica pendente dos modelos efetivos.** Tensão de trabalho ____ V · corrente contínua / pico previsto ____ / ____ A por ____ ms · limites correspondentes do driver e da fonte ____________________ · proteção escolhida e valor nominal ____________________.

**Conjunto definitivo pendente.** Transmissão ____ · motor/redutor ____ · driver ____ · fonte ____ · retenção ____ · parada independente ____.

**Pendências antes da integração.** Peça ou dado que falta ____________________ · como obtê-lo ____________________ · responsável ____________________.
