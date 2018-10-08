# Radio on the Internet
Putting radio on the internet. Again.


### Significant Features
- Live streaming from any_(*)_ ROI-server
- Background play
- Watch companion app _(that mostly works pretty well)_

_*) there exists only one, and for copyright reasons I don't think anyone else
can use it. I'm not technically sure if **I** can use it._


### Building
_(Note that this might be out of date)_

- Install dependency pods throuch CocoaPods _(`pod install`)_
- Run the icon-generating script located at `scripts/gen-icons.sh`
- You should be good to go

Note that in order to actually do anything with the app, you need to point the app
to a ROI-server. See the [ROI Server Project](https://github.com/pimms/roiserver).


### What, why?
ROI is an app invented to reinvent radio, again, but not really, because all of this
really did exist before.

I started this application because I'm unhealthily fond of Radioresepsjonen,
and the official channels don't offer exactly what I want; a radio channel
playing every single episode they have ever made, in a shuffled order, just
like an actual radio channel. I'm fairly certain that I can't distribute or
publish this application as a "Radioresepsjonen player", so both the server and
client are completely generic, and can in theory be used to play anything.

This app also works as a tool for me to learn iOS-development _(which is why
I'm adding features that serve virtually no benefit to anyone)_ and further
hone my backend-blade. Mostly though, I'm just scratching my own RR-itch.

