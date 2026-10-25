// Metroid Fusion JPN - revisao de teste 2 (2026-10-25).
// Alvo: ROM japonesa original (AMTJ), BizHawk com core mGBA.
// Auto-Start: confirmacao de nova partida 3 -> 5, observada no log do usuario.
// A rota separada de escolha Easy/Normal/Hard ainda nao consta desse log.
// Splits de equipamentos usam a aquisicao da habilidade, nao o ultimo hit.
// RTA e o padrao. IGT opcional acompanha o relogio nativo do save (64 subframes).
// Mapa RAM: biosp4rk/mf-zm-info, commit 2a0bc87ab1dcc1d61adb9c5f3ac7329ddb42939c,
// json/mf/ram.json, campos J; Equipment/InGameTimer em json/mf/structs.json.
// Este arquivo depende do mesmo emu-help-v2 ja usado pelo Zero Mission.
// Missiles e Morph Ball confirmados no emulador pelo usuario na revisao 1.
// Auto-Start validado por replay do log; ainda requer teste ao vivo.

state("LiveSplit") {}

startup
{
    refreshRate = 120;
    vars.observationPrimed = false;
    vars.completedSplits = new HashSet<string>();
    vars.pendingSplit = "";
    vars.lastGoodIGT = TimeSpan.Zero;
    vars.lastMenuFrame = -1;
    vars.menuTraceFrames = 0;
    vars.previousMenuLine = "";
    vars.pendingAutoStart = false;
    timer.IsGameTimePaused = false;

    settings.Add("general", true, "Geral - Fusion JPN");
    settings.Add("auto_start", true, "Auto-Start ao confirmar nova partida (caminho registrado)", "general");
    settings.SetToolTip("auto_start", "Calibrado para a confirmacao de inicio capturada no teste 1. Uma rota separada pela escolha de dificuldade ainda precisa de registro. Desmarque para iniciar manualmente.");
    settings.Add("clock_igt", false, "Game Time usa IGT nativo (desmarcado = acompanha RTA)", "general");
    settings.SetToolTip("clock_igt", "IGT absoluto do arquivo de save. Pode voltar ao morrer ou carregar um save. Nao e o conversor NSO e nao e RTA sem loads.");
    settings.Add("auto_reset", false, "Auto-Reset ao voltar do jogo para o titulo/reset", "general");
    settings.Add("trace_menu", true, "Registrar o menu JPN para validar o Auto-Start", "general");
    settings.Add("debug_verbose", false, "Log detalhado de eventos durante o jogo", "general");
    settings.Add("items", true, "Habilidades e downloads (aquisicao / absorcao)");
    settings.Add("item_missiles", true, "Missiles (download)", "items");
    settings.Add("item_morph", true, "Arachnus / Morph Ball (absorcao do Core-X)", "items");
    settings.Add("item_charge", true, "Charge Beam (absorcao do Core-X)", "items");
    settings.Add("item_bombs", true, "Bombs (download)", "items");
    settings.Add("item_high_jump", true, "Zazabi / Hi-Jump", "items");
    settings.Add("item_speed", true, "Serris / Speed Booster", "items");
    settings.Add("item_supers", true, "Super Missiles (download)", "items");
    settings.Add("item_varia", true, "Varia Suit", "items");
    settings.Add("item_ice_missiles", true, "Ice Missiles (download)", "items");
    settings.Add("item_wide", true, "Wide Beam", "items");
    settings.Add("item_power_bombs", true, "Power Bombs (download)", "items");
    settings.Add("item_space_jump", true, "Yakuza / Space Jump", "items");
    settings.Add("item_plasma", true, "Plasma Beam", "items");
    settings.Add("item_gravity", true, "Nightmare / Gravity Suit", "items");
    settings.Add("item_diffusion", true, "Diffusion Missiles (download)", "items");
    settings.Add("item_wave", true, "B.O.X. 2 / Wave Beam", "items");
    settings.Add("item_screw", true, "Ridley / Screw Attack", "items");
    settings.Add("item_ice", true, "Ice Beam (absorcao antes do Omega)", "items");
    settings.Add("events", true, "Eventos adicionais (opcionais)");
    settings.Add("event_hornoad", false, "Primeiro Hornoad (evento 2)", "events");
    settings.Add("event_stabilizers", false, "Estabilizadores ligados (evento 16)", "events");
    settings.Add("event_water", false, "Agua abaixada em AQA (evento 32)", "events");
    settings.Add("event_box1", false, "B.O.X. 1 derrotado (evento 40)", "events");
    settings.Add("event_cooling", false, "Cooling Unit operacional (evento 61)", "events");
    settings.Add("event_animals", false, "Animais liberados (evento 63)", "events");
    settings.Add("event_power", false, "Energia auxiliar ligada (evento 74)", "events");
    settings.Add("event_sax", false, "SA-X derrotado (evento 102)", "events");
    settings.Add("event_orbit", false, "Mudanca de orbita (evento 103)", "events");
    settings.Add("event_omega", false, "Omega Metroid derrotado (evento 108)", "events");
    settings.Add("event_escape", true, "Final: fuga na nave (evento 109)", "events");
    settings.Add("security", false, "Security Levels (opcionais)");
    settings.Add("security_1", false, "Security Level 1", "security");
    settings.Add("security_2", false, "Security Level 2", "security");
    settings.Add("security_3", false, "Security Level 3", "security");
    settings.Add("security_4", false, "Security Level 4", "security");
    settings.Add("area_entries", false, "Primeira entrada em cada setor (opcional)");
    settings.Add("area_0", false, "Main Deck", "area_entries");
    settings.Add("area_1", false, "Sector 1 (SRX)", "area_entries");
    settings.Add("area_2", false, "Sector 2 (TRO)", "area_entries");
    settings.Add("area_3", false, "Sector 3 (PYR)", "area_entries");
    settings.Add("area_4", false, "Sector 4 (AQA)", "area_entries");
    settings.Add("area_5", false, "Sector 5 (ARC)", "area_entries");
    settings.Add("area_6", false, "Sector 6 (NOC)", "area_entries");
    settings.Add("tanks", false, "Tanques de expansao (opcionais; um split por tanque)");
    settings.Add("tank_energy", false, "Cada Energy Tank", "tanks");
    settings.Add("tank_missiles", false, "Cada Missile Tank", "tanks");
    settings.Add("tank_pbs", false, "Cada Power Bomb Tank", "tanks");

    vars.logPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "MetroidFusion_JPN_teste2.log");
    vars.Log = (Action<string>)(msg =>
    {
        try
        {
            File.AppendAllText(vars.logPath, "[" + DateTime.Now.ToString("HH:mm:ss.fff") + "] " + msg + "\r\n");
            print("[Fusion JPN] " + msg);
        }
        catch {}
    });
    vars.Log("Fusion JPN teste 2: AUTO-START no caminho registrado 3->5; RAM japonesa; IGT opcional.");
    vars.BitChanged = (Func<byte, byte, int, bool>)((before, after, bit) =>
    {
        int mask = 1 << bit;
        return (before & mask) == 0 && (after & mask) != 0;
    });
    vars.TrySplit = (Func<string, bool, bool>)((key, enabled) =>
    {
        if (!enabled || vars.completedSplits.Contains(key))
            return false;
        vars.completedSplits.Add(key);
        vars.pendingSplit = key;
        return true;
    });
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
        vars.Helper.Load = (Func<dynamic, bool>)(emu =>
        {
            vars.observationPrimed = false;
            vars.lastMenuFrame = -1;
            vars.menuTraceFrames = 0;
            vars.previousMenuLine = "";
            vars.pendingAutoStart = false;
            emu.Make<short>("gameMode", 0x03000C12);
            emu.Make<short>("subGameMode1", 0x03000C14);
            emu.Make<byte>("subGameMode2", 0x03000C16);
            emu.Make<byte>("eventCounter", 0x03000BBB);
            emu.Make<byte>("area", 0x03000032);
            emu.Make<byte>("room", 0x03000033);
            emu.Make<byte>("demoState", 0x03001276);
            emu.Make<byte>("difficulty", 0x03000020);
            emu.Make<byte>("language", 0x03000014);
            emu.Make<ushort>("changedInput", 0x03001220);
            emu.Make<ushort>("frameCounter", 0x03000002);
            emu.Make<uint>("igtWord", 0x0300013C);
            emu.Make<ushort>("maxEnergy", 0x03001346);
            emu.Make<ushort>("maxMissiles", 0x0300134A);
            emu.Make<byte>("maxPowerBombs", 0x0300134D);
            emu.Make<byte>("beamStatus", 0x0300134E);
            emu.Make<byte>("weaponsStatus", 0x0300134F);
            emu.Make<byte>("suitMiscStatus", 0x03001350);
            emu.Make<byte>("securityLevel", 0x03001351);
            emu.Make<ushort>("fileMenuStage", 0x030014C2);
            emu.Make<byte>("fileAnimation", 0x030014C4);
            emu.Make<byte>("fileSlot", 0x030014C5);
            emu.Make<byte>("fileOption", 0x030014C6);
            emu.Make<byte>("fileDifficulty", 0x030014CF);
            emu.Make<uint>("menu0", 0x030014B8);
            emu.Make<uint>("menu1", 0x030014BC);
            emu.Make<uint>("menu2", 0x030014C0);
            emu.Make<uint>("menu3", 0x030014C4);
            emu.Make<uint>("menu4", 0x030014C8);
            emu.Make<uint>("menu5", 0x030014CC);
            emu.Make<uint>("menu6", 0x030014D0);
            emu.Make<uint>("menu7", 0x030014D4);
            emu.Make<uint>("menu8", 0x030014D8);
            emu.Make<uint>("menu9", 0x030014DC);
            emu.Make<uint>("menu10", 0x030014E0);
            emu.Make<uint>("menu11", 0x030014E4);
            emu.Make<uint>("menu12", 0x030014E8);
            emu.Make<uint>("menu13", 0x030014EC);
            emu.Make<uint>("menu14", 0x030014F0);
            emu.Make<uint>("menu15", 0x030014F4);
            emu.Make<uint>("menu16", 0x030014F8);
            emu.Make<uint>("menu17", 0x030014FC);
            emu.Make<uint>("menu18", 0x03001500);
            emu.Make<uint>("menu19", 0x03001504);
            emu.Make<uint>("menu20", 0x03001508);
            emu.Make<uint>("menu21", 0x0300150C);
            emu.Make<uint>("menu22", 0x03001510);
            emu.Make<uint>("menu23", 0x03001514);
            emu.Make<uint>("menu24", 0x03001518);
            emu.Make<uint>("menu25", 0x0300151C);
            emu.Make<uint>("menu26", 0x03001520);
            emu.Make<uint>("menu27", 0x03001524);
            emu.Make<uint>("menu28", 0x03001528);
            emu.Make<uint>("menu29", 0x0300152C);
            emu.Make<uint>("menu30", 0x03001530);
            emu.Make<uint>("menu31", 0x03001534);
            vars.Log("RAM JPN conectada: modo=03000C12 evento=03000BBB equipamento=03001344 IGT=0300013C.");
            return true;
        });
    }
}

