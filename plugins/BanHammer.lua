local function pre_process(msg)
  chat = msg.chat_id_
  user = msg.sender_user_id_
  local function check_newmember(arg, data)
    test = load_data(_config.moderation.data)
    local hash = "gp_lang:"..arg.chat_id
    local lang = redis:get(hash)
    if data.type_.ID == "UserTypeBot" then
      if not is_owner(arg.msg) then
        kick_user(data.id_, arg.chat_id)
      end
    end
if data.username_ then
 user_name = '@'..check_markdown(data.username_)
 else
 user_name = check_markdown(data.first_name_)
end
    if is_banned(data.id_, arg.chat_id) then
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." از گروه محروم است !", "md")
      kick_user(data.id_, arg.chat_id)
    end
    if is_gbanned(data.id_) then
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." سوپر بن است !", "md")
      kick_user(data.id_, arg.chat_id)
    end
  end
  if msg.adduser then
    tdcli_function ({
      ID = "GetUser",
      user_id_ = msg.adduser
    }, check_newmember, {chat_id=chat,msg_id=msg.id_,user_id=user,msg=msg})
  end
  if msg.joinuser then
    tdcli_function ({
      ID = "GetUser",
      user_id_ = msg.joinuser
    }, check_newmember, {chat_id=chat,msg_id=msg.id_,user_id=user,msg=msg})
  end
  if is_silent_user(user, chat) then
    del_msg(msg.chat_id_, msg.id_)
  end
  if is_banned(user, chat) then
    del_msg(msg.chat_id_, tonumber(msg.id_))
    kick_user(user, chat)
  end
  if is_gbanned(user) then
    del_msg(msg.chat_id_, tonumber(msg.id_))
    kick_user(user, chat)
  end
