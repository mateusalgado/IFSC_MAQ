# Validação da IHM e dos botões de andar · 25/11/2026

Esta revisão cria a IHM do elevador: uma caixa de comando impressa, ao lado da torre, com LCD, joystick, um botão por andar (T, 1, 2), botão de emergência e LED de falha. Os registros anteriores continuam válidos para as versões que descrevem.

Uma versão intermediária do mesmo dia, com botoeiras de chamada presas em cada andar, foi descartada a pedido da equipe e está guardada em [arquivo/versoes](../arquivo/versoes/README.md).

## O que mudou

- **Entradas.** Novo campo `calls` na amostra (bits dos botões T, 1 e 2) e eventos `EV_CALL0..2`. Cada botão passa pelo debounce de 30 ms e gera um evento por pressão. Dois botões juntos são entregues um depois do outro. [Entradas](../src/inputs.c)
- **Estados.** Em PARADO, o botão de um andar equivale a selecionar e confirmar esse andar. Nos demais estados é recusado com o aviso de ocupado, ou de referência pendente em INICIO. O controlador descarta apertos pendentes a cada troca de estado. [Estados](../src/elevator.c)
- **Port.** PB3, PB4 e PB15 com pull-up interno, contato NA para GND. O diagnóstico USB ganhou o campo `calls`. [Port do kit](../ports/stm32f411/kit/board_kit.c)
- **3D.** Pasta nova `ihm/` (hoje em [arquivo/versoes/v4_2026-11-25_ihm-separada](../arquivo/versoes/v4_2026-11-25_ihm-separada/)): caixa, tampa com o painel de comando, anel amarelo da emergência e calços de 15°. Modo `colisao` nos dois modelos de torre. As torres não mudaram de forma.

## Testes no computador

Ubuntu/WSL, `make -B test` e `make sanitize`. Ambos terminaram com saída zero: **29 grupos** do núcleo, com e sem AddressSanitizer e UndefinedBehaviorSanitizer, e o teste do kit. Os 26 grupos anteriores passaram sem alteração de comportamento; o varrimento de segurança passou a incluir os três eventos dos botões de andar.

Grupos novos:

- `test_calls`: botão de outro andar fecha a porta e viaja até ele; botão do próprio andar só avisa e mantém a porta aberta; botões recusados durante o fechamento e antes da referência.
- `test_call_inputs`: rejeição de pulso de 20 ms, uma entrega por pressão mantida, dois botões simultâneos entregues em sequência.
- `test_call_trip_raw`: do sinal bruto à viagem; botão apertado durante o fechamento da porta é descartado, não enfileirado.

O teste do kit confere as oito combinações dos três botões nos pinos PB3, PB4 e PB15.

## Compilação ARM

GNU Tools for STM32 14.3.rel1 do STM32CubeIDE 2.2.0, pelo script `scripts/build_f411.py`. Os perfis `unconfigured` e `kit-bancada` compilaram e ligaram com as fontes próprias em `-Werror`.

| Perfil | Objetos ligados | text (bytes) | data (bytes) | bss (bytes) |
|---|---:|---:|---:|---:|
| kit-bancada | 53 | 27032 | 332 | 20552 |

HEX distribuído em [firmware/kit-bancada](../firmware/kit-bancada/README.md): 77.048 bytes, SHA-256 `53746c7be2aba8d6eb40d04adc85ed3417f9b3bb05226286115862570a8492b8`.

## Verificação do 3D

OpenSCAD 2021.01. Todas as peças de `mecanica/`, `mecanica-impressa/` e `ihm/` geraram sólidos fechados. Essas pastas foram arquivadas em 26/11/2026, quando a estrutura passou a ser toda impressa numa base única ([impressao3d](../impressao3d/README.md)). O modo `colisao` das duas torres intersecta a cabine, com a porta fechada a cada 20 mm de curso e aberta em cada andar, com base, varões ou coluna, topo, motor, tambor e braçadeiras ou grampos com o corpo das microchaves. Só restaram contatos de volume zero da cabine apoiada no batente inferior.

## Não executado

- Gravação em placa e teste dos botões reais.
- Impressão da IHM; conferência das cotas nominais do LCD, joystick, protoboards, botões e emergência.
