import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmobarrc"
    xmonad $ defaultConfig
        { manageHook = manageDocks <+> manageHook defaultConfig
        , layoutHook = avoidStruts $ layoutHook defaultConfig
        , logHook = dynamicLogWithPP $ xmobarPP
            { ppOutput = hPutStrLn xmproc
            , ppTitle = xmobarColor "green" "" . shorten 65
            }
        , terminal = "urxvt -bg black -fg white +sb -vb"
        , borderWidth = 1
        , normalBorderColor = "#dddddd"
        , focusedBorderColor = "#963c59"
        } `additionalKeys`
        [ ((mod1Mask,		xK_F10), spawn "amixer set Master 5%+")
        , ((mod1Mask,		xK_F9 ), spawn "amixer set Master 5%-")
        , ((mod1Mask,		xK_F8 ), spawn "amixer set Master toggle; amixer set Beep toggle")
        , ((mod1Mask,		xK_F7 ), spawn "xbacklight -inc 12")
        , ((mod1Mask,		xK_F6 ), spawn "xbacklight -dec 10")
        ]
