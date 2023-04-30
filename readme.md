# LD53 - Delivery - "Space Truckers"

This is my attempt at making a game for the Ludem Dare 53, from April 28th - April 30th. The theme for this game jam was "Delivery"

My biggest goal was doing something -- anything -- with Networking. Admittedly my goal was not to finish the game jam with a fleshed out project.

## Controls

* `W` or `UP` -- Thrust Forwards
* `S` or `DOWN` -- Thrust Backwards
* `A` or `LEFT` -- Rotate counter-clockwise
* `D` or `RIGHT` -- Rotate clockwise
* `X` -- Full Stop -- pleasantly stop your ships momentum
* `Q` -- Translate Left -- accelerate your ship to the left
* `E` -- Translate Right -- accelerate your ship to the right

There's some fun movement behavior. I wanted to get a slight neutoniun feel but still have some "Sludge" slowing down the ship for easy controls.

## Learnings

* I learned Godot Networking! That was pretty neat. The documentation for the new multiplayer features needs a lot of time love and care
* This was my first major project in Godot 4 and there are still a lot of new things with GDScript to learn / adapt

It was fun seeing a lot of the reasons why modern game networking is setup how it is. There's a lot to learn!
* My game has significant ghosting problems, with "jittery" sprites
* To fix this, I would need to implement delayed rendering with 

## Releasing / Building

* Godot does not support low-level networking in browsers, so I had to scrounge up my TLS certs from my personal website
* Copy the `full` and `key` files and rename them to `fullchain.crt` and `key.key` to enable websocket connections
* Running `nu deploy.nu` will run a deploy, `scp` the files over `ssh` to my server
* I did not setup auto-running executables, so run the binary with `--headless` param to start the server
* Running in debug mode locally will use low-level networking features