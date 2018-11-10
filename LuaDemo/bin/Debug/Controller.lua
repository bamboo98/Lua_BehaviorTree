
_addToDelay_ = function() end
_addToTouchDown_ = function () end
_addToTouchUp_ = function () end

local function doFunction(f,blackboard)
    while f do
        f = coroutine.yield(f(blackboard))
    end
end

Blackboard={}

function Blackboard:new()--�����ڰ����
	local o={
		_tag="Blackboard",
		con={},
	}
	setmetatable(o,{__index = self} )

	return o
end

function Blackboard:setValue(Member,Value)
	self.con[Member]=Value
end

function Blackboard:getValue(Member,DefaultValue)
	if self.con[Member]~=nil then
		return self.con[Member] 
	else
		return DefaultValue or nil
	end
end

function Blackboard:setValueBatch(Value)
	for k,v in pairs(Value) do
		self.con[k]=v
	end
end

function Blackboard:getAllValue(Target)
	Target=Target or self
	return Target.con
end

function Blackboard:createScene()
	return Scene:new(self)
end
function Blackboard:createSequence()
	return Sequence:new(self)
end


Behavior={}

function Behavior:new(Parent)--��������
	local o={
		_tag="Behavior",
		parent=Parent,--���ø��ڵ�
		server=function(Blackboard) return end,
		continuity=false,--�����������Ϊtrue,��Э��ִ�к󲻻��Զ�����,�ٴ��������������ʱ�������ϴεĽ�����
		co=nil,
		blackboard=Parent.blackboard,
		triggerOnDelay = Trigger:new(Parent.blackboard),
		triggerOnTouchDown = Trigger:new(Parent.blackboard),
		triggerOnTouchUp = Trigger:new(Parent.blackboard),
	}
	setmetatable(o,{__index = self} )

	return o
end

function Behavior:setServer(ServerFunction)--���ﴫ��Functionû�в���,���ݽ���ʹ�úڰ����
	if type(ServerFunction)=="function" then
		self.server=ServerFunction
	end
end

function Behavior:run()
	local flag,ret
	self:setTrigger()--���ü����
	if self.co==nil then
		self.co=coroutine.create(doFunction)
	end
	flag,ret=coroutine.resume(self.co,self.server,self.blackboard)--��ʼ����Э��,���Ҵ���ڰ�����
	if flag and type(ret)=="string" and ret=="_stop_" then--���ֶ��ж�,�����������н���
		if not self.continuity then--����Ҫ�������е�Э��,ֱ������
			self.co=nil
		end
	elseif not flag then--����ֹͣ
		print("Э���ڷ�������,������Ϣ"..ret)
		os.exit(0)
	end
end

function Behavior:setContinuity(Flag)--������Ϊ�Ƿ������������(�жϺ�����)
	self.continuity=Flag
end

function Behavior.stop()--ֹͣ��ǰ��Ϊ
	if coroutine.isyieldable() then
		Behavior.resetTrigger()--���ü����
		coroutine.yield("_stop_")
	end
end

function Behavior:setTrigger()--���ü����
	_addToDelay_ = function() if self.triggerOnDelay:check() then Behavior.stop() end end
	_addToTouchDown_ = function() if self.triggerOnTouchDown:check() then Behavior.stop() end end
	_addToTouchUp_ = function() if self.triggerOnTouchUp:check() then Behavior.stop() end end
end

function Behavior:getTriggerOnDelay()--���ü����
	return self.triggerOnDelay
end

function Behavior:getTriggerOnTouchDown()--���ü����
	return self.triggerOnTouchDown
end

function Behavior:getTriggerOnTouchUp()--���ü����
	return self.triggerOnTouchUp
end

function Behavior.resetTrigger()--���ü����
	_addToDelay_ = function() end
	_addToTouchDown_ = function () end
	_addToTouchUp_ = function () end
end


Scene={}

