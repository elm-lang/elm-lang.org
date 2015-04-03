import Graphics.Element (..)
import Markdown
import Signal (Signal, (<~))
import Website.Skeleton (skeleton)

import Window

port title : String
port title = "Community"

main = skeleton "Community" content <~ Window.dimensions

content outer =
    let center elem =
            container outer (heightOf elem) middle elem
    in  center (width (min 600 outer) community)

community = Markdown.toElement """

# Community

### Mailing list

[elm-dev]: https://groups.google.com/forum/?fromgroups#!forum/elm-dev "development mailing list"
[elm-discuss]: https://groups.google.com/forum/?fromgroups#!forum/elm-discuss "general mailing list"

The mailing lists are a great place for friendly discussion! The two primary
lists are for general discussion about the language [elm-discuss][elm-discuss]
and for discussions pertaining to the development of the language itself
[elm-dev][elm-dev]. We welcome you to subscribe to and participate in both
mailing lists! Common activities include discussing API design, reviewing
blog posts and libraries, and finding projects to collaborate on. Share code
snippets with [share-elm.com](http://www.share-elm.com).

This list is all about learning and improvement, so even if you know a lot
about Elm or functional programming, be humble and open to learning new things
from anyone! Try to read some old emails to get a feel for the culture and who
everyone is.

### Reddit

[reddit]: http://www.reddit.com/r/elm

Check out [/r/elm][reddit] to find out about new libraries and read blog posts.
Or even better, use it to announce libraries and post your own blog posts!

### IRC

[irc]: http://webchat.freenode.net/?channels=elm

Got a quick question, but do not feel comfortable asking on the mailing list?
Chatting on [#elm][irc] is a great way to learn from a real person. Share code
snippets with [share-elm.com](http://www.share-elm.com).

As for culture, prefer to ask rather than tell. You may be talking to someone
with no programming background or a PhD in programming languages, so to answer
a question well, you should start by asking some questions yourself! This way
we can avoid XY problems, and better yet, have a culture that is kind and
respectful to everyone.

### Twitter

[twitter]: https://twitter.com/elmlang

Both [@elmlang][twitter] and [@czaplic](https://twitter.com/czaplic) tweet about
Elm a lot. The #elmlang hashtag is commonly used. Using #elm is okay, but people
tweet about weird stuff with that one sometimes.

### Real Life

[Evan Czaplicki](http://github.com/evancz) will periodically organize [Elm user
group](http://www.meetup.com/Elm-user-group-SF/) meetups in SF to talk about
language design or discuss upcoming features and challenges. Email the mailing
list know if you want to give a talk or organize more frequent meetings!

There are also a ton of Elm folks on the East coast, so Boston and New York
would both be great places for meetups. The European community is also quite
strong. We had [Elm Workshop](/blog/announce/Workshop-2013.elm) in 2013
with speakers and attendees from all over Europe, so more of this!

### Contribute

There are a bunch of projects in [the elm-lang
organization](http://github.com/elm-lang), including the compiler, REPL, server,
package manager, debugger, public library, and this website.

We have found that a good way to make contributions is to hang out on the
[mailing list][list] to learn about the ongoing challenges. Becoming a part of
this discussion will make it much clearer how you can effectively help the
community or a specific project based on your skills and interests.

"""

