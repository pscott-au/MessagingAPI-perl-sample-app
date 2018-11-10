use strict;
use warnings;
package WebService::TelstraAPI::Messaging;
use Mojo::Base -base;
use Mojo::UserAgent;
use Storable;
use Data::Dump qw/pp/;
use Carp;
# ABSTRACT: Telstra SMS Messaging API allows your applications to send and receive SMS text messages

has ua => sub {
  my $ua = Mojo::UserAgent->new(inactivity_timeout => 600);
  $ua->on(
    start => sub {
      my ($ua, $tx) = @_;
      $tx->res->max_message_size(2147483648);

      # Work around misconfigured IBS reverse proxy servers that send
      # "Content-Encoding: gzip" without being asked to
      #$tx->req->headers->add('Authorization' => 'Bearer ' . $self->access_token );
      #$tx->res->content->auto_decompress(0);
    }
  );
  return $ua;
};

#has storable => sub {
    #retrieve(dirname($0) . "/tokenstore.bin")
#    my ( $self ) = @_;
    #warn pp $self;
    #print qq{hre we are \n};
#};

has   token => '';
has   token_expires => 0;
has   client_id => '';
has   client_secret => '';
has debug => 0;
#has access_token =>  'default-access-token'; 



sub validate_token 
{
    my ( $self ) = @_;
	if ( $self->token and $self->token_expires > time() ) {
		carp "Oauth token present and valid... Using existing token - expires in " . ( $self->token_expires - time() ) . ' seconds  ' if $self->debug;
		return;
	}
    else 
    {
        carp( "refreshing token") if $self->debug;
        my $tx = $self->ua->build_tx( 'POST' => 'https://sapi.telstra.com/v1/oauth/token', => {Accept => '*/*'} => form => {
            'grant_type'	=> 'client_credentials',
            'scope'		=> 'NSMS',
            'client_id'	=> $self->client_id,
            'client_secret'	=> $self->client_secret,
         } );
         my $res = $self->ua->start( $tx )->res->json;
         $self->token( $res->{access_token} );
         $self->token_expires( $res->{expires_in} + time() - 60 );
         return;
    }
}




sub build_authenticated_tx 
{
    my ( $self, @params ) = @_;

    my $tx = $self->ua->build_tx( @params );
    $tx->req->headers->header( 'Content-Type'  => 'application/json' );
    $tx->req->headers->header( 'Authorization' => 'Bearer ' . $self->token );
    return $tx;
}



sub get_subscription
{
    my ( $self, $config ) = @_;
    $self->validate_token();
    my $tx = $self->build_authenticated_tx( 'GET' => 'https://tapi.telstra.com/v2/messages/provisioning/subscriptions' );
    #$tx->req->headers->header( 'Content-Type' => 'application/json' );
    #$tx->req->headers->header( 'Authorization' => 'Bearer ' . $self->token );
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
