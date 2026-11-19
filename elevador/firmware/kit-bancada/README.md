# Firmware de bancada pronto para gravar

Arquivo **[elevador-kit-bancada.hex](elevador-kit-bancada.hex)** · compilado em 18/11/2026, com a porta acionada por servomotor.

Baixe o repositório por **Code → Download ZIP** e extraia-o. O HEX estará nesta pasta. No STM32CubeProgrammer, selecione esse arquivo na área de gravação e habilite a verificação. O [roteiro do colega](../../docs/INSTRUCOES_COLEGA.md) cobre as peças, ligações, gravação e teste.

Esta imagem usa STM32F411CEU6, cristal externo de 25 MHz, joystick em PA0/PA2 e LCD PCF8574T em 0x27. A ponte permanece desabilitada por STBY baixo. PB8 fornece o sinal do servo da porta. A montagem usa contatos manuais para representar os três andares.

**SHA-256**

```text
82bddb2b1078b513d1e01bd4412a7a8366515b91c79d54e35deaec1a0d3a853c
```

Para conferir o arquivo no Windows, execute na pasta `elevador`:

```powershell
Get-FileHash firmware/kit-bancada/elevador-kit-bancada.hex -Algorithm SHA256
```

O HEX contém endereços de Flash a partir de `0x08000000`. Tamanho do arquivo, com os finais de linha originais do compilador, 76.402 bytes. A validação dos registros HEX e os resultados de testes e compilação desta versão estão no [registro da porta](../../docs/VALIDACAO_PORTA_2026-11-18.md). A versão anterior, sem porta, está no [registro da publicação](../../docs/VALIDACAO_PUBLICACAO_2026-11-06.md).

Para recompilar, execute `python scripts/build_f411.py --profile kit-bancada --cc <compilador>` na pasta `elevador`. A saída fica em `build/f411/kit-bancada/`. Atualize o HEX distribuído e seu hash sempre que publicar uma nova versão das fontes.
