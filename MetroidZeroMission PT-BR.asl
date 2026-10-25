// Metroid: Zero Mission — revisão 3 (2026-10-25).
// Corrige o script anexado por Erick: confirmação da dificuldade, Morph e relógio.
// RTA inicia ao aceitar A em Easy/Normal/Hard. IGT é opcional em Game Time.
// Biblioteca: emu-help-v2, já instalada em Components ou Components/MetroidGBA.
// Menu: offsets nativos GBA, com alinhamento das structs em 4 bytes.
// Fonte: biosp4rk/mf-zm-info, commit 2a0bc87ab1dcc1d61adb9c5f3ac7329ddb42939c,
// json/zm/structs.json (FileSelectData e FileSelectMenuCursors).
// A validação em um emulador real continua necessária.

state("LiveSplit") {}

startup
{
    refreshRate = 120;
    vars.difficultyArmed = false;
    vars.pendingSplit = "";
    vars.startReason = "manual";
    vars.lastGoodIGT = TimeSpan.Zero;
    // Libera uma pausa de Game Time que outro script possa ter deixado.
    timer.IsGameTimePaused = false;

    // -------------------------------------------------------------------------
    // Configuracoes (Settings) no LiveSplit
    // -------------------------------------------------------------------------
    settings.Add("general", true, "Opcoes Gerais");
    settings.Add("auto_start", true, "Auto-Start no A que confirma Easy / Normal / Hard", "general");
    settings.Add("auto_reset", false, "Auto-Reset ao voltar para a Tela Inicial / Title Screen", "general");
    settings.Add("clock_igt", false, "Game Time usa IGT do jogo (desmarcado = acompanha RTA)", "general");
    settings.Add("debug_verbose", false, "Log detalhado de menus e memoria", "general");
    settings.SetToolTip("clock_igt", "RTA comeca na confirmacao da dificuldade. O IGT e um relogio independente: acompanha as pausas e o tempo absoluto do save.");


    // 1. Upgrades / Itens (Beams, Suits, Misc, Tanks)
    settings.Add("items", true, "Upgrades & Equipamentos (Samus)");
    settings.Add("item_morph_ball", true, "Morph Ball", "items");
    settings.Add("item_long_beam", true, "Long Beam", "items");
    settings.Add("item_charge_beam", true, "Charge Beam", "items");
    settings.Add("item_bombs", true, "Bombs", "items");
    settings.Add("item_ice_beam", true, "Ice Beam", "items");
    settings.Add("item_wave_beam", true, "Wave Beam", "items");
    settings.Add("item_plasma_beam", true, "Plasma Beam / Unknown Item #1 (Crateria)", "items");
    settings.Add("item_high_jump", true, "High Jump", "items");
    settings.Add("item_speed_booster", true, "Speed Booster", "items");
    settings.Add("item_varia_suit", true, "Varia Suit", "items");
    settings.Add("item_space_jump", true, "Space Jump / Unknown Item #2 (Kraid)", "items");
    settings.Add("item_gravity_suit", true, "Gravity Suit / Unknown Item #3 (Ridley)", "items");
    settings.Add("item_screw_attack", true, "Screw Attack", "items");
    settings.Add("item_power_grip", true, "Power Grip", "items");
    settings.Add("item_fully_powered_suit", true, "Fully Powered Suit (Ruins Test / Gravity + Plasma + Space Jump)", "items");
    settings.Add("item_first_missile", true, "Primeiro Missile Tank", "items");
    settings.Add("item_first_super", true, "Primeiro Super Missile Tank", "items");
    settings.Add("item_first_pb", true, "Primeiro Power Bomb Tank", "items");

    // 2. Chefes & Eventos da Historia (gEventsTriggered em EWRAM 0x02037E00)
    settings.Add("bosses", true, "Chefes (Bosses) & Eventos Principais");
    settings.Add("boss_deorem", false, "Deorem derrotado na segunda sala (flag especifica)", "bosses");
    settings.Add("boss_acid_worm", false, "Acid Worm Derrotado (Ziplines)", "bosses");
    settings.Add("boss_kraid", true, "Kraid Derrotado", "bosses");
    settings.Add("boss_imago_cocoon", false, "Imago Cocoon Derrotado (Larva)", "bosses");
    settings.Add("boss_imago", false, "Imago Derrotado", "bosses");
    settings.Add("boss_ridley", true, "Ridley Derrotado", "bosses");
    settings.Add("boss_mother_brain", true, "Mother Brain Derrotada", "bosses");
    settings.Add("event_escaped_zebes", true, "Fuga de Tourian / Inicio de Chozodia (Zero Suit)", "bosses");
    settings.Add("boss_mecha_ridley", true, "Mecha Ridley Derrotado", "bosses");
    settings.Add("event_escaped_chozodia", true, "Split Final: Fuga de Chozodia (Nave)", "bosses");

    // 3. Transicoes de Area (Entradas e Saidas de Regioes)
    settings.Add("areas", false, "Transicoes de Area (Elevadores)");
    settings.Add("area_entries", false, "Entradas de Area (Primeira vez que entra)", "areas");
    settings.Add("area_brinstar", false, "Entrar em Brinstar", "area_entries");
    settings.Add("area_kraid", false, "Entrar em Kraid", "area_entries");
    settings.Add("area_norfair", false, "Entrar em Norfair", "area_entries");
    settings.Add("area_ridley", false, "Entrar em Ridley", "area_entries");
    settings.Add("area_tourian", false, "Entrar em Tourian", "area_entries");
    settings.Add("area_crateria", false, "Entrar em Crateria", "area_entries");
    settings.Add("area_chozodia", false, "Entrar em Chozodia", "area_entries");

    settings.Add("area_exits", false, "Saidas de Area (Sair pelo Elevador)", "areas");
    settings.Add("exit_brinstar", false, "Sair de Brinstar", "area_exits");
    settings.Add("exit_kraid", false, "Sair de Kraid", "area_exits");
    settings.Add("exit_norfair", false, "Sair de Norfair (Norfair Exit)", "area_exits");
    settings.Add("exit_ridley", false, "Sair de Ridley (Ridley Exit)", "area_exits");
    settings.Add("exit_tourian", false, "Sair de Tourian", "area_exits");
    settings.Add("exit_crateria", false, "Sair de Crateria", "area_exits");
    settings.Add("exit_chozodia", false, "Sair de Chozodia", "area_exits");

    // 4. Area Cleared - 100% de Itens da Area (Ideal para 100% Speedruns)
    settings.Add("area_clear", true, "Area Cleared - 100% de Itens da Area (100% Speedruns)");
    settings.Add("area_clear_on_transition", false, "Splitar no Elevador/Transicao apos 100% (Desmarcado = Split imediato no ultimo item da area)", "area_clear");
    settings.Add("clear_brinstar", false, "Brinstar Cleared (100%: 14 Tanques + 5 Upgrades)", "area_clear");
    settings.Add("clear_kraid", false, "Kraid Cleared (100%: 11 Tanques + 2 Upgrades)", "area_clear");
    settings.Add("clear_norfair", false, "Norfair Cleared (100%: 17 Tanques + 4 Upgrades)", "area_clear");
    settings.Add("clear_ridley", false, "Ridley Cleared (100%: 19 Tanques + 1 Upgrade)", "area_clear");
    settings.Add("clear_tourian", false, "Tourian Cleared (100%: 2 Tanques)", "area_clear");
    settings.Add("clear_crateria", false, "Crateria Cleared (100%: 5 Tanques + 2 Upgrades)", "area_clear");
    settings.Add("clear_chozodia", false, "Chozodia Cleared (100%: 18 Tanques + Fully Powered Suit)", "area_clear");

    // HashSet e Helpers auxiliares
    vars.completedSplits = new HashSet<string>();

    // Log desta revisao; as escritas de START/SPLIT ocorrem depois de marcar o tempo.
    vars.logPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "MetroidZeroMission_v3.log");
    try
    {
        File.AppendAllText(vars.logPath, "[MZM v3] Autosplitter inicializado: " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "\r\n");
    }
    catch {}

    vars.Log = (Action<string>)(msg =>
    {
        try
        {
            string line = "[" + DateTime.Now.ToString("HH:mm:ss.fff") + "] " + msg + "\r\n";
            File.AppendAllText(vars.logPath, line);
            print("[MZM] " + msg);
        }
        catch {}
    });

    vars.BitChanged = (Func<uint, uint, int, bool>)((oldVal, curVal, bit) =>
    {
        uint mask = 1U << bit;
        return (oldVal & mask) == 0 && (curVal & mask) != 0;
    });

    vars.IsAreaCleared = (Func<int, byte, byte, byte, byte, bool>)((areaId, tanks, beamBombs, suitMisc, suitType) =>
    {
        switch (areaId)
        {
            case 0: // Brinstar: 14 Tanques + Long(0x01), Charge(0x10), Bombs(0x80) + Varia(0x10), Morph(0x40)
                return tanks >= 14 && (beamBombs & 0x91) == 0x91 && (suitMisc & 0x50) == 0x50;
            case 1: // Kraid: 11 Tanques + SpeedBooster(0x02), SpaceJump(0x04)
                return tanks >= 11 && (suitMisc & 0x06) == 0x06;
            case 2: // Norfair: 17 Tanques + Ice(0x02), Wave(0x04) + HighJump(0x01), ScrewAttack(0x08)
                return tanks >= 17 && (beamBombs & 0x06) == 0x06 && (suitMisc & 0x09) == 0x09;
            case 3: // Ridley: 19 Tanques + GravitySuit(0x20)
                return tanks >= 19 && (suitMisc & 0x20) == 0x20;
            case 4: // Tourian: 2 Tanques (nenhum upgrade principal)
                return tanks >= 2;
            case 5: // Crateria: 5 Tanques + PlasmaBeam(0x08) + PowerGrip(0x80)
                return tanks >= 5 && (beamBombs & 0x08) == 0x08 && (suitMisc & 0x80) == 0x80;
            case 6: // Chozodia: 18 Tanques + Fully Powered Suit (suitType == 1)
                return tanks >= 18 && suitType == 1;
            default:
                return false;
        }
    });

    vars.TrySplit = (Func<string, bool, bool>)((splitKey, enabled) =>
    {
        if (enabled && !vars.completedSplits.Contains(splitKey))
        {
            vars.completedSplits.Add(splitKey);
            vars.pendingSplit = splitKey;
            return true;
        }
        return false;
    });

    // -------------------------------------------------------------------------
    // Carrega emu-help-v2
    // -------------------------------------------------------------------------
    vars.helperLoaded = false;
    string[] helperPaths = new string[]
    {
        Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Components", "MetroidGBA", "emu-help-v2"),
        Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Components", "emu-help-v2")
    };
    string lastHelperError = "Biblioteca nao encontrada.";
    foreach (string helperPath in helperPaths)
    {
        if (!File.Exists(helperPath))
            continue;
        try
        {
            byte[] bytes = File.ReadAllBytes(helperPath);
            string hash;
            using (var sha = System.Security.Cryptography.SHA256.Create())
                hash = BitConverter.ToString(sha.ComputeHash(bytes)).Replace("-", "").ToLowerInvariant();
            if (hash != "46ae44d21abea6eb34edde74c37223b415cf2035161130ecbd9a983edb0292d3")
                throw new InvalidDataException("Biblioteca diferente da versao emu-help-v2 conferida.");
            object helper = Assembly.Load(bytes).CreateInstance("GBA");
            if (helper == null)
                throw new InvalidOperationException("Classe GBA ausente na biblioteca.");
            vars.helperLoaded = true;
            vars.Log("emu-help-v2 carregado: " + helperPath);
            break;
        }
        catch (Exception ex)
        {
            lastHelperError = helperPath + ": " + ex.Message;
        }
    }
    if (!vars.helperLoaded)
    {
        settings.Add("dependency_error", false, "ERRO: confira emu-help-v2 em Components (veja o log)");
        settings.SetToolTip("dependency_error", lastHelperError);
        vars.Log("ERRO DE BIBLIOTECA: " + lastHelperError);
    }

    if (vars.helperLoaded)
    {
        // -------------------------------------------------------------------------
        // Mapeamento de Memoria GBA (offsets confrontados com a decompilacao USA)
        // IWRAM: 0x03000000 | EWRAM: 0x02000000
        // -------------------------------------------------------------------------
        vars.Helper.Load = (Func<dynamic, bool>)(emu =>
        {
            // Estado Geral e Area
            emu.Make<byte>("completedGame", 0x03000024);      // gGameCompletion.completedGame
            emu.Make<byte>("language", 0x03000020);           // gLanguage
            emu.Make<byte>("difficulty", 0x0300002C);         // gDifficulty (0=Easy, 1=Normal, 2=Hard)
            emu.Make<byte>("area", 0x03000054);               // gCurrentArea (0=Brinstar, 1=Kraid, 2=Norfair, 3=Ridley, 4=Tourian, 5=Crateria, 6=Chozodia)
            emu.Make<byte>("room", 0x03000055);               // gCurrentRoom
            emu.Make<byte>("escapeStatus", 0x0300095C);       // gCurrentEscapeStatus
            emu.Make<byte>("pauseScreenFlag", 0x03000BF0);    // gPauseScreenFlag
            emu.Make<short>("gameMode", 0x03000C70);          // gMainGameMode (0=Reset, 1=Intro, 2=Title, 3=FileSelect, 4=InGame, 5=Pause, 7=ChozodiaEscape)
            emu.Make<short>("subGameMode1", 0x03000C72);      // gSubGameMode1
            emu.Make<byte>("subGameMode2", 0x03000C74);       // gSubGameMode2 (0=menu idle, 1=continue, 2=new game)

            // FileSelectData fica no inicio de gNonGameplayRam (0x030016C4).
            // O compilador GBA alinha FileSelectMenuCursors em +0x2C e reserva 8 bytes.
            // Um offsetof com o compilador do PC dava +0x29 e 7 bytes (revisao 2).
            emu.Make<byte>("fileMenu", 0x03001702);        // FileSelectData.currentSubMenu, +0x3E
            emu.Make<byte>("fileStage", 0x03001704);       // FileSelectData.subMenuStage, +0x40
            emu.Make<ushort>("fileMenuTimer", 0x03001706); // FileSelectData.subMenuTimer, +0x42
            emu.Make<byte>("fileAction", 0x030016FE);      // FileSelectData.unk_3A, +0x3A
            emu.Make<byte>("fileDifficulty", 0x030016F6);  // fileSelectCursors.difficulty, +0x2C + 6
            emu.Make<ushort>("changedInput", 0x03001380);  // gChangedInput, KEY_A = 1
            emu.Make<ushort>("frameCounter", 0x03000002);  // gFrameCounter16Bit

            // Ler os quatro bytes juntos evita quatro leituras separadas do relogio.
            // Little endian: horas, minutos, segundos, frames (de 0 a 59).
            emu.Make<uint>("igtWord", 0x03000150);

            // Contadores de Tanques Coletados por Area - gNumberOfItemsCollected (u8[8] em 0x03000063)
            emu.Make<byte>("tanksBrinstar", 0x03000063);      // Area 0 (Brinstar): Max 14
            emu.Make<byte>("tanksKraid", 0x03000064);         // Area 1 (Kraid):    Max 11
            emu.Make<byte>("tanksNorfair", 0x03000065);       // Area 2 (Norfair):  Max 17
            emu.Make<byte>("tanksRidley", 0x03000066);        // Area 3 (Ridley):   Max 19
            emu.Make<byte>("tanksTourian", 0x03000067);       // Area 4 (Tourian):  Max 2
            emu.Make<byte>("tanksCrateria", 0x03000068);      // Area 5 (Crateria): Max 5
            emu.Make<byte>("tanksChozodia", 0x03000069);      // Area 6 (Chozodia): Max 18

            // Samus Data & Equipment
            emu.Make<byte>("demoState", 0x030013D2);          // gDemoState
            emu.Make<byte>("samusPose", 0x030013D4);          // gSamusData.pose
            emu.Make<ushort>("maxEnergy", 0x03001530);        // gEquipment.maxEnergy
            emu.Make<ushort>("maxMissiles", 0x03001532);      // gEquipment.maxMissiles
            emu.Make<byte>("maxSuperMissiles", 0x03001534);   // gEquipment.maxSuperMissiles
            emu.Make<byte>("maxPowerBombs", 0x03001535);      // gEquipment.maxPowerBombs
            emu.Make<byte>("beamBombs", 0x0300153C);          // gEquipment.beamBombs (bitflags)
            emu.Make<byte>("suitMisc", 0x0300153E);           // gEquipment.suitMisc (bitflags: bit 6 = Morph Ball)
            emu.Make<byte>("suitType", 0x03001542);           // gEquipment.suitType (0=Normal, 1=FullyPowered, 2=Suitless)

            // Eventos em EWRAM - gEventsTriggered (u32[3] em 0x02037E00)
            emu.Make<uint>("events0", 0x02037E00);            // Eventos 0x00 .. 0x1F
            emu.Make<uint>("events1", 0x02037E04);            // Eventos 0x20 .. 0x3F
            emu.Make<uint>("events2", 0x02037E08);            // Eventos 0x40 .. 0x5F

            vars.Log("Variaveis de memoria mapeadas com sucesso!");
            return true;
        });
    }
}

