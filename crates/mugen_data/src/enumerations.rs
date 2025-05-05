use std::slice::Iter;

use enumflags2::bitflags;

#[derive(Copy, Clone, PartialEq)]
pub enum Axis { None, X, Y }

#[derive(Copy, Clone, PartialEq)]
pub enum ScreenShotFormat { None, Jpg, Bmp, Png }

#[derive(Copy, Clone, PartialEq)]
pub enum ScreenType { None, Storyboard, Title, Select, Versus, Combat, Replay, Options }

#[derive(Copy, Clone, PartialEq)]
pub enum FadeDirection { None, In, Out }

#[derive(Copy, Clone, PartialEq)]
pub enum Assertion { None, Intro, Invisible, RoundNotOver, NoBarDisplay, NoBackground, NoForeground, NoStandGuard, NoAirGuard, NoCrouchGuard, NoAutoturn, NoJuggleCheck, NoKOSound, NoKOSlow, NoShadow, GlobalNoShadow, NoMusic, NoWalk, TimerFreeze, Unguardable, NoKO }

#[derive(Copy, Clone, PartialEq)]
pub enum BindToTargetPostion { None, Foot, Mid, Head }

#[derive(Copy, Clone, PartialEq)]
pub enum Victory { None, Normal, Special, Hyper, NormalThrow, Cheese, Time, Suicude, TeamKill }

#[derive(Copy, Clone, PartialEq)]
pub enum TeamSide { None, Left, Right }

#[derive(Copy, Clone, PartialEq)]
pub enum TeamMode { None, Single, Simul, Turns }

#[derive(Copy, Clone, PartialEq)]
pub enum GameSpeed { Normal, Slow }

#[derive(Copy, Clone, PartialEq)]
pub enum DrawMode { None, Normal, Font, OutlinedRectangle, FilledRectangle, Lines }

#[derive(Copy, Clone, PartialEq)]
pub enum CollisionType { None, PlayerPush, CharacterHit, ProjectileHit, ProjectileCollision }

#[bitflags]
#[repr(u8)]
#[derive(Copy, Clone, PartialEq)]
pub enum AttackStateType { Standing = 1, Crouching = 2, Air = 4 }

#[derive(Copy, Clone, PartialEq)]
pub enum AttackPower { None = 0, Normal, Special, Hyper, All }

#[derive(Copy, Clone, PartialEq)]
pub enum AttackClass { None = 0, Normal, Throw, Projectile, All }

#[derive(Copy, Clone, PartialEq)]
pub enum HitFlagCombo { No = 0, Yes, DontCare }

#[bitflags]
#[repr(u8)]
#[derive(Copy, Clone, PartialEq)]
pub enum AffectTeam { Enemy = 1, Friendly = 2 }

#[derive(Copy, Clone, PartialEq)]
pub enum HitAnimationType { None = 0, Light, Medium, Hard, Back, Up, DiagUp }

#[derive(Copy, Clone, PartialEq)]
pub enum PriorityType { None, Hit, Dodge, Miss }

#[derive(Copy, Clone, PartialEq)]
pub enum AttackEffect { None = 0, High, Low, Trip }

#[derive(Copy, Clone, PartialEq)]
pub enum HelperType { Normal = 0, Player, Projectile }

#[derive(Copy, Clone, PartialEq)]
pub enum PositionType { None = 0, P1, P2, Front, Back, Left, Right }

#[derive(Copy, Clone, PartialEq)]
pub enum ClsnType { None, Type1Attack, Type2Normal }

impl Default for ClsnType {
    fn default() -> Self { ClsnType::None }
}

#[derive(Copy, Clone, PartialEq)]
pub enum Facing { Left, Right }

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum BlendType { None, Add, Subtract }

impl Default for BlendType {
    fn default() -> Self { BlendType::None }
}

#[derive(Copy, Clone, Debug, PartialEq)]
pub enum BackgroundLayer { Front, Back }

#[derive(Copy, Clone, PartialEq)]
pub enum NumberType { None, Int, Float }

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum HorizontalAlign {
    Left,
    Center,
    Right,
}

impl Default for HorizontalAlign {
    fn default() -> Self {
        Self::Left
    }
}

#[bitflags]
#[repr(u8)]
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum PrintJustification { Left = 1, Right = 2, Center = 4 }

impl Default for PrintJustification {
    fn default() -> Self { PrintJustification::Center }
}

impl From<i16> for PrintJustification {
    fn from(just: i16) -> PrintJustification {
        let mut justification = PrintJustification::Center;

        if just > 0 {
            justification = PrintJustification::Left
        } else if just < 0 {
            justification = PrintJustification::Right;
        }

        return justification;
    }
}

