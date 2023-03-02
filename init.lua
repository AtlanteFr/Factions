-- Fonction pour obtenir les clés d'une table sous forme de liste
table.keys = function(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

-- Tableau des factions
factions = {}

-- Définition de la fonction qui affiche l'interface help
local function show_interface_help(player)
    local formspec = "size[9,11]"..
            "bgcolor[#080808BB;true]" ..
            "background[5,5;1,1;gui_formbg.png;true]" ..
           "button[2,10;1,1;next;Next]"..
            "label[3,0;Faction Commands Help]" ..
            "label[0,1;"..minetest.colorize("#e1a722", "/fac_create <name> \n"..minetest.colorize("#000000", "Create a faction")).."]"..
            "label[0,2;"..minetest.colorize("#e1a722", "/fac_invite <playername> \n"..minetest.colorize("#000000", "Invite a player to join your faction")).."]"..
            "label[0,3;"..minetest.colorize("#e1a722", "/fac_join <factionname> \n"..minetest.colorize("#000000", "Join a faction")).."]"..
            "label[0,4;"..minetest.colorize("#e1a722", "/fac_kick <playername>\n"..minetest.colorize("#000000", "Kick a member from your faction")).."]"..
            "label[0,5;"..minetest.colorize("#e1a722", "/fac_sethome \n"..minetest.colorize("#000000", "Set your faction's base")).."]"..
            "label[0,6;"..minetest.colorize("#e1a722", "/fac_home \n"..minetest.colorize("#000000", "Teleport to your faction's base")).."]"..
            "label[0,7;"..minetest.colorize("#e1a722", "/fac_leave \n"..minetest.colorize("#000000", "Leave your faction")).."]"..
            "label[0,8;"..minetest.colorize("#e1a722", "/fac_list \n"..minetest.colorize("#000000", "List all factions")).."]"..
            "label[0,9;"..minetest.colorize("#e1a722", "/fac_chat <msg> \n"..minetest.colorize("#000000", "Chat with faction members")).."]"..
            "button_exit[0,10;2,1;exit;Close]"
                     
    minetest.show_formspec(player:get_player_name(), "interface_help", formspec)
end

-- Définition de la commande qui appelle la fonction pour afficher l'interface
minetest.register_chatcommand("fac_help", {
    description = "Show help for faction commands",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        show_interface_help(player)
    end,
})

local function show_interface_help_2(player)
    local formspec = "size[9,11]"..
            "bgcolor[#080808BB;true]" ..
            "background[5,5;1,1;gui_formbg.png;true]" ..
           "button[2,10;1,1;previous;Previous]"..
            "label[3,0;Faction Commands Help]" ..
            "label[0,1;"..minetest.colorize("#e1a722", "/fac_delete  \n"..minetest.colorize("#000000", "Delete your faction")).."]"..
            "label[0,2;"..minetest.colorize("#e1a722", "/fac_members <faction_name>  \n"..minetest.colorize("#000000", "view members of a faction")).."]"..
            "label[0,3;"..minetest.colorize("#e1a722", "/fac_name <old name> <new name>  \n"..minetest.colorize("#000000", "Rename your faction")).."]"..
            "button_exit[0,10;2,1;exit;Close]"
                     
    minetest.show_formspec(player:get_player_name(), "interface_help_2", formspec)
end

-- Enregistrement de la fonction pour le bouton "next"
    minetest.register_on_player_receive_fields(function(player, formname, fields)
        if formname == "interface_help" and fields.next then
show_interface_help_2(player)
    end
end)

-- Enregistrement de la fonction pour le bouton "next"
    minetest.register_on_player_receive_fields(function(player, formname, fields)
        if formname == "interface_help_2" and fields.previous then
show_interface_help(player)
    end
end)




-- Commande pour créer une faction
minetest.register_chatcommand("fac_create", {
    description = "Create a faction",
    params = "<name>",
    func = function(name, param)
        -- Vérifier si le joueur est déjà membre d'une faction
        for _, faction in pairs(factions) do
            if faction.members[name] then
                return false, "You are already a member of the faction " .. faction.name
            end
        end
        -- Créer la faction
        factions[param] = {
            name = param,
            owner = name,
            members = {[name] = true},
            home = nil, -- Ajout de la propriété home pour stocker les coordonnées de la base
        }

        minetest.chat_send_all(minetest.colorize("#00FF00", "The faction [" .. param .. "] has just been created by " .. name))
    end,
})



-- Commande pour afficher la liste des factions
minetest.register_chatcommand("fac_list", {
    description = "List all factions",
    func = function(name, param)
        local faction_list = {}
        for _, faction in pairs(factions) do
            table.insert(faction_list, faction.name)
        end
        local message = "Current factions: " .. table.concat(faction_list, ", ")
        minetest.chat_send_player(name, message)
    end,
})

-- Commande pour expulser un membre de la faction
minetest.register_chatcommand("fac_kick", {
    description = "Kick a member from the faction",
    params = "<playername>",
    func = function(name, param)
        -- Vérifier si le joueur est membre et propriétaire de la faction
        local faction = nil
        for _, f in pairs(factions) do
            if f.members[name] and f.owner == name then
                faction = f
                break
            end
        end
        if not faction then
            return false, "You are not the owner of any faction"
        end
        -- Vérifier si le joueur à expulser est membre de la faction
        if not faction.members[param] then
            return false, param .. " is not a member of your faction"
        end
        -- Vérifier si le joueur à expulser n'est pas le propriétaire de la faction
        if param == faction.owner then
            return false, "You cannot kick yourself from your own faction"
        end
        -- Expulser le joueur de la faction
        faction.members[param] = nil
        minetest.chat_send_player(param, "You have been kicked from the faction " .. faction.name)
        minetest.chat_send_player(name, "You have kicked " .. param .. " from the faction " .. faction.name)
    end,
})

-- Commande pour créer une faction
minetest.register_chatcommand("fac_create", {
    description = "Create a faction",
    params = "<name>",
    func = function(name, param)
        -- Vérifier si le joueur est déjà membre d'une faction
        for _, faction in pairs(factions) do
            if faction.members[name] then
                return false, "You are already a member of the faction " .. faction.name
            end
        end
        -- Créer la faction
        factions[param] = {
            name = param,
            owner = name,
            members = {[name] = true},
            home = nil, -- Ajout de la propriété home pour stocker les coordonnées de la base
        }
    end,
})

-- Commande pour créer une faction
minetest.register_chatcommand("fac_create", {
    description = "Create a faction",
    params = "<name>",
    func = function(name, param)
        -- Vérifier si le joueur est déjà membre d'une faction
        for _, faction in pairs(factions) do
            if faction.members[name] then
                return false, "You are already a member of the faction " .. faction.name
            end
        end
        -- Créer la faction
        factions[param] = {
            name = param,
            owner = name,
            members = {[name] = true},
            home = nil, -- Ajout de la propriété home pour stocker les coordonnées de la base
        }
        -- Envoyer un message à tous les joueurs pour indiquer la création de la faction
        minetest.chat_send_all(minetest.colorize("#00FF00", "The faction " .. param .. " has just been created by " .. name))
    end,
})

-- Commande pour expulser un membre de la faction
minetest.register_chatcommand("fac_kick", {
    description = "Kick a member from the faction",
    params = "<playername>",
    func = function(name, param)
        -- Vérifier si le joueur est membre et propriétaire de la faction
        local faction = nil
        for _, f in pairs(factions) do
            if f.members[name] and f.owner == name then
                faction = f
                break
            end
        end
        if not faction then
            return false, "You are not the owner of any faction"
        end
        -- Vérifier si le joueur à expulser est membre de la faction
        if not faction.members[param] then
            return false, param .. " is not a member of your faction"
        end
        -- Vérifier si le joueur à expulser n'est pas le propriétaire de la faction
        if param == faction.owner then
            return false, "You cannot kick yourself from your own faction"
        end
        -- Expulser le joueur de la faction
        faction.members[param] = nil
        minetest.chat_send_player(param, "You have been kicked from the faction " .. faction.name)
        minetest.chat_send_player(name, "You have kicked " .. param .. " from the faction " .. faction.name)
    end,
})

-- Commande pour définir le home de la faction
minetest.register_chatcommand("fac_sethome", {
    description = "Set the home of your faction",
    func = function(name, param)
        -- Trouver la faction à laquelle appartient le joueur
        local player_faction = nil
        for _, faction in pairs(factions) do
            if faction.members[name] then
                player_faction = faction
                break
            end
        end
        if not player_faction then
            return false, "You are not a member of any faction"
        end
        -- Vérifier que le joueur est propriétaire de la faction
        if player_faction.owner ~= name then
            return false, "Only the owner of the faction can set the home"
        end
        -- Obtenir les coordonnées actuelles du joueur
        local player_pos = minetest.get_player_by_name(name):get_pos()
        -- Stocker les coordonnées dans la faction
        player_faction.home = player_pos
        return true, "The home of your faction has been set to (" .. player_pos.x .. ", " .. player_pos.y .. ", " .. player_pos.z .. ")"
    end,
})

-- Commande pour se téléporter vers le home de la faction
minetest.register_chatcommand("fac_home", {
    description = "Teleport to your faction's home",
    func = function(name, param)
        -- Trouver la faction à laquelle appartient le joueur
        local player_faction = nil
        for _, faction in pairs(factions) do
            if faction.members[name] then
                player_faction = faction
                break
            end
        end
        if not player_faction then
            return false, "You are not a member of any faction"
        end
        -- Vérifier que la faction a un home défini
        if not player_faction.home then
            return false, "Your faction has not set a home yet"
        end
        -- Téléporter le joueur vers le home de la faction
        minetest.get_player_by_name(name):set_pos(player_faction.home)
        return true, "Teleported to your faction's home"
    end,
})

-- Commande pour inviter un joueur dans une faction
minetest.register_chatcommand("fac_invite", {
    params = "<player> <faction>",
    description = "Invite a player to a faction",
    func = function(name, param)
        local player_name, faction_name = string.match(param, "^([^%s]+)%s([^%s]+)$")
if not player_name or not faction_name then
        return false, "Usage: /fac_invite <player> <faction>"
end
    if not factions[faction_name] then
        return false, "Non-existent faction"
end
    if factions[faction_name].owner ~= name then
        return false, "You are not the owner of this faction"
end
    local player = minetest.get_player_by_name(player_name)
        if not player then
    return false, "Player is offline"
end
-- Vérifier si le joueur est déjà membre d'une faction
        for _, faction in pairs(factions) do
    if faction.members[player_name] then
            return false, "The player is already a member of a faction"
    end
end
        factions[faction_name].invitations = factions[faction_name].invitations or {}
        factions[faction_name].invitations[player_name] = true
        minetest.chat_send_player(player_name, "You have been invited to the "..faction_name.." faction. Type /fac_accept "..faction_name.." to accept the invitation.")
    return true, "Invitation sent to " .. player_name
end,
})

-- Commande pour accepter une invitation dans une faction
minetest.register_chatcommand("fac_accept", {
    params = "<faction>",
    description = "Accept an invitation to a faction",
    func = function(name, param)
        local faction_name = param:trim()
        if faction_name == "" then
            return false, "Invalid faction name"
        end
            if not factions[faction_name] then
        return false, "Non-existent faction"
    end
           if not factions[faction_name].invitations or not factions[faction_name].invitations[name] then
                return false, "You have not been invited to this faction"
        end
-- Vérifier si le joueur est déjà membre d'une faction
        for _, faction in pairs(factions) do
if faction.members[name] then
          return false, "You are already a member of a faction"
     end
end
        factions[faction_name].members[name] = true
        factions[faction_name].invitations[name] = nil
        return true, "Vous avez rejoint la faction " .. faction_name
end,
})

-- Commande pour discuter dans une faction
minetest.register_chatcommand("fac_chat", {
    params = "<msg>",
    description = "Chat with faction members",
    func = function(name, param)
        local player_faction = nil
        -- Trouver la faction du joueur
        for faction_name, faction_data in pairs(factions) do
            if faction_data.members[name] then
                player_faction = faction_name
                break
            end
        end
        if not player_faction then
            return false, "You are not in any faction"
        end
        -- Envoyer le message aux membres de la faction
        for member_name, _ in pairs(factions[player_faction].members) do
            minetest.chat_send_player(member_name, "[" ..faction_name.. "]" .. name .. ": " .. param)
        end
        return true
    end,
})

-- Commande pour voir les membres d'une faction
minetest.register_chatcommand("fac_members", {
    params = "<faction name>",
    description = "view members of a faction",
    func = function(name, param)
        local faction_name = param:trim()
        if faction_name == "" then
            return false, "Faction name cannot be empty"
        end
        local faction = factions[faction_name]
        if not faction then
            return false, "No faction with this name was found"
        end
        local members_str = table.concat(table.keys(faction.members), ", ")
        if faction.owner == name then
            return true, "Faction members '" .. faction_name .. "': " .. members_str .. "\nFaction creator: " .. faction.owner
        end
    end,
})

-- Commande pour quitter une faction
minetest.register_chatcommand("fac_leave", {
    description = "Leave faction",
    func = function(name)
        local player_faction = nil
        -- Chercher la faction à laquelle le joueur appartient
        for faction_name, faction in pairs(factions) do
            if faction.members[name] then
                player_faction = faction_name
                break
            end
        end
        if not player_faction then
            return false, "You are not a member of any faction"
        end
        -- Vérifier si le joueur est le propriétaire de la faction
        if factions[player_faction].owner == name then
            return false, "You cannot leave the faction you own"
        end
        -- Retirer le joueur de la faction
        factions[player_faction].members[name] = nil
        return true, "You left the faction " .. player_faction
    end,
})

-- Ecouter les messages de chat
minetest.register_on_chat_message(function(name, message)
    local player_faction = nil
    -- Chercher la faction à laquelle le joueur appartient
    for faction_name, faction in pairs(factions) do
        if faction.members[name] then
            player_faction = faction_name
            break
        end
    end
    -- Ajouter un préfixe avec le nom de la faction si le joueur en a une
    if player_faction then
        local faction_prefix = "[" .. player_faction .. "] "
        minetest.chat_send_all(faction_prefix .. name .. ": " .. message)
        return true
    end
end)

-- Commande pour supprimer sa faction
minetest.register_chatcommand("fac_delete", {
    description = "Delete his faction",
    func = function(name)
        local player_faction = nil
        -- Chercher la faction à laquelle le joueur appartient
        for faction_name, faction in pairs(factions) do
            if faction.members[name] then
                player_faction = faction_name
                break
            end
        end
        if not player_faction then
            return false, "You are not a member of any faction"
        end
        -- Vérifier si le joueur est le propriétaire de la faction
        if factions[player_faction].owner ~= name then
            return false, "You are not the owner of this faction"
        end
        -- Supprimer tous les membres de la faction
        for member_name, _ in pairs(factions[player_faction].members) do
            factions[player_faction].members[member_name] = nil
        end
        -- Supprimer la faction
        factions[player_faction] = nil
        return true, "The Faction " .. player_faction .. " has been deleted"
    end,
})

-- Commande pour renommer une faction
minetest.register_chatcommand("fac_name", {
    params = "<old name> <new name>",
    description = "Rename your faction",
    func = function(name, param)
        local old_name, new_name = string.match(param, "^([^%s]+)%s([^%s]+)$")
        if not old_name or not new_name then
            return false, "Usage: /renamefaction <old name> <new name>"
        end
        if not factions[old_name] then
            return false, "Non-existent faction"
        end
        if factions[old_name].owner ~= name then
            return false, "You are not the owner of this faction"
        end
        if factions[new_name] then
            return false, "A faction with this name already exists"
        end
        factions[new_name] = factions[old_name]
        factions[new_name].name = new_name
        factions[old_name] = nil
        return true, "Faction "..old_name.." renamed to "..new_name
    end,
})

-- Fonction pour enregistrer les factions dans un fichier
local function save_factions()
    local factions_str = minetest.write_json(factions, true)
    local file = io.open(minetest.get_worldpath() .. "/factions.json", "w")
    file:write(factions_str)
    file:close()
end

-- Fonction pour charger les factions depuis un fichier
local function load_factions()
    local file = io.open(minetest.get_worldpath() .. "/factions.json", "r")
    if not file then
        return
    end
    local factions_str = file:read("*all")
    file:close()
    factions = minetest.parse_json(factions_str) or {}
end

-- Charger les factions au démarrage du jeu
load_factions()

-- Enregistrer les factions lorsqu'un joueur quitte le jeu
minetest.register_on_leaveplayer(function(player)
    save_factions()
end)

-- Enregistrer les factions toutes les 10 minutes
minetest.register_globalstep(function(dtime)
    save_factions()
end)

