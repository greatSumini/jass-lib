// 공용유틸 함수들 - 유닛

function Common_Unit_GetMana takes unit targetUnit returns integer
    return R2I(GetUnitStateSwap(UNIT_STATE_MANA, targetUnit))
endfunction

function Common_Unit_SetMana takes unit targetUnit, integer value returns nothing
    call SetUnitManaBJ(targetUnit, value)
endfunction

function Common_Unit_ClearMana takes unit targetUnit returns nothing
    call Common_Unit_SetMana(targetUnit, 0)
endfunction

function Common_Unit_IncreaseMana takes unit targetUnit, integer diff returns nothing
    call Common_Unit_SetMana(targetUnit, Common_Unit_GetMana(targetUnit) + diff)
endfunction

function Common_Unit_IsManaEquals takes unit targetUnit, integer mana returns boolean
    return Common_Unit_GetMana(targetUnit) == mana
endfunction

function Common_Unit_Show takes unit u returns nothing
    call ShowUnit(u, true)
endfunction

function Common_Unit_Hide takes unit u returns nothing
    call ShowUnit(u, false)
endfunction

function Common_Unit_SetOpacity takes unit u, real opacity returns nothing
    call SetUnitVertexColor(u, 255, 255, 255, R2I(opacity * 255))
endfunction

// 공용유틸함수들 - Math

function Common_Math_RandomDraw takes integer denominator, integer numerator returns boolean
    return GetRandomInt(1, denominator) <= numerator
endfunction

// 공용유틸함수들 - 타이머

function Common_HashTable_ForTimer takes nothing returns hashtable
    return htForTimer
endfunction

function Common_HashTable_SaveUnitForTimer takes timer t, string hashKey, unit value returns nothing
    call SaveUnitHandle(Common_HashTable_ForTimer(), GetHandleId(t), StringHash(hashKey), value)
endfunction
function Common_HashTable_LoadUnitForTimer takes timer t, string hashKey returns unit
    return LoadUnitHandle(Common_HashTable_ForTimer(), GetHandleId(t), StringHash(hashKey))
endfunction

function Common_HashTable_SaveLocationForTimer takes timer t, string hashKey, location value returns nothing
    call SaveLocationHandle(Common_HashTable_ForTimer(), GetHandleId(t), StringHash(hashKey), value)
endfunction
function Common_HashTable_LoadLocationForTimer takes timer t, string hashKey returns location
    return LoadLocationHandle(Common_HashTable_ForTimer(), GetHandleId(t), StringHash(hashKey))
endfunction

// callback은 반드시 expiredTimer를 파괴해야합니다
function Common_Timer_StartWithCallback takes timer targetTimer, real timeout, code callback returns nothing
    call TimerStart(targetTimer, timeout, false, callback)
endfunction