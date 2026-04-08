local MOD_NAME = "MLTradeTuner"
local UEHelpers = require("UEHelpers")

local function Log(msg)
    print(string.format("[%s] %s\n", MOD_NAME, msg))
end

local function same_object(a, b)
    if not a or not b or not a:IsValid() or not b:IsValid() then
        return false
    end

    local ok_a, addr_a = pcall(function() return a:GetAddress() end)
    local ok_b, addr_b = pcall(function() return b:GetAddress() end)
    if ok_a and ok_b then
        return addr_a == addr_b
    end

    return a == b
end

local function get_main_player_pawncpp()
    local pawns = FindAllOf("PawnCPP") or {}
    for _, pawn in ipairs(pawns) do
        if pawn and pawn:IsValid() then
            local ok, is_main = pcall(function() return pawn.isMainPlayer end)
            if ok and is_main then
                return pawn
            end
        end
    end

    local pc = UEHelpers.GetPlayerController()
    if pc and pc:IsValid() and pc.Pawn and pc.Pawn:IsValid() then
        return pc.Pawn
    end

    return CreateInvalidObject()
end

local function get_player_region()
    local pawn = get_main_player_pawncpp()
    if not pawn or not pawn:IsValid() then
        return CreateInvalidObject()
    end

    local ok_region, region = pcall(function() return pawn.currentRegion end)
    if not ok_region or not region or not region:IsValid() then
        return CreateInvalidObject()
    end

    return region
end

local function add_regional_wealth(amount, silent)
    local region = get_player_region()
    if not region or not region:IsValid() then
        if not silent then
            Log("Could not find player region to add regional wealth.")
        end
        return false
    end

    local current_value = 0
    local ok_current, val = pcall(function() return region.regionalWealth end)
    if ok_current and type(val) == "number" then
        current_value = val
    end

    local new_value = current_value + amount
    local prop = region:Reflection():GetProperty("regionalWealth")
    if not prop:IsValid() then
        if not silent then
            Log("Could not find regionalWealth property on current region.")
        end
        return false
    end

    prop:ImportText(tostring(new_value), prop:ContainerPtrToValuePtr(region), 0, region)
    if not silent then
        Log(string.format("Added %+d regional wealth (%d -> %d).", amount, current_value, new_value))
    end
    return true
end

local function get_engine_actor()
    local engines = FindAllOf("RTSMultiEngineCPP") or {}
    for _, engine in ipairs(engines) do
        if engine and engine:IsValid() then
            return engine
        end
    end
    return CreateInvalidObject()
end

-- 0.0 = fully toward import price, 1.0 = fully toward export/sell price.
local DEFAULT_SELL_BIAS = 0.75

local function get_target_price(building, good_type)
    if not building or not building:IsValid() then
        return nil, nil, nil
    end

    local import_price = nil
    local export_price = nil

    local ok_imp, imp = pcall(function() return building:getLowestImportPrice(good_type, true) end)
    if ok_imp and type(imp) == "number" and imp > 0 then
        import_price = imp
    end

    local ok_exp, exp = pcall(function() return building:getAvailableExportPrice(good_type) end)
    if ok_exp and type(exp) == "number" and exp > 0 then
        export_price = exp
    end

    if not import_price and export_price then
        import_price = export_price
    end
    if not export_price and import_price then
        export_price = import_price
    end

    if not import_price or not export_price then
        return nil, nil, nil
    end

    local weighted = (export_price * DEFAULT_SELL_BIAS) + (import_price * (1.0 - DEFAULT_SELL_BIAS))
    local target_price = math.floor(weighted + 0.5)
    return target_price, import_price, export_price
end

local last_processed_trade_log_index = 0

