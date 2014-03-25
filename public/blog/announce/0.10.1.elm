
import Website.Skeleton (skeleton)
import Window
import JavaScript as JS

port title : String
port title = "Elm 0.10.1"

main = lift (skeleton everything) Window.dimensions

everything wid =
    let w = min 600 wid
    in  width w intro

intro = [markdown|

<style type="text/css">
p { text-align: justify }
pre { background-color: white;
      padding: 10px;
      border: 1px solid rgb(216, 221, 225);
      border-radius: 4px;
}
code > span.kw { color: #204a87; font-weight: bold; }
code > span.dt { color: #204a87; }
code > span.dv { color: #0000cf; }
code > span.bn { color: #0000cf; }
code > span.fl { color: #0000cf; }
code > span.ch { color: #4e9a06; }
code > span.st { color: #4e9a06; }
code > span.co { color: #8f5902; font-style: italic; }
code > span.ot { color: #8f5902; }
code > span.al { color: #ef2929; }
code > span.fu { color: #000000; }
code > span.er { font-weight: bold; }
</style>

<h1><div style="text-align:center">Elm 0.10.1
<div style="padding-top:4px;font-size:0.5em;font-weight:normal">*Tools and Libraries*</div></div>
</h1>

A lot of work is going into tooling right now, so this incremental release
mainly gets the compiler in shape for:

  * [A greatly improved version of `elm-repl`](https://github.com/elm-lang/elm-repl/blob/master/changelog.txt#L1-L12)
    (`cabal install elm-repl`)
  * Easily sharing Elm libraries (announcement coming soon!)

Besides that stuff, this release focuses on improving Elm's standard libraries.
New and improved libraries include:

  * [`List`](http://library.elm-lang.org/catalog/evancz-Elm/0.10.1/List) &mdash;
    add general sorting functions
  * [`Transform2D`](http://library.elm-lang.org/catalog/evancz-Elm/0.10.1/Transform2D) &mdash;
    greatly expanded API
  * [`Bitwise`](http://library.elm-lang.org/catalog/evancz-Elm/0.10.1/Bitwise) &mdash;
    for your bitwise operation needs
  * [`Regex`](http://library.elm-lang.org/catalog/evancz-Elm/0.10.1/Regex) &mdash;
    for when parser combinators are too much

There are also many miscellaneous fixes and improvements. Most notably,
infinite types lead to *much* nicer error messages, type errors should
be a bit easier to read, and stale intermediate files are detected automatically.
You can install 0.10.1 with [these instructions](http://elm-lang.org/Install.elm)
or upgrade with:

    cabal update ; cabal install elm

The rest of this post covers the improvements directly related to the compiler
and core libraries.

## Sorting

In addition to a standard `sort` for any comparable values,
[the list library](http://library.elm-lang.org/catalog/evancz-Elm/0.10.1/List)
can now do some more flexible sorting with
[`sortBy`](http://library.elm-lang.org/catalog/evancz-Elm/0.10.1/List#sortBy) and
[`sortWith`](http://library.elm-lang.org/catalog/evancz-Elm/0.10.1/List#sortWith).
First, `sortBy` lets you sort values by a derived property:

```haskell
sortBy : (a -> comparable) -> [a] -> [a]

sortBy String.length ["mouse","cat"] == ["cat","mouse"]
```

This makes it really easy to do relatively involved sorts on
lists of records or other complex values:

```haskell
alice = { name="Alice", height=1.62 }
bob   = { name="Bob"  , height=1.85 }
chuck = { name="Chuck", height=1.76 }

sortBy .name   [chuck,alice,bob] == [alice,bob,chuck]
sortBy .height [chuck,alice,bob] == [alice,chuck,bob]
```

If that's not general enough for you, `sortWith` lets you sort
values with a custom comparison function:

```haskell
sortWith : (a -> a -> Order) -> [a] -> [a]

sortWith (flip compare) [1..5] == [5,4,3,2,1]
sortWith personCompare [chuck,alice,bob] == [alice,bob,chuck]

-- compare by name first, compare by height to break ties
personCompare a b =
    case compare a.name b.name of
      EQ -> compare a.height b.height
      order -> order
```

Big thank you to [Max Goldstein](https://github.com/mgold) for suggesting
and implementing this and to [Max New](https://github.com/maxsnew) for
coming up with really nice names for both functions. I am far too excited
about the `sortBy` function.

## Transform2D, Bitwise, and Regex

[`Transform2D`](http://library.elm-lang.org/catalog/evancz-Elm/0.10.1/Transform2D)
was significantly fleshed out by [Michael Søndergaard](https://github.com/Sheeo)
(Thank you!). Using `groupTransform` should be quite a bit more pleasant now.

I added the [`Bitwise`](http://library.elm-lang.org/catalog/evancz-Elm/0.10.1/Bitwise)
library for low-level bit manipulations of integers.
This may come in handy if you are writing a random number generator,
as [Joe Collard is](https://github.com/jcollard/elm-random).

I also added the [`Regex`](http://library.elm-lang.org/catalog/evancz-Elm/0.10.1/Regex)
library for searching through strings. It seemed like
a logical step after Elm [got a proper string representation in
0.10](/blog/announce/0.10.elm). Note: I decided to call it `Regex` rather
than `RegExp` to distinguish between the [monstrosity that is
regex](http://stackoverflow.com/a/1732454) and [beauty and joy of regular
expressions](http://www.amazon.com/Introduction-Theory-Computation-Michael-Sipser/dp/0534950973).

## Fixes

* Nice errors on infinite types in programs and type aliases.
* Slightly friendlier type error messages.
* Errors for duplicate constructors in Algebraic Data Types (Thanks to Ben Darwin)
* Fix silly String API errors (Thanks to [Tim Hobbs](https://github.com/timthelion))
* The `--print-types` flag works every time (Thanks to [Justin Leitgeb](https://github.com/jsl))
* Warnings for corrupted and incompatable intermediate files (Thanks again to Justin
  Leitgeb who made persuasive arguments and collected data when I was being
  frustratingly conservative.)

Thank you again to everyone who contributed to this release!

|]
