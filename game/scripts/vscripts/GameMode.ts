import { reloadable } from "./lib/tstl-utils";
import "./modifiers/modifier_panic";

declare global {
    interface CDOTAGamerules {
        Addon: GameMode;
    }
}

@reloadable
export class GameMode {
    public static Precache(this: void, context: CScriptPrecacheContext) {
        PrecacheUnitByNameSync("npc_dota_hero_tinker", context, undefined);
        PrecacheUnitByNameSync("npc_dota_hero_vengefulspirit", context, undefined);
        PrecacheUnitByNameSync("npc_dota_hero_kunkka", context, undefined);
        PrecacheUnitByNameSync("npc_dota_hero_puck", context, undefined);
        PrecacheUnitByNameSync("npc_dota_hero_skywrath_mage", context, undefined);
        PrecacheUnitByNameSync("npc_dota_hero_shadow_demon", context, undefined);
        PrecacheUnitByNameSync("npc_dota_hero_antimage", context, undefined);
        PrecacheUnitByNameSync("npc_dota_hero_bloodseeker", context, undefined);
        PrecacheUnitByNameSync("npc_dota_hero_enigma", context, undefined);
        PrecacheUnitByNameSync("npc_dota_hero_faceless_void", context, undefined);
        PrecacheUnitByNameSync("npc_dota_hero_pugna", context, undefined);
        PrecacheUnitByNameSync("npc_dota_hero_life_stealer", context, undefined);
        PrecacheUnitByNameSync("npc_dota_hero_enigma", context, undefined);
    }

    public static Activate(this: void) {
        GameRules.Addon = new GameMode();
    }

    constructor() {
        this.configure();
        ListenToGameEvent("game_rules_state_change", () => this.OnStateChange(), undefined);
        ListenToGameEvent("player_connect_full", event => this.OnPlayerConnected(event), undefined)
        ListenToGameEvent("npc_spawned", event => this.OnNpcSpawned(event), undefined);
        ListenToGameEvent("dota_player_killed", event => this.OnPlayerKilled(event), undefined);
    }

    private team0score = 0;
    private team1score = 0;
    private restarting = false;

    private configure(): void {
        GameRules.SetCustomGameTeamMaxPlayers(DOTATeam_t.DOTA_TEAM_GOODGUYS, 5);
        GameRules.SetCustomGameTeamMaxPlayers(DOTATeam_t.DOTA_TEAM_BADGUYS, 5);

        GameRules.GetGameModeEntity().SetCustomGameForceHero("npc_dota_hero_invoker");
        GameRules.GetGameModeEntity().SetDaynightCycleDisabled(true);

        GameRules.SetShowcaseTime(0);
        GameRules.SetHeroSelectionTime(1);
        GameRules.SetStrategyTime(1);

        GameRules.SetHeroRespawnEnabled(false);
    }

    public OnStateChange(): void {
        const state = GameRules.State_Get();

        // Add invoker bot
        if ((IsInToolsMode() || GetMapName() === "training_ground") && state == DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP) {
            Tutorial.AddBot("npc_dota_hero_invoker", "", "", false);
        }

        // Start game once pregame hits
        if (state == DOTA_GameState.DOTA_GAMERULES_STATE_STRATEGY_TIME) {
            Timers.CreateTimer(0.2, () => this.StartGame());
        }
    }

    private StartGame(): void {
        print("Game starting!");

        this.team0score = 0;
        this.team1score = 0;
    }

    // Called on script_reload
    public Reload() {
        print("Script reloaded!");

        // Do some stuff here
    }

    private OnNpcSpawned(event: NpcSpawnedEvent) {
        // After a hero unit spawns, apply modifier_panic for 8 seconds
        const unit = EntIndexToHScript(event.entindex) as CDOTA_BaseNPC; // Cast to npc since this is the 'npc_spawned' event
        if (unit.IsRealHero() && unit.GetLevel() === 1) {
            unit.AddExperience(11055, EDOTA_ModifyXP_Reason.DOTA_ModifyXP_TomeOfKnowledge, false, true)
            unit.GetAbilityByIndex(0)?.SetLevel(1);
            unit.GetAbilityByIndex(1)?.SetLevel(1);
            unit.GetAbilityByIndex(2)?.SetLevel(1);
            unit.GetAbilityByIndex(3)?.SetLevel(1);
        }
    }

    private OnPlayerConnected(event: PlayerConnectFullEvent) {
        print("Player connected with ID: " + event.PlayerID);
        const player = PlayerResource.GetPlayer(event.PlayerID);

        //player?.SetSelectedHero("npc_dota_hero_invoker");
    }

    private OnPlayerKilled(event: DotaPlayerKilledEvent) {
        if (this.restarting)
            return;

        const player = PlayerResource.GetPlayer(event.PlayerID);
        if (!player) {
            print(`Didn't find player with ID: ${event.PlayerID}`);
            return;
        }

        print(`Player ${player.GetPlayerID} from team ${player.GetTeamNumber()} has been killed`);

        const teamIsDead = HeroList.GetAllHeroes()
                                        .filter(hero => hero.GetTeamNumber() === player.GetTeamNumber())
                                        .filter(hero => hero.IsAlive())
                                        .length === 0;

        if (teamIsDead) {
            print(`Team ${player.GetTeamNumber()} lost the round`);

            if (player.GetTeamNumber() === 3) {
                if (GetMapName() != "training_ground")
                    this.team0score++;
                ShowMessage("Radiant wins the round!")
                if (this.team0score == 5)
                    GameRules.MakeTeamLose(3);
            } else {
                if (GetMapName() != "training_ground")
                    this.team1score++;
                ShowMessage("Dire wins the round!")
                if (this.team1score == 5)
                    GameRules.MakeTeamLose(2);
            }

            print("Team 0 score: " + this.team0score);
            print("Team 1 score: " + this.team1score);

            this.RestartRound();
        }

    }

    private RestartRound() {
        print("Restarting round...");
        this.restarting = true;

        const timer = GetMapName() === "training_ground" ? 0.1 : 3

        Timers.CreateTimer(timer,
        () => {
            ShowMessage(`RADIANT ${this.team0score} - ${this.team1score} DIRE`)

            HeroList.GetAllHeroes().forEach(hero => {
                hero.GetAdditionalOwnedUnits().forEach( unit => {
                    print(unit.GetName());
                    unit.ForceKill(false);
                } );
                hero.RespawnHero(false, false);
                hero.Purge(true, true, false, true, true);
                for (let i = 0; i <= 25; i++) {
                    hero.GetAbilityByIndex(i)?.EndCooldown();
                }
            });
            this.restarting = false;
        });
    }
}