init
{
    vars.Log("Aguardando emulador: use somente o ASL do Fusion JPN neste teste.");
}

onStart
{
    vars.completedSplits.Clear();
    vars.pendingSplit = "";
    vars.lastGoodIGT = TimeSpan.Zero;
    timer.IsGameTimePaused = false;
    vars.Log("START " + ((bool)vars.pendingAutoStart ? "automatico" : "manual")
        + ": RTA=" + timer.CurrentTime.RealTime + " clock_igt=" + settings["clock_igt"]);
    vars.pendingAutoStart = false;
    if (!string.IsNullOrEmpty((string)vars.previousMenuLine))
        vars.Log("MENU antes do START: " + vars.previousMenuLine);
}

onSplit
{
    if (!string.IsNullOrEmpty((string)vars.pendingSplit))
        vars.Log("SPLIT: " + vars.pendingSplit + " RTA=" + timer.CurrentTime.RealTime);
    vars.pendingSplit = "";
}

onReset
{
    vars.completedSplits.Clear();
    vars.pendingSplit = "";
    vars.lastGoodIGT = TimeSpan.Zero;
    vars.pendingAutoStart = false;
    timer.IsGameTimePaused = false;
    vars.Log("RESET da tentativa.");
}

shutdown
{
    timer.IsGameTimePaused = false;
}

