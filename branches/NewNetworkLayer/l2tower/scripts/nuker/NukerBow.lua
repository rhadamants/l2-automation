-- Simple replacement of feature L2Tower "Nuke Attack" for Bow
if GetMe():GetClass() ~= 142 then
	ShowToClient("ERROR","You are not Yul Archer, so this script is not for you");
	return;
end

BuffDebug = false
--AttackNewTargetDelay = 100;--ms

Debuff = 10801;
SkillId_Aura = 1933; -- Аура Эура
Stances = { -- first one is preferred to use in case user will not trigger another one
	10759, -- Стойка Снайпера
	10758, -- Стойка Беглого Огня
	10757, -- Осадная Огневая Стойка
}
RangeAttackSkills = {
			10762, -- Скоростной Выстрел
			10763, -- Точечный Удар
			--10760, -- Выстрел Торнадо
		};

MeleeAttackSkills = {
			10761, -- Удар Луком
			10774, -- Отступление
		};
MassAttackSkills = UseMassSkills and {
		    10760, -- Выстрел Торнадо
			10771, -- Туча Стрел
			10772, -- Проливной Дождь Стрел
		} or {};
RangedAttackCounter = 0;


function InitDebuffSkill()
	DebuffSkill = GetSkills():FindById(Debuff)
	return DebuffSkill ~= nil
end

function Nuke(target)  
	local dist = target:GetDistance();
	if 
		InitDebuffSkill() and DebuffSkill:CanBeUsed() and DebuffSkill:GetReuse() == 0 and CastSkill(Debuff)
		or target:GetHp() > 1000 and dist < 40 and CastOneByOneList(MeleeAttackSkills, 0)
		or dist < 1100 and MobsAroundTarget(target, 150) > 1 and CastOneByList(MassAttackSkills)
		or target:GetHp() > 2000 and dist < 1100 and CastOneByOneList(RangeAttackSkills, RangedAttackCounter)
	then
		return
	end
end

function CheckStance(me)
	for _,skillId_stance in pairs(Stances) do
		if me:GotBuff(skillId_stance) then
			return;
		end
	end
	Sleep(500)
	CastSkill(Stances[1]);
	--dprint("going to cast skill %s", Stances[1])
	Sleep(1000)
end

repeat
    if not IsPaused() then
		local target = GetTarget();
		local me = GetMe();

		-- aura
		if SkillId_Aura and not GetMe():GotBuff(SkillId_Aura) then
			CastSkill(SkillId_Aura);
			Sleep(500)
		end

		-- stance
		CheckStance(me)
		
        if not me:IsBlocked(true)
		and target
		and not target:IsAlikeDeath()
		and target:IsEnemy()
		then
			Nuke(target);
		end
	end
    Sleep(400)
until false