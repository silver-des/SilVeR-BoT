--[[

Invite user into the chat group.

Type !invite by replying to a message to invite replied user.
Usefull when you want to reinviting kicked user. Most reliable.

Use !invite 1234567890 (where 1234567890 is id_number) to invite a user by id_number.
This is a very reliable method, and if failed, will failed silently.

Use !invite @username to invite a user by @username.
Less reliable. Some users don't have @username.

Use !invite print_name to invite a user by print_name.
Unreliable. Avoid if possible. Maybe need an initial communication with the user.
If print_name is not exist, it will failed silently.

--]]

do

  local function invite_user(chat_id, user_id)
    if is_super_banned(user_id) or is_banned(user_id, chat_id) then
      return send_large_msg('chat#id'..chat_id, 'Invitation canceled.\n'
                            ..'ID'..user_id..' is (super)banned.')
    end
    chat_add_user('chat#id'..chat_id, 'user#id'..user_id, ok_cb, false)
  end

  local function resolve_username(extra, success, result)
    if success == 1 then
      invite_user(extra.msg.to.id, result.id)
    else
      return send_large_msg('chat#id'..extra.msg.to.id, 'Failed to invite '
                            ..string.gsub(extra.msg.text, '!invite ', '')
                            ..' into this group.\nPlease check if username is correct.')
    end
  end

  local function action_by_reply(extra, success, result)
    invite_user(result.to.id, result.from.id)
  end

  local function run(msg, matches)
    if is_chat_msg(msg) and is_admin(msg) then
      if msg.reply_id and msg.text == "biyaresg" then
        msgr = get_message(msg.reply_id, action_by_reply, {msg=msg})
      end
      if string.match(matches[1], '^%d+$') then
        invite_user(msg.to.id, matches[1])
      elseif string.match(matches[1], '^@.+$') then
        msgr = res_user(string.gsub(matches[1], '@', ''), resolve_username, {msg=msg})
      elseif string.match(matches[1], '.*$') then
        -- This one is tricky. Big chance are, you need an initial interaction with <print_name>.
        chat_add_user('chat#id'..msg.to.id, string.gsub(matches[1], ' ', '_'), ok_cb, false)
      end
    else
      return 'This is not a chat group!'
    end
  end

  return {
    description = 'Invite other user to the chat group.',
    usage = {
      moderator = {
        -- Need space in front of this, so bot won't consider it as a command
        ' !biyaresh : If type by replying, bot will then inviting the replied user.',
        ' biyaresh <user_id> : Invite by their user_id.',
        ' biyaresh @<user_name> : Invite by their @<user_name>.',
        ' biyaresh <print_name> : Invite by their print_name.'
      },
    },
    patterns = {
      '^!biyaresh$',
      '^biyaresh (.*)$',
      '^biyaresh (%d+)$'
    },
    run = run,
    moderated = true
  }

end
