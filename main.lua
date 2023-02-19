Engine = {}
Engine.new = function()
    local self = {}

    -- Objects
    local _ConfigurationBase = {}
    local _Configuration = {}
    local Configuration
    local _Logger = {}
    local _Indexer = {}
    local _EventDispatcher = {}
    local _Mouse = {}
    local _Keyboard = {}
    local _Camera = {}
    local _Window = {}
    local _Clock = {}
    local _SoundLoader = {}
    local _Unit = {}
    local _Player = {}
    local _Group = {}
    -- local _Item = {}
    local _Trigger = {}
    local _Effect = {}

    local Clock = {}
    local SoundLoader = {}
    local Unit = {}
    local Group = {}
    -- local Item = {}
    local Trigger = {}
    local Effect = {}
    local EventDispatcher = {}
    local Easing = {}
    local Camera = {}

    -- Engine Logger
    local LOG_LEVEL = {
        NONE,
        DEFAULT,
        HIGH,
        DEBUG
    }

    local InvokerTable = {}
    InvokerTable.new = function(on_change)
        local protectedTable = {}
        local on_change = on_change
        local metaTable = {
            __index = function (t,k)
                return protectedTable[k]
            end,
            __newindex = function (t,k,v)
                protectedTable[k] = v
                if on_change ~= nil then
                    on_change(k,v)
                end
            end
        }

        return setmetatable({},metaTable)
    end

    local _ConfigurationField = {}
    _ConfigurationField.new = function(on_change)
        local self = {}
        local mt = {}
        local on_change = on_change

        local Global = 1.0
        local Key = InvokerTable.new(on_change)

        function mt.__newindex(table, index, value)
            if index == "Global" then
                Global = value
                if on_change ~= nil then
                    on_change()
                end
            else
                print("[CONFIG ERROR] Unknown attribute '" .. index .. "'.")
            end
        end
        
        function mt.__index(table, index)
            if index == "Global" then
                return Global
            elseif index == "Key" then
                return Key
            else
                print("[CONFIG ERROR] Unknown attribute '" .. index .. "'.")
            end
        end
        
        setmetatable(self, mt)

        return self
    end

    -- This Configuration is used for configurations that apply to SPECIFIC players
    _ConfigurationBase.new = function()
        local self = {}
        local mt = {}

        local _Effects = {}
        _Effects.new = function()
            local self = {}
            local mt = {}

            local Transparency = _ConfigurationField.new(_Effect.refreshAll)

            function mt.__newindex(table, index, value)
                if index == "Transparency" then
                    Transparency.Global = value
                else
                    print("[CONFIG ERROR] Unknown attribute '" .. index .. "'.")
                end
            end
    
            function mt.__index(table, index)
                if index == "Transparency" then
                    return Transparency
                else
                    print("[CONFIG ERROR] Unknown attribute '" .. index .. "'.")
                end
            end
    
            setmetatable(self, mt)

            return self
        end
        local Effects = _Effects.new()

        function mt.__newindex(table, index, value)
            print("[CONFIG ERROR] Unknown attribute '" .. index .. "'.")
        end

        function mt.__index(table, index)
            if index == "Effects" then
                return Effects
            else
                print("[CONFIG ERROR] Unknown attribute '" .. index .. "'.")
            end
        end

        setmetatable(self, mt)

        return self
    end

    -- This Configuration references to the Global and User Configuration
    _Configuration.new = function()
        local self = {}
        local mt = {}

        local globalConfiguration = _ConfigurationBase.new()
        local userConfiguration = {}
        for pID = 0, 27 do
            userConfiguration[pID] = _ConfigurationBase.new()
        end

        local _Users = {}
        _Users.new = function()
            local self = {}
            local mt = {}

            function mt.__newindex(table, index, value)
                print("[CONFIG ERROR] Read-only!.")
            end
    
            function mt.__index(table, index)
                return userConfiguration[GetPlayerId(GetLocalPlayer())][index]
            end
    
            setmetatable(self, mt)
    
            return self
        end
        local Users = _Users.new()

        function mt.__newindex(table, index, value)
            print("[CONFIG ERROR] Read-only!.")
        end

        function mt.__index(table, index)
            if index == "Global" then
                return globalConfiguration
            elseif index == "Users" then
                return Users
            else
                print("[CONFIG ERROR] Unknown attribute '" .. index .. "'.")
            end
        end

        self.User = function(playerId)
            return userConfiguration[playerId]
        end

        setmetatable(self, mt)

        return self
    end

    _Logger.new = function(LogLevel)
        local self = {}

        self.Level = LogLevel or 0

        function self.Debug(message)
            if self.Level >= 3 then
                print("|c007d7d7d[DEBUG]|r" .. " " .. message)
            end
        end

        function self.Warn(message)

            if self.Level >= 2 then
                print("|c00FF7F00[WARN]|r" .. " " .. message)
            end
        
        end

        function self.Error(message)

            if self.Level >= 1 then
                print("|cffdc143c[ERROR]|r" .. " " .. message)
            end
        
        end

        return self

    end

    local Logger = _Logger.new

    local Log = Logger(2)

    _Indexer.new = function()
        local self = {}
        local objects = {}

        function self._add(object, handle)
            objects[handle] = object
            return handle
        end

        self.add = function(object, handle)
            local status, val = xpcall(self._add, Log.Error, object, handle)
            if status then return val end
        end

        function self._find(handle)
            local object = objects[handle]
            if object ~= nil then
                return object
            end
            Log.Warn("Indexer detected unknown handle! (" .. handle .. ")")
        end

        self.find = function(handle)
            local status, val = xpcall(self._find, Log.Error, handle)
            if status then return val end
        end

        return self

    end

    local Indexer = _Indexer.new()

    local _GetTriggerUnit = GetTriggerUnit
    local GetTriggerUnit = function()
        local handle = _GetTriggerUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetAttacker = GetAttacker
    local GetAttacker = function()
        local handle = _GetAttacker()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetFilterUnit = GetFilterUnit
    local GetFilterUnit = function()
        local handle = _GetFilterUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetSpellTargetUnit = GetSpellTargetUnit
    local GetSpellTargetUnit = function()
        local handle = _GetSpellTargetUnit()
        if handle == nil then
            return
        end
        local unit = Indexer.find(handle)
        return unit
    end

    -- local _GetManipulatedItem = GetManipulatedItem
    -- local GetManipulatedItem = function()
    --     local handle = _GetManipulatedItem()
    --     local item = Indexer.find(handle)
    --     return item
    -- end

    -- local _GetFilterItem = GetFilterItem
    -- local GetFilterItem = function()
    --     local handle = _GetFilterItem()
    --     local item = Indexer.find(handle)
    --     return item
    -- end

    local _GetTriggerPlayer = GetTriggerPlayer
    local GetTriggerPlayer = function()
        local handle = _GetTriggerPlayer()
        local player = Indexer.find(handle)
        return player
    end

    -- local _GetItemPlayer = GetItemPlayer
    -- local GetItemPlayer = function()
    --     local handle = _GetItemPlayer()
    --     local player = Indexer.find(handle)
    --     return player
    -- end

    local _GetEventDamageSource = GetEventDamageSource
    local GetEventDamageSource = function()
        local handle = _GetEventDamageSource()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetEventDamageTarget = BlzGetEventDamageTarget
    local GetEventDamageTarget = function()
        local handle = _GetEventDamageTarget()
        local unit = Indexer.find(handle)
        return unit
    end

    local _Player_ = Player
    local Player = function(id)
        local handle = _Player_(id)
        local player = Indexer.find(handle)
        return player
    end

    local _GetOwningPlayer = GetOwningPlayer
    local GetOwningPlayer = function(unit)
        local handle = _GetOwningPlayer(unit.handle)
        local player = Indexer.find(handle)
        return player
    end
    
    local _FirstOfGroup = FirstOfGroup
    local FirstOfGroup = function(whichGroup)
        local handle = _FirstOfGroup(whichGroup)
        local unit = Indexer.find(handle)
        return unit
    end

    local _BlzGroupUnitAt = BlzGroupUnitAt
    local BlzGroupUnitAt = function(whichGroup, index)
        local handle = _BlzGroupUnitAt(whichGroup, index)
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetEnumUnit = GetEnumUnit
    local GetEnumUnit = function()
        local handle = _GetEnumUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetEnteringUnit = GetEnteringUnit
    local GetEnteringUnit = function()
        local handle = _GetEnteringUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetLeavingUnit = GetLeavingUnit
    local GetLeavingUnit = function()
        local handle = _GetLeavingUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetLevelingUnit = GetLevelingUnit
    local GetLevelingUnit = function()
        local handle = _GetLevelingUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetLearningUnit = GetLearningUnit
    local GetLearningUnit = function()
        local handle = _GetLearningUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetRevivableUnit = GetRevivableUnit
    local GetRevivableUnit = function()
        local handle = _GetRevivableUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetRevivingUnit = GetRevivingUnit
    local GetRevivingUnit = function()
        local handle = _GetRevivingUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetRescuer = GetRescuer
    local GetRescuer = function()
        local handle = _GetRescuer()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetDyingUnit = GetDyingUnit
    local GetDyingUnit = function()
        local handle = _GetDyingUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetKillingUnit = GetKillingUnit
    local GetKillingUnit = function()
        local handle = _GetKillingUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetDecayingUnit = GetDecayingUnit
    local GetDecayingUnit = function()
        local handle = _GetDecayingUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetSelectedUnit = GetSelectedUnit
    local GetSelectedUnit = function()
        local handle = _GetSelectedUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetConstructingStructure = GetConstructingStructure
    local GetConstructingStructure = function()
        local handle = _GetConstructingStructure()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetCancelledStructure = GetCancelledStructure
    local GetCancelledStructure = function()
        local handle = _GetCancelledStructure()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetConstructedStructure = GetConstructedStructure
    local GetConstructedStructure = function()
        local handle = _GetConstructedStructure()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetResearchingUnit = GetResearchingUnit
    local GetResearchingUnit = function()
        local handle = _GetResearchingUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetTrainedUnit = GetTrainedUnit
    local GetTrainedUnit = function()
        local handle = _GetTrainedUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetDetectedUnit = GetDetectedUnit
    local GetDetectedUnit = function()
        local handle = _GetDetectedUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetSummoningUnit = GetSummoningUnit
    local GetSummoningUnit = function()
        local handle = _GetSummoningUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetSummonedUnit = GetSummonedUnit
    local GetSummonedUnit = function()
        local handle = _GetSummonedUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetTransportUnit = GetTransportUnit
    local GetTransportUnit = function()
        local handle = _GetTransportUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetLoadedUnit = GetLoadedUnit
    local GetLoadedUnit = function()
        local handle = _GetLoadedUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetSellingUnit = GetSellingUnit
    local GetSellingUnit = function()
        local handle = _GetSellingUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetSoldUnit = GetSoldUnit
    local GetSoldUnit = function()
        local handle = _GetSoldUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetBuyingUnit = GetBuyingUnit
    local GetBuyingUnit = function()
        local handle = _GetBuyingUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetChangingUnit = GetChangingUnit
    local GetChangingUnit = function()
        local handle = _GetChangingUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetManipulatingUnit = GetManipulatingUnit
    local GetManipulatingUnit = function()
        local handle = _GetManipulatingUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetOrderedUnit = GetOrderedUnit
    local GetOrderedUnit = function()
        local handle = _GetOrderedUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetOrderTargetUnit = GetOrderTargetUnit
    local GetOrderTargetUnit = function()
        local handle = _GetOrderTargetUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetSpellAbilityUnit = GetSpellAbilityUnit
    local GetSpellAbilityUnit = function()
        local handle = _GetSpellAbilityUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local _GetEventTargetUnit = GetEventTargetUnit
    local GetEventTargetUnit = function()
        local handle = _GetEventTargetUnit()
        local unit = Indexer.find(handle)
        return unit
    end

    local GetSpellObject = function()
        local self = {}
        self.handle = GetSpellAbility()
        self.id = GetSpellAbilityId()
        self.x = GetSpellTargetX()
        self.y = GetSpellTargetY()
        self.target = GetSpellTargetUnit()
        return self
    end

    local damageObjects = {}
    damageObjects.stack = {}
    damageObjects.last = 0
    local ConstructDamageObject = function()
        local self = {}
        self.damage = GetEventDamage()
        self.attackType = BlzGetEventAttackType()
        self.damageType = BlzGetEventDamageType()
        self.weaponType = BlzGetEventWeaponType()
        self.isAttack = BlzGetEventIsAttack()
        self.crit = 0

        if math.random(0., 100.) <= GetEventDamageSource().critChance then
            self.crit = GetEventDamageSource().critDamage * self.damage
        end

        damageObjects.last = damageObjects.last + 1
        damageObjects.stack[damageObjects.last] = self

        return self
    end
    local GetDamageObject = function()
        local self = {}
        self.damage = GetEventDamage()
        self.attackType = BlzGetEventAttackType()
        self.damageType = BlzGetEventDamageType()
        self.weaponType = BlzGetEventWeaponType()
        self.isAttack = BlzGetEventIsAttack()
        self.before = damageObjects.stack[damageObjects.last]

        damageObjects.stack[damageObjects.last] = nil
        damageObjects.last = damageObjects.last - 1

        return self
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

        self.registerTrackableTrackEvent = function(t)
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

    Trigger.new = function()
        local status, val = xpcall(_Trigger.new, Log.Error)
        if status then return val end
    end

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

    EventDispatcher.new = function(types)
        local status, val = xpcall(_EventDispatcher.new, Log.Error, types)
        if status then return val end
    end

    _Effect.Active = {} -- List of all effects that have a handle
    _Effect.refreshAll = function()
        for _, effect in pairs(_Effect.Active) do
            effect.alpha = effect.alpha -- Refreshes alpha
        end
    end
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
        local customId = nil
        local current
        local mt = {}

        local factoredAlpha = function()
            local factor = Configuration.Users.Effects.Transparency.Global
            if customId ~= nil and Configuration.Users.Effects.Transparency.Key[customId] then
                factor = Configuration.Users.Effects.Transparency.Key[customId]
            end
            return math.floor(alpha * factor)
        end

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
                    BlzSetSpecialEffectAlpha(handle, factoredAlpha())
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
            elseif index == "customId" then
                customId = value
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
            elseif index == "customId" then
                return customId
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        function self._attachTo(unit, point)
            if handle == nil then
                self.on_create()
                handle = AddSpecialEffectTarget(model, unit.handle, point)
                BlzSetSpecialEffectColor(handle, red, green, blue)
                BlzSetSpecialEffectAlpha(handle, factoredAlpha())
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

        local eventDispatcher = EventDispatcher.new(
            {"on_create", "on_destroy"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_create()
            table.insert(_Effect.Active, self)
            eventDispatcher.dispatch("on_create", self)
        end

        self.on_create = function()
            local status, val = xpcall(self._on_create, Log.Error)
            if status then return val end
        end

        function self._on_destroy()
            for index, effect in pairs(_Effect.Active) do
                if effect == self then
                    table.remove(_Effect.Active, index)
                    break
                end
            end
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
                BlzSetSpecialEffectAlpha(handle, factoredAlpha())
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

    Effect.new = function()
        local status, val = xpcall(_Effect.new, Log.Error)
        if status then return val end
    end

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
        local units = Group.new()
        local mouse = nil
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
            elseif index == "mouse" then
                return mouse
            elseif index == "handle" then
                return handle
            elseif index == "selection" then
                return selection
            elseif index == "selectionCircle" then
                return selectionCircle
            elseif index == "startPositionX" then
                return GetStartLocationX(id)
            elseif index == "startPositionY" then
                return GetStartLocationY(id)
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        -- Returns if player is local player
        function self.isLocal()
            return GetLocalPlayer() == handle
        end

        self.kick = function()
            local status, val = xpcall(self._kick, Log.Error)
            if status then return val end
        end

        function self._kick()
            RemovePlayer(handle, PLAYER_GAME_RESULT_NEUTRAL)
        end

        self.kick = function()
            local status, val = xpcall(self._kick, Log.Error)
            if status then return val end
        end

        -- NOT SYNC
        function self._clear_messages()
            if GetLocalPlayer() == handle then
                ClearTextMessages()
            end
        end

        self.clear_messages = function()
            local status, val = xpcall(self._clear_messages, Log.Error)
            if status then return val end
        end

        function self._send_message(message, duration)
            DisplayTimedTextToPlayer(handle, 0, 0, duration, message)
        end

        self.send_message = function(message, duration)
            local status, val = xpcall(self._send_message, Log.Error, message, duration)
            if status then return val end
        end

        -- Camera functions start

        function self._setCameraPosition(x, y)
            if self.isLocal() then
                Camera.setPosition(x, y)
            end
            return self
        end

        self.setCameraPosition = function(x, y)
            local status, val = xpcall(self._setCameraPosition, Log.Error, x, y)
            if status then return val end
        end

        function self._setCameraQuickPosition(x, y)
            if self.isLocal() then
                Camera.setQuickPosition(x, y)
            end
            return self
        end

        self.setCameraQuickPosition = function(x, y)
            local status, val = xpcall(self._setCameraQuickPosition, Log.Error, x, y)
            if status then return val end
        end

        function self._setCameraBounds(x1, y1, x2, y2, x3, y3, x4, y4)
            if self.isLocal() then
                Camera.setBounds(x1, y1, x2, y2, x3, y3, x4, y4)
            end
            return self
        end

        self.setCameraBounds = function(x1, y1, x2, y2, x3, y3, x4, y4)
            local status, val = xpcall(self._setCameraBounds, Log.Error, x1, y1, x2, y2, x3, y3, x4, y4)
            if status then return val end
        end

        function self._stopCamera()
            if self.isLocal() then
                Camera.stop()
            end
            return self
        end

        self.stopCamera = function()
            local status, val = xpcall(self._stopCamera, Log.Error)
            if status then return val end
        end

        function self._resetCamera(duration)
            if self.isLocal() then
                Camera.reset(duration)
            end
            return self
        end

        self.resetCamera = function()
            local status, val = xpcall(self._resetCamera, Log.Error, duration)
            if status then return val end
        end

        function self._panCameraTo(x, y)
            if self.isLocal() then
                Camera.panTo(x, y)
            end
            return self
        end

        self.panCameraTo = function(x, y)
            local status, val = xpcall(self._panCameraTo, Log.Error, x, y)
            if status then return val end
        end

        function self._panCameraToTimed(x, y, duration)
            if self.isLocal() then
                Camera.panToTimed(x, y)
            end
            return self
        end

        self.panCameraToTimed = function(x, y, duration)
            local status, val = xpcall(self._panCameraToTimed, Log.Error, x, y, duration)
            if status then return val end
        end
        
        function self._panCameraToZ(x, y, zOffset)
            if self.isLocal() then
                Camera.panToZ(x, y)
            end
            return self
        end

        self.panCameraToZ = function(x, y, zOffset)
            local status, val = xpcall(self._panCameraToZ, Log.Error, x, y, zOffset)
            if status then return val end
        end

        function self._panCameraToTimedZ(x, y, zOffset, duration)
            if self.isLocal() then
                Camera.panToTimedZ(x, y)
            end
            return self
        end

        self.panCameraToTimedZ = function(x, y, zOffset, duration)
            local status, val = xpcall(self._panCameraToTimedZ, Log.Error, x, y, zOffset, duration)
            if status then return val end
        end

        function self._setCameraCinematic(cameraModelFile)
            if self.isLocal() then
                Camera.setCinematic(cameraModelFile)
            end
            return self
        end

        self.setCameraCinematic = function(cameraModelFile)
            local status, val = xpcall(self._setCameraCinematic, Log.Error, cameraModelFile)
            if status then return val end
        end

        function self._setCameraRotateMode(x, y, radiansToSweep, duration)
            if self.isLocal() then
                Camera.setRotateMode(x, y, radiansToSweep, duration)
            end
            return self
        end

        self.setCameraRotateMode = function(x, y, radiansToSweep, duration)
            local status, val = xpcall(self._setCameraRotateMode, Log.Error, x, y, radiansToSweep, duration)
            if status then return val end
        end

        function self._setCameraField(whichField, value, duration)
            if self.isLocal() then
                Camera.setField(whichField, value, duration)
            end
            return self
        end

        self.setCameraField = function(whichField, value, duration)
            local status, val = xpcall(self._setCameraField, Log.Error, whichField, value, duration)
            if status then return val end
        end

        function self._adjustCameraField(whichField, offset, duration)
            if self.isLocal() then
                Camera.adjustField(whichField, offset, duration)
            end
            return self
        end

        self.adjustCameraField = function(whichField, offset, duration)
            local status, val = xpcall(self._adjustCameraField, Log.Error, whichField, offset, duration)
            if status then return val end
        end

        ---------

        function self._setCameraTargetController(whichUnit, xOffset, yOffset, inheritOrientation)
            if self.isLocal() then
                Camera.setTargetController(whichUnit.handle, xOffset, yOffset, inheritOrientation)
            end
            return self
        end
        
        self.setCameraTargetController = function(whichUnit, xOffset, yOffset, inheritOrientation)
            local status, val = xpcall(self._setCameraTargetController, Log.Error, whichUnit, xOffset, yOffset, inheritOrientation)
            if status then return val end
        end

        function self._setCameraOrientController(whichUnit, xOffset, yOffset)
            if self.isLocal() then
                Camera.setOrientController(whichUnit, xOffset, yOffset)
            end
            return self
        end

        self.setCameraOrientController = function(whichUnit, xOffset, yOffset)
            local status, val = xpcall(self._setCameraOrientController, Log.Error, whichUnit, xOffset, yOffset)
            if status then return val end
        end

        function self._setCameraTargetNoise(mag, velocity)
            if self.isLocal() then
                Camera.setTargetNoise(mag, velocity)
            end
            return self
        end

        self.setCameraTargetNoise = function(mag, velocity)
            local status, val = xpcall(self._setCameraTargetNoise, Log.Error, mag, velocity)
            if status then return val end
        end

        function self._setCameraSourceNoise(mag, velocity)
            if self.isLocal() then
                Camera.setSourceNoise(mag, velocity)
            end
            return self
        end

        self.setCameraSourceNoise = function(mag, velocity)
            local status, val = xpcall(self._setCameraSourceNoise, Log.Error, mag, velocity)
            if status then return val end
        end

        function self._setCameraTargetNoiseEx(mag, velocity, vertOnly)
            if self.isLocal() then
                Camera.setTargetNoiseEx(mag, velocity, vertOnly)
            end
            return self
        end

        self.setCameraTargetNoiseEx = function(mag, velocity, vertOnly)
            local status, val = xpcall(self._setCameraTargetNoiseEx, Log.Error, mag, velocity, vertOnly)
            if status then return val end
        end

        function self._setCameraSourceNoiseEx(mag, velocity, vertOnly)
            if self.isLocal() then
                Camera.setSourceNoiseEx(mag, velocity, vertOnly)
            end
            return self
        end

        self.setCameraSourceNoiseEx = function(mag, velocity, vertOnly)
            local status, val = xpcall(self._setCameraSourceNoiseEx, Log.Error, mag, velocity, vertOnly)
            if status then return val end
        end

        function self._setCameraSmoothingFactor(factor)
            if self.isLocal() then
                Camera.setSmoothingFactor(factor)
            end
            return self
        end

        self.setCameraSmoothingFactor = function(factor)
            local status, val = xpcall(self._setCameraSmoothingFactor, Log.Error, factor)
            if status then return val end
        end

        -- Camera functions end

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
            if GetLocalPlayer() == handle then
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

        local eventDispatcher = EventDispatcher.new(
            {"on_leave", "on_message", "on_sync", "on_createUnit",
             "on_unit_select", "on_unit_deselect", "on_unit_death_pre", "on_unit_death",
             "on_unit_damage_pre", "on_unit_damaged_pre", "on_unit_damage_after", "on_unit_damaged_after", 
             "on_unit_attack", "on_unit_attacked",
             "on_unit_level", "on_unit_skill",
             "on_unit_drop_item", "on_unit_pickup_item", "on_unit_use_item", "on_unit_stack_item",
             "on_unit_spell_channel", "on_unit_spell_cast", "on_unit_spell_effect", "on_unit_spell_finish", "on_unit_spell_end"}
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

        function self._on_unit_select(selected)
            eventDispatcher.dispatch("on_unit_select", self, selected)
        end

        self.on_unit_select = function(selected)
            local status, val = xpcall(self._on_unit_select, Log.Error, selected)
            if status then return val end
        end

        function self._on_unit_deselect(deselected)
            eventDispatcher.dispatch("on_unit_deselect", self, deselected)
        end

        self.on_unit_deselect = function(deselected)
            local status, val = xpcall(self._on_unit_deselect, Log.Error, deselected)
            if status then return val end
        end

        function self._on_unit_death_pre(source, target, damageObject)
            eventDispatcher.dispatch("on_unit_death_pre", source, target, damageObject)
        end

        self.on_unit_death_pre = function(source, target, damageObject)
            local status, val = xpcall(self._on_unit_death_pre, Log.Error, source, target, damageObject)
            if status then return val end
        end

        function self._on_unit_death(unit)
            eventDispatcher.dispatch("on_unit_death", unit)
        end

        self.on_unit_death = function(unit)
            local status, val = xpcall(self._on_unit_death, Log.Error, unit)
            if status then return val end
        end

        function self._on_unit_damage_pre(source, target, attack)
            eventDispatcher.dispatch("on_unit_damage_pre", source, target, attack)
        end

        self.on_unit_damage_pre = function(source, target, attack)
            local status, val = xpcall(self._on_unit_damage_pre, Log.Error, source, target, attack)
            if status then return val end
        end

        function self._on_unit_damaged_pre(source, target, attack)
            eventDispatcher.dispatch("on_unit_damaged_pre", source, target, attack)
        end

        self.on_unit_damaged_pre = function(source, target, attack)
            local status, val = xpcall(self._on_unit_damaged_pre, Log.Error, source, target, attack)
            if status then return val end
        end

        function self._on_unit_damage_after(source, target, attack)
            eventDispatcher.dispatch("on_unit_damage_after", source, target, attack)
        end

        self.on_unit_damage_after = function(source, target, attack)
            local status, val = xpcall(self._on_unit_damage_after, Log.Error, source, target, attack)
            if status then return val end
        end

        function self._on_unit_damaged_after(source, target, attack)
            eventDispatcher.dispatch("on_unit_damaged_after", source, target, attack)
        end

        self.on_unit_damaged_after = function(source, target, attack)
            local status, val = xpcall(self._on_unit_damaged_after, Log.Error, source, target, attack)
            if status then return val end
        end

        function self._on_unit_attack(source, target)
            eventDispatcher.dispatch("on_unit_attack", source, target)
        end

        self.on_unit_attack = function(source, target)
            local status, val = xpcall(self._on_unit_attack, Log.Error, source, target)
            if status then return val end
        end

        function self._on_unit_attacked(source, target)
            eventDispatcher.dispatch("on_unit_attacked", source, target)
        end

        self.on_unit_attacked = function(source, target)
            local status, val = xpcall(self._on_unit_attacked, Log.Error, source, target)
            if status then return val end
        end

        function self._on_unit_level(unit)
            eventDispatcher.dispatch("on_unit_level", unit)
        end

        self.on_unit_level = function(unit)
            local status, val = xpcall(self._on_unit_level, Log.Error, unit)
            if status then return val end
        end

        function self._on_unit_skill(unit, abilityId)
            eventDispatcher.dispatch("on_unit_skill", unit, abilityId)
        end

        self.on_unit_skill = function(unit, abilityId)
            local status, val = xpcall(self._on_unit_skill, Log.Error, unit, abilityId)
            if status then return val end
        end

        function self._on_unit_drop_item(unit, item)
            eventDispatcher.dispatch("on_unit_drop_item", unit, item)
        end

        self.on_unit_drop_item = function(unit, item)
            local status, val = xpcall(self._on_unit_drop_item, Log.Error, unit, item)
            if status then return val end
        end

        function self._on_unit_pickup_item(unit, item)
            eventDispatcher.dispatch("on_unit_pickup_item", unit, item)
        end

        self.on_unit_pickup_item = function(unit, item)
            local status, val = xpcall(self._on_unit_pickup_item, Log.Error, unit, item)
            if status then return val end
        end

        function self._on_unit_use_item(unit, item)
            eventDispatcher.dispatch("on_unit_use_item", unit, item)
        end

        self.on_unit_use_item = function(unit, item)
            local status, val = xpcall(self._on_unit_use_item, Log.Error, unit, item)
            if status then return val end
        end

        function self._on_unit_stack_item(unit, item)
            eventDispatcher.dispatch("on_unit_stack_item", unit, item)
        end

        self.on_unit_stack_item = function(unit, item)
            local status, val = xpcall(self._on_unit_stack_item, Log.Error, unit, item)
            if status then return val end
        end

        function self._on_unit_spell_channel(unit, spell)
            eventDispatcher.dispatch("on_unit_spell_channel", unit, spell)
        end

        self.on_unit_spell_channel = function(unit, spell)
            local status, val = xpcall(self._on_unit_spell_channel, Log.Error, unit, spell)
            if status then return val end
        end

        function self._on_unit_spell_cast(unit, spell)
            eventDispatcher.dispatch("on_unit_spell_cast", unit, spell)
        end

        self.on_unit_spell_cast = function(unit, spell)
            local status, val = xpcall(self._on_unit_spell_cast, Log.Error, unit, spell)
            if status then return val end
        end

        function self._on_unit_spell_effect(unit, spell)
            eventDispatcher.dispatch("on_unit_spell_effect", unit, spell)
        end

        self.on_unit_spell_effect = function(unit, spell)
            local status, val = xpcall(self._on_unit_spell_effect, Log.Error, unit, spell)
            if status then return val end
        end

        function self._on_unit_spell_finish(unit, spell)
            eventDispatcher.dispatch("on_unit_spell_finish", unit, spell)
        end

        self.on_unit_spell_finish = function(unit, spell)
            local status, val = xpcall(self._on_unit_spell_finish, Log.Error, unit, spell)
            if status then return val end
        end

        function self._on_unit_spell_end(unit, spell)
            eventDispatcher.dispatch("on_unit_spell_end", unit, spell)
        end

        self.on_unit_spell_end = function(unit, spell)
            local status, val = xpcall(self._on_unit_spell_end, Log.Error, unit, spell)
            if status then return val end
        end

        setmetatable(self, mt)

        do
            mouse = _Window.request_mouse(self)
            keyboard = _Window.request_keyboard(self)

            Trigger.new()
            .registerPlayerEvent(self, EVENT_PLAYER_LEAVE)
            .addAction(
                function()
                    Log.Debug("[PLAYER LEAVE] Name: " .. name .. ", Id:" .. id)
                    self.on_leave(self)
                end
            )

            Trigger.new()
            .registerPlayerChatEvent(self, "", false)
            .addAction(
                function()
                    Log.Debug("[PLAYER MESSAGE] ...")
                    self.on_message(GetEventPlayerChatString())
                end
            )

            Trigger.new()
            .registerPlayerSyncEvent(self, "avalon", false)
            .addAction(
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

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_SELECTED)
            .addAction(
                function()
                    Log.Debug("[UNIT SELECTED] ...")
                    local triggerPlayer = GetTriggerPlayer()
                    local triggerUnit = GetTriggerUnit()

                    triggerPlayer.on_unit_select(triggerUnit)
                    triggerUnit.on_selected(triggerPlayer)
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_DESELECTED)
            .addAction(
                function()
                    Log.Debug("[UNIT DESELECTED] ...")
                    local triggerPlayer = GetTriggerPlayer()
                    local triggerUnit = GetTriggerUnit()

                    triggerPlayer.on_unit_deselect(triggerUnit)
                    triggerUnit.on_deselected(triggerPlayer)
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_DEATH)
            .addAction(
                function()
                    Log.Debug("[UNIT DEATH] ...")
                    local triggerUnit = GetTriggerUnit()

                    triggerUnit.owner.on_unit_death(triggerUnit)
                    triggerUnit.on_death()
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_DAMAGING)
            .addAction(
                function()
                    Log.Debug("[UNIT DAMAGE PRE] ...")
                    local source = GetEventDamageSource()
                    local target = GetEventDamageTarget()
                    local damageObject = ConstructDamageObject()

                    source.owner.on_unit_damage_pre(source, target, damageObject)
                    source.on_damage_pre(target, damageObject)
                    target.owner.on_unit_damaged_pre(source, target, damageObject)
                    target.on_damaged_pre(source, damageObject)

                    damageObject.damage = damageObject.damage + damageObject.crit
                    if target.hp - damageObject.damage < 5 then
                        target.on_death_pre(source, damageObject)
                        target.owner.on_unit_death_pre(source, target, damageObject)
                    end

                    BlzSetEventDamage(damageObject.damage)
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_DAMAGED)
            .addAction(
                function()
                    Log.Debug("[UNIT DAMAGE AFTER] ...")
                    local source = GetEventDamageSource()
                    local target = GetEventDamageTarget()
                    local damageObject = GetDamageObject()

                    source.owner.on_unit_damage_after(source, target, damageObject)
                    source.on_damage_after(target, damageObject)
                    target.owner.on_unit_damaged_after(source, target, damageObject)
                    target.on_damaged_after(source, damageObject)
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_ATTACKED)
            .addAction(
                function()
                    Log.Debug("[UNIT ATTACK] ...")
                    local attacker = GetAttacker()
                    local attacked = GetTriggerUnit()

                    attacker.owner.on_unit_attack(attacker, attacked)
                    attacker.on_attack(attacked)
                    attacked.owner.on_unit_attacked(attacker, attacked)
                    attacked.on_attacked(attacker)
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_HERO_LEVEL)
            .addAction(
                function()
                    Log.Debug("[UNIT LEVEL] ...")
                    local triggerUnit = GetTriggerUnit()

                    triggerUnit.owner.on_unit_level(triggerUnit)
                    triggerUnit.on_level()
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_HERO_SKILL)
            .addAction(
                function()
                    Log.Debug("[UNIT SKILL] ...")
                    local triggerUnit = GetTriggerUnit()

                    triggerUnit.owner.on_unit_skill(triggerUnit, GetLearnedSkill())
                    triggerUnit.on_skill(GetLearnedSkill())
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_DROP_ITEM)
            .addAction(
                function()
                    Log.Debug("[UNIT DROP ITEM] ...")
                    local triggerUnit = GetTriggerUnit()

                    triggerUnit.owner.on_unit_drop_item(triggerUnit, GetManipulatedItem())
                    triggerUnit.on_drop_item(GetManipulatedItem())
                    -- GetManipulatedItem().on_drop(GetTriggerUnit())
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_PICKUP_ITEM)
            .addAction(
                function()
                    Log.Debug("[UNIT PICKUP ITEM] ...")
                    local triggerUnit = GetTriggerUnit()

                    triggerUnit.owner.on_unit_pickup_item(triggerUnit, GetManipulatedItem())
                    triggerUnit.on_pickup_item(GetManipulatedItem())
                    -- GetManipulatedItem().on_pickup(GetTriggerUnit())
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_USE_ITEM)
            .addAction(
                function()
                    Log.Debug("[UNIT USE ITEM] ...")
                    local triggerUnit = GetTriggerUnit()
                    
                    triggerUnit.owner.on_unit_use_item(triggerUnit, GetManipulatedItem())
                    triggerUnit.on_use_item(GetManipulatedItem())
                    -- GetManipulatedItem().on_use(GetTriggerUnit())
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_STACK_ITEM)
            .addAction(
                function()
                    Log.Debug("[UNIT STACK ITEM] ...")
                    local triggerUnit = GetTriggerUnit()

                    triggerUnit.owner.on_unit_stack_item(triggerUnit, GetManipulatedItem())
                    triggerUnit.on_stack_item(GetManipulatedItem())
                    -- GetManipulatedItem().on_stack(triggerUnit)
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_SPELL_CHANNEL)
            .addAction(
                function()
                    Log.Debug("[UNIT SPELL CHANNEL] ...")
                    local triggerUnit = GetTriggerUnit()
                    local spellObject = GetSpellObject()

                    triggerUnit.owner.on_unit_spell_channel(triggerUnit, spellObject)
                    triggerUnit.on_spell_channel(spellObject)
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_SPELL_CAST)
            .addAction(
                function()
                    Log.Debug("[UNIT SPELL CAST] ...")
                    local triggerUnit = GetTriggerUnit()
                    local spellObject = GetSpellObject()

                    triggerUnit.owner.on_unit_spell_cast(triggerUnit, spellObject)
                    triggerUnit.on_spell_cast(spellObject)
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            .addAction(
                function()
                    Log.Debug("[UNIT SPELL EFFECT] ...")
                    local triggerUnit = GetTriggerUnit()
                    local spellObject = GetSpellObject()

                    triggerUnit.owner.on_unit_spell_effect(triggerUnit, spellObject)
                    triggerUnit.on_spell_effect(spellObject)
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_SPELL_FINISH)
            .addAction(
                function()
                    Log.Debug("[UNIT SPELL FINISH] ...")
                    local triggerUnit = GetTriggerUnit()
                    local spellObject = GetSpellObject()

                    triggerUnit.owner.on_unit_spell_finish(triggerUnit, spellObject)
                    triggerUnit.on_spell_finish(spellObject)
                end
            )

            Trigger.new()
            .registerPlayerUnitEvent(self, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
            .addAction(
                function()
                    Log.Debug("[UNIT SPELL END] ...")
                    local triggerUnit = GetTriggerUnit()
                    local spellObject = GetSpellObject()

                    triggerUnit.owner.on_unit_spell_end(triggerUnit, spellObject)
                    triggerUnit.on_spell_end(spellObject)
                end
            )
        end

        Log.Debug("Generating new player object for player " .. id)

        return self

    end

    Easing.linear = function(progress)
        return progress
    end

    Easing.in_sine = function(progress)
        return 1. - math.cos((progress * math.pi) / 2.)
    end

    Easing.out_sine = function(progress)
        return math.sin((progress * math.pi) / 2.)
    end

    Easing.in_out_sine = function(progress)
        return -(math.cos(math.pi * progress) - 1.) / 2.
    end

    Easing.in_quad = function(progress)
        return progress * progress
    end

    Easing.out_quad = function(progress)
        return 1. - (1. - progress) * (1. - progress)
    end

    Easing.in_out_quad = function(progress)
        if progress < 0.5 then
            return 2. * progress * progress
        else
            return 1. - Pow(-2. * progress + 2., 2.) / 2.
        end
    end

    Easing.in_cubic = function(progress)
        return progress * progress * progress
    end

    Easing.out_cubic = function(progress)
        return 1. - Pow(1. - progress, 3.)
    end

    Easing.in_out_cubic = function(progress)
        if progress < 0.5 then
            return 4. * progress * progress * progress
        else
            return 1. - Pow(-2. * progress + 2., 3.) / 2.
        end
    end

    Easing.in_quart = function(progress)
        return progress * progress * progress * progress
    end

    Easing.out_quart = function(progress)
        return 1. - Pow(1. - progress, 4.)
    end

    Easing.in_out_quart = function(progress)
        if progress < 0.5 then
            return 8. * progress * progress * progress * progress
        else
            return 1. - Pow(-2. * progress + 2., 4.) / 2.
        end
    end

    Easing.in_quint = function(progress)
        return progress * progress * progress * progress * progress
    end

    Easing.out_quint = function(progress)
        return 1. - Pow(1. - progress, 5.)
    end

    Easing.in_out_quint = function(progress)
        if progress < 0.5 then
            return 16. * progress * progress * progress * progress * progress
        else
            return 1. - Pow(-2. * progress + 2., 5.) / 2.
        end
    end

    Easing.in_expo = function(progress)
        if progress == 0. then
            return 0.
        else
            return Pow(2., 10. * progress - 10.)
        end
    end

    Easing.out_expo = function(progress)
        if progress == 1. then
            return 1.
        else
            return 1. - Pow(2., -10. * progress)
        end
    end

    Easing.in_out_expo = function(progress)
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

    Easing.in_circ = function(progress)
        return 1. - math.sqrt(1. - Pow(progress, 2.))
    end

    Easing.out_circ = function(progress)
        return math.sqrt(1. - Pow(progress - 1., 2.))
    end

    Easing.in_out_circ = function(progress)
        if progress < 0.5 then
            return (1. - math.sqrt(1. - Pow(2. * progress, 2.))) / 2.
        else
            return (math.sqrt(1. - Pow(-2. * progress + 2., 2.)) + 1.) / 2.
        end
    end

    Easing.in_back = function(progress)
    local c1 = 1.70158
    local c3 = c1 + 1.

        return c3 * progress * progress * progress - c1 * progress * progress
    end

    Easing.out_back = function(progress)
    local c1 = 1.70158
    local c3 = c1 + 1.

        return 1. + c3 * Pow(progress - 1., 3.) + c1 * Pow(progress - 1., 2.)
    end

    Easing.in_out_back = function(progress)
    local c1 = 1.70158
    local c2 = c1 * 1.525

        if progress < 0.5 then
            return (Pow(2. * progress, 2.) * ((c2 + 1.) * 2. * progress - c2)) / 2.
        else
            return (Pow(2. * progress - 2., 2.) * ((c2 + 1.) * (progress * 2. - 2.) + c2) + 2.) / 2.
        end
    end

    Easing.in_elastic = function(progress)
    local c4 = (2. * math.pi) / 3.

        if progress == 0. then
            return 0.
        elseif progress == 1. then
            return 1.
        else
            return -Pow(2., 10. * progress - 10.) * math.sin((progress * 10. - 10.75) * c4)
        end
    end

    Easing.out_elastic = function(progress)
    local c4 = (2. * math.pi) / 3.

        if progress == 0. then
            return 0.
        elseif progress == 1. then
            return 1.
        else
            return Pow(2., -10. * progress) * math.sin((progress * 10. - 0.75) * c4) + 1.
        end
    end

    Easing.in_out_elastic = function(progress)
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

    Easing.in_bounce = function(progress)
        return 1. - Easing.out_bounce(1. - progress)
    end

    Easing.out_bounce = function(progress)
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

    Easing.in_out_bounce = function(progress)
        if progress < 0.5 then
            return (1. - Easing.out_bounce(1. - 2. * progress)) / 2.
        else
            return (1. + Easing.out_bounce(2. * progress - 1.)) / 2.
        end
    end

    --[[
    self.Animation = {}
    self.Animation.new = function(duration, transition, step)
        local clock = self.Clock.new()    
        local self = {}
        clock.start()
        
        self.duration = duration or 0.0
        self.transition = Easing[transition] or Easing.linear
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

        local eventDispatcher = EventDispatcher.new(
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
        
        local eventDispatcher = EventDispatcher.new(
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
        local eventDispatcher = EventDispatcher.new(
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
        local eventDispatcher = EventDispatcher.new(
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
        local eventDispatcher = EventDispatcher.new(
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
        local eventDispatcher = EventDispatcher.new(
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


    -- Engine Camera
    _Camera.new = function()
        local self = {}

        local mt = {}

        self.constants = {}
        self.constants.FIELD_TARGET_DISTANCE = CAMERA_FIELD_TARGET_DISTANCE
        self.constants.FIELD_FARZ = CAMERA_FIELD_FARZ
        self.constants.FIELD_FIELD_OF_VIEW = CAMERA_FIELD_FIELD_OF_VIEW
        self.constants.FIELD_ROLL = CAMERA_FIELD_ROLL
        self.constants.FIELD_ROTATION = CAMERA_FIELD_ROTATION
        self.constants.FIELD_ZOFFSET = CAMERA_FIELD_ZOFFSET

        self.constants.MARGIN_LEFT = CAMERA_MARGIN_LEFT
        self.constants.MARGIN_RIGHT = CAMERA_MARGIN_RIGHT
        self.constants.MARGIN_TOP = CAMERA_MARGIN_TOP
        self.constants.MARGIN_BOTTOM = CAMERA_MARGIN_BOTTOM

        -- Camera Getter
        function mt.__index(table, index)
            if index == "boundMinX" then
                return GetCameraBoundMinX()
            elseif index == "boundMinY" then
                return GetCameraBoundMinY()
            elseif index == "boundMaxX" then
                return GetCameraBoundMaxX()
            elseif index == "boundMaxY" then
                return GetCameraBoundMaxY()
            elseif index == "targetPositionX" then
                return GetCameraTargetPositionX()
            elseif index == "targetPositionY" then
                return GetCameraTargetPositionY()
            elseif index == "targetPositionZ" then
                return GetCameraTargetPositionZ()
            elseif index == "eyePositionX" then
                return GetCameraEyePositionX()
            elseif index == "eyePositionY" then
                return GetCameraEyePositionY()
            elseif index == "eyePositionZ" then
                return GetCameraEyePositionZ()
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        setmetatable(self, mt)

        function self._getMargin(whichMargin)
            return GetCameraMargin(whichMargin)
        end

        self.getMargin = function(whichMargin)
            local status, val = xpcall(self._getMargin, Log.Error, whichMargin)
            if status then return val end
        end

        function self._getField(whichField)
            GetCameraField(whichField)
            return self
        end

        self.getField = function(whichField)
            local status, val = xpcall(self._getField, Log.Error, whichField)
            if status then return val end
        end

        function self._setPosition(x, y)
            SetCameraPosition(x, y)
            return self
        end

        self.setPosition = function(x, y)
            local status, val = xpcall(self._setPosition, Log.Error, x, y)
            if status then return val end
        end

        function self._setQuickPosition(x, y)
            SetCameraQuickPosition(x, y)
            return self
        end

        self.setQuickPosition = function(x, y)
            local status, val = xpcall(self._setQuickPosition, Log.Error, x, y)
            if status then return val end
        end

        function self._setBounds(x1, y1, x2, y2, x3, y3, x4, y4)
            SetCameraBounds(x1, y1, x2, y2, x3, y3, x4, y4)
            return self
        end

        self.setBounds = function(x1, y1, x2, y2, x3, y3, x4, y4)
            local status, val = xpcall(self._setBounds, Log.Error, x1, y1, x2, y2, x3, y3, x4, y4)
            if status then return val end
        end

        function self._stop()
            StopCamera()
            return self
        end

        self.stop = function()
            local status, val = xpcall(self._stop, Log.Error)
            if status then return val end
        end

        function self._reset(duration)
            ResetToGameCamera(duration)
            return self
        end

        self.reset = function()
            local status, val = xpcall(self._reset, Log.Error, duration)
            if status then return val end
        end

        function self._panTo(x, y)
            PanCameraTo(x, y)
            return self
        end

        self.panTo = function(x, y)
            local status, val = xpcall(self._panTo, Log.Error, x, y)
            if status then return val end
        end

        function self._panToTimed(x, y, duration)
            PanCameraToTimed(x, y)
            return self
        end

        self.panToTimed = function(x, y, duration)
            local status, val = xpcall(self._panToTimed, Log.Error, x, y, duration)
            if status then return val end
        end
        
        function self._panToZ(x, y, zOffset)
            PanCameraToWithZ(x, y)
            return self
        end

        self.panToZ = function(x, y, zOffset)
            local status, val = xpcall(self._panToZ, Log.Error, x, y, zOffset)
            if status then return val end
        end

        function self._panToTimedZ(x, y, zOffset, duration)
            PanCameraToTimedWithZ(x, y)
            return self
        end

        self.panToTimedZ = function(x, y, zOffset, duration)
            local status, val = xpcall(self._panToTimedZ, Log.Error, x, y, zOffset, duration)
            if status then return val end
        end

        function self._setCinematic(cameraModelFile)
            PanCameraToTimedWithZ(cameraModelFile)
            return self
        end

        self.setCinematic = function(cameraModelFile)
            local status, val = xpcall(self._setCinematic, Log.Error, cameraModelFile)
            if status then return val end
        end

        function self._setRotateMode(x, y, radiansToSweep, duration)
            SetCameraRotateMode(x, y, radiansToSweep, duration)
            return self
        end

        self.setRotateMode = function(x, y, radiansToSweep, duration)
            local status, val = xpcall(self._setRotateMode, Log.Error, x, y, radiansToSweep, duration)
            if status then return val end
        end

        function self._setField(whichField, value, duration)
            SetCameraField(whichField, value, duration)
            return self
        end

        self.setField = function(whichField, value, duration)
            local status, val = xpcall(self._setField, Log.Error, whichField, value, duration)
            if status then return val end
        end

        function self._adjustField(whichField, offset, duration)
            AdjustCameraField(whichField, offset, duration)
            return self
        end

        self.adjustField = function(whichField, offset, duration)
            local status, val = xpcall(self._adjustField, Log.Error, whichField, offset, duration)
            if status then return val end
        end

        function self._setTargetController(whichUnit, xOffset, yOffset, inheritOrientation)
            SetCameraTargetController(whichUnit.handle, xOffset, yOffset, inheritOrientation)
            return self
        end

        self.setTargetController = function(whichUnit, xOffset, yOffset, inheritOrientation)
            local status, val = xpcall(self._setTargetController, Log.Error, whichUnit, xOffset, yOffset, inheritOrientation)
            if status then return val end
        end

        function self._setOrientController(whichUnit, xOffset, yOffset)
            SetCameraOrientController(whichUnit, xOffset, yOffset)
            return self
        end

        self.setOrientController = function(whichUnit, xOffset, yOffset)
            local status, val = xpcall(self._setOrientController, Log.Error, whichUnit, xOffset, yOffset)
            if status then return val end
        end

        function self._setTargetNoise(mag, velocity)
            CameraSetTargetNoise(mag, velocity)
            return self
        end

        self.setTargetNoise = function(mag, velocity)
            local status, val = xpcall(self._setTargetNoise, Log.Error, mag, velocity)
            if status then return val end
        end

        function self._setSourceNoise(mag, velocity)
            CameraSetSourceNoise(mag, velocity)
            return self
        end

        self.setSourceNoise = function(mag, velocity)
            local status, val = xpcall(self._setSourceNoise, Log.Error, mag, velocity)
            if status then return val end
        end

        function self._setTargetNoiseEx(mag, velocity, vertOnly)
            CameraSetTargetNoiseEx(mag, velocity, vertOnly)
            return self
        end

        self.setTargetNoiseEx = function(mag, velocity, vertOnly)
            local status, val = xpcall(self._setTargetNoiseEx, Log.Error, mag, velocity, vertOnly)
            if status then return val end
        end

        function self._setSourceNoiseEx(mag, velocity, vertOnly)
            CameraSetSourceNoiseEx(mag, velocity, vertOnly)
            return self
        end

        self.setSourceNoiseEx = function(mag, velocity, vertOnly)
            local status, val = xpcall(self._setSourceNoiseEx, Log.Error, mag, velocity, vertOnly)
            if status then return val end
        end

        function self._setSmoothingFactor(factor)
            CameraSetSmoothingFactor(factor)
            return self
        end

        self.setSmoothingFactor = function(factor)
            local status, val = xpcall(self._setSmoothingFactor, Log.Error, factor)
            if status then return val end
        end

        return self

    end

    Camera = _Camera.new()

    
    -- Engine Keyboard
    _Keyboard.new = function(whichPlayer)
        local self = {}

        local player = whichPlayer
        local keydown = {}

        local mt = {}

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

        -- Keyboard Getter
        function mt.__index(table, index)
            if index == "player" then
                return player
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        setmetatable(self, mt)

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

        local eventDispatcher = EventDispatcher.new(
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
            local keyDown = Trigger.new()
            keyDown.addAction(
                function()
                    if not keydown[index] then
                        Log.Debug("[KEY DOWN] Keycode: " .. index .. ", Modifier" .. BlzGetTriggerPlayerMetaKey())
                        keydown[index] = true
                        self.on_key_down(index, BlzGetTriggerPlayerKey(), BlzGetTriggerPlayerMetaKey())
                    end
                end
            )

            local keyUp = Trigger.new()
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

        Log.Debug("Generated new Keyboard for " .. player.name)

        return self

    end

    -- Engine Mouse
    _Mouse.new = function(whichPlayer)
        local self = {}

        local player = whichPlayer
        local keydown = {}

        local x = 0.
        local y = 0.

        local mt = {}

        -- Mouse Getter
        function mt.__index(table, index)
            if index == "x" then
                return x
            elseif index == "y" then
                return y
            elseif index == "player" then
                return player
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end


        local eventDispatcher = EventDispatcher.new(
            {"on_mouse_down", "on_mouse_up", "on_motion"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind
        
        -- Fired when user presses mouse key
        function self._on_mouse_down(pos, button)
            eventDispatcher.dispatch("on_mouse_down", self, pos, button)
        end

        self.on_mouse_down = function(pos, button)
            local status, val = xpcall(self._on_mouse_down, Log.Error, pos, button)
            if status then return val end
        end

        -- Fired when user releases mouse key
        function self._on_mouse_up(pos, button)
            eventDispatcher.dispatch("on_mouse_up", self, pos, button)
        end

        self.on_mouse_up = function(pos, button)
            local status, val = xpcall(self._on_mouse_up, Log.Error, pos, button)
            if status then return val end
        end

        -- Fired when user moves mouse
        function self._on_motion(pos)
            eventDispatcher.dispatch("on_motion", self, pos)
        end

        self.on_motion = function(pos)
            local status, val = xpcall(self._on_motion, Log.Error, pos)
            if status then return val end
        end

        setmetatable(self, mt)

        Trigger.new()
        .registerPlayerEvent(player, EVENT_PLAYER_MOUSE_DOWN)
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
                x = BlzGetTriggerPlayerMouseX()
                y = BlzGetTriggerPlayerMouseY()
                self.on_mouse_down({x, y}, {BlzGetTriggerPlayerMouseButton(), whichButton})
            end
        )

        Trigger.new()
        .registerPlayerEvent(player, EVENT_PLAYER_MOUSE_UP)
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
                x = BlzGetTriggerPlayerMouseX()
                y = BlzGetTriggerPlayerMouseY()
                self.on_mouse_up({x, y}, {BlzGetTriggerPlayerMouseButton(), whichButton})
            end
        )

        Trigger.new()
        .registerPlayerEvent(player, EVENT_PLAYER_MOUSE_MOVE)
        .addAction(
            function()
                x = BlzGetTriggerPlayerMouseX()
                y = BlzGetTriggerPlayerMouseY()
                Log.Debug("[MOUSE MOVE] Mouse Position: (" .. x .. " | " .. y .. ")")
                self.on_motion({x, y})
            end
        )

        Log.Debug("Generated new Mouse for " .. player.name)

        return self

    end

    -- Engine Window
    -- Request Player Keyboard
    function _Window._request_keyboard(player)
        if player.keyboard ~= nil then return player.keyboard else return _Keyboard.new(player) end
    end

    _Window.request_keyboard = function(player)
        local status, val = xpcall(_Window._request_keyboard, Log.Error, player)
        if status then return val end
    end

    -- Request Player Mouse
    function _Window._request_mouse(player)
        if player.mouse ~= nil then return player.mouse else return _Mouse.new(player) end
    end

    _Window.request_mouse = function(player)
        local status, val = xpcall(_Window._request_mouse, Log.Error, player)
        if status then return val end
    end
    _Window.new = function()
        local self = {}
        local handle = BlzGetFrameByName("ConsoleUIBackdrop", 0)
        local childs = {}
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOM, 0.4, 0.)
        BlzFrameSetEnable(handle, false)
        local mt = {}

        -- Window Getter
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

        setmetatable(self, mt)

        return self

    end

    local Window = _Window.new()

    
    -- Engine Clock
    _Clock.new = function()
        local self = {}
        local handle = CreateTimer()
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
                return self
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
            return self
        end

        self.stop = function()
            local status, val = xpcall(self._stop, Log.Error)
            if status then return val end
        end

        function self._start()
            Log.Debug("[CLOCK] A clock was started.")
            self.running = true
            TimerStart(handle, 0.001, true, self.on_schedule)
            return self
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

    Clock.new = function()
        local status, val = xpcall(_Clock.new, Log.Error)
        if status then return val end
    end

    _SoundLoader.new = function()
        local self = {}
        local clock = _Clock.new()
        clock.start()

        local Sound = {}
        Sound.new = function(file, _3d)
            local self = {}
            local sound = CreateSound(file, false, true, false, 0, 0, "DefaultEAXON")
            SetSoundDuration(sound, GetSoundDuration(sound))
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
                elseif index == "channel" then
                    SetSoundChannel(sound, value)
                elseif index == "distance" then
                    SetSoundDistances(sound, value[1], value[2])
                elseif index == "distanceCutoff" then
                    SetSoundDistanceCutoff(sound, value)
                elseif index == "coneAngles" then
                    SetSoundConeAngles(sound, value[1], value[2], value[3])
                elseif index == "coneOrientation" then
                    SetSoundChannel(sound, value[1], value[2], value[3])
                elseif index == "position" then
                    SetSoundPosition(sound, value[1], value[2], value[3])
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

            local eventDispatcher = EventDispatcher.new(
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

    local SoundLoader = _SoundLoader.new()


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
    local teleportCaster = {
        [0] = "Effects\\Blink Red Caster.mdx",
        [1] = "Effects\\Blink Blue Caster.mdx",
        [2] = "Effects\\Blink Teal Caster.mdx",
        [3] = "Effects\\Blink Purple Caster.mdx",
        [4] = "Effects\\Blink Gold Caster.mdx",
        [5] = "Effects\\Blink Gold Caster.mdx",
        [6] = "Effects\\Blink Green Caster.mdx",
        [7] = "Effects\\Blink Pink Caster.mdx"
    }

    local teleportTarget = {
        [0] = "Effects\\Blink Red Target.mdx",
        [1] = "Effects\\Blink Blue Target.mdx",
        [2] = "Effects\\Blink Teal Target.mdx",
        [3] = "Effects\\Blink Purple Target.mdx",
        [4] = "Effects\\Blink Gold Target.mdx",
        [5] = "Effects\\Blink Gold Target.mdx",
        [6] = "Effects\\Blink Green Target.mdx",
        [7] = "Effects\\Blink Pink Target.mdx"
    }

    _Unit.new = function(unit)
        local self = {}
        local handle = Indexer.add(self, unit)
        local color = GetPlayerColor(_GetOwningPlayer(handle))
        local scale = nil
        local timescale = 1.0
        local blendtime = 1.0
        local movementSpeed = GetUnitMoveSpeed(handle)
        local movementSpeedClock = Clock.new()
        local manualX = GetUnitX(handle)
        local manualY = GetUnitY(handle)
        movementSpeedClock.schedule_interval(
            function(triggeringClock, triggeringSchedule)
                self.x = self.x + (self.ms / 500) * math.cos(bj_DEGTORAD * self.face)
                self.y = self.y + (self.ms / 500) * math.sin(bj_DEGTORAD * self.face)
            end, 0.002
        ).setCondition(
            function(triggeringClock, triggeringSchedule)
                return manualX ~= self.x or manualY ~= self.y
            end
        )
        local highMovementSpeedEffect = Effect.new()
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

        local critChance = 0
        local critDamage = 0

        if IsHeroUnitId(GetUnitTypeId(handle)) then
            -- Capture Hero Stats
            --local capturedLevel = GetHeroLevel(handle)
            --SetHeroLevel(handle, 1)
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
            --SetHeroLevel(handle, capturedLevel, false)
            --capturedLevel = nil
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
                BlzSetUnitMaxHP(handle, math.floor(value))
            elseif index == "mp" then
                SetUnitState(handle, UNIT_STATE_MANA, value)
            elseif index == "maxmp" then
                BlzSetUnitMaxMana(handle, value)
            elseif index == "armor"then
                BlzSetUnitArmor(handle, value)
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
            elseif index == "height" then
                UnitAddAbility(handle, 'Amrf')
                SetUnitFlyHeight(handle, value)
                UnitRemoveAbility(handle, 'Amrf')
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
            elseif index == "attackspeed" then
                BlzSetUnitAttackCooldown(handle, 1.0 / value, 0)
            elseif index == "damage" then
                BlzSetUnitBaseDamage(handle, math.floor(value), 0)
            elseif index == "str" then
                if IsHeroUnitId(GetUnitTypeId(handle)) then
                    customStr = value - (GetHeroStr(handle, false) - customStr)
                    SetHeroStr(handle, value)
                else
                    Log.Error("Can't manipulate strength attribute of non-hero units.")
                end
            elseif index == "agi" then
                if IsHeroUnitId(GetUnitTypeId(handle)) then
                    customAgi = value - (GetHeroAgi(handle, false) - customAgi)
                    SetHeroAgi(handle, value)
                else
                    Log.Error("Can't manipulate agility attribute of non-hero units.")
                end
            elseif index == "int" then
                if IsHeroUnitId(GetUnitTypeId(handle)) then
                    customInt = value - (GetHeroInt(handle, false) - customInt)
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
                    if value <= GetHeroLevel(handle) then
                        SetHeroLevel(handle, value, false)
                    else
                        for level = GetHeroLevel(handle), value, 1 do
                            SetHeroLevel(handle, level, true)
                        end
                    end
                else
                    BlzSetUnitIntegerField(handle, UNIT_IF_LEVEL, value)
                end
            elseif index == "pause" then
                PauseUnit(handle, value)
            elseif index == "propername" then
                BlzSetHeroProperName(handle, value)
            elseif index == "name" then
                BlzSetUnitName(handle, value)
            elseif index == "skin" then
                if type(value) == "number" then
                    BlzSetUnitSkin(handle, value)
                else
                    BlzSetUnitSkin(handle, FourCC(value))
                end
            elseif index == "invulnerable" then
                SetUnitInvulnerable(handle, value)
            elseif index == "range" then
                BlzSetUnitWeaponRealField(handle, UNIT_WEAPON_RF_ATTACK_RANGE, 0, value)
            elseif index == "critChance" then
                critChance = value
            elseif index == "critDamage" then
                critDamage = value
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
            elseif index == "armor" then
                return BlzGetUnitArmor(handle)
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
            elseif index == "height" then
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
            elseif index == "skillPoints" then
                if IsHeroUnitId(GetUnitTypeId(handle)) then
                    return GetHeroSkillPoints(handle)
                else
                    Log.Error("Can't retrieve Skill Points of non-hero units.")
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
            elseif index == "range" then
                return BlzGetUnitWeaponRealField(handle, UNIT_WEAPON_RF_ATTACK_RANGE, 0)
            elseif index == "critChance" then
                return critChance
            elseif index == "critDamage" then
                return critDamage
            elseif index == "acquireRange" then
                return GetUnitAcquireRange(handle)
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        function self._teleportTo(targetX, targetY, disableFade)
            local disableFade = disableFade or false
            local effectCaster = Effect.new()
            effectCaster.model = teleportCaster[self.owner.id]
            effectCaster.x = self.x
            effectCaster.y = self.y
            effectCaster.z = self.z
            effectCaster.create().destroy()

            self.x = targetX
            self.y = targetY

            local effectTarget = Effect.new()
            effectTarget.model = teleportTarget[self.owner.id]
            effectTarget.x = self.x
            effectTarget.y = self.y
            effectTarget.z = self.z
            effectTarget.create().destroy()

            if not disableFade then
                self.fadeIn(1.0)
            end
        end

        self.teleportTo = function(targetX, targetY)
            local status, val = xpcall(self._teleportTo, Log.Error, targetX, targetY)
            if status then return val end
        end

        function self._fadeIn(duration)
            local alpha = 0
            local tickrate = 0.0165
            local change = R2I((255 / duration) * tickrate)
            local clock = Clock.new()
            clock.start()

            self.setVertexColor(255, 255, 255, alpha)

            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    if alpha + change > 255 then
                        alpha = 255
                        clock.unschedule(triggeringSchedule)
                        clock.stop()
                        clock = nil
                    else
                        alpha = alpha + change
                    end
                    self.setVertexColor(255, 255, 255, alpha)
                end, tickrate
            )
            return self
        end

        self.fadeIn = function(duration)
            local status, val = xpcall(self._fadeIn, Log.Error, duration)
            if status then return val end
        end

        function self._fadeOut(duration)
            local alpha = 0
            local tickrate = 0.0165
            local change = -R2I((255 / duration) * tickrate)
            local clock = Clock.new()
            clock.start()

            self.setVertexColor(255, 255, 255, alpha)

            clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    if alpha + change <= 0 then
                        alpha = 0
                        clock.unschedule(triggeringSchedule)
                        clock.stop()
                        clock = nil
                    else
                        alpha = alpha + change
                    end
                    self.setVertexColor(255, 255, 255, alpha)
                end, tickrate
            )
            return self
        end

        self.fadeOut = function(duration)
            local status, val = xpcall(self._fadeOut, Log.Error, duration)
            if status then return val end
        end

        function self._inGroup(group)
            return group.inGroup(self)
        end

        self.inGroup = function(group)
            local status, val = xpcall(self._inGroup, Log.Error, group)
            if status then return val end
        end

        function self._faceInstant(angle)
            BlzSetUnitFacingEx(handle, angle)
            return self
        end

        self.faceInstant = function(angle)
            local status, val = xpcall(self._faceInstant, Log.Error, angle)
            if status then return val end
        end

        function self._playAnimation(animation)
            if type(animation) == "number" then
                SetUnitAnimationByIndex(handle, animation)
            else
                SetUnitAnimation(handle, animation)
            end
            return self
        end

        self.playAnimation = function(animation)
            local status, val = xpcall(self._playAnimation, Log.Error, animation)
            if status then return val end
        end

        function self._kill()
            KillUnit(handle)
            return self
        end

        self.kill = function()
            local status, val = xpcall(self._kill, Log.Error)
            if status then return val end
        end

        function self._respawn(x, y)
            ReviveHero(handle, x, y, false)
            return self
        end

        self.respawn = function(x, y)
            local status, val = xpcall(self._respawn, Log.Error, x, y)
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
            return self
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
            return self
        end

        self.buildOrder = function(order, x, y)
            local status, val = xpcall(self._buildOrder, Log.Error, order, x, y)
            if status then return val end
        end

        function self._damageTarget(target, amount, attack, ranged, attackType, damageType, weaponType)
            UnitDamageTarget(handle, target.handle, amount, attack, ranged, attackType, damageType, weaponType)
            return self
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

        function self._removeAbility(abilityId)
            if type(abilityId) == "number" then
                UnitRemoveAbility(handle, abilityId)
            else
                UnitRemoveAbility(handle, FourCC(abilityId))
            end
            return self
        end

        self.removeAbility = function(abilityId)
            local status, val = xpcall(self._removeAbility, Log.Error, abilityId)
            if status then return val end
        end

        function self._addAbility(abilityId)
            if type(abilityId) == "number" then
                UnitAddAbility(handle, abilityId)
            else
                UnitAddAbility(handle, FourCC(abilityId))
            end
            return self
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
            return self
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
            return BlzGetUnitWeaponIntegerField(handle, field, index)
        end

        self.getWeaponIntegerField = function(field, index)
            local status, val = xpcall(self._getWeaponIntegerField, Log.Error, field, index)
            if status then return val end
        end

        function self._getWeaponStringField(field, index)
            return BlzGetUnitWeaponStringField(handle, field, index)
        end

        self.getWeaponStringField = function(field, index)
            local status, val = xpcall(self._getWeaponStringField, Log.Error, field, index)
            if status then return val end
        end

        function self._setVertexColor(red, green, blue, alpha)
            SetUnitVertexColor(handle, red, green, blue, alpha)
            return self
        end

        self.setVertexColor = function(red, green, blue, alpha)
            local status, val = xpcall(self._setVertexColor, Log.Error, red, green, blue, alpha)
            if status then return val end
        end

        local eventDispatcher = EventDispatcher.new(
            {"on_selected", "on_deselected",
             "on_death_pre", "on_death", "on_remove", 
             "on_damage_pre", "on_damaged_pre", "on_damage_after", "on_damaged_after", 
             "on_attack", "on_attacked",
             "on_exp", "on_level", "on_skill",
             "on_drop_item", "on_pickup_item", "on_use_item", "on_stack_item",
             "on_spell_channel", "on_spell_cast", "on_spell_effect", "on_spell_finish", "on_spell_end",
             "on_field_update"}
        )
        self.bind = eventDispatcher.bind
        self.unbind = eventDispatcher.unbind

        function self._on_deselected(deselector)
            eventDispatcher.dispatch("_on_deselected", deselector, self)
        end

        self.on_deselected = function(deselector)
            local status, val = xpcall(self._on_deselected, Log.Error, deselector, self)
            if status then return val end
        end

        function self._on_selected(selector)
            eventDispatcher.dispatch("on_selected", selector, self)
        end

        self.on_selected = function(selector)
            local status, val = xpcall(self._on_selected, Log.Error, selector)
            if status then return val end
        end

        function self._on_death_pre(source, damageObject)
            eventDispatcher.dispatch("on_death_pre", source, self, damageObject)
        end

        self.on_death_pre = function(source, damageObject)
            local status, val = xpcall(self._on_death_pre, Log.Error, source, damageObject)
            if status then return val end
        end

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

        function self._on_skill(abilityId)
            eventDispatcher.dispatch("on_skill", self, abilityId)
        end

        self.on_skill = function(abilityId)
            local status, val = xpcall(self._on_skill, Log.Error, abilityId)
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

        function self._on_field_update(field, oldValue, newValue)
            eventDispatcher.dispatch("on_field_update", self, field, oldValue, newValue)
        end

        self.on_field_update = function(field, oldValue, newValue)
            local status, val = xpcall(self._on_spell_end, Log.Error, field, oldValue, newValue)
            if status then return val end
        end

        setmetatable(self, mt)

        return self
    end

    Unit.new = function(player, unitId, x, y, face)
        local status, val = xpcall(_Unit.new, Log.Error, player.createUnit(unitId, x, y, face))
        if status then return val end
    end

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
    _Group.new = function()
        local self = {}
        local units = {}
        local mt = {}
        local handle = CreateGroup()

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

        function self._inRange(x, y, range)
            units = {}
            GroupEnumUnitsInRange(handle, x, y, range, Filter(
                function()
                    table.insert(units, GetFilterUnit())
                end
            ))
            return self
        end

        self.inRange = function(x, y, range)
            local status, val = xpcall(self._inRange, Log.Error, x, y, range)
            if status then return val end
        end

        function self._inRect(rect)
            units = {}
            GroupEnumUnitsInRect(handle, rect, Filter(
                function()
                    table.insert(units, GetFilterUnit())
                end
            ))
            return self
        end

        self.inRect = function(rect)
            local status, val = xpcall(self._inRect, Log.Error, rect)
            if status then return val end
        end

        function self._inRangeFiltered(x, y, range, filter)
            units = {}
            GroupEnumUnitsInRange(handle, x, y, range, Filter(
                function()
                    local filterUnit = GetFilterUnit()
                    if filter(group, filterUnit) then
                        table.insert(units, filterUnit)
                    end
                end
            ))
            return self
        end

        self.inRangeFiltered = function(x, y, range, filter)
            local status, val = xpcall(self._inRangeFiltered, Log.Error, x, y, range, filter)
            if status then return val end
        end

        function self._getRandom()
            return units[math.random(#units)]
        end

        self.getRandom = function()
            local status, val = xpcall(self._getRandom, Log.Error)
            if status then return val end
        end

        function self._inGroup(unit)
            for _, value in ipairs(units) do
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
                for index, unit in ipairs(units) do count = count + 1 end
                return count
            else
                Log.Error("Unknown attribute '" .. index .. "'.")
            end
        end

        -- currently wont work
        function self.__sub(group)
            newGroup = _Group.new({self, group})
            for index, unit in ipairs(group.unit) do
                newGroup.remove(unit)
            end
            return newGroup
        end

        -- currently wont work
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

        function self._forEach(action)
            self.on_foreach()
            for index, unit in ipairs(units) do
                action(self, unit)
            end
            return self
        end

        self.forEach = function(action)
            local status, val = xpcall(self._forEach, Log.Error, action)
            if status then return val end
        end

        local eventDispatcher = EventDispatcher.new(
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

    Group.new = function()
        local status, val = xpcall(_Group.new, Log.Error)
        if status then return val end
    end

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
    -- _Item.new = function(item)
    --     local self = {}
    --     local handle = Indexer.add(self, item)
    --     local droppable
    --     local mt = {}

    --     function mt.__newindex(table, index, value)
    --         if index == "name" then
    --             BlzSetItemName(handle, value)
    --         elseif index == "visible" then
    --             SetItemVisible(handle, value)
    --         elseif index == "player" then
    --             SetItemPlayer(handle, value)
    --         elseif index == "x" then
    --             SetItemPosition(handle, value, self.y)
    --         elseif index == "y" then
    --             SetItemY(handle, self.x, y)
    --         elseif index == "invulnerable" then
    --             SetItemInvulnerable(handle, value)
    --         elseif index == "droppable" then
    --             droppable = value
    --             SetItemDroppable(handle, value)
    --         elseif index == "pawnable" then
    --             SetItemPawnable(handle, value)
    --         elseif index == "charges" then
    --             SetItemCharges(handle, value)
    --         elseif index == "description" then
    --             BlzSetItemDescription(handle, value)
    --         elseif index == "tooltip" then
    --             BlzSetItemTooltip(handle, value)
    --         elseif index == "extendedTooltip" then
    --             BlzSetItemExtendedTooltip(handle, value)
    --         elseif index == "icon" then
    --             BlzSetItemIconPath(handle, value)
    --         elseif index == "skin" then
    --             if type(value) == "number" then
    --                 BlzSetUnitSkin(handle, value)
    --             else
    --                 BlzSetUnitSkin(handle, FourCC(value))
    --             end
    --         else
    --             Log.Error("Unknown attribute '" .. index .. "'.")
    --         end
    --     end

    --     function mt.__index(index)
    --         if index == "name" then
    --             return GetItemName(handle)
    --         elseif index == "id" then
    --             return GetItemTypeId(handle)
    --         elseif index == "visible" then
    --             return IsItemVisible(handle)
    --         elseif index == "player" then
    --             return GetItemPlayer(handle)
    --         elseif index == "x" then
    --             return GetItemX(handle)
    --         elseif index == "y" then
    --             return GetItemY(handle)
    --         elseif index == "invulnerable" then
    --             return IsItemInvulnerable(handle)
    --         elseif index == "owned" then
    --             return IsItemOwned(handle)
    --         elseif index == "droppable" then
    --             return droppable
    --         elseif index == "powerup" then
    --             return IsItemPowerup(handle)
    --         elseif index == "sellable" then
    --             return IsItemSellable(handle)
    --         elseif index == "pawnable" then
    --             return IsItemPawnable(handle)
    --         elseif index == "level" then
    --             return GetItemLevel(handle)
    --         elseif index == "type" then
    --             return GetItemType(handle)
    --         elseif index == "charges" then
    --             return GetItemCharges(handle)
    --         elseif index == "description" then
    --             return BlzGetItemDescription(handle)
    --         elseif index == "tooltip" then
    --             return BlzGetItemTooltip(handle)
    --         elseif index == "extendedTooltip" then
    --             return BlzGetItemExtendedTooltip(handle)
    --         elseif index == "icon" then
    --             return BlzGetItemIconPath(handle)
    --         elseif index == "skin" then
    --             return BlzGetUnitSkin(handle)
    --         elseif index == "handle" then
    --             return handle
    --         else
    --             Log.Error("Unknown attribute '" .. index .. "'.")
    --         end
    --     end

    --     local eventDispatcher = EventDispatcher.new(
    --         {"on_use", "on_drop", "on_pickup", "on_stack", "on_destroy"}
    --     )
    --     self.bind = eventDispatcher.bind
    --     self.unbind = eventDispatcher.unbind

    --     function self._on_use(triggerUnit)
    --         eventDispatcher.dispatch("on_use", self, triggerUnit)
    --     end

    --     self.on_use = function(triggerUnit)
    --         local status, val = xpcall(self._on_use, Log.Error, triggerUnit)
    --         if status then return val end
    --     end

    --     function self._on_drop(triggerUnit)
    --         eventDispatcher.dispatch("on_drop", self, triggerUnit)
    --     end

    --     self.on_drop = function(triggerUnit)
    --         local status, val = xpcall(self._on_drop, Log.Error, triggerUnit)
    --         if status then return val end
    --     end

    --     function self._on_pickup(triggerUnit)
    --         eventDispatcher.dispatch("on_pickup", self, triggerUnit)
    --     end

    --     self.on_pickup = function(triggerUnit)
    --         local status, val = xpcall(self._on_pickup, Log.Error, triggerUnit)
    --         if status then return val end
    --     end

    --     function self._on_stack(triggerUnit)
    --         eventDispatcher.dispatch("on_stack", self, triggerUnit)
    --     end

    --     self.on_stack = function(triggerUnit)
    --         local status, val = xpcall(self._on_stack, Log.Error, triggerUnit)
    --         if status then return val end
    --     end

    --     function self._on_destroy()
    --         eventDispatcher.dispatch("on_destroy", self)
    --     end

    --     self.on_destroy = function()
    --         local status, val = xpcall(self._on_destroy, Log.Error)
    --         if status then return val end
    --     end

    --     setmetatable(self, mt)

    --     do
    --         Trigger.new()
    --         .registerDeathEvent(handle)
    --         .addAction(
    --             function()
    --                 Log.Debug("[ITEM DESTROY] ...")
    --                 self.on_destroy()
    --             end
    --         )
    --     end

    --     return self
    -- end

    -- Item.new = function(itemId, x, y)
    --     local status, val = xpcall(_Item.new, Log.Error, CreateItem(itemId, x, y))
    --     if status then return val end
    -- end

    self.Player = {}
    for pID = 0, 27 do
        self.Player[pID] = _Player.new(_Player_(pID))
    end

    -- Delete pre-placed units
    do
        GroupEnumUnitsInRect(CreateGroup(), GetWorldBounds(), 
            Filter(
                function()
                    RemoveUnit(_GetFilterUnit())
                    -- _Unit.new(_GetFilterUnit())
                    -- GetOwningPlayer(GetFilterUnit()).units.append(GetFilterUnit())
                end
            )
        )
    end

    -- Delete pre-placed items
    do
        EnumItemsInRect(GetWorldBounds(), 
            Filter(
                function()
                    RemoveItem(_GetFilterItem())
                    -- _Item.new(_GetFilterItem())
                end
            )
        )
    end


    -- Capture default creationg functions
--    local _PlaceRandomUnit = PlaceRandomUnit
--    PlaceRandomUnit = function(whichPool, forWhichPlayer, x, y, facing)
--        local handle = _PlaceRandomUnit(whichPool, forWhichPlayer, x, y, facing)
--        local unit = _Unit.new(handle)
--        GetOwningPlayer(unit).units.append(unit)
--        return handle
--    end
--
--    local _CreateUnit = CreateUnit
--    CreateUnit = function(whichPlayer, unitId, x, y, face)
--        local handle = _CreateUnit(whichPlayer, unitId, x, y, face)
--        local unit = _Unit.new(handle)
--        GetOwningPlayer(unit).units.append(unit)
--        return handle
--    end
--
--    local _CreateUnitByName = CreateUnitByName
--    CreateUnitByName = function(whichPlayer, unitName, x, y, face)
--        local handle = _CreateUnitByName(whichPlayer, unitName, x, y, face)
--        local unit = _Unit.new(handle)
--        GetOwningPlayer(unit).units.append(unit)
--        return handle
--    end
--
--    local _CreateUnitAtLoc = CreateUnitAtLoc
--    CreateUnitAtLoc = function(whichPlayer, unitId, whichLocation, face)
--        local handle = _CreateUnitAtLoc(whichPlayer, unitId, whichLocation, face)
--        local unit = _Unit.new(handle)
--        GetOwningPlayer(unit).units.append(unit)
--        return handle
--    end
--
--    local _CreateUnitAtLocByName = CreateUnitAtLocByName
--    CreateUnitAtLocByName = function(whichPlayer, unitName, whichLocation, face)
--        local handle = _CreateUnitAtLocByName(whichPlayer, unitName, whichLocation, face)
--        local unit = _Unit.new(handle)
--        GetOwningPlayer(unit).units.append(unit)
--        return handle
--    end
--
--    local _CreateCorpse = CreateCorpse
--    CreateCorpse = function(whichPlayer, unitId, x, y, face)
--        local handle = _CreateCorpse(whichPlayer, unitId, x, y, face)
--        local unit = _Unit.new(handle)
--        GetOwningPlayer(unit).units.append(unit)
--        return handle
--    end
--
--    local _PlaceRandomItem = PlaceRandomItem
--    PlaceRandomItem = function(whichItemPool, x, y)
--        local handle = _PlaceRandomItem(whichItemPool, x, y)
--        local item = _Item.new(handle)
--        return handle
--    end
--
--    local _UnitAddItemById = UnitAddItemById
--    UnitAddItemById = function(whichUnit, itemId)
--        local handle = _UnitAddItemById(whichUnit, itemId)
--        local item = _Item.new(handle)
--        return handle
--    end
--
--    local _CreateItem = CreateItem
--    CreateItem = function(itemId, x, y)
--        local handle = _CreateItem(itemId, x, y)
--        local item = _Item.new(handle)
--        return handle
--    end
--
--    local _RemoveUnit = RemoveUnit
--    RemoveUnit = function(unit)
--        local unit = Indexer.find(unit)
--        unit.remove()
--    end

    -- local _KillUnit = KillUnit
    -- KillUnit = function(unit)
    --     local unit = Indexer.find(unit)
    --     unit.kill()
    -- end

    -- Internal Player Handling
    local Player = function(playerId)
        return self.Player[playerId]
    end

    Configuration = _Configuration.new()

    -- Interface [Object API]
    local IEngine = {}
    IEngine.Trigger = Trigger.new
    IEngine.EventDispatcher = EventDispatcher.new
    IEngine.Effect = Effect.new
    IEngine.Player = Player
    IEngine.Easing = Easing
    IEngine.Window = Window
    IEngine.Clock = Clock.new
    IEngine.SoundLoader = SoundLoader
    IEngine.Unit = Unit.new
    IEngine.Log = Log
    IEngine.Configuration = Configuration
    IEngine.Group = Group.new
    -- IEngine.Item = Item.new

    -- Interface [Unit API]
    IEngine.GetTriggerUnit = GetTriggerUnit
    IEngine.GetAttacker = GetAttacker
    IEngine.GetFilterUnit = GetFilterUnit
    IEngine.GetSpellTargetUnit = GetSpellTargetUnit
    -- IEngine.GetManipulatedItem = GetManipulatedItem
    -- IEngine.GetFilterItem = GetFilterItem
    IEngine.GetTriggerPlayer = GetTriggerPlayer
    -- IEngine.GetItemPlayer = GetItemPlayer
    IEngine.GetEventDamageSource = GetEventDamageSource
    IEngine.GetEventDamageTarget = GetEventDamageTarget
    IEngine.GetOwningPlayer = GetOwningPlayer
    IEngine.FirstOfGroup = FirstOfGroup
    IEngine.GetEnumUnit = GetEnumUnit
    IEngine.GetEnteringUnit = GetEnteringUnit
    IEngine.GetLeavingUnit = GetLeavingUnit
    IEngine.GetLevelingUnit = GetLevelingUnit
    IEngine.GetLearningUnit = GetLearningUnit
    IEngine.GetRevivableUnit = GetRevivableUnit
    IEngine.GetRevivingUnit = GetRevivingUnit
    IEngine.GetRescuer = GetRescuer
    IEngine.GetDyingUnit = GetDyingUnit
    IEngine.GetKillingUnit = GetKillingUnit
    IEngine.GetDecayingUnit = GetDecayingUnit
    IEngine.GetSelectedUnit = GetSelectedUnit
    IEngine.GetConstructingStructure = GetConstructingStructure
    IEngine.GetCancelledStructure = GetCancelledStructure
    IEngine.GetConstructedStructure = GetConstructedStructure
    IEngine.GetResearchingUnit = GetResearchingUnit
    IEngine.GetTrainedUnit = GetTrainedUnit
    IEngine.GetDetectedUnit = GetDetectedUnit
    IEngine.GetSummoningUnit = GetSummoningUnit
    IEngine.GetSummonedUnit = GetSummonedUnit
    IEngine.GetTransportUnit = GetTransportUnit
    IEngine.GetLoadedUnit = GetLoadedUnit
    IEngine.GetSellingUnit = GetSellingUnit
    IEngine.GetSoldUnit = GetSoldUnit
    IEngine.GetBuyingUnit = GetBuyingUnit
    IEngine.GetChangingUnit = GetChangingUnit
    IEngine.GetManipulatingUnit = GetManipulatingUnit
    IEngine.GetOrderedUnit = GetOrderedUnit
    IEngine.GetOrderTargetUnit = GetOrderTargetUnit
    IEngine.GetSpellAbilityUnit = GetSpellAbilityUnit
    IEngine.GetEventTargetUnit = GetEventTargetUnit
    IEngine.BlzGroupUnitAt = BlzGroupUnitAt

    return IEngine

end

MetaData = {}
MetaData.new = function()
    local self = {}

    self.name = ""
    self.description = ""
    self.icon = ""

    return self

end

EventHolder = {}
EventHolder.new = function(IEngine)
    local self = {}
    local mt = {}
    
    local clock = IEngine.Clock()
    local events = {}
    local schedules = {}
    local cleanups = {}

    function mt.__newindex(_table, index, value)
        if index == "event" then
            table.insert(events, value)
        elseif index == "schedule" then
            table.insert(schedules, value)
        elseif index == "cleanup" then
            table.insert(cleanups, value)
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    function mt.__index(table, index)
        if index == "clock" then
            return clock
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    function self.unbindAll()
        for _, event in ipairs(events) do
            clock.unschedule(event)
        end
        events = nil

        for _, schedule in ipairs(schedules) do
            clock.unschedule(schedule)
        end
        schedules = nil

        for _, cleanup in ipairs(cleanups) do
            cleanup()
        end
        cleanups = nil

        clock.stop()
        self = nil
    end

    clock.start()

    setmetatable(self, mt)

    return self

end

_Abilities = {}

_Abilities.Sword_Slash = {}
_Abilities.Sword_Slash.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()

    local bloodEffect = IEngine.Effect()
    bloodEffect.scale = 0.3
    bloodEffect.model = "Effects\\Blood Effect.mdx"

    local bladeEffects = {}
    bladeEffects[0] = "Effects\\Ephemeral Slash Red.mdx"
    bladeEffects[1] = "Effects\\Ephemeral Slash Midnight.mdx"
    bladeEffects[2] = "Effects\\Ephemeral Slash Teal.mdx"
    bladeEffects[3] = "Effects\\Ephemeral Slash Purple.mdx"
    bladeEffects[4] = "Effects\\Ephemeral Slash Yellow.mdx"
    bladeEffects[5] = "Effects\\Ephemeral Slash Orange.mdx"
    bladeEffects[6] = "Effects\\Ephemeral Slash Jade.mdx"
    bladeEffects[7] = "Effects\\Ephemeral Slash Pink.mdx"
    
    local cutEffects = {}
    cutEffects[0] = "Effects\\Ephemeral Cut Red.mdx"
    cutEffects[1] = "Effects\\Ephemeral Cut Midnight.mdx"
    cutEffects[2] = "Effects\\Ephemeral Cut Teal.mdx"
    cutEffects[3] = "Effects\\Ephemeral Cut Purple.mdx"
    cutEffects[4] = "Effects\\Ephemeral Cut Yellow.mdx"
    cutEffects[5] = "Effects\\Ephemeral Cut Orange.mdx"
    cutEffects[6] = "Effects\\Ephemeral Cut Jade.mdx"
    cutEffects[7] = "Effects\\Ephemeral Cut Pink.mdx"

    local bladeEffect = {}
    local cutEffect = {}
    for i = 0, 7 do
        bladeEffect[i] = IEngine.Effect()
        bladeEffect[i].scale = 1.0
        bladeEffect[i].model = bladeEffects[i]

        cutEffect[i] = IEngine.Effect()
        cutEffect[i].scale = 1.5
        cutEffect[i].model = cutEffects[i]
    end

    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            eventHolder.event = unit.bind("on_damage_after",
                function(source, target, attack)
                    local rad = source.face * bj_DEGTORAD
                    local x = source.x + 75. * math.cos(rad)
                    local y = source.y + 75. * math.sin(rad)
                    bladeEffect[source.owner.id].x = x
                    bladeEffect[source.owner.id].y = y
                    bladeEffect[source.owner.id].height = math.random(30., 100.)
                    bladeEffect[source.owner.id].timeScale = math.random(0.8, 1.3)
                    bladeEffect[source.owner.id].yaw = rad
                    bladeEffect[source.owner.id].roll = math.random(0.7854, 2.3562)
                    bladeEffect[source.owner.id].create().destroy()

                    local rad = math.random(0, math.pi * 2)
                    local x = target.x + math.random(0., 75.) * math.cos(rad)
                    local y = target.y + math.random(0., 75.) * math.sin(rad)
                    local height = math.random(30., 100.)
                    local timeScale = math.random(0.8, 1.3)
                    local roll = math.random(0.7854, 2.3562)
                    cutEffect[source.owner.id].x = x
                    cutEffect[source.owner.id].y = y
                    cutEffect[source.owner.id].height = height
                    cutEffect[source.owner.id].timeScale = timeScale
                    cutEffect[source.owner.id].yaw = rad
                    cutEffect[source.owner.id].roll = roll
                    cutEffect[source.owner.id].create().destroy()

                    bloodEffect.x = x
                    bloodEffect.y = y
                    bloodEffect.height = height
                    bloodEffect.timeScale = timeScale
                    bloodEffect.yaw = rad
                    bloodEffect.roll = roll
                    bloodEffect.create().destroy()

                end
            ).setCondition(
                function(source, target, attack)
                    return attack.isAttack and source == unit
                end
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    return self
end

_Abilities.Dodge = {}
_Abilities.Dodge.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()

    local effect = IEngine.Effect()
    effect.model = "Effects\\Dash.mdx"
    effect.scale = 0.3

    -- local aoeEffect = IEngine.Effect()
    -- aoeEffect.model = "Effects\\Stomp_Effect.mdx"

    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            eventHolder.event = unit.bind("on_spell_effect",
                function(source, spell)
                    --local withBlink = true
                    --local withAoE = true

                    local x = source.x
                    local y = source.y
                    local x2 = source.owner.mouse.x
                    local y2 = source.owner.mouse.y
                    local dx = x2 - x
                    local dy = y2 - y
                    local distance = math.sqrt(dx * dx + dy * dy)
                    local a = math.atan(y2 - y, x2 - x)
                    local distanceMax = 400 + source.ms
                    local distanceMin = source.ms / 2
                    local maximumDashDuration = 0.25
                    local interval = 0.005
                    local speed = distanceMax * (interval / maximumDashDuration)
                    if distance > distanceMax then
                        distance = distanceMax
                    elseif distance < distanceMin then
                        distance = distanceMin
                    end
                    local dashDuration = (distance / speed) * interval
                    local traveledDistance = 0
                    source.faceInstant(bj_RADTODEG * (a))
                    effect.x = unit.x
                    effect.y = unit.y
                    effect.z = unit.z
                    effect.yaw = a
                    effect.create().destroy()
                    local dashEffect = IEngine.Effect()
                    dashEffect.model = "Effects\\Windwalk Blue Soul.mdx"
                    source.attachEffect(dashEffect, "origin")
                    -- INT Scaling Blink Effect
                    --if withBlink then
                    source.fadeOut(dashDuration / 4)
                    eventHolder.clock.schedule_once(
                        function(triggeringClock, triggeringSchedule)
                            source.fadeIn(dashDuration)
                        end, dashDuration / 4
                    )
                    eventHolder.clock.schedule_interval(
                        function(triggeringClock, triggeringSchedule)
                            local tempUnit = source.owner.createUnit('hpea', unit.x, unit.y, bj_RADTODEG * a)
                            tempUnit.skin = source.skin
                            tempUnit.addAbility('Aloc')
                            tempUnit.setVertexColor(55, 55, 55, 65)
                            tempUnit.x = unit.x
                            tempUnit.y = unit.y
                            tempUnit.playAnimation('walk')
                            triggeringClock.schedule_once(
                                function(triggeringClock, triggeringSchedule)
                                    tempUnit.remove()
                                end, 0.2
                            )
                            traveledDistance = traveledDistance + speed
                            if traveledDistance >= distance * 0.25 and traveledDistance < distance * 0.5 then
                                traveledDistance = distance * 0.75
                                unit.teleportTo(unit.x + (distance * 0.5) * math.cos(a), unit.y + (distance * 0.5) * math.sin(a))
                            else
                                unit.x = unit.x + speed * math.cos(a)
                                unit.y = unit.y + speed * math.sin(a)
                            end
                            -- -0.5 because of error range
                            if traveledDistance >= distance - 0.5 then
                                -- STR Scaling AoE Effect
                                -- if withAoE then
                                --     aoeEffect.x = unit.x
                                --     aoeEffect.y = unit.y
                                --     aoeEffect.z = unit.z
                                --     aoeEffect.create().destroy()
                                -- end
                                dashEffect.destroy()
                                triggeringClock.unschedule(triggeringSchedule)
                            end
                        end, interval
                    )
                    --else
                    --    source.fadeOut(dashDuration / 2)
                    --    eventHolder.clock.schedule_once(
                    --        function(triggeringClock, triggeringSchedule)
                    --            source.fadeIn(dashDuration)
                    --        end, dashDuration / 2
                    --    )     
                    --    eventHolder.clock.schedule_interval(
                    --        function(triggeringClock, triggeringSchedule)
                    --            local tempUnit = source.owner.createUnit('hpea', unit.x, unit.y, bj_RADTODEG * a)
                    --            tempUnit.skin = source.skin
                    --            tempUnit.addAbility('Aloc')
                    --            tempUnit.setVertexColor(55, 55, 55, 65)
                    --            tempUnit.x = unit.x
                    --            tempUnit.y = unit.y
                    --            tempUnit.playAnimation('walk')
                    --            triggeringClock.schedule_once(
                    --                function(triggeringClock, triggeringSchedule)
                    --                    tempUnit.remove()
                    --                end, 0.2
                    --            )
                    --            unit.x = unit.x + speed * math.cos(a)
                    --            unit.y = unit.y + speed * math.sin(a)
                    --            traveledDistance = traveledDistance + speed
                    --            -- -0.5 because of error range
                    --            if traveledDistance >= distance - 0.5 then
                    --                -- STR Scaling AoE Effect
                    --                if withAoE then
                    --                    aoeEffect.x = unit.x
                    --                    aoeEffect.y = unit.y
                    --                    aoeEffect.z = unit.z
                    --                    aoeEffect.create().destroy()
                    --                end
                    --                dashEffect.destroy()
                    --                triggeringClock.unschedule(triggeringSchedule)
                    --            end
                    --        end, interval
                    --    )
                    --end
                end
            ).setCondition(
                function(source, spell)
                    return spell.id == FourCC('AEVA') and source == unit
                end
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    return self
end

_Abilities.Blade_Dance = {}
_Abilities.Blade_Dance.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Blade Dance"
    metadata.description = "Path:|cffe182f9N|r|cffdb7af3i|r|cffd573eeh|r|cffcf6be9i|r|cffc963e4l|r|cffc35cdfi|r|cffbd54dat|r|cffb74dd5y|r"
    .. "|nBlades rotate around you, dealing a total of 350% damage per second."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNNihility.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local bladeEffect = IEngine.Effect()
    bladeEffect.model = "Effects\\Ephemeral Slash Purple.mdx"
    local bloodEffect = IEngine.Effect()
    bloodEffect.model = "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl"
    bloodEffect.scale = 1.2
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local dps = 3.5
            local tickrate = 0.05
            local damagePerTick = dps * tickrate
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    bladeEffect.x = unit.x
                    bladeEffect.y = unit.y
                    bladeEffect.height = math.random(30., 100.)
                    bladeEffect.timeScale = math.random(0.8, 1.3)
                    bladeEffect.yaw = math.random(0., math.pi * 2)
                    bladeEffect.create().destroy()
                    
                    group
                        .inRange(unit.x, unit.y, 150.)
                        .forEach(
                            function(group, enumUnit)
                                if enumUnit.hp <= 1 or enumUnit.invulnerable then
                                    return
                                end
                                if unit.isEnemy(enumUnit) then
                                    bloodEffect.x = enumUnit.x
                                    bloodEffect.y = enumUnit.y
                                    bloodEffect.create().destroy()
                                    unit.damageTarget(enumUnit, unit.damage * damagePerTick, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE) 
                                end
                            end
                        )
                end, tickrate
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Blink_Strike = {}
_Abilities.Blink_Strike.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Blink Strike"
    metadata.description = "Path:|cffe182f9N|r|cffdb7af3i|r|cffd573eeh|r|cffcf6be9i|r|cffc963e4l|r|cffc35cdfi|r|cffbd54dat|r|cffb74dd5y|r"
    .. "|nEach attack you blink to a random nearby enemy and deal 450% damage."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNNihility.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local casterEffect = IEngine.Effect()
    casterEffect.scale = 0.8
    casterEffect.model = "Effects\\Blink Red Caster.mdx"
    local targetEffect = IEngine.Effect()
    targetEffect.scale = 0.8
    targetEffect.model = "Effects\\Blink Red Target.mdx"

    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            eventHolder.event = unit.bind("on_damage_after",
                function(source, target, attack)
                    local x = source.x
                    local y = source.y
                    local target = group
                        .inRangeFiltered(x, y, 1200.,
                            function(group, filterUnit)
                                if filterUnit.hp <= 1 or filterUnit.invulnerable then
                                    return false
                                end
                                if not unit.isEnemy(filterUnit) then
                                    return false
                                end
                                return true
                            end
                        ).getRandom()
                    if target == nil then
                        return
                    end

                    local x2 = target.x
                    local y2 = target.y
                    local a = math.random(0, math.pi * 2)
                    local dist = 50
                    local x4 = x2 + dist * math.cos(a)
                    local y4 = y2 + dist * math.sin(a)
                    casterEffect.x = x
                    casterEffect.y = y
                    casterEffect.create().destroy()

                    source.x = x4
                    source.y = y4
                    source.faceInstant(bj_RADTODEG * (a + math.pi))
                    targetEffect.x = x4
                    targetEffect.y = y4
                    targetEffect.create().destroy()

                    source.issueOrder("attack", target)
                    source.damageTarget(target, source.damage * 4.5, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE)
                end
            ).setCondition(
                function(source, target, attack)
                    return attack.isAttack
                end
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Demon_Control = {}
_Abilities.Demon_Control.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Demon Control"
    metadata.description = "Path:|cffe182f9N|r|cffdb7af3i|r|cffd573eeh|r|cffcf6be9i|r|cffc963e4l|r|cffc35cdfi|r|cffbd54dat|r|cffb74dd5y|r"
    .. "|nA Demon follows you, healing you by 30% of your max hp every 40 attacks."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNNihility.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local roarEffect = IEngine.Effect()
    roarEffect.model = "Abilities\\Spells\\Undead\\UnholyFrenzyAOE\\UnholyFrenzyAOETarget.mdl"
    roarEffect.scale = 2.0
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local demonEffect = IEngine.Effect()
            demonEffect.model = "Models\\Manifestation Pride.mdx"
            demonEffect.scale = 2.0
            demonEffect.create()
            -- Destroy later on with some 'on unschedule event'
            do
                eventHolder.schedule = eventHolder.clock.schedule_interval(
                    function(triggeringClock, triggeringSchedule)
                        local cx = demonEffect.x
                        local cy = demonEffect.y
                        local cz = demonEffect.z
                        local a = unit.face + 180.
                        local tx = unit.x + 95. * math.cos(bj_DEGTORAD * a)
                        local ty = unit.y + 95. * math.sin(bj_DEGTORAD * a)
                        local tz = unit.z + 50.
                        local dx = tx - cx
                        local dy = ty - cy
                        local dist = math.sqrt(dx * dx + dy * dy)
                        if dist > 1. then
                            local increment = 1. + 1.2 * dist / 70
                            local rad = math.atan(ty - cy, tx - cx)
                            demonEffect.x = cx + increment * math.cos(rad)
                            demonEffect.y = cy + increment * math.sin(rad)
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
                        demonEffect.yaw = math.atan(unit.y - cy, unit.x - cx)
                    end, 0.005
                )
            end

            do
                local attackCount = 0
                local casting = false
                eventHolder.event = unit.bind("on_damage_after",
                    function(source, target, attack)
                        attackCount = attackCount + 1
                        if attackCount >= 40 and not casting then
                            attackCount = 0
                            casting = true
                            roarEffect.x = demonEffect.x
                            roarEffect.y = demonEffect.y
                            roarEffect.z = demonEffect.z
                            roarEffect.create().destroy()
                            demonEffect.addSubAnim(SUBANIM_TYPE_SLAM).play(ANIM_TYPE_SPELL).removeSubAnim(SUBANIM_TYPE_SLAM)
                            unit.hp = unit.hp + 0.3 * unit.maxhp
                            eventHolder.clock.schedule_once(
                                function()
                                    casting = false
                                    demonEffect.play(ANIM_TYPE_STAND)
                                end, 1.1
                            )
                        end
                    end
                ).setCondition(
                    function(source, target, attack)
                        return attack.isAttack and source == unit
                    end
                )
            end

            eventHolder.cleanup = function()
                demonEffect.destroy()
            end
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Shadow_Strike = {}
_Abilities.Shadow_Strike.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Shadow Strike"
    metadata.description = "Path:|cffe182f9N|r|cffdb7af3i|r|cffd573eeh|r|cffcf6be9i|r|cffc963e4l|r|cffc35cdfi|r|cffbd54dat|r|cffb74dd5y|r"
    .. "|nEach attack spawns a illusion, with a duration of 5 seconds, that copies your damage, attack speed and blink strike."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNNihilityPath.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local disappearEffect = IEngine.Effect()
    disappearEffect.scale = 0.7
    disappearEffect.model = "Effects\\Soul Discharge Purple.mdx"
    local slashEffect = IEngine.Effect()
    slashEffect.scale = 2.0
    slashEffect.model = "Effects\\Ephemeral Cut Midnight.mdx"

    function self.apply(unit, Ability)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)
        
        do
            eventHolder.event = unit.bind("on_damage_after",
                function(source, target, attack)
                    local x = source.x
                    local y = source.y
                    local target = group
                        .inRangeFiltered(x, y, 1200.,
                            function(group, filterUnit)
                                if unit.isEnemy(filterUnit) and filterUnit.hp > 0 then
                                    return true
                                end
                                return false
                            end
                        ).getRandom()
                    if target == nil then
                        return
                    end
                    
                    local x2 = target.x
                    local y2 = target.y
                    local a = math.random(0., math.pi * 2)
                    local x3 = x2 + 50 * math.cos(a)
                    local y3 = y2 + 50 * math.sin(a)
                    a = a + math.pi

                    local tempUnit = source.owner.createUnit('unit', x3, y3, bj_RADTODEG * a)
                    tempUnit.skin = source.skin
                    tempUnit.addAbility('Aloc')
                    tempUnit.setVertexColor(55, 55, 55, 255)
                    tempUnit.invulnerable = true

                    tempUnit.damage = source.damage
                    tempUnit.attackspeed = source.attackspeed
                    Ability.Blink_Strike.apply(tempUnit)

                    eventHolder.clock.schedule_once(
                        function(triggeringClock, triggeringSchedule)
                            disappearEffect.x = tempUnit.x
                            disappearEffect.y = tempUnit.y
                            disappearEffect.create().destroy()
                            Ability.Blink_Strike.remove(tempUnit)
                            tempUnit.remove()
                        end, 5.0
                    )

                    tempUnit.issueOrder("attack", target)
                end
            ).setCondition(
                function(source, target, attack)
                    return attack.isAttack and source == unit
                end
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

-- _Abilities.Wolf = {}
-- _Abilities.Wolf.new = function(IEngine)
--     local self = {}
--     local _eventHolder = {}
--     local group = IEngine.Group()

--     local bloodEffect = IEngine.Effect()
--     bloodEffect.model = "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl"
--     bloodEffect.scale = 1.2
    
--     function self.apply(unit)
--         if _eventHolder[unit] ~= nil then
--             return
--         end
--         local eventHolder = EventHolder.new(IEngine)

--         do
--             local summonUnit
--             do
--                 local distance = math.random(0, 400)
--                 local rad = math.random(0., math.pi * 2)
--                 local x = unit.x + distance * math.cos(rad)
--                 local y = unit.y + distance * math.sin(rad)
--                 summonUnit = unit.owner.createUnit('unit', x, y, bj_RADTODEG * rad)
--                 summonUnit.skin = 'h00I'
--                 summonUnit.addAbility('Aloc')
--                 summonUnit.invulnerable = true
--                 summonUnit.attackspeed = unit.attackspeed * 3.0
--                 summonUnit.bind("on_attack",
--                     function(source, target)
--                         local rad = math.atan(target.y - source.y, target.x - source.x)
--                         bloodEffect.x = source.x + 140. * math.cos(rad)
--                         bloodEffect.y = source.y + 140. * math.sin(rad)
--                         bloodEffect.yaw = rad
--                         bloodEffect.create().destroy()
--                     end
--                 )
--                 summonUnit.bind("on_damage_pre",
--                     function(source, target, attack)
--                         BlzSetEventDamage(0)
--                         unit.damageTarget(target, unit.damage * 300.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE)
--                     end
--                 )
--                 --summonUnit.setWeaponIntegerField(UNIT_WEAPON_IF_ATTACK_TARGETS_ALLOWED, 0, 4)
--             end

--             local tx = nil
--             local ty = nil
--             local level = 0
--             eventHolder.schedule = eventHolder.clock.schedule_interval(
--                 function(triggeringClock, triggeringSchedule)
--                     if tx == nil or ty == nil then
--                         tx = summonUnit.x
--                         ty = summonUnit.y
--                     end
--                     local cx = summonUnit.x
--                     local cy = summonUnit.y
--                     local a = unit.face + 180.
--                     local ux = unit.x
--                     local uy = unit.y
--                     local dx = tx - ux
--                     local dy = ty - uy
--                     local dist = math.sqrt(dx * dx + dy * dy)
--                     if dist > 800. then
--                         local otherDist = math.random(400, 600)
--                         local rad = math.random(0., math.pi * 2)
--                         tx = ux + otherDist * math.cos(rad)
--                         ty = uy + otherDist * math.sin(rad)
--                         summonUnit.issueOrder("move", tx, ty)
--                     else
--                         local dx = tx - cx
--                         local dy = ty - cy
--                         local dist = math.sqrt(dx * dx + dy * dy)
--                         if dist > 1. then
--                             local rad = math.atan(dy, dx)
--                             local increment = 200 + 200 * 0.03 * dist / 70
--                             if increment > 500 then
--                                 increment = 500
--                                 summonUnit.teleportTo(tx, ty)
--                             end
--                             summonUnit.ms = increment
--                         elseif GetRandomInt(0, 1000) == 1 then
--                             local otherDist = math.random(400, 700)
--                             local rad = math.random(0., math.pi * 2)
--                             tx = ux + otherDist * math.cos(rad)
--                             ty = uy + otherDist * math.sin(rad)
--                             summonUnit.issueOrder("move", tx, ty)
--                         end
--                     end
--                 end, 0.005
--             )
            
--             eventHolder.event = unit.bind("on_damage_after",
--                 function(source, target, attack)
--                     summonUnit.issueOrder("attack", target)
--                 end
--             ).setCondition(
--                 function(source, target, attack)
--                     return attack.isAttack and summonUnit ~= nil and source == unit
--                 end
--             )

--             eventHolder.cleanup = function()
--                 summonUnit.remove()
--             end
--         end

--         _eventHolder[unit] = eventHolder
--     end

--     function self.remove(unit)
--         if _eventHolder[unit] == nil then
--             return
--         end
--         _eventHolder[unit].unbindAll()
--         _eventHolder[unit] = nil
--     end

--     return self
-- end

-- _Abilities.Bear = {}
-- _Abilities.Bear.new = function(IEngine)
--     local self = {}
--     local _eventHolder = {}
--     local group = IEngine.Group()

--     local bloodEffect = IEngine.Effect()
--     bloodEffect.model = "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl"
--     bloodEffect.scale = 1.2
    
--     function self.apply(unit)
--         if _eventHolder[unit] ~= nil then
--             return
--         end
--         local eventHolder = EventHolder.new(IEngine)

--         do
--             local summonUnit 
--             do
--                 local distance = math.random(0, 400)
--                 local rad = math.random(0., math.pi * 2)
--                 local x = unit.x + distance * math.cos(rad)
--                 local y = unit.y + distance * math.sin(rad)
--                 summonUnit = unit.owner.createUnit('unit', x, y, bj_RADTODEG * rad)
--                 summonUnit.skin = 'h00H'
--                 summonUnit.addAbility('Aloc')
--                 summonUnit.invulnerable = true
--                 summonUnit.attackspeed = unit.attackspeed * 1.0
--                 summonUnit.bind("on_attack",
--                     function(source, target)
--                         local rad = math.atan(target.y - source.y, target.x - source.x)
--                         bloodEffect.x = source.x + 140. * math.cos(rad)
--                         bloodEffect.y = source.y + 140. * math.sin(rad)
--                         bloodEffect.yaw = rad
--                         bloodEffect.create().destroy()
--                     end
--                 )
--                 summonUnit.bind("on_damage_pre",
--                     function(source, target, attack)
--                         BlzSetEventDamage(0)
--                         unit.damageTarget(target, unit.damage * 1000.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE)
--                     end
--                 )
--                 --summonUnit.setWeaponIntegerField(UNIT_WEAPON_IF_ATTACK_TARGETS_ALLOWED, 0, 4)
--             end
            
--             local tx = nil
--             local ty = nil
--             local level = 0
--             eventHolder.schedule = eventHolder.clock.schedule_interval(
--                 function(triggeringClock, triggeringSchedule)
--                     if tx == nil or ty == nil then
--                         tx = summonUnit.x
--                         ty = summonUnit.y
--                     end
--                     local cx = summonUnit.x
--                     local cy = summonUnit.y
--                     local a = unit.face + 180.
--                     local ux = unit.x
--                     local uy = unit.y
--                     local dx = tx - ux
--                     local dy = ty - uy
--                     local dist = math.sqrt(dx * dx + dy * dy)
--                     if dist > 800. then
--                         local otherDist = math.random(400, 600)
--                         local rad = math.random(0., math.pi * 2)
--                         tx = ux + otherDist * math.cos(rad)
--                         ty = uy + otherDist * math.sin(rad)
--                         summonUnit.issueOrder("move", tx, ty)
--                     else
--                         local dx = tx - cx
--                         local dy = ty - cy
--                         local dist = math.sqrt(dx * dx + dy * dy)
--                         if dist > 1. then
--                             local rad = math.atan(dy, dx)
--                             local increment = 200 + 200 * 0.03 * dist / 70
--                             if increment > 500 then
--                                 increment = 500
--                                 summonUnit.teleportTo(tx, ty)
--                             end
--                             summonUnit.ms = increment
--                         elseif GetRandomInt(0, 1000) == 1 then
--                             local otherDist = math.random(400, 700)
--                             local rad = math.random(0., math.pi * 2)
--                             tx = ux + otherDist * math.cos(rad)
--                             ty = uy + otherDist * math.sin(rad)
--                             summonUnit.issueOrder("move", tx, ty)
--                         end
--                     end
--                 end, 0.005
--             )

--             eventHolder.event = unit.bind("on_damage_after",
--                 function(source, target, attack)
--                     summonUnit.issueOrder("attack", target)
--                 end
--             ).setCondition(
--                 function(source, target, attack)
--                     return attack.isAttack and summonUnit ~= nil and source == unit
--                 end
--             )

--             eventHolder.cleanup = function()
--                 summonUnit.remove()
--             end
--         end

--         _eventHolder[unit] = eventHolder
--     end

--     function self.remove(unit)
--         if _eventHolder[unit] == nil then
--             return
--         end
--         _eventHolder[unit].unbindAll()
--         _eventHolder[unit] = nil
--     end

--     return self
-- end

-- _Abilities.Boar = {}
-- _Abilities.Boar.new = function(IEngine)
--     local self = {}
--     local _eventHolder = {}
--     local group = IEngine.Group()
    
--     function self.apply(unit)
--         if _eventHolder[unit] ~= nil then
--             return
--         end
--         local eventHolder = EventHolder.new(IEngine)

--         do
--             local summonUnit
--             do
--                 local distance = math.random(0, 400)
--                 local rad = math.random(0., math.pi * 2)
--                 local x = unit.x + distance * math.cos(rad)
--                 local y = unit.y + distance * math.sin(rad)
--                 summonUnit = unit.owner.createUnit('unit', x, y, bj_RADTODEG * rad)
--                 summonUnit.skin = 'h00J'
--                 summonUnit.addAbility('Aloc')
--                 summonUnit.invulnerable = true
--                 summonUnit.attackspeed = unit.attackspeed * 1.5
--                 summonUnit.bind("on_damage_pre",
--                     function(source, target, attack)
--                         BlzSetEventDamage(0)
--                         unit.damageTarget(target, unit.damage * 100.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE)
--                     end
--                 )
--                 --summonUnit.setWeaponIntegerField(UNIT_WEAPON_IF_ATTACK_TARGETS_ALLOWED, 0, 4)
--             end
            
--             local tx = nil
--             local ty = nil
--             eventHolder.schedule = eventHolder.clock.schedule_interval(
--                 function(triggeringClock, triggeringSchedule)
--                     if tx == nil or ty == nil then
--                         tx = summonUnit.x
--                         ty = summonUnit.y
--                     end
--                     local cx = summonUnit.x
--                     local cy = summonUnit.y
--                     local a = unit.face + 180.
--                     local ux = unit.x
--                     local uy = unit.y
--                     local dx = tx - ux
--                     local dy = ty - uy
--                     local dist = math.sqrt(dx * dx + dy * dy)
--                     if dist > 800. then
--                         local otherDist = math.random(400, 600)
--                         local rad = math.random(0., math.pi * 2)
--                         tx = ux + otherDist * math.cos(rad)
--                         ty = uy + otherDist * math.sin(rad)
--                         summonUnit.issueOrder("move", tx, ty)
--                     else
--                         local dx = tx - cx
--                         local dy = ty - cy
--                         local dist = math.sqrt(dx * dx + dy * dy)
--                         if dist > 1. then
--                             local rad = math.atan(dy, dx)
--                             local increment = 200 + 200 * 0.03 * dist / 70
--                             if increment > 500 then
--                                 increment = 500
--                                 summonUnit.teleportTo(tx, ty)
--                             end
--                             summonUnit.ms = increment
--                         elseif GetRandomInt(0, 1000) == 1 then
--                             local otherDist = math.random(400, 700)
--                             local rad = math.random(0., math.pi * 2)
--                             tx = ux + otherDist * math.cos(rad)
--                             ty = uy + otherDist * math.sin(rad)
--                             summonUnit.issueOrder("move", tx, ty)
--                         end
--                     end
--                 end, 0.005
--             )

--             eventHolder.event = unit.bind("on_damage_after",
--                 function(source, target, attack)
--                     summonUnit.issueOrder("attack", target)
--                 end
--             ).setCondition(
--                 function(source, target, attack)
--                     return attack.isAttack and summonUnit ~= nil and source == unit
--                 end
--             )

--             eventHolder.cleanup = function()
--                 summonUnit.remove()
--             end
--         end

--         _eventHolder[unit] = eventHolder
--     end

--     function self.remove(unit)
--         if _eventHolder[unit] == nil then
--             return
--         end
--         _eventHolder[unit].unbindAll()
--         _eventHolder[unit] = nil
--     end

--     return self
-- end

_Abilities.Reapers = {}
_Abilities.Reapers.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            -- Reaper 1
            do
                -- Prepare Slash Effect
                local slashEffect = IEngine.Effect()
                slashEffect.scale = 2.0
                slashEffect.model = "Effects\\Coup de Grace Purple.mdx"

                -- Prepare Aura
                local auraEffect = IEngine.Effect()
                auraEffect.model = "Auras\\Malevolence Aura Purple.mdx"
                auraEffect.scale = 1.5

                -- Prepare Summon
                local summonUnit
                do
                    local distance = math.random(0, 400)
                    local rad = math.random(0., math.pi * 2)
                    local x = unit.x + distance * math.cos(rad)
                    local y = unit.y + distance * math.sin(rad)
                    summonUnit = unit.owner.createUnit('h001', x, y, bj_RADTODEG * rad)
                    summonUnit.skin = 'h00E'
                    summonUnit.addAbility('Aloc')
                    
                    summonUnit.bind("on_attack",
                        function(source, target)
                            local rad = math.atan(target.y - source.y, target.x - source.x)
                            slashEffect.x = source.x + 50. * math.cos(rad)
                            slashEffect.y = source.y + 50. * math.sin(rad)
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

                    -- Create Aura
                    auraEffect.create()
                end

                local tx = nil
                local ty = nil
                eventHolder.schedule = eventHolder.clock.schedule_interval(
                    function(triggeringClock, triggeringSchedule)
                        -- Move Aura
                        auraEffect.x = summonUnit.x
                        auraEffect.y = summonUnit.y
                        auraEffect.z = summonUnit.z

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
                        local dist = math.sqrt(dx * dx + dy * dy)
                        
                        if dist > 800. then
                            local otherDist = math.random(400, 600)
                            local rad = math.random(0., math.pi * 2)
                            tx = ux + otherDist * math.cos(rad)
                            ty = uy + otherDist * math.sin(rad)
                            summonUnit.issueOrder("move", tx, ty)
                        else
                            local dx = tx - cx
                            local dy = ty - cy
                            local dist = math.sqrt(dx * dx + dy * dy)
                            if dist > 1. then
                                local rad = math.atan(dy, dx)
                                local increment = 200 + 200 * 0.03 * dist / 70
                                if increment > 500 then
                                    increment = 500
                                    summonUnit.teleportTo(tx, ty)
                                end
                                summonUnit.ms = increment
                            elseif GetRandomInt(0, 1000) == 1 then
                                local otherDist = math.random(400, 700)
                                local rad = math.random(0., math.pi * 2)
                                tx = ux + otherDist * math.cos(rad)
                                ty = uy + otherDist * math.sin(rad)
                                summonUnit.issueOrder("move", tx, ty)
                            end
                        end
                    end, 0.005
                )

                eventHolder.event = unit.bind("on_damage_after",
                    function(source, target, attack)
                        summonUnit.issueOrder("attack", target)
                    end
                ).setCondition(
                    function(source, target, attack)
                        return attack.isAttack and source == unit
                    end
                )

                eventHolder.cleanup = function()
                    summonUnit.remove()
                    auraEffect.destroy()
                end
            end
            
            -- Reaper 2
            do
                -- Prepare Explode Effect
                local explodeEffect = IEngine.Effect()
                explodeEffect.model = "Effects\\Soul Discharge Red.mdx"

                -- Prepare Aura
                local auraEffect = IEngine.Effect()
                auraEffect.model = "Auras\\Malevolence Aura Red.mdx"
                auraEffect.scale = 1.5

                -- Prepare Summon
                local summonUnit
                local cooldown = 0
                do
                    local distance = math.random(0, 400)
                    local rad = math.random(0., math.pi * 2)
                    local x = unit.x + distance * math.cos(rad)
                    local y = unit.y + distance * math.sin(rad)
                    summonUnit = unit.owner.createUnit('h002', x, y, bj_RADTODEG * rad)
                    summonUnit.skin = 'h00F'
                    summonUnit.addAbility('Aloc')
                    summonUnit.bind("on_attack",
                        function(source, target)
                            BlzUnitInterruptAttack(source.handle)
                            cooldown = math.floor(9.3 / 0.005)
                            local rad = (source.face - 5.) * bj_DEGTORAD
                            local x = source.x + 295. * math.cos(rad)
                            local y = source.y + 295. * math.sin(rad)
                            source.playAnimation("Spell Eight")
                            eventHolder.clock.schedule_once(
                                function(triggeringClock, triggeringSchedule)
                                    local dist = 0
                                    triggeringClock.schedule_interval(
                                        function(triggeringClock, triggeringSchedule)
                                            dist = dist + 100
                                            for i = 0, 12 do
                                                local rad = i * 0.5236
                                                local x2 = x + dist * math.cos(rad)
                                                local y2 = y + dist * math.sin(rad)
                                                explodeEffect.x = x2
                                                explodeEffect.y = y2
                                                explodeEffect.create().destroy()
                                                group
                                                    .inRange(x2, y2, 150.)
                                                    .forEach(
                                                        function(group, enumUnit)
                                                            if unit.isEnemy(enumUnit) then
                                                                unit.damageTarget(enumUnit, unit.damage * 30., false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                                            end
                                                        end
                                                    )
                                            end
                                            if dist >= 500 then
                                                triggeringClock.unschedule(triggeringSchedule)
                                            end
                                        end, 0.05
                                    )
                                end, 2.30
                            )
                        end
                    )
                    --summonUnit.setWeaponIntegerField(UNIT_WEAPON_IF_ATTACK_TARGETS_ALLOWED, 0, 4)

                    -- Create Aura
                    auraEffect.create()
                end

                local tx = nil
                local ty = nil 
                eventHolder.schedule = eventHolder.clock.schedule_interval(
                    function(triggeringClock, triggeringSchedule)
                        -- Move Aura
                        auraEffect.x = summonUnit.x
                        auraEffect.y = summonUnit.y
                        auraEffect.z = summonUnit.z
                        
                        -- Cooldown
                        if cooldown > 0 then
                            cooldown = cooldown - 1
                        end
                        if cooldown > 0 then
                            return
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
                        local dist = math.sqrt(dx * dx + dy * dy)
                        if dist > 800. then
                            local otherDist = math.random(400, 600)
                            local rad = math.random(0., math.pi * 2)
                            tx = ux + otherDist * math.cos(rad)
                            ty = uy + otherDist * math.sin(rad)
                            summonUnit.issueOrder("move", tx, ty)
                        else
                            local dx = tx - cx
                            local dy = ty - cy
                            local dist = math.sqrt(dx * dx + dy * dy)
                            if dist > 1. then
                                local rad = math.atan(dy, dx)
                                local increment = 200 + 200 * 0.03 * dist / 70
                                if increment > 500 then
                                    increment = 500
                                    summonUnit.teleportTo(tx, ty)
                                end
                                summonUnit.ms = increment
                            elseif GetRandomInt(0, 1000) == 1 then
                                local otherDist = math.random(400, 700)
                                local rad = math.random(0., math.pi * 2)
                                tx = ux + otherDist * math.cos(rad)
                                ty = uy + otherDist * math.sin(rad)
                                summonUnit.issueOrder("move", tx, ty)
                            end
                        end
                    end, 0.005
                )

                eventHolder.event = unit.bind("on_damage_after",
                    function(source, target, attack)
                        summonUnit.issueOrder("attack", target)
                    end
                ).setCondition(
                    function(source, target, attack)
                        return attack.isAttack and cooldown <= 0. and source == unit
                    end
                )

                eventHolder.cleanup = function()
                    summonUnit.remove()
                    auraEffect.destroy()
                end
            end

            -- Reaper 3
            do
                -- Prepare Blood Effect
                local bloodEffect = IEngine.Effect()
                bloodEffect.model = "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl"
                bloodEffect.scale = 1.2

                -- Prepare Aura
                local auraEffect = IEngine.Effect()
                auraEffect.model = "Auras\\Malevolence Aura Blue.mdx"
                auraEffect.scale = 1.5

                -- Prepare Summon
                local summonUnit
                local casting = false
                do
                    local distance = math.random(0, 400)
                    local rad = math.random(0., math.pi * 2)
                    local x = unit.x + distance * math.cos(rad)
                    local y = unit.y + distance * math.sin(rad)
                    summonUnit = unit.owner.createUnit('h002', x, y, bj_RADTODEG * rad)
                    summonUnit.skin = 'h00G'
                    summonUnit.range = 500
                    summonUnit.addAbility('Aloc')
                    summonUnit.bind("on_attack",
                        function(source, target)
                            casting = true
                            BlzUnitInterruptAttack(source.handle)
                            local rad = math.atan(target.y - source.y, target.x - source.x)
                            local x = source.x
                            local y = source.y
                            source.playAnimation(4)
                            eventHolder.clock.schedule_once(
                                function(triggeringClock, triggeringSchedule)
                                    local progress = 0.0
                                    local cosRes = math.cos(rad)
                                    local sinRes = math.sin(rad)
                                    source.playAnimation(11)
                                    triggeringClock.schedule_interval(
                                        function(triggeringClock, triggeringSchedule)
                                            progress = progress + 0.005
                                            local dist = 1000 * IEngine.Easing.in_out_sine(progress)
                                            local x2 = x + dist * cosRes
                                            local y2 = y + dist * sinRes
                                            source.x = x2
                                            source.y = y2
                                            group
                                                .inRange(x2, y2, 150.)
                                                .forEach(
                                                    function(group, enumUnit)
                                                        if unit.isEnemy(enumUnit) then
                                                            bloodEffect.x = enumUnit.x
                                                            bloodEffect.y = enumUnit.y
                                                            bloodEffect.create().destroy()
                                                            unit.damageTarget(enumUnit, unit.damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                                        end
                                                    end
                                                )
                                            if progress >= 1. then
                                                casting = false
                                                source.playAnimation("stand")
                                                triggeringClock.unschedule(triggeringSchedule)
                                            end
                                        end, 0.01
                                    )
                                end, 1.0
                            )
                        end
                    )
                    --summonUnit.setWeaponIntegerField(UNIT_WEAPON_IF_ATTACK_TARGETS_ALLOWED, 0, 4)

                    -- Create Aura
                    auraEffect.create()
                end

                local tx = nil
                local ty = nil 
                eventHolder.schedule = eventHolder.clock.schedule_interval(
                    function(triggeringClock, triggeringSchedule)
                        -- Move Aura
                        auraEffect.x = summonUnit.x
                        auraEffect.y = summonUnit.y
                        auraEffect.z = summonUnit.z

                        if casting then
                            return
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
                        local dist = math.sqrt(dx * dx + dy * dy)
                        if dist > 800. then
                            local otherDist = math.random(400, 600)
                            local rad = math.random(0., math.pi * 2)
                            tx = ux + otherDist * math.cos(rad)
                            ty = uy + otherDist * math.sin(rad)
                            summonUnit.issueOrder("move", tx, ty)
                        else
                            local dx = tx - cx
                            local dy = ty - cy
                            local dist = math.sqrt(dx * dx + dy * dy)
                            if dist > 1. then
                                local rad = math.atan(dy, dx)
                                local increment = 200 + 200 * 0.03 * dist / 70
                                if increment > 500 then
                                    increment = 500
                                    summonUnit.teleportTo(tx, ty)
                                end
                                summonUnit.ms = increment
                            elseif GetRandomInt(0, 1000) == 1 then
                                local otherDist = math.random(400, 700)
                                local rad = math.random(0., math.pi * 2)
                                tx = ux + otherDist * math.cos(rad)
                                ty = uy + otherDist * math.sin(rad)
                                summonUnit.issueOrder("move", tx, ty)
                            end
                        end
                    end, 0.005
                )

                eventHolder.event = unit.bind("on_damage_after",
                    function(source, target, attack)
                        summonUnit.issueOrder("attack", target)
                    end
                ).setCondition(
                    function(source, target, attack)
                        return attack.isAttack and not casting and source == unit
                    end
                )

                eventHolder.cleanup = function()
                    summonUnit.remove()
                    auraEffect.destroy()
                end
            end
        end
        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    return self
end

--[[
_Abilities.Soul_Steal = {}
_Abilities.Soul_Steal.new = function(IEngine)
    local self = {}
    local events = {}
    local clock = IEngine.Clock()
    local healEffect = IEngine.Effect()
    healEffect.model = "Effects\\Grim Curse.mdx"
    healEffect.yaw = 270. * bj_DEGTORAD

    function self.apply(unit)
        if events.unit == nil then
            unit.bind("on_damage_after",
                function(source, target, attack)
                    local healAmount = GetEventDamage()
                    local bulletEffect = IEngine.Effect()
                    bulletEffect.model = "Effects\\Purple Missile.mdx"
                    bulletEffect.x = target.x
                    bulletEffect.y = target.y
                    bulletEffect.create()
                    clock.schedule_interval(
                        function(triggeringClock, triggeringSchedule)
                            local dx = unit.x - bulletEffect.x
                            local dy = unit.y - bulletEffect.y
                            local dist = math.sqrt(dx * dx + dy * dy)
                            if dist > 5. then
                                local rad = math.atan(dy, dx)
                                bulletEffect.x = bulletEffect.x + 5. * math.cos(rad)
                                bulletEffect.y = bulletEffect.y + 5. * math.sin(rad)
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
]]--

-- _Abilities.Hurricane_Constellation = {}
-- _Abilities.Hurricane_Constellation.new = function(IEngine)
--     local self = {}
--     local _eventHolder = {}
--     local group = IEngine.Group()

--     local stompEffect = IEngine.Effect()
--     stompEffect.model = "Effects\\Wind Blast.mdx"
--     stompEffect.scale = 0.7
    
--     local amount = 7

--     function self.apply(unit)
--         if _eventHolder[unit] ~= nil then
--             return
--         end
--         local eventHolder = EventHolder.new(IEngine)

--         do
--             local boltEffect = {}
--             local delayTable = {}

--             for i = 1, amount do
--                 boltEffect[i] = IEngine.Effect()
--                 boltEffect[i].model = "Effects\\Windstorm.mdx"
--                 boltEffect[i].scale = 1.0
--                 boltEffect[i].create()
--                 delayTable[i] = {}
--             end

--             local count = 0
--             local increment = math.pi * 2 / 500.
--             local span = math.pi * 2 / amount

--             eventHolder.schedule = eventHolder.clock.schedule_interval(
--                 function(triggeringClock, triggeringSchedule)
--                     if count < 500 then
--                         count = count + 1
--                     else
--                         count = 0
--                     end
--                     for i = 1, amount do
--                         local x = unit.x + 650. * math.cos(count * increment + i * span)
--                         local y = unit.y + 650. * math.sin(count * increment + i * span)
--                         local z = unit.z
--                         boltEffect[i].x = x
--                         boltEffect[i].y = y
--                         boltEffect[i].z = z
--                         for k, v in pairs(delayTable[i]) do
--                             delayTable[i][k] = v + 1
--                         end
--                         group
--                             .inRange(x, y, 150.)
--                             .forEach(
--                                 function(group, enumUnit)
--                                     if unit.isEnemy(enumUnit) then
--                                         if delayTable[i][enumUnit] == nil then
--                                             delayTable[i][enumUnit] = 100
--                                         end
--                                         if delayTable[i][enumUnit] >= 100 then
--                                             local dist = math.random(0., 30.)
--                                             local rad = math.random(0., math.pi * 2)
--                                             local newX = x + dist * math.cos(rad)
--                                             local newY = y + dist * math.sin(rad)
--                                             stompEffect.x = newX
--                                             stompEffect.y = newY
--                                             stompEffect.z = z
--                                             stompEffect.create().destroy()
--                                             unit.damageTarget(enumUnit, unit.damage * 75., false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
--                                             delayTable[i][enumUnit] = 0
--                                         end
--                                     end
--                                 end
--                             )
--                     end
--                 end, 0.01
--             )

--             eventHolder.cleanup = function()
--                 for i = 1, amount do
--                     boltEffect[i].destroy()
--                 end
--             end
--         end

--         _eventHolder[unit] = eventHolder
--     end

--     function self.remove(unit)
--         if _eventHolder[unit] == nil then
--             return
--         end
--         _eventHolder[unit].unbindAll()
--         _eventHolder[unit] = nil
--     end

--     return self
-- end

_Abilities.Impale = {}
_Abilities.Impale.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Impale"
    metadata.description = "Path: |cffa9e8f9P|r|cff9de0f5r|r|cff91d8f2e|r|cff86d0efs|r|cff7ac9ebe|r|cff6fc1e8r|r|cff62b9e4v|r|cff57b1e1a|r|cff4ba9det|r|cff40a2dai|r|cff349ad7o|r|cff2892d4n|r"
    .. "|nEach 3 seconds deal 750% damage to nearby enemies within 850 range, and heal your allies in the same range by 5% of your max health."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNPreservation.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local impaleEffect = IEngine.Effect()
    impaleEffect.scale = 1.0
    impaleEffect.model = "Effects\\Holy Light.mdx"

    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local tickrate = 3.0
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    group
                        .inRange(unit.x, unit.y, 850.)
                        .forEach(
                            function(group, enumUnit)
                                if enumUnit.hp <= 1 or enumUnit.invulnerable then
                                    return
                                end

                                if unit.isEnemy(enumUnit) then
                                    impaleEffect.x = enumUnit.x
                                    impaleEffect.y = enumUnit.y
                                    impaleEffect.create().destroy()
                                    unit.damageTarget(enumUnit, unit.damage * 7.5, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
                                else
                                    unit.hp = unit.hp + (0.05 * unit.maxhp)
                                end
                            end
                        )
                end, tickrate
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Judgement = {}
_Abilities.Judgement.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Moon Halo"
    metadata.description = "Path: |cffa9e8f9P|r|cff9de0f5r|r|cff91d8f2e|r|cff86d0efs|r|cff7ac9ebe|r|cff6fc1e8r|r|cff62b9e4v|r|cff57b1e1a|r|cff4ba9det|r|cff40a2dai|r|cff349ad7o|r|cff2892d4n|r"
    .. "|nEach attack has a 10% chance to cause a huge aoe damage infront of you, that deals 950% damage."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNPreservation.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local impaleEffect = IEngine.Effect()
    impaleEffect.scale = 1.0
    impaleEffect.model = "Effects\\Holy Light.mdx"

    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            eventHolder.event = unit.bind("on_damage_after",
                function(source, target, attack)
                    if GetRandomInt(1, 10) == 1 then
                        local x = source.x
                        local y = source.y
                        local baseRad = bj_DEGTORAD * source.face
                        local dist = 0
                        local totalDistance = 960
                        local waves = 12
                        local increment = totalDistance / waves
                        eventHolder.clock.schedule_interval(
                            function(triggeringClock, triggeringSchedule)
                                dist = dist + increment
                                local amount = math.floor(dist / 80 + 0.5)
                                local minValue = 0.3 * ((amount - 1) / 2)
                                for i = 0, amount do
                                    local rad = baseRad - minValue + 0.3 * i
                                    local x2 = x + dist * math.cos(rad)
                                    local y2 = y + dist * math.sin(rad)
                                    impaleEffect.x = x2
                                    impaleEffect.y = y2
                                    impaleEffect.create().destroy()
                                    group
                                        .inRange(x2, y2, 100.)
                                        .forEach(
                                            function(group, enumUnit)
                                                if enumUnit.hp <= 1 or enumUnit.invulnerable then
                                                    return
                                                end

                                                if source.isEnemy(enumUnit) then
                                                    source.damageTarget(enumUnit, source.damage * 9.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                                end
                                            end
                                        )
                                end
                                if dist >= totalDistance then
                                    triggeringClock.unschedule(triggeringSchedule)
                                end
                            end, 0.05
                        )
                    end
                end
            ).setCondition(
                function(source, target, attack)
                    return attack.isAttack and source == unit
                end
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Overload = {}
_Abilities.Overload.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Overload"
    metadata.description = "Path: |cffa9e8f9P|r|cff9de0f5r|r|cff91d8f2e|r|cff86d0efs|r|cff7ac9ebe|r|cff6fc1e8r|r|cff62b9e4v|r|cff57b1e1a|r|cff4ba9det|r|cff40a2dai|r|cff349ad7o|r|cff2892d4n|r"
    .. "|nEach time you are attacked there is a 10% chance to deal a huge aoe damage around you, that deals 1000% damage."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNPreservation.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local explodeEffect = IEngine.Effect()
    explodeEffect.scale = 1.0
    explodeEffect.model = "Effects\\Shining Flare.mdx"

    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            eventHolder.event = unit.bind("on_damaged_after",
                function(source, target, attack)
                    if GetRandomInt(1, 10) == 1 then
                        local caster = target
                        local x = caster.x
                        local y = caster.y
                        local dist = 0
                        eventHolder.clock.schedule_interval(
                            function(triggeringClock, triggeringSchedule)
                                dist = dist + 100
                                for i = 0, 12 do
                                    local rad = i * 0.5236
                                    local x2 = x + dist * math.cos(rad)
                                    local y2 = y + dist * math.sin(rad)
                                    explodeEffect.x = x2
                                    explodeEffect.y = y2
                                    explodeEffect.create().destroy()
                                    group
                                        .inRange(x2, y2, 150.)
                                        .forEach(
                                            function(group, enumUnit)
                                                if enumUnit.hp <= 1 or enumUnit.invulnerable then
                                                    return
                                                end
                                                
                                                if caster.isEnemy(enumUnit) then
                                                    caster.damageTarget(enumUnit, caster.damage * 10.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                                end
                                            end
                                        )
                                end
                                if dist >= 500 then
                                    triggeringClock.unschedule(triggeringSchedule)
                                end
                            end, 0.05
                        )
                    end
                end
            ).setCondition(
                function(source, target, attack)
                    return attack.isAttack and target == unit
                end
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Heaven_Justice = {}
_Abilities.Heaven_Justice.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Heaven Justice"
    metadata.description = "Path: |cffa9e8f9P|r|cff9de0f5r|r|cff91d8f2e|r|cff86d0efs|r|cff7ac9ebe|r|cff6fc1e8r|r|cff62b9e4v|r|cff57b1e1a|r|cff4ba9det|r|cff40a2dai|r|cff349ad7o|r|cff2892d4n|r"
    .. "|nEvery 10 seconds a angel descends from the sky, casting lasers on several locations, dealing 4500% damage to enemies and healing allies by 20% of your max health."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNPreservationPath.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local explodeEffect = IEngine.Effect()
    explodeEffect.scale = 1.3
    explodeEffect.model = "Effects\\Shining Flare.mdx"
    local afterEffect = IEngine.Effect()
    afterEffect.scale = 0.7
    afterEffect.model = "Effects\\Earth Shock.mdx"
    local pointEffect = IEngine.Effect()
    pointEffect.scale = 1.0
    pointEffect.model = "Effects\\Blight.mdx"
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    local dist = math.random(300, 700)
                    local rad = math.random(0., math.pi * 2)
                    local x = unit.x + dist * math.cos(rad)
                    local y = unit.y + dist * math.sin(rad)
                    local auraEffect = IEngine.Effect()
                    auraEffect.model = "Effects\\Holy Aura.mdx"
                    auraEffect.x = x
                    auraEffect.y = y
                    auraEffect.scale = 1.0
                    auraEffect.create()
                    local angelUnit = unit.owner.createUnit('hpea', x, y, 270.)
                    angelUnit.skin = 'h00D'
                    angelUnit.addAbility('Aloc')
                    angelUnit.playAnimation("birth")
                    triggeringClock.schedule_once(
                        function(triggeringClock, triggeringSchedule)
                            angelUnit.playAnimation(2)
                            triggeringClock.schedule_once(
                                function(triggeringClock, triggeringSchedule)
                                    angelUnit.playAnimation(5)
                                    triggeringClock.schedule_once(
                                        function(triggeringClock, triggeringSchedule)
                                            angelUnit.remove()
                                            auraEffect.destroy()
                                        end, 1.9
                                    )
                                end, 2.55
                            )
                            triggeringClock.schedule_once(
                                function(triggeringClock, triggeringSchedule)
                                    local max = math.pi * 2
                                    for i = 0, 35 do
                                        local dist = math.random(0., 850.)
                                        local rad = math.random(0., max)
                                        local x2 = x + dist * math.cos(rad)
                                        local y2 = y + dist * math.sin(rad)
                                        pointEffect.x = x2
                                        pointEffect.y = y2
                                        pointEffect.create().destroy()
                                        triggeringClock.schedule_once(
                                            function(triggeringClock, triggeringSchedule)
                                                explodeEffect.x = x2
                                                explodeEffect.y = y2
                                                explodeEffect.create().destroy()
                                                afterEffect.x = x2
                                                afterEffect.y = y2
                                                afterEffect.create().destroy()
                                                group
                                                    .inRange(x2, y2, 150.)
                                                    .forEach(
                                                        function(group, enumUnit)
                                                            if enumUnit.hp <= 1 or enumUnit.invulnerable then
                                                                return
                                                            end
                                                            
                                                            if unit.isEnemy(enumUnit) then
                                                                unit.damageTarget(enumUnit, unit.damage * 45.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                                            else
                                                                enumUnit.hp = enumUnit.hp + 0.2 * unit.maxhp
                                                            end
                                                        end
                                                    )
                                            end, 1.05
                                        )
                                    end
                                end, 1.1
                            )
                        end, 1.3
                    )
                end, 10.0
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Interceptor = {}
_Abilities.Interceptor.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Interceptor"
    metadata.description = "Path: |cfffa795dD|r|cfff87158e|r|cfff66953s|r|cfff4624et|r|cfff25a49r|r|cfff05344u|r|cffee4b3fc|r|cffec443at|r|cffea3c35i|r|cffe83531o|r|cffe62d2cn|r"
    .. "|nEach 0.1 seconds a rocket falls from the sky within 100-800 range and deals 750% damage."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNDestruction.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local explodeEffect = IEngine.Effect()
    explodeEffect.scale = 2.0
    explodeEffect.model = "Effects\\Interceptor Shell Rain.mdx"
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local tickrate = 0.1
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    local dist = math.random(100, 800)
                    local rad = math.random(0., math.pi * 2)
                    local x = unit.x + dist * math.cos(rad)
                    local y = unit.y + dist * math.sin(rad)
                    explodeEffect.x = x
                    explodeEffect.y = y
                    explodeEffect.create().destroy()
                    triggeringClock.schedule_once(
                        function(triggeringClock, triggeringSchedule)
                            group
                                .inRange(x, y, 150.)
                                .forEach(
                                    function(group, enumUnit)
                                        if unit.isEnemy(enumUnit) then
                                            unit.damageTarget(enumUnit, unit.damage * 7.5, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE) 
                                        end
                                    end
                                )
                        end, 0.1
                    )
                end, tickrate
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end


_Abilities.Sacred_Storm = {}
_Abilities.Sacred_Storm.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Sacred Storm"
    metadata.description = "Path: |cfffa795dD|r|cfff87158e|r|cfff66953s|r|cfff4624et|r|cfff25a49r|r|cfff05344u|r|cffee4b3fc|r|cffec443at|r|cffea3c35i|r|cffe83531o|r|cffe62d2cn|r"
    .. "|nSummons 2 Lasers, which deal 1000% damage per second. When the two lasers collide, an area of darkness is created which causes eruptions each 0.2 seconds, that deal 500% damage."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNDestruction.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local explodeEffect = IEngine.Effect()
    explodeEffect.model = "Effects\\Gravity Storm.mdx"
    explodeEffect.scale = 0.5
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local speed = 1

            local orangeX = nil
            local orangeY = nil
            local blueX = nil
            local blueY = nil
            do
                local dps = 10.0
                local tickrate = 0.01
                local damagePerTick = dps * tickrate

                local laserOrange = nil
                local currentDist
                local targetRad
                local targetDist
                local casterLaserDist
                local casterLaserRad
                eventHolder.schedule = eventHolder.clock.schedule_interval(
                    function(triggeringClock, triggeringSchedule)
                        local ux = unit.x
                        local uy = unit.y

                        if laserOrange == nil then
                            laserOrange = IEngine.Effect()
                            laserOrange.model = "Effects\\Sacred Storm.mdx"
                            laserOrange.scale = 1.2
                            laserOrange.x = ux
                            laserOrange.y = uy
                            laserOrange.create()

                            -- Declare target point by radians and distance
                            targetDist = math.random(100, 800)
                            targetRad = math.random(0., math.pi * 2)

                            -- Declare distance and radians between caster and laser
                            casterLaserDist = 0
                            casterLaserRad = 0
                            currentDist = 0
                        end

                        currentDist = currentDist + speed

                        -- Declare current position of laser based on distance and radians
                        local currentX = ux + casterLaserDist * math.cos(casterLaserRad)
                        local currentY = uy + casterLaserDist * math.sin(casterLaserRad)

                        -- Declare new position of laser based on distance and radians
                        orangeX = currentX + speed * math.cos(targetRad)
                        orangeY = currentY + speed * math.sin(targetRad)

                        -- Move laser to new position
                        laserOrange.x = orangeX
                        laserOrange.y = orangeY

                        -- Declare new distance and radians between caster and laser
                        local dx = orangeX - ux
                        local dy = orangeY - uy
                        casterLaserDist = math.sqrt(dx * dx + dy * dy)
                        casterLaserRad = math.atan(dy, dx)

                        -- If laser travelled expected distance
                        if currentDist >= targetDist then
                            -- Declare new point from caster position
                            local tempRad = math.random(0., math.pi * 2)
                            local tempDist = math.random(100, 800)
                            local targetX = ux + tempDist * math.cos(tempRad)
                            local targetY = uy + tempDist * math.sin(tempRad)

                            -- Declare new expected distance and target radians
                            local dx = targetX - orangeX
                            local dy = targetY - orangeY
                            targetDist = math.sqrt(dx * dx + dy * dy)
                            targetRad = math.atan(dy, dx)

                            currentDist = 0
                        end

                        group
                            .inRange(orangeX, orangeY, 250.)
                            .forEach(
                                function(group, enumUnit)
                                    if unit.isEnemy(enumUnit) then
                                        unit.damageTarget(enumUnit, unit.damage * damagePerTick, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE) 
                                    end
                                end
                            )
                    end, tickrate
                )

                eventHolder.cleanup = function()
                    if laserOrange ~= nil then
                        laserOrange.destroy()
                    end
                end
            end

            do
                local dps = 10.0
                local tickrate = 0.01
                local damagePerTick = dps * tickrate

                local laserBlue = nil
                local currentDist
                local targetRad
                local targetDist
                local casterLaserDist
                local casterLaserRad
                eventHolder.schedule = eventHolder.clock.schedule_interval(
                    function(triggeringClock, triggeringSchedule)
                        local ux = unit.x
                        local uy = unit.y

                        if laserBlue == nil then
                            laserBlue = IEngine.Effect()
                            laserBlue.model = "Effects\\Mana Storm.mdx"
                            laserBlue.scale = 1.2
                            laserBlue.x = ux
                            laserBlue.y = uy
                            laserBlue.create()

                            -- Declare target point by radians and distance
                            targetDist = math.random(100, 800)
                            targetRad = math.random(0., math.pi * 2)

                            -- Declare distance and radians between caster and laser
                            casterLaserDist = 0
                            casterLaserRad = 0
                            currentDist = 0
                        end

                        currentDist = currentDist + speed

                        -- Declare current position of laser based on distance and radians
                        local currentX = ux + casterLaserDist * math.cos(casterLaserRad)
                        local currentY = uy + casterLaserDist * math.sin(casterLaserRad)

                        -- Declare new position of laser based on distance and radians
                        blueX = currentX + speed * math.cos(targetRad)
                        blueY = currentY + speed * math.sin(targetRad)

                        -- Move laser to new position
                        laserBlue.x = blueX
                        laserBlue.y = blueY

                        -- Declare new distance and radians between caster and laser
                        local dx = blueX - ux
                        local dy = blueY - uy
                        casterLaserDist = math.sqrt(dx * dx + dy * dy)
                        casterLaserRad = math.atan(dy, dx)

                        -- If laser travelled expected distance
                        if currentDist >= targetDist then
                            -- Declare new point from caster position
                            local tempRad = math.random(0., math.pi * 2)
                            local tempDist = math.random(100, 800)
                            local targetX = ux + tempDist * math.cos(tempRad)
                            local targetY = uy + tempDist * math.sin(tempRad)

                            -- Declare new expected distance and target radians
                            local dx = targetX - blueX
                            local dy = targetY - blueY
                            targetDist = math.sqrt(dx * dx + dy * dy)
                            targetRad = math.atan(dy, dx)

                            currentDist = 0
                        end

                        group
                            .inRange(blueX, blueY, 250.)
                            .forEach(
                                function(group, enumUnit)
                                    if unit.isEnemy(enumUnit) then
                                        unit.damageTarget(enumUnit, unit.damage * damagePerTick, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE) 
                                    end
                                end
                            )
                    end, tickrate
                )

                eventHolder.cleanup = function()
                    if laserBlue ~= nil then
                        laserBlue.destroy()
                    end
                end
            end

            do
                local tickrate = 0.01

                local laserDark = nil
                local count = 0
                eventHolder.schedule = eventHolder.clock.schedule_interval(
                    function(triggeringClock, triggeringSchedule)
                        if orangeX == nil or orangeY == nil or blueX == nil or blueY == nil then
                            return
                        end

                        local dx = orangeX - blueX
                        local dy = orangeY - blueY
                        local dist = math.sqrt(dx * dx + dy * dy)

                        if dist < 500 then
                            local rad = math.atan(dy, dx)
                            local newX = blueX + (dist / 2) * math.cos(rad)
                            local newY = blueY + (dist / 2) * math.sin(rad)
                            if laserDark == nil then
                                laserDark = IEngine.Effect()
                                laserDark.model = "Effects\\Void Disc.mdx"
                                laserDark.scale = 1.2
                                laserDark.x = newX
                                laserDark.y = newY
                                laserDark.create()
                            else
                                laserDark.x = newX
                                laserDark.y = newY
                            end
                            count = count + 1
                            local requiredCount = 20
                            if count >= requiredCount then
                                count = 0
                                local rad = math.random(0., math.pi * 2)
                                local dist = math.random(0, 150)
                                local explosionX = newX + dist * math.cos(rad)
                                local explosionY = newY + dist * math.sin(rad)
                                explodeEffect.x = explosionX
                                explodeEffect.y = explosionY
                                explodeEffect.create().destroy()
                                group
                                    .inRange(explosionX, explosionY, 150.)
                                    .forEach(
                                        function(group, enumUnit)
                                            if unit.isEnemy(enumUnit) then
                                                unit.damageTarget(enumUnit, unit.damage * 5., false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE) 
                                            end
                                        end
                                    )
                            end
                        elseif laserDark ~= nil then
                            laserDark.destroy()
                            laserDark = nil
                            count = 0
                        end
                    end, tickrate
                )

                eventHolder.cleanup = function()
                    if laserDark ~= nil then
                        laserDark.destroy()
                    end
                end
            end
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Kingdom_Come = {}
_Abilities.Kingdom_Come.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Kingdom Come"
    metadata.description = "Path: |cfffa795dD|r|cfff87158e|r|cfff66953s|r|cfff4624et|r|cfff25a49r|r|cfff05344u|r|cffee4b3fc|r|cffec443at|r|cffea3c35i|r|cffe83531o|r|cffe62d2cn|r"
    .. "|nEach second a sword falls from the sky that deals 2000% damage. Every 10th sword deals 6000% damage and is 400% larger."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNDestruction.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local explodeEffect = IEngine.Effect()
    explodeEffect.model = "Effects\\Kingdom Come.mdx"
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local count = 0
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    count = count + 1
                    local scale = 1.5
                    local damage_factor = 20.
                    if count >= 10 then
                        count = 0
                        scale = 4.0
                        damage_factor = 60.
                    end
                    local dist = math.random(100, 800)
                    local rad = math.random(0., math.pi * 2)
                    local x = unit.x + dist * math.cos(rad)
                    local y = unit.y + dist * math.sin(rad)
                    explodeEffect.scale = scale
                    explodeEffect.x = x
                    explodeEffect.y = y
                    explodeEffect.create().destroy()
                    local currentTime = 0
                    local totalTime = 2.3
                    local tickrate = 0.05
                    local damage_per_tick = damage_factor / (totalTime / tickrate)
                    triggeringClock.schedule_interval(
                        function(triggeringClock, triggeringSchedule)
                            currentTime = currentTime + tickrate
                            group
                                .inRange(x, y, 200. * scale)
                                .forEach(
                                    function(group, enumUnit)
                                        if unit.isEnemy(enumUnit) then
                                            unit.damageTarget(enumUnit, unit.damage * damage_per_tick, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE) 
                                        end
                                    end
                                )
                            if currentTime >= totalTime then
                                triggeringClock.unschedule(triggeringSchedule)
                            end
                        end, tickrate
                    )
                end, 1.0
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.I_Am_Atomic = {}
_Abilities.I_Am_Atomic.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "I am Atomic"
    metadata.description = "Path: |cfffa795dD|r|cfff87158e|r|cfff66953s|r|cfff4624et|r|cfff25a49r|r|cfff05344u|r|cffee4b3fc|r|cffec443at|r|cffea3c35i|r|cffe83531o|r|cffe62d2cn|r"
    .. "|nAfter being hit 30 times, cause a huge explosion after a few seconds, that deals a maximum of 25000% damage in its epicenter."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNDestructionPath.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local attackCount = 0

            local channelEffect1 = IEngine.Effect()
            channelEffect1.scale = 1.0
            channelEffect1.model = "Auras\\Darkness.mdx"

            local channelEffect2 = IEngine.Effect()
            channelEffect2.scale = 3.0
            channelEffect2.model = "Auras\\Memento Mori.mdx"

            local explodeEffect1 = IEngine.Effect()
            explodeEffect1.model = "Effects\\Shadow Explosion 1.mdx"

            local explodeEffect2 = IEngine.Effect()
            explodeEffect2.model = "Effects\\Shadow Explosion 2.mdx"

            eventHolder.event = unit.bind("on_damaged_after",
                function(source, target, attack)
                    attackCount = attackCount + 1
                    if attackCount < 30 then
                        return
                    end
                    attackCount = 0
                    local dist = 0
                    
                    channelEffect1.x = target.x
                    channelEffect1.y = target.y
                    channelEffect1.z = target.z
                    channelEffect1.create()

                    channelEffect2.x = target.x
                    channelEffect2.y = target.y
                    channelEffect2.z = target.z
                    channelEffect2.create()

                    local channelEffectSchedule = eventHolder.clock.schedule_interval(
                        function(triggeringClock, triggeringSchedule)
                            channelEffect1.x = target.x
                            channelEffect1.y = target.y
                            channelEffect1.z = target.z
                            channelEffect2.x = target.x
                            channelEffect2.y = target.y
                            channelEffect2.z = target.z
                        end, 0.01
                    )

                    local channelEffectSchedule = eventHolder.schedule_once(
                        function(triggeringClock, triggeringSchedule)
                            triggeringClock.unschedule(channelEffectSchedule)
                            channelEffect1.destroy()
                            channelEffect2.destroy()
                            
                            local effect1Size = 1.0
                            local effect1TargetSize = 10.0
                            local effect2Size = 0.2
                            local effect2TargetSize = 2.0

                            local currentDuration = 0
                            local totalDuration = 2.0
                            local tickrate = 0.01
                            
                            local effect1Change = (effect1TargetSize - effect1Size) / (totalDuration / tickrate)
                            local effect2Change = (effect2TargetSize - effect2Size) / (totalDuration / tickrate)

                            local explosionX = target.x
                            local explosionY = target.y
                            explodeEffect1.x = explosionX
                            explodeEffect1.y = explosionY
                            explodeEffect1.scale = effect1Size
                            explodeEffect2.x = explosionX
                            explodeEffect2.y = explosionY
                            explodeEffect2.scale = effect2Size

                            explodeEffect1.create()
                            explodeEffect2.create()

                            local damageFactor = 250.
                            local damage_per_tick = damage_factor / (totalDuration / tickrate)

                            triggeringClock.schedule_interval(
                                function(triggeringClock, triggeringSchedule)
                                    currentDuration = currentDuration + tickrate
                                    explodeEffect1.scale = effect1Size + effect1Change * (currentDuration / tickrate)
                                    explodeEffect2.scale = effect2Size + effect2Change * (currentDuration / tickrate)
                                    if currentDuration >= totalDuration then
                                        explodeEffect1.destroy()
                                        explodeEffect2.destroy()
                                        triggeringClock.unschedule(triggeringSchedule)
                                    end

                                    group
                                        .inRange(explosionX, explosionY, 300 + 2200. * (currentDuration / totalDuration))
                                        .forEach(
                                            function(group, enumUnit)
                                                if unit.isEnemy(enumUnit) then
                                                    unit.damageTarget(enumUnit, unit.damage * damage_per_tick, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE) 
                                                end
                                            end
                                        )
                                end, tickrate
                            )
                        end, 5.0
                    )
                end
            )

            eventHolder.cleanup = function()
                channelEffect1.destroy()
                channelEffect2.destroy()
                explodeEffect1.destroy()
                explodeEffect2.destroy()
            end
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Magma_Constellation = {}
_Abilities.Magma_Constellation.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Magma Constellation"
    metadata.description = "Path: |cffff0000H|r|cffaa0054a|r|cff5500a9r|r|cff0000fem|r|cff0054aao|r|cff00a955n|r|cff00fe00y|r"
    .. "|nMagma Stars are rotating around you, dealing 500% damage per tick. Each star can only deal damage once every 1.0 seconds."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNHarmony.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local hitEffect = IEngine.Effect()
    hitEffect.model = "Effects\\Firebolt.mdx"
    hitEffect.scale = 1.0
    local stompEffect = IEngine.Effect()
    stompEffect.model = "Effects\\Stomp_Effect.mdx"
    stompEffect.scale = 0.7

    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local boltEffect = {}
            local delayTable = {}
            local amount = 5
            for i = 1, amount do
                boltEffect[i] = IEngine.Effect()
                boltEffect[i].model = "Effects\\Firebolt.mdx"
                boltEffect[i].scale = 2.0
                boltEffect[i].create()
                delayTable[i] = {}
            end

            local count = 0
            local increment = math.pi * 2 / 200
            local span = math.pi * 2 / amount
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    if count < 200 then
                        count = count + 1
                    else
                        count = 0
                    end
                    for i = 1, amount do
                        local x = unit.x + 350. * math.cos(count * increment + i * span)
                        local y = unit.y + 350. * math.sin(count * increment + i * span)
                        local z = unit.z + 75.
                        boltEffect[i].x = x
                        boltEffect[i].y = y
                        boltEffect[i].z = z
                        for k, v in pairs(delayTable[i]) do
                            delayTable[i][k] = v + 1
                        end
                        group
                            .inRange(x, y, 150.)
                            .forEach(
                                function(group, enumUnit)
                                    if unit.isEnemy(enumUnit) then
                                        if delayTable[i][enumUnit] == nil then
                                            delayTable[i][enumUnit] = 100
                                        end
                                        if delayTable[i][enumUnit] >= 100 then
                                            local dist = math.random(0., 30.)
                                            local rad = math.random(0., math.pi * 2)
                                            local newX = x + dist * math.cos(rad)
                                            local newY = y + dist * math.sin(rad)
                                            hitEffect.x = newX
                                            hitEffect.y = newY
                                            hitEffect.z = z
                                            hitEffect.create().destroy()
                                            stompEffect.x = newX
                                            stompEffect.y = newY
                                            stompEffect.z = z
                                            stompEffect.create().destroy()
                                            unit.damageTarget(enumUnit, unit.damage * 5., false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                            delayTable[i][enumUnit] = 0
                                        end
                                    end
                                end
                            )
                    end
                end, 0.01
            )

            eventHolder.cleanup = function()
                for i = 1, amount do
                    boltEffect[i].destroy()
                end
            end
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Blizzard = {}
_Abilities.Blizzard.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Blizzard"
    metadata.description = "Path: |cffff0000H|r|cffaa0054a|r|cff5500a9r|r|cff0000fem|r|cff0054aao|r|cff00a955n|r|cff00fe00y|r"
    .. "|nSummons a blizzard around you, that deals 1000% damage per ice shard."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNHarmony.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local hailEffect = IEngine.Effect()
    hailEffect.scale = 1.3
    hailEffect.model = "Effects\\Blizzard II.mdx"
    local explodeEffect = IEngine.Effect()
    explodeEffect.model = "Effects\\Winter Blast.mdx"
    explodeEffect.scale = 0.7
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    local dist = math.random(350., 650.)
                    local rad = math.random(0., math.pi * 2)
                    local x = unit.x + dist * math.cos(rad)
                    local y = unit.y + dist * math.sin(rad)
                    hailEffect.x = x
                    hailEffect.y = y
                    hailEffect.create().destroy()
                    triggeringClock.schedule_once(
                        function(triggeringClock, triggeringSchedule)
                            explodeEffect.x = x
                            explodeEffect.y = y
                            explodeEffect.create().destroy()
                            group
                                .inRange(x, y, 150.)
                                .forEach(
                                    function(group, enumUnit)
                                        if unit.isEnemy(enumUnit) then
                                            unit.damageTarget(enumUnit, unit.damage * 10., false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                        end
                                    end
                                )
                        end, 0.9
                    )
                end, 0.10
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Uncontrollable_Flames = {}
_Abilities.Uncontrollable_Flames.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Uncontrollable Flames"
    metadata.description = "Path: |cffff0000H|r|cffaa0054a|r|cff5500a9r|r|cff0000fem|r|cff0054aao|r|cff00a955n|r|cff00fe00y|r"
    .. "|nCause fire eruptions around you, that deal 750% damage each."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNHarmony.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    local explodeEffect = IEngine.Effect()
    explodeEffect.scale = 1.3
    explodeEffect.model = "Effects\\Pillar of Flame Orange.mdx"
    local stompEffect = IEngine.Effect()
    stompEffect.model = "Effects\\Stomp_Effect.mdx"
    stompEffect.scale = 0.7
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local count = 0
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    local dist = math.random(100, 300)
                    local rad = math.random(0., math.pi * 2)
                    local x = unit.x + dist * math.cos(rad)
                    local y = unit.y + dist * math.sin(rad)

                    explodeEffect.x = x
                    explodeEffect.y = y
                    explodeEffect.create().destroy()

                    stompEffect.x = x
                    stompEffect.y = y
                    stompEffect.create().destroy()

                    group
                        .inRange(x, y, 150.)
                        .forEach(
                            function(group, enumUnit)
                                if unit.isEnemy(enumUnit) then
                                    unit.damageTarget(enumUnit, unit.damage * 7.5, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS) 
                                end
                            end
                        )
                end, 0.10
            )
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Black_Hole = {}
_Abilities.Black_Hole.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Black Hole"
    metadata.description = "Path: |cffff0000H|r|cffaa0054a|r|cff5500a9r|r|cff0000fem|r|cff0054aao|r|cff00a955n|r|cff00fe00y|r"
    .. "|nEach 3.0 seconds spawns a orange and a purple blackhole nearby, that stays for 10 seconds. Both blackholes deal 2500% damage per second to enemies that are in it. The purple blackhole drags enemies to its center, while the orange blackhole pushes enemies away from its center. Both effects get stronger, the nearer the unit is to the blackholes center."
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNHarmonyPath.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            -- Purple
            do
                local blackholes = {}
                local spawnInterval = 3.0
                local totalDuration = 10.0
                local tickrate = 0.01
                local range = 700.
                local damageRange = 250.
                local damageFactor = 25. * tickrate
                local minDist = 150.
                local maxDist = 1200.
                local change = 1.0 -- < 0 for push, > 0 for pull
                local lowestDistanceFactor = 0.6
                local highestDistanceFactor = 3.0
                local distanceFactor =(highestDistanceFactor - lowestDistanceFactor) / range
                local maxBlackholes = math.ceil(totalDuration / spawnInterval)
                for index = 1, maxBlackholes, 1 do
                    local blackhole = IEngine.Effect()
                    blackhole.model = "Effects\\Void Rift Purple.mdx"
                    blackhole.scale = 1.2
                    blackholes[index] = blackhole
                end
                local currentIndex = 1
                eventHolder.schedule = eventHolder.clock.schedule_interval(
                    function(triggeringClock, triggeringSchedule)
                        local ux = unit.x
                        local uy = unit.y
                        local dist = math.random(minDist, maxDist)
                        local rad = math.random(0., math.pi * 2)
                        local blackholeX = ux + dist * math.cos(rad)
                        local blackholeY = uy + dist * math.sin(rad)

                        local blackhole = blackholes[currentIndex]
                        blackhole.x = blackholeX
                        blackhole.y = blackholeY
                        blackhole.create()

                        local currentDuration = 0.
                        triggeringClock.schedule_interval(
                            function(triggeringClock, triggeringSchedule)
                                currentDuration = currentDuration + tickrate
                                -- Pull/Push enemies
                                group
                                    .inRange(blackholeX, blackholeY, range)
                                    .forEach(
                                        function(group, enumUnit)
                                            if not unit.isEnemy(enumUnit) then
                                                return
                                            end
                                            local dx = blackholeX - enumUnit.x
                                            local dy = blackholeY - enumUnit.y
                                            local dist = math.sqrt(dx * dx + dy * dy)
                                            local distanceFactor = highestDistanceFactor - distanceFactor * dist
                                            local rad = math.atan(dy, dx)
                                            enumUnit.x = enumUnit.x + (change * distanceFactor) * math.cos(rad)
                                            enumUnit.y = enumUnit.y + (change * distanceFactor) * math.sin(rad)
                                            if dist > damageRange then
                                                return
                                            end
                                            unit.damageTarget(enumUnit, unit.damage * damageFactor, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE) 
                                        end
                                    )
                                if currentDuration >= totalDuration then
                                    blackhole.destroy()
                                    triggeringClock.unschedule(triggeringSchedule)
                                end
                            end, tickrate
                        )
                        currentIndex = currentIndex + 1
                        if currentIndex > maxBlackholes then
                            currentIndex = 1
                        end
                    end, spawnInterval
                )
    
                eventHolder.cleanup = function()
                    for _, blackhole in pairs(blackholes) do
                        blackhole.destroy()
                    end
                end
            end

            -- Orange
            do
                local blackholes = {}
                local spawnInterval = 3.0
                local totalDuration = 10.0
                local tickrate = 0.01
                local range = 700.
                local damageRange = 250.
                local damageFactor = 25. * tickrate
                local minDist = 150.
                local maxDist = 1200.
                local change = -1.0 -- < 0 for push, > 0 for pull
                local lowestDistanceFactor = 0.6
                local highestDistanceFactor = 3.0
                local distanceFactor =(highestDistanceFactor - lowestDistanceFactor) / range
                local maxBlackholes = math.ceil(totalDuration / spawnInterval)
                for index = 1, maxBlackholes, 1 do
                    local blackhole = IEngine.Effect()
                    blackhole.model = "Effects\\Void Rift Orange.mdx"
                    blackhole.scale = 1.2
                    blackholes[index] = blackhole
                end
                local currentIndex = 1
                eventHolder.schedule = eventHolder.clock.schedule_interval(
                    function(triggeringClock, triggeringSchedule)
                        local ux = unit.x
                        local uy = unit.y
                        local dist = math.random(minDist, maxDist)
                        local rad = math.random(0., math.pi * 2)
                        local blackholeX = ux + dist * math.cos(rad)
                        local blackholeY = uy + dist * math.sin(rad)

                        local blackhole = blackholes[currentIndex]
                        blackhole.x = blackholeX
                        blackhole.y = blackholeY
                        blackhole.create()

                        local currentDuration = 0.
                        triggeringClock.schedule_interval(
                            function(triggeringClock, triggeringSchedule)
                                currentDuration = currentDuration + tickrate
                                -- Pull/Push enemies
                                group
                                    .inRange(blackholeX, blackholeY, range)
                                    .forEach(
                                        function(group, enumUnit)
                                            if not unit.isEnemy(enumUnit) then
                                                return
                                            end
                                            local dx = blackholeX - enumUnit.x
                                            local dy = blackholeY - enumUnit.y
                                            local dist = math.sqrt(dx * dx + dy * dy)
                                            local distanceFactor = highestDistanceFactor - distanceFactor * dist
                                            local rad = math.atan(dy, dx)
                                            enumUnit.x = enumUnit.x + (change * distanceFactor) * math.cos(rad)
                                            enumUnit.y = enumUnit.y + (change * distanceFactor) * math.sin(rad)
                                            if dist > damageRange then
                                                return
                                            end
                                            unit.damageTarget(enumUnit, unit.damage * damageFactor, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_CLAW_LIGHT_SLICE) 
                                        end
                                    )
                                if currentDuration >= totalDuration then
                                    blackhole.destroy()
                                    triggeringClock.unschedule(triggeringSchedule)
                                end
                            end, tickrate
                        )
                        currentIndex = currentIndex + 1
                        if currentIndex > maxBlackholes then
                            currentIndex = 1
                        end
                    end, spawnInterval
                )
    
                eventHolder.cleanup = function()
                    for _, blackhole in pairs(blackholes) do
                        blackhole.destroy()
                    end
                end
            end
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Destruction_Aura = {}
_Abilities.Destruction_Aura.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = nil
    metadata.description = nil
    metadata.icon = nil

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local auraEffect1 = IEngine.Effect()
            auraEffect1.model = "Auras\\Fountain of Souls.mdx"
            auraEffect1.scale = 1.0
            auraEffect1.yaw = bj_DEGTORAD * 270.
            auraEffect1.create()
            local auraEffect2 = IEngine.Effect()
            auraEffect2.model = "Auras\\Pentagram Aura.mdx"
            auraEffect2.scale = 2.0
            auraEffect2.yaw = bj_DEGTORAD * 270.
            auraEffect2.create()
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    auraEffect1.x = unit.x
                    auraEffect1.y = unit.y
                    auraEffect1.z = unit.z
                    auraEffect2.x = unit.x
                    auraEffect2.y = unit.y
                    auraEffect2.z = unit.z
                end, 0.01
            )

            eventHolder.cleanup = function()
                auraEffect1.destroy()
                auraEffect2.destroy()
            end
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Preservation_Aura = {}
_Abilities.Preservation_Aura.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = nil
    metadata.description = nil
    metadata.icon = nil

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local auraEffect = IEngine.Effect()
            auraEffect.model = "Auras\\Holy Aura.mdx"
            auraEffect.scale = 1.5
            auraEffect.yaw = bj_DEGTORAD * 270.
            auraEffect.create()
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    auraEffect.x = unit.x
                    auraEffect.y = unit.y
                    auraEffect.z = unit.z
                end, 0.01
            )

            eventHolder.cleanup = function()
                auraEffect.destroy()
            end
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Nihility_Aura = {}
_Abilities.Nihility_Aura.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = nil
    metadata.description = nil
    metadata.icon = nil

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local auraEffect = IEngine.Effect()
            auraEffect.model = "Auras\\Jibril Aura.mdx"
            auraEffect.scale = 2.0
            auraEffect.yaw = bj_DEGTORAD * 270.
            auraEffect.create()
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    auraEffect.x = unit.x
                    auraEffect.y = unit.y
                    auraEffect.z = unit.z
                end, 0.01
            )

            eventHolder.cleanup = function()
                auraEffect.destroy()
            end
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Harmony_Aura = {}
_Abilities.Harmony_Aura.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = nil
    metadata.description = nil
    metadata.icon = nil

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local auraEffect = IEngine.Effect()
            auraEffect.model = "Auras\\Blue Rune Aura.mdx"
            auraEffect.scale = 2.0
            auraEffect.yaw = bj_DEGTORAD * 270.
            auraEffect.create()
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    auraEffect.x = unit.x
                    auraEffect.y = unit.y
                    auraEffect.z = unit.z
                end, 0.01
            )

            eventHolder.cleanup = function()
                auraEffect.destroy()
            end
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Erudition_Aura = {}
_Abilities.Erudition_Aura.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = nil
    metadata.description = nil
    metadata.icon = nil

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local auraEffect1 = IEngine.Effect()
            auraEffect1.model = "Auras\\Grim Reaper Aura Origin.mdx"
            auraEffect1.scale = 1.5
            auraEffect1.yaw = bj_DEGTORAD * 270.
            auraEffect1.create()
            local auraEffect2 = IEngine.Effect()
            auraEffect2.model = "Auras\\Grim Reaper Aura Overhead.mdx"
            auraEffect2.scale = 1.5
            auraEffect2.yaw = bj_DEGTORAD * 270.
            auraEffect2.create()
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    auraEffect1.x = unit.x
                    auraEffect1.y = unit.y
                    auraEffect1.z = unit.z
                    auraEffect2.x = unit.x
                    auraEffect2.y = unit.y
                    auraEffect2.z = unit.z + 100.
                end, 0.01
            )

            eventHolder.cleanup = function()
                auraEffect1.destroy()
                auraEffect2.destroy()
            end
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Hunt_Aura = {}
_Abilities.Hunt_Aura.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = nil
    metadata.description = nil
    metadata.icon = nil

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            local auraEffect = IEngine.Effect()
            auraEffect.model = "Auras\\Thunder Aura.mdx"
            auraEffect.scale = 2.0
            auraEffect.yaw = bj_DEGTORAD * 270.
            auraEffect.create()
            eventHolder.schedule = eventHolder.clock.schedule_interval(
                function(triggeringClock, triggeringSchedule)
                    auraEffect.x = unit.x
                    auraEffect.y = unit.y
                    auraEffect.z = unit.z
                end, 0.01
            )

            eventHolder.cleanup = function()
                auraEffect.destroy()
            end
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

_Abilities.Template = {}
_Abilities.Template.new = function(IEngine)
    local self = {}
    local _eventHolder = {}
    local group = IEngine.Group()
    local metadata = MetaData.new()
    local mt = {}

    metadata.name = "Ability Name"
    metadata.description = "Ability Description"
    metadata.icon = "ReplaceableTextures\\CommandButtons\\BTNSomeIcon.blp"

    function mt.__index(table, index)
        if index == "metadata" then
            return metadata
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end
    
    function self.apply(unit)
        if _eventHolder[unit] ~= nil then
            return
        end
        local eventHolder = EventHolder.new(IEngine)

        do
            -- Code goes here
        end

        _eventHolder[unit] = eventHolder
    end

    function self.remove(unit)
        if _eventHolder[unit] == nil then
            return
        end
        _eventHolder[unit].unbindAll()
        _eventHolder[unit] = nil
    end

    setmetatable(self, mt)

    return self
end

Abilities = {}
Abilities.new = function(IEngine)
    local self = {}

    -- DEFAULT
    self.Sword_Slash = _Abilities.Sword_Slash.new(IEngine)
    self.Dodge = _Abilities.Dodge.new(IEngine)

    -- Nihility
    self.Blink_Strike = _Abilities.Blink_Strike.new(IEngine)
    self.Demon_Control = _Abilities.Demon_Control.new(IEngine)
    self.Blade_Dance = _Abilities.Blade_Dance.new(IEngine)

    self.Shadow_Strike = _Abilities.Shadow_Strike.new(IEngine)
    self.Nihility_Aura = _Abilities.Nihility_Aura.new(IEngine)

    -- Preservation
    self.Overload = _Abilities.Overload.new(IEngine)
    self.Impale = _Abilities.Impale.new(IEngine)
    self.Judgement = _Abilities.Judgement.new(IEngine)

    self.Heaven_Justice = _Abilities.Heaven_Justice.new(IEngine)
    self.Preservation_Aura = _Abilities.Preservation_Aura.new(IEngine)

    -- Harmony
    self.Magma_Constellation = _Abilities.Magma_Constellation.new(IEngine)
    self.Blizzard = _Abilities.Blizzard.new(IEngine)
    self.Uncontrollable_Flames = _Abilities.Uncontrollable_Flames.new(IEngine)

    self.Black_Hole = _Abilities.Black_Hole.new(IEngine)
    self.Harmony_Aura = _Abilities.Harmony_Aura.new(IEngine)

    -- Destruction
    self.Interceptor = _Abilities.Interceptor.new(IEngine)
    self.Sacred_Storm = _Abilities.Sacred_Storm.new(IEngine)
    self.Kingdom_Come = _Abilities.Kingdom_Come.new(IEngine)

    self.I_Am_Atomic = _Abilities.I_Am_Atomic.new(IEngine)
    self.Destruction_Aura = _Abilities.Destruction_Aura.new(IEngine)

    -- Erudition
    self.Erudition_Aura = _Abilities.Erudition_Aura.new(IEngine)

    -- Hunt
    self.Hunt_Aura = _Abilities.Hunt_Aura.new(IEngine)



    -- Leftovers
    -- self.Wolf = _Abilities.Wolf.new(IEngine)
    -- self.Bear = _Abilities.Bear.new(IEngine)
    -- self.Boar = _Abilities.Boar.new(IEngine)

    -- self.Reapers = _Abilities.Reapers.new(IEngine)

    -- self.Soul_Steal = _Abilities.Soul_Steal.new(IEngine)
    -- self.Hurricane_Constellation = _Abilities.Hurricane_Constellation.new(IEngine)

    return self
end

AreaConfiguration = {}
AreaConfiguration.new = function(disabled, skin, level, damage, health, armor, xp)
    local self = {}

    self.disabled = disabled or false
    self.creepSkin = skin
    self.creepLevel = level -- 1 | 20 | 35 | 50 | 65 | 80 Wenn Hero Level < Unit Level - 5 dann keine EXP und keine Stats! ; Maximal 20 Level über Creep, sonst keine XP
    self.creepDamage = damage -- 5 | 36 | 600 | 12.000 | 275.000 | 4.000.0000
    self.creepAttackspeed = 1.0
    self.creepMovementspeed = 340
    self.creepHealth = health -- 50 | 750 | 12.500 | 275.000 | 3.500.000 | 27.500.000
    self.creepArmor = armor -- 0 | 5 | 15 | 20 | 30 | 50
    self.creepLimit = 75
    self.creepXP = xp -- 5 | 20 | 60 | 450 | 2500 | 20000
    -- self.attackStacks = attackStacks -- 0.1 | 0.3 | 1.5 | 12.0 | 120.0 | 550.0
    -- self.healthStacks = healthStacks -- 0.2 | 0.6 | 3.0 | 24.0 | 240.0 | 1100.0

    self.bossSkin = 'h000'
    self.bossDamage = 1000
    self.bossAttackspeed = 0.7
    self.bossMovementspeed = 380
    self.bossHealth = 30000

    return self
end

Area = {}
Area.new = function(IEngine, rect, configuration)
    local self = {}
    local mt = {}

    self.configuration = configuration
    local clock = IEngine.Clock()
    local group = IEngine.Group()
    local enemyPlayer = IEngine.Player(PLAYER_NEUTRAL_AGGRESSIVE)
    
    local killcount = 0
    local bossSpawned = false
    local bossSpawnDisabled = false
    local BOSS_SPAWN_AMOUNT = 1000

    self.x = GetRectCenterX(rect)
    self.y = GetRectCenterY(rect)
    self.minX = GetRectMinX(rect)
    self.minY = GetRectMinY(rect)
    self.maxX = GetRectMaxX(rect)
    self.maxY = GetRectMaxY(rect)

    function mt.__newindex(table, index, value)
        if index == "killcount" then
            killcount = value
            --print(killcount)
            if killcount >= BOSS_SPAWN_AMOUNT and not bossSpawnDisabled then
                --print("boss spawned")
                self.spawnBoss()
            end
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    function mt.__index(table, index)
        if index == "killcount" then
            return killcount
        else
            IEngine.Log.Error("Unknown attribute '" .. index .. "'.")
        end
    end

    function self.removeAllEnemies()
        group
            .inRect(rect)
            .forEach(
                function(group, enumUnit)
                    if enumUnit.owner == enemyPlayer then
                        enumUnit.remove()
                    end
                end
            )
    end

    function self.spawnBoss()
        bossSpawned = true
        self.removeAllEnemies()
        -- Todo: spawn boss
    end

    function self.getRandomX()
        return math.random(self.minX + 2000., self.maxX - 2000.)
    end

    function self.getRandomY()
        return math.random(self.minY + 2000., self.maxY - 2000.)
    end

    function self.spawnUnit(unit)

        if bossSpawned then
            return
        end

        if unit == nil then
            local unit = enemyPlayer.createUnit('unit', self.getRandomX(), self.getRandomY(), math.random(0, 360))
            unit.skin = self.configuration.creepSkin
            unit.damage = self.configuration.creepDamage
            unit.attackspeed = self.configuration.creepAttackspeed
            unit.ms = self.configuration.creepMovementspeed
            unit.maxhp = self.configuration.creepHealth
            unit.hp = self.configuration.creepHealth
            unit.level = self.configuration.creepLevel
            unit.armor = self.configuration.creepArmor
            local xp = self.configuration.creepXP
            unit.bind("on_death_pre",
                function(source, target, damageObject)
                    damageObject.damage = 0
                    unit.addAbility('Aloc')
                    unit.invulnerable = true
                    unit.pause = true
                    unit.playAnimation("death")

                    group
                        .inRect(rect)
                        .forEach(
                            function(group, enumUnit)
                                if enumUnit.owner == enemyPlayer then
                                    return
                                end
                                if enumUnit.level >= unit.level + 20 then
                                    return
                                end
                                if enumUnit.level < unit.level - 5 then
                                    return
                                end
                                enumUnit.xp = enumUnit.xp + xp
                            end
                        )

                    self.killcount = self.killcount + 1
                    clock.schedule_once(
                        function(triggeringClock, triggeringSchedule)
                            unit.visible = false
                            self.spawnUnit(unit)
                        end, math.random(2.0, 3.0)
                    )
                end
            ).setCondition(
                function(source, target, damageObject)
                    return target == unit
                end
            )
        else
            if unit.handle == nil then
                return
            end
            unit.x = self.getRandomX()
            unit.y = self.getRandomY()
            unit.face = math.random(0, 360)
            unit.removeAbility('Aloc')
            unit.invulnerable = false
            unit.pause = false
            unit.visible = true
            unit.playAnimation("stand")
        end
    end

    function self.contains(unit)
        return group
            .inRect(rect)
            .inGroup(unit)
    end

    function self.enter(unit)
        if configuration.disabled then
            print("Area is currently disabled.")
            return
        end
        if self.contains(unit) then
            return
        end
        unit.teleportTo(self.x, self.y)

        local change = 2500.
        unit.owner.setCameraBounds(
            self.minX + change, self.minY + change, 
            self.minX + change, self.maxY - change, 
            self.maxX - change, self.maxY - change, 
            self.maxX - change, self.minY + change
        )
        unit.owner.setCameraPosition(self.x, self.y)
    end

    function self.reset()
        self.removeAllEnemies()
        for _ = 0, configuration.creepLimit, 1 do
            self.spawnUnit()
        end
    end

    setmetatable(self, mt)

    self.reset()

    clock.start()

    return self
end

AttributeSystem = {}
AttributeSystem.new = function(unit)
    local self = {}

    local SKILL_POINTS_BASE = 100
    local SKILL_POINTS_PER_LEVEL = 5
    --local informationAbility = BlzGetUnitAbility(unit.handle, FourCC('AATR'))
    local skillPoints = SKILL_POINTS_BASE + (unit.level - 1) * SKILL_POINTS_PER_LEVEL

    local BASE_ATTACK = 10
    local BASE_ATTACKSPEED = 0.7
    local BASE_MOVEMENTSPEED = 270
    local BASE_HEALTH = 100
    local BASE_ARMOR = 0

    local str = 0
    local vit = 0
    local agi = 0
    local int = 0

    local bonusStr = 0 -- Used for items & passives later on
    local bonusVit = 0 -- Used for items & passives later on
    local bonusAgi = 0 -- Used for items & passives later on
    local bonusInt = 0 -- Used for items & passives later on

    local damageStacks = 0
    local healthStacks = 0

    while unit.skillPoints > skillPoints do
        UnitModifySkillPoints(unit.handle, -1)
    end
    while unit.skillPoints < skillPoints do
        UnitModifySkillPoints(unit.handle, 1)
    end

    unit.bind("on_level",
        function(unit)
            skillPoints = skillPoints + SKILL_POINTS_PER_LEVEL
            --print("Current Skill Points: " .. skillPoints)
            while unit.skillPoints > skillPoints do
                UnitModifySkillPoints(unit.handle, -1)
            end
            while unit.skillPoints < skillPoints do
                UnitModifySkillPoints(unit.handle, 1)
            end
        end
    )

    function self.statBonusString(stat)
        if stat == "str" then
            if bonusStr == 0 then
                return "|c00808080 + 0" .. "|r"
            elseif bonusStr > 0 then
                return "|c0000FF00 + " .. bonusStr .. "|r"
            else
                return "|c00FF0000 - " .. (bonusStr * -1) .. "|r"
            end
        elseif stat == "vit" then
            if bonusVit == 0 then
                return "|c00808080 + 0" .. "|r"
            elseif bonusVit > 0 then
                return "|c0000FF00 + " .. bonusVit .. "|r"
            else
                return "|c00FF0000 - " .. (bonusVit * -1) .. "|r"
            end
        elseif stat == "agi" then
            if bonusAgi == 0 then
                return "|c00808080 + 0" .. "|r"
            elseif bonusAgi > 0 then
                return "|c0000FF00 + " .. bonusAgi .. "|r"
            else
                return "|c00FF0000 - " .. (bonusAgi * -1) .. "|r"
            end
        elseif stat == "int" then
            if bonusInt == 0 then
                return "|c00808080 + 0" .. "|r"
            elseif bonusInt > 0 then
                return "|c0000FF00 + " .. bonusInt .. "|r"
            else
                return "|c00FF0000 - " .. (bonusInt * -1) .. "|r"
            end
        end
    end

    function self.statString(stat)
        if stat == "str" then
            return "STR: " .. str .. self.statBonusString(stat) ..
                "\n - Each point increases physical damage by 2%%"
        elseif stat == "vit" then
            return "VIT: " .. vit .. self.statBonusString(stat) ..
                "\n - Each point increases armor by 1" ..
                "\n - Each point increases health by 2%%"
        elseif stat == "agi" then
            return "AGI: " .. agi .. self.statBonusString(stat) ..
                "\n - Each point increases attack speed by 2%%" ..
                "\n - Each point increases movement speed by 0.5%%"
        elseif stat == "int" then
            return "INT: " .. int .. self.statBonusString(stat) ..
                "\n - Each point increases magical damage by 2%%"
        end
    end

    function self.updateStats()
        local ATTACKSPEED_FACTOR = 0.02
        local MOVEMENTSPEED_FACTOR = 0.005
        local HEALTH_FACTOR = 0.02
        local ARMOR_FACTOR = 1

        -- NO CATEGORY
        unit.damage = BASE_ATTACK + damageStacks

        -- STR related
        -- Calculated on damage

        -- VIT related
        unit.maxhp = (BASE_HEALTH + healthStacks) * (1 + HEALTH_FACTOR * vit)
        unit.armor = BASE_ARMOR + (ARMOR_FACTOR * vit)

        -- AGI related
        unit.attackspeed = BASE_ATTACKSPEED * (1 + ATTACKSPEED_FACTOR * agi)
        unit.ms = BASE_MOVEMENTSPEED * (1 + MOVEMENTSPEED_FACTOR * agi)

        -- INT related
        -- Calculated on damage

    end

    function self.updateVisual()
        local tooltip = BlzGetAbilityExtendedTooltip(FourCC('AATR'), 0)
        if unit.owner.isLocal() then
            tooltip = 
                self.statString('str') .. "\n" ..
                self.statString('vit') .. "\n" ..
                self.statString('agi') .. "\n" ..
                self.statString('int') .. "\n"
        end
        BlzSetAbilityExtendedTooltip(FourCC('AATR'), tooltip, 0)
        --BlzSetAbilityStringLevelField(informationAbility, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1, "test")
    end

    unit.bind("on_skill",
        function(unit, abilityId)
            --local ability = BlzGetUnitAbility(unit.handle, abilityId)
            --local currentLevel = BlzGetAbilityIntegerField(ability, ABILITY_IF_LEVELS)
            --print(currentLevel)
            --BlzSetAbilityIntegerField(ability, ABILITY_IF_LEVELS, currentLevel + 1)
            if unit.getAbilityLevel(abilityId) == 2 then
                DecUnitAbilityLevel(unit.handle, abilityId)
            end
            skillPoints = skillPoints - 1
            --print("Current Skill Points: " .. skillPoints)

            if abilityId == FourCC('ASTR') then
                str = str + 1
            elseif abilityId == FourCC('AVIT') then
                vit = vit + 1
            elseif abilityId == FourCC('AAGI') then
                agi = agi + 1
            elseif abilityId == FourCC('AINT') then
                int = int + 1
            end
            self.updateVisual()
            self.updateStats()
        end
    )

    unit.bind("on_damage_after",
        function(source, target, damageObject)
            local dataTable = {
                [1] = {
                    ['level'] = 1,
                    ['damage'] = 0.1,
                    ['health'] = 0.2,
                    ['damageUpper'] = 50,
                    ['healthUpper'] = 100
                },
                [2] = {
                    ['level'] = 20,
                    ['damage'] = 0.3,
                    ['health'] = 0.6,
                    ['damageUpper'] = 750,
                    ['healthUpper'] = 1500
                },
                [3] = {
                    ['level'] = 35,
                    ['damage'] = 1.5,
                    ['health'] = 3.0,
                    ['damageUpper'] = 12500,
                    ['healthUpper'] = 25000
                },
                [4] = {
                    ['level'] = 50,
                    ['damage'] = 12,
                    ['health'] = 24,
                    ['damageUpper'] = 275000,
                    ['healthUpper'] = 550000
                },
                [5] = {
                    ['level'] = 65,
                    ['damage'] = 120,
                    ['health'] = 240,
                    ['damageUpper'] = 3500000,
                    ['healthUpper'] = 7000000
                },
                [6] = {
                    ['level'] = 80,
                    ['damage'] = 550,
                    ['health'] = 1100,
                    ['damageUpper'] = 27500000,
                    ['healthUpper'] = 50000000
                }
            }

            if target.level > source.level + 5 then
                -- Player is more than 5 levels below
                return
            end
            for _, data in ipairs(dataTable) do
                if target.level == data['level'] then
                    if damageStacks < data['damageUpper'] then
                        if damageStacks + data['damage'] > data['damageUpper'] then
                            damageStacks = data['damageUpper']
                        else
                            damageStacks = damageStacks + data['damage']
                        end
                    end
                    if healthStacks < data['healthUpper'] then
                        if healthStacks + data['health'] > data['healthUpper'] then
                            healthStacks = data['healthUpper']
                        else
                            healthStacks = healthStacks + data['health']
                        end
                    end
                    break
                end
            end
            
            self.updateStats()
        end
    ).setCondition(
        function(source, target, damageObject)
            return source == unit
        end
    )

    self.updateVisual()
    self.updateStats()

    return self
end

function onInit()
xpcall(function()

    -- Hide Hero Attributes
    do
        local parentDummy
        -- can not be used on Texture/String
        function HideSimpleFramePerma(frame)
            if not parentDummy then
                parentDummy = BlzCreateFrameByType("SIMPLEFRAME", "", BlzGetFrameByName("ConsoleUI", 0), "", 0)
                BlzFrameSetVisible(parentDummy, false)
            end
            BlzFrameSetParent(frame, parentDummy)
        end
    end
    HideSimpleFramePerma(BlzGetFrameByName("SimpleInfoPanelIconAlly", 7))
    HideSimpleFramePerma(BlzGetFrameByName("SimpleInfoPanelIconHeroText", 6))
    BlzFrameSetSize(BlzGetFrameByName("InfoPanelIconHeroIcon", 6), 0.00001, 0.00001)

    -- Initiate Framework
    Framework = Engine.new()
    Ability = Abilities.new(Framework)

    local neutralPlayer = Framework.Player(PLAYER_NEUTRAL_PASSIVE)
    
    local teleporter = neutralPlayer.createUnit('hTel', GetRectCenterX(gg_rct_Teleporter), GetRectCenterY(gg_rct_Teleporter), 270.) 
    teleporter.skin = 'hPai'
    teleporter.invulnerable = true

    local aeonRequirements = {
        [1] = {
            ["name"] = "Destruction",
            ["description"] = "You chose the path of "
            .. "|cfffa795dD|r|cfff87158e|r|cfff66953s|r|cfff4624et|r|cfff25a49r|r|cfff05344u|r|cffee4b3fc|r|cffec443at|r|cffea3c35i|r|cffe83531o|r|cffe62d2cn|r.",
            ["icon"] = "ReplaceableTextures/CommandButtons/BTNDestructionPath.blp",
            ["unlocks"] = Ability.I_Am_Atomic,
            ["aura"] = Ability.Destruction_Aura,
            ["requires"] = {
                [1] = Ability.Interceptor,
                [2] = Ability.Sacred_Storm,
                [3] = Ability.Kingdom_Come
            },
            ["disabled"] = false
        },
        [2] = {
            ["name"] = "Preservation",
            ["description"] = "You chose the path of "
            .. "|cffa9e8f9P|r|cff9de0f5r|r|cff91d8f2e|r|cff86d0efs|r|cff7ac9ebe|r|cff6fc1e8r|r|cff62b9e4v|r|cff57b1e1a|r|cff4ba9det|r|cff40a2dai|r|cff349ad7o|r|cff2892d4n|r.",
            ["icon"] = "ReplaceableTextures/CommandButtons/BTNPreservationPath.blp",
            ["unlocks"] = Ability.Heaven_Justice,
            ["aura"] = Ability.Preservation_Aura,
            ["requires"] = {
                [1] = Ability.Impale,
                [2] = Ability.Judgement,
                [3] = Ability.Overload
            },
            ["disabled"] = false
        },
        [3] = {
            ["name"] = "Nihility",
            ["description"] = "You chose the path of "
            .. "|cffe182f9N|r|cffdb7af3i|r|cffd573eeh|r|cffcf6be9i|r|cffc963e4l|r|cffc35cdfi|r|cffbd54dat|r|cffb74dd5y|r.",
            ["icon"] = "ReplaceableTextures/CommandButtons/BTNNihilityPath.blp",
            ["unlocks"] = Ability.Shadow_Strike,
            ["aura"] = Ability.Nihility_Aura,
            ["requires"] = {
                [1] = Ability.Blade_Dance,
                [2] = Ability.Blink_Strike,
                [3] = Ability.Demon_Control
            },
            ["disabled"] = false
        },
        [4] = {
            ["name"] = "Harmony",
            ["description"] = "You chose the path of "
            .. "|cffff0000H|r|cffaa0054a|r|cff5500a9r|r|cff0000fem|r|cff0054aao|r|cff00a955n|r|cff00fe00y|r.",
            ["icon"] = "ReplaceableTextures/CommandButtons/BTNHarmonyPath.blp",
            ["unlocks"] = Ability.Black_Hole,
            ["aura"] = Ability.Harmony_Aura,
            ["requires"] = {
                [1] = Ability.Magma_Constellation,
                [2] = Ability.Blizzard,
                [3] = Ability.Uncontrollable_Flames
            },
            ["disabled"] = false
        },
        [5] = {
            ["name"] = "Erudition",
            ["description"] = "You chose the path of "
            .. "|cffbcbcf6E|r|cffafaeefr|r|cffa2a0e8u|r|cff9592e1d|r|cff8783dai|r|cff7a75d3t|r|cff6d67cci|r|cff6059c6o|r|cff534bbfn|r.",
            ["icon"] = "ReplaceableTextures/CommandButtons/BTNEruditionPath.blp",
            ["unlocks"] = nil,
            ["aura"] = Ability.Erudition_Aura,
            ["requires"] = {
                [1] = nil,
                [2] = nil,
                [3] = nil
            },
            ["disabled"] = true
        },
        [6] = {
            ["name"] = "Hunt",
            ["description"] = "You chose the path of "
            .. "|cffaae5b7H|r|cff89daa9u|r|cff69d09bn|r|cff49c68et|r.",
            ["icon"] = "ReplaceableTextures/CommandButtons/BTNHuntPath.blp",
            ["unlocks"] = nil,
            ["aura"] = Ability.Hunt_Aura,
            ["requires"] = {
                [1] = nil,
                [2] = nil,
                [3] = nil
            },
            ["disabled"] = true
        }
    }

    local orbMetaData = {
        [1] = {
            ["base"] = 'hAS1',
            ["skin"] = 'h00Q', -- Light
            ["abil"] = 'APB1',
            ["abilities"] = {
                [1] = {
                    ["code"] = Ability.Impale,
                    ["shop"] = 'IA11',
                    ["disabled"] = false
                },
                [2] = {
                    ["code"] = Ability.Interceptor,
                    ["shop"] = 'IA12',
                    ["disabled"] = false
                },
                [3] = {
                    ["code"] = Ability.Magma_Constellation,
                    ["shop"] = 'IA13',
                    ["disabled"] = false
                },
            }
        },
        [2] = {
            ["base"] = 'hAS2',
            ["skin"] = 'h00M', -- Poison
            ["abil"] = 'APB2',
            ["abilities"] = {
                [1] = {
                    ["code"] = Ability.Blizzard,
                    ["shop"] = 'IA21',
                    ["disabled"] = false
                },
                [2] = {
                    ["code"] = nil,
                    ["shop"] = 'IA22',
                    ["disabled"] = true
                },
                [3] = {
                    ["code"] = Ability.Blade_Dance,
                    ["shop"] = 'IA23',
                    ["disabled"] = false
                },
            }
        },
        [3] = {
            ["base"] = 'hAS3',
            ["skin"] = 'h00O', -- Dragon
            ["abil"] = 'APB3',
            ["abilities"] = {
                [1] = {
                    ["code"] = Ability.Judgement,
                    ["shop"] = 'IA31',
                    ["disabled"] = false
                },
                [2] = {
                    ["code"] = nil,
                    ["shop"] = 'IA32',
                    ["disabled"] = true
                },
                [3] = {
                    ["code"] = Ability.Blink_Strike,
                    ["shop"] = 'IA33',
                    ["disabled"] = false
                },
            }
        },
        [4] = {
            ["base"] = 'hAS4',
            ["skin"] = 'h00P', -- Darkness
            ["abil"] = 'APB4',
            ["abilities"] = {
                [1] = {
                    ["code"] = Ability.Overload,
                    ["shop"] = 'IA41',
                    ["disabled"] = false
                },
                [2] = {
                    ["code"] = nil,
                    ["shop"] = 'IA42',
                    ["disabled"] = true
                },
                [3] = {
                    ["code"] = nil,
                    ["shop"] = 'IA43',
                    ["disabled"] = true
                },
            }
        },
        [5] = {
            ["base"] = 'hAS5',
            ["skin"] = 'h00L', -- Ice
            ["abil"] = 'APB5',
            ["abilities"] = {
                [1] = {
                    ["code"] = Ability.Uncontrollable_Flames,
                    ["shop"] = 'IA51',
                    ["disabled"] = false
                },
                [2] = {
                    ["code"] = nil,
                    ["shop"] = 'IA52',
                    ["disabled"] = true
                },
                [3] = {
                    ["code"] = Ability.Sacred_Storm,
                    ["shop"] = 'IA53',
                    ["disabled"] = false
                },
            }
        },
        [6] = {
            ["base"] = 'hAS6',
            ["skin"] = 'h00N', -- Fire
            ["abil"] = 'APB6',
            ["abilities"] = {
                [1] = {
                    ["code"] = Ability.Kingdom_Come,
                    ["shop"] = 'IA61',
                    ["disabled"] = false
                },
                [2] = {
                    ["code"] = nil,
                    ["shop"] = 'IA62',
                    ["disabled"] = true
                },
                [3] = {
                    ["code"] = Ability.Demon_Control,
                    ["shop"] = 'IA63',
                    ["disabled"] = false
                },
            }
        }
    }

    local orbs = {}
    for index, orbMeta in ipairs(orbMetaData) do
        local rad = index * 2 * math.pi / 6
        local x = Framework.Player(0).startPositionX + 500. * math.cos(rad)
        local y = Framework.Player(0).startPositionY + 500. * math.sin(rad)
        local orb = Framework.Player(PLAYER_NEUTRAL_PASSIVE).createUnit(orbMeta['base'], x, y, 270.)
        orb.skin = orbMeta['skin']
        orb.invulnerable = true
        orb.visible = false -- Set to true when required boss dies
        orbs[index] = orb
    end

    local areaConfigurations = {
        [1] = AreaConfiguration.new(false, 'h007', 1, 5, 50, 0, 5),
        [2] = AreaConfiguration.new(true, 'h007', 20, 36, 750, 5, 20),
        [3] = AreaConfiguration.new(true, 'h007', 35, 600, 12500, 15, 60),
        [4] = AreaConfiguration.new(true, 'h007', 50, 12000, 275000, 20, 450),
        [5] = AreaConfiguration.new(true, 'h007', 65, 275000, 3500000, 30, 2500),
        [6] = AreaConfiguration.new(true, 'h007', 80, 4000000, 27500000, 50, 20000)
    }

    local areas = {
        ['I000'] = Area.new(Framework, gg_rct_Bottom_Left_Room_BL, areaConfigurations[1]),
        ['I001'] = Area.new(Framework, gg_rct_Bottom_Left_Room_BR, areaConfigurations[2]),
        ['I002'] = Area.new(Framework, gg_rct_Bottom_Left_Room_TL, areaConfigurations[3]),
        ['I003'] = Area.new(Framework, gg_rct_Bottom_Right_Room_BL, areaConfigurations[4]),
        ['I004'] = Area.new(Framework, gg_rct_Bottom_Right_Room_BR, areaConfigurations[5]),
        ['I005'] = Area.new(Framework, gg_rct_Bottom_Right_Room_TR, areaConfigurations[6])
    }

    local MAX_PLAYERS = 8
    for pId = 0, MAX_PLAYERS, 1 do
        -- Edit player
        local player = Framework.Player(pId)
        if player.state == PLAYER_SLOT_STATE_PLAYING and player.controller == MAP_CONTROL_USER then
            -- Camera Settings
            FogModifierStart(CreateFogModifierRect(player.handle, FOG_OF_WAR_VISIBLE, GetPlayableMapRect(), false, false))
            local change = 2500.
            player.setCameraBounds(
                player.startPositionX - change, player.startPositionY - change, 
                player.startPositionX - change, player.startPositionY + change, 
                player.startPositionX + change, player.startPositionY + change, 
                player.startPositionX + change, player.startPositionY - change
            )
            player.setCameraField(CAMERA_FIELD_TARGET_DISTANCE, 2250., 0.)

            -- Prepare Player Unit
            local rad = pId * (math.pi * 2 / MAX_PLAYERS)
            local x = player.startPositionX + 350.0 * math.cos(rad)
            local y = player.startPositionY + 350.0 * math.sin(rad)
            local unit = player.createUnit('Hero', x, y, bj_RADTODEG * (rad + math.pi))

            -- Force Base Stats
            unit.propername = player.name
            unit.skin = 'h006'
            unit.damage = 1

            -- Init Attribute System
            local attributeSys = AttributeSystem.new(unit)

            local abilitySelection = {}
            local pathChosen = nil
            for index, orb in ipairs(orbMetaData) do
                for _, ability in ipairs(orb["abilities"]) do
                    unit.bind("on_pickup_item",
                        function(unit, item)
                            -- Store Item Metadata and then Delete Item
                            local name = BlzGetItemTooltip(item)
                            local description = BlzGetItemExtendedTooltip(item)
                            local icon = BlzGetItemIconPath(item)
                            RemoveItem(item)

                            -- Conditions
                            if abilitySelection[index] ~= nil then
                                print("You already selected an ability from this boss.")
                                return
                            end
                            if ability["disabled"] then
                                print("This ability is currently disabled, please select a different one.")
                                return
                            end

                            -- Store current ability data
                            local _name = BlzGetAbilityTooltip(FourCC(orb['abil']), 0)
                            local _description = BlzGetAbilityExtendedTooltip(FourCC(orb['abil']), 0)
                            local _icon = BlzGetAbilityIcon(FourCC(orb['abil']))
                            -- Update for local
                            if unit.owner.isLocal() then
                                _name = ability["code"].metadata.name
                                _description = ability["code"].metadata.description
                                _icon = ability["code"].metadata.icon
                            end
                            -- Update ability
                            BlzSetAbilityTooltip(FourCC(orb['abil']), _name, 0)
                            BlzSetAbilityExtendedTooltip(FourCC(orb['abil']), _description, 0)
                            BlzSetAbilityIcon(FourCC(orb['abil']), _icon)

                            abilitySelection[index] = ability["code"]
                            ability["code"].apply(unit)

                            if pathChosen ~= nil then
                                return
                            end

                            -- Check for Aeon
                            for _, aeon in ipairs(aeonRequirements) do
                                if aeon['disabled'] then
                                    goto continue
                                end
                                local criteriaFulfilled = true
                                for _, requirement in ipairs(aeon['requires']) do
                                    local found = false
                                    for _, unlockedAbility in pairs(abilitySelection) do
                                        if unlockedAbility == requirement then 
                                            found = true
                                            break
                                        end
                                    end
                                    if not found then
                                        criteriaFulfilled = false
                                        break
                                    end
                                end
                                if criteriaFulfilled then
                                    print("You've chosen the Path '" .. aeon['name'] .. "'")
                                    pathChosen = aeon

                                    --- Ability
                                    aeon['unlocks'].apply(unit)

                                    --- Aura
                                    aeon['aura'].apply(unit)

                                    --- Path Spellbook
                                    -- Store current ability data
                                    local _name = BlzGetAbilityTooltip(FourCC('ASBA'), 0)
                                    local _description = BlzGetAbilityExtendedTooltip(FourCC('ASBA'), 0)
                                    local _icon = BlzGetAbilityIcon(FourCC('ASBA'))
                                    -- Update for local
                                    if unit.owner.isLocal() then
                                        _name = "Path: " .. aeon['name']
                                        _description = aeon['description']
                                        _icon = aeon['icon']
                                    end
                                    -- Update ability
                                    BlzSetAbilityTooltip(FourCC('ASBA'), _name, 0)
                                    BlzSetAbilityExtendedTooltip(FourCC('ASBA'), _description, 0)
                                    BlzSetAbilityIcon(FourCC('ASBA'), _icon)

                                    --- Aeon Ability
                                    -- Store current ability data
                                    local _name = BlzGetAbilityTooltip(FourCC('APBX'), 0)
                                    local _description = BlzGetAbilityExtendedTooltip(FourCC('APBX'), 0)
                                    local _icon = BlzGetAbilityIcon(FourCC('APBX'))
                                    -- Update for local
                                    if unit.owner.isLocal() then
                                        _name = aeon['unlocks'].metadata.name
                                        _description = aeon['unlocks'].metadata.description
                                        _icon = aeon['unlocks'].metadata.icon
                                    end
                                    -- Update ability
                                    BlzSetAbilityTooltip(FourCC('APBX'), _name, 0)
                                    BlzSetAbilityExtendedTooltip(FourCC('APBX'), _description, 0)
                                    BlzSetAbilityIcon(FourCC('APBX'), _icon)
                                end
                                ::continue::
                            end
                        end
                    ).setCondition(
                        function(unit, item)
                            return GetItemTypeId(item) == FourCC(ability["shop"])
                        end
                    )
                end
            end

            for itemId, area in pairs(areas) do
                unit.bind("on_pickup_item",
                    function(unit, item)
                        RemoveItem(item)

                        area.enter(unit)
                    end
                ).setCondition(
                    function(unit, item)
                        return GetItemTypeId(item) == FourCC(itemId)
                    end
                )
            end

            unit.bind("on_death",
                function(unit)
                    unit.respawn(player.startPositionX, player.startPositionY)
                    unit.teleportTo(x, y)

                    local change = 2500.
                    unit.owner.setCameraBounds(
                        player.startPositionX - change, player.startPositionY - change, 
                        player.startPositionX - change, player.startPositionY + change, 
                        player.startPositionX + change, player.startPositionY + change, 
                        player.startPositionX + change, player.startPositionY - change
                    )
                    unit.owner.setCameraPosition(x, y)
                end
            )

            player.bind("on_message",
                function(player, message)
                    unit.teleportTo(x, y)
                    
                    local change = 2500.
                    unit.owner.setCameraBounds(
                        player.startPositionX - change, player.startPositionY - change, 
                        player.startPositionX - change, player.startPositionY + change, 
                        player.startPositionX + change, player.startPositionY + change, 
                        player.startPositionX + change, player.startPositionY - change
                    )
                    unit.owner.setCameraPosition(x, y)
                end
            ).setCondition(
                function(player, message)
                    return message == "0"
                end
            )

            player.bind("on_leave", 
                function(player)
                    print("player leave")
                    print("name: " .. player.name)
                    print("id: " .. player.id)
                end
            )

            -- Default Abilities
            Ability.Sword_Slash.apply(unit)
            Ability.Dodge.apply(unit)

            player.bind("on_message",
                function(player, message)
                    local whichAbility = StringCase(SubString(message, 5, StringLength(message)), false)
                    -- SUMMONER (Currently disabled)
                    -- if whichAbility == 'boar' then
                    --     Ability.Boar.apply(unit)
                    -- elseif whichAbility == 'wolf' then
                    --     Ability.Wolf.apply(unit)
                    -- elseif whichAbility == 'bear' then
                    --     Ability.Bear.apply(unit)
                    -- elseif whichAbility == 'reapers' then
                    --     Ability.Reapers.apply(unit)
                    -- DEMON (Works)
                    if whichAbility == 'blade dance' then
                        Ability.Blade_Dance.apply(unit)
                    elseif whichAbility == 'blink strike' then
                        Ability.Blink_Strike.apply(unit)
                    elseif whichAbility == 'demon control' then
                        Ability.Demon_Control.apply(unit)
                    elseif whichAbility == 'shadow strike' then
                        Ability.Shadow_Strike.apply(unit, Ability)
                    -- HOLY (Works)
                    elseif whichAbility == 'impale' then
                        Ability.Impale.apply(unit)
                    elseif whichAbility == 'judgement' then
                        Ability.Judgement.apply(unit)
                    elseif whichAbility == 'overload' then
                        Ability.Overload.apply(unit)
                    elseif whichAbility == 'heaven justice' then
                        Ability.Heaven_Justice.apply(unit)
                    -- DESTROYER (Works)
                    elseif whichAbility == 'interceptor' then
                        Ability.Interceptor.apply(unit)
                    elseif whichAbility == 'sacred storm' then
                        Ability.Sacred_Storm.apply(unit)
                    elseif whichAbility == 'kingdom come' then
                        Ability.Kingdom_Come.apply(unit)
                    elseif whichAbility == 'i am atomic' then
                        Ability.I_Am_Atomic.apply(unit)
                    -- ELEMENTS (Works)
                    elseif whichAbility == 'magma constellation' then
                        Ability.Magma_Constellation.apply(unit)
                    elseif whichAbility == 'blizzard' then
                        Ability.Blizzard.apply(unit)
                    elseif whichAbility == 'uncontrollable flames' then
                        Ability.Uncontrollable_Flames.apply(unit)
                    elseif whichAbility == 'black hole' then
                        Ability.Black_Hole.apply(unit)
                    end
                    print("Executed " .. message)
                end
            ).setCondition(
                function(player, message)
                    return SubString(message, 0, 4) == "-add"
                end
            )

            player.bind("on_message",
                function(player, message)
                    local whichAbility = StringCase(SubString(message, 8, StringLength(message)), false)
                    -- SUMMONER (Currently disabled)
                    -- if whichAbility == 'boar' then
                    --     Ability.Boar.remove(unit)
                    -- elseif whichAbility == 'wolf' then
                    --     Ability.Wolf.remove(unit)
                    -- elseif whichAbility == 'bear' then
                    --     Ability.Bear.remove(unit)
                    -- elseif whichAbility == 'reapers' then
                    --     Ability.Reapers.remove(unit)
                    -- DEMON (Works)
                    if whichAbility == 'blade dance' then
                        Ability.Blade_Dance.remove(unit)
                    elseif whichAbility == 'blink strike' then
                        Ability.Blink_Strike.remove(unit)
                    elseif whichAbility == 'demon control' then
                        Ability.Demon_Control.remove(unit)
                    elseif whichAbility == 'shadow strike' then
                        Ability.Shadow_Strike.remove(unit)
                    -- HOLY (Works)
                    elseif whichAbility == 'impale' then
                        Ability.Impale.remove(unit)
                    elseif whichAbility == 'judgement' then
                        Ability.Judgement.remove(unit)
                    elseif whichAbility == 'overload' then
                        Ability.Overload.remove(unit)
                    elseif whichAbility == 'heaven justice' then
                        Ability.Heaven_Justice.remove(unit)
                    -- DESTROYER (Works)
                    elseif whichAbility == 'interceptor' then
                        Ability.Interceptor.remove(unit)
                    elseif whichAbility == 'sacred storm' then
                        Ability.Sacred_Storm.remove(unit)
                    elseif whichAbility == 'kingdom come' then
                        Ability.Kingdom_Come.remove(unit)
                    elseif whichAbility == 'i am atomic' then
                        Ability.I_Am_Atomic.remove(unit)
                    -- ELEMENTS (Works)
                    elseif whichAbility == 'magma constellation' then
                        Ability.Magma_Constellation.remove(unit)
                    elseif whichAbility == 'blizzard' then
                        Ability.Blizzard.remove(unit)
                    elseif whichAbility == 'uncontrollable flames' then
                        Ability.Uncontrollable_Flames.remove(unit)
                    elseif whichAbility == 'black hole' then
                        Ability.Black_Hole.remove(unit)
                    end
                    print("Executed " .. message)
                end
            ).setCondition(
                function(player, message)
                    return SubString(message, 0, 7) == "-remove"
                end
            )

            player.bind("on_message",
                function(player, message)
                    local whichAbility = StringCase(SubString(message, 6, StringLength(message)), false)
                    if whichAbility == '1' then
                        orbs[1].visible = true
                    elseif whichAbility == '2' then
                        orbs[2].visible = true
                    elseif whichAbility == '3' then
                        orbs[3].visible = true
                    elseif whichAbility == '4' then
                        orbs[4].visible = true
                    elseif whichAbility == '5' then
                        orbs[5].visible = true
                    elseif whichAbility == '6' then
                        orbs[6].visible = true
                    end
                    print("Executed " .. message)
                end
            ).setCondition(
                function(player, message)
                    return SubString(message, 0, 5) == "-dead"
                end
            )

            player.bind("on_message",
                function(player, message)
                    local level = S2I(SubString(message, 7, StringLength(message)))
                    unit.level = level
                    print("Executed " .. message)
                end
            ).setCondition(
                function(player, message)
                    return SubString(message, 0, 6) == "-level"
                end
            )

            player.bind("on_message",
                function(player, message)
                    local damage = S2I(SubString(message, 8, StringLength(message)))
                    unit.damage = damage
                    print("Executed " .. message)
                end
            ).setCondition(
                function(player, message)
                    return SubString(message, 0, 7) == "-damage"
                end
            )

            -- player.bind("on_message",
            --     function(player, message)
            --         local alpha = S2I(SubString(message, 7, StringLength(message)))
            --         if alpha > 255 then
            --             alpha = 255
            --         elseif alpha < 0 then
            --             alpha = 0
            --         end
            --         Framework.Configuration.User(player.id).Effects.Transparency.Global = alpha
            --         print("Executed " .. message)
            --     end
            -- ).setCondition(
            --     function(player, message)
            --         return SubString(message, 0, 6) == "-alpha"
            --     end
            -- )

            

            -- native BlzSetSpecialEffectAlpha                    takes effect whichEffect, integer alpha returns nothing
        end
    end

    -- if player.state == PLAYER_SLOT_STATE_PLAYING and player.controller == MAP_CONTROL_USER then
    --     player.setCameraField(CAMERA_FIELD_TARGET_DISTANCE, 2250., 0.)
    --     local unit = player.createUnit('H000', GetRectCenterX(gg_rct_Example_Spawn), GetRectCenterY(gg_rct_Example_Spawn), 270.)
    --     unit.maxhp = 570
    --     unit.hp = 326
    --     unit.damage = 150
    --     unit.agi = 100
    --     unit.attackspeed = 4.0
    --     unit.ms = 800
    --     unit.level = 10
    --     effect = Framework.Effect()
    --     effect.model = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl"
    --     unit.bind("on_death",
    --         function(unit)
    --             unit.respawn(GetRectCenterX(gg_rct_Example_Spawn), GetRectCenterY(gg_rct_Example_Spawn))
    --             effect.x = unit.x
    --             effect.y = unit.y
    --             effect.create().destroy()
    --         end
    --     ).setCondition(
    --         function(unit)
    --             return unit.owner == player
    --         end
    --     )

    --     --effect = Effect()
    --     --effect.model = "Auras\\Fountain of Souls.mdx"
    --     --unit.attachEffect(effect, "origin")

    --     effect = Framework.Effect()
    --     effect.model = "Effects\\Wings.mdx"
    --     unit.attachEffect(effect, "chest")

    --     --effect = Effect()
    --     --effect.model = "Effects\\Ubershield Azure.mdx"
    --     --unit.attachEffect(effect, "chest")
        
    --     --unit.bind("on_damaged_pre",
    --     --    function(source, target, attack)
    --     --        print("unit is about to take damage")
    --     --    end
    --     --)
    --     --unit.bind("on_damaged_after",
    --     --    function(source, target, attack)
    --     --        print("unit took damage")
    --     --    end
    --     --)
    --     --unit.bind("on_damage_pre",
    --     --    function(source, target, attack)
    --     --        print("unit is about to deal damage")
    --     --    end
    --     --)
    --     --unit.bind("on_damage_after",
    --     --    function(source, target, attack)
    --     --        print("unit dealt damage")
    --     --    end
    --     --)

    --     print(unit.hp .. " / " .. unit.maxhp)
    --     player.bind("on_message",
    --         function(player, message)
    --             unit.kill()
    --         end
    --     ).setCondition(
    --         function(player, message)
    --             return message == "-kill"
    --         end
    --     )
    -- end

    -- -- Request Player 0 Keyboard
    -- --keyboard = Player(0).keyboard
    -- --keyboard.bind("on_key_down", 
    -- --    function(triggeringKeyboard, keydata, metakey)
    -- --        print("key down")
    -- --        print("keycode: " .. keydata[1])
    -- --        print("string: " .. keydata[2])
    -- --        print("metakey: " .. metakey)
    -- --    end
    -- --)

    -- --keyboard.bind("on_key_up", 
    -- --    function(triggeringKeyboard, keydata, metakey)
    -- --        print("key up")
    -- --        print("keycode: " .. keydata[1])
    -- --        print("string: " .. keydata[2])
    -- --        print("metakey: " .. metakey)
    -- --    end
    -- --)

    -- --Player(0).mouse.bind("on_mouse_down",
    -- --    function(triggeringMouse, pos, button)
    -- --        print("mouse down")
    -- --        print("player: " .. player.name)
    -- --        print("pos: " .. "(" .. pos[1] .. " | " .. pos[2] .. ")")
    -- --        print("key: " .. button[2])
    -- --    end
    -- --)

    -- --Player(0).mouse.bind("on_mouse_up",
    -- --    function(triggeringMouse, pos, button)
    -- --        print("mouse up")
    -- --        print("player: " .. player.name)
    -- --        print("pos: " .. "(" .. pos[1] .. " | " .. pos[2] .. ")")
    -- --        print("key: " .. button[2])
    -- --    end
    -- --)

    -- --Player(0).mouse.bind("on_motion",
    -- --    function(triggeringMouse, pos)
    -- --        print("mouse motion")
    -- --        print("player: " .. player.name)
    -- --        print("pos: " .. "(" .. pos[1] .. " | " .. pos[2] .. ")")
    -- --    end
    -- --).setCondition(
    -- --    function(triggeringMouse, pos)
    -- --        return player == Player(0)
    -- --    end
    -- --)

    -- player = Framework.Player(PLAYER_NEUTRAL_AGGRESSIVE)
    -- clock = Framework.Clock()
    -- clock.start()

    -- player.bind("on_unit_death",
    --     function(unit)
    --         local id = unit.id
    --         local x = unit.x
    --         local y = unit.y
    --         local face = unit.face
    --         clock.schedule_once(
    --             function(triggeringClock, triggeringSchedule)
    --                 unit.owner.createUnit(id, x, y, face)
    --             end, 5.0
    --         )
    --     end
    -- )

end, print)
end

TimerStart(CreateTimer(), 0., false, onInit)
