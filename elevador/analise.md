<img src="docs/assets/ifsc-logo.png" alt="IFSC" width="30%">

# 1. Análise do sistema

> Página 1 de 4 · [Sumário](README.md)

## Problema e operação

O operador tem uma cabine guiada, três paradas e um único comando de destino. Ao ligar, o controlador desconhece a altura da cabine. A primeira ação longa no botão solicita referência ao térreo. A partir daí, um movimento do joystick altera a seleção em um andar e um clique confirma o destino. Durante a viagem, a interface informa o último andar confirmado e o destino.

## Requisitos verificáveis

- **RF01 · Referenciar.** Encontrar o sensor do térreo ou reconhecer que a cabine já está nele. O fim de curso inferior interrompe a busca.
- **RF02 · Viajar.** Atender um destino por vez e observar os sensores na sequência física. Na chegada, zerar o comando e confirmar a permanência no andar.
- **RF03 · Interromper.** Parada, limite, sensores incoerentes ou prazo vencido cortam o comando. Após corrigir a causa, uma pressão longa reconhece a falha e outra solicita referência.
- **RF04 · Observar.** Exibir estado e destino no LCD e fornecer diagnóstico USB para identificar entrada, sensor e comando durante o teste.
- **RF05 · Investigar o acionamento.** Com carga conhecida, comparar subida e descida no mesmo trecho. Registrar corrente, tempo e ultrapassagem em cada repetição. Na bancada inicial esses valores físicos ficam pendentes.

O levantamento distingue massa medida, geometria do desenho e especificação elétrica do fabricante. Essas três fontes sustentam a escolha do conjunto que moverá a cabine. [Ficha de levantamento](docs/FICHA_LEVANTAMENTO_ETAPA_2.md) · [Plano de MAQ](docs/PLANO_DE_RETOMADA_MAQ.md)

[← Retroceder](README.md) · [Sumário](README.md) · [Avançar →](projeto.md)
