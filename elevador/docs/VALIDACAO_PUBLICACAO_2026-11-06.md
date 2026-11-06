# Validação para publicação · 06/11/2026

O pacote de bancada inclui as fontes ativas, as instruções de montagem, o diagrama e um HEX pronto para gravar. A publicação conserva a cópia histórica de MIC2 com suas licenças. O script passou a procurar primeiro essa dependência incluída no repositório e a gerar HEX além do ELF.

## Testes

Na raiz de `elevador`, em Ubuntu/WSL com GCC 15.2.0, foram executados `make -B test` e `make sanitize`. Ambos encerraram com saída zero. Passaram os 24 grupos do núcleo e o teste adicional do kit. Os sanitizadores de memória e comportamento indefinido encerraram sem diagnósticos.

O conteúdo dos 159 arquivos de projeto e dependências da base histórica foi comparado com a base local em MIC2. Os conteúdos coincidem após normalizar os finais de linha.

## Compilação ARM e reprodução do download

Com Python 3.12.14 e GNU Tools for STM32 14.3.rel1, foi executado `scripts/build_f411.py --profile kit-bancada --cc <compilador instalado>`.

A seleção de `-Werror` foi ajustada para aplicar-se explicitamente às fontes ativas. Dessa forma, colocar a dependência histórica dentro do projeto conserva o tratamento anterior dos avisos de terceiros.

- Ligação concluída com 53 objetos.
- `text=26404`, `data=332` e `bss=20416` bytes.
- Os tamanhos coincidem com a [validação do kit de 04/11](VALIDACAO_KIT.md).
- 20 avisos de parâmetros não utilizados nas dependências herdadas.
- HEX com registros e checksums válidos, contendo dados de Flash entre `0x08000000` e `0x08006877`.

Os arquivos preparados para o Git foram exportados para uma pasta temporária isolada usando `git checkout-index`. A compilação nessa cópia, sem a pasta externa MIC2, produziu um HEX idêntico ao distribuído. O arquivo contém 75.285 bytes e o seguinte SHA-256:

```text
1d836c23812a5383a479c9dedb3c302366683b8a5619bc2748268bebac13f651
```

O HEX publicado fica em [firmware/kit-bancada](../firmware/kit-bancada/README.md). O [roteiro do colega](INSTRUCOES_COLEGA.md) descreve download, montagem, gravação, verificação e percurso manual.

## Ensaio físico pendente

Esta sessão verificou o software e o pacote de publicação. Gravação em placa, níveis elétricos, comunicação com o LCD, diagnóstico USB e percurso manual ainda precisam ser realizados pela equipe. O firmware de bancada mantém STBY baixo. O ensaio com motor exige o fechamento da ficha de hardware e o roteiro de validação correspondente.
