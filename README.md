# Metroid GBA Auto Splitters for LiveSplit

**Português · English | Versão de testes / Preview**

## Português

Scripts `.asl` para **Metroid: Zero Mission (USA)** e **Metroid Fusion (JPN)**, com Auto-Start e splits configuráveis. Testados por MetroidGameplays / **BizHawk 2.11.2 com núcleo mGBA**, usando LiveSplit 1.8.37 no Windows.

### Arquivos

| Jogo | Opções em português | Options in English |
| --- | --- | --- |
| Zero Mission — USA | [MetroidZeroMission PT-BR.asl](MetroidZeroMission%20PT-BR.asl) | [MetroidZeroMission_EN.asl](MetroidZeroMission_EN.asl) |
| Fusion — JPN | [MetroidFusion_JPN_PT-BR.asl](MetroidFusion_JPN_PT-BR.asl) | [MetroidFusion_JPN_EN.asl](MetroidFusion_JPN_EN.asl) |

O idioma do arquivo muda as opções, mensagens e comentários. **Não muda a região da ROM nem a lógica de detecção.** Escolha apenas um idioma para o jogo que vai usar.

### O que já foi confirmado

| Jogo | Confirmado no emulador | Ainda precisa de validação |
| --- | --- | --- |
| Zero Mission USA | Start na confirmação da dificuldade com A; Morph Ball; timer seguindo além de um minuto | Percurso completo, demais checkpoints e opções de 100% |
| Fusion JPN | Auto-Start no caminho de início registrado; download de Missiles; absorção da Morph Ball | Percurso completo, demais upgrades e final na nave; caminho separado de seleção de dificuldade |

Os scripts também oferecem opções para outros itens e eventos. A presença de uma opção não significa que ela já tenha sido confirmada em uma run completa. Fusion usa a aquisição/absorção da habilidade para os upgrades; isso pode acontecer depois do último golpe no chefe.

### Instalação

