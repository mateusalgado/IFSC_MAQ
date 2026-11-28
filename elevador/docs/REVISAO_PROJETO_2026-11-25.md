# Revisão do projeto e próximos passos · 25/11/2026

> **Atualização de 26/11/2026.** A equipe decidiu por uma estrutura toda impressa, sem varões nem tábua, com a IHM aparafusada na base da torre. Isso substitui as decisões 1 e 2 abaixo. O modelo atual está em [impressao3d](../impressao3d/README.md), e os itens sobre a torre toda impressa (deslizamento, cabine em balanço) passam a valer para ele. Os demais pontos continuam válidos.

Revisão geral do mini elevador com foco no 3D, para orientar o início da montagem. Cobre a versão atual: torres da v2 com porta, IHM nova e firmware com os botões de andar. Os pontos estão em ordem de prioridade dentro de cada seção.

## Situação atual

| Parte | Estado | Verificado | Falta |
|---|---|---|---|
| Firmware | Completo para bancada: referência, viagens, porta, botões de andar, falhas | 29 grupos de teste, sanitizadores e compilação ARM | Rodar em placa; perfil de potência com motor real |
| Torre de varões | Modelada, com porta e servo | Sólidos fechados; sem colisão da cabine em todo o curso | Imprimir; medir peças reais |
| Torre toda impressa | Modelada, com porta e servo | Igual à de varões | Imprimir; risco de atrito nos trilhos |
| IHM | Modelada: caixa, tampa, anel da emergência, calços | Sólidos fechados | Imprimir; medir LCD, joystick e botões |
| Hardware | Pinagem e BOM definidas | Pinos sem conflito no STM32F411 | Fonte do motor, corte de emergência por hardware |

Nenhuma peça foi impressa e nenhuma cota de componente foi medida. Todos os furos de motor, servo, microchave, LCD, joystick e botões usam valores nominais.

## Decisões para começar

1. **Usar a torre de varões.** Ela desliza aço em plástico, tolera empeno e é mais fácil de ajustar. A torre toda impressa depende de plástico deslizando em plástico com a cabine em balanço e o peso do servo de um lado. Manter as duas dobra o trabalho a cada mudança: a sugestão é mover `mecanica-impressa/` para o arquivo de versões.
2. **Fixar torre e IHM numa tábua** de MDF de uns 400 × 300 mm. A torre tem 400 mm de altura sobre uma base de 170 × 120 mm, com o motor no topo, e tomba fácil.
3. **Começar pela IHM e pela eletrônica de bancada**, que não dependem da mecânica. O firmware de bancada já roda com chaves manuais no lugar dos sensores.

## 3D: problemas e ajustes

### Prioridade alta

**1. A cabine pode escorregar quando o motor para.** No estado parado, o firmware deixa a ponte em espera (STBY baixo, saídas em alta impedância). A redução 1:48 do motor TT, de engrenagens retas, não é autotravante. Se o peso da cabine girar o motor de volta, a cabine sai da janela de 16 mm do ressalto e o firmware acusa falha de posição.

- No firmware, frear em curto ao parar (TB6612 com IN1 = IN2 = alto) em vez de deixar solto. É a correção mais barata.
- Testar com a cabine carregada. Se ainda escorregar, trocar por um motorredutor com rosca sem-fim (N20 ou JGY-370), que segura a carga sozinho. Isso pede um novo suporte no topo.

**2. Medir todas as peças antes de imprimir as grandes.** O gabarito atual testa varão, eixo do motor, parafusos e furação do TT. Faltam o alojamento do servo, o rebaixo do braço da porta, o furo dos botões de 12 mm, o da emergência de 22 mm e os pilares do LCD e do joystick. Vale ampliar o gabarito com esses furos antes de gastar 190 g de filamento na caixa da IHM.

**3. O cabo do servo acompanha a cabine.** São três fios subindo e descendo 220 mm. Sem guia, o cabo enrosca nos varões, nas braçadeiras ou na porta aberta. Fazer uma presilha na cabine e outra no meio da torre, com o cabo em laço por trás, longe do lado da porta. Alternativa: cabo flat fino.

**4. A porta fica presa só no braço do servo.** A placa de 13 g fica em balanço, presa por um parafuso pequeno no eixo do servo. Com uso, ela cede e roça. Acrescentar um pino de articulação embaixo, no mesmo eixo, apoiado no piso da cabine.

### Prioridade média

**5. Peso desbalanceado na cabine.** Servo e porta ficam do lado direito, mas o fio puxa no centro. A cabine tende a girar e travar nas guias. Na torre de varões o rasgo de um dos lados ajuda. Se travar, deslocar a alça do fio uns 5 mm para a direita ou pôr um pequeno contrapeso do lado esquerdo.

**6. Fio e tambor.** Usar linha de pesca trançada de 0,3 a 0,5 mm, que não estica. Testar o nó no furo de ancoragem com o dobro da carga. As 3,4 voltas do curso cabem no tambor.

**7. Os fins de curso só avisam o software.** Para o ensaio com carga, a proteção forte é ligar o segundo contato NF da emergência em série com a alimentação do motor (ver hardware, item 1).

**8. IHM.** Faltam um alívio de tração no entalhe dos cabos (abraçadeira) e legenda nos jaques P4 (5 V e motor), para não inverter. A altura do rasgo do USB depende de como a placa ficar espetada na protoboard: conferir antes de imprimir.

### Prioridade baixa

- As legendas gravadas de 3,5 a 4 mm ficam pouco legíveis com bico de 0,4 mm; aumentar para 5 mm ou pintar o fundo.
- Imprimir a cabine e a porta em cor diferente da torre ajuda a ver o movimento nos vídeos do ensaio.

