package App::EventStreamr::Ingest;
use Method::Signatures;
use Scalar::Util::Reftype;
use Carp 'croak';
use Module::Load;
use Moo;
use namespace::clean;

# ABSTRACT: A Ingest object

# VERSION: Generated by DZP::OurPkg:Version

=head1 SYNOPSIS

This package provides an extendable class for starting/stopping
ingest devices.

=head1 DESCRIPTION

This package provides the core run/stop logic for Ingest Devices. A 
backend specific package will extend this and provide any extra logic 
specific to its needs.

'backend' is expected to be overridden by the consuming role.

=cut

my $ConfigRef = sub {
  croak "config isn't a 'App::EventStreamr::Config' object!" unless reftype( $_[0] )->class eq "App::EventStreamr::Config";
};

my $StatusRef = sub {
  croak "config isn't a 'App::EventStreamr::Status' object!" unless reftype( $_[0] )->class eq "App::EventStreamr::Status";
};

has 'config'      => ( is => 'rw', required => 1, isa => $ConfigRef );
has 'status'      => ( is => 'rw', required => 1, isa => $StatusRef );
has 'backend'     => ( is => 'ro', default => sub { 'DVswitch' } );
has '_devices'    => ( is => 'ro', default => sub { { } } );

method _load_package($device) {
  my $pkg = "App::EventStreamr::".$self->backend."::Ingest::$device->{type}";
  load $pkg;
  $self->_devices->{$device->{id}} = $pkg->new(
    device => $device->{device},
    id => $device->{id},
    config => $self->config,
    status => $self->status,
  );
}

=method start

  $ingest->start()

Will start all configured devices.

=cut

method start() {
  foreach my $device (@{$self->config->devices}) {
    if (! defined $self->_devices->{$device->{id}}) {
      $self->_load_package($device);
    }
    $self->_devices->{$device->{id}}->start();
  }
}

=method run_stop

  $ingest->run_stop()

Will start all configured devices if they're intended to be running 
or stop them if they're not.

=cut

method run_stop() {
  foreach my $device (@{$self->config->devices}) {
    if (! defined $self->_devices->{$device->{id}}) {
      $self->_load_package($device);
    }
    $self->_devices->{$device->{id}}->run_stop();
  }
}

=method stop

  $ingest->stop()

Will stop all configured devices.

=cut

method stop() {
  foreach my $device (@{$self->config->devices}) {
    if (! defined $self->_devices->{$device->{id}}) {
      $self->_load_package($device);
    }
    $self->_devices->{$device->{id}}->stop();
  }
}

1;
