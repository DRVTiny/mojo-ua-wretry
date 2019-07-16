package Mojo::UserAgent::WithRetry;
use 5.16.1;
use strict;
use warnings;
use utf8; # for server messages containing utf8-symbols
use Data::Dumper;

use constant {
    MOJO_UA_MAX_RETRIES		=> 5,
    MOJO_UA_RETRY_INTERVAL	=> 0.2,
};
use base 'Mojo::UserAgent';

BEGIN {
    no strict 'refs';
    for my $rqType (qw/get post put delete/) {
        *{__PACKAGE__ . '::' . $rqType . '_with_retry'} = sub {
            my $self = $_[0];
            my $uaMethod = $self->can($rqType)
                or die 'Mojo::UserAgent does not support method ' . $rqType;
            my $userCallback = pop @_;
            my $cntErrors = 0;
            my @methodArgs;
            push @_, sub {
                my ($ua, $tx) = @_;
                my $res = $tx->res;
                if ( defined( $res->error ) and ! defined( $res->code ) and $cntErrors++ < MOJO_UA_MAX_RETRIES ) {
                    $ENV{'MOJO_USERAGENT_DEBUG'}
                        and printf STDERR "request failed, reason: <<%s>>. will retry after %f sec.\n", 
                                $res->error->{message},
                                MOJO_UA_RETRY_INTERVAL;
                    Mojo::IOLoop->timer(MOJO_UA_RETRY_INTERVAL() => sub {
                        say STDERR 'retrying request';
                        print Dumper \@methodArgs;
                        $uaMethod->( @methodArgs )
                    })
                } else {
                    $userCallback->($ua, $tx)
                }
            };
            @methodArgs = @_;
            &{$uaMethod}
        }
    }
}

1;