end
local function action_by_reply(arg, data)
  local hash = "gp_lang:"..data.chat_id_
  local lang = redis:get(hash)
  local cmd = arg.cmd
  if not tonumber(data.sender_user_id_) then return false end
  if cmd == "ban" then
    local function ban_cb(arg, data)
      local hash = "gp_lang:"..arg.chat_id
      local lang = redis:get(hash)
      local administration = load_data(_config.moderation.data)
      if data.username_ then
        user_name = '@'..check_markdown(data.username_)
      else
        user_name = check_markdown(data.first_name_)
      end
      if is_mod1(arg.chat_id, data.id_) then
          return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ _شما نمی توانید مدیران را محروم کنید_ !", 0, "md")
      end
      if administration[tostring(arg.chat_id)]['banned'][tostring(data.id_)] then
        return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." از گروه محروم است !", "md")
      end
      administration[tostring(arg.chat_id)]['banned'][tostring(data.id_)] = user_name
      save_data(_config.moderation.data, administration)
      kick_user(data.id_, arg.chat_id)
      return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⛔️ کاربر [*"..data.id_.."*] "..user_name.." از گروه محروم شد !", "md")
    end
    tdcli_function ({
      ID = "GetUser",
      user_id_ = data.sender_user_id_
    }, ban_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
  end
  if cmd == "unban" then
    local function unban_cb(arg, data)
      local hash = "gp_lang:"..arg.chat_id
      local lang = redis:get(hash)
      local administration = load_data(_config.moderation.data)
      if data.username_ then
        user_name = '@'..check_markdown(data.username_)
      else
        user_name = check_markdown(data.first_name_)
      end
      if not administration[tostring(arg.chat_id)]['banned'][tostring(data.id_)] then
       tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." از گروه محروم نیست !", "md")
      end
      administration[tostring(arg.chat_id)]['banned'][tostring(data.id_)] = nil
      save_data(_config.moderation.data, administration)
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "❌ کاربر [*"..data.id_.."*] "..user_name.." از محرومیت در آمد !", "md")
      end
    tdcli_function ({
      ID = "GetUser",
      user_id_ = data.sender_user_id_
    }, unban_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
  end
  if cmd == "silent" then
    local function silent_cb(arg, data)
      local hash = "gp_lang:"..arg.chat_id
      local lang = redis:get(hash)
      local administration = load_data(_config.moderation.data)
      if data.username_ then
        user_name = '@'..check_markdown(data.username_)
      else
        user_name = check_markdown(data.first_name_)
      end
      if is_mod1(arg.chat_id, data.id_) then
          return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ _شما نمی توانید مدیران را بیصدا کنید_ !", 0, "md")
      end
      if administration[tostring(arg.chat_id)]['is_silent_users'][tostring(data.id_)] then
        tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." از قبل بیصدا است !", "md")
      end
      administration[tostring(arg.chat_id)]['is_silent_users'][tostring(data.id_)] = user_name
      save_data(_config.moderation.data, administration)
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⛔️ کاربر [*"..data.id_.."*] "..user_name.." بیصدا شد !", "md")
    end
    tdcli_function ({
      ID = "GetUser",
      user_id_ = data.sender_user_id_
    }, silent_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
  end
  if cmd == "unsilent" then
    local function unsilent_cb(arg, data)
      local hash = "gp_lang:"..arg.chat_id
      local lang = redis:get(hash)
      local administration = load_data(_config.moderation.data)
      if data.username_ then
        user_name = '@'..check_markdown(data.username_)
      else
        user_name = check_markdown(data.first_name_)
      end
      if not administration[tostring(arg.chat_id)]['is_silent_users'][tostring(data.id_)] then
       tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." بیصدا نیست !", "md")
      end
      administration[tostring(arg.chat_id)]['is_silent_users'][tostring(data.id_)] = nil
      save_data(_config.moderation.data, administration)
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "❌ کاربر [*"..data.id_.."*] "..user_name.." از لیست افراد بیصدا پاک شد !", "md")
    end
    tdcli_function ({
      ID = "GetUser",
      user_id_ = data.sender_user_id_
    }, unsilent_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
  end
  if cmd == "banall" then
    local function gban_cb(arg, data)
      local hash = "gp_lang:"..arg.chat_id
      local lang = redis:get(hash)
      local administration = load_data(_config.moderation.data)
      if data.username_ then
        user_name = '@'..check_markdown(data.username_)
      else
        user_name = check_markdown(data.first_name_)
      end
      if not administration['gban_users'] then
        administration['gban_users'] = {}
        save_data(_config.moderation.data, administration)
      end
      if is_admin1(data.id_) then
          return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ _شما نمی توانید مدیران را سوپر بن کنید_ !", 0, "md")
      end
      if is_gbanned(data.id_) then
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." سوپر بن است !", "md")
      end
      administration['gban_users'][tostring(data.id_)] = user_name
      save_data(_config.moderation.data, administration)
      kick_user(data.id_, arg.chat_id)
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⛔️ کاربر [*"..data.id_.."*] "..user_name.." سوپر بن شد !", "md")
    end
    tdcli_function ({
      ID = "GetUser",
      user_id_ = data.sender_user_id_
    }, gban_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
  end
  if cmd == "unbanall" then
    local function ungban_cb(arg, data)
      local hash = "gp_lang:"..arg.chat_id
      local lang = redis:get(hash)
      local administration = load_data(_config.moderation.data)
      if data.username_ then
        user_name = '@'..check_markdown(data.username_)
      else
        user_name = check_markdown(data.first_name_)
      end
      if not administration['gban_users'] then
        administration['gban_users'] = {}
        save_data(_config.moderation.data, administration)
      end
      if not is_gbanned(data.id_) then
       tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." سوپر بن نیست !", "md")
      end
      administration['gban_users'][tostring(data.id_)] = nil
      save_data(_config.moderation.data, administration)
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "❌ کاربر [*"..data.id_.."*] "..user_name.." از سوپر بن در آمد !", "md")
    end
    tdcli_function ({
      ID = "GetUser",
      user_id_ = data.sender_user_id_
    }, ungban_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
  end
  if cmd == "kick" then
    if is_mod1(data.chat_id_, data.sender_user_id_) then
         return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ _شما نمی توانید مدیران را اخراج کنید_ !", 0, "md")
    else
      kick_user(data.sender_user_id_, data.chat_id_)
    end
  end
  if cmd == "delall" then
    if is_mod1(data.chat_id_, data.sender_user_id_) then
         return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ _شما نمی توانید پیام های مدیران را پاک کنید_ !", 0, "md")
    else
        tdcli.deleteMessagesFromUser(data.chat_id_, data.sender_user_id_, dl_cb, nil)
        return tdcli.sendMessage(data.chat_id_, "", 0, "🗑 پیام های کاربر [*"..data.sender_user_id_.."*] پاک شد !", 0, "md")
    end
  end
end
local function action_by_username(arg, data)
  local hash = "gp_lang:"..arg.chat_id
  local lang = redis:get(hash)
  local cmd = arg.cmd
  local administration = load_data(_config.moderation.data)
  if data.type_.user_.username_ then
    user_name = '@'..check_markdown(data.type_.user_.username_)
  else
    user_name = check_markdown(data.title_)
  end
  if not arg.username then return false end
  if cmd == "ban" then
    if is_mod1(arg.chat_id, data.id_) then
          return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ _شما نمی توانید مدیران را محروم کنید_ !", 0, "md")
    end
    if administration[tostring(arg.chat_id)]['banned'][tostring(data.id_)] then
        tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." از گروه محروم است !", "md")
    end
    administration[tostring(arg.chat_id)]['banned'][tostring(data.id_)] = user_name
    save_data(_config.moderation.data, administration)
    kick_user(data.id_, arg.chat_id)
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⛔️ کاربر [*"..data.id_.."*] "..user_name.." از گروه محروم شد !", "md")
  end
  if cmd == "unban" then
    if not administration[tostring(arg.chat_id)]['banned'][tostring(data.id_)] then
       tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." از گروه محروم نیست !", "md")
    end
    administration[tostring(arg.chat_id)]['banned'][tostring(data.id_)] = nil
    save_data(_config.moderation.data, administration)
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "❌ کاربر [*"..data.id_.."*] "..user_name.." از محرومیت در آمد !", "md")
  end
  if cmd == "silent" then
    if is_mod1(arg.chat_id, data.id_) then
          return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ _شما نمی توانید مدیران را بیصدا کنید_ !", 0, "md")
    end
    if administration[tostring(arg.chat_id)]['is_silent_users'][tostring(data.id_)] then
        tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." از قبل بیصدا است !", "md")
    end
    administration[tostring(arg.chat_id)]['is_silent_users'][tostring(data.id_)] = user_name
    save_data(_config.moderation.data, administration)
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⛔️ کاربر [*"..data.id_.."*] "..user_name.." بیصدا شد !", "md")
  end
  if cmd == "unsilent" then
    if not administration[tostring(arg.chat_id)]['is_silent_users'][tostring(data.id_)] then
       tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." بیصدا نیست !", "md")
    end
    administration[tostring(arg.chat_id)]['is_silent_users'][tostring(data.id_)] = nil
    save_data(_config.moderation.data, administration)
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "❌ کاربر [*"..data.id_.."*] "..user_name.." از لیست افراد بیصدا پاک شد !", "md")
  end
  if cmd == "banall" then
    if not administration['gban_users'] then
      administration['gban_users'] = {}
      save_data(_config.moderation.data, administration)
    end
    if is_admin1(data.id_) then
          return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ _شما نمی توانید مدیران را سوپر بن کنید_ !", 0, "md")
    end
    if is_gbanned(data.id_) then
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⚠️ کاربر [*"..data.id_.."*] "..user_name.." سوپر بن است !", "md")
      end
    administration['gban_users'][tostring(data.id_)] = user_name
    save_data(_config.moderation.data, administration)
    kick_user(data.id_, arg.chat_id)
      tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "⛔️ کاربر [*"..data.id_.."*] "..user_name.." سوپر بن شد !", "md")
  end
  if cmd == "unbanall" then
    if not administration['gban_users'] then
      administration['gban_users'] = {}
      save_data(_config.moderation.data, administration)
    end
    if not is_gbanned(data.id_) then
      if not lang then
        return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "_User_ "..user_name.." *"..data.id_.."* _is not_ *globally banned*", 0, "md")
      else
        return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "_کاربر_ "..user_name.." *"..data.id_.."* *از گروه های ربات محروم نبود*", 0, "md")
      end
    end
    administration['gban_users'][tostring(data.id_)] = nil
    save_data(_config.moderation.data, administration)
    if not lang then
      return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "_User_ "..user_name.." *"..data.id_.."* _has been_ *globally unbanned*", 0, "md")
    else
      return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "_کاربر_ "..user_name.." *"..data.id_.."* *از محرومیت گروه های ربات خارج شد*", 0, "md")
    end
  end
  if cmd == "kick" then
    if is_mod1(arg.chat_id, data.id_) then
      if not lang then
        return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "_You can't kick_ *mods,owners and bot admins*", 0, "md")
      elseif lang then
        return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "*شما نمیتوانید مدیران،صاحبان گروه و ادمین های ربات رو اخراج کنید*", 0, "md")
      end
    else
      kick_user(data.id_, arg.chat_id)
    end
  end
  if cmd == "delall" then
    if is_mod1(arg.chat_id, data.id_) then
      if not lang then
        return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "_You can't delete messages_ *mods,owners and bot admins*", 0, "md")
      elseif lang then
        return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "*شما نمیتوانید پیام های مدیران،صاحبان گروه و ادمین های ربات رو پاک کنید*", 0, "md")
      end
    else
      tdcli.deleteMessagesFromUser(arg.chat_id, data.id_, dl_cb, nil)
      if not lang then
        return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "_All_ *messages* _of_ "..user_name.." *[ "..data.id_.." ]* _has been_ *deleted*", 0, "md")
      elseif lang then
        return tdcli.sendMessage(arg.chat_id, arg.msg_id, 0, "*تمام پیام های* "..user_name.." *[ "..data.id_.." ]* *پاک شد*", 0, "md")
      end
    end
  end
