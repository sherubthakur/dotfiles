import XMonad

import XMonad.Hooks.EwmhDesktops (ewmh, ewmhDesktopsLogHook, fullscreenEventHook)
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks)

import XMonad.Layout.LayoutModifier (ModifiedLayout)
import XMonad.Layout.Gaps (Gaps, Direction2D(..), gaps)
import XMonad.Layout.Spacing (Spacing, Border(..), spacingRaw)
import XMonad.Layout.NoBorders (Ambiguity(..), lessBorders)
import XMonad.Layout.ThreeColumns (ThreeCol(..))

import XMonad.Util.EZConfig (additionalKeys, removeKeys)

import XMonad.StackSet (greedyView, shift)
import Graphics.X11.ExtraTypes.XF86
    ( xF86XK_AudioLowerVolume
    , xF86XK_AudioRaiseVolume
    , xF86XK_AudioMute
    )


main :: IO ()
main = do
    xmonad . docks . ewmh $ myConfig


myConfig =
     def
         { logHook = ewmhDesktopsLogHook
         , terminal = "xterm"
         , startupHook = myStartupHook
         , manageHook =  myManageHook
         , layoutHook = myLayoutModifiers myLayouts 
         , workspaces = myWorkspaces
         , handleEventHook = fullscreenEventHook <+> handleEventHook def

         -- NOTE: Injected using nix strings.
         -- Think about parsing colorscheme.nix file in some way
         , focusedBorderColor = myFocusedBorderColor
         , borderWidth = 3
         }
         -- NOTE: Ordering matters here
         `removeKeys` keysToRemove
         `additionalKeys` keysToAdd


myWorkspaces :: [String]
myWorkspaces = ["a", "s", "d", "f"]


myModMask :: KeyMask
myModMask = mod1Mask


keysToRemove :: [(KeyMask, KeySym)]
keysToRemove = defaultWorkSpaceSwitchBinding ++ defaultWorkSpaceWindowMoveBinding
    where
        defaultWorkSpaceWindowMoveBinding =
            [(myModMask .|. shiftMask, n) | n <- [xK_1 .. xK_9]] 
        defaultWorkSpaceSwitchBinding =
            [(myModMask, n) | n <- [xK_1 .. xK_9]] 


keysToAdd :: [((KeyMask, KeySym), X ())]
keysToAdd =
      launchers
    ++ multimediaKeys
    ++ workspaceSetup
    ++ workspaceWindowMoveSetup
    ++ layoutRelated
    where
        launchers =
            [ ( (myModMask, xK_space)
                , spawn "rofi -show drun -theme grid"
              )
            , ( (myModMask .|. shiftMask, xK_l)
                , spawn "i3lock-fancy -p -t \"\""
              )
            , ( (myModMask .|. shiftMask, xK_Return)
                , spawn "xterm -e \"cd $(xcwd) && ~/.nix-profile/bin/zsh\""
              )
            , ( (myModMask .|. shiftMask, xK_4)
                , spawn "sleep 0.2 && scrot -s ~/Pictures/screenshots/scrot_%Y-%m-%d-%H%M%S.png"
              )
            ]

        workspaceKeyAndIdentifiers = 
            zip (myWorkspaces) [xK_a, xK_s, xK_d, xK_f]

        workspaceSetup = 
            [ ((myModMask, key), windows $ greedyView identifier)
            | (identifier, key) <- workspaceKeyAndIdentifiers]

        workspaceWindowMoveSetup =
            [ ((shiftMask .|. myModMask, key), windows $ shift identifier)
            | (identifier, key) <- workspaceKeyAndIdentifiers]

        multimediaKeys =
            [ ((0, xF86XK_AudioLowerVolume), spawn "amixer sset Master 5%-")
            , ((0, xF86XK_AudioRaiseVolume), spawn "amixer sset Master 5%+")
            , ((0, xF86XK_AudioMute       ), spawn "amixer sset Master toggle")
            ]
        layoutRelated =
            [ ((myModMask, xK_n), sendMessage NextLayout)
            ]


myLayoutModifiers =
    lessBorders OnlyScreenFloat . avoidStruts . spacingLayoutSetup . gapLayoutSetup
        where
            spacingLayoutSetup :: l a -> ModifiedLayout Spacing l a
            spacingLayoutSetup = spacingRaw True screenBorder True windowBorder True

            gapLayoutSetup :: l a -> ModifiedLayout Gaps l a
            gapLayoutSetup =
                gaps [ (U, edgeGap), (R, edgeGap), (D, edgeGap), (L, edgeGap) ]

            screenBorder = Border { top = 5, bottom = 5, right = 5, left = 5 }
            windowBorder = Border { top = 5, bottom = 5, right = 5, left = 5 }
            edgeGap = 20


myLayouts :: Choose Tall (Choose ThreeCol Full) a
myLayouts = tall ||| threeCol ||| Full
    where
        tall :: Tall a
        tall = Tall { tallNMaster = 1, tallRatioIncrement = 3/100, tallRatio = 1/2 }

        threeCol :: ThreeCol a
        threeCol = ThreeCol
            { threeColNMaster = 1, threeColDelta = 3/100, threeColFrac = 1/2 }


myManageHook :: ManageHook
myManageHook = composeAll
    [ manageDocks
    , className =? "OpenRGB" --> doFloat
    , className =? "Lxappearance" --> doFloat
    , className =? ".solaar-wrapped" --> doFloat
    , className =? "Psensor" --> doFloat
    , className =? "Nm-connection-editor" --> doFloat
    , className =? "Gddccontrol" --> doFloat
    ]


myStartupHook :: X ()
myStartupHook = do
    spawn "custom-panel-launch"