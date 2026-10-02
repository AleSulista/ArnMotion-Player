# ArnMotion Player — Studio Arn

Versão pessoal baseada no VLC 3.0.24.
Programador e responsável pela personalização: Alessandro Henriques Teixeira.
E-mail: studioarn@aletecweb.com.br
Site: https://www.aletecweb.com.br

Este pacote contém fontes modificados, não um aplicativo compilado.
As mudanças ainda precisam ser compiladas e verificadas no macOS.

## Instalar no projeto existente

1. Feche o player e aguarde qualquer compilação em andamento terminar.
2. Extraia este ZIP em Downloads. A pasta deve se chamar `ArnMotion-personalizacao-v1`.
3. No Terminal, execute:

```bash
python3 "$HOME/Downloads/ArnMotion-personalizacao-v1/aplicar.py"
bash "$HOME/Downloads/ArnMotion-personalizacao-v1/construir-intel.command"
```

O projeto padrão é `~/Documents/ArnMotion-Player-VLC3`.
Você pode informar outro caminho como argumento dos dois scripts.
O instalador confere cada arquivo antes de escrever. Se o seu projeto mudou
desde o ZIP enviado, ele interrompe sem substituir arquivos.
O backup fica em `~/Documents/ArnMotion-backups/`, com a data da aplicação.
Uma segunda aplicação do mesmo pacote não duplica o menu ou as alterações.

O script de compilação usa as dependências Intel já construídas. Não apaga
contribs nem o projeto. Ele reconstrói `build-intel/VLC.app` e, após verificar
a assinatura, cria `build-intel/ArnMotion Player.app` se esse nome estiver livre.
A verificação de assinatura não equivale a notarização Apple.

Para acompanhar a compilação em outro Terminal:

```bash
tail -f "$HOME/Documents/ArnMotion-Player-VLC3/build-intel/build-arnmotion.log"
```

## O que foi personalizado

- Nome, identificador do aplicativo e ícones de aplicativo e arquivos.
- Janela Sobre e autores: Studio Arn, Alessandro, e-mail e site.
- Ajuda pessoal acompanhada da documentação da base VLC.
- Menu Arquivo → Baixar vídeo autorizado, com autorização explícita,
  escolha da pasta, vídeo MP4 ou áudio MP3, progresso e cancelamento.
- Barras superior e inferior com o material translúcido escuro do AppKit.
  Botões, atalhos e controles de reprodução da base são preservados.
- Atualizador Sparkle desativado, inclusive nas opções de build do pacote.

A transparência depende das configurações de acessibilidade do macOS e
precisa ser conferida visualmente no seu Mac. A opção “Reduzir transparência”
pode tornar o material opaco. A implementação usa o material do sistema,
portanto sua intensidade varia conforme o fundo e a versão do macOS.

## Download autorizado

O downloader usa yt-dlp e FFmpeg. Esta primeira integração procura essas
ferramentas em `Contents/Resources/tools`, `/usr/local/bin` e
`/opt/homebrew/bin`. Elas não estão incluídas neste ZIP de fontes.
Se já estiverem instaladas para o ArnPlay nesses caminhos, serão usadas.
Para instalá-las com Homebrew:

```bash
brew install yt-dlp ffmpeg
```

Baixe somente conteúdo próprio ou autorizado. Não há implementação para
contornar DRM. A disponibilidade de cada serviço depende do yt-dlp e do
acesso permitido ao endereço. Este pacote não configura login ou cookies.

Os downloads usam o título e o identificador do vídeo. Não substituem
arquivos existentes. MP4 usa remux quando necessário; MP3 usa conversão.

## Base, licença e créditos

ArnMotion Player é uma personalização independente do Studio Arn.
A base VLC foi desenvolvida pelos autores do VLC e pela comunidade VideoLAN.
As marcas VLC e VideoLAN pertencem à VideoLAN Association.
O Studio Arn é responsável pelas alterações indicadas, não pelo código
original do VLC. Os cabeçalhos, autores e licenças originais são mantidos.
Consulte COPYING, AUTHORS, THANKS e a licença da base no repositório.
As contribuições deste pacote são disponibilizadas sob GPL-2.0-or-later,
em conformidade com os cabeçalhos dos módulos adaptados.

## Estado de validação e próxima etapa

Os arquivos XML/plist, a lista de fontes e o funcionamento do instalador
foram conferidos no ambiente de preparação. A compilação AppKit, o lançamento,
o download real, o cancelamento e a aparência dependem da validação no Mac.

Sua compilação original Intel funcionou antes deste pacote.
Este pacote ainda não constitui um aplicativo universal: a compilação arm64
e a junção dos executáveis, bibliotecas e plugins das duas arquiteturas são
uma etapa posterior. Não copie as bibliotecas Homebrew Intel para a build ARM.

O pacote preserva a remoção da troca de CFNetwork por CoreServices feita
anteriormente. Não substitui `extras/package/macosx/package.mak` nem apaga
as bibliotecas b2, lz4 e zstd já copiadas para o prefixo Intel.