init
{
    vars.difficultyArmed = false;
    vars.Log("init: aguardando emulador / menu de dificuldade.");
}

onStart
{
    vars.completedSplits.Clear();
    vars.difficultyArmed = false;
    vars.pendingSplit = "";
    vars.lastGoodIGT = TimeSpan.Zero;
    timer.IsGameTimePaused = false;
    vars.Log("START: " + vars.startReason);
    vars.startReason = "manual";
}

onSplit
{
    // O LiveSplit ja capturou o timestamp do split antes deste evento.
    if (!string.IsNullOrEmpty((string)vars.pendingSplit))
        vars.Log("SPLIT: " + vars.pendingSplit);
    vars.pendingSplit = "";
}

onReset
{
    vars.completedSplits.Clear();
    vars.difficultyArmed = false;
    vars.pendingSplit = "";
    vars.lastGoodIGT = TimeSpan.Zero;
    timer.IsGameTimePaused = false;
    vars.Log("RESET da tentativa.");
}

shutdown
{
    // emu-help injeta o descarte da sua propria instancia neste bloco.
    timer.IsGameTimePaused = false;
}

update
{
    // O helper injeta sua verificacao de conexao antes deste bloco.
    if (!vars.helperLoaded)
        return false;
    var values = (IDictionary<string, object>)current;
    if (!values.ContainsKey("gameMode") || !values.ContainsKey("suitMisc")
        || !values.ContainsKey("fileStage") || !values.ContainsKey("igtWord"))
        return false;

    if (settings["debug_verbose"])
    {
        if (old.gameMode != current.gameMode || old.subGameMode1 != current.subGameMode1
            || (current.gameMode == 3 && old.fileStage != current.fileStage))
            vars.Log(string.Format("GM={0}->{1} SGM1={2}->{3} menu={4} stage={5}->{6} action={7} dificuldade={8} frame={9}",
                old.gameMode, current.gameMode, old.subGameMode1, current.subGameMode1,
                current.fileMenu, old.fileStage, current.fileStage, current.fileAction,
                current.fileDifficulty, current.frameCounter));
        if (old.suitMisc != current.suitMisc)
            vars.Log(string.Format("suitMisc 0x{0:X2}->0x{1:X2}", (byte)old.suitMisc, (byte)current.suitMisc));
    }
    return true;
}

