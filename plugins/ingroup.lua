do

local function check_member(cb_extra, success, result)
  vardump(result)
    local receiver = cb_extra.receiver
    local data = cb_extra.data
    local msg = cb_extra.msg
    for k,v in ipairs(result) do
      local member_id = v.peer_id
      if member_id ~= our_id then
        data[tostring(msg.to.id)] = {
          group_type = 'Supergroup',
		  moderators = {},
		  set_owner = member_id,
          settings = {
            set_name = string.gsub(msg.to.print_name, '_', ' '),
            lock_member = 'no',
			lock_sticker = 'no',
			lock_link = 'no',
			lock_spam = 'yes',
			lock_arabic = 'no',
            flood = 'yes',
            public = 'no'
          }
        }
        save_data(_config.moderation.data, data)
        local super = 'supergroup'
        if not data[tostring(super)] then
          data[tostring(super)] = {}
          save_data(_config.moderation.data, data)
        end
        data[tostring(super)][tostring(msg.to.id)] = msg.to.id
        save_data(_config.moderation.data, data)
        return reply_msg(receiver,'Supergroup has been added!', ok_cb, false)
      end
    end
end
local function show_settings(msg, data)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local data = load_data(_config.moderation.data)
  if data[tostring(msg.to.id)] then
    if data[tostring(msg.to.id)]['settings']['flood_msg_max'] then
      NUM_MSG_MAX = tonumber(data[tostring(msg.to.id)]['settings']['flood_msg_max'])
      print('custom'..NUM_MSG_MAX)
    else
      NUM_MSG_MAX = 5
    end
  end
  local settings = data[tostring(msg.to.id)]['settings']
  local text = "SuperGroup settings:\nLock links : "..settings.lock_link.."\nLock flood : "..settings.flood.."\nflood sensitivity : "..NUM_MSG_MAX.."\nLock spam :"..settings.lock_spam.."\nLock Arabic :"..settings.lock_arabic.."\nLock sticker :"..settings.lock_sticker.."\nPublic : "..settings.public
  return text
end
local function check_member_superrem(cb_extra, success, result)
  vardump(result)
	local receiver = cb_extra.receiver
	local data = cb_extra.data
	local msg = cb_extra.msg
	for k,v in ipairs(result) do
		local member_id = v.peer_id
		if member_id ~= our_id then
		-- Group configuration removal
		data[tostring(msg.to.id)] = nil
		save_data(_config.moderation.data, data)
		local super = 'supergroup'
		if not data[tostring(super)] then
			data[tostring(super)] = nil
			save_data(_config.moderation.data, data)
		end
		data[tostring(super)][tostring(msg.to.id)] = nil
		save_data(_config.moderation.data, data)
		return reply_msg(receiver, 'SuperGroup has been removed', ok_cb, false)
		end
	end
end
local function group_add(msg)
  if not is_admin(msg) then
    return "You're not admin"
  end
  if is_super(msg) then
    return "SuperGroup is already added!"
  end
  local data = load_data(_config.moderation.data)
    receiver = msg.id
    receiver2 = get_receiver(msg)
    channel_get_users(receiver2, check_member,{receiver=receiver, data=data, msg = msg}) 
end
local function group_rem(msg)
  if not is_admin(msg) then
    return "You're not admin"
  end
  if not is_super(msg) then
    return "Supergroup is not added!"
  end
  local data = load_data(_config.moderation.data)
    receiver = msg.id
    receiver2 = get_receiver(msg)
    channel_get_users(receiver2, check_member_superrem,{receiver=receiver, data=data, msg = msg})
