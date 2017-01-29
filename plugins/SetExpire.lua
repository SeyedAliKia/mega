local function rem(msg)
    local data = load_data(_config.moderation.data)  
    local groups = 'groups'
    data[tostring(groups)][tostring(msg.chat_id_)] = nil
    save_data(_config.moderation.data, data)
    tdcli.changeChatMemberStatus(msg.chat_id_, 242864471, 'Left', dl_cb, nil)
  end

local function pre_process(msg)
  local timetoexpire = 'unknown'
  local expiretime = redis:hget ('expiretime', msg.chat_id_)
  local now = tonumber(os.time())
  if expiretime then
    timetoexpire = math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1
    if tonumber("0") > tonumber(timetoexpire) then
      if msg.chat_id_ then
        redis:del('expiretime', msg.chat_id_)
        rem(msg)
        return 'test'
      else
        return
      end
    end
    if tonumber(timetoexpire) == 0 then
      if redis:hget('expires0', msg.chat_id_) then return msg end
      local user = "user#id"..185449679
      local text = "تاریخ انقضای گروه ارسال شده به پایان رسیده است"
      local text12 = 0
      local data = load_data(_config.moderation.data)
      local group_owner = data[tostring(msg.chat_id_)]['set_owner']
      if not group_owner then
        group_owner = "--"
      end
      local group_link = data[tostring(msg.chat_id_)]['settings']['set_link']
      if not group_link then
        group_link = "Unset"
      end
      local exppm = '💢charge finish\n'
      ..'----------------------------------\n'
      --..'👥Group Name : <code> '..msg.to.title..' </code>\n'
      ..'🆔Group ID : <code> '..msg.chat_id_..'  </code>\n'
      ..'🏅Group Owner :  <code> '..group_owner..'  </code> \n'
      ..'➰Group Link : '..group_link..'\n'
      --..'🔘Info Time:\n'..text12..'\n'
      ..'----------------------------------\n'
      ..'🔋Charge For 1 Month :\n'
      ..'/setexp_'..msg.chat_id_..'_30\n'
      ..'🔋Charge For 3 Month :\n'
      ..'/setexp_'..msg.chat_id_..'_90\n'
      ..'🔋Unlimited Charge :\n'
      ..'/setexp_'..msg.chat_id_..'_999\n'
      ..'----------------------------------\n'
      ..'@TeleSync'
      --local sends = send_msg(user, exppm, ok_cb, false)
      tdcli.sendMessage(msg.chat_id_, "", 0, "00", 0, "md")
      redis:hset('expires0',msg.chat_id_,'0')
    end
    if tonumber(timetoexpire) == 1 then
      if redis:hget('expires1',msg.chat_id_) then return msg end
      local user = "user#id"..185449679
      local text2 = "تاریخ انقضای گروه ارسال شده 1 روز دیگر به پایان میرسد"
      local data = load_data(_config.moderation.data)
      local group_link = data[tostring(msg.chat_id_)]['settings']['linkgp']     
      if not group_link then
        group_link = "❌ تنظیم نشده"
      end
      local exppm = '💢پایان تاریخ اعتبار\n'
      ..'----------------------------------\n'
      --..'👥نام گروه : <code> '..msg.to.title..' </code>\n'
      ..'🆔شناسه گروه : <code> '..msg.chat_id_..'  </code>\n'
      ..'➰لینک گروه : '..group_link..'\n'
      ..'----------------------------------\n'
      ..'🔋شارژ کردن برای یک ماه :\n'
      ..'setexp_'..msg.chat_id_..'_30\n'
      ..'🔋شارژ کردن برای سه ماه :\n'
      ..'setexp_'..msg.chat_id_..'_90\n'
      ..'🔋شارژ نامحدود :\n'
      ..'setexp_'..msg.chat_id_..'_999\n'
      ..'----------------------------------\n'
      tdcli.sendMessage(msg.chat_id_, "", 0, "1", 0, "md")
      redis:hset('expires1',msg.chat_id_,'1')
    end
    if tonumber(timetoexpire) == 2 then
      if redis:hget('expires2',msg.chat_id_) then return msg end
      tdcli.sendMessage(msg.chat_id_, "", 0, "2", 0, "md")
      redis:hset('expires2',msg.chat_id_,'2')
    end
    if tonumber(timetoexpire) == 3 then
      if redis:hget('expires3',msg.chat_id_) then return msg end
      tdcli.sendMessage(msg.chat_id_, "", 0, "3", 0, "md")
      redis:hset('expires3',msg.chat_id_,'3')
    end
    if tonumber(timetoexpire) == 4 then
      if redis:hget('expires4',msg.chat_id_) then return msg end
      tdcli.sendMessage(msg.chat_id_, "", 0, "4", 0, "md")
      redis:hset('expires4',msg.chat_id_,'4')
    end
    if tonumber(timetoexpire) == 5 then
      if redis:hget('expires5',msg.chat_id_) then return msg end
      tdcli.sendMessage(msg.chat_id_, "", 0, "5", 0, "md")
      redis:hset('expires5',msg.chat_id_,'5')
    end
  end
  return msg