1. Baixe o `.asl` do jogo e do idioma desejados.
2. Se ainda não tiver a dependência, baixe o arquivo [emu-help-v2](https://raw.githubusercontent.com/Jujstme/emu-help/0736b8d8d54a35bde83006eaf02a4178bfb92e0e/lib/emu-help-v2) e coloque em `LiveSplit/Components/`. Mantenha o nome `emu-help-v2`, sem adicionar `.dll` ou `.txt`. O caminho `LiveSplit/Components/MetroidGBA/emu-help-v2` também é aceito. Essa dependência é baixada separadamente.
3. No LiveSplit: **Edit Layout → + → Control → Scriptable Auto Splitter**. Abra suas configurações e selecione o `.asl` em **Browse**.
4. Marque **Start**, **Split** e a opção **Auto-Start** do script. Deixe o Auto-Reset desmarcado se não quiser resets automáticos.
5. Abra a ROM da região indicada no BizHawk, usando o núcleo **mGBA**. Mantenha apenas um ASL deste pacote ativo.
6. Abra/crie sua lista `.lss` e marque somente os checkpoints que ela contém. Os scripts não criam a lista de splits nem associam eventos pelos nomes das linhas.

Para uma lista de Fusion que passa de **Screw Attack direto para Ship**, desmarque **Ice Beam** e deixe o evento final de fuga na nave marcado.

### Tempo e compatibilidade

**RTA / Real Time é o padrão desta prévia.** A opção de Game Time por IGT é experimental e deve ficar desmarcada para os testes de RTA. IGT é o relógio interno do save e pode retroceder ao morrer/carregar um arquivo.

Esta distribuição de ASLs se destina à leitura de RAM no emulador. **Não inclui autosplitter por captura de vídeo nem conversão integrada de tempo para Nintendo Switch Online no Switch 1/2.** Outras regiões de ROM e outros emuladores ainda não têm compatibilidade validada neste pacote.

Se usar o componente separado **GBA Converter** e o layout congelar perto de 59,7 segundos, desmarque **Drop Decimals When More Than 1 Minute** nas configurações desse componente. Os ASLs não instalam nem corrigem o conversor.

### Como ajudar nos testes

Ao relatar um problema, informe jogo/região, versão do BizHawk, núcleo, evento esperado e o que aconteceu. Inclua o log correspondente, gerado ao lado de `LiveSplit.exe`: `MetroidZeroMission_v3.log` ou `MetroidFusion_JPN_teste2.log`. No Fusion, deixe o registro do menu ligado ao testar outros caminhos de início. As versões em inglês mantêm os mesmos nomes de log.

## English

LiveSplit `.asl` scripts for **Metroid: Zero Mission (USA)** and **Metroid Fusion (JPN)**, with automatic starts and configurable splits. Tested by MetroidGameplays in **BizHawk 2.11.2 with the mGBA core**, using LiveSplit 1.8.37 on Windows.

The file table above provides Portuguese and English settings. The language choice changes labels, messages and comments; **it does not change the target ROM region or detection logic**. Choose one language per game.

### Current testing status

| Game | Confirmed in the emulator | Still needs validation |
| --- | --- | --- |
| Zero Mission USA | Start when A confirms difficulty; Morph Ball; timer advancing beyond one minute | Full runs, remaining checkpoints and 100% options |
| Fusion JPN | Auto-Start on the recorded new-game path; Missiles download; Morph Ball absorption | Full runs, remaining upgrades and final ship split; separate difficulty-selection path |

Other item/event settings are implemented, but have not all been verified in full runs. Fusion upgrade splits follow ability acquisition/absorption, which may happen after the final hit on a boss.

### Installation

1. Download the `.asl` for your game and preferred settings language.
2. If not already installed, download [emu-help-v2](https://raw.githubusercontent.com/Jujstme/emu-help/0736b8d8d54a35bde83006eaf02a4178bfb92e0e/lib/emu-help-v2) into `LiveSplit/Components/`. Keep the filename `emu-help-v2` without a `.dll` or `.txt` extension. `LiveSplit/Components/MetroidGBA/emu-help-v2` is also supported. This dependency is downloaded separately.
3. In LiveSplit, open **Edit Layout → + → Control → Scriptable Auto Splitter**. Open its settings and select the `.asl` with **Browse**.
4. Enable **Start**, **Split** and the script's **Auto-Start** setting. Leave Auto-Reset disabled unless you want automatic resets.
5. Open the ROM from the listed region in BizHawk, using the **mGBA** core. Keep only one ASL from this package active.
6. Open/create your `.lss` split list and enable only the checkpoints it contains. These scripts do not create split lists or map events to row names.

For a Fusion split list that goes from **Screw Attack directly to Ship**, disable **Ice Beam** and enable the final ship escape event.

### Timing and compatibility

**RTA / Real Time is the default for this preview.** Native IGT as Game Time is experimental; leave it unchecked for RTA testing. IGT is the internal save timer and may go backwards after death or loading a file.

This ASL distribution targets emulator RAM reading. **It does not include video-based autosplitting or integrated Nintendo Switch Online time conversion for Switch 1/2.** Other ROM regions and emulators have not been validated for this package.

If you use the separate **GBA Converter** component and the layout freezes around 59.7 seconds, uncheck **Drop Decimals When More Than 1 Minute** in that component's settings. These ASLs do not install or patch the converter.

### Feedback

Please report the game/region, BizHawk version, core, expected checkpoint and actual behavior. Attach the corresponding log from the `LiveSplit.exe` folder: `MetroidZeroMission_v3.log` or `MetroidFusion_JPN_teste2.log`. For other Fusion start paths, keep menu tracing enabled. English scripts retain the same log filenames.

## Sources / Créditos

- [Jujstme/emu-help](https://github.com/Jujstme/emu-help/tree/0736b8d8d54a35bde83006eaf02a4178bfb92e0e) — emulator memory helper; see its upstream license. The helper binary is not bundled here.
- [biosp4rk/mf-zm-info](https://github.com/biosp4rk/mf-zm-info/tree/2a0bc87ab1dcc1d61adb9c5f3ac7329ddb42939c) — memory maps and native data structures.
- [metroidret/mf](https://github.com/metroidret/mf) — Fusion decompilation reference. Its USA menu code alone does not establish the Japanese menu layout.

No ROMs or BIOS files are included. / Este pacote não contém ROMs nem BIOS.
