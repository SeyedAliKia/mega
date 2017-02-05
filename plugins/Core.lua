local function modadd(msg)
  local hash = "gp_lang:"..msg.chat_id_
  local lang = redis:get(hash)
  -- superuser and admins only (because sudo are always has privilege)
  local data = load_data(_config.moderation.data)
  if is_admin(msg) then
    if data[tostring(msg.chat_id_)] then
      return '⚠️ _گروه از قبل در لیست گروه های ربات است_ !'
    end
  -- create data array in moderation.json
  data[tostring(msg.chat_id_)] = {
    owners = {},
    mods ={},
    banned ={},
    is_silent_users ={},
    settings = {
      lock_link = 'yes',
      lock_tag = 'yes',
      lock_spam = 'yes',
      flood = 'yes',
      lock_bots = 'yes'
    },
    mutes = {
      mute_fwd = 'no',
      mute_audio = 'no',
      mute_video = 'no',
      mute_contact = 'no',
      mute_text = 'no',
      mute_photos = 'no',
      mute_gif = 'no',
      mute_doc = 'no',
      mute_sticker = 'no',
      mute_voice = 'no',
      mute_all = 'no'
    }
  }
  save_data(_config.moderation.data, data)
  local groups = 'groups'
  if not data[tostring(groups)] then
    data[tostring(groups)] = {}
    save_data(_config.moderation.data, data)
  end
  data[tostring(groups)][tostring(msg.chat_id_)] = msg.chat_id_
  save_data(_config.moderation.data, data)
  return '✅ _گروه به لیست گروه های ربات افزوده شد_ !'
end
end

local function modrem(msg)
  local hash = "gp_lang:"..msg.chat_id_
  local lang = redis:get(hash)
  local data = load_data(_config.moderation.data)
  -- superuser and admins only (because sudo are always has privilege)
  if is_admin(msg) then
    local receiver = msg.chat_id_
    if not data[tostring(msg.chat_id_)] then
      return '🚫 _گروه در لیست گروه های ربات نیست_ !'
    end
  data[tostring(msg.chat_id_)] = nil
  save_data(_config.moderation.data, data)
  local groups = 'groups'
  if not data[tostring(groups)] then
    data[tostring(groups)] = nil
    save_data(_config.moderation.data, data)
    end data[tostring(groups)][tostring(msg.chat_id_)] = nil
    save_data(_config.moderation.data, data)
    return '📛 _گروه از لیست گروه های ربات پاک شد_ !'
  end
  end

local function modlist(msg)
 if is_mod(msg) then 
    local hash = "gp_lang:"..msg.chat_id_
    local lang = redis:get(hash)
    local data = load_data(_config.moderation.data)
    local i = 1
    if not data[tostring(msg.chat_id_)] then
      return '🚫 _گروه در لیست گروه های ربات نیست_ !'
    end
    -- determine if table is empty
    if next(data[tostring(msg.chat_id_)]['mods']) == nil then --fix way
    return "⚠️ _لیست مدیران گروه خالی است_ !"
  end
  message = '📋 _لیست مدیران گروه_ :\n\n'
  for k,v in pairs(data[tostring(msg.chat_id_)]['mods'])
  do
    message = message ..i.. '- '..v..' [*' ..k.. '*] \n'
    i = i + 1
  end
  return message
end    
end

local function ownerlist(msg)
if is_mod(msg) then  
  local hash = "gp_lang:"..msg.chat_id_
  local lang = redis:get(hash)
  local data = load_data(_config.moderation.data)
  local i = 1
  if not data[tostring(msg.chat_id_)] then
    return '🚫 _گروه در لیست گروه های ربات نیست_ !'
  end
  -- determine if table is empty
  if next(data[tostring(msg.chat_id_)]['owners']) == nil then --fix way
  return "⚠️ _لیست صاحبان گروه خالی است_ !"
end
message = '📋 _لیست صاحبان گروه_ :\n\n'
for k,v in pairs(data[tostring(msg.chat_id_)]['owners']) do
  message = message ..i.. '- '..v..' [' ..k.. '] \n'
  i = i + 1
end
return message
end
end

local function action_by_reply(arg, data)
local hash = "gp_lang:"..data.chat_id_
local lang = redis:get(hash)
local cmd = arg.cmd
local administration = load_data(_config.moderation.data)
if not tonumber(data.sender_user_id_) then return false end
if not administration[tostring(data.chat_id_)] then
  return tdcli.sendMessage(data.chat_id_, "", 0, "🚫 _گروه در لیست گروه های ربات نیست_ !", 0, "md")
end
  
if cmd == "setowner" then
  local function owner_cb(arg, data)
    local hash = "gp_lang:"..arg.chat_id
    local lang = redis:get(hash)
    local administration = load_data(_config.moderation.data)
    if data.username_ then
      user_name = '@'..check_markdown(data.username_)
    else
      user_name = check_markdown(data.first_name_)
    end
    if administration[tostring(arg.chat_id)]['owners'][tostring(data.id_)] then
      return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." از قبل در لیست صاحبان گروه بود !", 0, "md")
    end
    administration[tostring(arg.chat_id)]['owners'][tostring(data.id_)] = user_name
    save_data(_config.moderation.data, administration)
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." به لیست صاحبان گروه افزوده شد !", "md")
  end
  tdcli_function ({
    ID = "GetUser",
    user_id_ = data.sender_user_id_
  }, owner_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
end
  
if cmd == "promote" then
  local function promote_cb(arg, data)
    local hash = "gp_lang:"..arg.chat_id
    local lang = redis:get(hash)
    local administration = load_data(_config.moderation.data)
    if data.username_ then
      user_name = '@'..check_markdown(data.username_)
    else
      user_name = check_markdown(data.first_name_)
    end
    if administration[tostring(arg.chat_id)]['mods'][tostring(data.id_)] then
      return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." از قبل در لیست مدیران گروه بود !", "md")
    end
    administration[tostring(arg.chat_id)]['mods'][tostring(data.id_)] = user_name
    save_data(_config.moderation.data, administration)
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." به لیست مدیران گروه افزوده شد !", 0, "md")
  end
  tdcli_function ({
    ID = "GetUser",
    user_id_ = data.sender_user_id_
  }, promote_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
end
  
if cmd == "remowner" then
  local function rem_owner_cb(arg, data)
    local hash = "gp_lang:"..arg.chat_id
    local lang = redis:get(hash)
    local administration = load_data(_config.moderation.data)
    if data.username_ then
      user_name = '@'..check_markdown(data.username_)
    else
      user_name = check_markdown(data.first_name_)
    end
    if not administration[tostring(arg.chat_id)]['owners'][tostring(data.id_)] then
      return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." در لیست صاحبان گروه نیست !", 0, "md")
    end
    administration[tostring(arg.chat_id)]['owners'][tostring(data.id_)] = nil
    save_data(_config.moderation.data, administration)
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." از لیست صاحبان گروه پاک شد !", "md")
  end
  tdcli_function ({
    ID = "GetUser",
    user_id_ = data.sender_user_id_
  }, rem_owner_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
end
  
if cmd == "demote" then
  local function demote_cb(arg, data)
    local administration = load_data(_config.moderation.data)
    if data.username_ then
      user_name = '@'..check_markdown(data.username_)
    else
      user_name = check_markdown(data.first_name_)
    end
    if not administration[tostring(arg.chat_id)]['mods'][tostring(data.id_)] then
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." در لیست مدیران گروه نیست !", "md")
    end
    administration[tostring(arg.chat_id)]['mods'][tostring(data.id_)] = nil
    save_data(_config.moderation.data, administration)
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." از لیست مدیران گروه پاک شد !", "md")
  end
  tdcli_function ({
    ID = "GetUser",
    user_id_ = data.sender_user_id_
  }, demote_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
end
  
if cmd == "id" then
  local function id_cb(arg, data)
    --return tdcli.sendMessage(arg.chat_id, "", 0, "*"..data.id_.."*", 0, "md")
    tdcli_function ({ID="SendMessage", chat_id_=arg.chat_id, reply_to_message_id_="", disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=data.id_, disable_web_page_preview_=1, clear_draft_=0, entities_={[0]={ID="MessageEntityMentionName", offset_=0, length_= string.len(data.id_), user_id_=data.id_}}}}, dl_cb, nil)                      
  end
  tdcli_function ({
    ID = "GetUser",
    user_id_ = data.sender_user_id_
  }, id_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
end
  
end

local function action_by_username(arg, data)
local hash = "gp_lang:"..arg.chat_id
local lang = redis:get(hash)
local cmd = arg.cmd
local administration = load_data(_config.moderation.data)
if not administration[tostring(arg.chat_id)] then
  return tdcli.sendMessage(data.chat_id_, "", 0, "🚫 _گروه در لیست گروه های ربات نیست_ !", 0, "md")
end
if data.type_.user_.username_ then
  user_name = '@'..check_markdown(data.type_.user_.username_)
else
  user_name = check_markdown(data.title_)
end

if not arg.username then return false end
  
if cmd == "setowner" then
  if administration[tostring(arg.chat_id)]['owners'][tostring(data.id_)] then
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." از قبل در لیست صاحبان گروه بود !", 0, "md")
  end
  administration[tostring(arg.chat_id)]['owners'][tostring(data.id_)] = user_name
  save_data(_config.moderation.data, administration)
  return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." به لیست صاحبان گروه افزوده شد !", "md")
end

if cmd == "promote" then
  if administration[tostring(arg.chat_id)]['mods'][tostring(data.id_)] then
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." از قبل در لیست مدیران گروه بود !", "md")
  end
  administration[tostring(arg.chat_id)]['mods'][tostring(data.id_)] = user_name
  save_data(_config.moderation.data, administration)
  return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." به لیست مدیران گروه افزوده شد !", 0, "md")
