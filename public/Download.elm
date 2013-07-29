import Website.Skeleton (skeleton)
import Window

install = [markdown|

### Install

If you are on Mac OSX, [download this](https://dl.dropboxusercontent.com/u/5850974/Elm/Elm.pkg).
Otherwise use these [install instructions][1].
You are getting:

1. *Compiler* &ndash; Turn Elm code into HTML, CSS, and JavaScript.

2. *Server* &ndash; Serve Elm files, images, videos, HTML, JavaScript,
   and anything else you can think of.

  [1]: https://github.com/evancz/Elm/blob/master/README.md#install "install instructions"

|]

other = [markdown|

### Build from Source

[The Elm compiler and server](https://github.com/evancz/Elm) are on github.

[This website](https://github.com/evancz/elm-lang.org) is also
available with [setup instructions][instruct]. The server can
be the basis for your own website. It also lets you use
the interactive editor locally.

 [instruct]: https://github.com/evancz/elm-lang.org#elm-langorg-a-template-for-creating-websites-in-elm "install"

|]

syntax = [markdown|

### Syntax Highlighting

There are some Elm specific highlighters.
Haskell syntax highlighting also tends to work pretty well.

* *Vim* &ndash; use Haskell mode or [try elm.vim](https://github.com/otavialabs/elm.vim).
* *Sublime Text* &ndash; install [Elm Language Support](https://github.com/deadfoxygrandpa/Elm.tmLanguage) with [Package Control](http://wbond.net/sublime_packages/package_control).
* *Emacs* &ndash; turn on [haskell-mode](https://github.com/afeinberg/haskellmode-emacs#readme)
  for `.elm` files.

There is some more info on this [on the email list](https://groups.google.com/forum/?fromgroups#!topic/elm-discuss/Tt0Z538Xv7g).
|]

problems = [markdown|

### Problems?

If you run into problems, you should email the [mailing list][2], ask
questions [on IRC](http://webchat.freenode.net/?channels=elm), or
report an issue to Elm's [source repository][3]

  [2]: https://groups.google.com/forum/?fromgroups#!forum/elm-discuss "email list"
  [3]: https://github.com/evancz/Elm "source repository"

|]

info w =
  let hwidth = if w < 800 then w `div` 2 - 20 else 380 in
  flow down
    [ flow right [ width hwidth install, spacer 40 10, width hwidth syntax ]
    , spacer w 30
    , flow right [ width hwidth other, spacer 40 10, width hwidth problems ] ]

main = lift (skeleton info) Window.width
