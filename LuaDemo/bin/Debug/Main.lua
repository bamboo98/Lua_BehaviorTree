require "Controller"

print=PrintToWindows--��дprint����,�����붨λ��c#����

--ShowMessage("������ϢΪ:"..GetString("��ʾ��","������","Ĭ������"))--c#�ṩ���õĺ���
--ClearPrint()
local PlayerState={
	['����']=1,
	['����']=2,
	['����']=3,
	['����']=4,
	['����']=5,
	['�ָ�']=6,
	'����',
	'����',
	'����',
	'����',
	'����',
	'�ָ�'
}









function PrintInfo(bk,player,monster)
	print(string.format("���HP:%d%s%s,����HP:%d%s%s",bk:getValue("���HP"),player>=0 and "+" or "",tostring(player),bk:getValue("����HP"),monster>=0 and "+" or "",tostring(monster)))
	bk:setValue("���HP",bk:getValue("���HP")+player)
	bk:setValue("����HP",bk:getValue("����HP")+monster)
end
function RoundChange(bk)--�غϱ��
	local select=tonumber(GetString("��������Ҫ���еĲ���(����) 1:���� 2:���� 3:���� 4:���� 5:���� 6:�ָ� ���������ַ����˳���Ϸ","����ѡ��",""))
	if not select then
		select=PlayerState['����']
		PrintInfo(bk,-100,0)
	end
	if select>6 or select<1 then
		select=1
	end

	bk:setValue("���״̬",select)
	if bk:getValue("�������") then
		if select==PlayerState['����'] then
			if math.random(1,100)>60 then
				print("�㳢�Զ��򸽽��Ĳݴ�,��������Ч��")
				bk:setValue("���״̬",PlayerState['����'])
				bk:setValue("�������",false)
			else
				print("�㳢�Զ��򸽽��Ĳݴ�,���ǹ����ƺ��������!")
				bk:setValue("���״̬",PlayerState['����'])
			end
		elseif select==PlayerState['����'] then
			print("�������ݺݵؿ���һ��")
			PrintInfo(bk,0,-bk:getValue("����ȼ�")/(bk:getValue("��ҵȼ�")+50)*20)
			bk:setValue("����ҹ����Ļغ���",bk:getValue("��ǰ�غ���"))

		elseif select==PlayerState['����'] then
			print("����������еĶ���")
		elseif select==PlayerState['����'] then
			print("�㳢�����Ա߷���")
		elseif select==PlayerState['����'] then
			if math.random(1,100)>60 then
				print("�㳢�Զ��򸽽��Ĳݴ�,��������Ч��")
				bk:setValue("���״̬",PlayerState['����'])
				bk:setValue("�������",false)
			else
				print("�㳢�Զ��򸽽��Ĳݴ�,���ǹ����ƺ��������!")
				bk:setValue("���״̬",PlayerState['����'])
			end
		elseif select==PlayerState['�ָ�'] then
			print("�������˻ָ�����������,�ָ�������ʧ����ֵ�İٷ�֮25")
			PrintInfo(bk,(100-bk:getValue("���HP"))*0.25,0)

		end
	else
		if select==PlayerState['����'] then
			print("����ڸ����Ĳݴ���")
		elseif select==PlayerState['����'] then
			print("�������ݺݵؿ���һ��,����û��Ӧ����,Ч����Ⱥ!")
			bk:setValue("�������",true)
			PrintInfo(bk,0,-bk:getValue("����ȼ�")/(bk:getValue("��ҵȼ�")+50)*40)
			bk:setValue("����ҹ����Ļغ���",bk:getValue("��ǰ�غ���"))
		elseif select==PlayerState['����'] then
			print("����������еĶ���,Ȼ���������㻹�к�Զ")
			bk:setValue("���״̬",PlayerState['����'])
		elseif select==PlayerState['����'] then
			print("�㳢�����Ա߷���,Ȼ���������㻹�к�Զ")
			bk:setValue("���״̬",PlayerState['����'])
		elseif select==PlayerState['����'] then
			print("����ڸ����Ĳݴ���")
			bk:setValue("���״̬",PlayerState['����'])
		elseif select==PlayerState['�ָ�'] then
			print("�������˻ָ�����������,�ָ�������ʧ����ֵ�İٷ�֮25")
			PrintInfo(bk,(100-bk:getValue("���HP"))*0.25,0)

		end
	end
	bk:setValue("��ǰ�غ���",bk:getValue("��ǰ�غ���")+1)
end