impl From<PrintJustification> for HorizontalAlign {
    fn from(justification: PrintJustification) -> HorizontalAlign {
        match justification {
            PrintJustification::Center => HorizontalAlign::Center,
            PrintJustification::Left => HorizontalAlign::Left,
            PrintJustification::Right => HorizontalAlign::Right,
        }
    }
}

#[bitflags]
#[repr(u16)]
#[derive(Copy, Clone, PartialEq)]
pub enum PlayerButton { Up = 1, Down = 2, Left = 4, Right = 8, A = 16, B = 32, C = 64, X = 128, Y = 256, Z = 512, Taunt = 1024, Pause = 2048 }

#[bitflags]
#[repr(u16)]
#[derive(Copy, Clone, PartialEq)]
pub enum SystemButton {
    Pause = 1,
    PauseStep = 2,
    Quit = 4,
    DebugDraw = 8,
    FullLifeAndPower = 16,
    TestCheat = 32,
    TakeScreenshot = 64,
    SetPlayer1LifeToZero = 128,
    SetPlayer2LifeToZero = 256,
    SetBothPlayersLifeToOne = 512,
    TimeOver = 1024
}

#[derive(Copy, Clone, PartialEq)]
pub enum RoundState { None, PreIntro, Intro, Fight, PreOver, Over }

#[derive(Copy, Clone, PartialEq)]
pub enum IntroState { None, Running, RoundNumber, Fight }

#[derive(Copy, Clone, PartialEq)]
pub enum CommandDirection { None = 0, B, DB, D, DF, F, UF, U, UB, B4Way, U4Way, F4Way, D4Way }

#[derive(Copy, Clone, PartialEq)]
pub enum StateType { None, Unchanged, Standing, Crouching, Airborne, Prone }

#[derive(Copy, Clone, PartialEq)]
pub enum MoveType { None, Idle, Attack, BeingHit, Unchanged }

#[derive(Copy, Clone, PartialEq)]
pub enum Physics { None, Unchanged, Standing, Crouching, Airborne }

#[derive(Copy, Clone, PartialEq)]
pub enum PlayerControl { Unchanged, InControl, NoControl }

#[derive(Copy, Clone, PartialEq)]
pub enum PlayerMode { Human, Ai }

#[bitflags]
#[repr(u8)]
#[derive(Copy, Clone, PartialEq)]
pub enum CommandButton { A = 1, B = 2, C = 4, X = 8, Y = 16, Z = 32, Taunt = 64 }

#[bitflags]
#[repr(u8)]
#[derive(Copy, Clone, PartialEq)]
pub enum ForceFeedbackType { Sine = 1, Square = 2 }

#[derive(Copy, Clone, PartialEq)]
pub enum ButtonState { Up, Down, Pressed, Released }

#[derive(Copy, Clone, PartialEq)]
pub enum ProjectileDataType { None, Hit, Guarded, Cancel }

#[derive(Copy, Clone, PartialEq)]
pub enum PauseState { Unpaused, Paused, PauseStep }

#[repr(usize)]
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum MainMenuOption { Arcade = 0, Versus = 1, TeamArcade = 2, TeamVersus = 3, TeamCoop = 4, Survival = 5, SurvivalCoop = 6, Training = 7, Watch = 8, Options = 9, Quit = 10 }

impl MainMenuOption {
    pub fn iter() -> Iter<'static, MainMenuOption> {
        static VALUES: [MainMenuOption; 11] = [
            MainMenuOption::Arcade,
            MainMenuOption::Versus,
            MainMenuOption::TeamArcade,
            MainMenuOption::TeamVersus,
            MainMenuOption::TeamCoop,
            MainMenuOption::Survival,
            MainMenuOption::SurvivalCoop,
            MainMenuOption::Training,
            MainMenuOption::Watch,
            MainMenuOption::Options,
            MainMenuOption::Quit
        ];

        VALUES.iter()
    }
}

#[derive(Copy, Clone, PartialEq)]
pub enum EntityUpdateOrder { Character, Projectile, Explod }

#[derive(Copy, Clone, PartialEq)]
pub enum ProjectileState { Normal, Removing, Canceling, Kill }

#[derive(Copy, Clone, PartialEq, Debug)]
pub enum PlayerSelectType { Profile, Random }

#[derive(Copy, Clone, PartialEq)]
pub enum CursorDirection { Up, Down, Left, Right }

#[derive(Copy, Clone, PartialEq)]
pub enum ElementType { None, Static, Animation, Text }

#[derive(Debug, Clone, Eq, PartialEq, Hash)]
pub enum CombatMode { None, Arcade, Versus, TeamArcade, TeamVersus, TeamCoop, Survival, SurvivalCoop, Training }

#[bitflags]
#[repr(u16)]
#[derive(Copy, Clone, Debug, PartialEq)]
pub enum SpriteEffects {
    FlipHorizontally = 1,
    FlipVertically = 2
}