end
local function run(msg, matches)
  local hash = "gp_lang:"..msg.chat_id_
  local lang = redis:get(hash)
  local data = load_data(_config.moderation.data)
  chat = msg.chat_id_
  user = msg.sender_user_id_
  if matches[1] == "kick" and is_mod(msg) then
    if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
      tdcli_function ({
        ID = "GetMessage",
        chat_id_ = msg.chat_id_,
        message_id_ = msg.reply_to_message_id_
      }, action_by_reply, {chat_id=msg.chat_id_,msg_id=msg.id_,cmd="kick"})
    end
    if matches[2] and string.match(matches[2], '^%d+$') then
      if is_mod1(msg.chat_id_, matches[2]) then
        if not lang then
          tdcli.sendMessage(msg.chat_id_, "", 0, "_You can't kick mods,owners or bot admins_", 0, "md")
        elseif lang then
          tdcli.sendMessage(msg.chat_id_, "", 0, "*شما نمیتوانید مدیران،صاحبان گروه و ادمین های ربات رو اخراج کنید*", 0, "md")
        end
      else
        kick_user(matches[2], msg.chat_id_)
      end
    end
    if matches[2] and not string.match(matches[2], '^%d+$') then
      tdcli_function ({
        ID = "SearchPublicChat",
        username_ = matches[2]
      }, action_by_username, {chat_id=msg.chat_id_,msg_id=msg.id_,username=matches[2],cmd="kick"})
    end
  end
  if matches[1] == "delall" and is_mod(msg) then
    if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
      tdcli_function ({
        ID = "GetMessage",
        chat_id_ = msg.chat_id_,
        message_id_ = msg.reply_to_message_id_
      }, action_by_reply, {chat_id=msg.chat_id_,msg_id=msg.id_,cmd="delall"})
    end
    if matches[2] and string.match(matches[2], '^%d+$') then
      if is_mod1(msg.chat_id_, matches[2]) then
        if not lang then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "_You can't delete messages mods,owners or bot admins_", 0, "md")
        elseif lang then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*شما نمیتوانید پیام های مدیران،صاحبان گروه و ادمین های ربات رو پاک کنید*", 0, "md")
        end
      else
        tdcli.deleteMessagesFromUser(msg.chat_id_, matches[2], dl_cb, nil)
        if not lang then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "_All_ *messages* _of_ *[ "..matches[2].." ]* _has been_ *deleted*", 0, "md")
        elseif lang then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*تمامی پیام های* *[ "..matches[2].." ]* *پاک شد*", 0, "md")
        end
      end
    end
    if matches[2] and not string.match(matches[2], '^%d+$') then
      tdcli_function ({
        ID = "SearchPublicChat",
        username_ = matches[2]
      }, action_by_username, {chat_id=msg.chat_id_,username=matches[2],msg_id=msg.id_,cmd="delall"})
    end
  end
  if matches[1] == "banall" and is_admin(msg) then
    if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
      tdcli_function ({
        ID = "GetMessage",
        chat_id_ = msg.chat_id_,
        message_id_ = msg.reply_to_message_id_
      }, action_by_reply, {chat_id=msg.chat_id_,cmd="banall"})
    end
    if matches[2] and string.match(matches[2], '^%d+$') then
      if is_admin1(matches[2]) then
        if not lang then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "_You can't globally ban other admins_", 0, "md")
        else
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*شما نمیتوانید ادمین های ربات رو از گروه های ربات محروم کنید*", 0, "md")
        end
      end
      if is_gbanned(matches[2]) then
        if not lang then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*User "..matches[2].." is already globally banned*", 0, "md")
        else
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*کاربر "..matches[2].." از گروه های ربات محروم بود*", 0, "md")
        end
      end
      data['gban_users'][tostring(matches[2])] = ""
      save_data(_config.moderation.data, data)
      kick_user(matches[2], msg.chat_id_)
      if not lang then
        return tdcli.sendMessage(msg.chat_id_, msg.id_, 0, "*User "..matches[2].." has been globally banned*", 0, "md")
      else
        return tdcli.sendMessage(msg.chat_id_, msg.id_, 0, "*کاربر "..matches[2].." از تمام گروه هار ربات محروم شد*", 0, "md")
      end
    end
    if matches[2] and not string.match(matches[2], '^%d+$') then
      tdcli_function ({
        ID = "SearchPublicChat",
        username_ = matches[2]
      }, action_by_username, {chat_id=msg.chat_id_,username=matches[2],msg_id=msg.id_,cmd="banall"})
    end
  end
  if matches[1] == "unbanall" and is_admin(msg) then
    if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
      tdcli_function ({
        ID = "GetMessage",
        chat_id_ = msg.chat_id_,
        message_id_ = msg.reply_to_message_id_
      }, action_by_reply, {chat_id=msg.chat_id_,cmd="unbanall"})
    end
    if matches[2] and string.match(matches[2], '^%d+$') then
      if not is_gbanned(matches[2]) then
        if not lang then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*User "..matches[2].." is not globally banned*", 0, "md")
        else
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*کاربر "..matches[2].." از گروه های ربات محروم نبود*", 0, "md")
        end
      end
      data['gban_users'][tostring(matches[2])] = nil
      save_data(_config.moderation.data, data)
      if not lang then
        return tdcli.sendMessage(msg.chat_id_, msg.id_, 0, "*User "..matches[2].." has been globally unbanned*", 0, "md")
      else
        return tdcli.sendMessage(msg.chat_id_, msg.id_, 0, "*کاربر "..matches[2].." از محرومیت گروه های ربات خارج شد*", 0, "md")
      end
    end
    if matches[2] and not string.match(matches[2], '^%d+$') then
      tdcli_function ({
        ID = "SearchPublicChat",
        username_ = matches[2]
      }, action_by_username, {chat_id=msg.chat_id_,username=matches[2],msg_id=msg.id_,cmd="unbanall"})
    end
  end
  if matches[1] == "ban" and is_mod(msg) then
    if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
      tdcli_function ({
        ID = "GetMessage",
        chat_id_ = msg.chat_id_,
        message_id_ = msg.reply_to_message_id_
      }, action_by_reply, {chat_id=msg.chat_id_,msg_id=msg.id_,cmd="ban"})
    end
    if matches[2] and string.match(matches[2], '^%d+$') then
      if is_mod1(msg.chat_id_, matches[2]) then
        if not lang then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "_You can't ban mods,owners or bot admins_", 0, "md")
        else
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*شما نمیتوانید مدیران،صاحبان گروه و ادمین های ربات رو از گروه محروم کنید*", 0, "md")
        end
      end
      if is_banned(matches[2], msg.chat_id_) then
        if not lang then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "_User "..matches[2].." is already banned_", 0, "md")
        else
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*کاربر "..matches[2].." از گروه محروم بود*", 0, "md")
        end
      end
      data[tostring(chat)]['banned'][tostring(matches[2])] = ""
      save_data(_config.moderation.data, data)
      kick_user(matches[2], msg.chat_id_)
      if not lang then
        return tdcli.sendMessage(msg.chat_id_, msg.id_, 0, "_User "..matches[2].." has been banned_", 0, "md")
      else
        return tdcli.sendMessage(msg.chat_id_, msg.id_, 0, "*کاربر "..matches[2].." از گروه محروم شد*", 0, "md")
      end
    end
    if matches[2] and not string.match(matches[2], '^%d+$') then
      tdcli_function ({
        ID = "SearchPublicChat",
        username_ = matches[2]
      }, action_by_username, {chat_id=msg.chat_id_,username=matches[2],msg_id=msg.id_,cmd="ban"})
    end
  end
  if matches[1] == "unban" and is_mod(msg) then
    if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
      tdcli_function ({
        ID = "GetMessage",
        chat_id_ = msg.chat_id_,
        message_id_ = msg.reply_to_message_id_
      }, action_by_reply, {chat_id=msg.chat_id_,cmd="unban"})
    end
    if matches[2] and string.match(matches[2], '^%d+$') then
      if not is_banned(matches[2], msg.chat_id_) then
        if not lang then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "_User "..matches[2].." is not banned_", 0, "md")
        else
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*کاربر "..matches[2].." از گروه محروم نبود*", 0, "md")
        end
      end
      data[tostring(chat)]['banned'][tostring(matches[2])] = nil
      save_data(_config.moderation.data, data)
        return tdcli.sendMessage(msg.chat_id_, msg.id_, 0, "*کاربر "..matches[2].." از محرومیت گروه خارج شد*", 0, "md")
    end
    if matches[2] and not string.match(matches[2], '^%d+$') then
      tdcli_function ({
        ID = "SearchPublicChat",
        username_ = matches[2]
      }, action_by_username, {chat_id=msg.chat_id_,username=matches[2],msg_id=msg.id_,cmd="unban"})
    end
  end
  if matches[1] == "silent" and is_mod(msg) then
    if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
      tdcli_function ({
        ID = "GetMessage",
        chat_id_ = msg.chat_id_,
        message_id_ = msg.reply_to_message_id_
      }, action_by_reply, {chat_id=msg.chat_id_,cmd="silent"})
    end
    if matches[2] and string.match(matches[2], '^%d+$') then
      if is_mod1(msg.chat_id_, matches[2]) then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*شما نمیتوانید توانایی چت کردن رو از مدیران،صاحبان گروه و ادمین های ربات بگیرید*", 0, "md")
        end
      if is_silent_user(matches[2], chat) then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*کاربر "..matches[2].." از قبل توانایی چت کردن رو نداشت*", 0, "md")
       end
      data[tostring(chat)]['is_silent_users'][tostring(matches[2])] = ""
      save_data(_config.moderation.data, data)
        return tdcli.sendMessage(msg.chat_id_, msg.id_, 0, "*کاربر "..matches[2].." توانایی چت کردن رو از دست داد*", 0, "md")
    end
    if matches[2] and not string.match(matches[2], '^%d+$') then
      tdcli_function ({
        ID = "SearchPublicChat",
        username_ = matches[2]
      }, action_by_username, {chat_id=msg.chat_id_,username=matches[2],cmd="silent"})
    end
  end
  if matches[1] == "unsilent" and is_mod(msg) then
    if not matches[2] and tonumber(msg.reply_to_message_id_) ~= 0 then
      tdcli_function ({
        ID = "GetMessage",
        chat_id_ = msg.chat_id_,
        message_id_ = msg.reply_to_message_id_
      }, action_by_reply, {chat_id=msg.chat_id_,cmd="unsilent"})
    end
    if matches[2] and string.match(matches[2], '^%d+$') then
      if not is_silent_user(matches[2], chat) then
          return tdcli.sendMessage(msg.chat_id_, "", 0, "*کاربر "..matches[2].." از قبل توانایی چت کردن رو داشت*", 0, "md")
      end
      data[tostring(chat)]['is_silent_users'][tostring(matches[2])] = nil
      save_data(_config.moderation.data, data)
        return tdcli.sendMessage(msg.chat_id_, msg.id_, 0, "*کاربر "..matches[2].." توانایی چت کردن رو به دست آورد*", 0, "md")
      end
    if matches[2] and not string.match(matches[2], '^%d+$') then
      tdcli_function ({
        ID = "SearchPublicChat",
        username_ = matches[2]
      }, action_by_username, {chat_id=msg.chat_id_,username=matches[2],msg_id=msg.id_,cmd="unsilent"})
    end
  end
  if matches[1]:lower() == 'clean' and is_owner(msg) then
    if matches[2] == 'bans' then
      if next(data[tostring(chat)]['banned']) == nil then
          return "*هیچ کاربری از این گروه محروم نشده*"
      end
      for k,v in pairs(data[tostring(chat)]['banned']) do
        data[tostring(chat)]['banned'][tostring(k)] = nil
        save_data(_config.moderation.data, data)
      end
        return "*تمام کاربران محروم شده از گروه از محرومیت خارج شدند*"
    end
    if matches[2] == 'silentlist' then
      if next(data[tostring(chat)]['is_silent_users']) == nil then
          return "*لیست کاربران سایلنت شده خالی است*"
      end
      for k,v in pairs(data[tostring(chat)]['is_silent_users']) do
        data[tostring(chat)]['is_silent_users'][tostring(k)] = nil
        save_data(_config.moderation.data, data)
      end
        return "*لیست کاربران سایلنت شده پاک شد*"
    end
  end
  if matches[1]:lower() == 'clean' and is_sudo(msg) then
    if matches[2] == 'gbans' then
      if next(data['gban_users']) == nil then
          return "*هیچ کاربری از گروه های ربات محروم نشده*"
        end
      for k,v in pairs(data['gban_users']) do
        data['gban_users'][tostring(k)] = nil
        save_data(_config.moderation.data, data)
      end
        return "*تمام کاربرانی که از گروه های ربات محروم بودند از محرومیت خارج شدند*"
      end
  end
  if matches[1] == "gbanlist" and is_admin(msg) then
    return gbanned_list()
  end
  if matches[1] == "silentlist" and is_mod(msg) then
    return silent_users_list(chat)
  end
  if matches[1] == "banlist" and is_mod(msg) then
    return banned_list(chat)
  end
end
return {
  patterns = {
    "^(banall)$",
    "^(banall) (.*)$",
    "^(unbanall)$",
    "^(unbanall) (.*)$",
    "^(gbanlist)$",
    "^(ban)$",
    "^(ban) (.*)$",
    "^(unban)$",
    "^(unban) (.*)$",
    "^(banlist)$",
    "^(silent)$",
    "^(silent) (.*)$",
    "^(unsilent)$",
    "^(unsilent) (.*)$",
    "^(silentlist)$",
    "^(kick)$",
    "^(kick) (.*)$",
    "^(delall)$",
    "^(delall) (.*)$",
    "^(clean) (.*)$",
  },
  run = run,
  pre_process = pre_process
}
