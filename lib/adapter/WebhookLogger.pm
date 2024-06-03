package Adapter::WebhookLogger;

use strict;
use warnings;

use Moose;
with 'Role::LoggerRole';

use JSON::MaybeXS;
use Adapter::WebhookURLRepository 'load_urls';

sub new {
    my ($class) = @_;
    return bless {}, $class;
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
    my @webhook_urls = load_urls;
    _send("[$timestamp] INFO: $message\n", $webhook_urls[0]);
}

sub error {
    my ($self, $message) = @_;
    my $timestamp = localtime;
    my @webhook_urls = load_urls;
    _send("[$timestamp] ERROR: $message\n", $webhook_urls[1]);
}

1;
