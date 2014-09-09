
import Website.Skeleton (skeleton)
import Window

port title : String
port title = "Making Pong"

main = lift (skeleton "Blog" content) Window.dimensions

content w = width (min 600 w) [markdown|

<br>
<div style="font-family: futura, 'century gothic', 'twentieth century', calibri, verdana, helvetica, arial; text-align: center; font-size: 4em;">Making Pong</div>

This post has two major goals:

 1. Get you thinking about [Functional Reactive
    Programming](/learn/What-is-FRP.elm) (FRP) for games.
 2. Teach you how to make games with Elm.

In this post we will be looking into [Pong in Elm](/edit/examples/Intermediate/Pong.elm):
a functional game written in Elm, playable in any modern browser.

## Functional Game Design

Making games is historically a very imperative undertaking, so it has long
missed the benefits of purely functional programming. FRP makes it possible
to program rich user interactions without traditional imperative idioms.

By the end of this post we will have written Pong without any
imperative code. No global mutable state, no flipping pixels, no destructive
updates. In fact, Elm disallows all of these things at the language level.
So good design and safe coding practices are a requirement, not just
self-enforced suggestions.

Imperative programs allow you to reach into objects and data structures
whenever you want, so it is not a huge deal if your code is somewhat
disorganized. With functional game design, we must be more careful about how
our programs are structured. In fact in Elm, all games will share the same
underlying structure.

The structure of Elm games breaks into four major parts: modeling inputs,
modeling the game, updating the game, and viewing the game. It may be helpful
to think of it as a functional variation on the Model-View-Controller paradigm.

To make this more concrete, lets see how Pong needs to be structured:

 1. [**Inputs**](#inputs) &mdash; This is all of the stuff coming in from
    &ldquo;the world&rdquo;. For Pong, this is keyboard input from users and
    the passage of time.

 2. [**Model**](#model) &mdash; The model holds all of the information we will
    need to update the game and render it on screen. For Pong we need to model
    things like paddles, a ball, scores, and the &ldquo;pong court&rdquo;
    itself which interacts with the paddles and ball. (It seems that there is
    no way to refer to a &ldquo;pong court&rdquo; that does not sound silly.)

 3. [**Update**](#update) &mdash; When new inputs come in, we need to update
    the game. Without updates, this version of Pong would be very very boring!
    This section defines a number of *step functions* that step the game forward
    based on our inputs. By separating this from the model and display code,
    we can change how the game works (how it steps forward) without changing
    anything else: the underlying model and the display code need not be touched.

 4. [**View**](#view) &mdash; Finally, we need a display function that defines
    the user&rsquo;s view of the game. This code is completely separate from
    the game logic, so it can be modified without affecting any other part of
    the program. We can also define many different views of the same underlying
    model. In Pong there is not much need for this, but as your model becomes
    more complex this may be very useful!

If you would like to make a game or larger application in Elm, use this
structure! I provide both [the source code for Pong][src] and [an empty
skeleton for game creation][skeleton] which can both be a starting point for
playing around with your own ideas.

 [src]: /edit/examples/Intermediate/Pong.elm
 [skeleton]: https://github.com/elm-lang/elm-lang.org/blob/master/public/examples/Intermediate/GameSkeleton.elm

Let&rsquo;s get into the code!

<h1 id="inputs">Inputs</h1>

This game has two primary inputs: the passage of time and key presses.
With the keyboard, we to keep track of:

  * SPACE &mdash; to pause and unpause the game.
  * w/s &mdash; whether paddle *one* is moving up or down.
  * &uarr;/&darr; &mdash; whether paddle *two* is moving up or down.

We can represent the state of the SPACE key with a boolean value. Up and down
can be represented by an integer in { -1, 0, 1 }. So to represent the game
like this:

```haskell
type Input = { space:Bool, paddle1:Int, paddle2:Int, delta:Time }
```

From here we will actually define these inputs. To keep track of the passage of
time, we define `delta` using the `fps` function. The `fps` takes a target
frames-per-second and gives a sequence of time deltas that gets as close to the
desired FPS as possible. If the browser can not keep up, the time deltas will
slow down gracefully.

```haskell
delta : Signal Time
delta = inSeconds <~ fps 35
```

Now we put that together with the [keyboard][] inputs to make a signal representing
all inputs.

 [keyboard]: http://library.elm-lang.org/catalog/elm-lang-Elm/latest/Keyboard

```haskell
input : Signal Input
input = sampleOn delta <| Input <~ Keyboard.space
                                 ~ lift .y Keyboard.wasd
                                 ~ lift .y Keyboard.arrows
                                 ~ delta
```

Notice that we sample on time deltas so that keyboard events do not
cause extra updates. We want 35 frames per second, not 35 plus the
number of key presses.

<h1 id="model">Model</h1>

Here we will define the data structures that will be used throughout the rest
of the program. This is the foundation of our game, so changes here will likely
cause changes in both the update and view code.

These models are a rough specification for your game. They force you to ask:
Which features do I want? What information do I need for those features? How
do I represent that information? Once you have figured out the core information
needed for your game, you have already done a lot of planning about how
everything else will work. Do not be afraid to spend a lot of time thinking
about this!

The most basic thing we need to model is the &ldquo;pong court&rdquo;. This
just comes down to the dimensions of the court to know when the ball should
bounce and where the paddles should stop. We will also define halfway points
which are commonly used. 

```haskell
(gameWidth,gameHeight) = (600,400)
(halfWidth,halfHeight) = (300,200)
```

Now that we have a court, we need a ball and paddles. We will define these data
structures so that they share a lot of structure. Both have a position and
velocity, so thanks to [structural typing](/learn/Records.elm) in Elm, we can
share some code later on.

```haskell
type Object a = { a | x:Float, y:Float, vx:Float, vy:Float }

type Ball = Object {}

type Player = Object { score:Int }
```

Both `Ball` and `Player` have a position and velocity, but notice that a
`Player` has one extra field for representing the player&rsquo;s score.

We also want to be able to pause the game between volleys so the user can take
a break. We do this with an [algebraic data type](/learn/Pattern-Matching.elm)
which we can later extend if we want more game states for speeding up gameplay
or whatever else.

```haskell
data State = Play | Pause
```

We now have a way to model balls, players, and the game state, so we just need
to put it together. We define a `Game` that includes all of these things and
then create a default game state.

```haskell
type Game = { state:State, ball:Ball, player1:Player, player2:Player }

player : Float -> Player
player x = { x=x, y=0, vx=0, vy=0, score=0 }

defaultGame : Game
defaultGame =
  { state   = Pause
  , ball    = { x=0, y=0, vx=200, vy=200 }
  , player1 = player (20-halfWidth)
  , player2 = player (halfWidth-20)
  }
```

The `defaultGame` is the starting state, so we pause the game, place the ball
in the middle of the screen, and put the paddles on either side of the court.

<h1 id="update">Update</h1>

Our `Game` data structure holds all of the information needed to represent the
game at any moment. In this section we will define a *step function* that steps
from `Game` to `Game`, moving the game forward as new inputs come in.

To make our step function more managable, we can break it up into smaller
functions. This next chunk of code defines some not-so-interesting helper
functions: `near` and `within` for detecting collisions and `stepV` for safely
stepping velocity.

```haskell
-- are n and m near each other?
-- specifically are they within c of each other?
near : Float -> Float -> Float -> Bool
near n c m = m >= n-c && m <= n+c

-- is the ball within a paddle?
within : Ball -> Player -> Bool
within ball player =
    (ball.x |> near player.x 8) && (ball.y |> near player.y 20)

-- change the direction of a velocity based on collisions
stepV : Float -> Bool -> Bool -> Float
stepV v lowerCollision upperCollision =
  if | lowerCollision -> abs v
     | upperCollision -> 0 - abs v
     | otherwise      -> v
```

Okay, now that we have the boring functions, we can define step functions
for balls and paddles. Notice that `stepObj` which uses structural typing to
share code between `stepBall` and `stepPlyr`. `stepObj` changes an objects
position based on its velocity, so `stepBall` and `stepPlyr` can just focus
on how their velocities change.

```haskell
-- step the position of an object based on its velocity and a timestep
stepObj : Time -> Object a -> Object a
stepObj t ({x,y,vx,vy} as obj) =
    { obj | x <- x + vx * t
          , y <- y + vy * t }

-- move a ball forward, detecting collisions with either paddle
stepBall : Time -> Ball -> Player -> Player -> Ball
stepBall t ({x,y,vx,vy} as ball) player1 player2 =
  if not (ball.x |> near 0 halfWidth)
  then { ball | x <- 0, y <- 0 }
  else
    let vx' = stepV vx (ball `within` player1) (ball `within` player2)
        vy' = stepV vy (y < 7-halfHeight) (y > halfHeight-7)
    in
        stepObj t { ball | vx <- vx', vy <- vy' }

-- step a player forward, making sure it does not fly off the court
stepPlyr : Time -> Int -> Int -> Player -> Player
stepPlyr t dir points player =
  let player' = stepObj t { player | vy <- toFloat dir * 200 }
      y'      = clamp (22-halfHeight) (halfHeight-22) player'.y
      score'  = player.score + points
  in
      { player' | y <- y', score <- score' }
```

Now that we have the `stepBall` and `stepPlyr` helper functions, we can define
a step function for the entire game. Here we are stepping our game forward based
on inputs from the world.

```haskell
stepGame : Input -> Game -> Game
stepGame {space,paddle1,paddle2,delta}
         ({state,ball,player1,player2} as game) =
  let score1 = if ball.x >  halfWidth then 1 else 0
      score2 = if ball.x < -halfWidth then 1 else 0

      state' = if | space            -> Play
                  | score1 /= score2 -> Pause
                  | otherwise        -> state

      ball' = if state == Pause then ball else
                  stepBall delta ball player1 player2

      player1' = stepPlyr delta paddle1 score1 player1
      player2' = stepPlyr delta paddle2 score2 player2
  in
      { game | state   <- state'
             , ball    <- ball'
             , player1 <- player1'
             , player2 <- player2' }
```

Finally we put together the inputs, the default game, and the step function to
define `gameState`.

```haskell
gameState : Signal Game
gameState = foldp stepGame defaultGame input
```

This models the state of the game over time.

<h1 id="view">View</h1>

The view is totally independent of how the game updates, it is only based on
the model. This means we can change how the game looks without changing any of
*the update logic* of the game.

You can be as fancy and elaborate as you want in the view, but I will try to
keep our display fairly simple! The most interesting thing about this code is
that the `displayObj` function allows us to share some code for rendering balls
and players. The rest of the code is more about drawing the pong court and
displaying scores and instructions nicely.

```haskell
-- helper values
pongGreen = rgb 60 100 60
textGreen = rgb 160 200 160
txt f = leftAligned << f << monospace << Text.color textGreen << toText
msg = "SPACE to start, WS and &uarr;&darr; to move"

-- shared function for rendering objects
displayObj : Object a -> Shape -> Form
displayObj obj shape =
    move (obj.x,obj.y) (filled white shape)

-- display a game state
display : (Int,Int) -> Game -> Element
display (w,h) {state,ball,player1,player2} =
  let scores : Element
      scores = txt (Text.height 50) <|
               show player1.score ++ "  " ++ show player2.score
  in 
      container w h middle <|
      collage gameWidth gameHeight
       [ filled pongGreen   (rect gameWidth gameHeight)
       , displayObj ball    (oval 15 15)
       , displayObj player1 (rect 10 40)
       , displayObj player2 (rect 10 40)
       , toForm scores
           |> move (0, gameHeight/2 - 40)
       , toForm (if state == Play then spacer 1 1 else txt id msg)
           |> move (0, 40 - gameHeight/2)
       ]
```

Now that we have a way to display a particular game state, we just
apply it to our `gameState` that changes over time.

```haskell
main = lift2 display Window.dimensions gameState
```

And that is it, [Pong in Elm](/edit/examples/Intermediate/Pong.elm)!

<br/>

# Further Reading and Exercises

If you want to read more about FRP for games, see [this paper][afrp]. Note that
it is specific to Arrowized FRP, which is supported by Elm&rsquo;s
[Automaton][automaton] library.

 [afrp]: http://haskell.cs.yale.edu/wp-content/uploads/2011/01/yampa-arcade.pdf
 [automaton]: http://library.elm-lang.org/catalog/evancz-automaton/latest

Learning by doing is a great way to improve your skills, so if you want to
learn more about making games in Elm, try tackling some of these challenges:

 * Make the Pong field look nicer. Add a line (or dotted line) at mid-field.

 * Add the ability to pause the game during game play.

 * Add the ability to reset the game (besides refreshing the page!)

 * Make ball collisions more complicated. Possiblities:

     * When the ball hits the corner of a paddle, it changes direction.

     * If the ball hits a moving paddle, it adds spin to the ball, making it
       rebound in a different direction.

 * Add a second ball to the game.

 * Write a simple AI for a paddle. A simple strategy is to always put the
   paddle at the same y height as the ball, but this is not very fun to play
   against. Maybe try an AI that is not so smart to make things more
   interesting.

|]
