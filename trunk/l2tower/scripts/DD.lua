-- Different classes have a bit different combat logic.
-- So this script will decide wich Nuker to user for current class and allow you to create easy preconfigured setups

UseMassSkills = true;

AttackNewTargetDelay = 100; --ms

Mage_UseBTM = true;


SummonServitorSkillId = 11257; -- 11257 - Saber Tooth Cougar; 11258 - for Summon Soul Reaper; 11256 - for Summon Armored Bear
Sum_UseManaRecharge = true;
Sum_UseNuke = true;
Sum_SummonCube = true;
Sum_SummonSoulshotsEnabled = true;
Sum_RequiredSummonsCount = 2; -- 0 to disable summon

dofile(package.path .. "..\\..\\scripts\\nuker\\NukerBase.lua");