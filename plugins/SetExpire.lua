local function pre_process(msg)
  local timetoexpire = 'unknown'
  local expiretime = redis:hget ('expiretime', msg.chat_id_)
  local now = tonumber(os.time())
  if expiretime then
    timetoexpire = math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1
    if tonumber("0") > tonumber(timetoexpire) or tonumber("0") == tonumber(timetoexpire) then
        redis:del('expiretime', msg.chat_id_)
        redis:hdel('expires0', msg.chat_id_)
        redis:hdel('expires1', msg.chat_id_)
        redis:hdel('expires2', msg.chat_id_)
        redis:hdel('expires3', msg.chat_id_)
        redis:hdel('expires4', msg.chat_id_)
        redis:hdel('expires5', msg.chat_id_)
                        
        tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "⚠️ تاریخ انقضای گروه شما به پایان رسید !\nبرای تمدید به @SeyedRobot مراجعه کنید .", 1, "md", dl_cb, nil)
        tdcli.changeChatMemberStatus(msg.chat_id_, 242864471, 'Left', dl_cb, nil)
    end
    if tonumber(timetoexpire) == 0 then
      if redis:hget('expires0',msg.chat_id_) then return msg end
      local data = load_data(_config.moderation.data)
      local group_link = data[tostring(chat)]['settings']['linkgp']
      if not group_link then
        group_link = "---"
      end
      local text = '💢 پایان تاریخ انقضا\n'
      ..'----------------------------------\n'
      ..'🆔شناسه گروه : _'..msg.chat_id_..'_\n'
      ..'➰لینک گروه : '..group_link..'\n'
      ..'----------------------------------\n'
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "⚠️ تاریخ انقضای گروه شما یک روز دیگر به پایان می رسد.\nبرای تمدید به @SeyedRobot مراجعه کنید!", 1, "md", dl_cb, nil)      
      tdcli.sendMessage(250877155, 0, 1, text, 1, "md", dl_cb, nil)      
      redis:hset('expires0',msg.chat_id_,'0')
    end
    if tonumber(timetoexpire) == 1 then
      if redis:hget('expires1',msg.chat_id_) then return msg end
      local user = "user#id"..185449679
      local text2 = "تاریخ انقضای گروه ارسال شده 1 روز دیگر به پایان میرسد"
      local text13 = 1
      local data = load_data(_config.moderation.data)
      local group_link = data[tostring(chat)]['settings']['linkgp']
      if not group_link then
        group_link = "---"
      end
      local text = '💢 پایان تاریخ انقضا\n'
      ..'----------------------------------\n'
      ..'🆔شناسه گروه : _'..msg.chat_id_..'_\n'
      ..'➰لینک گروه : '..group_link..'\n'
      ..'----------------------------------\n'
      tdcli.sendMessage(250877155, 0, 1, "⚠️ تاریخ انقضای گروه شما امروز دیگر به پایان می رسد.\nبرای تمدید به @SeyedRobot مراجعه کنید!", 1, "md", dl_cb, nil)      
      tdcli.sendMessage(250877155, 0, 1, text, 1, "md", dl_cb, nil)      
      redis:hset('expires1',msg.chat_id_,'1')
    end
    if tonumber(timetoexpire) == 2 then
      if redis:hget('expires2',msg.chat_id_) then return msg end
      tdcli.sendMessage(250877155, 0, 1, "⚠️ تاریخ انقضای گروه شما دو روز دیگر به پایان می رسد.\nبرای تمدید به @SeyedRobot مراجعه کنید!", 1, "md", dl_cb, nil)      
      redis:hset('expires2',msg.chat_id_,'2')
    end
    if tonumber(timetoexpire) == 3 then
      if redis:hget('expires3',msg.chat_id_) then return msg end
      tdcli.sendMessage(250877155, 0, 1, "⚠️ تاریخ انقضای گروه شما سه روز دیگر به پایان می رسد.\nبرای تمدید به @SeyedRobot مراجعه کنید!", 1, "md", dl_cb, nil)      
      redis:hset('expires3',msg.chat_id_,'3')
    end
    if tonumber(timetoexpire) == 4 then
      if redis:hget('expires4',msg.chat_id_) then return msg end
      tdcli.sendMessage(250877155, 0, 1, "⚠️ تاریخ انقضای گروه شما چهار روز دیگر به پایان می رسد.\nبرای تمدید به @SeyedRobot مراجعه کنید!", 1, "md", dl_cb, nil)      
      redis:hset('expires4',msg.chat_id_,'4')
    end
    if tonumber(timetoexpire) == 5 then
      if redis:hget('expires5',msg.chat_id_) then return msg end
      tdcli.sendMessage(250877155, 0, 1, "⚠️ تاریخ انقضای گروه شما پنج روز دیگر به پایان می رسد.\nبرای تمدید به @SeyedRobot مراجعه کنید!", 1, "md", dl_cb, nil)      
      redis:hset('expires5',msg.chat_id_,'5')
    end
  end
  return msg
end
function run(msg, matches)
  
  if matches[1]:lower() == 'setexpire' then
    if not is_sudo(msg) then return end
    local time = os.time()
    local buytime = tonumber(os.time())
    local timeexpire = tonumber(buytime) + (tonumber(matches[2]) * 86400)
    redis:hset('expiretime',msg.chat_id_,timeexpire)
    return "✅ گروه برای _"..matches[2].."_ روز شارژ شد !"
  end

end
return {
patterns = {
  "^(setexpire) (.*)$",
},
run = run,
pre_process = pre_process
}
