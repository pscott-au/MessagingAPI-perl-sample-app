# Perl WebService-Telstra-Messaging

[![Build Status](https://travis-ci.org/pscott-au/MessagingAPI-perl-sample-app.svg?branch=master)](https://travis-ci.org/pscott-au/MessagingAPI-perl-sample-app)

The Telstra SMS Messaging API allows your applications to send and receive SMS text messages from Australia's leading network operator.

It also allows your application to track the delivery status of both sent and received SMS messages.

## Forked From Telstra Repo

This is a forked version from the demo code published by Telstra.

It has been augmented with the CPAN Module code contained beneath WebService-Telstra-Messaging which is a dzil build for the CPAN module.



## Original Telstra Demo Code Configuration

Edit functions.pm and fill out:
```
my $consumer_key = "";
my $consumer_secret = "";
```

See the documentation at [Dev.Telstra.com](https://dev.telstra.com/content/messaging-api) for more information
