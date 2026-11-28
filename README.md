<img src="elevador/docs/assets/ifsc-logo.png" alt="Instituto Federal de Santa Catarina" width="30%">

# Máquinas e Acionamentos — IFSC

Mini elevador didático de três andares, desenvolvido por Mateus Salgado Barboza Costa com STM32F411CEU6 e FreeRTOS.

**Para quem vai montar e testar, comece pelo [passo a passo do colega](elevador/docs/INSTRUCOES_COLEGA.md).** Ele explica como baixar os arquivos, separar as peças, montar na protoboard, gravar o código pronto e testar o percurso térreo → 2º → térreo.

- [Diagrama pino a pino](elevador/docs/DIAGRAMA_KIT_BANCADA.svg).
- [Firmware de bancada pronto para gravar](elevador/firmware/kit-bancada/README.md).
- [Documentação com análise, projeto, implementação e testes](elevador/README.md).
- [Ficha de levantamento da mecânica e das peças](elevador/docs/FICHA_LEVANTAMENTO_ETAPA_2.md).
- [Peças para impressão 3D](elevador/impressao3d/README.md): torre, cabine, porta, sensores e IHM, tudo impresso, numa base única. Versões anteriores ficam em [arquivo/versoes](elevador/arquivo/versoes/README.md).
- [Revisão do projeto e próximos passos](elevador/docs/REVISAO_PROJETO_2026-11-25.md).

A primeira montagem funciona com contatos manuais para representar os andares. O perfil de bancada mantém a ponte desabilitada. O acionamento da cabine depende das medidas, da retenção e da seleção de motor, driver e fonte.

O repositório contém o projeto ativo em `elevador/` e a publicação anterior de MIC2 em `elevador/arquivo/publicacao-mic2/`. A cópia histórica fornece as bibliotecas para recompilar em outro computador e conserva as licenças dos respectivos autores. [Validação da publicação](elevador/docs/VALIDACAO_PUBLICACAO_2026-11-06.md)
