use strict;
use warnings;
package WebService::TelstraAPI::Messaging;
use Mojo::Base -base;
use Mojo::UserAgent;
use Storable;
use Data::Dump qw/pp/;
use Carp;
use JSON;
use curry;
# ABSTRACT: Telstra SMS Messaging API allows your applications to send and receive SMS text messages

has   token         => '';
has   token_expires => 0;
has   client_id     => '';
has   client_secret => '';
has   debug => 0;



has ua => sub  { my ($self) = @_; 
                 Mojo::UserAgent->new->tap(on => start => $self->curry::weak::inject_auth_header) ;
            };

sub inject_auth_header  
{ 
    my ($self, $ua, $tx) = @_; 
    
    if (  $self->token =~ /\w+/mx) 
    {
        $tx->req->headers->header( 'Content-Type'  => 'application/json' );
        $tx->req->headers->header( 'Authorization' => 'Bearer ' . $self->token ) 
    }
    return $tx;
}


sub validate_token 
{
    my ( $self ) = @_;
    
    
    ## TODO: need some better checking here - esp. to get initial token
    my $t = $self->token() ;
    $self->token('') unless defined $t;
	if ( $self->token and $self->token_expires > time() ) {
		carp "Oauth token present and valid... Using existing token - expires in " . ( $self->token_expires - time() ) . ' seconds  ' if $self->debug;
		return;
	}
    else 
    {
        carp( "refreshing token") if $self->debug;
        $self->token(''); ## empty out stale token
        my $tx = $self->ua->build_tx( 'POST' => 'https://sapi.telstra.com/v1/oauth/token', => {Accept => '*/*' } =>  form => {
            'grant_type'	=> 'client_credentials',
            'scope'		=> 'NSMS',
            'client_id'	=> $self->client_id,
            'client_secret'	=> $self->client_secret,
         } );
         #pp $tx;
#         exit;
         my $res = $self->ua->start( $tx )->res;
         #pp $res;
         my $res_json = $res->json;
         croak("token renewal request response did not contain token and expires_in") unless defined $res_json->{access_token};
         croak("token renewal request response did not contain expires_in") unless defined $res_json->{expires_in};
         $self->token( $res_json->{access_token} );
         $self->token_expires( $res_json->{expires_in} + time() - 60 );
         return;
    }
}



sub get_subscription
{
    my ( $self, $config ) = @_;
    $self->validate_token();
    # my $tx = $self->build_authenticated_tx( 'GET' => 'https://tapi.telstra.com/v2/messages/provisioning/subscriptions' );
    my $tx = $self->ua->build_tx( 'GET' => 'https://tapi.telstra.com/v2/messages/provisioning/subscriptions'  );
    my $res = $self->ua->start(  $tx )->res;
    return $res->json;
}

=head2 C<send_sms>

    $agent->send_sms(  n=>'+61410580546', m=>'hello peter' )

=cut


sub send_sms
{
    my ( $self, %options ) = @_;
    $self->validate_token();
    ## If a number isn't provided with -n, prompt for destination number.
    if ( ! $options{n} ) {
        print "Enter destination number in format +61......: ";
        $options{n} = <STDIN>;
        chomp($options{n});
    }
    if ( $options{n} eq "" ) { exit 1; }

    ## If a message isn't provided with -m, prompt for a message.
    if ( ! $options{m} ) {
        print "Enter message to send: ";
        $options{m} = <STDIN>;
        chomp($options{m});
    }
    if ( $options{m} eq "" ) { exit 1; }

    my %body = (
        'to'	=> $options{n},
        'body'	=> $options{m},
    );

    ## Get an OAuth token if required.
    $self->validate_token();

   my $payload = to_json( {        'to'	=> $options{n},
        'body'	=> $options{m},} );

    #my $tx = $self->build_authenticated_tx( 'POST' => 'https://tapi.telstra.com/v2/messages/sms' =>  $payload );
    my $tx = $self->ua->build_tx( 'POST' => 'https://tapi.telstra.com/v2/messages/sms' =>  $payload );

    my $res = $self->ua->start(  $tx )->res;
    return $res->json;

}

=head2 LICENSE

This software is Copyright (c) 2018 by Peter Scott.

This is free software, licensed under:

  The MIT (X11) License

The MIT License

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to
whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall
be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT
WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT
SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut

1;