update
{
    if (!vars.helperLoaded)
        return false;
    var values = (IDictionary<string, object>)current;
    if (!values.ContainsKey("gameMode") || !values.ContainsKey("suitMiscStatus")
        || !values.ContainsKey("eventCounter") || !values.ContainsKey("menu31"))
        return false;
    if (current.gameMode < 0 || current.gameMode > 14 || current.eventCounter > 110)
        return false;

    if (!vars.observationPrimed)
    {
        vars.observationPrimed = true;
        vars.Log("Primeira amostra ignorada para evitar split ao conectar em um save existente.");
        return false;
    }

    if (settings["trace_menu"] && current.gameMode == 7 && current.subGameMode2 == 0
        && current.frameCounter != vars.lastMenuFrame)
    {
        vars.lastMenuFrame = (int)current.frameCounter;
        uint[] words = new uint[] {
            current.menu0, current.menu1, current.menu2, current.menu3, current.menu4, current.menu5, current.menu6, current.menu7, current.menu8, current.menu9, current.menu10, current.menu11, current.menu12, current.menu13, current.menu14, current.menu15, current.menu16, current.menu17, current.menu18, current.menu19, current.menu20, current.menu21, current.menu22, current.menu23, current.menu24, current.menu25, current.menu26, current.menu27, current.menu28, current.menu29, current.menu30, current.menu31
        };
        string raw = "";
        foreach (uint word in words)
            raw += word.ToString("X8") + " ";
        string line = string.Format("MENU frame={0} GM={1} SGM={2}/{3} input=0x{4:X4} diff={5} lang={6} IWRAM[030014B8..03001537]={7}",
            current.frameCounter, current.gameMode, current.subGameMode1, current.subGameMode2,
            current.changedInput, current.difficulty, current.language, raw);
        if (current.changedInput != 0 || old.subGameMode1 != current.subGameMode1 || old.gameMode != current.gameMode
            || old.fileMenuStage != current.fileMenuStage || old.fileDifficulty != current.fileDifficulty)
        {
            if (!string.IsNullOrEmpty((string)vars.previousMenuLine))
                vars.Log("MENU anterior ao input: " + vars.previousMenuLine);
            vars.menuTraceFrames = 8;
        }
        if (vars.menuTraceFrames > 0)
        {
            vars.Log(line);
            vars.menuTraceFrames--;
        }
        vars.previousMenuLine = line;
    }

    if (settings["debug_verbose"] && (old.eventCounter != current.eventCounter
        || old.gameMode != current.gameMode || old.subGameMode1 != current.subGameMode1))
        vars.Log(string.Format("ESTADO GM={0}->{1} SGM1={2}->{3} evento={4}->{5} area={6} sala={7} IGT=0x{8:X8}",
            old.gameMode, current.gameMode, old.subGameMode1, current.subGameMode1,
            old.eventCounter, current.eventCounter, current.area, current.room, (uint)current.igtWord));
    return true;
}