function Scene:new(Blackboard)
	local o={
		_tag="Scene",
		blackboard=Blackboard,--�ڰ�
		startTrigger=Trigger:new(Blackboard),--���д�����
		endTrigger=Trigger:new(Blackboard),--����������
	}
	setmetatable(o,{__index = self} )
	o.startingBehavior=Behavior:new(o)--����ǰ����(һ����ִ��)
	o.doingBehavior=Behavior:new(o)--������ѭ������(��������������򲻻�ִ��)
	o.endingBehavior=Behavior:new(o)--���н��������(һ����ִ��)
	return o
end

function Scene:getStartingBehavior()
	return self.startingBehavior
end

function Scene:getDoingBehavior()
	return self.doingBehavior
end

function Scene:getEndingBehavior()
	return self.endingBehavior
end

function Scene:getStartTrigger()
	return self.startTrigger
end

function Scene:getEndTrigger()
	return self.endTrigger
end

function Scene:run()
	if self.startTrigger:check() then
		self.startingBehavior:run()
		if not self.endTrigger:check() then
			self.doingBehavior:run()
		end
		self.endingBehavior:run()
		if self.child and self.child._tag=="Sequence" then
			self.child:run()--���ӳ��������ɹ�ʱ,����ӳ�������
		end
		return true
	end
	return false
end

function Scene:addSequence(Sequence)
	if Sequence._tag and Sequence._tag=="Sequence" then
		self.child=Sequence
	end
end


Trigger={}

function Trigger:new(Blackboard)
	local o={
		_tag="Trigger",
		blackboard=Blackboard,--�ڰ�
		rule=function(bk) return false end,--�жϹ���
	}
	setmetatable(o,{__index = self} )
	return o
end

function Trigger:setRule(RuleFunction)
	if type(RuleFunction)=="function" then
		self.rule=RuleFunction
	end
end

function Trigger:check()
	return self.rule(self.blackboard)
end


Sequence={}

function Sequence:new(Blackboard)
	local o={
		_tag="Sequence",
		scenes={},
		isLoop=false,
		maxCount=-1,
		maxTime=-1,
		loopIntervalTime=0,
		LoopEndTrigger=Trigger:new(Blackboard)
	}
	setmetatable(o,{__index = self} )
	return o
end

function Sequence:run()
	local flag=true
	local loopCount,loopTime
	repeat
		if flag then --����ϴα���scene�ɹ�ִ��,������ѭ��ʱ��ʹ���
			loopTime=os.time()
			loopCount=0
		end
		for _,v in ipairs(self.scenes) do--����sceneִ��run����
			flag=v:run()
			if flag then
				break 
			end
		end
		if self.LoopEndTrigger:check() then 
			break 
		end
		loopCount=loopCount+1
		if self.loopIntervalTime>0 then delay(loopIntervalTime) end
	until((not flag and not self.isLoop) or ((self.isLoop and not flag) and (loopTime+self.maxTime<os.time() or loopCount>self.maxCount)))
end

function Sequence:addScene(Scene)
	if Scene._tag and Scene._tag=="Scene" then
		table.insert(self.scenes,Scene)
	end
end

function Sequence:getLoopEndTrigger()
	return self.LoopEndTrigger
end

--[[
	Sequence:setLoop(isLoop,LoopCount,LoopTime,IntervalTime)
	���ó�������ѭ����ʽ
	����:	isLoop		Bool��,�Ƿ�ѭ��
			LoopCount 	ѭ������
			LoopTime 	ѭ���ʱ��
			IntervalTimeÿ��ѭ���ļ��
]]
function Sequence:setLoop(isLoop,LoopCount,LoopTime,IntervalTime)
	LoopCount=LoopCount or -1
	LoopTime=LoopTime or -1
	IntervalTime=IntervalTime or 0
	self.isLoop=isLoop
	self.maxCount=LoopCount
	self.maxTime=LoopTime*1000
	self.loopIntervalTime=IntervalTime
end