end

if cmd == "remowner" then
  if not administration[tostring(arg.chat_id)]['owners'][tostring(data.id_)] then
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." در لیست صاحبان گروه نیست !", 0, "md")
  end
  administration[tostring(arg.chat_id)]['owners'][tostring(data.id_)] = nil
  save_data(_config.moderation.data, administration)
  return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." از لیست صاحبان گروه پاک شد !", "md")
end

if cmd == "demote" then
  if not administration[tostring(arg.chat_id)]['mods'][tostring(data.id_)] then
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." در لیست مدیران گروه نیست !", "md")
  end
  administration[tostring(arg.chat_id)]['mods'][tostring(data.id_)] = nil
  save_data(_config.moderation.data, administration)
  return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." از لیست مدیران گروه پاک شد !", "md")    
end

if cmd == "id" then
  --return tdcli.sendMessage(arg.chat_id, "", 0, "_"..data.id_.."_", 0, "md")
  tdcli_function ({ID="SendMessage", chat_id_=arg.chat_id, reply_to_message_id_="", disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=data.id_, disable_web_page_preview_=1, clear_draft_=0, entities_={[0]={ID="MessageEntityMentionName", offset_=0, length_= string.len(data.id_), user_id_=data.id_}}}}, dl_cb, nil)                
end

if cmd == "res" then
  if lang then
    text = "Result for [ ".. check_markdown(data.type_.user_.username_) .." ] :\n"
    .. "".. check_markdown(data.title_) .."\n"
    .. " [".. data.id_ .."]"
  else
    text = "اطلاعات برای [ ".. check_markdown(data.type_.user_.username_) .." ] :\n"
    .. "".. check_markdown(data.title_) .."\n"
    .. " [".. data.id_ .."]"
    return tdcli.sendMessage(arg.chat_id, 0, 1, text, 1, 'md')
  end
end

end


local function action_by_id(arg, data)
local hash = "gp_lang:"..arg.chat_id
local lang = redis:get(hash)
local cmd = arg.cmd
local administration = load_data(_config.moderation.data)
if not administration[tostring(arg.chat_id)] then
  return tdcli.sendMessage(data.chat_id_, "", 0, "🚫 _گروه در لیست گروه های ربات نیست_ !", 0, "md")
end
if not tonumber(arg.user_id) then return false end
if data.first_name_ then
  if data.username_ then
    user_name = '@'..check_markdown(data.username_)
  else
    user_name = check_markdown(data.first_name_)
  end
    
  if cmd == "setowner" then
    if administration[tostring(arg.chat_id)]['owners'][tostring(data.id_)] then
      return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." از قبل در لیست صاحبان گروه بود !", 0, "md")
    end
    administration[tostring(arg.chat_id)]['owners'][tostring(data.id_)] = user_name
    save_data(_config.moderation.data, administration)
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." به لیست صاحبان گروه افزوده شد !", "md")
  end
    
  if cmd == "promote" then
    if administration[tostring(arg.chat_id)]['mods'][tostring(data.id_)] then
      return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." از قبل در لیست مدیران گروه بود !", "md")
    end
    administration[tostring(arg.chat_id)]['mods'][tostring(data.id_)] = user_name
    save_data(_config.moderation.data, administration)
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." به لیست مدیران گروه افزوده شد !", 0, "md")
  end
    
  if cmd == "remowner" then
    if not administration[tostring(arg.chat_id)]['owners'][tostring(data.id_)] then
      return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." در لیست صاحبان گروه نیست !", 0, "md")
    end
    administration[tostring(arg.chat_id)]['owners'][tostring(data.id_)] = nil
    save_data(_config.moderation.data, administration)
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." از لیست صاحبان گروه پاک شد !", "md")
  end
    
  if cmd == "demote" then
    if not administration[tostring(arg.chat_id)]['mods'][tostring(data.id_)] then
      return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." در لیست مدیران گروه نیست !", "md")
    end
    administration[tostring(arg.chat_id)]['mods'][tostring(data.id_)] = nil
    save_data(_config.moderation.data, administration)
    return tdcli.sendMessage(arg.chat_id, "", 0, "✅ کاربر [*"..data.id_.."*] "..user_name.." از لیست مدیران گروه پاک شد !", "md")
  end
    
  if cmd == "whois" then
    if data.username_ then
      username = '@'..data.username_
    else
      username = '---'
    end   
    local text1 = data.first_name_.."\n"..username.."\n"..data.id_
    --tdcli.sendMessage(arg.chat_id, 0, 1, "📜 اطلاعات کاربر :\nشناسه : [*"..data.id_.."*]\nنام کاربری : "..username.."\nنام کاربر : _"..data.first_name_.."_\n", 1, "md")  
    tdcli_function ({ID="SendMessage", chat_id_=arg.chat_id, reply_to_message_id_="", disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text1, disable_web_page_preview_=1, clear_draft_=0, entities_={[0]={ID="MessageEntityMentionName", offset_=0, length_= string.len(data.first_name_), user_id_=data.id_}}}}, dl_cb, nil)            
  else
    return tdcli.sendMessage(arg.chat_id, "", 0, "🚫 _مشخصات کاربر پیدا نشد_ !", 0, "md")
  end
    
end
end

