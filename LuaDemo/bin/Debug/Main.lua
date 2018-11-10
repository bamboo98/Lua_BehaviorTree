require "Controller"

print=PrintToWindows--重写print函数,将输入定位到c#窗口

--ShowMessage("输入信息为:"..GetString("提示文","标题文","默认输入"))--c#提供调用的函数
--ClearPrint()
local PlayerState={
	['隐蔽']=1,
	['攻击']=2,
	['防御']=3,
	['闪避']=4,
	['逃跑']=5,
	['恢复']=6,
	'隐蔽',
	'攻击',
	'防御',
	'闪避',
	'逃跑',
	'恢复'
}









function PrintInfo(bk,player,monster)
	print(string.format("玩家HP:%d%s%s,怪物HP:%d%s%s",bk:getValue("玩家HP"),player>=0 and "+" or "",tostring(player),bk:getValue("怪物HP"),monster>=0 and "+" or "",tostring(monster)))
	bk:setValue("玩家HP",bk:getValue("玩家HP")+player)
	bk:setValue("怪物HP",bk:getValue("怪物HP")+monster)
end
function RoundChange(bk)--回合变更
	local select=tonumber(GetString("请输入你要进行的操作(数字) 1:隐蔽 2:攻击 3:防御 4:闪避 5:逃跑 6:恢复 输入其他字符则退出游戏","操作选择",""))
	if not select then
		select=PlayerState['逃跑']
		PrintInfo(bk,-100,0)
	end
	if select>6 or select<1 then
		select=1
	end

	bk:setValue("玩家状态",select)
	if bk:getValue("发现玩家") then
		if select==PlayerState['隐蔽'] then
			if math.random(1,100)>60 then
				print("你尝试躲向附近的草丛,看起来奏效了")
				bk:setValue("玩家状态",PlayerState['隐蔽'])
				bk:setValue("发现玩家",false)
			else
				print("你尝试躲向附近的草丛,但是怪物似乎想跟过来!")
				bk:setValue("玩家状态",PlayerState['逃跑'])
			end
		elseif select==PlayerState['攻击'] then
			print("你向怪物狠狠地砍了一刀")
			PrintInfo(bk,0,-bk:getValue("怪物等级")/(bk:getValue("玩家等级")+50)*20)
			bk:setValue("被玩家攻击的回合数",bk:getValue("当前回合数"))

		elseif select==PlayerState['防御'] then
			print("你举起了手中的盾牌")
		elseif select==PlayerState['闪避'] then
			print("你尝试向旁边翻滚")
		elseif select==PlayerState['逃跑'] then
			if math.random(1,100)>60 then
				print("你尝试躲向附近的草丛,看起来奏效了")
				bk:setValue("玩家状态",PlayerState['隐蔽'])
				bk:setValue("发现玩家",false)
			else
				print("你尝试躲向附近的草丛,但是怪物似乎想跟过来!")
				bk:setValue("玩家状态",PlayerState['逃跑'])
			end
		elseif select==PlayerState['恢复'] then
			print("你念起了恢复法术的咒语,恢复了已损失生命值的百分之25")
			PrintInfo(bk,(100-bk:getValue("玩家HP"))*0.25,0)

		end
	else
		if select==PlayerState['隐蔽'] then
			print("你躲在附近的草丛里")
		elseif select==PlayerState['攻击'] then
			print("你向怪物狠狠地砍了一刀,怪物没反应过来,效果拔群!")
			bk:setValue("发现玩家",true)
			PrintInfo(bk,0,-bk:getValue("怪物等级")/(bk:getValue("玩家等级")+50)*40)
			bk:setValue("被玩家攻击的回合数",bk:getValue("当前回合数"))
		elseif select==PlayerState['防御'] then
			print("你举起了手中的盾牌,然而怪物离你还有很远")
			bk:setValue("玩家状态",PlayerState['隐蔽'])
		elseif select==PlayerState['闪避'] then
			print("你尝试向旁边翻滚,然而怪物离你还有很远")
			bk:setValue("玩家状态",PlayerState['隐蔽'])
		elseif select==PlayerState['逃跑'] then
			print("你躲在附近的草丛里")
			bk:setValue("玩家状态",PlayerState['隐蔽'])
		elseif select==PlayerState['恢复'] then
			print("你念起了恢复法术的咒语,恢复了已损失生命值的百分之25")
			PrintInfo(bk,(100-bk:getValue("玩家HP"))*0.25,0)

		end
	end
	bk:setValue("当前回合数",bk:getValue("当前回合数")+1)