function Main()
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	ClearPrint()
	print("========��Ϸ��ʼ����========")
	local bk=Blackboard:new()--�½�һ���ڰ�
	bk:setValue("���HP",100)
	bk:setValue("����HP",100)
	bk:setValue("��ҵȼ�",tonumber(GetString("�������Ѷ�(1~150)","�Ѷ�ѡ��","50")) or 50)--�����ʽ������Ĭ��Ϊ50
	bk:setValue("����ȼ�",50)
	bk:setValue("���״̬",PlayerState['����'])
	bk:setValue("�������",false)
	bk:setValue("��ǰ�غ���",0)
	bk:setValue("����ҹ����Ļغ���",-999)
	bk:setValue("�Ƿ��",false)
	bk:setValue("�񱩹�����ȴ�غ�",1)
	bk:setValue("�񱩹�������",0)


	local Sequence_Monster=bk:createSequence()--�½�����ĸ�����

	local Scene_Battle=bk:createScene()--����ս������
	local Scene_Patrol=bk:createScene()--����Ѳ�߳���
	local Scene_Escape=bk:createScene()--�������ܳ���

	Sequence_Monster:addScene(Scene_Battle)--����������������
	Sequence_Monster:addScene(Scene_Patrol)--����������������
	Sequence_Monster:addScene(Scene_Escape)--����������������

	local Sequence_Battle=bk:createSequence()--�½�ս������

	Scene_Battle:addSequence(Sequence_Battle)--��ս���������ս������

	local Scene_CrazyAttack=bk:createScene()--�����񱩹�������
	local Scene_UsualAttack=bk:createScene()--����ͨ����������
	local Scene_PursueAttack=bk:createScene()--����׷������

	Sequence_Battle:addScene(Scene_CrazyAttack)--����������������
	Sequence_Battle:addScene(Scene_UsualAttack)--����������������
	Sequence_Battle:addScene(Scene_PursueAttack)--����������������

	local Sequence_Patrol=bk:createSequence()--�½�Ѳ������

	Scene_Patrol:addSequence(Sequence_Patrol)--��Ѳ�߳������Ѳ������

	local Scene_UsualPatrol=bk:createScene()--����ͨ��Ѳ�߳���
	local Scene_AlertPatrol=bk:createScene()--��������Ѳ�߳���

	Sequence_Patrol:addScene(Scene_UsualPatrol)--����������������
	Sequence_Patrol:addScene(Scene_AlertPatrol)--����������������

	Scene_Battle:getStartTrigger():setRule(
	function(blackboard)--����ս�������Ĵ�����
		return blackboard:getValue("�������") and blackboard:getValue("����HP")>=10 and blackboard:getValue("���HP")>0
	end
	)
	Scene_Patrol:getStartTrigger():setRule(
	function(blackboard)--����Ѳ�߳����Ĵ�����
		return not blackboard:getValue("�������") and blackboard:getValue("����HP")>=10 and blackboard:getValue("���HP")>0
	end
	)
	Scene_Escape:getStartTrigger():setRule(
	function(blackboard)--�������ܳ����Ĵ�����
		return blackboard:getValue("����HP")<10 and blackboard:getValue("����HP")>0 and blackboard:getValue("���HP")>0
	end
	)
	Scene_CrazyAttack:getStartTrigger():setRule(
	function(blackboard)--���ÿ񱩹����Ĵ�����
		return blackboard:getValue("����HP")>=10 and blackboard:getValue("����HP")<60 and blackboard:getValue("�������") and blackboard:getValue("���HP")>0
	end
	)
	Scene_UsualAttack:getStartTrigger():setRule(
	function(blackboard)--����ͨ�������Ĵ�����
		return blackboard:getValue("����HP")>=60 and blackboard:getValue("�������") and blackboard:getValue("���HP")>0
	end
	)
	Scene_PursueAttack:getStartTrigger():setRule(
	function(blackboard)--����׷�������Ĵ�����
		return blackboard:getValue("����HP")>=10 and blackboard:getValue("���״̬")==PlayerState['����'] and blackboard:getValue("���HP")/blackboard:getValue("����HP")<2 and blackboard:getValue("���HP")>0
	end
	)
	Scene_UsualPatrol:getStartTrigger():setRule(
	function(blackboard)--����ͨ��Ѳ�ߵĴ�����
		return blackboard:getValue("����HP")>=10 and not blackboard:getValue("�������") and blackboard:getValue("��ǰ�غ���")-blackboard:getValue("����ҹ����Ļغ���")>3 and blackboard:getValue("���HP")>0
	end
	)
	Scene_AlertPatrol:getStartTrigger():setRule(
	function(blackboard)--���þ���Ѳ�ߵĴ�����
		return blackboard:getValue("����HP")>=10 and not blackboard:getValue("�������") and blackboard:getValue("��ǰ�غ���")-blackboard:getValue("����ҹ����Ļغ���")<=3 and blackboard:getValue("���HP")>0
	end
	)


	Scene_Battle:getDoingBehavior():setServer(
	function(blackboard)--����ս������
		print("�㱻���﷢����!����ս������!")
	end
	)
	Scene_Patrol:getDoingBehavior():setServer(
	function(blackboard)--����Ѳ�߳���

	end
	)
	Scene_Escape:getDoingBehavior():setServer(
	function(blackboard)--�������ܳ���
		blackboard:setValue("����HP",-999)
	end
	)
	Scene_CrazyAttack:getDoingBehavior():setServer(
	function(blackboard)--���ÿ񱩹���
		if blackboard:getValue("�񱩹�����ȴ�غ�")==0 then
			if blackboard:getValue("���״̬")==PlayerState['����'] then
				print("duang!����Ĺ���������Ķ�����,��͹��ﶼ�ܵ��˷����˺�")
				PrintInfo(blackboard,-(blackboard:getValue("��ҵȼ�")+50)/(blackboard:getValue("����ȼ�")+100)*26,-(blackboard:getValue("��ҵȼ�")+50)/(blackboard:getValue("����ȼ�")+100)*25)
				blackboard:setValue("����ҹ����Ļغ���",blackboard:getValue("��ǰ�غ���"))
				blackboard:setValue("�񱩹�����ȴ�غ�",2)


			elseif blackboard:getValue("���״̬")==PlayerState['����'] then
				if math.random(1,100)>60 then--���ܳɹ�
					print("����Ĺ��������!��û���ܵ��κ��˺�")
				else
					print("�㳢�������˹���,����û�гɹ�,���ݺݵ�����һȭ")
					PrintInfo(blackboard,-(blackboard:getValue("��ҵȼ�")+50)/(blackboard:getValue("����ȼ�")+100)*50,0)
					blackboard:setValue("����ҹ����Ļغ���",blackboard:getValue("��ǰ�غ���"))

				end
				blackboard:setValue("�񱩹�����ȴ�غ�",1)
			else
				print("�㱻����ݺݵ�����һȭ")
				PrintInfo(blackboard,-(blackboard:getValue("��ҵȼ�")+50)/(blackboard:getValue("����ȼ�")+100)*50,0)
				blackboard:setValue("����ҹ����Ļغ���",blackboard:getValue("��ǰ�غ���"))
				blackboard:setValue("�񱩹�����ȴ�غ�",1)
			end
		else
			print("������������!")
			blackboard:setValue("�񱩹�����ȴ�غ�",blackboard:getValue("�񱩹�����ȴ�غ�")-1)
		end
		RoundChange(blackboard)
	end
	)
	Scene_UsualAttack:getDoingBehavior():setServer(
	function(blackboard)--����ͨ������
		if blackboard:getValue("���״̬")==PlayerState['����'] then
			print("duang!����Ĺ���������Ķ�����,��͹��ﶼ�ܵ��˷����˺�")
			PrintInfo(blackboard,-(blackboard:getValue("��ҵȼ�")+50)/(blackboard:getValue("����ȼ�")+100)*7.7,-(blackboard:getValue("��ҵȼ�")+50)/(blackboard:getValue("����ȼ�")+100)*7.5)
			blackboard:setValue("����ҹ����Ļغ���",blackboard:getValue("��ǰ�غ���"))

		elseif blackboard:getValue("���״̬")==PlayerState['����'] then
			if math.random(1,100)>35 then--���ܳɹ�
				print("����Ĺ��������!��û���ܵ��κ��˺�")
			else
				print("�㳢�������˹���,����û�гɹ�,������һȭ")
				PrintInfo(blackboard,-(blackboard:getValue("��ҵȼ�")+50)/(blackboard:getValue("����ȼ�")+100)*15,0)
				blackboard:setValue("����ҹ����Ļغ���",blackboard:getValue("��ǰ�غ���"))


			end
		else
			print("�㱻��������һȭ")
			PrintInfo(blackboard,-(blackboard:getValue("��ҵȼ�")+50)/(blackboard:getValue("����ȼ�")+100)*15,0)
			blackboard:setValue("����ҹ����Ļغ���",blackboard:getValue("��ǰ�غ���"))

		end
		RoundChange(blackboard)
	end
	)
	Scene_PursueAttack:getDoingBehavior():setServer(
	function(blackboard)--����׷������
		print("�㳢������,���Ǳ�����׷��û������,��������һȭ")
		PrintInfo(blackboard,-(blackboard:getValue("��ҵȼ�")+50)/(blackboard:getValue("����ȼ�")+100)*12,0)
		blackboard:setValue("����ҹ����Ļغ���",blackboard:getValue("��ǰ�غ���"))


		RoundChange(blackboard)
	end
	)
	Scene_UsualPatrol:getDoingBehavior():setServer(
	function(blackboard)--����ͨ��Ѳ��
		if math.random(1,100)>85 then--������
			print("�㲻С�Ĳȵ��˿���֦,���������챻���﷢����!�������ڳ������")
			blackboard:setValue("�������",true)
		else
			print("��������Ѳ��")
		end
		RoundChange(blackboard)
	end
	)
	Scene_AlertPatrol:getDoingBehavior():setServer(
	function(blackboard)--���þ���Ѳ��
		if math.random(1,100)>75 then--������
			print("�㲻С�Ĳȵ��˿���֦,���������챻���﷢����!�������ڳ������")
			blackboard:setValue("�������",true)
		else
			print("��������Ѳ��,�������ܽ���,��֪�����ڸ���")
		end
		RoundChange(blackboard)
	end
	)



	print("==========��ʼ��Ϸ==========")
	


	Sequence_Monster:run()


	if bk:getValue("����HP")==-999 then
		print("����������!")
		print("==========��սʧ��==========")
	elseif bk:getValue("���HP")>0 then
		print("��սʤ�˹���!")
		print("==========��ս�ɹ�==========")
	else
		print("��û��սʤ����!")
		print("==========��սʧ��==========")
	end
	print("==========��Ϸ����==========")
	return 1
end
