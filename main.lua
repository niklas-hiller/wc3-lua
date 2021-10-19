Log = {}    -- Required to use it ouside of Engine Framework
Framework = {}  -- Stores Engine Framework in a variable
Engine = {}
Engine.new = function()
    local self = {}

    -- Objects
    local _Logger = {}
    local _Indexer = {}
    local _EventDispatcher = {}
    local _Keyboard = {}
    local _Window = {}
    local _Clock = {}
    local _SoundLoader = {}
    local _Unit = {}
    local _Player = {}
    local _Group = {}
    local _Item = {}
    local _Trigger = {}
    local _Effect = {}

    -- Engine Logger
    local LOG_LEVEL = {
        NONE,
        DEFAULT,
        HIGH,
        DEBUG
    }

    _Logger.new = function(LogLevel)
        local self = {}

        self.Level = LogLevel or 0

        function self.Debug(message)
            if self.Level >= 3 then
                print("|c007d7d7d[DEBUG]|r" .. " " .. message)
            end
        end

        function self.Error(message)

            if self.Level >= 1 then
                print("|cffdc143c[ERROR]|r" .. " " .. message)
            end
        
        end

        function self.Warn(message)

            if self.Level >= 2 then
                print("|c00FF7F00[WARN]|r" .. " " .. message)
            end
        
        end

        return self

    end

    Logger = _Logger.new

    Log = Logger(2)

    _Indexer.new = function()
        local self = {}
        local handles = {}

        function self._add(object, handle)
            handles[object] = handle
            return handle
        end

        self.add = function(object, handle)
            local status, val = xpcall(self._add, Log.Error, object, handle)
            if status then return val end
        end

        function self._find(_handle)
            for object, handle in pairs(handles) do
                if handle == _handle then
                    return object
                end
            end
            Log.Warn("Indexer detected unknown handle! (" .. GetHandleId(_handle) .. ")")
        end

        self.find = function(handle)
            local status, val = xpcall(self._find, Log.Error, handle)
            if status then return val end
        end

        return self

    end

    local Indexer = _Indexer.new()

    _GetTriggerUnit = GetTriggerUnit
    GetTriggerUnit = function()
        local handle = _GetTriggerUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    _GetAttacker = GetAttacker
    GetAttacker = function()
        local handle = _GetAttacker()
        local unit = Indexer.find(handle)
        return unit
    end

    _GetFilterUnit = GetFilterUnit
    GetFilterUnit = function()
        local handle = _GetFilterUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    _GetSpellTargetUnit = GetSpellTargetUnit
    GetSpellTargetUnit = function()
        local handle = _GetSpellTargetUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    _GetManipulatedItem = GetManipulatedItem
    GetManipulatedItem = function()
        local handle = _GetManipulatedItem()
        local item = Indexer.find(handle)
        return item
    end

    _GetFilterItem = GetFilterItem
    GetFilterItem = function()
        local handle = _GetFilterItem()
        local item = Indexer.find(handle)
        return item
    end

    _GetTriggerPlayer = GetTriggerPlayer
    GetTriggerPlayer = function()
        local handle = _GetTriggerPlayer()
        local player = Indexer.find(handle)
        return player
    end

    _GetItemPlayer = GetItemPlayer
    GetItemPlayer = function()
        local handle = _GetItemPlayer()
        local player = Indexer.find(handle)
        return player
    end

    GetSpellObject = function()
        local self = {}
        self.handle = GetSpellAbility()
        self.id = GetSpellAbilityId()
        self.x = GetSpellTargetX()
        self.y = GetSpellTargetY()
        self.target = GetSpellTargetUnit()
        return self
    end

    GetDamageObject = function()
        local self = {}
        self.attackType = BlzGetEventAttackType()
        self.damageType = BlzGetEventDamageType()
        self.weaponType = BlzGetEventWeaponType()
        self.isAttack = BlzGetEventIsAttack()
        return self
    end

    _GetEventDamageSource = GetEventDamageSource
    GetEventDamageSource = function()
        local handle = _GetEventDamageSource()
        local unit = Indexer.find(handle)
        return unit
    end

    _GetEventDamageTarget = BlzGetEventDamageTarget
    GetEventDamageTarget = function()
        local handle = _GetEventDamageTarget()
        local unit = Indexer.find(handle)
        return unit
    end

    _Player_ = Player
    Player = function(id)
        local handle = _Player_(id)
        local player = Indexer.find(handle)
        return player
    end

    _GetOwningPlayer = GetOwningPlayer
    GetOwningPlayer = function(unit)
        local handle = _GetOwningPlayer(unit.handle)
        local player = Indexer.find(handle)
        return player
    end

    _Trigger.new = function()
        local self = {}
        local handle = CreateTrigger()

        function self._registerVariableEvent(varName, opcode, limitval)
            TriggerRegisterVariableEvent(handle, varName, opcode, limitval)
            return self
        end

        self.registerVariableEvent = function(varName, opcode, limitval)
            local status, val = xpcall(self._registerVariableEvent, Log.Error, varName, opcode, limitval)
            if status then return val end
        end

        function self._registerTimerEvent(timeout, periodic)
            TriggerRegisterTimerEvent(handle, timeout, periodic)
            return self
        end

        self.registerTimerEvent = function(timeout, periodic)
            local status, val = xpcall(self._registerTimerEvent, Log.Error, timeout, periodic)
            if status then return val end
        end

        function self._registerTimerExpireEvent(t)
            TriggerRegisterTimerExpireEvent(handle, t)
            return self
        end

        self.registerTimerExpireEvent = function(t)
            local status, val = xpcall(self._registerTimerExpireEvent, Log.Error, t)
            if status then return val end
        end

        function self._registerGameStateEvent(whichState, opcode, limitval)
            TriggerRegisterGameStateEvent(handle, whichState, opcode, limitval)
            return self
        end

        self.registerGameStateEvent = function(whichState, opcode, limitval)
            local status, val = xpcall(self._registerGameStateEvent, Log.Error, whichState, opcode, limitval)
            if status then return val end
        end

        function self._registerDialogEvent(whichDialog)
            TriggerRegisterDialogEvent(handle, whichDialog)
            return self
        end

        self.registerDialogEvent = function(whichDialog)
            local status, val = xpcall(self._registerDialogEvent, Log.Error, whichDialog)
            if status then return val end
        end

        function self._registerDialogButtonEvent(whichButton)
            TriggerRegisterDialogButtonEvent(handle, whichButton)
            return self
        end

        self.registerDialogButtonEvent = function(whichButton)
            local status, val = xpcall(self._registerDialogButtonEvent, Log.Error, whichButton)
            if status then return val end
        end

        function self._registerGameEvent(whichGameEvent)
            TriggerRegisterGameEvent(handle, whichGameEvent)
            return self
        end

        self.registerGameEvent = function(whichGameEvent)
            local status, val = xpcall(self._registerGameEvent, Log.Error, whichGameEvent)
            if status then return val end
        end

        function self._registerEnterRegion(whichRegion, filter)
            TriggerRegisterEnterRegion(handle, whichRegion, filter)
            return self
        end

        self.registerEnterRegion = function(whichRegion, filter)
            local status, val = xpcall(self._registerEnterRegion, Log.Error, whichRegion, filter)
            if status then return val end
        end

        function self._registerLeaveRegion(whichRegion, filter)
            TriggerRegisterLeaveRegion(handle, whichRegion, filter)
            return self
        end

        self.registerLeaveRegion = function(whichRegion, filter)
            local status, val = xpcall(self._registerLeaveRegion, Log.Error, whichRegion, filter)
            if status then return val end
        end

        function self._registerTrackableHitEvent(t)
            TriggerRegisterTrackableHitEvent(handle, t)
            return self
        end

        self.registerTrackableHitEvent = function(t)
            local status, val = xpcall(self._registerTrackableHitEvent, Log.Error, t)
            if status then return val end
        end

        function self._registerTrackableTrackEvent(t)
            TriggerRegisterTrackableTrackEvent(handle, t)
            return self
        end

        self.registerTrackableTrackEvent = function(Tan)
            local status, val = xpcall(self._registerTrackableTrackEvent, Log.Error, t)
            if status then return val end
        end

        function self._registerCommandEvent(whichAbility)
            TriggerRegisterCommandEvent(handle, whichAbility)
            return self
        end

        self.registerCommandEvent = function(whichAbility)
            local status, val = xpcall(self._registerCommandEvent, Log.Error, whichAbility)
            if status then return val end
        end

        function self._registerUpgradeCommandEvent(whichUpgrade)
            TriggerRegisterUpgradeCommandEvent(handle, whichUpgrade)
            return self
        end

        self.registerUpgradeCommandEvent = function(whichUpgrade)
            local status, val = xpcall(self._registerUpgradeCommandEvent, Log.Error, whichUpgrade)
            if status then return val end
        end

        function self._registerPlayerEvent(whichPlayer, whichPlayerEvent)
            TriggerRegisterPlayerEvent(handle, whichPlayer.handle, whichPlayerEvent)
            return self
        end

        self.registerPlayerEvent = function(whichPlayer, whichPlayerEvent)
            local status, val = xpcall(self._registerPlayerEvent, Log.Error, whichPlayer, whichPlayerEvent)
            if status then return val end
        end

        function self._registerPlayerUnitEvent(whichPlayer, whichPlayerUnitEvent, filter)
            TriggerRegisterPlayerUnitEvent(handle, whichPlayer.handle, whichPlayerUnitEvent, nil)
            return self
        end

        self.registerPlayerUnitEvent = function(whichPlayer, whichPlayerUnitEvent, filter)
            local status, val = xpcall(self._registerPlayerUnitEvent, Log.Error, whichPlayer, whichPlayerUnitEvent, filter)
            if status then return val end
        end

        function self._registerPlayerAllianceChange(whichPlayer, whichAlliance)
            TriggerRegisterPlayerAllianceChange(handle, whichPlayer.handle, whichAlliance)
            return self
        end

        self.registerPlayerAllianceChange = function(whichPlayer, whichAlliance)
            local status, val = xpcall(self._registerPlayerAllianceChange, Log.Error, whichPlayer, whichAlliance)
            if status then return val end
        end

        function self._registerPlayerStateEvent(varName, opcode, limitval)
            TriggerRegisterPlayerStateEvent(handle, whichPlayer.handle, whichState, lopcode, limitval)
            return self
        end

        self.registerPlayerStateEvent = function(varName, opcode, limitval)
            local status, val = xpcall(self._registerPlayerStateEvent, Log.Error, varName, opcode, limitval)
            if status then return val end
        end

        function self._registerPlayerChatEvent(whichPlayer, chatMessageToDetect, exactMatchOnly)
            TriggerRegisterPlayerChatEvent(handle, whichPlayer.handle, chatMessageToDetect, exactMatchOnly)
            return self
        end

        self.registerPlayerChatEvent = function(whichPlayer, chatMessageToDetect, exactMatchOnly)
            local status, val = xpcall(self._registerPlayerChatEvent, Log.Error, whichPlayer, chatMessageToDetect, exactMatchOnly)
            if status then return val end
        end

        function self._registerDeathEvent(whichWidget)
            TriggerRegisterDeathEvent(handle, whichWidget)
            return self
        end

        self.registerDeathEvent = function(whichWidget)
            local status, val = xpcall(self._registerDeathEvent, Log.Error, whichWidget)
            if status then return val end
        end

        function self._registerUnitStateEvent(whichUnit, whichState, opcode, limitval)
            TriggerRegisterUnitStateEvent(handle, whichUnit.handle, whichState, opcode, limitval)
            return self
        end

        self.registerUnitStateEvent = function(whichUnit, whichState, opcode, limitval)
            local status, val = xpcall(self._registerUnitStateEvent, Log.Error, whichUnit, whichState, opcode, limitval)
            if status then return val end
        end

        function self._registerUnitEvent(whichUnit, whichEvent)
            TriggerRegisterUnitEvent(handle, whichUnit.handle, whichEvent)
            return self
        end

        self.registerUnitEvent = function(whichUnit, whichEvent)
            local status, val = xpcall(self._registerUnitEvent, Log.Error, whichUnit, whichEvent)
            if status then return val end
        end

        function self._registerFilterUnitEvent(whichUnit, whichEvent, filter)
            TriggerRegisterFilterUnitEvent(handle, whichUnit.handle, whichEvent, filter)
            return self
        end

        self.registerFilterUnitEvent = function(whichUnit, whichEvent, filter)
            local status, val = xpcall(self._registerFilterUnitEvent, Log.Error, whichUnit, whichEvent, filter)
            if status then return val end
        end

        function self._registerUnitInRange(whichUnit, range, filter)
            TriggerRegisterUnitInRange(handle, whichUnit.handle, range, filter)
            return self
        end

        self.registerUnitInRange = function(whichUnit, range, filter)
            local status, val = xpcall(self._registerUnitInRange, Log.Error, whichUnit, range, filter)
            if status then return val end
        end

        function self._registerFrameEvent(frame, eventId)
            BlzTriggerRegisterFrameEvent(handle, frame, eventId)
            return self
        end

        self.registerFrameEvent = function(frame, eventId)
            local status, val = xpcall(self._registerFrameEvent, Log.Error, frame, eventId)
            if status then return val end
        end

        function self._registerPlayerSyncEvent(whichPlayer, prefix, fromServer)
            BlzTriggerRegisterPlayerSyncEvent(handle, whichPlayer.handle, prefix, fromServer)
            return self
        end

        self.registerPlayerSyncEvent = function(whichPlayer, prefix, fromServer)
            local status, val = xpcall(self._registerPlayerSyncEvent, Log.Error, whichPlayer, prefix, fromServer)
            if status then return val end
        end

        function self._registerPlayerKeyEvent(whichPlayer, key, metaKey, keyDown)
            BlzTriggerRegisterPlayerKeyEvent(handle, whichPlayer.handle, key, metaKey, keyDown)
            return self
        end

        self.registerPlayerKeyEvent = function(whichPlayer, key, metaKey, keyDown)
            local status, val = xpcall(self._registerPlayerKeyEvent, Log.Error, whichPlayer, key, metaKey, keyDown)
            if status then return val end
        end

        function self._addAction(action)
            TriggerAddAction(handle, action)
            return self
        end

        self.addAction = function(action)
            local status, val = xpcall(self._addAction, Log.Error, action)
            if status then return val end
        end

        return self

    end

    self.Trigger = {}
    self.Trigger.new = function()
        local status, val = xpcall(_Trigger.new, Log.Error)
        if status then return val end
    end

    Trigger = self.Trigger.new

    _EventDispatcher.new = function(types)
        local self = {}
        local events = {}
        local availableTypes = types

        local Event = {}
        Event.new = function(type, callback, argument)
            local self = {}
            self.type = type
            self.callback = callback
            self.condition = nil
            self.argument = argument

            function self._setCondition(filterfunc)
                self.condition = filterfunc
            end

            self.setCondition = function(filterfunc)
                local status, val = xpcall(self._setCondition, Log.Error, filterfunc)
                if status then return val end
            end

            return self
        end

        function self._bind(bindThis, callback, argument)
            for index, eventType in ipairs(availableTypes) do
                if eventType == bindThis then
                    local event = Event.new(eventType, callback, argument)
                    table.insert(events, event)
                    return event
                end
            end
        end

        self.bind = function(bindThis, callback, argument)
            local status, val = xpcall(self._bind, Log.Error, bindThis, callback, argument)
            if status then return val end
        end

        function self._unbind(unbindThis)
            for index, event in ipairs(events) do
                if event == unbindThis then
                    table.remove(events, index)
                    return true
                end
            end
            return false
        end

        self.unbind = function(unbindThis)
            local status, val = xpcall(self._unbind, Log.Error, unbindThis)
            if status then return val end
        end

        function self._dispatch(eventType, source, ...)
            local arg = {...}
            for index, event in ipairs(events) do
                if event.type == eventType then
                    if event.condition == nil then
                        if #arg == 0 then
                            event.callback(source, event.argument)
                        elseif #arg == 1 then
                            event.callback(source, arg[1], event.argument)
                        elseif #arg == 2 then
                            event.callback(source, arg[1], arg[2], event.argument)
                        elseif #arg == 3 then
                            event.callback(source, arg[1], arg[2], arg[3], event.argument)
                        elseif #arg == 4 then
                            event.callback(source, arg[1], arg[2], arg[3], arg[4], event.argument)
                        elseif #arg == 5 then
                            event.callback(source, arg[1], arg[2], arg[3], arg[4], arg[5], event.argument)
                        elseif #arg == 6 then
                            event.callback(source, arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], event.argument)
                        else
                            Log.Error("[EVENT DISPATCHER] Argument Overflow!")
                        end
                    else
                        if #arg == 0 then
                            if event.condition(source, event.argument) then
                                event.callback(source, event.argument)
                            end
                        elseif #arg == 1 then
                            if event.condition(source, arg[1], event.argument) then
                                event.callback(source, arg[1], event.argument)
                            end
                        elseif #arg == 2 then
                            if event.condition(source, arg[1], arg[2], event.argument) then
                                event.callback(source, arg[1], arg[2], event.argument)
                            end
                        elseif #arg == 3 then
                            if event.condition(source, arg[1], arg[2], arg[3], event.argument) then
                                event.callback(source, arg[1], arg[2], arg[3], event.argument)
                            end
                        elseif #arg == 4 then
                            if event.condition(source, arg[1], arg[2], arg[3], arg[4], event.argument) then
                                event.callback(source, arg[1], arg[2], arg[3], arg[4], event.argument)
                            end
                        elseif #arg == 5 then
                            if event.condition(source, arg[1], arg[2], arg[3], arg[4], arg[5], event.argument) then
                                event.callback(source, arg[1], arg[2], arg[3], arg[4], arg[5], event.argument)
                            end
                        elseif #arg == 6 then
                            if event.condition(source, arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], event.argument) then
                                event.callback(source, arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], event.argument)
                            end
                        else
                            Log.Error("[EVENT DISPATCHER] Argument Overflow!")
                        end
                    end
                end
            end
        end

        self.dispatch = function(eventType, source, ...)
            local status, val = xpcall(self._dispatch, Log.Error, eventType, source, ...)
            if status then return val end
        end

        return self
    end

    self.EventDispatcher = {}
    self.EventDispatcher.new = function(types)
        local status, val = xpcall(_EventDispatcher.new, Log.Error, types)
        if status then return val end
    end

    EventDispatcher = self.EventDispatcher.new


    _Effect.new = function()
        local self = {}
        local handle = nil
        local model = nil
        local x = 0.
        local y = 0.
        local z = 0.
        local red = 255
        local green = 255
        local blue = 255
        local alpha = 255
        local scale = 1.0
        local height = 0.
        local timeScale = 1.0
        local yaw = 0.
        local pitch = 0.
        local roll = 0.
        local current
        local mt = {}

        function mt.__newindex(table, index, value)
            if index == "model" then
                if handle == nil then
                    model = value
                else
                    Log.Error("Can't change model of already created effects!")
                end
            elseif index == "x" then
                x = value
                if handle ~= nil then
                    BlzSetSpecialEffectX(handle, x)
                end
            elseif index == "y" then
                y = value
                if handle ~= nil then
                    BlzSetSpecialEffectY(handle, y)
                end
            elseif index == "z" then
                z = value
                if handle ~= nil then
                    BlzSetSpecialEffectZ(handle, z)
                end
            elseif index == "red" then
                red = value
                if handle ~= nil then
                    BlzSetSpecialEffectColor(handle, red, green, blue)
                end
            elseif index == "green" then
                green = value
                if handle ~= nil then
                    BlzSetSpecialEffectColor(handle, red, green, blue)
                end
            elseif index == "blue" then
                blue = value
                if handle ~= nil then
                    BlzSetSpecialEffectColor(handle, red, green, blue)
                end
            elseif index == "alpha" then
                alpha = value
                if handle ~= nil then
                    BlzSetSpecialEffectAlpha(handle, alpha)
                end
            elseif index == "scale" then
                scale = value
                if handle ~= nil then
                    BlzSetSpecialEffectScale(handle, scale)
                end
            elseif index == "height" then
                height = value
                if handle ~= nil then
                    BlzSetSpecialEffectHeight(handle, height)
                end
            elseif index == "timeScale" then
                timeScale = value
                if handle ~= nil then
                    BlzSetSpecialEffectTimeScale(handle, timeScale)
                end
            elseif index == "yaw" then
                yaw = value
                if handle ~= nil then
                    BlzSetSpecialEffectYaw(handle, yaw)
                end
            elseif index == "pitch" then
                pitch = value
                if handle ~= nil then
                    BlzSetSpecialEffectPitch(handle, pitch)
                end
            elseif index == "roll" then
                roll = value
                if handle ~= nil then
                    BlzSetSpecialEffectRoll(handle, roll)
                end
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        function mt.__index(table, index)
            if index == "model" then
                return model
            elseif index == "x" then
                return x
            elseif index == "y" then
                return y
            elseif index == "z" then
                return z
            elseif index == "red" then
                return red
            elseif index == "green" then
                return green
            elseif index == "blue" then
                return blue
            elseif index == "alpha" then
                return alpha
            elseif index == "scale" then
                return scale
            elseif index == "height" then
                return height
            elseif index == "timeScale" then
                return timeScale
            elseif index == "yaw" then
                return yaw
            elseif index == "pitch" then
                return pitch
            elseif index == "roll" then
                return roll
            elseif index == "handle" then
                return handle
            elseif index == "current" then
                return current
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        function self._attachTo(unit, point)
            if handle == nil then
                self.on_create()
                handle = AddSpecialEffectTarget(model, unit.handle, point)
                BlzSetSpecialEffectColor(handle, red, green, blue)
                BlzSetSpecialEffectAlpha(handle, alpha)
                BlzSetSpecialEffectTimeScale(handle, timeScale)
            else
                Log.Error("Effect already is created, please destroy first.")
            end
            return self
        end

        self.attachTo = function(unit, point)
            local status, val = xpcall(self._attachTo, Log.Error, unit, point)
            if status then return val end
        end

        local eventDispatcher = EventDispatcher(
            {"on_create", "on_destroy"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_create()
            eventDispatcher.dispatch("on_create", self)
        end

        self.on_create = function()
            local status, val = xpcall(self._on_create, Log.Error)
            if status then return val end
        end

        function self._on_destroy()
            eventDispatcher.dispatch("on_destroy", self)
        end

        self.on_destroy = function()
            local status, val = xpcall(self._on_destroy, Log.Error)
            if status then return val end
        end

        function self._create()
            if handle == nil then
                self.on_create()
                handle = AddSpecialEffect(model, x, y)
                BlzSetSpecialEffectZ(handle, z)
                BlzSetSpecialEffectColor(handle, red, green, blue)
                BlzSetSpecialEffectAlpha(handle, alpha)
                BlzSetSpecialEffectScale(handle, scale)
                BlzSetSpecialEffectHeight(handle, height)
                BlzSetSpecialEffectTimeScale(handle, timeScale)
                BlzSetSpecialEffectYaw(handle, yaw)
                BlzSetSpecialEffectPitch(handle, pitch)
                BlzSetSpecialEffectRoll(handle, roll)
            else
                Log.Error("Effect already is created, please destroy first.")
            end
            return self
        end

        self.create = function()
            local status, val = xpcall(self._create, Log.Error)
            if status then return val end
        end

        function self._destroy()
            self.on_destroy()
            DestroyEffect(handle)
            handle = nil
            return self
        end

        self.destroy = function()
            local status, val = xpcall(self._destroy, Log.Error)
            if status then return val end
        end

        function self._addSubAnim(subanim)
            BlzSpecialEffectAddSubAnimation(self.handle, subanim)
            return self
        end

        self.addSubAnim = function(subanim)
            local status, val = xpcall(self._addSubAnim, Log.Error, subanim)
            if status then return val end
        end

        function self._removeSubAnim(subanim)
            BlzSpecialEffectRemoveSubAnimation(self.handle, subanim)
            return self
        end

        self.removeSubAnim = function(subanim)
            local status, val = xpcall(self._removeSubAnim, Log.Error, subanim)
            if status then return val end
        end

        function self._play(anim)
            current = anim
            BlzPlaySpecialEffect(self.handle, anim)
            return self
        end

        self.play = function(anim)
            local status, val = xpcall(self._play, Log.Error, anim)
            if status then return val end
        end

        setmetatable(self, mt)

        return self
    end

    self.Effect = {}
    self.Effect.new = function()
        local status, val = xpcall(_Effect.new, Log.Error)
        if status then return val end
    end

    Effect = self.Effect.new

    --[[
        ** Player Structure **
        Available Properties:
            - name [get, set]           -> returns player name
            - id [get]                  -> returns player id
            - color [get, set]          -> returns player color
            - controller [get]          -> returns current controller of player
            - state [get]               -> returns slot state of player
            - team [get, set]           -> returns current team of player
            - selectable [get]          -> returns if player is selectable
            - gold [get, set]           -> returns gold of player
            - lumber [get, set]         -> returns lumber of player
            - foodcap [get, set]        -> returns food cap of player
            - food [get, set]           -> returns current food used by player
            - units [get]               -> returns group of all units player owns
        Available Events:
            - on_leave                  -> triggers when player leaves game
            - on_message                -> triggers when player sends a message
            - on_sync                   -> triggers when a sync finishes
            - on_createUnit             -> triggers when a unit is created for player
        Available Methods:
            - kick()                    -> removes player from game
            - sync()                    -> sends specific data from player to all others
            - createUnit()              -> creates unit for given player
    --]]
    _Player.new = function(player)
        local self = {}
        local handle = Indexer.add(self, player)
        local name = GetPlayerName(handle)
        local units = Group()
        local keyboard = nil
        local id = GetPlayerId(handle)
        local selection = true
        local selectionCircle = true
        local mt = {}

        -- Player Setter
        function mt.__newindex(table, index, value)
            if index == "name" then
                SetPlayerName(handle, value)
                name = value
            elseif index == "color" then
                SetPlayerColor(handle, value)
            elseif index == "team" then
                SetPlayerTeam(handle, value)
            elseif index == "gold" then
                SetPlayerState(handle, PLAYER_STATE_RESOURCE_GOLD, value)
            elseif index == "lumber" then
                SetPlayerState(handle, PLAYER_STATE_RESOURCE_LUMBER, value)
            elseif index == "foodcap" then
                SetPlayerState(handle, PLAYER_STATE_RESOURCE_FOOD_CAP, value)
            elseif index == "food" then
                SetPlayerState(handle, PLAYER_STATE_RESOURCE_FOOD_USED, value)
            elseif index == "keyboard" then
                keyboard = value
            elseif index == "selection" then
                selection = value
                BlzEnableSelections(selection, selectionCircle)
            elseif index == "selectionCircle" then
                selectionCircle = value
                BlzEnableSelections(selection, selectionCircle)
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        -- Player Getter
        function mt.__index(table, index)
            if index == "name" then
                return name
            elseif index == "id" then
                return id
            elseif index == "color" then
                return GetPlayerColor(handle)
            elseif index == "controller" then
                return GetPlayerController(handle)
            elseif index == "state" then
                return GetPlayerSlotState(handle)
            elseif index == "team" then
                return GetPlayerTeam(handle)
            elseif index == "selectable" then
                return GetPlayerSelectable(handle)
            elseif index == "gold" then
                return GetPlayerState(handle, PLAYER_STATE_RESOURCE_GOLD)
            elseif index == "lumber" then
                return GetPlayerState(handle, PLAYER_STATE_RESOURCE_LUMBER)
            elseif index == "foodcap" then
                return GetPlayerState(handle, PLAYER_STATE_RESOURCE_FOOD_CAP)
            elseif index == "food" then
                return GetPlayerState(handle, PLAYER_STATE_RESOURCE_FOOD_USED)
            elseif index == "units" then
                return units
            elseif index == "keyboard" then
                return keyboard
            elseif index == "handle" then
                return handle
            elseif index == "selection" then
                return selection
            elseif index == "selectionCircle" then
                return selectionCircle
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        function self._kick()
            RemovePlayer(handle, PLAYER_GAME_RESULT_NEUTRAL)
        end

        self.kick = function()
            local status, val = xpcall(self._kick, Log.Error)
            if status then return val end
        end

        -- NOT SYNC
        function self._setCameraField(camerafield, value, duration)
            if GetLocalPlayer() == handle then
                SetCameraField(camerafield, value, duration)
            end
        end

        self.setCameraField = function(camerafield, value, duration)
            local status, val = xpcall(self._setCameraField, Log.Error, camerafield, value, duration)
            if status then return val end
        end

        -- NOT SYNC
        function self._getCameraField(camerafield)
            if GetLocalPlayer() == handle then
                return GetCameraField(camerafield)
            end
        end

        self.getCameraField = function(camerafield)
            local status, val = xpcall(self._getCameraField, Log.Error, camerafield)
            if status then return val end
        end

        local syncHandler = {}
        local syncValue = {}
        local syncData = {}
        function self._sync(identifier, data)
            local count = 0
            for index, value in ipairs(syncHandler) do
                count = count + 1
            end
            syncHandler[count] = identifier
            syncValue[count] = 0
            if GetLocalPlayer() == self then
                local part = {}
                local current = 0
                local totalSync = 0
                while StringLength(data) > 0 do
                    if StringLength(data) > 180 then
                        part[current] = SubString(data, 0, 180)
                        data = SubString(data, 180, StringLength(data))
                    else
                        part[current] = data
                        data = ""
                    end
                    totalSync = totalSync + R2I(Pow(2, current))
                    current = current + 1
                end
                local total = current - 1
                for current = 0, total do
                    BlzSendSyncData("avalon",  "id='" .. count .. "'data='" .. part[current] .. "'part='" .. current .. "'total='" .. totalSync .. "'")
                end
            end
            return self
        end

        self.sync = function(identifier, data)
            local status, val = xpcall(self._sync, Log.Error, identifier, data)
            if status then return val end
        end

        function self._createUnit(unitId, x, y, face)
            if type(unitId) == 'number' then
                unit = CreateUnit(handle, unitId, x, y, face)
            else
                unit = CreateUnit(handle, FourCC(unitId), x, y, face)
            end
            _unit = _Unit.new(unit)
            units.append(_unit)
            self.on_createUnit(_unit)
            return _unit
        end

        self.createUnit = function(unitId, x, y, face)
            local status, val = xpcall(self._createUnit, Log.Error, unitId, x, y, face)
            if status then return val end
        end

        local eventDispatcher = EventDispatcher(
            {"on_leave", "on_message", "on_sync", "on_createUnit", "on_unitDeath"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_leave()
            eventDispatcher.dispatch("on_leave", self)
        end

        self.on_leave = function()
            local status, val = xpcall(self._on_leave, Log.Error)
            if status then return val end
        end

        function self._on_message(message)
            eventDispatcher.dispatch("on_message", self, message)
        end

        self.on_message = function(message)
            local status, val = xpcall(self._on_message, Log.Error, message)
            if status then return val end
        end

        function self._on_sync(identifier, data)
            eventDispatcher.dispatch("on_sync", self, identifier, data)
        end

        self.on_sync = function(identifier, data)
            local status, val = xpcall(self._on_sync, Log.Error, identifier, data)
            if status then return val end
        end

        function self._on_createUnit(unit)
            eventDispatcher.dispatch("on_createUnit", self, unit)
        end

        self.on_createUnit = function(unit)
            local status, val = xpcall(self._on_createUnit, Log.Error, unit)
            if status then return val end
        end

        function self._on_unitDeath(unit)
            eventDispatcher.dispatch("on_unitDeath", self, unit)
        end

        self.on_unitDeath = function(unit)
            local status, val = xpcall(self._on_unitDeath, Log.Error, unit)
            if status then return val end
        end

        setmetatable(self, mt)

        do
            Trigger()
            .registerPlayerEvent(self, EVENT_PLAYER_LEAVE)
            .addAction(
                function()
                    Log.Debug("[PLAYER LEAVE] Name: " .. name .. ", Id:" .. id)
                    self.on_leave(self)
                end
            )

            Trigger()
            .registerPlayerChatEvent(self, "", false)
            .addAction(
                function()
                    Log.Debug("[PLAYER MESSAGE] ...")
                    self.on_message(GetEventPlayerChatString())
                end
            )

            Trigger()
            .registerPlayerSyncEvent(self, "avalon", false)
            .addAction(trig,
                function()
                    Log.Debug("[PLAYER SYNC PACKAGE] ...")
                    local raw = BlzGetTriggerSyncData()
                    local id = 0
                    local data = ""
                    local part = 0
                    local total = 0
                    for current = 0, StringLength(raw) do
                        if SubString(raw, current, current + 2) == "id" then
                            current = current + 4
                            local infoStart = current
                            while SubString(raw, current, current + 1) ~= "'" do
                                current = current + 1
                            end
                            local infoEnd = current
                            id = SubString(raw, infoStart, infoEnd)
                        elseif SubString(raw, current, current + 4) == "data" then
                            current = current + 6
                            local infoStart = current
                            while SubString(raw, current, current + 1) ~= "'" do
                                current = current + 1
                            end
                            local infoEnd = current
                            data = SubString(raw, infoStart, infoEnd)
                        elseif SubString(raw, current, current + 4) == "part" then
                            current = current + 6
                            local infoStart = current
                            while SubString(raw, current, current + 1) ~= "'" do
                                current = current + 1
                            end
                            local infoEnd = current
                            part = SubString(raw, infoStart, infoEnd)
                        elseif SubString(raw, current, current + 5) == "total" then
                            current = current + 7
                            local infoStart = current
                            while SubString(raw, current, current + 1) ~= "'" do
                                current = current + 1
                            end
                            local infoEnd = current
                            total = SubString(raw, infoStart, infoEnd)
                        end
                    end
                    syncValue[id] = syncValue[id] + R2I(Pow(2, part))
                    syncData[id][part] = data
                    if syncValue[id] == total then
                        Log.Debug("[PLAYER SYNC COMPLETE] ...")
                        local full = ""
                        for part, content in ipairs(syncData[id]) do
                            full = full + content
                        end
                        self.on_sync(syncHandler[id], full)
                    end
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_DEATH)
            .addAction(
                function()
                    Log.Debug("[UNIT DEATH] ...")
                    self.on_unitDeath(GetTriggerUnit())
                    GetTriggerUnit().on_death()
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_DAMAGING)
            .addAction(
                function()
                    Log.Debug("[UNIT DAMAGE PRE] ...")
                    GetEventDamageSource().on_damage_pre(GetEventDamageTarget(), GetDamageObject())
                    GetEventDamageTarget().on_damaged_pre(GetEventDamageSource(), GetDamageObject())
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_DAMAGED)
            .addAction(
                function()
                    Log.Debug("[UNIT DAMAGE AFTER] ...")
                    GetEventDamageSource().on_damage_after(GetEventDamageTarget(), GetDamageObject())
                    GetEventDamageTarget().on_damaged_after(GetEventDamageSource(), GetDamageObject())
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_ATTACKED)
            .addAction(
                function()
                    Log.Debug("[UNIT ATTACK] ...")
                    GetAttacker().on_attack(GetTriggerUnit())
                    GetTriggerUnit().on_attacked(GetAttacker())
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_HERO_LEVEL)
            .addAction(
                function()
                    Log.Debug("[UNIT LEVEL] ...")
                    GetTriggerUnit().on_level()
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_DROP_ITEM)
            .addAction(
                function()
                    Log.Debug("[UNIT DROP ITEM] ...")
                    GetTriggerUnit().on_drop_item(GetManipulatedItem())
                    GetManipulatedItem().on_drop(GetTriggerUnit())
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_PICKUP_ITEM)
            .addAction(
                function()
                    Log.Debug("[UNIT PICKUP ITEM] ...")
                    GetTriggerUnit().on_pickup_item(GetManipulatedItem())
                    GetManipulatedItem().on_pickup(GetTriggerUnit())
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_USE_ITEM)
            .addAction(
                function()
                    Log.Debug("[UNIT USE ITEM] ...")
                    GetTriggerUnit().on_use_item(GetManipulatedItem())
                    GetManipulatedItem().on_use(GetTriggerUnit())
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_STACK_ITEM)
            .addAction(
                function()
                    Log.Debug("[UNIT STACK ITEM] ...")
                    GetTriggerUnit().on_stack_item(GetManipulatedItem())
                    GetManipulatedItem().on_use(GetTriggerUnit())
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_SPELL_CHANNEL)
            .addAction(
                function()
                    Log.Debug("[UNIT SPELL CHANNEL] ...")
                    GetTriggerUnit().on_spell_channel(GetSpellObject())
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_SPELL_CAST)
            .addAction(
                function()
                    Log.Debug("[UNIT SPELL CAST] ...")
                    GetTriggerUnit().on_spell_cast(GetSpellObject())
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            .addAction(
                function()
                    Log.Debug("[UNIT SPELL EFFECT] ...")
                    GetTriggerUnit().on_spell_effect(GetSpellObject())
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_SPELL_FINISH)
            .addAction(
                function()
                    Log.Debug("[UNIT SPELL FINISH] ...")
                    GetTriggerUnit().on_spell_finish(GetSpellObject())
                end
            )

            Trigger()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
            .addAction(
                function()
                    Log.Debug("[UNIT SPELL END] ...")
                    GetTriggerUnit().on_spell_end(GetSpellObject())
                end
            )
        end

        Log.Debug("Generating new player object for player " .. id)

        return self

    end


    AnimationTransition = {}

    AnimationTransition.linear = function(progress)
        return progress
    end

    AnimationTransition.in_sine = function(progress)
        return 1. - Cos((progress * math.pi) / 2.)
    end

    AnimationTransition.out_sine = function(progress)
        return Sin((progress * math.pi) / 2.)
    end

    AnimationTransition.in_out_sine = function(progress)
        return -(Cos(math.pi * progress) - 1.) / 2.
    end

    AnimationTransition.in_quad = function(progress)
        return progress * progress
    end

    AnimationTransition.out_quad = function(progress)
        return 1. - (1. - progress) * (1. - progress)
    end

    AnimationTransition.in_out_quad = function(progress)
        if progress < 0.5 then
            return 2. * progress * progress
        else
            return 1. - Pow(-2. * progress + 2., 2.) / 2.
        end
    end

    AnimationTransition.in_cubic = function(progress)
        return progress * progress * progress
    end

    AnimationTransition.out_cubic = function(progress)
        return 1. - Pow(1. - progress, 3.)
    end

    AnimationTransition.in_out_cubic = function(progress)
        if progress < 0.5 then
            return 4. * progress * progress * progress
        else
            return 1. - Pow(-2. * progress + 2., 3.) / 2.
        end
    end

    AnimationTransition.in_quart = function(progress)
        return progress * progress * progress * progress
    end

    AnimationTransition.out_quart = function(progress)
        return 1. - Pow(1. - progress, 4.)
    end

    AnimationTransition.in_out_quart = function(progress)
        if progress < 0.5 then
            return 8. * progress * progress * progress * progress
        else
            return 1. - Pow(-2. * progress + 2., 4.) / 2.
        end
    end

    AnimationTransition.in_quint = function(progress)
        return progress * progress * progress * progress * progress
    end

    AnimationTransition.out_quint = function(progress)
        return 1. - Pow(1. - progress, 5.)
    end

    AnimationTransition.in_out_quint = function(progress)
        if progress < 0.5 then
            return 16. * progress * progress * progress * progress * progress
        else
            return 1. - Pow(-2. * progress + 2., 5.) / 2.
        end
    end

    AnimationTransition.in_expo = function(progress)
        if progress == 0. then
            return 0.
        else
            return Pow(2., 10. * progress - 10.)
        end
    end

    AnimationTransition.out_expo = function(progress)
        if progress == 1. then
            return 1.
        else
            return 1. - Pow(2., -10. * progress)
        end
    end

    AnimationTransition.in_out_expo = function(progress)
        if progress == 0. then
            return 0.
        elseif progress == 1. then
            return 1.
        elseif progress < 0.5 then
            return Pow(2., 20. * progress - 10.) / 2.
        else
            return (2. - Pow(2., -20. * progress + 10.)) / 2.
        end
    end

    AnimationTransition.in_circ = function(progress)
        return 1. - math.sqrt(1. - Pow(progress, 2.))
    end

    AnimationTransition.out_circ = function(progress)
        return math.sqrt(1. - Pow(progress - 1., 2.))
    end

    AnimationTransition.in_out_circ = function(progress)
        if progress < 0.5 then
            return (1. - math.sqrt(1. - Pow(2. * progress, 2.))) / 2.
        else
            return (math.sqrt(1. - Pow(-2. * progress + 2., 2.)) + 1.) / 2.
        end
    end

    AnimationTransition.in_back = function(progress)
    local c1 = 1.70158
    local c3 = c1 + 1.

        return c3 * progress * progress * progress - c1 * progress * progress
    end

    AnimationTransition.out_back = function(progress)
    local c1 = 1.70158
    local c3 = c1 + 1.

        return 1. + c3 * Pow(progress - 1., 3.) + c1 * Pow(progress - 1., 2.)
    end

    AnimationTransition.in_out_back = function(progress)
    local c1 = 1.70158
    local c2 = c1 * 1.525

        if progress < 0.5 then
            return (Pow(2. * progress, 2.) * ((c2 + 1.) * 2. * progress - c2)) / 2.
        else
            return (Pow(2. * progress - 2., 2.) * ((c2 + 1.) * (progress * 2. - 2.) + c2) + 2.) / 2.
        end
    end

    AnimationTransition.in_elastic = function(progress)
    local c4 = (2. * math.pi) / 3.

        if progress == 0. then
            return 0.
        elseif progress == 1. then
            return 1.
        else
            return -Pow(2., 10. * progress - 10.) * math.sin((progress * 10. - 10.75) * c4)
        end
    end

    AnimationTransition.out_elastic = function(progress)
    local c4 = (2. * math.pi) / 3.

        if progress == 0. then
            return 0.
        elseif progress == 1. then
            return 1.
        else
            return Pow(2., -10. * progress) * math.sin((progress * 10. - 0.75) * c4) + 1.
        end
    end

    AnimationTransition.in_out_elastic = function(progress)
    local c5 = (2. * math.pi) / 4.5

        if progress == 0. then
            return 0.
        elseif progress == 1. then
            return 1.
        elseif progress < 0.5 then
            return -(Pow(2., 20. * progress - 10.) * math.sin((20. * progress - 11.125) * c5)) / 2.
        else
            return (Pow(2., -20. * progress + 10.) * math.sin((20. * progress - 11.125) * c5)) / 2. + 1.
        end
    end

    AnimationTransition.in_bounce = function(progress)
        return 1. - AnimationTransition.out_bounce(1. - progress)
    end

    AnimationTransition.out_bounce = function(progress)
    local n1 = 7.5625
    local d1 = 2.75
        
        if progress < 1. / d1 then
            return n1 * progress * progress
        elseif progress < 2. / d1 then
            return n1 * Pow(progress - 1.5 / d1, 2.) + 0.75
        elseif progress < 2.5 / d1 then
            return n1 * Pow(progress - 2.25 / d1, 2.) + 0.9375
        else
            return n1 * Pow(progress - 2.625 / d1, 2.) + 0.984375
        end
    end

    AnimationTransition.in_out_bounce = function(progress)
        if progress < 0.5 then
            return (1. - AnimationTransition.out_bounce(1. - 2. * progress)) / 2.
        else
            return (1. + AnimationTransition.out_bounce(2. * progress - 1.)) / 2.
        end
    end

    --[[
    self.Animation = {}
    self.Animation.new = function(duration, transition, step)
        local clock = self.Clock.new()    
        local self = {}
        clock.start()
        
        self.duration = duration or 0.0
        self.transition = AnimationTransition[transition] or AnimationTransition.linear
        self.step = step or 0

        local animatedWidgets = {}
        local AnimatedWidget = {}
        AnimatedWidget.new = function(widget, schedule)
            self.widget = widget
            self.schedule = schedule
            self.duration = nil
            self.transition = nil
        end

        self.loop = false

        function self._update(clock, schedule, widget)
            -- add actual animation handling
            self.on_progress(widget)    -- Dispatches on_progress
            if schedule.runtime >= duration then
                self.stop(widget)
            end
        end

        self.update = function(clock, schedule, widget)
            local status, val = xpcall(self._update, Log.Error, clock, schedule, widget)
            if status then return val end
        end

        function self._start(widget)
            local schedule = clock.schedule_interval(self.update, self.step, widget)
            local animatedWidget = AnimatedWidget.new(widget, schedule)
            table.insert(animatedWidgets, animatedWidget)
            self.on_start(widget)   -- Dispatches on_start
        end

        self.start = function(widget)
            local status, val = xpcall(self._start, Log.Error, widget)
            if status then return val end
        end

        function self._stop(widget)
            for index, animatedWidget in ipairs(animatedWidgets) do
                if animatedWidget.widget == widget then
                    clock.unschedule(animatedWidget.schedule)
                    table.remove(animatedWidgets, index)
                    self.on_complete(widget)    -- Dispatches on_complete
                    return true
                end
            end
            return false
        end

        self.stop = function(widget)
            local status, val = xpcall(self._stop, Log.Error, widget)
            if status then return val end
        end

        function self._stop_all()
            for index, animatedWidget in ipairs(animatedWidgets) do
                clock.unschedule(animatedWidget.schedule)
                table.remove(animatedWidgets, index)
                self.on_complete(animatedWidget.widget)    -- Dispatches on_complete
            end
        end

        self.stop_all = function()
            local status, val = xpcall(self._stop, Log.Error)
            if status then return val end
        end

        local eventDispatcher = EventDispatcher(
            {"on_start", "on_complete", "on_progress"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_start()
            eventDispatcher.dispatch("on_start", self)
        end

        self.on_start = function()
            local status, val = xpcall(self._on_start, Log.Error)
            if status then return val end
        end

        function self._on_complete()
            eventDispatcher.dispatch("on_complete", self)
        end

        self.on_complete = function()
            local status, val = xpcall(self._on_complete, Log.Error)
            if status then return val end
        end

        function self._on_progress(widget)
            eventDispatcher.dispatch("on_progress", self, widget)
        end

        self.on_progress = function(widget)
            local status, val = xpcall(self._on_progress, Log.Error, widget)
            if status then return val end
        end

        return self

    end
    ]]--

    --[[
    -- Engine Widgets
    _Widget = {}
    _Widget.new = function(widgetType)
        local self = BlzCreateFrameByType(widgetType, "", nil, "", 0)
        local visible = true
        local x = nil
        local y = nil
        local right = nil
        local top = nil
        local width = nil
        local height = nil
        local childs = {}
        local parent = nil
        local relative_width = false
        local relative_height = false
        local relative_x = false
        local relative_y = false

        -- Declares height of a widget (relative to parent)
        function _setHeight(newHeight)
            height = newHeight
            self.update()
        end

        local setHeight = function(newHeight)
            local status, val = xpcall(_setHeight, Log.Error, newHeight)
            if status then return val end
        end

        -- Declares width of a widget (relative to parent)
        function _setWidth(newWidth)
            width = newWidth
            self.update()
        end

        local setWidth = function(newWidth) 
            local status, val = xpcall(_setWidth, Log.Error, newWidth)
            if status then return val end
        end

        -- Declares x of a widget (relative to parent)
        function _setX(newX)
            x = newX
            self.update()
        end

        local setX = function(newX) 
            local status, val = xpcall(_setX, Log.Error, newX)
            if status then return val end
        end

        -- Declares y of a widget (relative to parent)
        function _setY(newY)
            y = newY
            self.update()
        end

        local setY = function(newY) 
            local status, val = xpcall(_setY, Log.Error, newY)
            if status then return val end
        end

        -- Declares right of a widget (relative to parent)
        function _setRight(newRight)
            right = newRight
            self.update()
        end

        local setRight = function(newRight)
            local status, val = xpcall(_setRight, Log.Error, newRight)
            if status then return val end
        end

        -- Declares top of a widget (relative to parent)
        function _setTop(newTop)
            top = newTop
            self.update()
        end

        local setTop = function(newTop)
            local status, val = xpcall(_setTop, Log.Error, newTop)
            if status then return val end
        end

        -- Declares if a widget should be visible
        function _setVisible(newVisible)
            visible = newVisible
            BlzFrameSetVisible(self, newVisible)
        end

        local setVisible = function(newVisible)
            local status, val = xpcall(_setVisible, Log.Error, newVisible)
            if status then return val end
        end

        -- Declares if a widget should have relative height
        function _setRelativeHeight(newRelativeHeight)
            relative_height = newRelativeHeight
            BlzFrameSetVisible(self, newRelativeHeight)
        end

        local setRelativeHeight = function(newRelativeHeight)
            local status, val = xpcall(_setRelativeHeight, Log.Error, newRelativeHeight)
            if status then return val end
        end

        -- Widget Setter
        function self.__newindex(index, value)
            if index == "height" then
                setHeight(value)       
            elseif index == "width" then
                setWidth(value)
            elseif index == "x" then
                setX(value)
            elseif index == "y" then
                setY(value)
            elseif index == "right" then
                setRight(value)
            elseif index == "top" then
                setTop(value)
            elseif index == "relative_height" then
                relative_height = value
            elseif index == "relative_width" then
                relative_width = value
            elseif index == "relative_x" then
                relative_x = value
            elseif index == "relative_y" then
                relative_y = value
            elseif index == "visible" then
                setVisible(value)
            end
        end
        
        -- Widget Getter
        function self.__index(index)
            if index == "height" then
                return height
            elseif index == "width" then
                return width
            elseif index == "x" then
                return setX
            elseif index == "y" then
                return y
            elseif index == "right" then
                return right
            elseif index == "top" then
                return top
            elseif index == "visible" then
                return visible
            elseif index == "parent" then
                return parent
            elseif index == "childs" then
                return childs
            elseif index == "relative_height" then
                return relative_height
            elseif index == "relative_width" then
                return relative_width
            elseif index == "relative_x" then
                return relative_x
            elseif index == "relative_y" then
                return relative_y
            end
        end

        -- Returns if a widget is actually visible right now
        function self._isVisible()
            if parent ~= nil and parent.isVisible() and visible then
                return true
            else
                return false
            end
        end

        self.isVisible = function()
            local status, val = xpcall(self._isVisible, Log.Error)
            if status then return val end
        end

        -- Returns the actual width in wc3 coordinates
        function self._absWidth()
            local actualWidth = width or 0.
            if relative_width then
                if x ~= nil and right ~= nil then
                    if width ~= nil then Log.Warn("X and Right provided, width overwritten") end
                    actualWidth = 1.0 - x - right
                end
                return actualWidth * parent.absWidth()
            else
                if x ~= nil and right ~= nil then
                    if width ~= nil then Log.Warn("X and Right provided, width overwritten") end
                    actualWidth = x - right
                end
                return actualWidth
            end
        end
        
        self.absWidth = function()
            local status, val = xpcall(self._absWidth, Log.Error)
            if status then return val end
        end

        -- Returns the actual height in wc3 coordinates
        function self._absHeight()
            local actualHeight = height or 0.
            if relative_width then
                if y ~= nil and top ~= nil then
                    if height ~= nil then Log.Warn("Y and Top provided, height overwritten") end
                    actualHeight = 1.0 - y - top
                end
                return actualHeight * parent.absHeight()
            else
                if y ~= nil and top ~= nil then
                    if height ~= nil then Log.Warn("Y and Top provided, height overwritten") end
                    actualHeight = y - top
                end
                return actualWidth
            end
        end

        self.absHeight = function()
            local status, val = xpcall(self._absHeight, Log.Error)
            if status then return val end
        end

        -- Inits the widget frame
        function self._init(newParent)
            parent = newParent
            BlzFrameSetParent(self, newParent)
            self.update()

            return self
        end

        self.init = function(newParent) 
            local status, val = xpcall(self._init, Log.Error, newParent)
            if status then return val end
        end

        -- Adds widget to this widget
        function self._addWidget(widget)
            table.insert(childs, widget)
            return widget.init(self)
        end

        self.addWidget = function(widget) 
            local status, val = xpcall(self._addWidget, Log.Error, widget)
            if status then return val end
        end

        -- Removes the widget frame
        function self._remove()
            parent = nil
            self.update()
            return self
        end

        self.remove = function() 
            local status, val = xpcall(self._remove, Log.Error)
            if status then return val end
        end

        -- Removes widget from this widget
        function self._removeWidget(widget)
            for index, child in ipairs(childs) do
                if child == widget then
                    table.remove(childs, index)
                end
            end
            return widget.remove()
        end

        self.removeWidget = function(widget) 
            local status, val = xpcall(self._removeWidget, Log.Error, widget)
            if status then return val end
        end

        -- Update Visuals
        function self._update()
            if self.isVisible() then
                Log.Debug("Updating " .. GetHandleId(self))
                local newWidth = self.absWidth()
                local newHeight = self.absHeight()

                BlzFrameClearAllPoints(self)
                if x ~= nil and y ~= nil then
                    local newX = x
                    if relative_x then newX = newX * parent.absWidth() end
                    local newY = y
                    if relative_y then newY = newY * parent.absHeight() end
                    BlzFrameSetPoint(self, FRAMEPOINT_LEFT, parent, FRAMEPOINT_LEFT, newX, newY)
                elseif x ~= nil and top ~= nil then
                    local newX = x
                    if relative_x then newX = newX * parent.absWidth() end
                    local newTop = top
                    if relative_y then newTop = newTop * parent.absHeight() end
                    BlzFrameSetPoint(self, FRAMEPOINT_LEFT, parent, FRAMEPOINT_LEFT, newX, parent.absHeight() - newTop)
                elseif y ~= nil and right ~= nil then
                    local newRight = right
                    if relative_x then newRight = newRight * parent.absWidth() end
                    local newY = y
                    if relative_y then newY = newY * parent.absHeight() end
                    BlzFrameSetPoint(self, FRAMEPOINT_LEFT, parent, FRAMEPOINT_LEFT, parent.absWidth() - newRight, newY)
                end
                BlzFrameSetSize(self, newWidth, newHeight)
                Log.Debug("expected w: " .. newWidth)
                Log.Debug("actual w: " .. BlzFrameGetWidth(self))
                Log.Debug("expected h: " .. newHeight)
                Log.Debug("actual h: " .. BlzFrameGetHeight(self))
                BlzFrameSetVisible(self, true)
            else
                BlzFrameSetVisible(self, false)
            end
            for index, child in ipairs(childs) do
                child.update()
            end
        end

        self.update = function()
            local status, val = xpcall(self._update, Log.Error)
            if status then return val end
        end

        return self

    end

    self.Widget.new = function(widgetType)
        local status, val = xpcall(_Widget.new, Log.Error, widgetType)
        if status then return val end
    end

    _Button = {}
    _Button.new = function()
        local self = _Widget.new('BUTTON')
        
        local eventDispatcher = EventDispatcher(
            {"on_press", "on_release", "on_state"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_press()
            eventDispatcher.dispatch("on_press", self)
        end

        self.on_press = function()
            local status, val = xpcall(self._on_press, Log.Error)
            if status then return val end
        end

        function self._on_release()
            eventDispatcher.dispatch("on_release", self)
        end

        self.on_release = function()
            local status, val = xpcall(self._on_release, Log.Error)
            if status then return val end
        end

        function self._on_state()
            eventDispatcher.dispatch("on_state", self)
        end

        self.on_state = function()
            local status, val = xpcall(self._on_state, Log.Error)
            if status then return val end
        end

        return self
    end

    self.Button.new = function()
        local status, val = xpcall(_Button.new, Log.Error)
        if status then return val end
    end

    _Checkbox = {}
    _Checkbox.new = function()
        local self = _Widget.new('CHECKBOX')
        local eventDispatcher = EventDispatcher(
            {"on_active"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_active()
            eventDispatcher.dispatch("on_active", self)
        end

        self.on_active = function()
            local status, val = xpcall(self._on_active, Log.Error)
            if status then return val end
        end

        return self
    end

    self.Checkbox.new = function()
        local status, val = xpcall(_Checkbox.new, Log.Error)
        if status then return val end
    end

    _Image = {}
    _Image.new = function()
        local self = _Widget.new('BACKDROP')

        return self
    end

    self.Image.new = function()
        local status, val = xpcall(_Image.new, Log.Error)
        if status then return val end
    end

    _Label = {}
    _Label.new = function()
        local self = _Widget.new('TEXT')

        return self
    end

    self.Label.new = function()
        local status, val = xpcall(_Label.new, Log.Error)
        if status then return val end
    end

    _Slider = {}
    _Slider.new = function()
        local self = _Widget.new('SLIDER')
        local eventDispatcher = EventDispatcher(
            {"on_touch_down", "on_touch_move", "on_touch_up"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_touch_down()
            eventDispatcher.dispatch("on_touch_down", self)
        end

        self.on_touch_down = function()
            local status, val = xpcall(self._on_touch_down, Log.Error)
            if status then return val end
        end

        function self._on_touch_move()
            eventDispatcher.dispatch("on_touch_move", self)
        end

        self.on_touch_move = function()
            local status, val = xpcall(self._on_touch_move, Log.Error)
            if status then return val end
        end

        function self._on_touch_up()
            eventDispatcher.dispatch("on_touch_up", self)
        end

        self.on_touch_up = function()
            local status, val = xpcall(self._on_touch_up, Log.Error)
            if status then return val end
        end

        return self
    end

    self.Slider.new = function()
        local status, val = xpcall(_Slider.new, Log.Error)
        if status then return val end
    end

    _ProgressBar = {}
    _ProgressBar.new = function()
        local self = _Widget.new('SIMPLESTATUSBAR')
        local eventDispatcher = EventDispatcher(
            {"on_state"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_state()
            eventDispatcher.dispatch("on_state", self)
        end

        self.on_state = function()
            local status, val = xpcall(self._on_state, Log.Error)
            if status then return val end
        end

        return self
    end

    self.ProgressBar.new = function()
        local status, val = xpcall(_ProgressBar.new, Log.Error)
        if status then return val end
    end

    _TextInput = {}
    _TextInput.new = function()
        local self = _Widget.new('EDITBOX')
        local eventDispatcher = EventDispatcher(
            {"on_enter", "on_text", "on_focus"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_enter()
            eventDispatcher.dispatch("on_enter", self)
        end

        self.on_enter = function()
            local status, val = xpcall(self._on_enter, Log.Error)
            if status then return val end
        end

        function self._on_text()
            eventDispatcher.dispatch("on_text", self)
        end

        self.on_text = function()
            local status, val = xpcall(self._on_text, Log.Error)
            if status then return val end
        end

        function self._on_focus()
            eventDispatcher.dispatch("on_focus", self)
        end

        self.on_focus = function()
            local status, val = xpcall(self._on_focus, Log.Error)
            if status then return val end
        end

        return self
    end

    self.TextInput.new = function()
        local status, val = xpcall(_TextInput.new, Log.Error)
        if status then return val end
    end
    ]]--
    
    -- Engine Keyboard
    _Keyboard.new = function(whichPlayer)
        local self = {}

        local player = whichPlayer
        player.keyboard = self
        local keydown = {}

        -- Keycodes mapping, between str <-> int. These keycodes are
        -- currently taken from common.j. But when a new provider will be
        -- used, it must do the translation to these keycodes too.
        local keycodes = {
            -- specials keys
            ['backspace']= 0x08, ['tab']= 0x09, ['enter']= 0x0D, ['rshift']= 0xA0, ['shift']= 0xA1,
            ['alt']= 0x12, ['rctrl']= 0xA3, ['lctrl']= 0xA2,
            ['super']= 309, ['capslock']= 0x14, ['escape']= 0x1B, 
            ['spacebar']= 0x20, ['pageup']= 0x21, ['pagedown']= 0x22, 
            ['end']= 0x23, ['home']= 0x24, ['left']= 0x25, ['up']=0x26, 
            ['right']= 0x27, ['down']= 0x28, ['insert']= 0x2D, ['delete']= 0x2E,
            ['numlock']= 0x90, ['print']= 0x2A, ['screenlock']= 145, ['pause']= 0x13,

            -- a-z keys
            ['a']= 0x41, ['b']= 0x42, ['c']= 0x43, ['d']= 0x44, ['e']= 0x45, ['f']= 0x46, ['g']= 0x47,
            ['h']= 0x48, ['i']= 0x49, ['j']= 0x4A, ['k']= 0x4B, ['l']= 0x4C, ['m']= 0x4D, ['n']= 0x4E,
            ['o']= 0x4F, ['p']= 0x50, ['q']= 0x51, ['r']= 0x52, ['s']= 0x53, ['t']= 0x54, ['u']= 0x55,
            ['v']= 0x56, ['w']= 0x57, ['x']= 0x58, ['y']= 0x59, ['z']= 0x5A,

            -- 0-9 keys
            ['0']= 0x30, ['1']= 0x31, ['2']= 0x32, ['3']= 0x33, ['4']= 0x34,
            ['5']= 0x35, ['6']= 0x36, ['7']= 0x37, ['8']= 0x38, ['9']= 0x39,

            -- numpad
            ['numpad0']= 0x60, ['numpad1']= 0x61, ['numpad2']= 0x62, ['numpad3']= 0x63,
            ['numpad4']= 0x64, ['numpad5']= 0x65, ['numpad6']= 0x66, ['numpad7']= 0x67,
            ['numpad8']= 0x68, ['numpad9']= 0x69, ['numpaddecimal']= 0x6E,
            ['numpaddivide']= 0x6F, ['numpadmul']= 0x6A, ['numpadsubstract']= 0x6D,
            ['numpadadd']= 0x6B,

            -- F1-24
            ['f1']= 0x70, ['f2']= 0x71, ['f3']= 0x72, ['f4']= 0x73, ['f5']= 0x74, ['f6']= 0x75,
            ['f7']= 0x76, ['f8']= 0x77, ['f9']= 0x78, ['f10']= 0x79, ['f11']= 0x7A, ['f12']= 0x7B,
            ['f13']= 0x7C, ['f14']= 0x7D, ['f15']= 0x7E, ['f16']= 0x7F, ['f17']= 0x80, ['f18']= 0x81,
            ['f19']= 0x82, ['f20']= 0x83, ['f21']= 0x84, ['f22']= 0x85, ['f23']= 0x86, ['f24']= 0x87,
        }

        function self.string_to_keycode(value)
            -- Convert a string to a keycode number according to the keycodes
            -- If the value is not found in the keycodes, it will return -1.
            for string, keycode in pairs(keycodes) do
                if string == value then
                    return keycode
                end
            end

            return -1
        end

        function self.keycode_to_string(value)
            -- Convert a keycode number to a string according to the keycodes
            -- If the value is not found in the keycodes, it will return ''.
            for string, keycode in pairs(keycodes) do
                if keycode == value then
                    return string
                end
            end

            return ''
        end

        local eventDispatcher = EventDispatcher(
            {"on_key_up", "on_key_down"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        -- Fired when user releases a key
        function self._on_key_up(keycode, oskey, metakey)
            local keydata = {keycode, self.keycode_to_string(keycode), oskey}
            eventDispatcher.dispatch("on_key_up", self, keydata, metakey)
        end

        self.on_key_up = function(keycode, oskey, metakey)
            local status, val = xpcall(self._on_key_up, Log.Error, keycode, oskey, metakey)
            if status then return val end
        end

        -- Fired when user presses a key
        function self._on_key_down(keycode, oskey, metakey)
            local keydata = {keycode, self.keycode_to_string(keycode), oskey}
            eventDispatcher.dispatch("on_key_down", self, keydata, metakey)
        end

        self.on_key_down = function(keycode, oskey, metakey)
            local status, val = xpcall(self._on_key_down, Log.Error, keycode, oskey, metakey)
            if status then return val end
        end

        function self._release()
            -- Call this method to release the current keyboard.
            -- This will ensure that the keyboard is no longer attached to your callback.
            self = nil
        end

        self.release = function()
            local status, val = xpcall(self._release, Log.Error)
            if status then return val end
        end

        for index = 8, 255 do
            local keyDown = Trigger()
            keyDown.addAction(
                function()
                    if not keydown[index] then
                        Log.Debug("[KEY DOWN] Keycode: " .. index .. ", Modifier" .. BlzGetTriggerPlayerMetaKey())
                        keydown[index] = true
                        self.on_key_down(index, BlzGetTriggerPlayerKey(), BlzGetTriggerPlayerMetaKey())
                    end
                end
            )

            local keyUp = Trigger()
            keyUp.addAction(
                function()
                    if keydown[index] then
                        Log.Debug("[KEY UP] Keycode: " .. index .. ", Modifier" .. BlzGetTriggerPlayerMetaKey())
                        keydown[index] = false
                        self.on_key_up(index, BlzGetTriggerPlayerKey(), BlzGetTriggerPlayerMetaKey())
                    end
                end
            )

            local key = ConvertOsKeyType(index)
            for metaKey = 0, 15 do
                keyDown.registerPlayerKeyEvent(player, key, metaKey, true)
                keyUp.registerPlayerKeyEvent(player, key, metaKey, false)
            end

            keydown[index] = false
            keyDown = nil
            keyUp = nil
        end

        print("Generated new Keyboard for " .. player.name)

        return self

    end

    -- Engine Window
    _Window.new = function()
        local self = {}
        local handle = BlzGetFrameByName("ConsoleUIBackdrop", 0)
        local childs = {}
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOM, 0.4, 0.)
        BlzFrameSetEnable(handle, false)
        local mt = {}

        -- Sound Getter
        function mt.__index(table, index)
            if index == "width" then
                return BlzGetLocalClientWidth()
            elseif index == "height" then
                return BlzGetLocalClientHeight()
            elseif index == "ratio" then
                return BlzGetLocalClientWidth() / BlzGetLocalClientHeight()
            elseif index == "handle" then
                return handle
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        -- Request Player Keyboard
        function self._request_keyboard(player)
            if player.keyboard ~= nil then return player.keyboard else return _Keyboard.new(player) end
        end

        self.request_keyboard = function(player)
            local status, val = xpcall(self._request_keyboard, Log.Error, player)
            if status then return val end
        end

        --[[
        TimerStart(CreateTimer(), 0.01, true, 
            function()
                if BlzFrameGetWidth(self) / BlzFrameGetHeight(self) ~= self.ratio then
                    BlzFrameSetSize(self, 0.6 * self.ratio, 0.6)
                    for index, child in ipairs(childs) do
                        child.update()
                    end
                end
            end
        )

        -- Adds widget to window
        function self._addWidget(widget)
            table.insert(childs, widget)
            return widget.init(self)
        end

        self.addWidget = function(widget) 
            local status, val = xpcall(self._addWidget, Log.Error, widget)
            if status then return val end
        end

        -- Removes widget from window
        function self._removeWidget(widget)
            for index, child in ipairs(childs) do
                if child == widget then
                    table.remove(childs, index)
                end
            end
            return widget.remove(self)
        end

        self.removeWidget = function(widget) 
            local status, val = xpcall(self._removeWidget, Log.Error, widget)
            if status then return val end
        end
        ]]--

        -- Returns the actual width in wc3 coordinates
        function self._absWidth()
            return 0.6 * self.ratio
        end
        
        self.absWidth = function() 
            local status, val = xpcall(self._absWidth, Log.Error)
            if status then return val end
        end

        -- Returns the actual height in wc3 coordinates
        function self._absHeight()
            return 0.6
        end

        self.absHeight = function() 
            local status, val = xpcall(self._absHeight, Log.Error)
            if status then return val end
        end

        --[[
        -- Returns if the Window is actually visible right now (always true)
        function self._isVisible()
            return true
        end

        self.isVisible = function()
            local status, val = xpcall(self._isVisible, Log.Error)
            if status then return val end
        end
        ]]--

        local eventDispatcher = EventDispatcher(
            {"on_mouse_down", "on_mouse_up", "on_motion"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind
        
        -- Fired when user presses mouse key
        function self._on_mouse_down(player, pos, button)
            eventDispatcher.dispatch("on_mouse_down", self, player, pos, button)
        end

        self.on_mouse_down = function(player, pos, button)
            local status, val = xpcall(self._on_mouse_down, Log.Error, player, pos, button)
            if status then return val end
        end

        -- Fired when user releases mouse key
        function self._on_mouse_up(player, pos, button)
            eventDispatcher.dispatch("on_mouse_up", self, player, pos, button)
        end

        self.on_mouse_up = function(player, pos, button)
            local status, val = xpcall(self._on_mouse_up, Log.Error, player, pos, button)
            if status then return val end
        end

        -- Fired when user moves mouse
        function self._on_motion(player, pos)
            eventDispatcher.dispatch("on_motion", self, player, pos)
        end

        self.on_motion = function(player, pos)
            local status, val = xpcall(self._on_motion, Log.Error, player, pos)
            if status then return val end
        end

        setmetatable(self, mt)

        for pID = 0, 23 do
            Trigger()
            .registerPlayerEvent(Player(pID), EVENT_PLAYER_MOUSE_DOWN)
            .addAction(
                function()
                    if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
                        whichButton = "left"
                    elseif BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_MIDDLE then
                        whichButton = "middle"
                    elseif BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
                        whichButton = "right"
                    end
                    Log.Debug("[MOUSE DOWN] Mouse Button: " .. whichButton)
                    self.on_mouse_down(GetTriggerPlayer(), {BlzGetTriggerPlayerMouseX(), BlzGetTriggerPlayerMouseY()}, {BlzGetTriggerPlayerMouseButton(), whichButton})
                end
            )

            Trigger()
            .registerPlayerEvent(Player(pID), EVENT_PLAYER_MOUSE_UP)
            .addAction(
                function()
                    if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
                        whichButton = "left"
                    elseif BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_MIDDLE then
                        whichButton = "middle"
                    elseif BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
                        whichButton = "right"
                    end
                    Log.Debug("[MOUSE UP] Mouse Button: " .. whichButton)
                    self.on_mouse_up(GetTriggerPlayer(), {BlzGetTriggerPlayerMouseX(), BlzGetTriggerPlayerMouseY()}, {BlzGetTriggerPlayerMouseButton(), whichButton})
                end
            )

            Trigger()
            .registerPlayerEvent(Player(pID), EVENT_PLAYER_MOUSE_MOVE)
            .addAction(
                function()
                    Log.Debug("[MOUSE MOVE] Mouse Position: (" .. BlzGetTriggerPlayerMouseX() .. " | " .. BlzGetTriggerPlayerMouseY() .. ")")
                    self.on_motion(GetTriggerPlayer(), {BlzGetTriggerPlayerMouseX(), BlzGetTriggerPlayerMouseY()})
                end
            )
        end

        return self

    end
    
    -- Engine Clock
    _Clock.new = function()
        local self = {}
        local handle = Indexer.add(self, CreateTimer())
        local schedule_list = {}
        self.running = false

        local Schedule = {}
        Schedule.new = function(callback, interval, argument, loop)
            local self = {}

            self.callback = callback
            self.interval = interval
            self.remaining = interval
            self.argument = argument
            self.loop = loop
            self.runtime = 0.0

            self.condition = nil

            function self._setCondition(filterfunc)
                self.condition = filterfunc
            end

            self.setCondition = function(filterfunc)
                local status, val = xpcall(self._setCondition, Log.Error, filterfunc)
                if status then return val end
            end

            return self
        end

        function self._schedule_once(callback, delay, argument)
            local time = (delay or 0) * 1000    -- convert to miliseconds
            local schedule = Schedule.new(callback, time, argument, false)
            table.insert(schedule_list, schedule)
            Log.Debug("[SCHEDULE_ONCE] A new callback was scheduled.")
            return schedule
        end

        self.schedule_once = function(callback, delay, argument)
            local status, val = xpcall(self._schedule_once, Log.Error, callback, delay, argument)
            if status then return val end
        end

        function self._schedule_interval(callback, delay, argument)
            local time = (delay or 0) * 1000    -- convert to miliseconds
            local schedule = Schedule.new(callback, time, argument, true)
            table.insert(schedule_list, schedule)
            Log.Debug("[SCHEDULE_INTERVAL] A new callback was scheduled.")
            return schedule
        end

        self.schedule_interval = function(callback, delay, argument)
            local status, val = xpcall(self._schedule_interval, Log.Error, callback, delay, argument)
            if status then return val end
        end

        function self._unschedule(unschedule)
            for index, schedule in ipairs(schedule_list) do
                if schedule == unschedule then
                    Log.Debug("[SCHEDULE] A callback was unscheduled.")
                    table.remove(schedule_list, index)
                end
            end
        end

        self.unschedule = function(unschedule)
            local status, val = xpcall(self._unschedule, Log.Error, unschedule)
            if status then return val end
        end

        function self._stop()
            Log.Debug("[CLOCK] A clock was stopped.")
            self.running = false
            PauseTimer(handle)
        end

        self.stop = function()
            local status, val = xpcall(self._stop, Log.Error)
            if status then return val end
        end

        function self._start()
            Log.Debug("[CLOCK] A clock was started.")
            self.running = true
            TimerStart(handle, 0.001, true, self.on_schedule)
        end

        self.start = function()
            local status, val = xpcall(self._start, Log.Error)
            if status then return val end
        end

        function self._on_schedule()
            for index, schedule in ipairs(schedule_list) do
                schedule.remaining = schedule.remaining - 1
                schedule.runtime = schedule.runtime + 1
                if schedule.remaining <= 0 then
                    if schedule.condition == nil then
                        schedule.callback(self, schedule, schedule.argument)
                        Log.Debug("[ON_SCHEDULE] A scheduled callback was performed.")
                        if schedule.loop then
                            schedule.remaining = schedule.interval
                        else
                            table.remove(schedule_list, index)
                        end
                    else
                        if schedule.condition(self, schedule, schedule.argument) then
                            schedule.callback(self, schedule, schedule.argument)
                            Log.Debug("[ON_SCHEDULE] A scheduled callback was performed.")
                        end
                        if schedule.loop then
                            schedule.remaining = schedule.interval
                        else
                            table.remove(schedule_list, index)
                        end
                    end
                end
            end
        end

        self.on_schedule = function()
            local status, val = xpcall(self._on_schedule, Log.Error)
            if status then return val end
        end

        
        return self

    end

    self.Clock = {}
    self.Clock.new = function()
        local status, val = xpcall(_Clock.new, Log.Error)
        if status then return val end
    end

    Clock = self.Clock.new

    _SoundLoader.new = function()
        local self = {}
        local clock = _Clock.new()
        clock.start()

        local Sound = {}
        Sound.new = function(file)
            local self = {}
            local sound = CreateSound(file, false, false, false, 12700, 12700, "")
            local filename = file
            local loop = false
            local volume = 100
            local schedule = nil
            local pitch
            local pos
            local mt = {}

            -- Sound Setter
            function mt.__newindex(table, index, value)
                if index == "loop" then
                    loop = value
                elseif index == "volume" then
                    SetSoundVolume(sound, volume)
                    volume = value
                elseif index == "pos" then
                    SetSoundPlayPosition(sound, miliseconds)
                    pos = value
                elseif index == "pitch" then
                    SetSoundPitch(sound, pitch)
                    pitch = value
                else
                    Log.Error("Unknown attribute '" .. index .. "'.")
                end
            end
            
            -- Sound Getter
            function mt.__index(table, index)
                if index == "filename" then
                    return filename
                elseif index == "loop" then
                    return loop
                elseif index == "volume" then
                    return volume
                elseif index == "pos" then
                    return pos
                elseif index == "pitch" then
                    return pitch
                elseif index == "length" then
                    return GetSoundDuration(sound)
                else
                    Log.Error("Unknown attribute '" .. index .. "'.")
                end
            end

            function self._play()
                if schedule == nil then
                    schedule = clock.schedule_interval(self.update, 0)  -- 0 == each milisecond
                end
                pos = 0
                StartSound(sound)
                self.on_play()
            end

            self.play = function()
                local status, val = xpcall(self._play, Log.Error)
                if status then return val end
            end

            function self._stop()
                if schedule ~= nil then
                    clock.unschedule(schedule)
                    schedule = nil
                end
                StopSound(sound, false, 12700)
                self.on_stop()
            end

            self.stop = function()
                local status, val = xpcall(self._stop, Log.Error)
                if status then return val end
            end

            function self._update()
                pos = pos + 1
                if pos == self.length then
                    if loop then
                        self.play()
                    else
                        self.stop()
                    end
                end
            end

            self.update = function()
                local status, val = xpcall(self._update, Log.Error)
                if status then return val end
            end

            local eventDispatcher = EventDispatcher(
                {"on_play", "on_stop"}
            )
            self.bind = eventDispatcher.bind
            self.unbind = eventDispatcher.unbind

            function self._on_play()
                eventDispatcher.dispatch("on_play", self)
            end

            self.on_play = function()
                local status, val = xpcall(self._on_play, Log.Error)
                if status then return val end
            end

            function self._on_stop()
                eventDispatcher.dispatch("on_stop", self)
            end

            self.on_stop = function()
                local status, val = xpcall(self._on_stop, Log.Error)
                if status then return val end
            end

            return self

        end

        function self._load(file)
            if GetSoundFileDuration(file) > 0 then
                return Sound.new(file)
            end
            error("Request soundfile does not exist.")
        end

        self.load = function(file)
            local status, val = xpcall(self._load, Log.Error, file)
            if status then return val end
        end

        setmetatable(self, mt)

        return self

    end

    self.SoundLoader = {}
    self.SoundLoader.new = function()
        local status, val = xpcall(_SoundLoader.new, Log.Error)
        if status then return val end
    end

    SoundLoader = self.SoundLoader.new

    --[[
        ** Unit Structure **
        Available Properties:
            - hp [get ; set]            -> returns current hp of unit
            - maxhp  [get ; set]        -> returns max hp of unit
            - mp [get ; set]            -> returns current mp of unit
            - maxmp [get ; set]         -> returns max mp of unit
            - name [get ; set]          -> returns name of unit
            - id [get]                  -> returns unit id of unit
            - visible [get ; set]       -> returns visibility state of unit
            - x [get ; set]             -> returns x of unit
            - y [get ; set]             -> returns y of unit
            - face [get ; set]          -> returns unit facing
            - ms [get ; set]            -> returns unit movement speed
            - flyheight [get ; set]     -> returns unit fly height
            - turnspeed [get ; set]     -> returns unit turn speed
            - owner [get ; set]         -> returns unit owner
            - color [get ;set]          -> returns unit color
            - scale [get ; set]         -> returns unit scale
            - timescale [get ; set]     -> returns unit animation speed
            - blendtime [get ; set]     -> returns unit blend time
            - animation [set]           -> sets unit animation
            - str [get ; set]           -> returns list of unit str (base, bonus, total)
            - agi [get ; set]           -> returns list of unit agi (base, bonus, total)
            - int [get ; set]           -> returns list of unit int (base, bonus, total)
            - xp [get ; set]            -> returns unit experience
            - level [get ; set]         -> returns unit level
            - pause [get ; set]         -> returns if unit is paused
            - food [get]                -> returns food used by unit
        Available Events:
            - on_death                  -> triggers on unit death
            - on_remove                 -> triggers on unit remove
            - on_damage_pre             -> triggers when a unit is about to deal damage
            - on_damaged_pre            -> triggers when a unit is about to take damage
            - on_damage_after           -> triggers after a unit dealt damage
            - on_damaged_after          -> triggers after a unit took damage
            - on_level                  -> trigger on unit level up
            - on_drop_item              -> triggers when unit drops item
            - on_pickup_item            -> triggers when unit pickup item
            - on_use_item               -> triggers when unit use item
            - on_stack_item             -> triggers when unit stack item
            - on_spell_channel          -> triggers when unit starts channel spell
            - on_spell_cast             -> triggers when unit starts casting spell
            - on_spell_effect           -> triggers when unit spell effect hits
            - on_spell_finish           -> triggers when unit spell finishes
            - on_spell_end              -> triggers when unit ends casting spell
        Available Methods:
            - inGroup()                 -> returns if unit is in a specific group
            - kill()                    -> kills the unit
            - remove()                  -> removes the unit
    --]]
    _Unit.new = function(unit)
        local self = {}
        local handle = Indexer.add(self, unit)
        local color = GetPlayerColor(_GetOwningPlayer(handle))
        local scale = nil
        local timescale = 1.0
        local blendtime = 1.0
        local movementSpeed = GetUnitMoveSpeed(handle)
        local movementSpeedClock = Clock()
        local manualX = GetUnitX(handle)
        local manualY = GetUnitY(handle)
        movementSpeedClock.schedule_interval(
            function(triggeringClock, triggeringSchedule)
                self.x = self.x + (self.ms / 500) * Cos(bj_DEGTORAD * self.face)
                self.y = self.y + (self.ms / 500) * Sin(bj_DEGTORAD * self.face)
            end, 0.002
        ).setCondition(
            function(triggeringClock, triggeringSchedule)
                return manualX ~= self.x or manualY ~= self.y
            end
        )
        local highMovementSpeedEffect = Effect()
        highMovementSpeedEffect.model = "Effects\\Windwalk Blue Soul.mdx"
        local baseStr = 0
        local baseAgi = 0
        local baseInt = 0
        local strLevel = 0.
        local agiLevel = 0.
        local intLevel = 0.
        local primaryAttribute = 0
        local customStr = 0
        local customAgi = 0
        local customInt = 0

        if IsHeroUnitId(GetUnitTypeId(handle)) then
            -- Capture Hero Stats
            local capturedLevel = GetHeroLevel(handle)
            SetHeroLevel(handle, 1)
            baseStr = GetHeroStr(handle)
            baseAgi = GetHeroAgi(handle)
            baseInt = GetHeroInt(handle)
            strLevel = BlzGetUnitRealField(handle, UNIT_RF_STRENGTH_PER_LEVEL)
            agiLevel = BlzGetUnitRealField(handle, UNIT_RF_AGILITY_PER_LEVEL)
            intLevel = BlzGetUnitRealField(handle, UNIT_RF_INTELLIGENCE_PER_LEVEL)
            primaryAttribute = BlzGetUnitIntegerField(handle, UNIT_IF_PRIMARY_ATTRIBUTE)
            customStr = 0
            customAgi = 0
            customInt = 0
            BlzSetUnitRealField(handle, UNIT_RF_STRENGTH_PER_LEVEL, 0.0)
            BlzSetUnitRealField(handle, UNIT_RF_AGILITY_PER_LEVEL, 0.0)
            BlzSetUnitRealField(handle, UNIT_RF_INTELLIGENCE_PER_LEVEL, 0.0)
            SetHeroLevel(handle, capturedLevel, false)
            capturedLevel = nil
        end
        local mt = {}

        -- Unit Setter
        function mt.__newindex(table, index, value)
            if index == "hp" then
                if value > 0 then
                    SetUnitState(handle, UNIT_STATE_LIFE, value)
                else
                    self.kill()
                end
            elseif index == "maxhp" then
                BlzSetUnitMaxHP(handle, value)
            elseif index == "mp" then
                SetUnitState(handle, UNIT_STATE_MANA, value)
            elseif index == "maxmp" then
                BlzSetUnitMaxMana(handle, value)
            elseif index == "visible" then
                ShowUnit(handle, value)
            elseif index == "x" then
                SetUnitX(handle, value)
                manualX = GetUnitX(handle)
            elseif index == "y" then
                SetUnitY(handle, value)
                manualY = GetUnitY(handle)
            elseif index == "face" then
                SetUnitFacing(handle, value)
            elseif index == "faceEx" then
                BlzSetUnitFacingEx(handle, value)
            elseif index == "ms" then
                if value > 800 then
                    Log.Warn("Movement Speed over cap, reducing to 800...")
                    value = 800
                end
                movementSpeed = value
                if value > 522 then
                    SetUnitMoveSpeed(handle, 522)
                    if not movementSpeedClock.running then
                        self.attachEffect(highMovementSpeedEffect, "origin")
                        movementSpeedClock.start()
                    end
                else
                    SetUnitMoveSpeed(handle, value)
                    if movementSpeedClock.running then
                        highMovementSpeedEffect.destroy()
                        movementSpeedClock.stop()
                    end
                end
            elseif index == "flyheight" then
                SetUnitFlyHeight(handle, value)
            elseif index == "turnspeed" then
                SetUnitTurnSpeed(handle, value)
            elseif index == "owner" then
                GetOwningPlayer(self).units.remove(self)
                SetUnitOwner(handle, value, false)
                value.units.append(handle)
            elseif index == "color" then
                SetUnitColor(handle, value)
                color = value
            elseif index == "scale" then
                SetUnitScale(handle, value, value, value)
                scale = value
            elseif index == "timescale" then
                SetUnitTimeScale(handle, value)
                timescale = value
            elseif index == "blendtime" then
                SetUnitBlendTime(handle, value)
                blendtime = value
            elseif index == "animation" then
                if type(value) == "number" then
                    SetUnitAnimationByIndex(handle, value)
                else
                    SetUnitAnimation(handle, value)
                end
            elseif index == "attackspeed" then
                BlzSetUnitAttackCooldown(handle, 1.0 / value, 0)
            elseif index == "damage" then
                BlzSetUnitBaseDamage(handle, value, 0)
            elseif index == "str" then
                if IsHeroUnitId(GetUnitTypeId(handle)) then
                    customStr = value - GetHeroStr(handle, false)
                    SetHeroStr(handle, value)
                else
                    Log.Error("Can't manipulate strength attribute of non-hero units.")
                end
            elseif index == "agi" then
                if IsHeroUnitId(GetUnitTypeId(handle)) then
                    customAgi = value - GetHeroInt(handle, false)
                    SetHeroAgi(handle, value)
                else
                    Log.Error("Can't manipulate agility attribute of non-hero units.")
                end
            elseif index == "int" then
                if IsHeroUnitId(GetUnitTypeId(handle)) then
                    customInt = value - GetHeroStr(handle, false)
                    SetHeroInt(handle, value)
                else
                    Log.Error("Can't manipulate intelligence attribute of non-hero units.")
                end
            elseif index == "xp" then
                local origExp = GetHeroXP(handle)
                SetHeroXP(handle, value, true)
                self.on_exp(GetHeroXP(handle) - origExp, nil)
            elseif index == "level" then
                if IsHeroUnitId(GetUnitTypeId(handle)) then
                    SetHeroLevel(handle, value, true)
                else
                    BlzSetUnitIntegerField(handle, UNIT_IF_LEVEL, value)
                end
            elseif index == "pause" then
                PauseUnit(handle, value)
            elseif index == "name" then
                BlzSetUnitName(handle, value)
            elseif index == "skin" then
                BlzSetUnitSkin(handle, value)
            elseif index == "invulnerable" then
                SetUnitInvulnerable(handle, value)
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        -- Unit Getter
        function mt.__index(table, index)
            if index == "hp" then
                return GetUnitState(handle, UNIT_STATE_LIFE)
            elseif index == "maxhp" then
                return GetUnitState(handle, UNIT_STATE_MAX_LIFE)
            elseif index == "mp" then
                return GetUnitState(handle, UNIT_STATE_MANA)
            elseif index == "maxmp" then
                return GetUnitState(handle, UNIT_STATE_MAX_MANA)
            elseif index == "name" then
                return GetUnitName(handle)
            elseif index == "id" then
                return GetUnitTypeId(handle)
            elseif index == "x" then
                return GetUnitX(handle)
            elseif index == "y" then
                return GetUnitY(handle)
            elseif index == "z" then
                return BlzGetUnitZ(handle)
            elseif index == "face" then
                return GetUnitFacing(handle)
            elseif index == "ms" then
                return movementSpeed
            elseif index == "flyheight" then
                return GetUnitFlyHeight(handle)
            elseif index == "turnspeed" then
                return GetUnitTurnSpeed(handle)
            elseif index == "owner" then
                return GetOwningPlayer(self)
            elseif index == "color" then
                return color
            elseif index == "scale" then
                return scale
            elseif index == "timescale" then
                return timescale
            elseif index == "blendtime" then
                return blendtime
            elseif index == "visible" then
                return IsUnitVisible(handle)
            elseif index == "attackspeed" then
                return 1.0 / BlzGetUnitAttackCooldown(handle, 0)
            elseif index == "damage" then
                return BlzGetUnitBaseDamage(handle, 0)
            elseif index == "str" then
                if IsHeroUnitId(GetUnitTypeId(handle)) then
                    return {base = GetHeroStr(handle, false), bonus = GetHeroStr(handle, true) - GetHeroStr(handle, false), total = GetHeroStr(handle, true)}
                else
                    Log.Error("Can't retrieve strength attribute of non-hero units.")
                end
            elseif index == "agi" then
                if IsHeroUnitId(GetUnitTypeId(handle)) then
                    return {base = GetHeroAgi(handle, false), bonus = GetHeroAgi(handle, true) - GetHeroAgi(handle, false), total = GetHeroAgi(handle, true)}
                else
                    Log.Error("Can't retrieve agility attribute of non-hero units.")
                end
            elseif index == "int" then
                if IsHeroUnitId(GetUnitTypeId(handle)) then
                    return {base = GetHeroInt(handle, false), bonus = GetHeroInt(handle, true) - GetHeroInt(handle, false), total = GetHeroInt(handle, true)}
                else
                    Log.Error("Can't retrieve intelligence attribute of non-hero units.")
                end
            elseif index == "xp" then
                return GetHeroXP(handle)
            elseif index == "level" then
                if IsHeroUnitId(GetUnitTypeId(handle)) then
                    return GetHeroLevel(handle)
                else 
                    return GetUnitLevel(handle)
                end
            elseif index == "pause" then
                return IsUnitPause(handle)
            elseif index == "food" then
                return GetFoodUsed(handle)
            elseif index == "handle" then
                return handle
            elseif index == "items" then
                local items = {}
                local inventorySize = UnitInventorySize(handle)
                if inventorySize > 0 then
                    for slot = 0, (inventorySize - 1) do
                        items[slot] = UnitItemInSlot(handle, slot)
                    end
                end
                return items
            elseif index == "skin" then
                return BlzGetUnitSkin(handle)
            elseif index == "invulnerable" then
                return BlzIsUnitInvulnerable(handle)
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        function self._inGroup(group)
            return group.inGroup(self)
        end

        self.inGroup = function(group)
            local status, val = xpcall(self._inGroup, Log.Error, group)
            if status then return val end
        end

        function self._kill()
            KillUnit(handle)
        end

        self.kill = function()
            local status, val = xpcall(self._kill, Log.Error)
            if status then return val end
        end

        function self._respawn(spawnPoint)
            ReviveHero(handle, spawnPoint.x, spawnPoint.y, false)
        end

        self.respawn = function(spawnPoint)
            local status, val = xpcall(self._respawn, Log.Error, spawnPoint)
            if status then return val end
        end

        function self._remove()
            self.on_remove()
            RemoveUnit(handle)
            self = nil
        end

        self.remove = function()
            local status, val = xpcall(self._remove, Log.Error)
            if status then return val end
        end

        function self._isEnemy(unit)
            return IsUnitEnemy(unit.handle, self.owner.handle)
        end

        self.isEnemy = function(unit)
            local status, val = xpcall(self._isEnemy, Log.Error, unit)
            if status then return val end
        end

        function self._attachEffect(effect, point)
            return effect.attachTo(self, point)
        end

        self.attachEffect = function(effect, point)
            local status, val = xpcall(self._attachEffect, Log.Error, effect, point)
            if status then return val end
        end

        function self._issueOrder(order, ...)
            local arg = {...}
            if type(order) == "number" then
                if #arg == 0 then
                    IssueImmediateOrderById(handle, order)
                elseif #arg == 1 then
                    IssueTargetOrderById(handle, order, arg[1].handle)
                elseif #arg == 2 then
                    IssuePointOrderById(handle, order, arg[1], arg[2])
                end
            else
                if #arg == 0 then
                    IssueImmediateOrder(handle, order)
                elseif #arg == 1 then
                    IssueTargetOrder(handle, order, arg[1].handle)
                elseif #arg == 2 then
                    IssuePointOrder(handle, order, arg[1], arg[2])
                end
            end
        end

        self.issueOrder = function(order, ...)
            local status, val = xpcall(self._issueOrder, Log.Error, order, ...)
            if status then return val end
        end

        function self._buildOrder(order, x, y)
            if type(order) == "number" then
                IssueBuildOrderById(handle, order, x, y)
            else
                IssueBuildOrder(handle, order, x, y)
            end
        end

        self.buildOrder = function(order, x, y)
            local status, val = xpcall(self._buildOrder, Log.Error, order, x, y)
            if status then return val end
        end

        function self._damageTarget(target, amount, attack, ranged, attackType, damageType, weaponType)
            UnitDamageTarget(handle, target.handle, amount, attack, ranged, attackType, damageType, weaponType)
        end

        self.damageTarget = function(target, amount, attack, ranged, attackType, damageType, weaponType)
            local status, val = xpcall(self._damageTarget, Log.Error, target, amount, attack, ranged, attackType, damageType, weaponType)
            if status then return val end
        end

        function self._hasAbilityOrBuff(objId)
            if type(objId) == "number" then
                return GetUnitAbilityLevel(handle, objId) > 0
            else
                return GetUnitAbilityLevel(handle, FourCC(objId)) > 0
            end
        end

        self.hasBuff = function(buffId)
            local status, val = xpcall(self._hasAbilityOrBuff, Log.Error, buffId)
            if status then return val end
        end

        self.hasAbility = function(abilityId)
            local status, val = xpcall(self._hasAbilityOrBuff, Log.Error, abilityId)
            if status then return val end
        end

        function self._addAbility(abilityId)
            if type(abilityId) == "number" then
                return UnitAddAbility(handle, abilityId)
            else
                return UnitAddAbility(handle, FourCC(abilityId))
            end
        end

        self.addAbility = function(abilityId)
            local status, val = xpcall(self._addAbility, Log.Error, abilityId)
            if status then return val end
        end

        function self._getAbilityLevel(abilityId)
            if type(abilityId) == "number" then
                return GetUnitAbilityLevel(handle, abilityId)
            else
                return GetUnitAbilityLevel(handle, FourCC(abilityId))
            end
        end

        self.getAbilityLevel = function(abilityId)
            local status, val = xpcall(self._getAbilityLevel, Log.Error, abilityId)
            if status then return val end
        end

        function self._setWeaponIntegerField(field, index, value)
            BlzSetUnitWeaponIntegerField(handle, field, index, value)
        end

        self.setWeaponIntegerField = function(field, index, value)
            local status, val = xpcall(self._setWeaponIntegerField, Log.Error, field, index, value)
            if status then return val end
        end

        function self._setWeaponStringField(field, index, value)
            BlzSetUnitWeaponStringField(handle, field, index, value)
        end

        self.setWeaponStringField = function(field, index, value)
            local status, val = xpcall(self._setWeaponStringField, Log.Error, field, index, value)
            if status then return val end
        end

        function self._getWeaponIntegerField(field, index)
            BlzGetUnitWeaponIntegerField(handle, field, index)
        end

        self.getWeaponIntegerField = function(field, index)
            local status, val = xpcall(self._getWeaponIntegerField, Log.Error, field, index)
            if status then return val end
        end

        function self._getWeaponStringField(field, index)
            print(GetHandleId(handle))
            print(field)
            print(index)
            BlzGetUnitWeaponStringField(handle, field, index)
        end

        self.getWeaponStringField = function(field, index)
            local status, val = xpcall(self._getWeaponStringField, Log.Error, field, index)
            if status then return val end
        end

        function self._setVertexColor(red, green, blue, alpha)
            SetUnitVertexColor(handle, red, green, blue, alpha)
        end

        self.setVertexColor = function(red, green, blue, alpha)
            local status, val = xpcall(self._setVertexColor, Log.Error, red, green, blue, alpha)
            if status then return val end
        end

        local eventDispatcher = EventDispatcher(
            {"on_death", "on_remove", 
             "on_damage_pre", "on_damaged_pre", "on_damage_after", "on_damaged_after", 
             "on_attack", "on_attacked",
             "on_exp", "on_level", 
             "on_drop_item", "on_pickup_item", "on_use_item", "on_stack_item",
             "on_spell_channel", "on_spell_cast", "on_spell_effect", "on_spell_finish", "on_spell_end"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_death()
            eventDispatcher.dispatch("on_death", self)
        end

        self.on_death = function()
            local status, val = xpcall(self._on_death, Log.Error)
            if status then return val end
        end

        function self._on_remove()
            eventDispatcher.dispatch("on_remove", self)
        end

        self.on_remove = function()
            local status, val = xpcall(self._on_remove, Log.Error)
            if status then return val end
        end

        function self._on_damage_pre(target, attack)
            eventDispatcher.dispatch("on_damage_pre", self, target, attack)
        end

        self.on_damage_pre = function(target, attack)
            local status, val = xpcall(self._on_damage_pre, Log.Error, target, attack)
            if status then return val end
        end

        function self._on_damaged_pre(source, attack)
            eventDispatcher.dispatch("on_damaged_pre", source, self, attack)
        end

        self.on_damaged_pre = function(source, attack)
            local status, val = xpcall(self._on_damaged_pre, Log.Error, source, attack)
            if status then return val end
        end

        function self._on_damage_after(target, attack)
            eventDispatcher.dispatch("on_damage_after", self, target, attack)
        end

        self.on_damage_after = function(target, attack)
            local status, val = xpcall(self._on_damage_after, Log.Error, target, attack)
            if status then return val end
        end

        function self._on_damaged_after(source, attack)
            eventDispatcher.dispatch("on_damaged_after", source, self, attack)
        end

        self.on_damaged_after = function(source, attack)
            local status, val = xpcall(self._on_damaged_after, Log.Error, source, attack)
            if status then return val end
        end

        function self._on_attack(target)
            eventDispatcher.dispatch("on_attack", self, target)
        end

        self.on_attack = function(target)
            local status, val = xpcall(self._on_attack, Log.Error, target)
            if status then return val end
        end

        function self._on_attacked(source)
            eventDispatcher.dispatch("on_attacked", source, self)
        end

        self.on_attacked = function(source)
            local status, val = xpcall(self._on_attacked, Log.Error, source)
            if status then return val end
        end

        function self._on_exp(amount, source)
            eventDispatcher.dispatch("on_exp", self, amount, source)
        end

        self.on_exp = function(amount, source)
            local status, val = xpcall(self._on_exp, Log.Error, amount, source)
            if status then return val end
        end

        function self._on_level()
            if IsHeroUnitId(GetUnitTypeId(handle)) then
                SetHeroStr(handle, math.floor(baseStr + strLevel * GetHeroLevel(handle) + customStr))
                SetHeroStr(handle, math.floor(baseAgi + agiLevel * GetHeroLevel(handle) + customAgi))
                SetHeroStr(handle, math.floor(baseInt + intLevel * GetHeroLevel(handle) + customInt))
            end
            eventDispatcher.dispatch("on_level", self)
        end

        self.on_level = function()
            local status, val = xpcall(self._on_level, Log.Error)
            if status then return val end
        end

        function self._on_drop_item(item)
            eventDispatcher.dispatch("on_drop_item", self, item)
        end

        self.on_drop_item = function(item)
            local status, val = xpcall(self._on_drop_item, Log.Error, item)
            if status then return val end
        end

        function self._on_pickup_item(item)
            eventDispatcher.dispatch("on_pickup_item", self, item)
        end

        self.on_pickup_item = function(item)
            local status, val = xpcall(self._on_pickup_item, Log.Error, item)
            if status then return val end
        end

        function self._on_use_item(item)
            eventDispatcher.dispatch("on_use_item", self, item)
        end

        self.on_use_item = function(item)
            local status, val = xpcall(self._on_use_item, Log.Error, item)
            if status then return val end
        end

        function self._on_stack_item(item)
            eventDispatcher.dispatch("on_stack_item", self, item)
        end

        self.on_stack_item = function(item)
            local status, val = xpcall(self._on_stack_item, Log.Error, item)
            if status then return val end
        end

        function self._on_spell_channel(spell)
            eventDispatcher.dispatch("on_spell_channel", self, spell)
        end

        self.on_spell_channel = function(spell)
            local status, val = xpcall(self._on_spell_channel, Log.Error, spell)
            if status then return val end
        end

        function self._on_spell_cast(spell)
            eventDispatcher.dispatch("on_spell_cast", self, spell)
        end

        self.on_spell_cast = function(spell)
            local status, val = xpcall(self._on_spell_cast, Log.Error, spell)
            if status then return val end
        end

        function self._on_spell_effect(spell)
            eventDispatcher.dispatch("on_spell_effect", self, spell)
        end

        self.on_spell_effect = function(spell)
            local status, val = xpcall(self._on_spell_effect, Log.Error, spell)
            if status then return val end
        end

        function self._on_spell_finish(spell)
            eventDispatcher.dispatch("on_spell_finish", self, spell)
        end

        self.on_spell_finish = function(spell)
            local status, val = xpcall(self._on_spell_finish, Log.Error, spell)
            if status then return val end
        end

        function self._on_spell_end(spell)
            eventDispatcher.dispatch("on_spell_end", self, spell)
        end

        self.on_spell_end = function(spell)
            local status, val = xpcall(self._on_spell_end, Log.Error, spell)
            if status then return val end
        end

        setmetatable(self, mt)

        return self
    end

    self.Unit = {}
    self.Unit.new = function(player, unitId, x, y, face)
        local status, val = xpcall(_Unit.new, Log.Error, player.createUnit(unitId, x, y, face))
        if status then return val end
    end

    Unit = self.Unit.new

    --[[
        ** Group Structure **
        Available Properties:
            - units [get]   -> returns a list of all units in group
            - size  [get]   -> returns the amount of units in group
        Available Events:
            - on_destroy    -> Triggers when group is destroyed
            - on_clear      -> Triggers when group is cleared
            - on_foreach    -> Triggers when group perfoms forEach
            - on_append     -> Triggers when unit is append to group
            - on_remove     -> Triggers when unit is removed from group
        Available Methods:
            - append()      -> adds a unit to a group
            - remove()      -> removes a unit from a group
            - inGroup()     -> returns if a specific unit is in the group
            - clear()       -> clears a group
            - destroy()     -> destroys a group
            - forEach()     -> performs a given action for all units in group
    --]]
    _Group.new = function(groupList)
        local self = {}
        local units = {}
        local mt = {}

        if groupList then
            for group in groupList do
                for unit in group.units do
                    self.append(unit)
                end
            end
        end

        function self._append(unit)
            for index, value in ipairs(units) do
                if value == unit then
                    return false
                end
            end
            table.insert(units, unit)
            self.on_append(unit)
            return true
        end

        self.append = function(unit)
            local status, val = xpcall(self._append, Log.Error, unit)
            if status then return val end
        end

        function self._remove(unit)
            for index, value in ipairs(units) do
                if value == unit then
                    table.remove(units, index)
                    self.on_remove(unit)
                    return true
                end
            end
            return false
        end

        self.remove = function(unit)
            local status, val = xpcall(self._remove, Log.Error, unit)
            if status then return val end
        end

        function self._inGroup(unit)
            for index, value in ipairs(units) do
                if value == unit then
                    return true
                end
            end
            return false
        end

        self.inGroup = function(unit)
            local status, val = xpcall(self._inGroup, Log.Error, unit)
            if status then return val end
        end

        function mt.__index(table, index)
            if index == "units" then
                return units
            elseif index == "size" then
                local count = 0
                for _ in pairs(units) do count = count + 1 end
                return count
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        function self.__sub(group)
            newGroup = _Group.new({self, group})
            for unit in group.units do
                newGroup.remove(unit)
            end
            return newGroup
        end

        function self.__add(group)
            return _Group.new(
                {self, group}
            )
        end

        function self._clear()
            self.on_clear()
            units = {}
        end
        
        self.clear = function()
            local status, val = xpcall(self._clear, Log.Error)
            if status then return val end
        end

        function self._destroy()
            self.on_destroy()
            self = nil
        end

        self.destroy = function()
            local status, val = xpcall(self._destroy, Log.Error)
            if status then return val end
        end

        function self._forEach(action, ...)
            self.on_foreach()
            for unit in units do
                action(group, unit, ...)
            end
        end

        self.forEach = function(action, ...)
            local status, val = xpcall(self._forEach, Log.Error, action, ...)
            if status then return val end
        end

        local eventDispatcher = EventDispatcher(
            {"on_destroy", "on_clear", "on_foreach", "on_append", "on_remove"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_destroy()
            eventDispatcher.dispatch("on_destroy", self)
        end

        self.on_destroy = function()
            local status, val = xpcall(self._on_destroy, Log.Error)
            if status then return val end
        end

        function self._on_clear()
            eventDispatcher.dispatch("on_clear", self)
        end

        self.on_clear = function()
            local status, val = xpcall(self._on_clear, Log.Error)
            if status then return val end
        end

        function self._on_foreach()
            eventDispatcher.dispatch("on_foreach", self)
        end

        self.on_foreach = function()
            local status, val = xpcall(self._on_foreach, Log.Error)
            if status then return val end
        end

        function self._on_append(unit)
            eventDispatcher.dispatch("on_append", self, unit)
        end

        self.on_append = function(unit)
            local status, val = xpcall(self._on_append, Log.Error, unit)
            if status then return val end
        end

        function self._on_remove(unit)
            eventDispatcher.dispatch("on_remove", self, unit)
        end

        self.on_remove = function(unit)
            local status, val = xpcall(self._on_remove, Log.Error, unit)
            if status then return val end
        end

        setmetatable(self, mt)

        return self
    end

    self.Group = {}
    self.Group.new = function(groupList)
        local status, val = xpcall(_Group.new, Log.Error, groupList)
        if status then return val end
    end

    Group = self.Group.new

    --[[
        ** Item Structure **
        Available Properties:
            - name [get, set]               -> returns item name
            - visible [get, set]            -> returns item visibility state
            - id [get]                      -> returns item id
            - player [get, set]             -> returns item player
            - x [get, set]                  -> returns item x
            - y [get, set]                  -> returns item y
            - invulnerable [get, set]       -> returns item invulnerability state
            - owned [get]                   -> returns if item is owned
            - droppable [get, set]          -> returns if items is droppable
            - powerup [get]                 -> returns if item is a powerup
            - pawnable [get, set]           -> returns if item is pawnable
            - sellable [get]                -> returns if item is sellable
            - level [get]                   -> returns item level
            - type [get]                    -> returns item type
            - charges [get, set]            -> returns item charges
            - description [get, set]        -> returns item description
            - tooltip [get, set]            -> returns item tooltip
            - extendedTooltip [get, set]    -> returns item extended tooltip
            - icon [get, set]               -> returns item icon
            - skin [get, set]               -> returns item skin
        Available Events:
            - on_use        -> triggers when item is used
            - on_drop       -> triggers when item is dropped
            - on_pickup     -> triggers when item is picked up
            - on_stack      -> triggers when item is stacked
            - on_destroy    -> triggers when item is destroyed
    --]]
    _Item.new = function(item)
        local self = {}
        local handle = Indexer.add(self, item)
        local droppable
        local mt = {}

        function mt.__newindex(table, index, value)
            if index == "name" then
                BlzSetItemName(handle, value)
            elseif index == "visible" then
                SetItemVisible(handle, value)
            elseif index == "player" then
                SetItemPlayer(handle, value)
            elseif index == "x" then
                SetItemPosition(handle, value, self.y)
            elseif index == "y" then
                SetItemY(handle, self.x, y)
            elseif index == "invulnerable" then
                SetItemInvulnerable(handle, value)
            elseif index == "droppable" then
                droppable = value
                SetItemDroppable(handle, value)
            elseif index == "pawnable" then
                SetItemPawnable(handle, value)
            elseif index == "charges" then
                SetItemCharges(handle, value)
            elseif index == "description" then
                BlzSetItemDescription(handle, value)
            elseif index == "tooltip" then
                BlzSetItemTooltip(handle, value)
            elseif index == "extendedTooltip" then
                BlzSetItemExtendedTooltip(handle, value)
            elseif index == "icon" then
                BlzSetItemIconPath(handle, value)
            elseif index == "skin" then
                if type(value) == "number" then
                    BlzSetUnitSkin(handle, value)
                else
                    BlzSetUnitSkin(handle, FourCC(value))
                end
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        function mt.__index(index)
            if index == "name" then
                return GetItemName(handle)
            elseif index == "id" then
                return GetItemTypeId(handle)
            elseif index == "visible" then
                return IsItemVisible(handle)
            elseif index == "player" then
                return GetItemPlayer(handle)
            elseif index == "x" then
                return GetItemX(handle)
            elseif index == "y" then
                return GetItemY(handle)
            elseif index == "invulnerable" then
                return IsItemInvulnerable(handle)
            elseif index == "owned" then
                return IsItemOwned(handle)
            elseif index == "droppable" then
                return droppable
            elseif index == "powerup" then
                return IsItemPowerup(handle)
            elseif index == "sellable" then
                return IsItemSellable(handle)
            elseif index == "pawnable" then
                return IsItemPawnable(handle)
            elseif index == "level" then
                return GetItemLevel(handle)
            elseif index == "type" then
                return GetItemType(handle)
            elseif index == "charges" then
                return GetItemCharges(handle)
            elseif index == "description" then
                return BlzGetItemDescription(handle)
            elseif index == "tooltip" then
                return BlzGetItemTooltip(handle)
            elseif index == "extendedTooltip" then
                return BlzGetItemExtendedTooltip(handle)
            elseif index == "icon" then
                return BlzGetItemIconPath(handle)
            elseif index == "skin" then
                return BlzGetUnitSkin(handle)
            elseif index == "handle" then
                return handle
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        local eventDispatcher = EventDispatcher(
            {"on_use", "on_drop", "on_pickup", "on_stack", "on_destroy"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_use(triggerUnit)
            eventDispatcher.dispatch("on_use", self, triggerUnit)
        end

        self.on_use = function(triggerUnit)
            local status, val = xpcall(self._on_use, Log.Error, triggerUnit)
            if status then return val end
        end

        function self._on_drop(triggerUnit)
            eventDispatcher.dispatch("on_drop", self, triggerUnit)
        end

        self.on_drop = function(triggerUnit)
            local status, val = xpcall(self._on_drop, Log.Error, triggerUnit)
            if status then return val end
        end

        function self._on_pickup(triggerUnit)
            eventDispatcher.dispatch("on_pickup", self, triggerUnit)
        end

        self.on_pickup = function(triggerUnit)
            local status, val = xpcall(self._on_pickup, Log.Error, triggerUnit)
            if status then return val end
        end

        function self._on_stack(triggerUnit)
            eventDispatcher.dispatch("on_stack", self, triggerUnit)
        end

        self.on_stack = function(triggerUnit)
            local status, val = xpcall(self._on_stack, Log.Error, triggerUnit)
            if status then return val end
        end

        function self._on_destroy()
            eventDispatcher.dispatch("on_destroy", self)
        end

        self.on_destroy = function()
            local status, val = xpcall(self._on_destroy, Log.Error)
            if status then return val end
        end

        setmetatable(self, mt)

        do
            Trigger()
            .registerDeathEvent(handle)
            .addAction(
                function()
                    Log.Debug("[ITEM DESTROY] ...")
                    self.on_destroy()
                end
            )
        end

        return self
    end

    self.Item = {}
    self.Item.new = function(itemId, x, y)
        local status, val = xpcall(_Item.new, Log.Error, CreateItem(itemId, x, y))
        if status then return val end
    end

    Item = self.Item.new

    self.Player = {}
    for pID = 0, 27 do
        self.Player[pID] = _Player.new(_Player_(pID))
    end

    -- Register pre-placed units
    do
        GroupEnumUnitsInRect(CreateGroup(), GetWorldBounds(), 
            Filter(
                function()
                    _Unit.new(_GetFilterUnit())
                    GetOwningPlayer(GetFilterUnit()).units.append(GetFilterUnit())
                end
            )
        )
    end

    -- Register pre-placed items
    do
        EnumItemsInRect(GetWorldBounds(), 
            Filter(
                function()
                    _Item.new(_GetFilterItem())
                end
            )
        )
    end

    self.Window = _Window.new()

    return self

end





--[[
Wave = {}
Wave.new = function()
    local self = {}
    local waveTimer = Clock()
    local time
    local maxTime = 0
    local units
    local mt = {}

    function mt.__newindex(index, value)
        if index == "maxTime" then
            if maxTime >= 0 then maxTime = value else Log.Warn("Wave Time can't be below 0") end
        else
            Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    function mt.__index(table, index)
        if index == "time" then
            return time
        elseif index == "maxTime" then
            return maxTime
        else
            Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    function self._start()
        self.on_start()
        waveTimer.start()
    end

    function self._resume()
        self.on_resume()
        waveTimer.start()
    end
    
    function self._pause()
        self.on_pause()
        waveTimer.stop()
    end

    function self._end()
        self.on_end()
        waveTimer.stop()
    end

    local eventDispatcher = EventDispatcher(
        {"on_kill", "on_start", "on_resume", "on_pause", "on_end"}
    )
    self.bind = eventDispatcher.bind
    self.unbind = eventDispatcher.unbind

    function self._on_kill()
        eventDispatcher.dispatch("on_kill", self)
    end

    self.on_kill = function()
        local status, val = xpcall(self._on_kill, Log.Error)
        if status then return val end
    end

    function self._on_start()
        eventDispatcher.dispatch("on_start", self)
    end

    self.on_start = function()
        local status, val = xpcall(self._on_start, Log.Error)
        if status then return val end
    end
    
    function self._on_resume()
        eventDispatcher.dispatch("on_resume", self)
    end

    self.on_resume = function()
        local status, val = xpcall(self._on_resume, Log.Error)
        if status then return val end
    end
    
    function self._on_pause()
        eventDispatcher.dispatch("on_pause", self)
    end

    self.on_pause = function()
        local status, val = xpcall(self._on_pause, Log.Error)
        if status then return val end
    end

    function self._on_end()
        eventDispatcher.dispatch("on_end", self)
    end

    self.on_end = function()
        local status, val = xpcall(self._on_end, Log.Error)
        if status then return val end
    end

    setmetatable(self, mt)
    
    return self
end
]]--

Game = {}
Game.new = function()
    local self = {}
    
    local _Spawn = {}
    local _Teleporter = {}
    local _Wildcard = {}
    local ENEMY_PLAYER = Player(PLAYER_NEUTRAL_AGGRESSIVE)

    _Spawn = {}
    _Spawn.new = function()
        local self = {}
        local mt = {}
        local x
        local y

        function mt.__newindex(table, index, value)
            if index == "x" then
                x = value
            elseif index == "y" then
                y = value
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        function mt.__index(table, index)
            if index == "x" then
                return x
            elseif index == "y" then
                return y
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        function self._teleport(unit)
            unit.x = x
            unit.y = y
        end

        self.teleport = function(unit)
            local status, val = xpcall(self._teleport, Log.Error, unit)
            if status then return val end
        end

        setmetatable(self, mt)

        return self

    end

    Spawn = _Spawn.new

    _Teleporter = {}
    _Teleporter.new = function()
        local self = {}
        local mt = {}
        local exit
        local entry

        function mt.__newindex(table, index, value)
            if index == "entry" then
                entry = value
            elseif index == "exit" then
                exit = value
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        function mt.__index(table, index)
            if index == "entry" then
                return entry
            elseif index == "exit" then
                return exit
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end


        setmetatable(self, mt)

        return self
    end

    Teleporter = _Teleporter.new


    -- WIP
    _Wildcard = {}
    _Wildcard.new = function(key)
        local self = {}
        local mt = {}

        function isValid(player, wildcard_key)
            
        end

        return self
    end

    Wildcard = _Wildcard.new

    return self
end

_Abilities = {}
_Abilities.Shadow_Strike = {}
_Abilities.Shadow_Strike.new = function()
    local self = {}
    local disappearEffect = Effect()
    disappearEffect.scale = 0.7
    disappearEffect.model = "Effects\\Soul Discharge Purple.mdx"
    local slashEffect = Effect()
    slashEffect.scale = 2.0
    slashEffect.model = "Effects\\Ephemeral Cut Midnight.mdx"
    local clock = Clock()
    local events = {}

    function self.apply(unit)
        if events.unit == nil then
            events.unit = unit.bind("on_damage_after",
                function(source, target, attack)
                    local damage = GetEventDamage()
                    local x = source.x
                    local y = source.y
                    local x2 = target.x
                    local y2 = target.y
                    local a = Atan2(y2 - y, x2 - x) + 3.14159 + GetRandomReal(-0.436332, 0.436332)
                    local x3 = x + 25 * Cos(a)
                    local y3 = y + 25 * Sin(a)
                    a = Atan2(y2 - y3, x2 - x3)
                    local tempUnit = source.owner.createUnit('hrif', x3, y3, bj_RADTODEG * a)
                    tempUnit.skin = source.skin
                    tempUnit.addAbility('Aloc')
                    tempUnit.setVertexColor(55, 55, 55, 255)
                    tempUnit.attackspeed = source.attackspeed
                    tempUnit.bind("on_attack",
                        function(source, target)
                            source.setWeaponIntegerField(UNIT_WEAPON_IF_ATTACK_TARGETS_ALLOWED, 0, 4)
                        end
                    )
                    tempUnit.bind("on_damage_pre",
                        function(source, target, attack)    
                            BlzSetEventDamage(damage)
                            slashEffect.x = target.x
                            slashEffect.y = target.y
                            slashEffect.create().destroy()
                        end
                    )

                    clock.schedule_once(
                        function(triggeringClock, triggeringSchedule)
                            disappearEffect.x = tempUnit.x
                            disappearEffect.y = tempUnit.y
                            disappearEffect.create().destroy()
                            tempUnit.remove()
                        end, 1.5
                    )
                    tempUnit.issueOrder("attack", target)
                end
            ).setCondition(
                function(source, target, attack)
                    return source.hasAbility('A001') and attack.isAttack
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Blink_Strike = {}
_Abilities.Blink_Strike.new = function()
    local self = {}
    local casterEffect = Effect()
    casterEffect.scale = 0.8
    casterEffect.model = "Effects\\Blink Red Caster.mdx"
    local targetEffect = Effect()
    targetEffect.scale = 0.8
    targetEffect.model = "Effects\\Blink Red Target.mdx"
    local events = {}

    function self.apply(unit)
        if events.unit == nil then
            events.unit = unit.bind("on_damage_after",
                function(source, target, attack)
                    local x = source.x
                    local y = source.y
                    local x2 = target.x
                    local y2 = target.y
                    local a = GetRandomReal(0, 6.28318)
                    local dx = y2 - y
                    local dy = x2 - x
                    local dist = SquareRoot(dx * dx + dy * dy)
                    local x4 = x2 + dist * Cos(a)
                    local y4 = y2 + dist * Sin(a)
                    casterEffect.x = x
                    casterEffect.y = y
                    casterEffect.create().destroy()
                    source.x = x4
                    source.y = y4
                    source.faceEx = bj_RADTODEG * (a + 3.14159)
                    targetEffect.x = x4
                    targetEffect.y = y4
                    targetEffect.create().destroy()
                end
            ).setCondition(
                function(source, target, attack)
                    return source.hasAbility('A001') and attack.isAttack
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    return self
end

_Abilities.Demon_Control = {}
_Abilities.Demon_Control.new = function()
    local self = {}
    local events = {}
    local roarEffect = Effect()
    roarEffect.model = "Abilities\\Spells\\Undead\\UnholyFrenzyAOE\\UnholyFrenzyAOETarget.mdl"
    roarEffect.scale = 2.0
    local clock = Clock()
    
    function self.apply(unit)
        if events.unit == nil then
            local demonEffect = Effect()
            demonEffect.model = "Models\\Manifestation Pride.mdx"
            demonEffect.scale = 2.0
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    local cx = demonEffect.x
                    local cy = demonEffect.y
                    local cz = demonEffect.z
                    local a = unit.face + 180.
                    local tx = unit.x + 95. * Cos(bj_DEGTORAD * a)
                    local ty = unit.y + 95. * Sin(bj_DEGTORAD * a)
                    local tz = unit.z + 50.
                    local dx = tx - cx
                    local dy = ty - cy
                    local dist = SquareRoot(dx * dx + dy * dy)
                    if dist > 1. then
                        local increment = 1. + 1.2 * dist / 70
                        local rad = Atan2(ty - cy, tx - cx)
                        demonEffect.x = cx + increment * Cos(rad)
                        demonEffect.y = cy + increment * Sin(rad)
                    else
                        demonEffect.x = tx
                        demonEffect.y = ty
                    end
                    if RAbsBJ(tz - cz) > 1. then
                        local increment = 1. + 0.6 * dist / 70
                        if tz > cz then
                            demonEffect.z = cz + increment
                        else
                            demonEffect.z = cz - increment
                        end
                    else
                        demonEffect.z = tz
                    end
                    demonEffect.yaw = Atan2(unit.y - cy, unit.x - cx)
                end, 0.005
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    if unit.hasAbility('A001') then
                        if demonEffect.handle == nil then
                            demonEffect.create()
                        end
                        return true
                    else
                        if demonEffect.handle ~= nil then
                            demonEffect.destroy()
                        end
                        return false
                    end
                end
            )
            local attackCount = 0
            local casting = false
            events.unit = unit.bind("on_damage_after",
                function(source, target, attack)
                    attackCount = attackCount + 1
                    if attackCount >= 50 and not casting then
                        attackCount = 0
                        casting = true
                        roarEffect.x = demonEffect.x
                        roarEffect.y = demonEffect.y
                        roarEffect.z = demonEffect.z
                        roarEffect.create().destroy()
                        demonEffect.addSubAnim(SUBANIM_TYPE_SLAM).play(ANIM_TYPE_SPELL).removeSubAnim(SUBANIM_TYPE_SLAM)
                        clock.schedule_once(
                            function()
                                casting = false
                                demonEffect.play(ANIM_TYPE_STAND)
                            end, 1.1
                        )
                    end
                end
            ).setCondition(
                function(source, target, attack)
                    return source.hasAbility('A001')
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Blade_Dance = {}
_Abilities.Blade_Dance.new = function()
    local self = {}
    local events = {}
    local bladeEffect = Effect()
    bladeEffect.model = "Effects\\Ephemeral Slash Purple.mdx"
    local bloodEffect = Effect()
    bloodEffect.model = "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl"
    bloodEffect.scale = 1.2
    local clock = Clock()
    local group = CreateGroup()
    
    function self.apply(unit)
        if events.unit == nil then
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    bladeEffect.x = unit.x
                    bladeEffect.y = unit.y
                    bladeEffect.height = GetRandomReal(30., 100.)
                    bladeEffect.timeScale = GetRandomReal(0.8, 1.3)
                    bladeEffect.yaw = GetRandomReal(0., 6.26573)
                    bladeEffect.create().destroy()
                    GroupEnumUnitsInRange(group, unit.x, unit.y, 150., 
                        Filter(
                            function()
                                local target = GetFilterUnit()
                                if unit.isEnemy(target) then
                                    bloodEffect.x = target.x
                                    bloodEffect.y = target.y
                                    bloodEffect.create().destroy()
                                    unit.damageTarget(target, unit.damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE) 
                                end
                            end
                        )
                    )
                end, 0.05
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    return unit.hasAbility('A001')
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Possessed = {}
_Abilities.Possessed.new = function()
    local self = {}
    local events = {}
    local clock = Clock()
    
    function self.apply(unit)
        if events.unit == nil then
            local auraEffect = Effect()
            auraEffect.model = "Effects\\Fountain of Souls.mdx"
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    auraEffect.x = unit.x
                    auraEffect.y = unit.y
                    auraEffect.z = unit.z
                end, 0.01
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    if unit.hasAbility('A001') then
                        if auraEffect.handle == nil then
                            auraEffect.create()
                        end
                        return true
                    else
                        if auraEffect.handle ~= nil then
                            auraEffect.destroy()
                        end
                        return false
                    end
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

--_Abilities.Reaper_1 = {}
--_Abilities.Reaper_1.new = function()
--    local self = {}
--    local events = {}
--    local clock = Clock()
--    
--    function self.apply(unit)
--        if events.unit == nil then
--            local summonEffect = Effect()
--            summonEffect.model = "Models\\Reaper 1.mdx"
--            summonEffect.scale = 1.5
--            local tx = nil
--            local ty = nil
--            clock.schedule_interval(
--                function(triggeringClock, triggeringSchedule)
--                    if tx == nil or ty == nil then
--                        tx = summonEffect.x
--                        ty = summonEffect.y
--                    end
--                    local cx = summonEffect.x
--                    local cy = summonEffect.y
--                    local a = unit.face + 180.
--                    local ux = unit.x
--                    local uy = unit.y
--                    local dx = tx - ux
--                    local dy = ty - uy
--                    local dist = SquareRoot(dx * dx + dy * dy)
--                    if dist > 800. then
--                        local otherDist = GetRandomReal(400, 600)
--                        local rad = GetRandomReal(0., math.pi * 2)
--                        tx = ux + otherDist * Cos(rad)
--                        ty = uy + otherDist * Sin(rad)
--                    else
--                        local dx = tx - cx
--                        local dy = ty - cy
--                        local dist = SquareRoot(dx * dx + dy * dy)
--                        if dist > 1. then
--                            local rad = Atan2(dy, dx)
--                            local increment = 0.
--                            if RAbsBJ(summonEffect.yaw - rad) > 0.001 then
--                                local diff = RAbsBJ(summonEffect.yaw - rad)
--                                increment = 0. * (math.pi - diff) / math.pi
--                                if diff > 0.035 then
--                                    if summonEffect.yaw < rad then
--                                        summonEffect.yaw = summonEffect.yaw + 0.034
--                                    else
--                                        summonEffect.yaw = summonEffect.yaw - 0.034
--                                    end
--                                    if summonEffect.yaw > math.pi * 2 then
--                                        summonEffect.yaw = summonEffect.yaw - math.pi * 2
--                                    end
--                                else
--                                    summonEffect.yaw = rad
--                                end
--                            else
--                                increment = 0.3 + 0.1 * dist / 70
--                            end
--                            summonEffect.x = cx + increment * Cos(rad)
--                            summonEffect.y = cy + increment * Sin(rad)
--                            if increment > 0.05 then
--                                if summonEffect.current ~=  ANIM_TYPE_WALK then
--                                    summonEffect.play(ANIM_TYPE_WALK)
--                                end
--                            end
--                        elseif dist > 0.01 then
--                            summonEffect.x = tx
--                            summonEffect.y = ty
--                        elseif GetRandomInt(0, 1000) == 1 then
--                            local otherDist = GetRandomReal(400, 700)
--                            local rad = GetRandomReal(0., math.pi * 2)
--                            tx = ux + otherDist * Cos(rad)
--                            ty = uy + otherDist * Sin(rad)
--                        else
--                            if summonEffect.current ~=  ANIM_TYPE_STAND then
--                                summonEffect.play(ANIM_TYPE_STAND)
--                            end
--                        end
--                    end
--                end, 0.005
--            ).setCondition(
--                function(triggeringClock, triggeringSchedule)
--                    if unit.hasAbility('A005') then
--                        if summonEffect.handle == nil then
--                            local distance = GetRandomReal(0, 400)
--                            local rad = GetRandomReal(0., math.pi * 2)
--                            summonEffect.yaw = GetRandomReal(0., math.pi * 2)
--                            summonEffect.x = unit.x + distance * Cos(rad)
--                            summonEffect.y = unit.y + distance * Sin(rad)
--                            summonEffect.create()
--                        end
--                        return true
--                    else
--                        if summonEffect.handle ~= nil then
--                            summonEffect.destroy()
--                        end
--                        return false
--                    end
--                end
--            )
--        end
--    end
--
--    function self.remove(unit)
--        if events.unit ~= nil then
--            unit.unbind(events.unit)
--            events.unit = nil
--        end
--    end
--
--    clock.start()
--
--    return self
--end

_Abilities.Reaper_1 = {}
_Abilities.Reaper_1.new = function()
    local self = {}
    local events = {}
    local clock = Clock()
    local slashEffect = Effect()
    slashEffect.scale = 2.0
    slashEffect.model = "Effects\\Coup de Grace Purple.mdx"
    
    function self.apply(unit)
        if events.unit == nil then
            local summonUnit = nil 
            local tx = nil
            local ty = nil
            local auraEffect = Effect()
            auraEffect.model = "Effects\\Malevolence Aura Purple.mdx"
            auraEffect.scale = 1.5
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    if tx == nil or ty == nil then
                        tx = summonUnit.x
                        ty = summonUnit.y
                    end
                    local cx = summonUnit.x
                    local cy = summonUnit.y
                    local a = unit.face + 180.
                    local ux = unit.x
                    local uy = unit.y
                    local dx = tx - ux
                    local dy = ty - uy
                    local dist = SquareRoot(dx * dx + dy * dy)
                    auraEffect.x = summonUnit.x
                    auraEffect.y = summonUnit.y
                    auraEffect.z = summonUnit.z
                    if dist > 800. then
                        local otherDist = GetRandomReal(400, 600)
                        local rad = GetRandomReal(0., math.pi * 2)
                        tx = ux + otherDist * Cos(rad)
                        ty = uy + otherDist * Sin(rad)
                        summonUnit.issueOrder("move", tx, ty)
                    else
                        local dx = tx - cx
                        local dy = ty - cy
                        local dist = SquareRoot(dx * dx + dy * dy)
                        if dist > 1. then
                            local rad = Atan2(dy, dx)
                            local increment = 200 + 200 * 0.03 * dist / 70
                            summonUnit.ms = increment
                        elseif GetRandomInt(0, 1000) == 1 then
                            local otherDist = GetRandomReal(400, 700)
                            local rad = GetRandomReal(0., math.pi * 2)
                            tx = ux + otherDist * Cos(rad)
                            ty = uy + otherDist * Sin(rad)
                            summonUnit.issueOrder("move", tx, ty)
                        end
                    end
                end, 0.005
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    if unit.hasAbility('A005') then
                        if summonUnit == nil then
                            local distance = GetRandomReal(0, 400)
                            local deg = GetRandomReal(0., 360.)
                            local rad = deg * bj_DEGTORAD
                            summonUnit = unit.owner.createUnit('h001', unit.x + distance * Cos(rad), unit.y + distance * Sin(rad), deg)
                            summonUnit.addAbility('Aloc')
                            auraEffect.create()
                            summonUnit.bind("on_attack",
                                function(source, target)
                                    local rad = Atan2(target.y - source.y, target.x - source.x)
                                    slashEffect.x = source.x + 50. * Cos(rad)
                                    slashEffect.y = source.y + 50. * Sin(rad)
                                    slashEffect.yaw = rad
                                    slashEffect.create().destroy()
                                end
                            )
                            summonUnit.bind("on_damage_pre",
                                function(source, target, attack)
                                    BlzSetEventDamage(0)
                                    unit.damageTarget(target, unit.damage * 5.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE)
                                end
                            )
                            --summonUnit.setWeaponIntegerField(UNIT_WEAPON_IF_ATTACK_TARGETS_ALLOWED, 0, 4)
                        end
                        return true
                    else
                        if summonUnit ~= nil then
                            auraEffect.destroy()
                            summonUnit.remove()
                        end
                        return false
                    end
                end
            )
            unit.bind("on_damage_after",
                function(source, target, attack)
                    summonUnit.issueOrder("attack", target)
                end
            ).setCondition(
                function(source, target, attack)
                    return source.hasAbility('A005') and attack.isAttack and summonUnit ~= nil
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Reaper_2 = {}
_Abilities.Reaper_2.new = function()
    local self = {}
    local events = {}
    local clock = Clock()
    local group = CreateGroup()
    local explodeEffect = Effect()
    explodeEffect.model = "Effects\\Soul Discharge Red.mdx"
    
    function self.apply(unit)
        if events.unit == nil then
            local summonUnit = nil 
            local tx = nil
            local ty = nil 
            local cooldown = 0
            local auraEffect = Effect()
            auraEffect.model = "Effects\\Malevolence Aura Red.mdx"
            auraEffect.scale = 1.5
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    auraEffect.x = summonUnit.x
                    auraEffect.y = summonUnit.y
                    auraEffect.z = summonUnit.z
                    if cooldown > 0 then
                        cooldown = cooldown - 1
                    end
                    if cooldown <= 0 then
                        if tx == nil or ty == nil then
                            tx = summonUnit.x
                            ty = summonUnit.y
                        end
                        local cx = summonUnit.x
                        local cy = summonUnit.y
                        local a = unit.face + 180.
                        local ux = unit.x
                        local uy = unit.y
                        local dx = tx - ux
                        local dy = ty - uy
                        local dist = SquareRoot(dx * dx + dy * dy)
                        if dist > 800. then
                            local otherDist = GetRandomReal(400, 600)
                            local rad = GetRandomReal(0., math.pi * 2)
                            tx = ux + otherDist * Cos(rad)
                            ty = uy + otherDist * Sin(rad)
                            summonUnit.issueOrder("move", tx, ty)
                        else
                            local dx = tx - cx
                            local dy = ty - cy
                            local dist = SquareRoot(dx * dx + dy * dy)
                            if dist > 1. then
                                local rad = Atan2(dy, dx)
                                local increment = 200 + 200 * 0.03 * dist / 70
                                summonUnit.ms = increment
                            elseif GetRandomInt(0, 1000) == 1 then
                                local otherDist = GetRandomReal(400, 700)
                                local rad = GetRandomReal(0., math.pi * 2)
                                tx = ux + otherDist * Cos(rad)
                                ty = uy + otherDist * Sin(rad)
                                summonUnit.issueOrder("move", tx, ty)
                            end
                        end
                    end
                end, 0.005
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    if unit.hasAbility('A005') then
                        if summonUnit == nil then
                            local distance = GetRandomReal(0, 400)
                            local deg = GetRandomReal(0., 360.)
                            local rad = deg * bj_DEGTORAD
                            summonUnit = unit.owner.createUnit('h002', unit.x + distance * Cos(rad), unit.y + distance * Sin(rad), deg)
                            summonUnit.addAbility('Aloc')
                            auraEffect.create()
                            summonUnit.bind("on_attack",
                                function(source, target)
                                    BlzUnitInterruptAttack(source.handle)
                                    cooldown = math.floor(9.3 / 0.005)
                                    local rad = (source.face - 5.) * bj_DEGTORAD
                                    local x = source.x + 295. * Cos(rad)
                                    local y = source.y + 295. * Sin(rad)
                                    source.animation = "Spell Eight"
                                    clock.schedule_once(
                                        function(triggeringClock, triggeringSchedule)
                                            local dist = 0
                                            clock.schedule_interval(
                                                function(triggeringClock, triggeringSchedule)
                                                    dist = dist + 100
                                                    for i = 0, 12 do
                                                        local rad = i * 0.5236
                                                        local x2 = x + dist * Cos(rad)
                                                        local y2 = y + dist * Sin(rad)
                                                        explodeEffect.x = x2
                                                        explodeEffect.y = y2
                                                        explodeEffect.create().destroy()
                                                        GroupEnumUnitsInRange(group, x2, y2, 150., 
                                                            Filter(
                                                                function()
                                                                    local target = GetFilterUnit()
                                                                    if unit.isEnemy(target) then
                                                                        unit.damageTarget(target, unit.damage * 30., false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                                                    end
                                                                end
                                                            )
                                                        )
                                                    end
                                                    if dist >= 500 then
                                                        clock.unschedule(triggeringSchedule)
                                                    end
                                                end, 0.05
                                            )
                                        end, 2.30
                                    )
                                end
                            )
                            --summonUnit.setWeaponIntegerField(UNIT_WEAPON_IF_ATTACK_TARGETS_ALLOWED, 0, 4)
                        end
                        return true
                    else
                        if summonUnit ~= nil then
                            auraEffect.destroy()
                            summonUnit.remove()
                        end
                        return false
                    end
                end
            )
            unit.bind("on_damage_after",
                function(source, target, attack)
                    summonUnit.issueOrder("attack", target)
                end
            ).setCondition(
                function(source, target, attack)
                    return source.hasAbility('A005') and attack.isAttack and summonUnit ~= nil and cooldown <= 0.
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Reaper_3 = {}
_Abilities.Reaper_3.new = function()
    local self = {}
    local events = {}
    local clock = Clock()
    local group = CreateGroup()
    local bloodEffect = Effect()
    bloodEffect.model = "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl"
    bloodEffect.scale = 1.2
    
    function self.apply(unit)
        if events.unit == nil then
            local summonUnit = nil 
            local tx = nil
            local ty = nil 
            local casting = false
            local auraEffect = Effect()
            auraEffect.model = "Effects\\Malevolence Aura Blue.mdx"
            auraEffect.scale = 1.5
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    auraEffect.x = summonUnit.x
                    auraEffect.y = summonUnit.y
                    auraEffect.z = summonUnit.z
                    if not casting then
                        if tx == nil or ty == nil then
                            tx = summonUnit.x
                            ty = summonUnit.y
                        end
                        local cx = summonUnit.x
                        local cy = summonUnit.y
                        local a = unit.face + 180.
                        local ux = unit.x
                        local uy = unit.y
                        local dx = tx - ux
                        local dy = ty - uy
                        local dist = SquareRoot(dx * dx + dy * dy)
                        if dist > 800. then
                            local otherDist = GetRandomReal(400, 600)
                            local rad = GetRandomReal(0., math.pi * 2)
                            tx = ux + otherDist * Cos(rad)
                            ty = uy + otherDist * Sin(rad)
                            summonUnit.issueOrder("move", tx, ty)
                        else
                            local dx = tx - cx
                            local dy = ty - cy
                            local dist = SquareRoot(dx * dx + dy * dy)
                            if dist > 1. then
                                local rad = Atan2(dy, dx)
                                local increment = 200 + 200 * 0.03 * dist / 70
                                summonUnit.ms = increment
                            elseif GetRandomInt(0, 1000) == 1 then
                                local otherDist = GetRandomReal(400, 700)
                                local rad = GetRandomReal(0., math.pi * 2)
                                tx = ux + otherDist * Cos(rad)
                                ty = uy + otherDist * Sin(rad)
                                summonUnit.issueOrder("move", tx, ty)
                            end
                        end
                    end
                end, 0.005
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    if unit.hasAbility('A005') then
                        if summonUnit == nil then
                            local distance = GetRandomReal(0, 400)
                            local deg = GetRandomReal(0., 360.)
                            local rad = deg * bj_DEGTORAD
                            summonUnit = unit.owner.createUnit('h006', unit.x + distance * Cos(rad), unit.y + distance * Sin(rad), deg)
                            summonUnit.addAbility('Aloc')
                            auraEffect.create()
                            summonUnit.bind("on_attack",
                                function(source, target)
                                    casting = true
                                    BlzUnitInterruptAttack(source.handle)
                                    local rad = Atan2(target.y - source.y, target.x - source.x)
                                    local x = source.x
                                    local y = source.y
                                    source.animation = 4
                                    clock.schedule_once(
                                        function(triggeringClock, triggeringSchedule)
                                            local progress = 0.0
                                            local cosRes = Cos(rad)
                                            local sinRes = Sin(rad)
                                            source.animation = 11
                                            clock.schedule_interval(
                                                function(triggeringClock, triggeringSchedule)
                                                    progress = progress + 0.005
                                                    local dist = 1000 * AnimationTransition.in_out_sine(progress)
                                                    local x2 = x + dist * cosRes
                                                    local y2 = y + dist * sinRes
                                                    source.x = x2
                                                    source.y = y2
                                                    GroupEnumUnitsInRange(group, x2, y2, 150., 
                                                        Filter(
                                                            function()
                                                                local target = GetFilterUnit()
                                                                if unit.isEnemy(target) then
                                                                    bloodEffect.x = target.x
                                                                    bloodEffect.y = target.y
                                                                    bloodEffect.create().destroy()
                                                                    unit.damageTarget(target, unit.damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                                                end
                                                            end
                                                        )
                                                    )
                                                    if progress >= 1. then
                                                        casting = false
                                                        source.animation = "stand"
                                                        clock.unschedule(triggeringSchedule)
                                                    end
                                                end, 0.01
                                            )
                                        end, 1.0
                                    )
                                end
                            )
                            --summonUnit.setWeaponIntegerField(UNIT_WEAPON_IF_ATTACK_TARGETS_ALLOWED, 0, 4)
                        end
                        return true
                    else
                        if summonUnit ~= nil then
                            auraEffect.destroy()
                            summonUnit.remove()
                        end
                        return false
                    end
                end
            )
            unit.bind("on_damage_after",
                function(source, target, attack)
                    summonUnit.issueOrder("attack", target)
                end
            ).setCondition(
                function(source, target, attack)
                    return source.hasAbility('A005') and attack.isAttack and summonUnit ~= nil and not casting
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Soul_Steal = {}
_Abilities.Soul_Steal.new = function()
    local self = {}
    local events = {}
    local clock = Clock()
    local healEffect = Effect()
    healEffect.model = "Effects\\Grim Curse.mdx"
    healEffect.yaw = 270. * bj_DEGTORAD

    function self.apply(unit)
        if events.unit == nil then
            unit.bind("on_damage_after",
                function(source, target, attack)
                    local healAmount = GetEventDamage()
                    local bulletEffect = Effect()
                    bulletEffect.model = "Effects\\Purple Missile.mdx"
                    bulletEffect.x = target.x
                    bulletEffect.y = target.y
                    bulletEffect.create()
                    clock.schedule_interval(
                        function(triggeringClock, triggeringSchedule)
                            local dx = unit.x - bulletEffect.x
                            local dy = unit.y - bulletEffect.y
                            local dist = SquareRoot(dx * dx + dy * dy)
                            if dist > 5. then
                                local rad = Atan2(dy, dx)
                                bulletEffect.x = bulletEffect.x + 5. * Cos(rad)
                                bulletEffect.y = bulletEffect.y + 5. * Sin(rad)
                                bulletEffect.z = unit.z
                            else
                                bulletEffect.x = unit.x
                                bulletEffect.y = unit.y
                                bulletEffect.z = unit.z
                                bulletEffect.destroy()
                                healEffect.x = unit.x
                                healEffect.y = unit.y
                                healEffect.z = unit.z
                                healEffect.create().destroy()
                                unit.hp = unit.hp + healAmount
                                clock.unschedule(triggeringSchedule)
                            end
                        end, 0.005
                    )
                end
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    return unit.hasAbility('A005')
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Grim_Reaper = {}
_Abilities.Grim_Reaper.new = function()
    local self = {}
    local events = {}
    local clock = Clock()
    
    function self.apply(unit)
        if events.unit == nil then
            local auraEffect = Effect()
            auraEffect.model = "Effects\\Grim Reaper Aura Origin.mdx"
            local overheadEffect = Effect()
            overheadEffect.model = "Effects\\Grim Reaper Aura Overhead.mdx"
            overheadEffect.yaw = 270. * bj_DEGTORAD
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    auraEffect.x = unit.x
                    auraEffect.y = unit.y
                    auraEffect.z = unit.z
                    overheadEffect.x = unit.x
                    overheadEffect.y = unit.y
                    overheadEffect.z = unit.z + 100
                end, 0.01
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    if unit.hasAbility('A005') then
                        if auraEffect.handle == nil then
                            auraEffect.create()
                            overheadEffect.create()
                        end
                        return true
                    else
                        if auraEffect.handle ~= nil then
                            auraEffect.destroy()
                            overheadEffect.destroy()
                        end
                        return false
                    end
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Overload = {}
_Abilities.Overload.new = function()
    local self = {}
    local explodeEffect = Effect()
    explodeEffect.scale = 1.0
    explodeEffect.model = "Effects\\Shining Flare.mdx"
    local events = {}
    local clock = Clock()
    local group = CreateGroup()

    function self.apply(unit)
        if events.unit == nil then
            events.unit = unit.bind("on_damaged_after",
                function(source, target, attack)
                    if GetRandomInt(1, 10) == 1 then
                        local caster = target
                        local x = caster.x
                        local y = caster.y
                        local dist = 0
                        clock.schedule_interval(
                            function(triggeringClock, triggeringSchedule)
                                dist = dist + 100
                                for i = 0, 12 do
                                    local rad = i * 0.5236
                                    local x2 = x + dist * Cos(rad)
                                    local y2 = y + dist * Sin(rad)
                                    explodeEffect.x = x2
                                    explodeEffect.y = y2
                                    explodeEffect.create().destroy()
                                    GroupEnumUnitsInRange(group, x2, y2, 150., 
                                        Filter(
                                            function()
                                                local target = GetFilterUnit()
                                                if caster.isEnemy(target) then
                                                    caster.damageTarget(target, caster.damage * 30., false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                                end
                                            end
                                        )
                                    )
                                end
                                if dist >= 500 then
                                    clock.unschedule(triggeringSchedule)
                                end
                            end, 0.05
                        )
                    end
                end
            ).setCondition(
                function(source, target, attack)
                    return target.hasAbility('A002') and attack.isAttack
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Heaven_Justice = {}
_Abilities.Heaven_Justice.new = function()
    local self = {}
    local events = {}
    local clock = Clock()
    local explodeEffect = Effect()
    explodeEffect.scale = 1.3
    explodeEffect.model = "Effects\\Shining Flare.mdx"
    local afterEffect = Effect()
    afterEffect.scale = 0.7
    afterEffect.model = "Effects\\Earth Shock.mdx"
    local pointEffect = Effect()
    pointEffect.scale = 1.0
    pointEffect.model = "Effects\\Blight.mdx"
    
    function self.apply(unit)
        if events.unit == nil then
            local count = 0
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    count = count + 1
                    if count >= 200 then
                        count = 0
                        local dist = GetRandomReal(300, 700)
                        local rad = GetRandomReal(0., math.pi * 2)
                        local x = unit.x + dist * Cos(rad)
                        local y = unit.y + dist * Sin(rad)
                        local auraEffect = Effect()
                        auraEffect.model = "Effects\\Holy Aura.mdx"
                        auraEffect.x = x
                        auraEffect.y = y
                        auraEffect.scale = 1.0
                        auraEffect.create()
                        local angelUnit = unit.owner.createUnit('h003', x, y, 270.)
                        angelUnit.addAbility('Aloc')
                        angelUnit.animation = "birth"
                        clock.schedule_once(
                            function(triggeringClock, triggeringSchedule)
                                angelUnit.animation = 2
                                clock.schedule_once(
                                    function(triggeringClock, triggeringSchedule)
                                        angelUnit.animation = 5
                                        clock.schedule_once(
                                            function(triggeringClock, triggeringSchedule)
                                                angelUnit.remove()
                                                auraEffect.destroy()
                                            end, 1.9
                                        )
                                    end, 2.55
                                )
                                clock.schedule_once(
                                    function(triggeringClock, triggeringSchedule)
                                        local max = math.pi * 2
                                        for i = 0, 35 do
                                            local dist = GetRandomReal(0., 850.)
                                            local rad = GetRandomReal(0., max)
                                            local x2 = x + dist * Cos(rad)
                                            local y2 = y + dist * Sin(rad)
                                            pointEffect.x = x2
                                            pointEffect.y = y2
                                            pointEffect.create().destroy()
                                            clock.schedule_once(
                                                function(triggeringClock, triggeringSchedule)
                                                    explodeEffect.x = x2
                                                    explodeEffect.y = y2
                                                    explodeEffect.create().destroy()
                                                    afterEffect.x = x2
                                                    afterEffect.y = y2
                                                    afterEffect.create().destroy()
                                                    GroupEnumUnitsInRange(group, x2, y2, 150., 
                                                        Filter(
                                                            function()
                                                                local target = GetFilterUnit()
                                                                if unit.isEnemy(target) then
                                                                    unit.damageTarget(target, unit.damage * 30., false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                                                end
                                                            end
                                                        )
                                                    )
                                                end, 1.05
                                            )
                                        end
                                    end, 1.1
                                )
                            end, 1.3
                        )
                    end
                end, 0.05
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    return unit.hasAbility('A002')
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Impale = {}
_Abilities.Impale.new = function()
    local self = {}
    local events = {}
    local clock = Clock()
    local group = CreateGroup()
    local impaleEffect = Effect()
    impaleEffect.scale = 1.0
    impaleEffect.model = "Effects\\Holy Light.mdx"

    function self.apply(unit)
        if events.unit == nil then
            local count = 0
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    count = count + 1
                    if count >= 60 then
                        count = 0
                        GroupEnumUnitsInRange(group, unit.x, unit.y, 850., 
                            Filter(
                                function()
                                    local target = GetFilterUnit()
                                    if unit.isEnemy(target) then
                                        impaleEffect.x = target.x
                                        impaleEffect.y = target.y
                                        impaleEffect.create().destroy()
                                        unit.damageTarget(target, unit.damage * 5., false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                    end
                                end
                            )
                        )
                    end
                end, 0.05
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    return unit.hasAbility('A002')
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Judgement = {}
_Abilities.Judgement.new = function()
    local self = {}
    local impaleEffect = Effect()
    impaleEffect.scale = 1.0
    impaleEffect.model = "Effects\\Holy Light.mdx"
    local events = {}
    local clock = Clock()
    local group = CreateGroup()

    function self.apply(unit)
        if events.unit == nil then
            events.unit = unit.bind("on_damage_after",
                function(source, target, attack)
                    if GetRandomInt(1, 100) == 1 then
                        local x = source.x
                        local y = source.y
                        local baseRad = bj_DEGTORAD * source.face
                        local dist = 0
                        clock.schedule_interval(
                            function(triggeringClock, triggeringSchedule)
                                dist = dist + 80
                                for i = 0, 3 do
                                    local rad = baseRad - 0.3 + 0.3 * i
                                    local x2 = x + dist * Cos(rad)
                                    local y2 = y + dist * Sin(rad)
                                    impaleEffect.x = x2
                                    impaleEffect.y = y2
                                    impaleEffect.create().destroy()
                                    GroupEnumUnitsInRange(group, x2, y2, 100., 
                                        Filter(
                                            function()
                                                local target = GetFilterUnit()
                                                if source.isEnemy(target) then
                                                    source.damageTarget(target, source.damage * 30., false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                                end
                                            end
                                        )
                                    )
                                end
                                if dist >= 480 then
                                    clock.unschedule(triggeringSchedule)
                                end
                            end, 0.05
                        )
                    end
                end
            ).setCondition(
                function(source, target, attack)
                    return source.hasAbility('A002') and attack.isAttack
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Temple_Knight = {}
_Abilities.Temple_Knight.new = function()
    local self = {}
    local events = {}
    local clock = Clock()
    
    function self.apply(unit)
        if events.unit == nil then
            local auraEffect = Effect()
            auraEffect.model = "Effects\\Archangel Aura.mdx"
            auraEffect.scale = 1.4
            auraEffect.yaw = bj_DEGTORAD * 270.
            local floatingEffect = Effect()
            floatingEffect.model = "Effects\\Floating Swords.mdx"
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    auraEffect.x = unit.x
                    auraEffect.y = unit.y
                    auraEffect.z = unit.z
                    floatingEffect.x = unit.x
                    floatingEffect.y = unit.y
                    floatingEffect.z = unit.z
                    floatingEffect.yaw = unit.face * bj_DEGTORAD
                end, 0.01
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    if unit.hasAbility('A002') then
                        if auraEffect.handle == nil then
                            auraEffect.create()
                            floatingEffect.create()
                        end
                        return true
                    else
                        if auraEffect.handle ~= nil then
                            auraEffect.create()
                            floatingEffect.destroy()
                        end
                        return false
                    end
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Wolf = {}
_Abilities.Wolf.new = function()
    local self = {}
    local events = {}
    local clock = Clock()
    local bloodEffect = Effect()
    bloodEffect.model = "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl"
    bloodEffect.scale = 1.2
    
    function self.apply(unit)
        if events.unit == nil then
            local summonUnit = nil 
            local tx = nil
            local ty = nil
            local level = 0
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    if level ~= unit.getAbilityLevel('A010') then
                        level = unit.getAbilityLevel('A010')
                        summonUnit.scale = 0.8 + (level - 1) * 0.06
                        local levelUpEffect = Effect()
                        levelUpEffect.model = "Effects\\Heal Green.blp"
                        levelUpEffect.attachTo(summonUnit, "origin")
                        clock.schedule_once(
                            function(triggeringClock, triggeringSchedule)
                                levelUpEffect.destroy()
                            end, 3.0
                        )
                    end
                    if tx == nil or ty == nil then
                        tx = summonUnit.x
                        ty = summonUnit.y
                    end
                    local cx = summonUnit.x
                    local cy = summonUnit.y
                    local a = unit.face + 180.
                    local ux = unit.x
                    local uy = unit.y
                    local dx = tx - ux
                    local dy = ty - uy
                    local dist = SquareRoot(dx * dx + dy * dy)
                    if dist > 800. then
                        local otherDist = GetRandomReal(400, 600)
                        local rad = GetRandomReal(0., math.pi * 2)
                        tx = ux + otherDist * Cos(rad)
                        ty = uy + otherDist * Sin(rad)
                        summonUnit.issueOrder("move", tx, ty)
                    else
                        local dx = tx - cx
                        local dy = ty - cy
                        local dist = SquareRoot(dx * dx + dy * dy)
                        if dist > 1. then
                            local rad = Atan2(dy, dx)
                            local increment = 200 + 200 * 0.03 * dist / 70
                            summonUnit.ms = increment
                        elseif GetRandomInt(0, 1000) == 1 then
                            local otherDist = GetRandomReal(400, 700)
                            local rad = GetRandomReal(0., math.pi * 2)
                            tx = ux + otherDist * Cos(rad)
                            ty = uy + otherDist * Sin(rad)
                            summonUnit.issueOrder("move", tx, ty)
                        end
                    end
                end, 0.005
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    if unit.hasAbility('A010') then
                        if summonUnit == nil then
                            local distance = GetRandomReal(0, 400)
                            local deg = GetRandomReal(0., 360.)
                            local rad = deg * bj_DEGTORAD
                            summonUnit = unit.owner.createUnit('h011', unit.x + distance * Cos(rad), unit.y + distance * Sin(rad), deg)
                            summonUnit.addAbility('Aloc')
                            summonUnit.bind("on_attack",
                                function(source, target)
                                    local rad = Atan2(target.y - source.y, target.x - source.x)
                                    bloodEffect.x = source.x + 140. * Cos(rad)
                                    bloodEffect.y = source.y + 140. * Sin(rad)
                                    bloodEffect.yaw = rad
                                    bloodEffect.create().destroy()
                                end
                            )
                            summonUnit.bind("on_damage_pre",
                                function(source, target, attack)
                                    BlzSetEventDamage(0)
                                    unit.damageTarget(target, unit.damage * 2.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE)
                                end
                            )
                            --summonUnit.setWeaponIntegerField(UNIT_WEAPON_IF_ATTACK_TARGETS_ALLOWED, 0, 4)
                        end
                        return true
                    else
                        if summonUnit ~= nil then
                            auraEffect.destroy()
                            summonUnit.remove()
                        end
                        return false
                    end
                end
            )
            unit.bind("on_damage_after",
                function(source, target, attack)
                    summonUnit.issueOrder("attack", target)
                end
            ).setCondition(
                function(source, target, attack)
                    return source.hasAbility('A010') and attack.isAttack and summonUnit ~= nil
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Bear = {}
_Abilities.Bear.new = function()
    local self = {}
    local events = {}
    local clock = Clock()
    local bloodEffect = Effect()
    bloodEffect.model = "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl"
    bloodEffect.scale = 1.2
    
    function self.apply(unit)
        if events.unit == nil then
            local summonUnit = nil 
            local tx = nil
            local ty = nil
            local level = 0
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    if level ~= unit.getAbilityLevel('A010') then
                        level = unit.getAbilityLevel('A010')
                        summonUnit.scale = 1.0 + (level - 1) * 0.06
                        local levelUpEffect = Effect()
                        levelUpEffect.model = "Effects\\Heal Gold.blp"
                        levelUpEffect.attachTo(summonUnit, "origin")
                        clock.schedule_once(
                            function(triggeringClock, triggeringSchedule)
                                levelUpEffect.destroy()
                            end, 3.0
                        )
                    end
                    if tx == nil or ty == nil then
                        tx = summonUnit.x
                        ty = summonUnit.y
                    end
                    local cx = summonUnit.x
                    local cy = summonUnit.y
                    local a = unit.face + 180.
                    local ux = unit.x
                    local uy = unit.y
                    local dx = tx - ux
                    local dy = ty - uy
                    local dist = SquareRoot(dx * dx + dy * dy)
                    if dist > 800. then
                        local otherDist = GetRandomReal(400, 600)
                        local rad = GetRandomReal(0., math.pi * 2)
                        tx = ux + otherDist * Cos(rad)
                        ty = uy + otherDist * Sin(rad)
                        summonUnit.issueOrder("move", tx, ty)
                    else
                        local dx = tx - cx
                        local dy = ty - cy
                        local dist = SquareRoot(dx * dx + dy * dy)
                        if dist > 1. then
                            local rad = Atan2(dy, dx)
                            local increment = 200 + 200 * 0.03 * dist / 70
                            summonUnit.ms = increment
                        elseif GetRandomInt(0, 1000) == 1 then
                            local otherDist = GetRandomReal(400, 700)
                            local rad = GetRandomReal(0., math.pi * 2)
                            tx = ux + otherDist * Cos(rad)
                            ty = uy + otherDist * Sin(rad)
                            summonUnit.issueOrder("move", tx, ty)
                        end
                    end
                end, 0.005
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    if unit.hasAbility('A010') then
                        if summonUnit == nil then
                            local distance = GetRandomReal(0, 400)
                            local deg = GetRandomReal(0., 360.)
                            local rad = deg * bj_DEGTORAD
                            summonUnit = unit.owner.createUnit('h012', unit.x + distance * Cos(rad), unit.y + distance * Sin(rad), deg)
                            summonUnit.addAbility('Aloc')
                            summonUnit.bind("on_attack",
                                function(source, target)
                                    local rad = Atan2(target.y - source.y, target.x - source.x)
                                    bloodEffect.x = source.x + 140. * Cos(rad)
                                    bloodEffect.y = source.y + 140. * Sin(rad)
                                    bloodEffect.yaw = rad
                                    bloodEffect.create().destroy()
                                end
                            )
                            summonUnit.bind("on_damage_pre",
                                function(source, target, attack)
                                    BlzSetEventDamage(0)
                                    unit.damageTarget(target, unit.damage * 2.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE)
                                end
                            )
                            --summonUnit.setWeaponIntegerField(UNIT_WEAPON_IF_ATTACK_TARGETS_ALLOWED, 0, 4)
                        end
                        return true
                    else
                        if summonUnit ~= nil then
                            auraEffect.destroy()
                            summonUnit.remove()
                        end
                        return false
                    end
                end
            )
            unit.bind("on_damage_after",
                function(source, target, attack)
                    summonUnit.issueOrder("attack", target)
                end
            ).setCondition(
                function(source, target, attack)
                    return source.hasAbility('A010') and attack.isAttack and summonUnit ~= nil
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

_Abilities.Frost_Arrow = {}
_Abilities.Frost_Arrow.new = function()
    local self = {}
    local clock = Clock()


    function self.apply(unit)
        unit.bind("on_damage_after",
            function(source, target, attack)
                local amount = 10
                local offset = 100.
                for current = 1, amount do
                    local rad = (6.28319 / amount) * current
                    local x = target.x + 30. * Cos(rad)
                    local y = target.y + 30. * Sin(rad)
                    local z = target.z + 200.
                    local effect = Effect()
                    effect.model = "Effects\\Freezingsplinter.mdx"
                    effect.x = x
                    effect.y = y
                    effect.z = z
                    effect.yaw = rad
                    effect.pitch = 45. * bj_DEGTORAD
                    effect.create()
                    local increment = 0
                    clock.schedule_interval(
                        function(triggeringClock, triggeringSchedule)
                            effect.x = x + (offset / (20 - increment)) * Cos(rad)
                            effect.y = y + (offset / (20 - increment)) * Sin(rad)
                            effect.z = z - (200 / (20 - increment))
                            increment = increment + 1
                            if increment >= 20 then
                                clock.unschedule(triggeringSchedule)
                                effect.destroy()
                            end
                        end, 0.01
                    )
                end
            end
        ).setCondition(
            function(source, target, attack)
                return source.hasAbility('A003') and attack.isAttack
            end
        )
    end

    clock.start()

    return self
end

_Abilities.Boar = {}
_Abilities.Boar.new = function()
    local self = {}
    local events = {}
    local clock = Clock()
    
    function self.apply(unit)
        if events.unit == nil then
            local summonUnit = nil 
            local tx = nil
            local ty = nil
            local level = 0
            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    if level ~= unit.getAbilityLevel('A010') then
                        level = unit.getAbilityLevel('A010')
                        summonUnit.scale = 1.2 + (level - 1) * 0.06
                        local levelUpEffect = Effect()
                        levelUpEffect.model = "Effects\\Heal Orange.blp"
                        levelUpEffect.attachTo(summonUnit, "origin")
                        clock.schedule_once(
                            function(triggeringClock, triggeringSchedule)
                                levelUpEffect.destroy()
                            end, 3.0
                        )
                    end
                    if tx == nil or ty == nil then
                        tx = summonUnit.x
                        ty = summonUnit.y
                    end
                    local cx = summonUnit.x
                    local cy = summonUnit.y
                    local a = unit.face + 180.
                    local ux = unit.x
                    local uy = unit.y
                    local dx = tx - ux
                    local dy = ty - uy
                    local dist = SquareRoot(dx * dx + dy * dy)
                    if dist > 800. then
                        local otherDist = GetRandomReal(400, 600)
                        local rad = GetRandomReal(0., math.pi * 2)
                        tx = ux + otherDist * Cos(rad)
                        ty = uy + otherDist * Sin(rad)
                        summonUnit.issueOrder("move", tx, ty)
                    else
                        local dx = tx - cx
                        local dy = ty - cy
                        local dist = SquareRoot(dx * dx + dy * dy)
                        if dist > 1. then
                            local rad = Atan2(dy, dx)
                            local increment = 200 + 200 * 0.03 * dist / 70
                            summonUnit.ms = increment
                        elseif GetRandomInt(0, 1000) == 1 then
                            local otherDist = GetRandomReal(400, 700)
                            local rad = GetRandomReal(0., math.pi * 2)
                            tx = ux + otherDist * Cos(rad)
                            ty = uy + otherDist * Sin(rad)
                            summonUnit.issueOrder("move", tx, ty)
                        end
                    end
                end, 0.005
            ).setCondition(
                function(triggeringClock, triggeringSchedule)
                    if unit.hasAbility('A010') then
                        if summonUnit == nil then
                            local distance = GetRandomReal(0, 400)
                            local deg = GetRandomReal(0., 360.)
                            local rad = deg * bj_DEGTORAD
                            summonUnit = unit.owner.createUnit('h013', unit.x + distance * Cos(rad), unit.y + distance * Sin(rad), deg)
                            summonUnit.addAbility('Aloc')
                            summonUnit.bind("on_damage_pre",
                                function(source, target, attack)
                                    BlzSetEventDamage(0)
                                    unit.damageTarget(target, unit.damage * 2.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE)
                                end
                            )
                            --summonUnit.setWeaponIntegerField(UNIT_WEAPON_IF_ATTACK_TARGETS_ALLOWED, 0, 4)
                        end
                        return true
                    else
                        if summonUnit ~= nil then
                            auraEffect.destroy()
                            summonUnit.remove()
                        end
                        return false
                    end
                end
            )
            unit.bind("on_damage_after",
                function(source, target, attack)
                    summonUnit.issueOrder("attack", target)
                end
            ).setCondition(
                function(source, target, attack)
                    return source.hasAbility('A010') and attack.isAttack and summonUnit ~= nil
                end
            )
        end
    end

    function self.remove(unit)
        if events.unit ~= nil then
            unit.unbind(events.unit)
            events.unit = nil
        end
    end

    clock.start()

    return self
end

Abilities = {}
Abilities.new = function()
    local self = {}

    self.Shadow_Strike = _Abilities.Shadow_Strike.new()
    self.Blink_Strike = _Abilities.Blink_Strike.new()
    self.Demon_Control = _Abilities.Demon_Control.new()
    self.Blade_Dance = _Abilities.Blade_Dance.new()
    self.Possessed = _Abilities.Possessed.new()

    self.Reaper_1 = _Abilities.Reaper_1.new()
    self.Reaper_2 = _Abilities.Reaper_2.new()
    self.Reaper_3 = _Abilities.Reaper_3.new()
    self.Soul_Steal = _Abilities.Soul_Steal.new()
    self.Grim_Reaper = _Abilities.Grim_Reaper.new()

    self.Wolf = _Abilities.Wolf.new()
    self.Bear = _Abilities.Bear.new()
    self.Boar = _Abilities.Boar.new()

    self.Frost_Arrow = _Abilities.Frost_Arrow.new()
    
    self.Overload = _Abilities.Overload.new()
    self.Heaven_Justice = _Abilities.Heaven_Justice.new()
    self.Impale = _Abilities.Impale.new()
    self.Judgement = _Abilities.Judgement.new()
    self.Temple_Knight = _Abilities.Temple_Knight.new()

    return self
end

function onInit()
xpcall(function()

    -- Initiate Framework
    Framework = Engine.new()
    Gameplay = Game.new()
    Ability = Abilities.new()

    spawn = Spawn()
    spawn.x = GetRectCenterX(gg_rct_Example_Spawn)
    spawn.y = GetRectCenterY(gg_rct_Example_Spawn)

    -- Edit player 0 (red)
    player = Player(0)
    player.bind("on_leave", 
        function(player)
            print("player leave")
            print("name: " .. player.name)
            print("id: " .. player.id)
        end
    )
    player.gold = 500
    print(player.name .. "'s Gold: " .. player.gold)

    if player.state == PLAYER_SLOT_STATE_PLAYING then
        print(player.name .. " is playing")
    end
    if player.controller == MAP_CONTROL_USER then
        print(player.name .. " is a user")
    end

    if player.state == PLAYER_SLOT_STATE_PLAYING and player.controller == MAP_CONTROL_USER then
        player.setCameraField(CAMERA_FIELD_TARGET_DISTANCE, 2250., 0.)
        local unit = player.createUnit('H001', spawn.x, spawn.y, 270.)
        unit.maxhp = 570
        unit.hp = 326
        unit.damage = 150
        unit.agi = 100
        unit.attackspeed = 1.0
        unit.ms = 800
        unit.level = 10
        effect = Effect()
        effect.model = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl"
        unit.bind("on_death",
            function(unit)
                unit.respawn(spawn)
                effect.x = unit.x
                effect.y = unit.y
                effect.create().destroy()
            end
        ).setCondition(
            function(unit)
                return unit.owner == player
            end
        )

        --effect = Effect()
        --effect.model = "Effects\\Fountain of Souls.mdx"
        --unit.attachEffect(effect, "origin")

        effect = Effect()
        effect.model = "Effects\\Wings.mdx"
        unit.attachEffect(effect, "chest")

        --effect = Effect()
        --effect.model = "Effects\\Ubershield Azure.mdx"
        --unit.attachEffect(effect, "chest")

        Ability.Shadow_Strike.apply(unit)
        Ability.Blink_Strike.apply(unit)
        Ability.Demon_Control.apply(unit)
        Ability.Blade_Dance.apply(unit)
        Ability.Possessed.apply(unit)

        Ability.Reaper_1.apply(unit)
        Ability.Reaper_2.apply(unit)
        Ability.Reaper_3.apply(unit)
        Ability.Soul_Steal.apply(unit)
        Ability.Grim_Reaper.apply(unit)

        Ability.Wolf.apply(unit)
        Ability.Bear.apply(unit)
        Ability.Boar.apply(unit)

        Ability.Overload.apply(unit)
        Ability.Heaven_Justice.apply(unit)
        Ability.Impale.apply(unit)
        Ability.Judgement.apply(unit)
        Ability.Temple_Knight.apply(unit)

        Ability.Frost_Arrow.apply(unit)
        
        --unit.bind("on_damaged_pre",
        --    function(source, target, attack)
        --        print("unit is about to take damage")
        --    end
        --)
        --unit.bind("on_damaged_after",
        --    function(source, target, attack)
        --        print("unit took damage")
        --    end
        --)
        --unit.bind("on_damage_pre",
        --    function(source, target, attack)
        --        print("unit is about to deal damage")
        --    end
        --)
        --unit.bind("on_damage_after",
        --    function(source, target, attack)
        --        print("unit dealt damage")
        --    end
        --)

        print(unit.hp .. " / " .. unit.maxhp)
        player.bind("on_message",
            function(player, message)
                unit.kill()
            end
        ).setCondition(
            function(player, message)
                return message == "-kill"
            end
        )
    end

    -- Request Player 0 Keyboard
    --keyboard = Framework.Window.request_keyboard(Player(0))
    --keyboard.bind("on_key_down", 
    --    function(triggeringKeyboard, keydata, metakey)
    --        print("key down")
    --        print("keycode: " .. keydata[1])
    --        print("string: " .. keydata[2])
    --        print("metakey: " .. metakey)
    --    end
    --)

    --keyboard.bind("on_key_up", 
    --    function(triggeringKeyboard, keydata, metakey)
    --        print("key up")
    --        print("keycode: " .. keydata[1])
    --        print("string: " .. keydata[2])
    --        print("metakey: " .. metakey)
    --    end
    --)

    --Framework.Window.bind("on_mouse_down",
    --    function(triggeringWindow, player, pos, button)
    --        print("mouse down")
    --        print("player: " .. player.name)
    --        print("pos: " .. "(" .. pos[1] .. " | " .. pos[2] .. ")")
    --        print("key: " .. button[2])
    --    end
    --)

    --Framework.Window.bind("on_mouse_up",
    --    function(triggeringWindow, player, pos, button)
    --        print("mouse up")
    --        print("player: " .. player.name)
    --        print("pos: " .. "(" .. pos[1] .. " | " .. pos[2] .. ")")
    --        print("key: " .. button[2])
    --    end
    --)

    --Framework.Window.bind("on_motion",
    --    function(triggeringWindow, player, pos)
    --        print("mouse motion")
    --        print("player: " .. player.name)
    --        print("pos: " .. "(" .. pos[1] .. " | " .. pos[2] .. ")")
    --    end
    --).setCondition(
    --    function(triggeringWindow, player, pos)
    --        return player == Player(0)
    --    end
    --)

    player = Player(PLAYER_NEUTRAL_AGGRESSIVE)
    clock = Clock()
    clock.start()

    player.bind("on_unitDeath",
        function(player, unit)
            local id = unit.id
            local x = unit.x
            local y = unit.y
            local face = unit.face
            clock.schedule_once(
                function(triggeringClock, triggeringSchedule)
                    player.createUnit(id, x, y, face)
                end, 5.0
            )
        end
    )

    --clock = Clock()
    --clock.schedule_once(
    --    function(triggeringClock, triggeringSchedule, arguments)
    --        print("5 seconds expired " .. arguments)
    --    end, 5.0, "[once]"
    --).setCondition(
    --    function(triggeringClock, triggeringSchedule, arguments)
    --        print("This condition check is always true")
    --        return true
    --    end
    --)

    --clock.schedule_interval(
    --    function(triggeringClock, triggeringSchedule, arguments)
    --        print("7 seconds expired [repeat]")
    --    end, 7.0
    --)
    --clock.start()

    --soundLoader = SoundLoader()

end, print)
end

TimerStart(CreateTimer(), 0., false, onInit)