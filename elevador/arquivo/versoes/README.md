# Versões anteriores de 3D e hardware

Cada vez que a mecânica, a IHM ou o mapa de hardware mudam, a versão substituída é guardada aqui e as pastas principais (`mecanica/`, `mecanica-impressa/`, `ihm/` e `docs/HARDWARE.md`) ficam só com a versão atual.

As pastas guardam os modelos `.scad`, os scripts `gerar.ps1`, as imagens e os documentos de hardware da época. Os STLs ficaram de fora: para obtê-los, rode o `gerar.ps1` da pasta com o OpenSCAD.

| Versão | Data | O que tinha | Por que foi substituída |
|---|---|---|---|
| [v1](v1_2026-11-16_torres-sem-porta/) | 16/11/2026 | Torre com varões e torre toda impressa, motor TT com tambor, microchaves. Sem porta. | Entrou a porta com servomotor. |
| [v2](v2_2026-11-18_porta-com-servo/) | 18/11/2026 | v1 com a porta e o alojamento do servo SG90 na cabine. Pinos com servo em PB8. | Entrou a IHM. A torre desta versão continua igual na atual. |
| [v3](v3_2026-11-25_botoeiras-nos-andares/) | 25/11/2026 | Botoeira de chamada presa em cada andar (quarto varão na torre de varões) e primeira caixa de eletrônica, sem botões de andar. | **Não adotada.** A equipe preferiu os botões de andar na IHM, não nos andares. |

**Versão atual (v4, 25/11/2026):** torres da v2 com verificação de colisão, e [IHM](../../ihm/README.md) com LCD, joystick, botões T, 1 e 2, emergência e LED.

O firmware não é arquivado aqui: o histórico do Git guarda cada versão, e o HEX publicado sempre corresponde à versão atual.