### Filamento estimado (PLA, peças maciças, limite superior)

| Conjunto | Massa | Observação |
|---|---:|---|
| Torre de varões (base, topo, cabine, porta, 5 braçadeiras, tambor, gabarito) | ~380 g | Com 20% de preenchimento cai para ~250 g |
| IHM (caixa, tampa, anel, 2 calços) | ~360 g | Calços são opcionais (88 g) |
| Torre toda impressa, para comparação | ~640 g | Mais filamento que a de varões |

A cabine de varões com porta e servo deve ficar perto de 100 g. Com 100 g de carga de ensaio, o tambor de raio 10,3 mm pede cerca de 0,02 N·m no eixo do motor. Falta conferir na curva do motor real.

## Eletrônica e hardware

1. **Emergência com corte por hardware.** Comprar o botão de 22 mm com **dois** contatos NF: um vai a PB10 (diagnóstico) e o outro interrompe a alimentação VM da ponte. Assim a emergência corta o motor mesmo com o firmware travado. Hoje esse corte não existe.
2. **Uma fonte só.** O motor TT trabalha de 3 a 6 V. Uma fonte de 5 V e 3 A pode alimentar motor, servo, LCD e lógica, com fios separados desde a fonte e um capacitor eletrolítico de 470 µF a 1000 µF junto à ponte e ao servo. Isso elimina o segundo jaque. A placa continua pelo USB durante os testes.
3. **Medir a corrente.** O objetivo do experimento de MAQ é comparar corrente, tempo e ultrapassagem na subida e na descida (RF05), e hoje nada mede corrente. Um módulo INA219 no mesmo barramento I²C do LCD mede tensão e corrente do motor e cabe na protoboard de 170 pontos.
4. **Medir velocidade e posição.** O sensor de velocidade óptico vendido com os kits de motor TT (módulo com disco encoder de 20 furos) pode ler um disco impresso no eixo do tambor. PA6 e PA7 já estão reservados para o encoder (TIM3). Isso dá velocidade e ultrapassagem em milímetros, que hoje não são medidas.
5. Conferir que o backpack do LCD tem os pull-ups do I²C no lado de 5 V e o conversor de nível no lado de 3,3 V, como no diagrama.

## Firmware

1. **Freio ao parar** (ver 3D, item 1). Mudança pequena no port e no teste do kit.
2. **Perfil de potência.** O HEX de bancada nunca liga a ponte (STBY sempre baixo), de propósito. Para o motor girar é preciso o perfil `kit-operacao`, que exige o registro de hardware em JSON com motor, transmissão, fonte, retenção, corte de emergência e os limites de PWM. Preencher esse registro é o portão para o primeiro movimento real.
3. **Registrar pedidos durante a viagem.** Hoje botões apertados durante o movimento são recusados. Um elevador real guarda o pedido e atende depois. Dá para guardar um pedido por andar e atender na ordem do sentido de viagem.
4. **LED nos botões de andar.** Botões de 12 mm com LED mostram o pedido aceito, como num elevador. Precisam de três saídas livres (por exemplo PA9, PA10 e PB9, a confirmar).
5. **Modo manutenção.** Segurar o botão do joystick e mover para cima ou para baixo move a cabine devagar, enquanto o botão estiver apertado. Ajuda a calibrar as microchaves sem viagens completas.
6. **LCD.** Mostrar “Abrindo porta” e o andar atual em destaque.
7. **Registro do ensaio.** Acrescentar corrente e velocidade ao log USB, já com carimbo de tempo, para gerar as curvas do relatório de MAQ direto do terminal.

## Documentação

- As duas torres têm READMEs quase iguais. Ao arquivar a impressa, sobra um só guia de montagem.
- O [passo a passo do colega](INSTRUCOES_COLEGA.md) cobre só a bancada sem motor. Falta um roteiro de montagem completa: torre, IHM, cabos e primeiro movimento.
- A [ficha da etapa 2](FICHA_LEVANTAMENTO_ETAPA_2.md) é o lugar para registrar as medidas das peças compradas. Preencher conforme forem chegando.

## Roteiro para começar

1. **Comprar** a lista de materiais: STM32F411 Black Pill, ST-LINK, joystick KY-023, LCD 1602 com PCF8574T, conversor de nível, 5 microchaves KW12, 3 botões de 12 mm, emergência de 22 mm com dois NF, motor TT, TB6612FNG, servo SG90, fonte de 5 V 3 A, 4 varões de 8 mm (bastam 3 na versão atual), protoboards, parafusos M2, M2,5 e M3. Incluir INA219 e sensor de velocidade, se quiserem as medições de MAQ.
2. **Medir** as peças com paquímetro e anotar na ficha. Ajustar os parâmetros no início de `elevador.scad` e `ihm.scad` e gerar de novo.
3. **Imprimir os gabaritos** e conferir encaixes.
4. **Montar a IHM** com a eletrônica de bancada, gravar o HEX pronto e testar com chaves na mão, seguindo o passo a passo do colega.
5. **Imprimir e montar a torre** sem o motor. Conferir que a cabine desce sozinha pelos varões e que as microchaves clicam em cada andar.
6. **Instalar o motor** com freio ao parar, preencher o registro de hardware, gerar o perfil de potência e fazer o primeiro movimento com a cabine vazia.
7. **Ensaiar** com carga para o relatório de MAQ: subida e descida no mesmo trecho, registrando corrente, tempo e ultrapassagem.