end
local function set_rules(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return 'SuperGroup rules set'
end
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'No rules available.'
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  local rules = string.gsub(msg.to.print_name, '_', ' ')..' rules:\n\n'..rules
  return rules
end
local function set_description(msg, data, target, about)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local data_cat = 'description'
  data[tostring(target)][data_cat] = about
  save_data(_config.moderation.data, data)
  local text = "Description has been set\n\nSelect chat again to see!"
  return reply_msg(msg.id, text, ok_cb, false)
end
local function get_description(msg, data)
  local data_cat = 'description'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'No description available.'
  end
  local about = data[tostring(msg.to.id)][data_cat]
  local about = string.gsub(msg.to.print_name, "_", " ")..':\n\n'..about
  return 'Description for supergroup :'..about
end
local function lock_group_link(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'yes' then
    return 'Link posting is already locked'
  else
    data[tostring(target)]['settings']['lock_link'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'Link posting has been locked'
  end
end
local function unlock_group_link(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'no' then
    return 'Link posting is already unlocked'
  else
    data[tostring(target)]['settings']['lock_link'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Link posting has been unlocked'
  end
end

local function lock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'yes' then
    return 'Arabic language are already locked'
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'Arabic language has been locked'
  end
end
local function unlock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'no' then
    return 'Arabic language already unlocked'
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Arabic language has been unlocked'
  end
end
local function lock_group_flood(msg, data, target)
  if not is_owner(msg) then
    return "Only admins can do it for now"
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'yes' then
    return 'Group flood is locked'
  else
    data[tostring(target)]['settings']['flood'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'Group flood has been locked'
  end
end

local function unlock_group_flood(msg, data, target)
  if not is_owner(msg) then
    return "Only admins can do it for now"
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'no' then
    return 'Group flood is not locked'
  else
    data[tostring(target)]['settings']['flood'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Group flood has been unlocked'
  end
end

local function lock_group_member(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'yes' then
    return 'Group members are already locked'
  else
    data[tostring(target)]['settings']['lock_member'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return 'Group members has been locked'
end

local function unlock_group_member(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'no' then
    return 'Group members are not locked'
  else
    data[tostring(target)]['settings']['lock_member'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Group members has been unlocked'
  end
end
local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'yes' then
    return 'Sticker posting are already locked'
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'Sticker posting has been locked'
  end
end

local function unlock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'no' then
    return 'Sticker posting are already unlocked'
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Sticker posting has been unlocked'
  end
end

local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'yes' then
    return 'Spam detection is already locked'
  else
    data[tostring(target)]['settings']['lock_spam'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'Spam detection has been locked'
  end
end

local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'no' then
    return 'Spam detection is already unlocked'
  else
    data[tostring(target)]['settings']['lock_spam'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Spam detection has been unlocked'
  end
end

local function set_group_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/chat_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    channel_set_photo (receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    data[tostring(msg.to.id)]['settings']['lock_photo'] = 'yes'
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'Photo saved!', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'Failed, please try again!', ok_cb, false)
  end
end
local function promote(receiver, member_username, member_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'Group is not added.')
  end
  if data[group]['moderators'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' is already a moderator.')
  end
  channel_add_mod(receiver, "user#id"..member_id, ok_cb, false)
  data[group]['moderators'][tostring(member_id)] = member_username
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, member_username..' has been promoted.')
end
local function promote_by_reply(extra, success, result)
  vardump(result)
    local msg = result
    local full_name = (msg.from.first_name or '')..' '..(msg.from.last_name or '')
    if msg.from.username then
      member_username = '@'.. result.from.username
    else
      member_username = full_name
    end
    local member_id = msg.from.peer_id
    if msg.to.peer_type == 'channel' then
      return promote("channel#id"..msg.to.peer_id, member_username, member_id)
    end  
end
local function demote(receiver, member_username, member_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'Group is not added.')
  end
  if not data[group]['moderators'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' is not a moderator.')
  end
  channel_rem_mod(receiver, "user#id"..member_id, ok_cb, false)
  data[group]['moderators'][tostring(member_id)] = nil
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, member_username..' has been demoted.')
end
local function demote_by_reply(extra, success, result)
  vardump(result)
    local msg = result
    local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
    if result.from.username then
      member_username = '@'..result.from.username
    else
      member_username = full_name
    end
    local member_id = result.from.peer_id
    if result.to.peer_type == 'channel' then
      return demote("channel#id"..msg.to.peer_id, member_username, member_id)
    end  
end
local function promote_demote_res(extra, success, result)
  vardump(result)
	local member_id = result.peer_id
	local member_username = "@"..result.username
	local channel_id = extra.channel_id
	local mod_cmd = extra.mod_cmd
	local receiver = "channel#id"..channel_id
	if mod_cmd == "promote" then
	  return promote(receiver, member_username, member_id)
	elseif mod_cmd == "demote" then
	  return demote(receiver, member_username, member_id)
	end
end
local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "supergroup"
  if not data[tostring(groups)][tostring(msg.to.id)] then
    return 'Group is not added.'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then --fix way
    return 'No moderator in this group.'
  end
  local i = 1
  local message = '\nList of moderators for ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message ..i..'- '..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end
local function run(msg, matches)
  local data = load_data(_config.moderation.data)
  if msg.media then
    if msg.media.type == "photo" and data[tostring(msg.to.id)]['settings']['set_photo'] == "waiting" and is_momod(msg) then
	  load_photo(msg.id, set_group_photo, msg)
	end
  end
  if matches[1] == "add" then
    return group_add(msg)
  end
  if matches[1] == "rem" then
    return group_rem(msg)
  end
  if matches[1] == "lock" then
    local target = msg.to.id
    if matches[2] == "links" then
      return lock_group_link(msg, data, target)
    end
    if matches[2] == "spam" then
      return lock_group_spam(msg, data, target)
    end
    if matches[2] == "flood" then
      return lock_group_flood(msg, data, target)
    end
    if matches[2] == "sticker" then
      return lock_group_sticker(msg, data, target)
    end
    if matches[2] == "member" then
      return lock_group_member(msg, data, target)
    end
	if matches[2] == "arabic" then
	  return lock_group_arabic(msg, data, target)
	end
  end
  if matches[1] == "unlock" then
    local target = msg.to.id
    if matches[2] == "links" then
      return unlock_group_link(msg, data, target)
    end
    if matches[2] == "spam" then
      return unlock_group_spam(msg, data, target)
    end
    if matches[2] == "flood" then
      return unlock_group_flood(msg, data, target)
    end
    if matches[2] == "sticker" then
      return unlock_group_sticker(msg, data, target)
    end
    if matches[2] == "member" then
      return unlock_group_member(msg, data, target)
    end
	if matches[2] == "arabic" then
	  return unlock_group_arabic(msg, data, target)
	end
  end
  if matches[1] == "settings" then
    return show_settings(msg, data)
  end
  if matches[1] == "rules" then
    return get_rules(msg, data)
  end
  if matches[1] == "about" then
    return get_description(msg, data)
  end
  if matches[1] == "set" then
    local data = load_data(_config.moderation.data)
    if matches[2] == "rules" then
      rules = matches[3]
      local target = msg.to.id
      return set_rules(msg, data, target)
    end
    if matches[2] == "about" and is_momod(msg) then
      local target = msg.to.id
      local about = matches[3]
      set_about("channel#id"..target, about, ok_cb, true)
      return set_description(msg, data, target, about)
    end
  end
  if matches[1] == "setflood" then
    if not is_momod(msg) then
      return "For moderators only!"
    end
    if tonumber(matches[2]) < 5 or tonumber(matches[2]) > 20 then
      return "Wrong number, range [5-20]"
    end
    local flood_max = matches[2]
    data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
    save_data(_config.moderation.data, data)
    return "Group flood has been set to "..flood_max
  end
  if matches[1] == "setowner" and matches[2] then
    if not is_owner(msg) then
	  return "For owner only!"
	end
	last = data[tostring(msg.to.id)]['set_owner']
	channel_rem_admins("channel#id"..msg.to.id, "user#id"..last, ok_cb, true)
	data[tostring(msg.to.id)]['set_owner'] = matches[2]
	channel_set_admins("channel#id"..msg.to.id, "user#id"..matches[2], ok_cb, true)
	save_data(_config.moderation.data, data)
	local text = matches[2].." added as owner"
	return text
  end
  if matches[1] == "owner" then
    local data = load_data(_config.moderation.data)
    local group_owner = data[tostring(msg.to.id)]['set_owner']
	if not group_owner then
	  return "no owner,ask admins in support groups to set owner for your group"
	end
	return "SuperGroup owner is ["..group_owner.."]"
  end
  if matches[1] == "promote" and not matches[2] then
    if not is_owner(msg) then
	  return "Only the owner can promote new moderator"
	end
	if type(msg.reply_id)~= "nil" then
	  msgr = get_message(msg.reply_id, promote_by_reply, false)
	end
  end
  if matches[1] == "promote" and matches[2] then
    if not is_owner(msg) then
	  return "Only owner can do promote!"
	end
	if string.gsub(matches[2], "@", "") == msg.from.username and not is_owner(msg) then
	  return "You can't demote yourself"
	end
	local cbres_extra = {
	  channel_id = msg.to.id,
	  mod_cmd = 'promote'
	}
	local username = matches[2]
	local username = string.gsub(matches[2], "@", "")
	return resolve_username(username, promote_demote_res, cbres_extra)
  end
  if matches[1] == "modlist" then
    return modlist(msg)
  end
  if matches[1] == "demote" and not matches[2] then
    if not is_owner(msg) then
	  return "Only owner can demote moderator!"
	end
	if type(msg.reply_id)~="nil" then
	  msgr = get_message(msg.reply_id, demote_by_reply, false)
	end
  end
  if matches[1] == "demote" and matches[2] then
    if not is_owner(msg) then
	  return "Only owner can do demote!"
	end
	if string.gsub(matches[2], "@", "") == msg.from.username and not is_owner(msg) then
	  return "You can't demote yourself!"
	end
	local cbres_extra = {
	  channel_id = msg.to.id,
	  mod_cmd = 'demote'
	}
	local username = matches[2]
	local username = string.gsub(matches[2], "@", "")
	return resolve_username(username, promote_demote_res, cbres_extra)
  end
  if matches[1] == "clean" then
    if not is_owner(msg) then
	  return "Only owner can clean!"
	end
	if matches[2] == "modlist" then
	--  if next(data[tostring(msg.to.id)['moderators']]) == nil then
	--    return "No moderators in this group"
    --  end
	  local message = '\nList of moderators for ' .. string.gsub(msg.to.print_name, '_', '') .. ':\n'
	  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
	    channel_rem_mod("channel#id"..msg.to.id, "user#id"..k, ok_cb, true)
		data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
		save_data(_config.moderation.data, data)
	  end
	  return "Modlist has been cleaned"
	end
	if matches[2] == "rules" then
	  data[tostring(msg.to.id)]['rules'] = nil
	  save_data(_config.moderation.data, data)
	  return "Rules has been cleaned"
	end
	if matches[2] == "about" then
	  set_about("channel#id"..msg.to.id, '', ok_cb, true)
	  local data_cat = 'description'
	  data[tostring(msg.to.id)][data_cat] = nil
	  save_data(_config.moderation.data, data)
	  return "SuperGroup description has been cleaned"
	end
  end 
  if matches[1] == 'setphoto' and is_momod(msg) then
    data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
    save_data(_config.moderation.data, data)
    return 'Please send me new group photo now'
  end
end
return {
  patterns = {
    "^[/!#](add)$",
    "^[/!#](rem)$",
    "^[/!#](rules)$",
    "^[/!#](about)$",
	"^[/!#](owner)$",
	"^[/!#](modlist)$",
    "^[/!#](settings)$",
	"^[/!#](promote)$",
	"^[/!#](demote)$",
	"^[/!#](setphoto)$",
	"^[/!#](clean) (.*)$",
    "^[/!#](lock) (.*)$",
    "^[/!#](unlock) (.*)$",
	"^[/!#](promote) (.*)$",
	"^[/!#](demote) (.*)$",
	"^[/!#](setowner) (%d+)$",
    "^[/!#](setflood) (%d+)$",
    "^[/!#](set) ([^%s]+) (.*)$",
	"%[(photo)%]",
	"^!!tgservice (.+)$",
  },
  run = run
}

end
