# Versões anteriores de 3D e hardware

Cada vez que a mecânica, a IHM ou o mapa de hardware mudam, a versão substituída é guardada aqui e as pastas principais (`impressao3d/` e `docs/HARDWARE.md`) ficam só com a versão atual.

As pastas guardam os modelos `.scad`, os scripts `gerar.ps1`, as imagens e os documentos de hardware da época. Os STLs ficaram de fora: para obtê-los, rode o `gerar.ps1` da pasta com o OpenSCAD.

| Versão | Data | O que tinha | Por que foi substituída |
|---|---|---|---|
| [v1](v1_2026-11-16_torres-sem-porta/) | 16/11/2026 | Torre com varões e torre toda impressa, motor TT com tambor, microchaves. Sem porta. | Entrou a porta com servomotor. |
| [v2](v2_2026-11-18_porta-com-servo/) | 18/11/2026 | v1 com a porta e o alojamento do servo SG90 na cabine. Pinos com servo em PB8. | Entrou a IHM. A torre toda impressa desta versão é a base da atual. |
| [v3](v3_2026-11-25_botoeiras-nos-andares/) | 25/11/2026 | Botoeira de chamada presa em cada andar (quarto varão na torre de varões) e primeira caixa de eletrônica, sem botões de andar. | **Não adotada.** A equipe preferiu os botões de andar na IHM, não nos andares. |
| [v4](v4_2026-11-25_ihm-separada/) | 25/11/2026 | Torres da v2 com verificação de colisão e IHM numa caixa separada, com calços de inclinação. | A equipe quis a IHM na mesma base da torre e nenhum material estrutural além do impresso. |

**Versão atual (v5, 26/11/2026):** [impressao3d](../../impressao3d/README.md). Torre toda impressa e IHM aparafusada na base da torre, formando uma base única; sem varões nem tábua.

O firmware não é arquivado aqui: o histórico do Git guarda cada versão, e o HEX publicado sempre corresponde à versão atual.
