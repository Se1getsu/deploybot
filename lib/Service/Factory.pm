package Service::Factory;

use strict;
use warnings;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(create);

use Module::Load;
use Adapter::TargetShellExecutor;
use Adapter::WebhookLogger;
use Adapter::WebhookURLRepository 'load_urls';

sub create {
    my ($module) = @_;

    if ($module eq 'Dpb::Hello') {
        load $module;
        my @webhook_urls = load_urls;
        return $module->new(
            logger => Adapter::WebhookLogger->new(
                info_webhook => $webhook_urls[0],
                error_webhook => $webhook_urls[1],
            )
        );

    } elsif ($module eq 'Dpb::Run') {
        load $module;
        my @webhook_urls = load_urls;
        return $module->new(
            logger => Adapter::WebhookLogger->new(
                info_webhook => $webhook_urls[0],
                error_webhook => $webhook_urls[1],
            ),
            target_executor => Adapter::TargetShellExecutor->new(
                info_webhook => $webhook_urls[2],
                error_webhook => $webhook_urls[3],
            )
        );

    } elsif ($module eq 'Dpb::Log') {
        load $module;
        return $module;

    } elsif ($module eq 'Dpb::SetLog') {
        load $module;
        return $module;

    } else {
        die "The method of creating module $module is not defined."
    }
}
