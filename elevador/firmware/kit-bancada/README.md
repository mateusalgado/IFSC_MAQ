# Firmware de bancada pronto para gravar

Arquivo **[elevador-kit-bancada.hex](elevador-kit-bancada.hex)** · compilado em 25/11/2026, com a porta acionada por servomotor e os botões de andar da IHM.

Baixe o repositório por **Code → Download ZIP** e extraia-o. O HEX estará nesta pasta. No STM32CubeProgrammer, selecione esse arquivo na área de gravação e habilite a verificação. O [roteiro do colega](../../docs/INSTRUCOES_COLEGA.md) cobre as peças, ligações, gravação e teste.

Esta imagem usa STM32F411CEU6, cristal externo de 25 MHz, joystick em PA0/PA2 e LCD PCF8574T em 0x27. A ponte permanece desabilitada por STBY baixo. PB8 fornece o sinal do servo da porta e PB3, PB4 e PB15 leem os botões T, 1 e 2 da IHM. A montagem usa contatos manuais para representar os três andares.

**SHA-256**

```text
53746c7be2aba8d6eb40d04adc85ed3417f9b3bb05226286115862570a8492b8
```

Para conferir o arquivo no Windows, execute na pasta `elevador`:

```powershell
Get-FileHash firmware/kit-bancada/elevador-kit-bancada.hex -Algorithm SHA256
```

O HEX contém endereços de Flash a partir de `0x08000000`. Tamanho do arquivo, com os finais de linha originais do compilador, 77.048 bytes. A validação dos registros HEX e os resultados de testes e compilação desta versão estão no [registro da IHM](../../docs/VALIDACAO_IHM_2026-11-25.md). A versão anterior, sem porta, está no [registro da publicação](../../docs/VALIDACAO_PUBLICACAO_2026-11-06.md).

Para recompilar, execute `python scripts/build_f411.py --profile kit-bancada --cc <compilador>` na pasta `elevador`. A saída fica em `build/f411/kit-bancada/`. Atualize o HEX distribuído e seu hash sempre que publicar uma nova versão das fontes.