end
function run(msg, matches)
  if matches[1]:lower() == 'setexpire' and is_sudo(msg) then
    local time = os.time()
    local buytime = tonumber(os.time())
    local timeexpire = tonumber(buytime) + (tonumber(matches[2]) * 86400)
    redis:hset('expiretime', msg.chat_id_, timeexpire)
    tdcli.sendMessage(msg.chat_id_, "", 0, "222", 0, "md")
  end

  if matches[1]:lower() == 'setexp' then
    local expgp = "channel#id"..matches[2]
    local time = os.time()
    local buytime = tonumber(os.time())
    local timeexpire = tonumber(buytime) + (tonumber(matches[3]) * 86400)
    redis:hset('expiretime', msg.chat_id_,timeexpire)
    return "تاریخ انقضای گروه:\nبه "..matches[3].. " روز دیگر تنظیم شد."
  end
  if matches[1]:lower() == 'expire' then
    local expiretime = redis:hget ('expiretime', msg.chat_id_)
    if not expiretime then return 'تاریخ ست نشده است' else
    local now = tonumber(os.time())
    local text = (math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1)
    tdcli.sendMessage(msg.chat_id_, "", 0, (math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1), 0, "md")
  end
end
if matches[1]:lower() == 'charge' then
  if not is_owner(msg) then return end
  local expiretime = redis:hget ('expiretime', msg.chat_id_)
  local now = tonumber(os.time())
  local text4 = (math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1)
  if not expiretime then
    expiretime = "-"
  end
  local text3 = "صاحب گروه درخواست شارژ کردن گروه را دارد"
  local user = "user#id"..185449679
  local data = load_data(_config.moderation.data)
  local group_owner = data[tostring(msg.chat_id_)]['set_owner']
  if not group_owner then
    group_owner = "--"
  end
  local group_link = data[tostring(msg.chat_id_)]['settings']['set_link']
  if not group_link then
    group_link = "Unset"
  end
  local exppm = '💢Req Charge\n'
  ..'----------------------------------\n'
  ..'👥Group Name : <code> '..msg.to.title..' </code>\n'
  ..'🆔Group ID : <code> '..msg.chat_id_..'  </code>\n'
  ..'🏅Group Owner :  <code> '..group_owner..'  </code> \n'
  ..'➰Group Link : '..group_link..' \n'
  ..'🔘Info Time: '..text4..'  \n'
  ..'🔘Info msg:\n'..text3..'  \n'
  ..'----------------------------------\n'
  ..'🔋Charge For 1 Month :\n'
  ..'/setexp_'..msg.chat_id_..'_30 +'..text4..'\n'
  ..'🔋Charge For 3 Month :\n'
  ..'/setexp_'..msg.chat_id_..'_90 +'..text4..'\n'
  ..'🔋Unlimited Charge :\n'
  ..'/setexp_'..msg.chat_id_..'_999\n'
  ..'----------------------------------\n'
  return "درخواست شما برای شارژ مجدد گروه ارسال شد"
end
end
return {
patterns = {
  "^(setexpire) (.*)$",
  "^(setexp)_(.*)_(.*)$",
  "^(expire)$",
  "^(charge)$",
},
run = run,
pre_process = pre_process
}
