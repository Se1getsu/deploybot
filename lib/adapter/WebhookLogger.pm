package Adapter::WebhookLogger;

use strict;
use warnings;

use Moose;
with 'Role::LoggerRole';

use JSON::MaybeXS;

sub new {
    my ($class, %args) = @_;
    my $self = {
        _info_webhook_url   => $args{info_webhook},
        _error_webhook_url  => $args{error_webhook},
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
    _send("[$timestamp] INFO: $message\n", $self->{_info_webhook_url});
}

sub error {
    my ($self, $message) = @_;
    my $timestamp = localtime;
    _send("[$timestamp] ERROR: $message\n", $self->{_error_webhook_url});
}

1;