start
{
    if (!settings["auto_start"] || !vars.helperLoaded || !vars.observationPrimed)
        return false;
    // The recorded A press changes 3 -> 5 immediately; fade-out starts 43
    // emulated frames later. Use the accepted menu transition, not the fade
    // or a one-frame input pulse that LiveSplit might miss between polls.
    bool inMenu = current.gameMode == 7 && current.subGameMode1 == 3
        && current.subGameMode2 == 0 && current.demoState == 0;
    bool wasInMenu = old.gameMode == 7 && old.subGameMode1 == 3
        && old.subGameMode2 == 0 && old.demoState == 0;
    bool sameFile = current.fileSlot < 3 && old.fileSlot == current.fileSlot;
    bool newGameConfirmed = old.fileMenuStage == 3 && current.fileMenuStage == 5
        && old.fileOption == 0 && current.fileOption == 0
        && old.fileAnimation == 0 && current.fileAnimation <= 8
        && current.fileDifficulty <= 2;
    if (inMenu && wasInMenu && sameFile && newGameConfirmed)
    {
        vars.pendingAutoStart = true;
        vars.Log("AUTO-START: confirmacao JPN 3->5; frame=" + current.frameCounter
            + " arquivo=" + current.fileSlot + " dificuldade=" + current.fileDifficulty);
        return true;
    }
    return false;
}

reset
{
    if (!settings["auto_reset"])
        return false;
    bool wasPlaying = old.gameMode == 1 || old.gameMode == 3 || old.gameMode == 4
        || old.gameMode == 5 || old.gameMode == 8 || old.gameMode == 9;
    return wasPlaying && (current.gameMode == 0 || current.gameMode == 2);
}

