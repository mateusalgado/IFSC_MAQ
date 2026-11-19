# Validação da porta com servomotor · 18/11/2026

Esta revisão acrescenta o segundo tipo de motor do projeto: um servomotor que abre e fecha a porta da cabine. Os registros anteriores ([27/10](VALIDACAO.md), [04/11](VALIDACAO_MAQ_2026-11-04.md), [kit](VALIDACAO_KIT.md), [06/11](VALIDACAO_PUBLICACAO_2026-11-06.md)) descrevem as versões sem porta e não foram alterados.

## O que mudou

- **Núcleo.** Novo estado `FECHANDO`, novo comando de porta na FSM e nova falha `porta`. A porta abre em `PARADO` e fica fechada nos demais estados. O motor da cabine só recebe comando depois de 0,8 s de porta comandada fechada (`EL_DOOR_MS`). [Estados](../src/elevator.c) · [Arquitetura](ARQUITETURA.md#porta)
- **Port.** `board_door_write` no contrato da placa. No perfil de bancada, TIM10_CH1 em PB8 gera 50 Hz com pulso de 1,0 ms (fechada) ou 2,0 ms (aberta). O port inativo ignora o comando. [Port do kit](../ports/stm32f411/kit/board_kit.c)
- **Interface.** LCD mostra “PARADO P:aberta” e “Fechando porta”. O diagnóstico USB ganhou o campo `door`.
- **Mecânica.** Alojamento do servo na cabine e peça `porta` nos dois modelos de impressão 3D.

## Testes no computador

Ubuntu/WSL, `make -B test` e `make sanitize` na raiz de `elevador`. Ambos terminaram com saída zero. Passaram **26 grupos** do núcleo, com e sem AddressSanitizer e UndefinedBehaviorSanitizer, e o teste do kit.

Os 24 grupos anteriores foram adaptados para esperar o fechamento da porta antes de cada viagem. Dois grupos são novos:

- `test_door`: porta fechada durante a referência e a chegada; referência aguarda o tempo do servo; porta aberta em `PARADO`; pedido fecha a porta e a viagem só começa após 0,8 s; pedidos recusados durante o fechamento; perda do sensor durante o fechamento gera falha de posição; falha congela a porta e o reconhecimento a fecha sem mover a cabine; porta comandada aberta em viagem gera falha `porta`.
- `test_door_display`: textos do LCD com a porta aberta e fechando, com 16 caracteres por linha.

A rotina comum de passo dos testes passou a verificar, em todos os casos, que o comando do motor da cabine é zero sempre que a porta está comandada aberta. O teste do kit confere os dois valores de pulso do servo e o período de 20 ms.

## Compilação ARM

GNU Tools for STM32 14.3.rel1 do STM32CubeIDE 2.2.0, pelo script `scripts/build_f411.py`, executado com Python 3.14 no WSL chamando o compilador do Windows. Os perfis `unconfigured` e `kit-bancada` compilaram e ligaram, com as fontes próprias em `-Werror`.

| Perfil | Objetos ligados | text (bytes) | data (bytes) | bss (bytes) |
|---|---:|---:|---:|---:|
| kit-bancada | 53 | 26800 | 332 | 20480 |

HEX distribuído em [firmware/kit-bancada](../firmware/kit-bancada/README.md): 76.402 bytes, SHA-256 `82bddb2b1078b513d1e01bd4412a7a8366515b91c79d54e35deaec1a0d3a853c`.

## Não executado

- Gravação em placa, medição do pulso em PB8 e movimento de um servo real.
- Calibração dos pulsos de porta aberta e fechada e do tempo de 0,8 s.
- Impressão e montagem da porta e do alojamento do servo.
- Ensaio do servo e do motor da cabine na mesma fonte.

O firmware não detecta porta travada, obstáculo ou servo desconectado.
