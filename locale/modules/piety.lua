--Piety, tribute to the god of industry
--Written by Mylon, 2017
--MIT License

if MODULE_LIST then
	module_list_add("Piety")
end

global.pious = {}
piety = {}

function piety.tribute(event)
    --Check once per hour, offset by 7 minutes
    if game.tick % 216000 ~= 25200 then
    --if game.tick % 600 ~= 0 then --Debug
        return
    end
    --Check all forces
    for _, force in pairs(game.forces) do
        if force and force.valid then            
            for __, surface_list in pairs(force.logistic_networks) do
                for ___, network in pairs(surface_list) do
                    if network and network.valid then
                        if network.get_item_count("landfill") >= 15000 then
                            --Pick a roboport at random.
                            local cell = network.cells[math.random(#network.cells)]
                            if cell and cell.valid and cell.owner and cell.owner.valid then
                                local miracle = cell.owner
                                --55% chance of iron, 30% chance of copper, 15% chance of coal
                                local res = "iron-ore"
                                local rand = math.random()
                                if rand < 0.15 then
                                    res = "coal"
                                elseif rand < 0.45 then
                                    res = "copper-ore"
                                end
                                local amount = math.floor(network.get_item_count("landfill")/10)
                                piety.bless(cell.owner.surface, cell.owner.position, res, amount * 20)
                                --miracle.surface.create_entity{name=res, position=miracle.position, amount=amount * 20}
                                network.remove_item{name="landfill", count=amount}
                                cell.owner.die()
                                if cell.owner.last_user then
                                    game.print(cell.owner.last_user.name .. " has been blessed by the god of industry.")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

--/c piety.bless(game.player.surface, game.player.selected.position, "iron-ore", 200000)
--This doesn't actuallge generate (amount) of resources, but close enough and it scales linearly.
--200k creates zone of amount 164k
function piety.bless(surface, position, resource, amount)
    local radius = math.floor(amount^0.24)
    for x = position.x - radius, position.x + radius do
        for y = position.y - radius, position.y + radius do
            local intensity = math.floor(radius^2 - (position.x - x)^2 - (position.y - y)^2)
            if intensity > 0 then
                local corrected_pos = surface.find_non_colliding_position("iron-ore", {x,y}, 5, 1)
                if corrected_pos ~= nil then
                    surface.create_entity{name=resource, position=corrected_pos, amount=intensity}
                end
            end
        end
    end
end

Event.register(defines.events.on_tick, piety.tribute)