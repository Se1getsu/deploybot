package Service::Factory;

use strict;
use warnings;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(create);

use Module::Load;
use Adapter::WebhookLogger;

sub create {
    my ($module) = @_;

    if ($module eq 'Dpb::Hello') {
        load $module;
        return $module->new(
            logger => Adapter::WebhookLogger->new()
        );

    } elsif ($module eq 'Dpb::Run') {
        load $module;
        return $module->new(
            logger => Adapter::WebhookLogger->new()
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
