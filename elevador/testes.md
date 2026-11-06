<img src="docs/assets/ifsc-logo.png" alt="IFSC" width="30%">

# 4. Testes e montagem

> Página 4 de 4 · [Sumário](README.md)

## No computador

Execute `make -B test` e `make sanitize` a partir da raiz, no Linux ou WSL. Os 24 grupos do núcleo incluem referência, viagens nos dois sentidos, chegada, timeout, sensores incoerentes, reconhecimento de falha e reversão. O teste adicional do kit verifica as polaridades, a validade do ADC, os bits de direção, o comando PWM e a inibição de STBY. [Casos do núcleo](tests/test_elevator.c) · [Casos do kit](tests/test_kit.c)

## Na bancada

1. **TC01 · Entradas.** Identificar a placa e os pinos. Com VM desligada e motor desconectado, conferir pelo USB o centro do joystick, o botão, cada andar e cada contato NF.
2. **TC02 · Viagem.** Referenciar no térreo e representar à mão uma viagem 0→2→0. Conferir o LCD e medir direção, PWM e STBY nos pontos indicados.
3. **TC03 · Falhas.** Abrir a parada durante a viagem, abrir cada limite e simular dois sensores de andar simultâneos. Conferir corte e recuperação separada da referência.
4. **TC04 · Acionamento.** Após fechar e registrar o hardware, começar com motor fixado e desacoplado. Só avançar para a cabine com retenção e corte verificados.

O [guia de montagem](docs/KIT_BANCADA.md) traz cada ligação, o arquivo para gravar e o resultado esperado por ação. Registrar medições, instrumento e evidências no [roteiro de bancada](docs/BANCADA.md).

## Evidências

- [Base de 27/10/2026](docs/VALIDACAO.md) e [reprodução de 04/11/2026](docs/VALIDACAO_MAQ_2026-11-04.md).
- [Validação da versão com o kit](docs/VALIDACAO_KIT.md), incluindo alcance dos testes e pendências físicas.

[← Retroceder](implementacao.md) · [Sumário](README.md) · [Voltar à capa →](README.md)
