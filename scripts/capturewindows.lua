function make_chat_window()
  chat_window = Geyser.UserWindow:new({
    name = "chat_window",
    titleText = "CHATS BLURT",
    docked = true,
    height = "5c",
    dockPosition = "right",
    autoWrap = true,
  })
  chat_window:setFontSize(getFontSize("main"))
  chat_window:setFont(getFont("main"))
  return 1
end

make_chat_window()
---------------------------------------------------------------------------
--------------------------------------------------
-- BONUS WINDOW
--------------------------------------------------
function make_bonus_window()

  bonus_window = Geyser.UserWindow:new({
    name = "bonus_window",
    titleText = "BLURT BONUS",
    autoWrap = true,
    autoDock = false,
    x = "20%",
    y = "40%"
  })

  bonus_window:setFontSize(getFontSize())
  bonus_window:setFont(getFont("main"))

  return 1
end

make_bonus_window()
