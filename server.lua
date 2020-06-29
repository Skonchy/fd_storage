RegisterServerEvent("fd_storage:getStorage")
AddEventHandler("fd_storage:getStorage",function(plate)
    local src = source
    local vehPlate = plate
    print(vehPlate)
    exports["externalsql"]:AsyncQueryCallback({
        query = [[SELECT * FROM storage WHERE plate = :plate]],
        data = {
            plate = vehPlate
        }
    }, function(results)
        if results.data[1] == nil then
            print("No inventory found, now adding one")
            exports["externalsql"]:AsyncQueryCallback({
                query = [[INSERT INTO storage (plate,inventory) VALUES (:plate,"{}")]],
                data = {
                    plate = vehPlate
                }
            }, function(cunt) end)
        else
            inventory = json.decode(results.data[1].inventory)
            TriggerClientEvent("chat:clear",src)
            TriggerClientEvent("chat:addMessage", src, {
                color = {255, 255, 255},
                multiline = false,
                args = {"----- Trunk Storage -----"}
            })
            for k,v in ipairs(inventory) do -- k is index || v is a table of item,amount
                print(dump(inventory[k]))
                TriggerClientEvent("chat:addMessage", src, {
                    color = {255, 255, 255},
                    multiline = false,
                    args = {"[^2"..tostring(k).."^7] ","|| "..tostring(getItemName(v[1])).." || "..tostring(v[2])}
                })
            end
        end
    end)
end)

RegisterServerEvent("fd_storage:putInInv")
AddEventHandler("fd_storage:putInInv", function(item, amount, plate)
    local src = source
    if item and amount and plate then
        local storedAmount = 0
        local character = exports["drp_id"]:GetCharacterData(src)
        local itemCheck = exports["drp_inventory"]:GetItem(character,getItemLabel(item))
        local existingItem = false
        if tonumber(itemCheck) >= tonumber(amount) then
            exports["externalsql"]:AsyncQueryCallback({
                query = [[SELECT * FROM storage WHERE plate = :plate]],
                data={
                    plate = plate
                }
            }, function(results)
                if results.data[1] == nil then
                    print("No inventory found to put into")
                else
                    local inventory = json.decode(results.data[1].inventory)
                    for k,v in ipairs(inventory) do
                        if tostring(v[1]) == tostring(getItemLabel(item)) then
                            local temp = v[2] + amount
                            v[2] = temp
                            existingItem = true
                        end
                        print(v[2], existingItem)
                    end
                    if existingItem then
                        exports["externalsql"]:AsyncQueryCallback({
                            query = [[UPDATE storage SET inventory = :inventory WHERE plate = :plate]],
                            data = {
                                inventory = json.encode(inventory),
                                plate = plate
                            }
                        }, function(cunt) end)
                    else
                        table.insert(inventory,{getItemLabel(item),amount})
                        exports["externalsql"]:AsyncQueryCallback({
                            query = [[UPDATE storage SET inventory = :inventory WHERE plate = :plate]],
                            data = {
                                inventory = json.encode(inventory),
                                plate = plate
                            }
                        },function(cunt) end)
                    end
                    TriggerEvent("DRP_Inventory:removeInventoryItem",tostring(getItemLabel(item)),amount,src)
                    TriggerClientEvent("DRP_Core:Warning",src,"Trunk",tostring("You put "..amount.." of "..item.." into the trunk"),4500,false,"leftCenter")
                end
            end)
        else
            TriggerClientEvent("DRP_Core:Error",src,"Trunk",tostring("You do not have the amount specified"),4500,false,"leftCenter")     
        end
    end
end)

RegisterServerEvent("fd_storage:takeFromInv")
AddEventHandler("fd_storage:takeFromInv", function(item, amount, plate)
    local existingItem = false
    local src = source
    if item and amount and plate then
        exports["externalsql"]:AsyncQueryCallback({
            query = [[SELECT * FROM storage WHERE plate = :plate]],
            data = {
                plate = plate
            }
        }, function(results) 
            if results.data[1] == nil then
                print("No inventory found to take from")
            else
                local inventory = json.decode(results.data[1].inventory)
                for k,v in ipairs(inventory) do
                    if tostring(v[1]) == tostring(getItemLabel(item)) then
                        local temp = v[2] - amount
                        if temp == 0 then
                            table.remove(inventory, k)
                        else
                            v[2] = temp
                        end
                        existingItem = true
                    end
                    print(v[2], existingItem)
                end
                if existingItem then
                    exports["externalsql"]:AsyncQueryCallback({
                        query = [[UPDATE storage SET inventory = :inventory WHERE plate = :plate]],
                        data = {
                            inventory = json.encode(inventory),
                            plate = plate
                        }
                    }, function(cunt)
                        TriggerEvent("DRP_Inventory:addInventoryItem",tostring(getItemLabel(item)),amount,src)
                        TriggerClientEvent("DRP_Core:Warning",src,"Trunk",tostring("You took "..amount.." of "..item.." from the trunk"),4500,false,"leftCenter")
                    end)
                else
                    TriggerClientEvent("DRP_Core:Error",src,"Trunk",tostring("There is none of the specified item in the trunk"),4500, false, "leftCenter")
                end
            end
        end)
    end
end)

function getItemName(item)
    return InventoryItems[tostring(item)].name
end

function getItemLabel(name)
    local result = nil
    for k,v in pairs(InventoryItems) do
        if v.name == name then
            result = k
        end
    end
    return result
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end