start
{
    if (!settings["auto_start"])
    {
        vars.difficultyArmed = false;
        return false;
    }

    // GM 3 / SGM1 2 = File Select processando input (sem fadeout).
    // Submenu 1 = arquivo; stage 30 = escolha de dificuldade aguardando input.
    bool difficultyMenu = current.gameMode == 3 && current.subGameMode1 == 2
        && current.fileMenu == 1 && current.demoState == 0;
    if (!difficultyMenu)
    {
        vars.difficultyArmed = false;
        return false;
    }
    if (current.fileStage == 30)
    {
        vars.difficultyArmed = true;
        return false;
    }

    // O jogo aceita A em stage 30 e escreve action=4, stage=34 no mesmo frame.
    // 35/36 mantem a confirmacao, caso a consulta perca apenas o primeiro frame.
    // Nao ha fallback para Press Start, fadeout, tela preta ou entrada em Brinstar.
    bool confirmed = vars.difficultyArmed && current.fileAction == 4
        && current.fileStage >= 34 && current.fileStage <= 36
        && current.fileDifficulty <= 2;
    vars.difficultyArmed = false;
    if (!confirmed)
        return false;

    vars.startReason = "A aceito na dificuldade (menu=1, stage="
        + current.fileStage + ", action=4, dificuldade=" + current.fileDifficulty
        + ", frame=" + current.frameCounter + ")";
    return true;
}

