globals
    hashtable easyAsync_ht = InitHashtable()
endglobals

struct EasyAsyncStep
    // 타이머의 timeout
    real timeout
    // 실행될 콜백
    code callback
    // 반복 횟수
    integer loopCount

    method isLoop takes nothing returns boolean
        return this.loopCount > 1
    endmethod
endstruct

struct EasyAsyncStepList
    private EasyAsyncStep array steps
    integer size = 0

    method isEmpty takes nothing returns boolean
        return this.size == 0
    endmethod
    
    method at takes integer index returns EasyAsyncStep
        return this._steps[index]
    endmethod

    method push takes real timeout, code callback, integer loopCount returns nothing
        local EasyAsyncStep step = EasyAsyncStep.create()

        set step.timeout = timeout
        set step.callback = callback
        set step.loopCount = loopCount

        set this._steps[this.size] = step
        set this.size = this.size + 1
    endmethod

    // 소멸자

    method onDestroy takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= this.size
            call this._steps[i].destroy()
            set i = i + 1
        endloop

        set this.steps = null
    endmethod
endstruct

function EasyAsync_Callback takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local EasyAsync async = LoadInteger(easyAsync_ht, GetHandleId(t), StringHash("_this"))

    local integer stage = async._stage
    local EasyAsyncStep step = async.stepAt(stage)

    call step.callback()
    set async.currentStepExecutionCount = async.currentStepExecutionCount + 1

    if (step.isLoop() && async.currentStepExecutionCount < step.loopCount) then
        return
    endif

    set async.currentStepExecutionCount = 0
    set async._stage = stage + 1

    if (async._stage >= async._stepList.size) then
        // 모든 스텝이 끝났을 때
        call async.destroy()
        set async = null
    else
        // 다음 스텝 실행
        call async.run()
    endif
endfunction

struct EasyAsync
    private integer _stage = 0
    private EasyAsyncStepList _stepList = EasyAsyncStepList.allocate()
    private timer t
    private integer currentStepExecutionCount = 0

    // getters

    method timerId takes nothing returns integer
        return GetHandleId(this.t)
    endmethod

    method ht takes nothing returns hashtable
        return easyAsync_ht
    endmethod

    // private methods

    private method stepAt takes integer index returns EasyAsyncStep
        return this._stepList.at(index)
    endmethod

    // hashtable handlers

    method saveInteger takes string whichKey, integer value returns nothing
        call SaveInteger(this.ht(), this.timerId(), StringHash(whichKey), value)
    endmethod

    method saveUnit takes string whichKey, unit value returns nothing
        call SaveUnitHandle(this.ht(), this.timerId(), StringHash(whichKey), value)
    endmethod

    // EasyAsync 객체 초기화
    static method init takes nothing returns thistype
        local thistype res = thistype.create()

        set res.t = CreateTimer()
        this.saveInteger("_this", this)

        return res
    endmethod

    // Step handlers

    method addStep takes real timeout, code callback returns nothing
        call this._stepList.push(timeout, callback, 1)
    endmethod

    method addLoopStep takes real interval, code callback, integer loopCount
        call this._stepList.push(timeout, callback, loopCount)
    endmethod

    // 실행

    method run takes nothing returns nothing
        local EasyAsyncStep step = this.stepAt(this._stage)
        
        call PauseTimer(this.t)
        call TimerStart(this.t, step.timeout, step.isLoop(), function EasyAsync_Callback)
    endmethod

    method runWithCallback takes code callback returns nothing
        call this.addStep(0.0, callback)
        call this.run()
    endmethod

    // 소멸자

    method onDestroy takes nothing returns nothing
        call FlushChildHashtable(easyAsync_ht, this.timerId)

        call PauseTimer(this.t)
        call DestroyTimer(this.t)

        if (this.t != null) then
            call DestroyTimer(this.t)
            set this.t = null
        endif

        if(this.tempCallback != null) then
            call DestroyTrigger(this.tempCallback)
            set this.tempCallback = null
        endif

        call this._stepList.destory()
        set this._stepList = null
    endmethod
endstruct

// 이렇게 쓰고싶음

function Skill_Function takes nothing returns nothing
    local EasyAsync async = EasyAsync.init()

    call async.saveInteger("age", 28)
    call async.saveUnit("attacker", GetAttacker())

    call async.addStep(0.1, function Skill_Step1, 5)
    call async.addStep(1.0, function Skill_Step2)
    call async.addStep(1.0, function Skill_Step3)

    call async.run()
endfunction