---------------Lock Link-------------------
local function lock_link(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local lock_link = data[tostring(target)]["settings"]["lock_link"]
  if lock_link == "yes" then
    return "🔐 _قفل #لینک از قبل فعال است_ !"
  else
    data[tostring(target)]["settings"]["lock_link"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #لینک فعال شد_ !\n🔸`از این پس لینک های فرستاده شده توسط کاربران پاک می شوند` !"
  end
end
end

local function unlock_link(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local lock_link = data[tostring(target)]["settings"]["lock_link"]
  if lock_link == "no" then
    return "🔓 _قفل #لینک فعال نیست_ !"
  else
    data[tostring(target)]["settings"]["lock_link"] = "no" save_data(_config.moderation.data, data)
    return "🔏 _قفل #لینک غیرفعال شد_ !"
  end
end
end
---------------Lock Tag-------------------
local function lock_tag(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local lock_tag = data[tostring(target)]["settings"]["lock_tag"]
  if lock_tag == "yes" then
    return "🔐 _قفل #تگ از قبل فعال است_ !"
  else
    data[tostring(target)]["settings"]["lock_tag"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #تگ فعال شد_ !\n🔸`از این پس پیام های تگ دار فرستاده شده توسط کاربران پاک می شوند` !"
  end
end
end

local function unlock_tag(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local lock_tag = data[tostring(target)]["settings"]["lock_tag"]
  if lock_tag == "no" then
    return "🔓 _قفل #تگ فعال نیست_ !"
  else
    data[tostring(target)]["settings"]["lock_tag"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #تگ غیرفعال شد_ !"
  end
end
end
---------------Lock Mention-------------------
--[[local function lock_mention(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نمیباشید"
end
end
local lock_mention = data[tostring(target)]["settings"]["lock_mention"]
if lock_mention == "yes" then
if lang then
  return "*Mention* _Posting Is Already Locked_"
elseif lang then
  return "ارسال فراخوانی افراد هم اکنون ممنوع است"
end
else
data[tostring(target)]["settings"]["lock_mention"] = "yes"
save_data(_config.moderation.data, data)
if lang then
  return "*Mention* _Posting Has Been Locked_"
else
  return "ارسال فراخوانی افراد در گروه ممنوع شد"
end
end
end
local function unlock_mention(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نمیباشید"
end
end
local lock_mention = data[tostring(target)]["settings"]["lock_mention"]
if lock_mention == "no" then
if lang then
  return "*Mention* _Posting Is Not Locked_"
elseif lang then
  return "ارسال فراخوانی افراد در گروه ممنوع نمیباشد"
end
else
data[tostring(target)]["settings"]["lock_mention"] = "no" save_data(_config.moderation.data, data)
if lang then
  return "*Mention* _Posting Has Been Unlocked_"
else
  return "ارسال فراخوانی افراد در گروه آزاد شد"
end
end
end]]

---------------Lock Edit-------------------
local function lock_edit(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local lock_edit = data[tostring(target)]["settings"]["lock_edit"]
  if lock_edit == "yes" then
    return "🔐 _قفل #ویرایش پیام از قبل فعال است_ !"
  else
    data[tostring(target)]["settings"]["lock_edit"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #ویرایش پیام فعال شد_ !\n🔸`از این پس پیام هایی که ویرایش شوند پاک می شوند` !"
  end
end
end

local function unlock_edit(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local lock_edit = data[tostring(target)]["settings"]["lock_edit"]
  if lock_edit == "no" then
    return "🔓 _قفل #ویرایش پیام فعال نیست_ !"
  else
    data[tostring(target)]["settings"]["lock_edit"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #ویرایش پیام غیرفعال شد_ !"
  end
end
end
---------------Lock spam-------------------
local function lock_spam(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local lock_spam = data[tostring(target)]["settings"]["lock_spam"]
  if lock_spam == "yes" then
    return "🔐 _قفل #پیام های طولانی از قبل فعال است_ !"
  else
    data[tostring(target)]["settings"]["lock_spam"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #پیام های طولانی فعال شد_ !\n🔸`از این پس پیام های طولانی فرستاده شده توسط کاربران پاک می شوند` !"
  end
end
end

local function unlock_spam(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local lock_spam = data[tostring(target)]["settings"]["lock_spam"]
  if lock_spam == "no" then
    return "🔓 _قفل #پیام های طولانی فعال نیست_ !"
  else
    data[tostring(target)]["settings"]["lock_spam"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #پیام های طولانی غیرفعال شد_ !"
  end
end
end
---------------Lock Flood-------------------
local function lock_flood(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local lock_flood = data[tostring(target)]["settings"]["flood"]
  if lock_flood == "yes" then
    return "🔐 _قفل #رگباری از قبل فعال است_ !"
  else
    data[tostring(target)]["settings"]["flood"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #تگ فعال شد_ !\n🔸`از این پس فرستادن پیام های رگباری باعث اخراج فرد می شود` !"
  end
end
end

local function unlock_flood(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local lock_flood = data[tostring(target)]["settings"]["flood"]
  if lock_flood == "no" then
    return "🔓 _قفل #رگباری فعال نیست_ !"
  else
    data[tostring(target)]["settings"]["flood"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #رگباری غیرفعال شد_ !"
  end
end
end
---------------Lock Bots-------------------
--[[local function lock_bots(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نمیباشید"
end
end
local lock_bots = data[tostring(target)]["settings"]["lock_bots"]
if lock_bots == "yes" then
if lang then
  return "*Bots* _Protection Is Already Enabled_"
elseif lang then
  return "محافظت از گروه در برابر ربات ها هم اکنون فعال است"
end
else
data[tostring(target)]["settings"]["lock_bots"] = "yes"
save_data(_config.moderation.data, data)
if lang then
  return "*Bots* _Protection Has Been Enabled_"
else
  return "محافظت از گروه در برابر ربات ها فعال شد"
end
end
end
local function unlock_bots(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نمیباشید"
end
end
local lock_bots = data[tostring(target)]["settings"]["lock_bots"]
if lock_bots == "no" then
if lang then
  return "*Bots* _Protection Is Not Enabled_"
elseif lang then
  return "محافظت از گروه در برابر ربات ها غیر فعال است"
end
else
data[tostring(target)]["settings"]["lock_bots"] = "no" save_data(_config.moderation.data, data)
if lang then
  return "*Bots* _Protection Has Been Disabled_"
else
  return "محافظت از گروه در برابر ربات ها غیر فعال شد"
end
end
end]]

---------------Lock Markdown-------------------
--[[local function lock_markdown(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نمیباشید"
end
end
local lock_markdown = data[tostring(target)]["settings"]["lock_markdown"]
if lock_markdown == "yes" then
if lang then
  return "*Markdown* _Posting Is Already Locked_"
elseif lang then
  return "ارسال پیام های دارای فونت در گروه هم اکنون ممنوع است"
end
else
data[tostring(target)]["settings"]["lock_markdown"] = "yes"
save_data(_config.moderation.data, data)
if lang then
  return "*Markdown* _Posting Has Been Locked_"
else
  return "ارسال پیام های دارای فونت در گروه ممنوع شد"
end
end
end
local function unlock_markdown(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نمیباشید"
end
end
local lock_markdown = data[tostring(target)]["settings"]["lock_markdown"]
if lock_markdown == "no" then
if lang then
  return "*Markdown* _Posting Is Not Locked_"
elseif lang then
  return "ارسال پیام های دارای فونت در گروه ممنوع نمیباشد"
end
else
data[tostring(target)]["settings"]["lock_markdown"] = "no" save_data(_config.moderation.data, data)
if lang then
  return "*Markdown* _Posting Has Been Unlocked_"
else
  return "ارسال پیام های دارای فونت در گروه آزاد شد"
end
end
end]]

---------------Lock Webpage-------------------
--[[local function lock_webpage(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
local lock_webpage = data[tostring(target)]["settings"]["lock_webpage"]
if lock_webpage == "yes" then
  return "*Webpage* _Is Already Locked_"
else
  data[tostring(target)]["settings"]["lock_webpage"] = "yes"
  save_data(_config.moderation.data, data)
  if lang then
    return "*Webpage* _Has Been Locked_"
  else
    return "ارسال صفحات وب در گروه ممنوع شد"
  end
end
end
end
local function unlock_webpage(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
--[[local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نمیباشید"
end
end
local lock_webpage = data[tostring(target)]["settings"]["lock_webpage"]
if lock_webpage == "no" then
if lang then
  return "*Webpage* _Is Not Locked_"
elseif lang then
  return "ارسال صفحات وب در گروه ممنوع نمیباشد"
end
else
data[tostring(target)]["settings"]["lock_webpage"] = "no"
save_data(_config.moderation.data, data)
if lang then
  return "*Webpage* _Has Been Unlocked_"
else
  return "ارسال صفحات وب در گروه آزاد شد"
end
end
end]]

--------Mutes---------
--------Mute all--------------------------
local function mute_all(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_all = data[tostring(target)]["mutes"]["mute_all"]
  if mute_all == "yes" then
    return "🔐 _قفل #گروه از قبل فعال است_ !"
  else
    data[tostring(target)]["mutes"]["mute_all"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #گروه فعال شد_ !\n🔸`از این پس همه ی پیام های فرستاده شده توسط کاربران پاک می شوند` !"
  end
end
end

local function unmute_all(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_all = data[tostring(target)]["mutes"]["mute_all"]
  if mute_all == "no" then
    return "🔓 _قفل #گروه فعال نیست_ !"
  else
    data[tostring(target)]["mutes"]["mute_all"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #گروه غیرفعال شد_ !"
  end
end
end
---------------Mute Gif-------------------
local function mute_gif(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_gif = data[tostring(target)]["mutes"]["mute_gif"]
  if mute_gif == "yes" then
    return "🔐 _قفل #گیف از قبل فعال است_ !"
  else
    data[tostring(target)]["mutes"]["mute_gif"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #گیف فعال شد_ !\n🔸`از این پس گیف های فرستاده شده توسط کاربران پاک می شوند` !"
  end
end
end

local function unmute_gif(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_gif = data[tostring(target)]["mutes"]["mute_gif"]
  if mute_gif == "no" then
    return "🔓 _قفل #گیف فعال نیست_ !"
  else
    data[tostring(target)]["mutes"]["mute_gif"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #گیف غیرفعال شد_ !"

  end
end
end
---------------Mute Game-------------------
--[[local function mute_game(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نمیباشید"
end
end
local mute_game = data[tostring(target)]["mutes"]["mute_game"]
if mute_game == "yes" then
if lang then
  return "*Mute Game* _Is Already Enabled_"
elseif lang then
  return "بیصدا کردن بازی های تحت وب فعال است"
end
else
data[tostring(target)]["mutes"]["mute_game"] = "yes"
save_data(_config.moderation.data, data)
if lang then
  return "*Mute Game* _Has Been Enabled_"
else
  return "بیصدا کردن بازی های تحت وب فعال شد"
end
end
end
local function unmute_game(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نمیباشید"
end
end
local mute_game = data[tostring(target)]["mutes"]["mute_game"]
if mute_game == "no" then
if lang then
  return "*Mute Game* _Is Already Disabled_"
elseif lang then
  return "بیصدا کردن بازی های تحت وب غیر فعال است"
end
else
data[tostring(target)]["mutes"]["mute_game"] = "no"
save_data(_config.moderation.data, data)
if lang then
  return "*Mute Game* _Has Been Disabled_"
else
  return "بیصدا کردن بازی های تحت وب غیر فعال شد"
end
end
end]]
---------------Mute Inline-------------------
local function mute_inline(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_inline = data[tostring(target)]["mutes"]["mute_inline"]
  if mute_inline == "yes" then
    return "🔐 _قفل #کیبورد شیشه ای از قبل فعال است_ !"
  else
    data[tostring(target)]["mutes"]["mute_inline"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #کیبورد شیشه ای فعال شد_ !\n🔸`از این پس کیبورد های شیشه ای فرستاده شده توسط کاربران پاک می شوند` !"
  end
end
end

local function unmute_inline(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_inline = data[tostring(target)]["mutes"]["mute_inline"]
  if mute_inline == "no" then
    return "🔓 _قفل #کیبورد شیشه ای فعال نیست_ !"
  else
    data[tostring(target)]["mutes"]["mute_inline"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #کیبورد شیشه ای غیرفعال شد_ !"
  end
end
end
---------------Mute Text-------------------
local function mute_text(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_text = data[tostring(target)]["mutes"]["mute_text"]
  if mute_text == "yes" then
    return "🔐 _قفل #متن از قبل فعال است_ !"
  else
    data[tostring(target)]["mutes"]["mute_text"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #متن فعال شد_ !\n🔸`از این پس متن های فرستاده شده توسط کاربران پاک می شوند` !"
  end
end
end

local function unmute_text(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_text = data[tostring(target)]["mutes"]["mute_text"]
  if mute_text == "no" then
    return "🔓 _قفل #متن فعال نیست_ !"
  else
    data[tostring(target)]["mutes"]["mute_text"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #متن غیرفعال شد_ !"
  end
end
end
---------------Mute photo-------------------
local function mute_photo(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_photo = data[tostring(target)]["mutes"]["mute_photo"]
  if mute_photo == "yes" then
    return "🔐 _قفل #عکس از قبل فعال است_ !"
  else
    data[tostring(target)]["mutes"]["mute_photo"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #لینک فعال شد_ !\n🔸`از این پس عکس های فرستاده شده توسط کاربران پاک می شوند` !"
  end
end
end

local function unmute_photo(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_photo = data[tostring(target)]["mutes"]["mute_photo"]
  if mute_photo == "no" then
    return "🔓 _قفل #عکس فعال نیست_ !"
  else
    data[tostring(target)]["mutes"]["mute_photo"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #عکس غیرفعال شد_ !"
  end
end
end
---------------Mute Video-------------------
local function mute_video(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_video = data[tostring(target)]["mutes"]["mute_video"]
  if mute_video == "yes" then
    return "🔐 _قفل #فیلم از قبل فعال است_ !"
  else
    data[tostring(target)]["mutes"]["mute_video"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #فیلم فعال شد_ !\n🔸`از این پس فیلم های فرستاده شده توسط کاربران پاک می شوند` !"
  end
end
end

local function unmute_video(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_video = data[tostring(target)]["mutes"]["mute_video"]
  if mute_video == "no" then
    return "🔓 _قفل #فیلم فعال نیست_ !"
  else
    data[tostring(target)]["mutes"]["mute_video"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #فیلم غیرفعال شد_ !"
  end
end
end
---------------Mute Audio-------------------
local function mute_audio(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_audio = data[tostring(target)]["mutes"]["mute_audio"]
  if mute_audio == "yes" then
    return "🔐 _قفل #آهنگ از قبل فعال است_ !"
  else
    data[tostring(target)]["mutes"]["mute_audio"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #صدا فعال شد_ !\n🔸`از این پس آهنگ های فرستاده شده توسط کاربران پاک می شوند` !"
  end
end
end

local function unmute_video(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_audio = data[tostring(target)]["mutes"]["mute_audio"]
  if mute_audio == "no" then
    return "🔓 _قفل #آهنگ فعال نیست_ !"
  else
    data[tostring(target)]["mutes"]["mute_audio"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #آهنگ غیرفعال شد_ !"
  end
end
end
---------------Mute Voice-------------------
local function mute_voice(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_voice = data[tostring(target)]["mutes"]["mute_voice"]
  if mute_voice == "yes" then
    return "🔐 _قفل #وُیس از قبل فعال است_ !"
  else
    data[tostring(target)]["mutes"]["mute_voice"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #وُیس فعال شد_ !\n🔸`از این پس وُیس های فرستاده شده توسط کاربران پاک می شوند` !"
  end
end
end

local function unmute_voice(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_voice = data[tostring(target)]["mutes"]["mute_voice"]
  if mute_voice == "no" then
    return "🔓 _قفل #وُیس فعال نیست_ !"
  else
    data[tostring(target)]["mutes"]["mute_voice"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #وُیس غیرفعال شد_ !"
  end
end
end
---------------Mute Sticker-------------------
local function mute_sticker(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_sticker = data[tostring(target)]["mutes"]["mute_sticker"]
  if mute_sticker == "yes" then
    return "🔐 _قفل #استیکر پیام از قبل فعال است_ !"
  else
    data[tostring(target)]["mutes"]["mute_sticker"] = "yes"
    save_data(_config.moderation.data, data)
    return "🔒 _قفل #استیکر فعال شد_ !\n🔸`از این پس استیکر های فرستاده شده توسط کاربران پاک می شوند` !"
  end
end
end

local function unmute_sticker(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
  local mute_sticker = data[tostring(target)]["mutes"]["mute_sticker"]
  if mute_sticker == "no" then
    return "🔓 _قفل #استیکر فعال نیست_ !"
  else
    data[tostring(target)]["mutes"]["mute_sticker"] = "no"
    save_data(_config.moderation.data, data)
    return "🔏 _قفل #استیکر غیرفعال شد_ !"
  end
end
end
---------------Mute Contact-------------------
local function mute_contact(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
local mute_contact = data[tostring(target)]["mutes"]["mute_contact"]
if mute_contact == "yes" then
    return "🔐 _قفل #مخاطب از قبل فعال است_ !"
else
  data[tostring(target)]["mutes"]["mute_contact"] = "yes"
  save_data(_config.moderation.data, data)
    return "🔒 _قفل #مخاطب فعال شد_ !\n🔸`از این پس مخاطب های فرستاده شده توسط کاربران پاک می شوند` !"
end
end
end

local function unmute_contact(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
local mute_contact = data[tostring(target)]["mutes"]["mute_contact"]
if mute_contact == "no" then
    return "🔓 _قفل #مخاطب فعال نیست_ !"
else
  data[tostring(target)]["mutes"]["mute_contact"] = "no"
  save_data(_config.moderation.data, data)
    return "🔏 _قفل #مخاطب غیرفعال شد_ !"
end
end
end
---------------Mute Forward-------------------
local function mute_forward(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
local mute_forward = data[tostring(target)]["mutes"]["mute_forward"]
if mute_forward == "yes" then
    return "🔐 _قفل #فروارد از قبل فعال است_ !"
else
  data[tostring(target)]["mutes"]["mute_forward"] = "yes"
  save_data(_config.moderation.data, data)
    return "🔒 _قفل #فروارد فعال شد_ !\n🔸`از این پس فروارد های فرستاده شده توسط کاربران پاک می شوند` !"
end
end
end

local function unmute_forward(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
local mute_forward = data[tostring(target)]["mutes"]["mute_forward"]
if mute_forward == "no" then
    return "🔓 _قفل #فروارد فعال نیست_ !"
else
  data[tostring(target)]["mutes"]["mute_forward"] = "no"
  save_data(_config.moderation.data, data)
    return "🔏 _قفل #فروارد غیرفعال شد_ !"
end
end
end  
---------------Mute Location-------------------
--[[local function mute_location(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نمیباشید"
end
end
local mute_location = data[tostring(target)]["mutes"]["mute_location"]
if mute_location == "yes" then
if lang then
  return "*Mute Location* _Is Already Enabled_"
elseif lang then
  return "بیصدا کردن موقعیت فعال است"
end
else
data[tostring(target)]["mutes"]["mute_location"] = "yes"
save_data(_config.moderation.data, data)
if lang then
  return "*Mute Location* _Has Been Enabled_"
else
  return "بیصدا کردن موقعیت فعال شد"
end
end
end
local function unmute_location(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نمیباشید"
end
end
local mute_location = data[tostring(target)]["mutes"]["mute_location"]
if mute_location == "no" then
if lang then
  return "*Mute Location* _Is Already Disabled_"
elseif lang then
  return "بیصدا کردن موقعیت غیر فعال است"
end
else
data[tostring(target)]["mutes"]["mute_location"] = "no"
save_data(_config.moderation.data, data)
if lang then
  return "*Mute Location* _Has Been Disabled_"
else
  return "بیصدا کردن موقعیت غیر فعال شد"
end
end
end]]
---------------Mute Document-------------------
local function mute_document(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
local mute_document = data[tostring(target)]["mutes"]["mute_document"]
if mute_document == "yes" then
    return "🔐 _قفل #فایل از قبل فعال است_ !"
else
  data[tostring(target)]["mutes"]["mute_document"] = "yes"
  save_data(_config.moderation.data, data)
    return "🔒 _قفل #فایل فعال شد_ !\n🔸`از این پس فایل های فرستاده شده توسط کاربران پاک می شوند` !"
end
end
end

local function unmute_document(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
local mute_document = data[tostring(target)]["mutes"]["mute_document"]
if mute_document == "no" then
    return "🔓 _قفل #فایل فعال نیست_ !"
else
  data[tostring(target)]["mutes"]["mute_document"] = "no"
  save_data(_config.moderation.data, data)
    return "🔏 _قفل #فایل غیرفعال شد_ !"
end
end
end  
---------------Mute TgService-------------------
--[[local function mute_tgservice(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نمیباشید"
end
end
local mute_tgservice = data[tostring(target)]["mutes"]["mute_tgservice"]
if mute_tgservice == "yes" then
if lang then
  return "*Mute TgService* _Is Already Enabled_"
elseif lang then
  return "بیصدا کردن خدمات تلگرام فعال است"
end
else
data[tostring(target)]["mutes"]["mute_tgservice"] = "yes"
save_data(_config.moderation.data, data)
if lang then
  return "*Mute TgService* _Has Been Enabled_"
else
  return "بیصدا کردن خدمات تلگرام فعال شد"
end
end
end
local function unmute_tgservice(msg, data, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
if lang then
  return "_You're Not_ *Moderator*"
else
  return "شما مدیر گروه نیستید"
end
end
local mute_tgservice = data[tostring(target)]["mutes"]["mute_tgservice"]
if mute_tgservice == "no" then
if lang then
  return "*Mute TgService* _Is Already Disabled_"
elseif lang then
  return "بیصدا کردن خدمات تلگرام غیر فعال است"
end
else
data[tostring(target)]["mutes"]["mute_tgservice"] = "no"
save_data(_config.moderation.data, data)
if lang then
  return "*Mute TgService* _Has Been Disabled_"
else
  return "بیصدا کردن خدمات تلگرام غیر فعال شد"
end
end
end]]
---------------

function group_settings(msg, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if is_mod(msg) then
local data = load_data(_config.moderation.data)
local target = msg.chat_id_
if data[tostring(target)] then
  if data[tostring(target)]["settings"]["num_msg_max"] then
    NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['num_msg_max'])
    print('custom'..NUM_MSG_MAX)
  else
    NUM_MSG_MAX = 5
  end
end


  local mutes = data[tostring(target)]["mutes"]  
  local settings = data[tostring(target)]["settings"]  
  
if data[tostring(target)]["settings"] then
  if not data[tostring(target)]["settings"]["lock_link"] then
    data[tostring(target)]["settings"]["lock_link"] = "yes"
  end
end

if data[tostring(target)]["settings"] then
  if not data[tostring(target)]["settings"]["lock_tag"] then
    data[tostring(target)]["settings"]["lock_tag"] = "yes"
  end
end

--[[if data[tostring(target)]["settings"] then
  if not data[tostring(target)]["settings"]["lock_mention"] then
    data[tostring(target)]["settings"]["lock_mention"] = "no"
  end
end]]

if data[tostring(target)]["settings"] then
  if not data[tostring(target)]["settings"]["lock_edit"] then
    data[tostring(target)]["settings"]["lock_edit"] = "no"
  end
end

if data[tostring(target)]["settings"] then
  if not data[tostring(target)]["settings"]["lock_spam"] then
    data[tostring(target)]["settings"]["lock_spam"] = "yes"
  end
end

if data[tostring(target)]["settings"] then
  if not data[tostring(target)]["settings"]["lock_flood"] then
    data[tostring(target)]["settings"]["lock_flood"] = "yes"
  end
end

if data[tostring(target)]["settings"] then
  if not data[tostring(target)]["settings"]["lock_bots"] then
    data[tostring(target)]["settings"]["lock_bots"] = "yes"
  end
end

--[[if data[tostring(target)]["settings"] then
  if not data[tostring(target)]["settings"]["lock_markdown"] then
    data[tostring(target)]["settings"]["lock_markdown"] = "no"
  end
end]]

--[[if data[tostring(target)]["settings"] then
  if not data[tostring(target)]["settings"]["lock_webpage"] then
    data[tostring(target)]["settings"]["lock_webpage"] = "no"
  end
end]]

if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_all"] then
    data[tostring(target)]["mutes"]["mute_all"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_gif"] then
    data[tostring(target)]["mutes"]["mute_gif"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_text"] then
    data[tostring(target)]["mutes"]["mute_text"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_photo"] then
    data[tostring(target)]["mutes"]["mute_photo"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_video"] then
    data[tostring(target)]["mutes"]["mute_video"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_audio"] then
    data[tostring(target)]["mutes"]["mute_audio"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_voice"] then
    data[tostring(target)]["mutes"]["mute_voice"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_sticker"] then
    data[tostring(target)]["mutes"]["mute_sticker"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_contact"] then
    data[tostring(target)]["mutes"]["mute_contact"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_forward"] then
    data[tostring(target)]["mutes"]["mute_forward"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_location"] then
    data[tostring(target)]["mutes"]["mute_location"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_document"] then
    data[tostring(target)]["mutes"]["mute_document"] = "no"
  end
end
--[[if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_tgservice"] then
    data[tostring(target)]["mutes"]["mute_tgservice"] = "no"
  end
end]]
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_inline"] then
    data[tostring(target)]["mutes"]["mute_inline"] = "no"
  end
end
--[[if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_game"] then
    data[tostring(target)]["mutes"]["mute_game"] = "no"
  end
end]]

  --text = "*تنظیمات گروه:*\n_قفل ویرایش پیام :_ *"..settings.lock_edit.."*\n_قفل لینک :_ *"..settings.lock_link.."*\n_قفل تگ :_ *"..settings.lock_tag.."*\n_قفل پیام مکرر :_ *"..settings.flood.."*\n_قفل هرزنامه :_ *"..settings.lock_spam.."*\n_قفل فراخوانی :_ *"..settings.lock_mention.."*\n_قفل صفحات وب :_ *"..settings.lock_webpage.."*\n_قفل فونت :_ *"..settings.lock_markdown.."*\n_محافظت در برابر ربات ها :_ *"..settings.lock_bots.."*\n_حداکثر پیام مکرر :_ *"..NUM_MSG_MAX.."*\n*____________________*\n*Bot channel*: @BeyondTeam\n_زبان سوپرگروه_ : *FA*"
  text = "⚙ `تنظیمات گروه` \n\n[🔐] قفل های عادی :\n▪️ قفل _#لینک_ : "..settings.lock_link.."\n▪️ قفل _#فروارد_ : "..mutes.mute_forward.."\n▪️ قفل _#نام کاربری_ : yes\n▪️ قفل _#تگ_ : "..settings.lock_tag.."\n▪️ قفل _#ویرایش پیام_ : "..settings.lock_edit.."\n▪️ قفل _#کیبورد شیشه ای_ : "..mutes.mute_inline.."\n▪️ قفل _#رگباری_ : "..settings.flood.."\n▪️ قفل _#حساسیت رگباری_ : "..NUM_MSG_MAX.."\n▪️ قفل _#پیام طولانی_ : "..settings.lock_spam.."\n▪️ قفل _#ربات_ : "..settings.lock_bots.."\n\n[🔏] قفل های رسانه :\n▫️ قفل _#عکس_ : "..mutes.mute_photo.."\n▫️ قفل _#فیلم_ : "..mutes.mute_video.."\n▫️ قفل _#گیف_ : "..mutes.mute_gif.."\n▫️ قفل _#فایل_ : "..mutes.mute_document.."\n▫️ قفل _#گروه_ : "..mutes.mute_all.."\n"
  text = text:gsub("yes", "فعال|🔒")  
  text = text:gsub("no", "غیرفعال|🔓")      
return text
end
end

----------MuteList---------
--[[local function mutes(msg, target)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
if not is_mod(msg) then
  if lang then
    return "_You're Not_ *Moderator*"
  else
    return "شما مدیر گروه نیستید"
  end
end
local data = load_data(_config.moderation.data)
local target = msg.chat_id_
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_all"] then
    data[tostring(target)]["mutes"]["mute_all"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_gif"] then
    data[tostring(target)]["mutes"]["mute_gif"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_text"] then
    data[tostring(target)]["mutes"]["mute_text"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_photo"] then
    data[tostring(target)]["mutes"]["mute_photo"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_video"] then
    data[tostring(target)]["mutes"]["mute_video"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_audio"] then
    data[tostring(target)]["mutes"]["mute_audio"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_voice"] then
    data[tostring(target)]["mutes"]["mute_voice"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_sticker"] then
    data[tostring(target)]["mutes"]["mute_sticker"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_contact"] then
    data[tostring(target)]["mutes"]["mute_contact"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_forward"] then
    data[tostring(target)]["mutes"]["mute_forward"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_location"] then
    data[tostring(target)]["mutes"]["mute_location"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_document"] then
    data[tostring(target)]["mutes"]["mute_document"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_tgservice"] then
    data[tostring(target)]["mutes"]["mute_tgservice"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_inline"] then
    data[tostring(target)]["mutes"]["mute_inline"] = "no"
  end
end
if data[tostring(target)]["mutes"] then
  if not data[tostring(target)]["mutes"]["mute_game"] then
    data[tostring(target)]["mutes"]["mute_game"] = "no"
  end
end
if lang then
  local mutes = data[tostring(target)]["mutes"]
  text = " *Group Mute List* : \n_Mute all : _ *"..mutes.mute_all.."*\n_Mute gif :_ *"..mutes.mute_gif.."*\n_Mute text :_ *"..mutes.mute_text.."*\n_Mute inline :_ *"..mutes.mute_inline.."*\n_Mute game :_ *"..mutes.mute_game.."*\n_Mute photo :_ *"..mutes.mute_photo.."*\n_Mute video :_ *"..mutes.mute_video.."*\n_Mute audio :_ *"..mutes.mute_audio.."*\n_Mute voice :_ *"..mutes.mute_voice.."*\n_Mute sticker :_ *"..mutes.mute_sticker.."*\n_Mute contact :_ *"..mutes.mute_contact.."*\n_Mute forward :_ *"..mutes.mute_forward.."*\n_Mute location :_ *"..mutes.mute_location.."*\n_Mute document :_ *"..mutes.mute_document.."*\n_Mute TgService :_ *"..mutes.mute_tgservice.."*\n*____________________*\n*Bot channel*: @BeyondTeam\n*Group Language* : *EN*"
else
  local mutes = data[tostring(target)]["mutes"]
  text = " *لیست بیصدا ها* : \n_بیصدا همه : _ *"..mutes.mute_all.."*\n_بیصدا تصاویر متحرک :_ *"..mutes.mute_gif.."*\n_بیصدا متن :_ *"..mutes.mute_text.."*\n_بیصدا کیبورد شیشه ای :_ *"..mutes.mute_inline.."*\n_بیصدا بازی های تحت وب :_ *"..mutes.mute_game.."*\n_بیصدا عکس :_ *"..mutes.mute_photo.."*\n_بیصدا فیلم :_ *"..mutes.mute_video.."*\n_بیصدا آهنگ :_ *"..mutes.mute_audio.."*\n_بیصدا صدا :_ *"..mutes.mute_voice.."*\n_بیصدا برچسب :_ *"..mutes.mute_sticker.."*\n_بیصدا مخاطب :_ *"..mutes.mute_contact.."*\n_بیصدا نقل قول :_ *"..mutes.mute_forward.."*\n_بیصدا موقعیت :_ *"..mutes.mute_location.."*\n_بیصدا اسناد :_ *"..mutes.mute_document.."*\n_بیصدا خدمات تلگرام :_ *"..mutes.mute_tgservice.."*\n*____________________*\n*Bot channel*: @BeyondTeam\n_زبان سوپرگروه_ : *FA*"
end
return text
end]]

local function run(msg, matches)
local hash = "gp_lang:"..msg.chat_id_
local lang = redis:get(hash)
local data = load_data(_config.moderation.data)
local chat = msg.chat_id_
local user = msg.sender_user_id_
if matches[1]:lower() == "id" or matches[1] == "شناسه" then
  chat = chat:gsub("-100", "")    
  if not matches[2] and tonumber(msg.reply_to_message_id_) == 0 then
    return "_شناسه شما_ : [*"..user.."*]\n _شناسه گروه_ : [*"..chat.."*]"
  end
  if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
    tdcli_function ({
      ID = "GetMessage",
      chat_id_ = msg.chat_id_,
      message_id_ = msg.reply_to_message_id_
    }, action_by_reply, {chat_id=msg.chat_id_,cmd="id"})
  end
  if matches[2] and tonumber(msg.reply_to_message_id_) == 0 then
    tdcli_function ({
      ID = "SearchPublicChat",
      username_ = matches[2]:lower()
    }, action_by_username, {chat_id=msg.chat_id_,username=matches[2]:lower(),cmd="id"})
  end
end
if matches[1]:lower() == "pin" or matches[1] == "سنجاق" and is_mod(msg) and tonumber(msg.reply_to_message_id_) ~= 0 then
    tdcli.pinChannelMessage(msg.chat_id_, msg.reply_to_message_id_, 1, dl_cb)
    return "📌 پیام سنجاق شد !"
end
if matches[1]:lower() == "unpin" or matches[1] == "حذف سنجاق" and is_mod(msg) then
    tdcli.unpinChannelMessage(msg.chat_id_, dl_cb)
    return "🗑 پیام سنجاق شده، از سنجاق در آمد !"
end
if matches[1]:lower() == "add" or matches[1] == "افزودن" then
  return modadd(msg)
end
if matches[1]:lower() == "rem" or matches[1] == "حذف گروه" then
  return modrem(msg)
end
if matches[1]:lower() == "setowner" and is_admin(msg) then
  if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
    tdcli_function ({
      ID = "GetMessage",
      chat_id_ = msg.chat_id_,
      message_id_ = msg.reply_to_message_id_
    }, action_by_reply, {chat_id=msg.chat_id_,cmd="setowner"})
  end
  if matches[2] and string.match(matches[2]:lower(), '^%d+$') then
    tdcli_function ({
      ID = "GetUser",
      user_id_ = matches[2]:lower(),
    }, action_by_id, {chat_id=msg.chat_id_,user_id=matches[2]:lower(),cmd="setowner"})
  end
  if matches[2] and not string.match(matches[2]:lower(), '^%d+$') then
    tdcli_function ({
      ID = "SearchPublicChat",
      username_ = matches[2]:lower()
    }, action_by_username, {chat_id=msg.chat_id_,username=matches[2]:lower(),cmd="setowner"})
  end
end
if matches[1]:lower() == "remowner" and is_admin(msg) then
  if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
    tdcli_function ({
      ID = "GetMessage",
      chat_id_ = msg.chat_id_,
      message_id_ = msg.reply_to_message_id_
    }, action_by_reply, {chat_id=msg.chat_id_,cmd="remowner"})
  end
  if matches[2] and string.match(matches[2]:lower(), '^%d+$') then
    tdcli_function ({
      ID = "GetUser",
      user_id_ = matches[2]:lower(),
    }, action_by_id, {chat_id=msg.chat_id_,user_id=matches[2]:lower(),cmd="remowner"})
  end
  if matches[2] and not string.match(matches[2]:lower(), '^%d+$') then
    tdcli_function ({
      ID = "SearchPublicChat",
      username_ = matches[2]:lower()
    }, action_by_username, {chat_id=msg.chat_id_,username=matches[2]:lower(),cmd="remowner"})
  end
end
if matches[1]:lower() == "promote" and is_owner(msg) then
  if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
    tdcli_function ({
      ID = "GetMessage",
      chat_id_ = msg.chat_id_,
      message_id_ = msg.reply_to_message_id_
    }, action_by_reply, {chat_id=msg.chat_id_,cmd="promote"})
  end
  if matches[2] and string.match(matches[2]:lower(), '^%d+$') then
    tdcli_function ({
      ID = "GetUser",
      user_id_ = matches[2]:lower(),
    }, action_by_id, {chat_id=msg.chat_id_,user_id=matches[2]:lower(),cmd="promote"})
  end
  if matches[2] and not string.match(matches[2]:lower(), '^%d+$') then
    tdcli_function ({
      ID = "SearchPublicChat",
      username_ = matches[2]:lower()
    }, action_by_username, {chat_id=msg.chat_id_,username=matches[2]:lower(),cmd="promote"})
  end
end
if matches[1]:lower() == "demote" and is_owner(msg) then
  if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
    tdcli_function ({
      ID = "GetMessage",
      chat_id_ = msg.chat_id_,
      message_id_ = msg.reply_to_message_id_
    }, action_by_reply, {chat_id=msg.chat_id_,cmd="demote"})
  end
  if matches[2] and string.match(matches[2]:lower(), '^%d+$') then
    tdcli_function ({
      ID = "GetUser",
      user_id_ = matches[2]:lower(),
    }, action_by_id, {chat_id=msg.chat_id_,user_id=matches[2]:lower(),cmd="demote"})
  end
  if matches[2] and not string.match(matches[2]:lower(), '^%d+$') then
    tdcli_function ({
      ID = "SearchPublicChat",
      username_ = matches[2]:lower()
    }, action_by_username, {chat_id=msg.chat_id_,username=matches[2]:lower(),cmd="demote"})
  end
end

if matches[1]:lower() == "lock" and is_mod(msg) then
  local target = msg.chat_id_
  if matches[2] == "links" then
    return lock_link(msg, data, target)
  end
  if matches[2] == "tag" then
    return lock_tag(msg, data, target)
  end
  --[[if matches[2] == "mention" then
    return lock_mention(msg, data, target)
  end]]
  if matches[2] == "edit" then
    return lock_edit(msg, data, target)
  end
  if matches[2] == "spam" then
    return lock_spam(msg, data, target)
  end
  if matches[2] == "flood" then
    return lock_flood(msg, data, target)
  end
  if matches[2] == "bots" then
    return lock_bots(msg, data, target)
  end
  --[[if matches[2] == "markdown" then
    return lock_markdown(msg, data, target)
  end]]
 --[[ if matches[2] == "webpage" then
    return lock_webpage(msg, data, target)
  end]]

  if matches[2] == "all" then
    return mute_all(msg, data, target)
  end
  if matches[2] == "gif" then
    return mute_gif(msg, data, target)
  end
  if matches[2] == "text" then
    return mute_text(msg ,data, target)
  end
  if matches[2] == "photo" then
    return mute_photo(msg ,data, target)
  end
  if matches[2] == "video" then
    return mute_video(msg ,data, target)
  end
  if matches[2] == "audio" then
    return mute_audio(msg ,data, target)
  end
  if matches[2] == "voice" then
    return mute_voice(msg ,data, target)
  end
  if matches[2] == "sticker" then
    return mute_sticker(msg ,data, target)
  end
  if matches[2] == "contact" then
    return mute_contact(msg ,data, target)
  end
  if matches[2] == "fwd" then
    return mute_forward(msg ,data, target)
  end
  --[[if matches[2] == "location" then
    return mute_location(msg ,data, target)
  end]]
  if matches[2] == "file" then
    return mute_document(msg ,data, target)
  end
  --[[if matches[2] == "tgservice" then
    return mute_tgservice(msg ,data, target)
  end]]
  if matches[2] == "inline" then
    return mute_inline(msg ,data, target)
  end
  --[[if matches[2] == "game" then
    return mute_game(msg ,data, target)
  end]]
end

if matches[1]:lower() == "unlock" and is_mod(msg) then
  local target = msg.chat_id_
  if matches[2] == "links" then
    return unlock_link(msg, data, target)
  end
  if matches[2] == "tag" then
    return unlock_tag(msg, data, target)
  end
  --[[if matches[2] == "mention" then
    return unlock_mention(msg, data, target)
  end]]
  if matches[2] == "edit" then
    return unlock_edit(msg, data, target)
  end
  if matches[2] == "spam" then
    return unlock_spam(msg, data, target)
  end
  if matches[2] == "flood" then
    return unlock_flood(msg, data, target)
  end
  if matches[2] == "bots" then
    return unlock_bots(msg, data, target)
  end
  --[[if matches[2] == "markdown" then
    return unlock_markdown(msg, data, target)
  end
  if matches[2] == "webpage" then
    return unlock_webpage(msg, data, target)
  end]]

  if matches[2] == "all" then
    return unmute_all(msg, data, target)
  end
  if matches[2] == "gif" then
    return unmute_gif(msg, data, target)
  end
  if matches[2] == "text" then
    return unmute_text(msg, data, target)
  end
  if matches[2] == "photo" then
    return unmute_photo(msg ,data, target)
  end
  if matches[2] == "video" then
    return unmute_video(msg ,data, target)
  end
  if matches[2] == "audio" then
    return unmute_audio(msg ,data, target)
  end
  if matches[2] == "voice" then
    return unmute_voice(msg ,data, target)
  end
  if matches[2] == "sticker" then
    return unmute_sticker(msg ,data, target)
  end
  if matches[2] == "contact" then
    return unmute_contact(msg ,data, target)
  end
  if matches[2] == "fwd" then
    return unmute_forward(msg ,data, target)
  end
  --if matches[2] == "location" then
  --  return unmute_location(msg ,data, target)
  --end
  if matches[2] == "file" then
    return unmute_document(msg ,data, target)
  end
  --if matches[2] == "tgservice" then
  --  return unmute_tgservice(msg ,data, target)
 -- end
  if matches[2] == "inline" then
    return unmute_inline(msg ,data, target)
  end
 -- if matches[2] == "game" then
  --  return unmute_game(msg ,data, target)
  --end
end

if matches[1]:lower() == "gpinfo" or matches[1] == "اطلاعات گروه" and is_mod(msg) and gp_type(msg.chat_id_) == "channel" then
  local function group_info(arg, data)
    ginfo = "📃 `اطلاعات گروه` :\n🌟 _تعداد ادمین ها_ : *"..data.administrator_count_.."*\n🔢 _تعداد اعضا_ : *"..data.member_count_.."*\n♨️ _تعداد اعضای اخراج شده_ : *"..data.kicked_count_.."*\n"
    tdcli.sendMessage(arg.chat_id, arg.msg_id, 1, ginfo, 1, 'md')
  end
    
  tdcli.getChannelFull(msg.chat_id_, group_info, {chat_id=msg.chat_id_,msg_id=msg.id_})
end
  
if matches[1]:lower() == 'setlink' and is_mod(msg) then
  data[tostring(chat)]['settings']['linkgp'] = 'waiting'
  save_data(_config.moderation.data, data)
    return '❇️ _لینک گروه را بفرستید_ :'
end
    
--[[local function gg(arg, data)
  print(serpent.block(data))
   local text = "test\n" 
    for v,i in pairs(data.members_) do
			--tdlib.changeChatMemberStatus(msg.chat_id_, i.user_id_, 'Kicked')
      text = text..i.user_id_
    end
  
  tdcli.sendMessage(arg.chat_id, 0, 0, text , 0, "md")
end]]
	
local function gg(extra, result)
  tdcli.sendMessage(extra.chat_id, 0, 0, result.members_, 0, "md")
end	
if matches[1] == "idfrom" then
   --tdcli.getMessage(msg.chat_id_, msg.reply_to_message_id_, gg, {chat_id=msg.chat_id_}) 
   tdcli.getChannelMembers(msg.chat_id_, 0, 'Administrators', 200, gg, {chat_id=msg.chat_id})
end    
  
if msg.content_.text_ then
  local is_link = msg.content_.text_:match("^([https?://w]*.?telegram.me/joinchat/%S+)$") or msg.content_.text_:match("^([https?://w]*.?t.me/joinchat/%S+)$")
  if is_link and data[tostring(chat)]['settings']['linkgp'] == 'waiting' and is_mod(msg) then
    data[tostring(chat)]['settings']['linkgp'] = msg.content_.text_
    save_data(_config.moderation.data, data)
      return "لینک جدید ذخیره شد"
  end
end
if matches[1]:lower() == 'link' and is_mod(msg) then
  local linkgp = data[tostring(chat)]['settings']['linkgp']
  if not linkgp then
    if lang then
      return "_First set a link for group with using_ /setlink"
    else
      return "اول لینک گروه خود را ذخیره کنید با /setlink"
    end
  end
  if lang then
    text = "<b>Group Link :</b>\n"..linkgp
  else
    text = "<b>لینک گروه :</b>\n"..linkgp
  end
  return tdcli.sendMessage(chat, msg.id_, 1, text, 1, 'html')
end
if matches[1]:lower() == "setrules" and matches[2]:lower() and is_mod(msg) then
  data[tostring(chat)]['rules'] = matches[2]:lower()
  save_data(_config.moderation.data, data)
  if lang then
    return "*Group rules* _has been set_"
  else
    return "قوانین گروه ثبت شد"
  end
end
if matches[1]:lower() == "rules" then
  if not data[tostring(chat)]['rules'] then
    if lang then
      rules = "ℹ️ The Default Rules :\n1⃣ No Flood.\n2⃣ No Spam.\n3⃣ No Advertising.\n4⃣ Try to stay on topic.\n5⃣ Forbidden any racist, sexual, homophobic or gore content.\n➡️ Repeated failure to comply with these rules will cause ban.\n@BeyondTeam"
    elseif lang then
      rules = "ℹ️ قوانین پپیشفرض:\n1⃣ ارسال پیام مکرر ممنوع.\n2⃣ اسپم ممنوع.\n3⃣ تبلیغ ممنوع.\n4⃣ سعی کنید از موضوع خارج نشید.\n5⃣ هرنوع نژاد پرستی, شاخ بازی و پورنوگرافی ممنوع .\n➡️ از قوانین پیروی کنید, در صورت عدم رعایت قوانین اول اخطار و در صورت تکرار مسدود.\n@BeyondTeam"
    end
  else
    rules = "*Group Rules :*\n"..data[tostring(chat)]['rules']
  end
  return rules
end
if matches[1]:lower() == "res" and matches[2]:lower() and is_mod(msg) then
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = matches[2]:lower()
  }, action_by_username, {chat_id=msg.chat_id_,username=matches[2]:lower(),cmd="res"})
end
if matches[1]:lower() == "whois" and matches[2]:lower() and is_mod(msg) then
  tdcli_function ({
    ID = "GetUser",
    user_id_ = matches[2]:lower(),
  }, action_by_id, {chat_id=msg.chat_id_,user_id=matches[2]:lower(),cmd="whois"})
end
if matches[1]:lower() == 'setflood' and is_mod(msg) then
  if tonumber(matches[2]:lower()) < 1 or tonumber(matches[2]:lower()) > 50 then
    return "_Wrong number, range is_ *[1-50]*"
  end
  local flood_max = matches[2]:lower()
  local data = load_data(_config.moderation.data)
  data[tostring(msg.chat_id_)]['settings']['num_msg_max'] = flood_max
  save_data(_config.moderation.data, data)
  return "_Group_ *flood* _sensitivity has been set to :_ *[ "..matches[2]:lower().." ]*"
end
if matches[1]:lower():lower() == 'clean' and is_owner(msg) then
  if matches[2] == 'mods' then
    if next(data[tostring(chat)]['mods']) == nil then
      if lang then
        return "_No_ *moderators* _in this group_"
      else
        return "هیچ مدیری برای گروه انتخاب نشده است"
      end
    end
    for k,v in pairs(data[tostring(chat)]['mods']) do
      data[tostring(chat)]['mods'][tostring(k)] = nil
      save_data(_config.moderation.data, data)
    end
    if lang then
      return "_All_ *moderators* _has been demoted_"
    else
      return "تمام مدیران گروه تنزیل مقام شدند"
    end
  end
  if matches[2] == 'rules' then
    if not data[tostring(chat)]['rules'] then
      if lang then
        return "_No_ *rules* _available_"
      else
        return "قوانین برای گروه ثبت نشده است"
      end
    end
    data[tostring(chat)]['rules'] = nil
    save_data(_config.moderation.data, data)
    if lang then
      return "*Group rules* _has been cleaned_"
    else
      return "قوانین گروه پاک شد"
    end
  end
  if matches[2] == 'about' then
    if gp_type(chat) == "chat" then
      if not data[tostring(chat)]['about'] then
        if lang then
          return "_No_ *description* _available_"
        else
          return "پیامی مبنی بر درباره گروه ثبت نشده است"
        end
      end
      data[tostring(chat)]['about'] = nil
      save_data(_config.moderation.data, data)
    elseif gp_type(chat) == "channel" then
      tdcli.changeChannelAbout(chat, "", dl_cb, nil)
    end
    if lang then
      return "*Group description* _has been cleaned_"
    else
      return "پیام مبنی بر درباره گروه پاک شد"
    end
  end
end
if matches[1]:lower():lower() == 'clean' and is_admin(msg) then
  if matches[2] == 'owners' then
    if next(data[tostring(chat)]['owners']) == nil then
      if lang then
        return "_No_ *owners* _in this group_"
      else
        return "مالکی برای گروه انتخاب نشده است"
      end
    end
    for k,v in pairs(data[tostring(chat)]['owners']) do
      data[tostring(chat)]['owners'][tostring(k)] = nil
      save_data(_config.moderation.data, data)
    end
    if lang then
      return "_All_ *owners* _has been demoted_"
    else
      return "تمامی مالکان گروه تنزیل مقام شدند"
    end
  end
end
if matches[1]:lower() == "setname" and matches[2]:lower() and is_mod(msg) then
  local gp_name = matches[2]:lower()
  tdcli.changeChatTitle(chat, gp_name, dl_cb, nil)
end
if matches[1]:lower() == "setabout" and matches[2]:lower() and is_mod(msg) then
  if gp_type(chat) == "channel" then
    tdcli.changeChannelAbout(chat, matches[2]:lower(), dl_cb, nil)
  elseif gp_type(chat) == "chat" then
    data[tostring(chat)]['about'] = matches[2]:lower()
    save_data(_config.moderation.data, data)
  end
  if lang then
    return "*Group description* _has been set_"
  else
    return "پیام مبنی بر درباره گروه ثبت شد"
  end
end
if matches[1]:lower() == "about" and gp_type(chat) == "chat" then
  if not data[tostring(chat)]['about'] then
    if lang then
      about = "_No_ *description* _available_"
    elseif lang then
      about = "پیامی مبنی بر درباره گروه ثبت نشده است"
    end
  else
    about = "*Group Description :*\n"..data[tostring(chat)]['about']
  end
  return about
end
if matches[1]:lower() == "settings" then
  return group_settings(msg, target)
end
if matches[1]:lower() == "mutelist" then
  return mutes(msg, target)
end
if matches[1]:lower() == "modlist" then
  return modlist(msg)
end
if matches[1]:lower() == "ownerlist" and is_owner(msg) then
  return ownerlist(msg)
end

if matches[1]:lower() == "setlang" and is_owner(msg) then
  if matches[2] == "en" then
    local hash = "gp_lang:"..msg.chat_id_
    local lang = redis:get(hash)
    redis:del(hash)
    return "_Group Language Set To:_ EN"
  elseif matches[2] == "fa" then
    redis:set(hash, true)
    return "*زبان گروه تنظیم شد به : فارسی*"
  end
end

if matches[1]:lower() == "help" and is_mod(msg) then
  if lang then
    text = [[
    *Beyond Bot Commands:*
    *!setowner* `[username|id|reply]`
    _Set Group Owner(Multi Owner)_
    *!remowner* `[username|id|reply]`
    _Remove User From Owner List_
    *!promote* `[username|id|reply]`
    _Promote User To Group Admin_
    *!demote* `[username|id|reply]`
    _Demote User From Group Admins List_
    *!setflood* `[1-50]`
    _Set Flooding Number_
    *!silent* `[username|id|reply]`
    _Silent User From Group_
    *!unsilent* `[username|id|reply]`
    _Unsilent User From Group_
    *!kick* `[username|id|reply]`
    _Kick User From Group_
    *!ban* `[username|id|reply]`
    _Ban User From Group_
    *!unban* `[username|id|reply]`
    _UnBan User From Group_
    *!res* `[username]`
    _Show User ID_
    *!id* `[reply]`
    _Show User ID_
    *!whois* `[id]`
    _Show User's Username And Name_
    *!lock* `[link | tag | edit | webpage | bots | spam | flood | markdown | mention]`
    _If This Actions Lock, Bot Check Actions And Delete Them_
    *!unlock* `[link | tag | edit | webpage | bots | spam | flood | markdown | mention]`
    _If This Actions Unlock, Bot Not Delete Them_
    *!mute* `[gifs | photo | document | sticker | video | text | forward | location | audio | voice | contact | all]`
    _If This Actions Lock, Bot Check Actions And Delete Them_
    *!unmute* `[gifs | photo | document | sticker | video | text | forward | location | audio | voice | contact | all]`
    _If This Actions Unlock, Bot Not Delete Them_
    *!set*`[rules | name | photo | link | about]`
    _Bot Set Them_
    *!clean* `[bans | mods | bots | rules | about | silentlist]`
    _Bot Clean Them_
    *!pin* `[reply]`
    _Pin Your Message_
    *!unpin*
    _Unpin Pinned Message_
    *!settings*
    _Show Group Settings_
    *!mutelist*
    _Show Mutes List_
    *!silentlist*
    _Show Silented Users List_
    *!banlist*
    _Show Banned Users List_
    *!ownerlist*
    _Show Group Owners List_
    *!modlist*
    _Show Group Moderators List_
    *!rules*
    _Show Group Rules_
    *!about*
    _Show Group Description_
    *!id*
    _Show Your And Chat ID_
    *!gpinfo*
    _Show Group Information_
    *!link*
    _Show Group Link_
    *!setwelcome [text]*
    _set Welcome Message_
    _You Can Use_ *[!/#]* _To Run The Commands_
    _This Help List Only For_ *Moderators/Owners!*
    _Its Means, Only Group_ *Moderators/Owners* _Can Use It!_
    *Good luck ;)*]]

  elseif lang then

    text = [[
    *دستورات ربات بیوند:*
    *!setowner* `[username|id|reply]`
    _انتخاب مالک گروه(قابل انتخاب چند مالک)_
    *!remowner* `[username|id|reply]`
    _حذف کردن فرد از فهرست مالکان گروه_
    *!promote* `[username|id|reply]`
    _ارتقا مقام کاربر به مدیر گروه_
    *!demote* `[username|id|reply]`
    _تنزیل مقام مدیر به کاربر_
    *!setflood* `[1-50]`
    _تنظیم حداکثر تعداد پیام مکرر_
    *!silent* `[username|id|reply]`
    _بیصدا کردن کاربر در گروه_
    *!unsilent* `[username|id|reply]`
    _در آوردن کاربر از حالت بیصدا در گروه_
    *!kick* `[username|id|reply]`
    _حذف کاربر از گروه_
    *!ban* `[username|id|reply]`
    _مسدود کردن کاربر از گروه_
    *!unban* `[username|id|reply]`
    _در آوردن از حالت مسدودیت کاربر از گروه_
    *!res* `[username]`
    _نمایش شناسه کاربر_
    *!id* `[reply]`
    _نمایش شناسه کاربر_
    *!whois* `[id]`
    _نمایش نام کاربر, نام کاربری و اطلاعات حساب_
    *!lock* `[link | tag | edit | webpage | bots | spam | flood | markdown | mention]`
    _در صورت قفل بودن فعالیت ها, ربات آنهارا حذف خواهد کرد_
    *!unlock* `[link | tag | edit | webpage | bots | spam | flood | markdown | mention]`
    _در صورت قفل نبودن فعالیت ها, ربات آنهارا حذف نخواهد کرد_
    *!mute* `[gifs | photo | document | sticker | video | text | forward | location | audio | voice | contact | all]`
    _در صورت بیصدد بودن فعالیت ها, ربات آنهارا حذف خواهد کرد_
    *!unmute* `[gifs | photo | document | sticker | video | text | forward | location | audio | voice | contact | all]`
    _در صورت بیصدا نبودن فعالیت ها, ربات آنهارا حذف نخواهد کرد_
    *!set*`[rules | name | photo | link | about]`
    _ربات آنهارا ثبت خواهد کرد_
    *!clean* `[bans | mods | bots | rules | about | silentlist]`
    _ربات آنهارا پاک خواهد کرد_
    *!pin* `[reply]`
    _ربات پیام شمارا در گروه سنجاق خواهد کرد_
    *!unpin*
    _ربات پیام سنجاق شده در گروه را حذف خواهد کرد_
    *!settings*
    _نمایش تنظیمات گروه_
    *!mutelist*
    _نمایش فهرست بیصدا های گروه_
    *!silentlist*
    _نمایش فهرست افراد بیصدا_
    *!banlist*
    _نمایش افراد مسدود شده از گروه_
    *!ownerlist*
    _نمایش فهرست مالکان گروه_
    *!modlist*
    _نمایش فهرست مدیران گروه_
    *!rules*
    _نمایش قوانین گروه_
    *!about*
    _نمایش درباره گروه_
    *!id*
    _نمایش شناسه شما و گروه_
    *!gpinfo*
    _نمایش اطلاعات گروه_
    *!link*
    _نمایش لینک گروه_
    *!setwelcome [text]*
    _ثبت پیام خوش آمد گویی_
    _شما میتوانید از [!/#] در اول دستورات برای اجرای آنها بهره بگیرید
    این راهنما فقط برای مدیران/مالکان گروه میباشد!
    این به این معناست که فقط مدیران/مالکان گروه میتوانند از دستورات بالا استفاده کنند!_
    *موفق باشید ;)*]]
  end
  return text
end
--------------------- Welcome -----------------------
local lang = redis:get("gp_lang:"..msg.chat_id_)
----------------------------------------
if matches[1]:lower() == 'setwelcome' and matches[2]:lower() then
  if lang then
    welcome = check_markdown(matches[2]:lower())
    redis:hset('beyond_welcome',msg.chat_id_,tostring(welcome))
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'Welcome Message Seted :\n\n'..matches[2]:lower(), 1, 'md')
  else
    welcome = check_markdown(matches[2]:lower())
    redis:hset('beyond_welcome',msg.chat_id_,tostring(welcome))
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'پیام خوش آمد ثبت شد:\n\n'..matches[2]:lower(), 1, 'md')
  end
end
-----------------------------------------
if matches[1]:lower() == 'delwelcome' then
  if lang then
    if not redis:hget('beyond_welcome',msg.chat_id_) then
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'Already No welcome message available!', 1, 'md')
    else
      redis:hdel('beyond_welcome',msg.chat_id_)
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'Weclome Message Deleted!', 1, 'md')
    end
  else
    if not redis:hget('beyond_welcome',msg.chat_id_) then
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'در حال حاضر هیچ پیام خوش آمد گویی وجود ندارد !', 1, 'md')
    else
      welcome = check_markdown(matches[2]:lower())
      redis:hdel('beyond_welcome',msg.chat_id_)
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'پیام خوش آمد گویی حذف شد', 1, 'md')
    end
  end
end
end
-----------------------------------------
local function pre_process(msg)
if msg.content_.members_ then
  if redis:hget('beyond_welcome',msg.chat_id_) then
    if msg.content_.members_[0] then
      name = msg.content_.members_[0].first_name_
      if msg.content_.members_[0].type_.ID == 'UserTypeBot' then
        return nil
      else
        data = redis:hget('beyond_welcome',msg.chat_id_)
        if data:match('{name}') then
          out = data:gsub('{name}',name)
        else
          out = data
        end
        tdcli.sendMessage(msg.chat_id_, msg.id_, 1, tostring(out:gsub('\\_','_')), 1, 'md')
      end
    end
  end
end
end
return {
patterns ={
  "^([Ii][Dd])$",
  "^(شناسه)$",    
  "^([Ii][Dd]) (.*)$",
  "^(شناسه) (.*)$",  
    
  "^([Pp][Ii][Nn])$",
  "^(سنجاق)$",
  "^([Uu][Nn][Pp][Ii][Nn])$",
  "^(حذف سنجاق)$",
    
  "^([Gg][Pp][Ii][Nn][Ff][Oo])$",
  "^(اطلاعات گروه)$",
    
  --"^(test)$",
  "^(add)$",
  "^(rem)$",
  "^(setowner)$",
  "^(setowner) (.*)$",
  "^(remowner)$",
  "^(remowner) (.*)$",
  "^(promote)$",
  "^(promote) (.*)$",
  "^(demote)$",
  "^(demote) (.*)$",
  "^(modlist)$",
  "^(ownerlist)$",
  "^(lock) (.*)$",
  "^(unlock) (.*)$",
  "^(settings)$",
  "^(inv)$",    
  "^(mutelist)$",
  "^(link)$",
  "^(setlink)$",
  "^(idfrom)$",      
  "^(rules)$",
  "^(setrules) (.*)$",
  "^(about)$",
  --"^(setabout) (.*)$",
  "^(setname) (.*)$",
  "^(clean) (.*)$",
  "^(setflood) (%d+)$",
  --"^(res) (.*)$",
  "^(whois) (%d+)$",
  --"^(help)$",
  --"^(setlang) (.*)$",
  "^([https?://w]*.?t.me/joinchat/%S+)$",
  "^([https?://w]*.?telegram.me/joinchat/%S+)$",
  --"^(setwelcome) (.*)",
  --"^(delwelcome)$"
},
run=run,
--pre_process = pre_process
}
