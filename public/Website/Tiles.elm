module Website.Tiles (examples) where

import Graphics.Input as Input
import open Website.ColorScheme

examples w exs =
    let block = flow down . intersperse (spacer 10 10) <| map row exs
    in  container w (heightOf block) middle block

row = flow right . intersperse (spacer 10 124) . map example

navigation = Input.customButtons ()

example name =
    let btn clr = color clr . container 124 124 middle <|
                  image 120 120 ("/screenshot/" ++ name ++ ".jpg")
    in  link ("/edit/examples/Intermediate/" ++ name ++ ".elm") <|
        navigation.customButton () (btn mediumGrey) (btn accent1) (btn accent3)
