#!/usr/bin/env perl

use strictures;

use WebService::TelstraAPI::Messaging;
use Data::Dump qw/pp/;
use Storable;

my $config = retrieve( "./tokenstore.bin");
# $config = {
#   token => 't',
#   token_expires => 1,
#   client_id => 'c',
#   client_secret => 's',
# }
#pp $config;

my $m = WebService::TelstraAPI::Messaging->new( %$config );

my $tx = $m->get_subscription();

print pp $tx;

## store new credentials with up-to-date token
store {
    client_id      => $m->client_id ,
    client_secret  => $m->client_secret ,
    token          => $m->token ,
    token_expires  => $m->token_expires ,
  }, "tokenstore.bin" ;



