
# Heinteira Motion Player 1.0.1 — Heinteira Studio

Projeto pessoal de melhorias, sem fins lucrativos.
Programador: Alessandro Henriques Teixeira.
Contato e PIX: studioarn@aletecweb.com.br
Site: https://www.aletecweb.com.br
Base: VLC 3.0.24 / VideoLAN. Créditos e licenças originais preservados.

## Melhorias
Download autorizado de vídeo MP4 e áudio MP3; opção de usar localmente a sessão do Chrome no YouTube.
Janela de download com vidro integral, movimentação pelo fundo, Fechar e Cancelar.
Conclusão bem-sucedida fecha a janela e revela o arquivo no Finder.
Ícones próprios do aplicativo e documentos, com indicação de formato.
Volume até 400%; barra de progresso vermelha e verde com 50% de opacidade.
Atualizador VideoLAN/Sparkle desativado.

## Instalação e compatibilidade
Build Intel x86_64; não universal. O macOS mínimo da distribuição é informado na Release.
Apple Silicon depende de Rosetta 2 e ainda requer teste.
Arraste o aplicativo do DMG para Aplicativos. A miniatura do Finder permanece quando disponível.
Os ícones de documento dependem da associação dos arquivos ao Heinteira Motion Player.
Ferramentas yt-dlp, FFmpeg, FFprobe e Deno são incorporadas pelo finalizador do DMG.
Quando o YouTube exigir sessão, abra o vídeo no Chrome conectado e marque a opção no player.
O aplicativo não inclui contas, senhas ou cookies. Baixe somente conteúdo próprio ou autorizado.

## Licenças e doações
Consulte COPYING, COPYING.LIB, AUTHORS e THANKS para o código-base VLC/VideoLAN.
Faça uma doação para apoiar as melhorias pessoais do Heinteira Studio.
PIX (chave e-mail): studioarn@aletecweb.com.br.

## Compilação
Use extras/package/macosx/build.sh com a arquitetura x86_64 para a build Intel.
Execute o finalizador apenas após compilar e testar a aplicação.