split
{
    if (!settings.SplitEnabled || !vars.observationPrimed || current.demoState != 0)
        return false;
    // Somente jogo/mapa/cutscenes/ending; menus e carregamento inicial nao splitam.
    bool active = current.gameMode == 1 || current.gameMode == 3 || current.gameMode == 4
        || current.gameMode == 5 || current.gameMode == 9;
    bool wasActive = old.gameMode == 1 || old.gameMode == 3 || old.gameMode == 4
        || old.gameMode == 5 || old.gameMode == 9;
    if (!active || !wasActive)
        return false;

    // O contador e sequencial, nao um bitfield. Nao splitar checkpoints pulados.
    if (current.eventCounter > old.eventCounter && current.eventCounter == 109
        && vars.TrySplit("event_escape", (bool)settings["event_escape"]))
        return true;
    if (vars.BitChanged((byte)old.weaponsStatus, (byte)current.weaponsStatus, 0)
        && vars.TrySplit("item_missiles", (bool)settings["item_missiles"]))
        return true;
    if (vars.BitChanged((byte)old.suitMiscStatus, (byte)current.suitMiscStatus, 6)
        && vars.TrySplit("item_morph", (bool)settings["item_morph"]))
        return true;
    if (vars.BitChanged((byte)old.beamStatus, (byte)current.beamStatus, 0)
        && vars.TrySplit("item_charge", (bool)settings["item_charge"]))
        return true;
    if (vars.BitChanged((byte)old.weaponsStatus, (byte)current.weaponsStatus, 4)
        && vars.TrySplit("item_bombs", (bool)settings["item_bombs"]))
        return true;
    if (vars.BitChanged((byte)old.suitMiscStatus, (byte)current.suitMiscStatus, 0)
        && vars.TrySplit("item_high_jump", (bool)settings["item_high_jump"]))
        return true;
    if (vars.BitChanged((byte)old.suitMiscStatus, (byte)current.suitMiscStatus, 1)
        && vars.TrySplit("item_speed", (bool)settings["item_speed"]))
        return true;
    if (vars.BitChanged((byte)old.weaponsStatus, (byte)current.weaponsStatus, 1)
        && vars.TrySplit("item_supers", (bool)settings["item_supers"]))
        return true;
    if (vars.BitChanged((byte)old.suitMiscStatus, (byte)current.suitMiscStatus, 4)
        && vars.TrySplit("item_varia", (bool)settings["item_varia"]))
        return true;
    if (vars.BitChanged((byte)old.weaponsStatus, (byte)current.weaponsStatus, 2)
        && vars.TrySplit("item_ice_missiles", (bool)settings["item_ice_missiles"]))
        return true;
    if (vars.BitChanged((byte)old.beamStatus, (byte)current.beamStatus, 1)
        && vars.TrySplit("item_wide", (bool)settings["item_wide"]))
        return true;
    if (vars.BitChanged((byte)old.weaponsStatus, (byte)current.weaponsStatus, 5)
        && vars.TrySplit("item_power_bombs", (bool)settings["item_power_bombs"]))
        return true;
    if (vars.BitChanged((byte)old.suitMiscStatus, (byte)current.suitMiscStatus, 2)
        && vars.TrySplit("item_space_jump", (bool)settings["item_space_jump"]))
        return true;
    if (vars.BitChanged((byte)old.beamStatus, (byte)current.beamStatus, 2)
        && vars.TrySplit("item_plasma", (bool)settings["item_plasma"]))
        return true;
    if (vars.BitChanged((byte)old.suitMiscStatus, (byte)current.suitMiscStatus, 5)
        && vars.TrySplit("item_gravity", (bool)settings["item_gravity"]))
        return true;
    if (vars.BitChanged((byte)old.weaponsStatus, (byte)current.weaponsStatus, 3)
        && vars.TrySplit("item_diffusion", (bool)settings["item_diffusion"]))
        return true;
    if (vars.BitChanged((byte)old.beamStatus, (byte)current.beamStatus, 3)
        && vars.TrySplit("item_wave", (bool)settings["item_wave"]))
        return true;
    if (vars.BitChanged((byte)old.suitMiscStatus, (byte)current.suitMiscStatus, 3)
        && vars.TrySplit("item_screw", (bool)settings["item_screw"]))
        return true;
    if (vars.BitChanged((byte)old.beamStatus, (byte)current.beamStatus, 4)
        && vars.TrySplit("item_ice", (bool)settings["item_ice"]))
        return true;
    if (current.eventCounter > old.eventCounter)
    {
        if (current.eventCounter == 2 && vars.TrySplit("event_hornoad", (bool)settings["event_hornoad"])) return true;
        if (current.eventCounter == 16 && vars.TrySplit("event_stabilizers", (bool)settings["event_stabilizers"])) return true;
        if (current.eventCounter == 32 && vars.TrySplit("event_water", (bool)settings["event_water"])) return true;
        if (current.eventCounter == 40 && vars.TrySplit("event_box1", (bool)settings["event_box1"])) return true;
        if (current.eventCounter == 61 && vars.TrySplit("event_cooling", (bool)settings["event_cooling"])) return true;
        if (current.eventCounter == 63 && vars.TrySplit("event_animals", (bool)settings["event_animals"])) return true;
        if (current.eventCounter == 74 && vars.TrySplit("event_power", (bool)settings["event_power"])) return true;
        if (current.eventCounter == 102 && vars.TrySplit("event_sax", (bool)settings["event_sax"])) return true;
        if (current.eventCounter == 103 && vars.TrySplit("event_orbit", (bool)settings["event_orbit"])) return true;
        if (current.eventCounter == 108 && vars.TrySplit("event_omega", (bool)settings["event_omega"])) return true;
    }
    if (current.securityLevel > old.securityLevel && current.securityLevel <= 4)
    {
        string key = "security_" + current.securityLevel;
        if (vars.TrySplit(key, (bool)settings[key])) return true;
    }
    if (old.area != current.area && current.area <= 6)
    {
        string key = "area_" + current.area;
        if (vars.TrySplit(key, (bool)settings[key])) return true;
    }

    // Downloads ja possuem checkpoint de habilidade. Nao duplica com tanque.
    if (current.maxEnergy > old.maxEnergy && old.maxEnergy >= 99
        && vars.TrySplit("energy_" + current.maxEnergy, (bool)settings["tank_energy"]))
        return true;
    if (current.weaponsStatus == old.weaponsStatus && current.maxMissiles > old.maxMissiles
        && old.maxMissiles > 0 && vars.TrySplit("missile_tank_" + current.maxMissiles, (bool)settings["tank_missiles"]))
        return true;
    if (current.weaponsStatus == old.weaponsStatus && current.maxPowerBombs > old.maxPowerBombs
        && old.maxPowerBombs > 0 && vars.TrySplit("pb_tank_" + current.maxPowerBombs, (bool)settings["tank_pbs"]))
        return true;
    return false;
}

