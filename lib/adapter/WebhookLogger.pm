package Adapter::WebhookLogger;

use strict;
use warnings;

use Moose;
with 'Role::LoggerRole';

use JSON::MaybeXS;

sub new {
    my ($class, %args) = @_;
    my $self = {
        _info_webhook   => $args{info_webhook},
        _error_webhook  => $args{error_webhook},
    };
    return bless $self, $class;
}

sub _send {
    my ($content, $url) = @_;
    my $json = JSON::MaybeXS->new(utf8 => 1, pretty => 1);
    my $request_body = $json->encode({ content => $content });
    system('curl', '-X', 'POST', '-H', 'Content-Type: application/json', '-d', $request_body, $url)
}

sub info {
    my ($self, $message) = @_;
    my $timestamp = localtime;
    my $content = "[$timestamp] INFO: $message\n";
    if ($self->{_info_webhook} eq "default") {
        print STDOUT $content;
    } else {
        _send($content, $self->{_info_webhook});
    }
}

sub error {
    my ($self, $message) = @_;
    my $timestamp = localtime;
    my $content = "[$timestamp] ERROR: $message\n";
    if ($self->{_error_webhook} eq "default") {
        print STDERR $content;
    } else {
        _send($content, $self->{_error_webhook});
    }
}

1;