reset
{
    if (!settings["auto_reset"])
        return false;
    return old.gameMode >= 4 && old.gameMode <= 10
        && (current.gameMode == 0 || current.gameMode == 2 || current.gameMode == 3);
}

split
{
    // Ignora menus e telas fora do jogo principal (GM_INGAME == 4, GM_MAP_SCREEN == 5, GM_CHOZODIA_ESCAPE == 7, etc.)
    if (current.demoState != 0 || current.gameMode < 4 || current.gameMode > 10 || current.gameMode == 6)
        return false;

    // -------------------------------------------------------------------------
    // 1. Upgrades & Equipamentos (Samus)
    // -------------------------------------------------------------------------
    // Fully Powered Suit (apos derrotar Ruins Test em Chozodia: suitType muda de 2=Suitless para 1=FullyPowered)
    if (old.suitType != 1 && current.suitType == 1 && vars.TrySplit("item_fully_powered_suit", (bool)settings["item_fully_powered_suit"] && settings.SplitEnabled))
        return true;

    // Morph Ball (Bit 6 de suitMisc: SMF_MORPH_BALL == 0x40)
    if (vars.BitChanged(old.suitMisc, current.suitMisc, 6) && vars.TrySplit("item_morph_ball", (bool)settings["item_morph_ball"] && settings.SplitEnabled))
        return true;

    if (current.beamBombs != old.beamBombs)
    {
        if (vars.BitChanged(old.beamBombs, current.beamBombs, 0) && vars.TrySplit("item_long_beam", (bool)settings["item_long_beam"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.beamBombs, current.beamBombs, 1) && vars.TrySplit("item_ice_beam", (bool)settings["item_ice_beam"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.beamBombs, current.beamBombs, 2) && vars.TrySplit("item_wave_beam", (bool)settings["item_wave_beam"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.beamBombs, current.beamBombs, 3) && vars.TrySplit("item_plasma_beam", (bool)settings["item_plasma_beam"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.beamBombs, current.beamBombs, 4) && vars.TrySplit("item_charge_beam", (bool)settings["item_charge_beam"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.beamBombs, current.beamBombs, 7) && vars.TrySplit("item_bombs", (bool)settings["item_bombs"] && settings.SplitEnabled)) return true;
    }

    if (current.suitMisc != old.suitMisc)
    {
        if (vars.BitChanged(old.suitMisc, current.suitMisc, 0) && vars.TrySplit("item_high_jump", (bool)settings["item_high_jump"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.suitMisc, current.suitMisc, 1) && vars.TrySplit("item_speed_booster", (bool)settings["item_speed_booster"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.suitMisc, current.suitMisc, 2) && vars.TrySplit("item_space_jump", (bool)settings["item_space_jump"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.suitMisc, current.suitMisc, 3) && vars.TrySplit("item_screw_attack", (bool)settings["item_screw_attack"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.suitMisc, current.suitMisc, 4) && vars.TrySplit("item_varia_suit", (bool)settings["item_varia_suit"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.suitMisc, current.suitMisc, 5) && vars.TrySplit("item_gravity_suit", (bool)settings["item_gravity_suit"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.suitMisc, current.suitMisc, 7) && vars.TrySplit("item_power_grip", (bool)settings["item_power_grip"] && settings.SplitEnabled)) return true;
    }


    // Primeiros Tanks de Misseis, Super Misseis e Power Bombs
    if (old.maxMissiles == 0 && current.maxMissiles > 0 && vars.TrySplit("item_first_missile", (bool)settings["item_first_missile"] && settings.SplitEnabled))
        return true;
    if (old.maxSuperMissiles == 0 && current.maxSuperMissiles > 0 && vars.TrySplit("item_first_super", (bool)settings["item_first_super"] && settings.SplitEnabled))
        return true;
    if (old.maxPowerBombs == 0 && current.maxPowerBombs > 0 && vars.TrySplit("item_first_pb", (bool)settings["item_first_pb"] && settings.SplitEnabled))
        return true;

    // -------------------------------------------------------------------------
    // 2. Chefes & Eventos da Historia (gEventsTriggered)
    // -------------------------------------------------------------------------
    // Bloco 0 (0x02037E00: Eventos 0x00 .. 0x1F)
    if (current.events0 != old.events0)
    {
        if (vars.BitChanged(old.events0, current.events0, 0x1B) && vars.TrySplit("boss_deorem", (bool)settings["boss_deorem"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.events0, current.events0, 0x1C) && vars.TrySplit("boss_acid_worm", (bool)settings["boss_acid_worm"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.events0, current.events0, 0x1E) && vars.TrySplit("boss_kraid", (bool)settings["boss_kraid"] && settings.SplitEnabled)) return true;
    }

    // Bloco 1 (0x02037E04: Eventos 0x20 .. 0x3F -> bit = eventId - 0x20)
    if (current.events1 != old.events1)
    {
        if (vars.BitChanged(old.events1, current.events1, 0x22 - 0x20) && vars.TrySplit("boss_imago_cocoon", (bool)settings["boss_imago_cocoon"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.events1, current.events1, 0x23 - 0x20) && vars.TrySplit("boss_imago", (bool)settings["boss_imago"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.events1, current.events1, 0x25 - 0x20) && vars.TrySplit("boss_ridley", (bool)settings["boss_ridley"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.events1, current.events1, 0x27 - 0x20) && vars.TrySplit("boss_mother_brain", (bool)settings["boss_mother_brain"] && settings.SplitEnabled)) return true;
    }

    // Bloco 2 (0x02037E08: Eventos 0x40 .. 0x5F -> bit = eventId - 0x40)
    if (current.events2 != old.events2)
    {
        if (vars.BitChanged(old.events2, current.events2, 0x41 - 0x40) && vars.TrySplit("event_escaped_zebes", (bool)settings["event_escaped_zebes"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.events2, current.events2, 0x4A - 0x40) && vars.TrySplit("boss_mecha_ridley", (bool)settings["boss_mecha_ridley"] && settings.SplitEnabled)) return true;
        if (vars.BitChanged(old.events2, current.events2, 0x4B - 0x40) && vars.TrySplit("event_escaped_chozodia", (bool)settings["event_escaped_chozodia"] && settings.SplitEnabled)) return true;
    }


    // -------------------------------------------------------------------------
    // 3. Transicoes de Area (Entradas e Saidas de Regiao)
    // -------------------------------------------------------------------------
    if (current.area != old.area)
    {
        // Entradas de Area
        if (current.area == 0 && vars.TrySplit("area_brinstar", (bool)settings["area_brinstar"] && settings.SplitEnabled)) return true;
        if (current.area == 1 && vars.TrySplit("area_kraid", (bool)settings["area_kraid"] && settings.SplitEnabled)) return true;
        if (current.area == 2 && vars.TrySplit("area_norfair", (bool)settings["area_norfair"] && settings.SplitEnabled)) return true;
        if (current.area == 3 && vars.TrySplit("area_ridley", (bool)settings["area_ridley"] && settings.SplitEnabled)) return true;
        if (current.area == 4 && vars.TrySplit("area_tourian", (bool)settings["area_tourian"] && settings.SplitEnabled)) return true;
        if (current.area == 5 && vars.TrySplit("area_crateria", (bool)settings["area_crateria"] && settings.SplitEnabled)) return true;
        if (current.area == 6 && vars.TrySplit("area_chozodia", (bool)settings["area_chozodia"] && settings.SplitEnabled)) return true;

        // Saidas de Area
        if (old.area == 0 && vars.TrySplit("exit_brinstar", (bool)settings["exit_brinstar"] && settings.SplitEnabled)) return true;
        if (old.area == 1 && vars.TrySplit("exit_kraid", (bool)settings["exit_kraid"] && settings.SplitEnabled)) return true;
        if (old.area == 2 && vars.TrySplit("exit_norfair", (bool)settings["exit_norfair"] && settings.SplitEnabled)) return true;
        if (old.area == 3 && vars.TrySplit("exit_ridley", (bool)settings["exit_ridley"] && settings.SplitEnabled)) return true;
        if (old.area == 4 && vars.TrySplit("exit_tourian", (bool)settings["exit_tourian"] && settings.SplitEnabled)) return true;
        if (old.area == 5 && vars.TrySplit("exit_crateria", (bool)settings["exit_crateria"] && settings.SplitEnabled)) return true;
        if (old.area == 6 && vars.TrySplit("exit_chozodia", (bool)settings["exit_chozodia"] && settings.SplitEnabled)) return true;
    }

    // -------------------------------------------------------------------------
    // 4. Area Cleared (100% de Itens da Area - gNumberOfItemsCollected + Equip)
    // -------------------------------------------------------------------------
    if (settings["area_clear"])
    {
        bool curBrinstar = vars.IsAreaCleared(0, current.tanksBrinstar, current.beamBombs, current.suitMisc, current.suitType);
        bool curKraid    = vars.IsAreaCleared(1, current.tanksKraid,    current.beamBombs, current.suitMisc, current.suitType);
        bool curNorfair  = vars.IsAreaCleared(2, current.tanksNorfair,  current.beamBombs, current.suitMisc, current.suitType);
        bool curRidley   = vars.IsAreaCleared(3, current.tanksRidley,   current.beamBombs, current.suitMisc, current.suitType);
        bool curTourian  = vars.IsAreaCleared(4, current.tanksTourian,  current.beamBombs, current.suitMisc, current.suitType);
        bool curCrateria = vars.IsAreaCleared(5, current.tanksCrateria, current.beamBombs, current.suitMisc, current.suitType);
        bool curChozodia = vars.IsAreaCleared(6, current.tanksChozodia, current.beamBombs, current.suitMisc, current.suitType);

        if (!settings["area_clear_on_transition"])
        {
            // Modo Padrao: Split imediato no frame em que o ultimo item/tanque da area e registrado na RAM
            bool oldBrinstar = vars.IsAreaCleared(0, old.tanksBrinstar, old.beamBombs, old.suitMisc, old.suitType);
            bool oldKraid    = vars.IsAreaCleared(1, old.tanksKraid,    old.beamBombs, old.suitMisc, old.suitType);
            bool oldNorfair  = vars.IsAreaCleared(2, old.tanksNorfair,  old.beamBombs, old.suitMisc, old.suitType);
            bool oldRidley   = vars.IsAreaCleared(3, old.tanksRidley,   old.beamBombs, old.suitMisc, old.suitType);
            bool oldTourian  = vars.IsAreaCleared(4, old.tanksTourian,  old.beamBombs, old.suitMisc, old.suitType);
            bool oldCrateria = vars.IsAreaCleared(5, old.tanksCrateria, old.beamBombs, old.suitMisc, old.suitType);
            bool oldChozodia = vars.IsAreaCleared(6, old.tanksChozodia, old.beamBombs, old.suitMisc, old.suitType);

            if (!oldBrinstar && curBrinstar && vars.TrySplit("clear_brinstar", (bool)settings["clear_brinstar"] && settings.SplitEnabled)) return true;
            if (!oldKraid    && curKraid    && vars.TrySplit("clear_kraid", (bool)settings["clear_kraid"] && settings.SplitEnabled))    return true;
            if (!oldNorfair  && curNorfair  && vars.TrySplit("clear_norfair", (bool)settings["clear_norfair"] && settings.SplitEnabled))  return true;
            if (!oldRidley   && curRidley   && vars.TrySplit("clear_ridley", (bool)settings["clear_ridley"] && settings.SplitEnabled))   return true;
            if (!oldTourian  && curTourian  && vars.TrySplit("clear_tourian", (bool)settings["clear_tourian"] && settings.SplitEnabled))  return true;
            if (!oldCrateria && curCrateria && vars.TrySplit("clear_crateria", (bool)settings["clear_crateria"] && settings.SplitEnabled)) return true;
            if (!oldChozodia && curChozodia && vars.TrySplit("clear_chozodia", (bool)settings["clear_chozodia"] && settings.SplitEnabled)) return true;
        }
        else if (current.area != old.area)
        {
            // Modo Opcional: Split na transicao de area (elevador) logo apos limpar 100% da area anterior
            if (old.area == 0 && curBrinstar && vars.TrySplit("clear_brinstar", (bool)settings["clear_brinstar"] && settings.SplitEnabled)) return true;
            if (old.area == 1 && curKraid    && vars.TrySplit("clear_kraid", (bool)settings["clear_kraid"] && settings.SplitEnabled))    return true;
            if (old.area == 2 && curNorfair  && vars.TrySplit("clear_norfair", (bool)settings["clear_norfair"] && settings.SplitEnabled))  return true;
            if (old.area == 3 && curRidley   && vars.TrySplit("clear_ridley", (bool)settings["clear_ridley"] && settings.SplitEnabled))   return true;
            if (old.area == 4 && curTourian  && vars.TrySplit("clear_tourian", (bool)settings["clear_tourian"] && settings.SplitEnabled))  return true;
            if (old.area == 5 && curCrateria && vars.TrySplit("clear_crateria", (bool)settings["clear_crateria"] && settings.SplitEnabled)) return true;
            if (old.area == 6 && curChozodia && vars.TrySplit("clear_chozodia", (bool)settings["clear_chozodia"] && settings.SplitEnabled)) return true;
        }
    }

    return false;
}


isLoading
{
    // RTA: liberar pausa herdada. IGT: manter o valor escrito a partir da RAM.
    return settings["clock_igt"];
}

gameTime
{
    if (!settings["clock_igt"])
        return timer.CurrentTime.RealTime ?? TimeSpan.Zero;

    // No menu/intro, a RAM pode conservar o IGT da tentativa anterior.
    if (current.gameMode < 4 || current.gameMode > 10 || current.demoState != 0)
        return vars.lastGoodIGT;

    uint word = current.igtWord;
    int hours = (int)(word & 0xFFU);
    int minutes = (int)((word >> 8) & 0xFFU);
    int seconds = (int)((word >> 16) & 0xFFU);
    int frames = (int)((word >> 24) & 0xFFU);
    if (hours > 99 || minutes > 59 || seconds > 59 || frames > 59)
        return vars.lastGoodIGT;

    long ticks = ((long)hours * 3600L + minutes * 60L + seconds) * TimeSpan.TicksPerSecond;
    ticks += ((long)frames * TimeSpan.TicksPerSecond + 30L) / 60L;
    vars.lastGoodIGT = TimeSpan.FromTicks(ticks);
    return vars.lastGoodIGT;
}