end


function Main()
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	ClearPrint()
	print("========游戏初始化中========")
	local bk=Blackboard:new()--新建一个黑板
	bk:setValue("玩家HP",100)
	bk:setValue("怪物HP",100)
	bk:setValue("玩家等级",tonumber(GetString("请输入难度(1~150)","难度选择","50")) or 50)--输入格式错误则默认为50
	bk:setValue("怪物等级",50)
	bk:setValue("玩家状态",PlayerState['隐蔽'])
	bk:setValue("发现玩家",false)
	bk:setValue("当前回合数",0)
	bk:setValue("被玩家攻击的回合数",-999)
	bk:setValue("是否狂暴",false)
	bk:setValue("狂暴攻击冷却回合",1)
	bk:setValue("狂暴攻击次数",0)


	local Sequence_Monster=bk:createSequence()--新建怪物的根流程

	local Scene_Battle=bk:createScene()--创建战斗场景
	local Scene_Patrol=bk:createScene()--创建巡逻场景
	local Scene_Escape=bk:createScene()--创建逃跑场景

	Sequence_Monster:addScene(Scene_Battle)--将场景绑定至流程内
	Sequence_Monster:addScene(Scene_Patrol)--将场景绑定至流程内
	Sequence_Monster:addScene(Scene_Escape)--将场景绑定至流程内

	local Sequence_Battle=bk:createSequence()--新建战斗流程

	Scene_Battle:addSequence(Sequence_Battle)--给战斗场景添加战斗流程

	local Scene_CrazyAttack=bk:createScene()--创建狂暴攻击场景
	local Scene_UsualAttack=bk:createScene()--创建通常攻击场景
	local Scene_PursueAttack=bk:createScene()--创建追击场景

	Sequence_Battle:addScene(Scene_CrazyAttack)--将场景绑定至流程内
	Sequence_Battle:addScene(Scene_UsualAttack)--将场景绑定至流程内
	Sequence_Battle:addScene(Scene_PursueAttack)--将场景绑定至流程内

	local Sequence_Patrol=bk:createSequence()--新建巡逻流程

	Scene_Patrol:addSequence(Sequence_Patrol)--给巡逻场景添加巡逻流程

	local Scene_UsualPatrol=bk:createScene()--创建通常巡逻场景
	local Scene_AlertPatrol=bk:createScene()--创建警戒巡逻场景

	Sequence_Patrol:addScene(Scene_UsualPatrol)--将场景绑定至流程内
	Sequence_Patrol:addScene(Scene_AlertPatrol)--将场景绑定至流程内

	Scene_Battle:getStartTrigger():setRule(
	function(blackboard)--设置战斗场景的触发器
		return blackboard:getValue("发现玩家") and blackboard:getValue("怪物HP")>=10 and blackboard:getValue("玩家HP")>0
	end
	)
	Scene_Patrol:getStartTrigger():setRule(
	function(blackboard)--设置巡逻场景的触发器
		return not blackboard:getValue("发现玩家") and blackboard:getValue("怪物HP")>=10 and blackboard:getValue("玩家HP")>0
	end
	)
	Scene_Escape:getStartTrigger():setRule(
	function(blackboard)--设置逃跑场景的触发器
		return blackboard:getValue("怪物HP")<10 and blackboard:getValue("怪物HP")>0 and blackboard:getValue("玩家HP")>0
	end
	)
	Scene_CrazyAttack:getStartTrigger():setRule(
	function(blackboard)--设置狂暴攻击的触发器
		return blackboard:getValue("怪物HP")>=10 and blackboard:getValue("怪物HP")<60 and blackboard:getValue("发现玩家") and blackboard:getValue("玩家HP")>0
	end
	)
	Scene_UsualAttack:getStartTrigger():setRule(
	function(blackboard)--设置通常攻击的触发器
		return blackboard:getValue("怪物HP")>=60 and blackboard:getValue("发现玩家") and blackboard:getValue("玩家HP")>0
	end
	)
	Scene_PursueAttack:getStartTrigger():setRule(
	function(blackboard)--设置追击攻击的触发器
		return blackboard:getValue("怪物HP")>=10 and blackboard:getValue("玩家状态")==PlayerState['逃跑'] and blackboard:getValue("玩家HP")/blackboard:getValue("怪物HP")<2 and blackboard:getValue("玩家HP")>0
	end
	)
	Scene_UsualPatrol:getStartTrigger():setRule(
	function(blackboard)--设置通常巡逻的触发器
		return blackboard:getValue("怪物HP")>=10 and not blackboard:getValue("发现玩家") and blackboard:getValue("当前回合数")-blackboard:getValue("被玩家攻击的回合数")>3 and blackboard:getValue("玩家HP")>0
	end
	)
	Scene_AlertPatrol:getStartTrigger():setRule(
	function(blackboard)--设置警戒巡逻的触发器
		return blackboard:getValue("怪物HP")>=10 and not blackboard:getValue("发现玩家") and blackboard:getValue("当前回合数")-blackboard:getValue("被玩家攻击的回合数")<=3 and blackboard:getValue("玩家HP")>0
	end
	)


	Scene_Battle:getDoingBehavior():setServer(
	function(blackboard)--设置战斗场景
		print("你被怪物发现了!进入战斗场景!")
	end
	)
	Scene_Patrol:getDoingBehavior():setServer(
	function(blackboard)--设置巡逻场景

	end
	)
	Scene_Escape:getDoingBehavior():setServer(
	function(blackboard)--设置逃跑场景
		blackboard:setValue("怪物HP",-999)
	end
	)
	Scene_CrazyAttack:getDoingBehavior():setServer(
	function(blackboard)--设置狂暴攻击
		if blackboard:getValue("狂暴攻击冷却回合")==0 then
			if blackboard:getValue("玩家状态")==PlayerState['防御'] then
				print("duang!怪物的攻击打到了你的盾牌上,你和怪物都受到了反震伤害")
				PrintInfo(blackboard,-(blackboard:getValue("玩家等级")+50)/(blackboard:getValue("怪物等级")+100)*26,-(blackboard:getValue("玩家等级")+50)/(blackboard:getValue("怪物等级")+100)*25)
				blackboard:setValue("被玩家攻击的回合数",blackboard:getValue("当前回合数"))
				blackboard:setValue("狂暴攻击冷却回合",2)


			elseif blackboard:getValue("玩家状态")==PlayerState['闪避'] then
				if math.random(1,100)>60 then--闪避成功
					print("怪物的攻击落空了!你没有受到任何伤害")
				else
					print("你尝试闪避了攻击,但是没有成功,被狠狠地揍了一拳")
					PrintInfo(blackboard,-(blackboard:getValue("玩家等级")+50)/(blackboard:getValue("怪物等级")+100)*50,0)
					blackboard:setValue("被玩家攻击的回合数",blackboard:getValue("当前回合数"))

				end
				blackboard:setValue("狂暴攻击冷却回合",1)
			else
				print("你被怪物狠狠的揍了一拳")
				PrintInfo(blackboard,-(blackboard:getValue("玩家等级")+50)/(blackboard:getValue("怪物等级")+100)*50,0)
				blackboard:setValue("被玩家攻击的回合数",blackboard:getValue("当前回合数"))
				blackboard:setValue("狂暴攻击冷却回合",1)
			end
		else
			print("怪物正在蓄力!")
			blackboard:setValue("狂暴攻击冷却回合",blackboard:getValue("狂暴攻击冷却回合")-1)
		end
		RoundChange(blackboard)
	end
	)
	Scene_UsualAttack:getDoingBehavior():setServer(
	function(blackboard)--设置通常攻击
		if blackboard:getValue("玩家状态")==PlayerState['防御'] then
			print("duang!怪物的攻击打到了你的盾牌上,你和怪物都受到了反震伤害")
			PrintInfo(blackboard,-(blackboard:getValue("玩家等级")+50)/(blackboard:getValue("怪物等级")+100)*7.7,-(blackboard:getValue("玩家等级")+50)/(blackboard:getValue("怪物等级")+100)*7.5)
			blackboard:setValue("被玩家攻击的回合数",blackboard:getValue("当前回合数"))

		elseif blackboard:getValue("玩家状态")==PlayerState['闪避'] then
			if math.random(1,100)>35 then--闪避成功
				print("怪物的攻击落空了!你没有受到任何伤害")
			else
				print("你尝试闪避了攻击,但是没有成功,被揍了一拳")
				PrintInfo(blackboard,-(blackboard:getValue("玩家等级")+50)/(blackboard:getValue("怪物等级")+100)*15,0)
				blackboard:setValue("被玩家攻击的回合数",blackboard:getValue("当前回合数"))


			end
		else
			print("你被怪物揍了一拳")
			PrintInfo(blackboard,-(blackboard:getValue("玩家等级")+50)/(blackboard:getValue("怪物等级")+100)*15,0)
			blackboard:setValue("被玩家攻击的回合数",blackboard:getValue("当前回合数"))

		end
		RoundChange(blackboard)
	end
	)
	Scene_PursueAttack:getDoingBehavior():setServer(
	function(blackboard)--设置追击攻击
		print("你尝试逃跑,但是被怪物追得没法脱身,还被揍了一拳")
		PrintInfo(blackboard,-(blackboard:getValue("玩家等级")+50)/(blackboard:getValue("怪物等级")+100)*12,0)
		blackboard:setValue("被玩家攻击的回合数",blackboard:getValue("当前回合数"))


		RoundChange(blackboard)
	end
	)
	Scene_UsualPatrol:getDoingBehavior():setServer(
	function(blackboard)--设置通常巡逻
		if math.random(1,100)>85 then--被发现
			print("你不小心踩到了枯树枝,发出了声响被怪物发现了!怪物正在朝你冲来")
			blackboard:setValue("发现玩家",true)
		else
			print("怪物正在巡逻")
		end
		RoundChange(blackboard)
	end
	)
	Scene_AlertPatrol:getDoingBehavior():setServer(
	function(blackboard)--设置警戒巡逻
		if math.random(1,100)>75 then--被发现
			print("你不小心踩到了枯树枝,发出了声响被怪物发现了!怪物正在朝你冲来")
			blackboard:setValue("发现玩家",true)
		else
			print("怪物正在巡逻,看起来很谨慎,他知道你在附近")
		end
		RoundChange(blackboard)
	end
	)



	print("==========开始游戏==========")
	


	Sequence_Monster:run()


	if bk:getValue("怪物HP")==-999 then
		print("怪物逃跑了!")
		print("==========作战失败==========")
	elseif bk:getValue("玩家HP")>0 then
		print("你战胜了怪物!")
		print("==========作战成功==========")
	else
		print("你没能战胜怪物!")
		print("==========作战失败==========")
	end
	print("==========游戏结束==========")
	return 1
end
