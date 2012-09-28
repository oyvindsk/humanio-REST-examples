## Simple Human.io REST example, using perl5 and Mojolicious

Human.io hello world using the REST callback API.

It first creates a Human.io app by POST'ing to their REST API and then starts to listen for callbacks from the human.io servers.

- http://human.io
- http://human.io/docs/rest
- http://boingboing.net/2012/09/25/humanio.html

## Usage

You need perl5 (at least 5.10) and the Mojolicious module. 

### Get Mojolicious
There's Mojolicious packages for many systems.
If you cant find one (or it's outdated) and you're comfortable with running random code from the web, you can do:  

        $ curl get.mojolicio.us | sh

#### Mojolicious info:
- http://mojolicio.us/ 
- https://github.com/kraih/mojo 

### Running
Set the two environment variables HIO_DEVELOPER_ID and HIO_SECRET_KEY and run the perl file.

For example:

        $ HIO_DEVELOPER_ID=foo HIO_SECRET_KEY=bar ./hello_world.pl

Note: By default it is private (public => 0) so you have to follow yourself to see the app.