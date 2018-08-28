# Joakims Rikskringkasting Listening Client

This is the companion app written to exclusively work with [JRK Server](https://github.com/pimms/jrk_server)

This app is *not* complete, and is missing a few required components for it to work properly. Because copyright.


## Background Image

You'll quickly notice that the main view needs a background image. You need to
supply this because of copyrights etc. Find your favorite image _(it probably
needs to be square, idk)_, and put it in `arrclient/assets/background-main.png`.


## JRK Server Host

You need to point the app at your JRK server instance.

There exists a file in `arrclient/assets/` named `TODO.plist`.

1. Rename the file to `AppConfig.plist`
2. Update the `jrkServerURL` field to point to the URL of your server.
   For instance, `https://jrk.isgreatm8.pizza`. No trailing slash.
3. Tataa

