package LWP::UserAgent::Patch::Delay;

# DATE
# VERSION

use 5.010001;
use strict;
no warnings;
use Log::ger;

use Module::Patch ();
use base qw(Module::Patch);

use Time::HiRes qw(sleep);

our %config;

my $seen;
my $p_send_request = sub {
    my $ctx  = shift;
    my $orig = $ctx->{orig};

    if ($seen++) {
        my $secs = $config{-between_request} // 1;
        log_trace "Sleeping %.1f second(s) between LWP::UserAgent request ...",
            $secs;
        sleep $secs;
    }
    $ctx->{orig}->(@_);
};

sub patch_data {
    return {
        v => 3,
        config => {
            -between_request => {
                schema  => 'nonnegnum*',
                default => 1,
            },
        },
        patches => [
            {
                action => 'wrap',
                mod_version => qr/^6\./,
                sub_name => 'send_request',
                code => $p_send_request,
            },
        ],
    };
}

1;
# ABSTRACT: Add sleep() between requests to slow down

=head1 SYNOPSIS

 use LWP::UserAgent::Patch::Delay;


=head1 DESCRIPTION

This patch adds sleep() between L<LWP::UserAgent>'s requests.


=head1 CONFIGURATION

=head2 -between_request

Float. Default is 1. Number of seconds to sleep() after each request. Uses
L<Time::HiRes> so you can include fractions of a second, e.g. 0.1 or 1.5.


=head1 FAQ

=head2 Why not subclass?

By patching, you do not need to replace all the client code which uses
L<LWP::UserAgent> (or WWW::Mechanize, and so on).


=head1 SEE ALSO

L<LWP::UserAgent>

L<HTTP::Tiny::Patch::Delay>

=cut
