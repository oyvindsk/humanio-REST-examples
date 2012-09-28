
## Simple Human.io REST example, using perl5 and Mojolicious

Human.io hello world using the REST callback API.

- http://human.io
- http://human.io/docs/rest 

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