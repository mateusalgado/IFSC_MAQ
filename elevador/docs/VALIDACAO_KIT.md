# Validação do firmware de bancada · 04/11/2026

## Execução no computador

Ubuntu/WSL, GCC 15.2.0. Na raiz de `MAQ/elevador`, `make -B test` e `make sanitize` terminaram com saída zero. Passaram os mesmos 24 grupos da [base de retomada](VALIDACAO_MAQ_2026-11-04.md) e o novo executável de testes do kit. AddressSanitizer e UndefinedBehaviorSanitizer não emitiram diagnósticos.

O teste do kit verificou as máscaras dos três sensores, os três contatos NF, botão e validade da amostra do ADC. Para o comando de bancada, percorreu cinco valores de sentido (incluindo inválidos), PWM de 0 a 1000 e as três razões de parada. Em cada combinação conferiu a máscara de escrita dos pinos, o valor de comparação do timer e a inibição de STBY. As verificações usam a função de conversão chamada pelo port real. [Teste](../tests/test_kit.c) · [Conversão de sinais](../ports/stm32f411/kit/kit_signals.c)

## Compilação ARM

Python 3.12.14, GNU Tools for STM32 14.3.rel1. O [guia de integração](INTEGRACAO.md) contém o comando PowerShell e a seleção dos perfis. O script recompilou e ligou separadamente:

| Perfil | Objetos ligados | text (bytes) | data (bytes) | bss (bytes) |
|---|---:|---:|---:|---:|
| unconfigured | 51 | 24852 | 332 | 20400 |
| kit-bancada | 53 | 26404 | 332 | 20416 |

Em relação ao port inativo registrado antes das alterações, o perfil inativo atual cresceu 120 bytes em `text` e 136 em `bss`. Esta revisão inclui as entradas brutas no diagnóstico USB. O build de bancada teve 20 avisos em fontes herdadas e compilou as fontes próprias com `-Werror`.

ELF de bancada: `build/f411/kit-bancada/elevador-kit-bancada.elf`. SHA-256 local: `8e4a34a16e8268f722374747596aa8f8f45f6f38d16acf4b99fbbf00827244ba`. A tabela de símbolos contém os handlers do kit para EXTI, HardFault e UsageFault, além dos drivers de entradas, saída e LCD.

O construtor recusou `--profile kit-operacao` sem ficha de hardware e rejeitou uma ficha de teste cujo comando de viagem excedia o teto (saída 2 em ambos). Em uma cópia temporária das fontes, com ficha sintética exclusiva de teste, o perfil de potência compilou e ligou 53 objetos (`text=26420`, `data=332`, `bss=20416` bytes). A cópia, a ficha e o ELF de potência foram descartados ao fim da verificação.

Não houve gravação, energização nem ensaio físico. O primeiro registro de LCD, USB, polaridades, watchdog e sinais reais deve ser feito na [bancada](KIT_BANCADA.md).