local function process_new_trade_entries()
    local engine = get_engine_actor()
    if not engine or not engine:IsValid() then
        return
    end

    local trade_log = engine.tradeLog
    if not trade_log then
        return
    end

    local log_size = #trade_log
    if log_size <= 0 then
        last_processed_trade_log_index = 0
        return
    end

    -- First run: set cursor to end to avoid retroactive adjustments on old save data.
    if last_processed_trade_log_index == 0 then
        last_processed_trade_log_index = log_size
        return
    end

    local player_region = get_player_region()
    if not player_region or not player_region:IsValid() then
        last_processed_trade_log_index = log_size
        return
    end

    for i = last_processed_trade_log_index + 1, log_size do
        local entry = trade_log[i]
        if entry and entry.goodAmt and entry.goodAmt > 0 then
            local local_building = nil
            local is_import = false

            if entry.toBuilding and entry.toBuilding:IsValid() and entry.toBuilding.Region and entry.toBuilding.Region:IsValid() then
                if same_object(entry.toBuilding.Region, player_region) then
                    local_building = entry.toBuilding
                    is_import = true
                end
            end

            if not local_building and entry.fromBuilding and entry.fromBuilding:IsValid() and entry.fromBuilding.Region and entry.fromBuilding.Region:IsValid() then
                if same_object(entry.fromBuilding.Region, player_region) then
                    local_building = entry.fromBuilding
                    is_import = false
                end
            end

            if local_building then
                local target_price, import_price, export_price = get_target_price(local_building, entry.goodType)
                if target_price and entry.priceTotal and type(entry.priceTotal) == "number" then
                    local desired_total = target_price * entry.goodAmt
                    local delta = 0

                    if is_import then
                        -- Paid import price; refund down to midpoint.
                        delta = entry.priceTotal - desired_total
                    else
                        -- Received export price; top-up up to midpoint.
                        delta = desired_total - entry.priceTotal
                    end

                    if delta > 0 then
                        add_regional_wealth(delta, true)
                        Log(string.format("Trade adjust good=%d amt=%d imp=%d exp=%d target=%d bias=%.2f paid=%d delta=+%d", entry.goodType, entry.goodAmt, import_price, export_price, target_price, DEFAULT_SELL_BIAS, entry.priceTotal, delta))
                    end
                end
            end
        end
    end

    last_processed_trade_log_index = log_size
end

local DEFAULT_MONEY_ADD = 100

RegisterConsoleCommandHandler("ml_money_add", function(_, params)
    local amount = tonumber(params[1]) or DEFAULT_MONEY_ADD
    add_regional_wealth(amount, false)
    return true
end)

RegisterConsoleCommandHandler("ml_trade_rebalance_now", function()
    process_new_trade_entries()
    return true
end)

RegisterConsoleCommandHandler("ml_trade_help", function()
    Log("Commands:")
    Log("  ml_money_add [amount]")
    Log("  ml_trade_rebalance_now")
    Log("Hotkeys:")
    Log("  F7 -> add +100 regional wealth")
    Log("  F9 -> process pending trade adjustments")
    Log("Note:")
    Log("  Displayed buy/sell prices stay vanilla; executed transactions are adjusted toward sell-biased average.")
    Log(string.format("  Current sell bias: %.2f", DEFAULT_SELL_BIAS))
    return true
end)

RegisterKeyBindAsync(Key.F7, {}, function()
    ExecuteInGameThread(function()
        add_regional_wealth(DEFAULT_MONEY_ADD, false)
    end)
end)

RegisterKeyBindAsync(Key.F9, {}, function()
    ExecuteInGameThread(function()
        process_new_trade_entries()
    end)
end)

-- Auto-process on frequent engine updates.
local function hook_trade_update(fn_name)
    local ok, pre, post = pcall(function()
        return RegisterHook(fn_name, function(_)
            ExecuteInGameThread(function()
                process_new_trade_entries()
            end)
        end)
    end)

    if ok then
        Log(string.format("Hooked %s", fn_name))
        return true
    end

    return false
end

hook_trade_update("/Script/ManorLords.RTSMultiEngineCPP:updateFreeMerchants")
hook_trade_update("/Script/ManorLords.RTSMultiEngineCPP:updatePlayerRequests")
hook_trade_update("/Script/ManorLords.RTSMultiEngineCPP:updateOpenClaims")

ExecuteInGameThread(function()
    process_new_trade_entries()
end)

Log(string.format("Loaded. Keeping visible prices vanilla; adjusting executed trades (sell bias=%.2f).", DEFAULT_SELL_BIAS))
