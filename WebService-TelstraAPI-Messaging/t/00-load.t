#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

# plan tests => 4; # instead of noplan using  done_testing;

BEGIN {
    use_ok( 'WebService::TelstraAPI::Messaging' ) || print "Bail out!\n";

}


done_testing;
diag( "Testing WebService::TelstraAPI::Messaging, Perl $], $^X" );
