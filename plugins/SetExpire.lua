local function rem(msg)
  local hash = "gp_lang:"..msg.chat_id_
  local lang = redis:get(hash)
  local data = load_data(_config.moderation.data)  
  -- superuser and admins only (because sudo are always has privilege)
  if is_admin(msg) then
  local receiver = msg.chat_id_
  if not data[tostring(msg.chat_id_)] then
      return
  end
 end
  data[tostring(msg.chat_id_)] = nil
  save_data(_config.moderation.data, data)
  local groups = 'groups'
  if not data[tostring(groups)] then
    data[tostring(groups)] = nil
    save_data(_config.moderation.data, data)
    end data[tostring(groups)][tostring(msg.chat_id_)] = nil
    save_data(_config.moderation.data, data)
    tdcli.changeChatMemberStatus(msg.chat_id_, 223667070, 'Left', dl_cb, nil)
  end

--[[local function pre_process(msg)
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
      local group_owner = data[tostring(msg.to.id)]['set_owner']
      if not group_owner then
        group_owner = "--"
      end
      local group_link = data[tostring(msg.to.id)]['settings']['set_link']
      if not group_link then
        group_link = "Unset"
      end
      local exppm = '💢charge finish\n'
      ..'----------------------------------\n'
      ..'👥Group Name : <code> '..msg.to.title..' </code>\n'
      ..'🆔Group ID : <code> '..msg.to.id..'  </code>\n'
      ..'🏅Group Owner :  <code> '..group_owner..'  </code> \n'
      ..'➰Group Link : '..group_link..'\n'
      ..'🔘Info Time:\n'..text12..'\n'
      ..'----------------------------------\n'
      ..'🔋Charge For 1 Month :\n'
      ..'/setexp_'..msg.to.id..'_30\n'
      ..'🔋Charge For 3 Month :\n'
      ..'/setexp_'..msg.to.id..'_90\n'
      ..'🔋Unlimited Charge :\n'
      ..'/setexp_'..msg.to.id..'_999\n'
      ..'----------------------------------\n'
      ..'@TeleSync'
      local sends = send_msg(user, exppm, ok_cb, false)
      send_large_msg(get_receiver(msg), '0 روز تا پایان تاریخ انقضای گروه باقی مانده است\nنسبت به تمدید اقدام کنید.')
      redis:hset('expires0',msg.to.id,'0')
    end
    if tonumber(timetoexpire) == 1 then
      if redis:hget('expires1',msg.to.id) then return msg end
      local user = "user#id"..185449679
      local text2 = "تاریخ انقضای گروه ارسال شده 1 روز دیگر به پایان میرسد"
      local text13 = 1
      local data = load_data(_config.moderation.data)
      local group_owner = data[tostring(msg.to.id)]['set_owner']
      if not group_owner then
        group_owner = "--"
      end
      local group_link = data[tostring(msg.to.id)]['settings']['set_link']
      if not group_link then
        group_link = "Unset"
      end
      local exppm = '💢charge finish\n'
      ..'----------------------------------\n'
      ..'👥Group Name : <code> '..msg.to.title..' </code>\n'
      ..'🆔Group ID : <code> '..msg.to.id..'  </code>\n'
      ..'🏅Group Owner :  <code> '..group_owner..'  </code> \n'
      ..'➰Group Link : '..group_link..' \n'
      ..'🔘Info Time:\n'..text13..'\n'
      ..'----------------------------------\n'
      ..'🔋Charge For 1 Month :\n'
      ..'/setexp_'..msg.to.id..'_30\n'
      ..'🔋Charge For 3 Month :\n'
      ..'/setexp_'..msg.to.id..'_90\n'
      ..'🔋Unlimited Charge :\n'
      ..'/setexp_'..msg.to.id..'_999\n'
      ..'----------------------------------\n'
      ..'@TeleSync'
      local sends = send_msg(user, exppm, ok_cb, false)
      return "1"
      redis:hset('expires1',msg.to.id,'1')
    end
    if tonumber(timetoexpire) == 2 then
      if redis:hget('expires2',msg.to.id) then return msg end
      send_large_msg(get_receiver(msg), '2 روز تا پایان تاریخ انقضای گروه باقی مانده است\nنسبت به تمدید اقدام کنید.')
      redis:hset('expires2',msg.to.id,'2')
    end
    if tonumber(timetoexpire) == 3 then
      if redis:hget('expires3',msg.to.id) then return msg end
      send_large_msg(get_receiver(msg), '3 روز تا پایان تاریخ انقضای گروه باقی مانده است\nنسبت به تمدید اقدام کنید.')
      redis:hset('expires3',msg.to.id,'3')
    end
    if tonumber(timetoexpire) == 4 then
      if redis:hget('expires4',msg.to.id) then return msg end
      send_large_msg(get_receiver(msg), '4 روز تا پایان تاریخ انقضای گروه باقی مانده است\nنسبت به تمدید اقدام کنید.')
      redis:hset('expires4',msg.to.id,'4')
    end
    if tonumber(timetoexpire) == 5 then
      if redis:hget('expires5',msg.to.id) then return msg end
      send_large_msg(get_receiver(msg), '5 روز تا پایان تاریخ انقضای گروه باقی مانده است\nنسبت به تمدید اقدام کنید.')
      redis:hset('expires5',msg.to.id,'5')
    end
  end
  return msg
end]]
function run(msg, matches)
  if matches[1]:lower() == 'setexpire' and is_sudo(msg) then
    local time = os.time()
    local buytime = tonumber(os.time())
    local timeexpire = tonumber(buytime) + (tonumber(matches[2]) * 86400)
    redis:hset('expiretime', msg.chat_id_, timeexpire)
    return "تاریخ انقضای گروه:\nبه "..matches[2].. " روز دیگر تنظیم شد."
    tdcli.sendMessage(msg.chat_id_, 0, 1, 'ss', 1, 'md')
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
    return (math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1) .. " روز دیگر\nاگر تمایل به شارژ کردن گروه دارید دستور زیر را اسال نمایید\n !charge"

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
  local group_owner = data[tostring(msg.to.id)]['set_owner']
  if not group_owner then
    group_owner = "--"
  end
  local group_link = data[tostring(msg.to.id)]['settings']['set_link']
  if not group_link then
    group_link = "Unset"
  end
  local exppm = '💢Req Charge\n'
  ..'----------------------------------\n'
  ..'👥Group Name : <code> '..msg.to.title..' </code>\n'
  ..'🆔Group ID : <code> '..msg.to.id..'  </code>\n'
  ..'🏅Group Owner :  <code> '..group_owner..'  </code> \n'
  ..'➰Group Link : '..group_link..' \n'
  ..'🔘Info Time: '..text4..'  \n'
  ..'🔘Info msg:\n'..text3..'  \n'
  ..'----------------------------------\n'
  ..'🔋Charge For 1 Month :\n'
  ..'/setexp_'..msg.to.id..'_30 +'..text4..'\n'
  ..'🔋Charge For 3 Month :\n'
  ..'/setexp_'..msg.to.id..'_90 +'..text4..'\n'
  ..'🔋Unlimited Charge :\n'
  ..'/setexp_'..msg.to.id..'_999\n'
  ..'----------------------------------\n'
  ..'@TeleSync'
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
