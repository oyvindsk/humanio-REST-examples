#!/usr/bin/env perl

use Mojolicious::Lite;
use Mojo::UserAgent;
use Data::Dumper;


## 
## Set human.io keys etc..

use constant API_URL => 'http://api.human.io/v1';

my $developer_id = $ENV{HIO_DEVELOPER_ID} or die("Set environment variable HIO_DEVELOPER_ID (or just put it in the scipt)");
my $secret_key   = $ENV{HIO_SECRET_KEY}   or die("Set environment variable HIO_SECRET_KEY (or just put it in the scipt)");


##
## Ask duckduckgo for our (external) ip.
## We must be able to handle incomming connections on this IP since human.io will callback to us

my $ip;
my $dd_res = app->ua->get('http://duckduckgo.com/?q=my+ip')->res;

if( $dd_res and $dd_res->dom->at('#zero_click_abstract') and $dd_res->dom->at('#zero_click_abstract')->text =~ /Your IP address is (\d+.\d+.\d+.\d+)/ ){
    $ip = $1;
    app->log->debug("Found my own IP: $ip");
}

die "Could not get your IP, set it above here in the script" unless $ip;



## 
## POST to human.io and create an app  and a task

my $ua = Mojo::UserAgent->new;

## Create App
app->log->debug("Creating App..");

my $last_res = $ua->post_form( API_URL . '/app' => {
        developer_id    => $developer_id,
        secret_key      => $secret_key,
        callback_url    => "http://$ip:3000/cb", # FIXME : Don't hardcode the port-number
        public          => 0,                    # Only vissible to the ones that either have the URL or are subscribed to us
        # app_id          => "rest-testapp",     # Lets leave it out and let human.io chose a random one
    })->res;


app->log->debug("\tserver said: " . $last_res->body);

# Store the app_id they picked, need it later
my $app_id = $last_res->json->{app_id} or die "Server returned non-json: '" . $last_res->body . "'";


## Create a Task

app->log->debug("Creating Task..");

$last_res = $ua->post_form( API_URL . '/task' => {
        developer_id            => $developer_id,
        secret_key              => $secret_key,
        app_id                  => $app_id,
        # task_id               => "FOO",
        description             => "Hello World from the REST API",
        # thumbnail             => "URL??",         # Thumbnail to show in the app
        # items                 => "",              # list of objects?? Json?? ,
        humans_per_item         => 1,
        hidden                  => 0,
        camera                  => 0,               # Limit to ppl with camera (1|0)
        auto_repeat             => 0,
        human_can_do_multiple   => 0,               # same item or same task?

        ## Limit to ppl within ..
        # latitude => 242.4234,
        # longitude => 23424.234,
        # radius_miles => 0.34,
} )->res;


app->log->debug("\tserver said: " . $last_res->body);


##
## Listen for incomming connections. 

post '/cb/' => sub {

    # On POST to /cb/ run this sub..

    my $self = shift;
    my $log  = $self->app->log;
    
    my $data = $self->req->json ;

    if($data){
        $log->debug("Got json data:\n\t" . Dumper($data));
    };

    if($data->{event_name}){

        if( $data->{event_name} eq 'human_connected'){

            # Looks something like this: 
            #   {
            #       "status": "ok",
            #       "item": {},
            #       "human": {
            #           "latitude": null, 
            #           "camera": false,
            #           "hashed_human_id": "..", 
            #           "human_id": "..", 
            #           "longitude": null
            #       }, 
            #       "task_id": "..", 
            #       "event_name": "human_connected", 
            #       "session_id": ".."
            #   } 

            $log->debug("Human connected!");
            
            $log->debug("Saying hello..");

            my $res = $self->ua->post_form( API_URL . "/session/$data->{session_id}/call" => {
                developer_id    => $developer_id,
                secret_key      => $secret_key,
                calls           => '[
                    { "method": "add_text", "text": "Hello =)" },
                    { "method": "add_submit_button" }
                    ]'
            })->res;


            $log->debug("\tserver said: " . $res->body);

        } elsif( $data->{event_name} eq 'human_submitted' ){

            $log->debug("Saying Thanks..");

            my $res = $self->ua->post_form( API_URL . "/session/$data->{session_id}/call" => {
                developer_id    => $developer_id,
                secret_key      => $secret_key,
                calls           => '[ { "method": "add_text", "text": "Thanks!" } ]'
            })->res;

            $log->debug("\tserver said: " . $res->body);

            $log->debug("dismissing connected human");

            $res = $self->ua->post_form( API_URL . "/session/$data->{session_id}/dismiss" => {
                    developer_id    => $developer_id,
                    secret_key      => $secret_key,
                    app_id          => $app_id,
                    task_id         => $data->{task_id},
                    approve         => 1,
                    delay_seconds   => 2,
                    # new_task_hashed_id => FOO,
                    })->res;

            $log->debug("\tserver said: " . $res->body);

        }
    }

    # Don't think it's usefull to "return" anything?
    $self->render( text => "" ); 

};



app->start;

__DATA__