isLoading
{
    // IGT absoluto: desabilita interpolacao. RTA: libera o Game Time.
    return settings["clock_igt"];
}

gameTime
{
    if (!settings["clock_igt"])
        return timer.CurrentTime.RealTime ?? TimeSpan.Zero;
    // A RAM do IGT pode conter o tempo anterior durante menus/intro.
    if (current.demoState != 0 || current.gameMode == 0 || current.gameMode == 2
        || current.gameMode == 6 || current.gameMode == 7 || current.gameMode == 12)
        return vars.lastGoodIGT;
    bool inRun = current.gameMode == 1 || current.gameMode == 3 || current.gameMode == 4
        || current.gameMode == 5 || current.gameMode == 8 || current.gameMode == 9
        || current.gameMode == 11;
    if (!inRun)
        return vars.lastGoodIGT;

    uint word = current.igtWord;
    int hours = (int)(word & 0xFFU);
    int minutes = (int)((word >> 8) & 0xFFU);
    int seconds = (int)((word >> 16) & 0xFFU);
    int frames = (int)((word >> 24) & 0xFFU);
    if (hours > 99 || minutes > 59 || seconds > 59 || frames > 63)
        return vars.lastGoodIGT;
    long ticks = ((long)hours * 3600L + minutes * 60L + seconds) * TimeSpan.TicksPerSecond;
    ticks += ((long)frames * TimeSpan.TicksPerSecond + 32L) / 64L;
    vars.lastGoodIGT = TimeSpan.FromTicks(ticks);
    return vars.lastGoodIGT;
}
