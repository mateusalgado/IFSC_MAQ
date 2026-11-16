<img src="docs/assets/ifsc-logo.png" alt="Instituto Federal de Santa Catarina" width="30%">

# Mini elevador didático de três andares

## Máquinas e Acionamentos · Controle de uma cabine com STM32F411 e FreeRTOS

> Aluno: Mateus Salgado Barboza Costa  
> Instituto Federal de Santa Catarina · 04/11/2026

A cabine atende térreo, primeiro e segundo andar. O operador escolhe um destino pelo joystick e acompanha a viagem no LCD. O experimento de MAQ compara como carga e sentido afetam corrente, tempo e deslocamento após a detecção do andar.

**Para montar agora:** siga o [passo a passo do colega](docs/INSTRUCOES_COLEGA.md), desde o download até a montagem, gravação e percurso com chaves manuais. O [HEX de bancada pronto](firmware/kit-bancada/README.md) acompanha o repositório. Nesse perfil os sinais PWM e direção chegam aos pontos de medição e STBY permanece baixo. O fechamento da mecânica e da alimentação está na [ficha da etapa 2](docs/FICHA_LEVANTAMENTO_ETAPA_2.md).

<p align="center"><strong>SUMÁRIO</strong></p>

[**1. Análise do sistema**](analise.md) · [**2. Projeto do sistema**](projeto.md) · [**3. Implementação em C e FreeRTOS**](implementacao.md) · [**4. Testes e montagem**](testes.md)

## Começar pelos testes

Linux, WSL ou ambiente com GCC e Make, dentro desta pasta:

```sh
make test
make sanitize
```

No PowerShell:

```powershell
wsl -d Ubuntu -- make -C /mnt/c/Users/mateu/OneDrive/Documentos/MAQ/elevador test
```

Os testes não dependem de HAL, placa, internet ou FreeRTOS. Simulam sensores,
comandos e relógio. `sanitize` acrescenta verificações de memória e comportamento
indefinido. Não usar `-DNDEBUG`, pois os testes empregam `assert`.

## Documentação

- [Relatório técnico e vínculo com a disciplina](docs/RELATORIO.md).
- [Arquitetura, estados e operação](docs/ARQUITETURA.md).
- [Compilação ARM e integração no STM32CubeIDE](docs/INTEGRACAO.md).
- [Componentes, pinagem provisória e decisões pendentes](docs/HARDWARE.md).
- [Montagem, calibração e roteiro de bancada](docs/BANCADA.md).
- [Evidências e limites da validação](docs/VALIDACAO.md).
- [Protótipo mecânico para impressão 3D](mecanica/README.md).

## Organização

```text
include/              Contratos e parâmetros provisórios
src/                  FSM, entradas, motor e formatação LCD, sem HAL
tests/                Testes determinísticos no computador
ports/stm32f411/       Tarefas FreeRTOS, USB, port inativo e perfil de kit
scripts/              Compilação ARM reproduzível
docs/                 Relatório, montagem, decisões e evidências
```

## Operação prevista

1. Após ligar, o motor permanece inativo. Soltar o botão antes de usá-lo.
2. Segurar o botão do joystick por pelo menos 1 s e soltar para iniciar referência.
3. A cabine desce com comando limitado até confirmar o sensor do térreo.
4. Com a cabine parada, mover o joystick uma vez para selecionar o andar;
   voltar ao centro antes de outra seleção. Clique curto confirma.
5. Pedidos durante referência, viagem ou chegada são recusados e descartados.
6. Em falha, corrigir a causa, liberar a parada/limites e segurar/soltar para
   reconhecer. Isso retorna à inicialização sem movimento. Uma nova ação longa
   solicita outra referência. O destino anterior não é retomado.

O LCD alterna informação de último andar confirmado/destino com “entre andares”.
PWM é percentual de comando, não velocidade medida. A primeira versão para no
sensor, em movimento lento; não estima distância contínua nem desaceleração precisa.

## Dependências e preservação

O build ARM usa por padrão a cópia de `ex_Barry_USB_STM32F411CE` em
`arquivo/publicacao-mic2/`, incluída neste repositório e tratada como dependência
de leitura. O script também reconhece a base externa em `../../MIC2/labRTOS/`.
HAL STM32F4, CMSIS, FreeRTOS 10.3.1, USB CDC, startup e linker permanecem na base
original. A configuração FreeRTOS local foi derivada dela, conservando a licença.
`washmachine` foi consultado como referência de FSM, sem importar HAL, pinagem,
startup ou configuração STM32F103. Os slides foram consultados localmente; não são
duplicados nesta entrega.

O elevador passou de MIC2 para MAQ em 27/10/2026. A publicação anterior está preservada em `arquivo/publicacao-mic2/`. O relatório original registra essa origem. A capa, o sumário e a navegação seguem [MIC2](https://github.com/mateusalgado/IFSC_MIC2/tree/main/projeto-jogo) e [PROGOO](https://github.com/mateusalgado/IFSC_PROGOO_PROJECT). O logotipo foi reutilizado do material local de MIC2.
