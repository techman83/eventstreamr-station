package App::EventStreamr::Process;
use Method::Signatures;
use Moo;
use Scalar::Util::Reftype;
use Carp 'croak';
use namespace::clean;

# ABSTRACT: A process object

# VERSION: Generated by DZP::OurPkg:Version

=head1 SYNOPSIS

This package provides core start/stop logic for all processes
and devices.

=head1 DESCRIPTION

This package provides the core run/stop logic for EventStreamr. A 
process will extend this and provide any extra logic specific to its
needs.

It consumes the 'ProcessControl' role with requires a 'cmd' attribute 
and will utilise an optional 'cmd_regex' if one exists.

=cut

my $ConfigRef = sub {
  croak "auth isn't a 'App::EventStreamr::Config' object!" unless reftype( $_[0] )->class eq "App::EventStreamr::Config";
};

my $StatusRef = sub {
  croak "auth isn't a 'App::EventStreamr::Status' object!" unless reftype( $_[0] )->class eq "App::EventStreamr::Status";
};

has 'config'      => ( is => 'rw', required => 1, isa => $ConfigRef );
has 'status'      => ( is => 'rw', required => 1, isa => $StatusRef );
has 'cmd'         => ( is => 'ro', required => 1 );
has 'id'          => ( is => 'ro', required => 1 );
has 'type'        => ( is => 'ro', default => sub { 'internal' } );
has 'sleep_time'  => ( is => 'ro', default => sub { 1 } );
has 'cmd_regex'   => ( is => 'ro' );

method _run() {
  # Unless we spefically set our state we're going to want to run
  # By default our control config will be empty and this shortcut
  # attriubute makes things look a little cleaner.
  my $run = defined $self->{config}{control}{$self->{id}}{run} ? $self->{config}{control}{$self->{id}}{run} : 1;

  $self->{config}{control}{$self->{id}}{run} = $run;
  
  # We only want to run if both the process is set to run
  # and the system is set to run.
  if ($run && $self->{config}{run}) {
    return 1;
  } else {
    return 0;
  }
}

method _restart() {
  if (defined $self->{config}{control}{$self->{id}}{run} && $self->{config}{control}{$self->{id}}{run} == 2) {
    return 1;
  } else {
    return 0;
  }
}

=method run_stop
  $device->run_stop()

Will start the process if it's intended to be running or stop it
if isn't.

=cut

method run_stop() {
  if ($self->_restart) {
    $self->info("Restarting ".$self->id." with command: ".$self->cmd);
    $self->status->restarting($self->{id},$self->{type});

    if (! $self->running) {
      $self->{config}{control}{$self->{id}}{run} = 1;
    } else {
      $self->status->stopping($self->{id},$self->{type});
      $self->stop();
    
      # Give the process time to settle.
      sleep $self->sleep_time;
    }

  } elsif ( $self->_run && ! $self->pid) {
    # Slows down the restarts to ensure we don't flood logs
    # and control systems.
    return if $self->status->threshold($self->{id},$self->{type});

    $self->info("Starting ".$self->id." with command: ".$self->cmd);
    $self->status->starting($self->{id},$self->{type});

    $self->start();
  
    # Give the process time to settle.
    sleep $self->sleep_time;
  } elsif ( (! $self->_run && $self->pid ) ) {
    $self->info("Stopping ".$self->id);
    $self->status->stopping($self->{id},$self->{type});

    $self->stop();

    # Give the process time to settle.
    sleep $self->sleep_time;
  }
  

  # Write config on state change.
  if ( $self->status->set_state($self->running,$self->{id},$self->{type}) ) {
    $self->info("State changed for ".$self->id);
    $self->config->write_config();
  }
  return;
}

with('App::EventStreamr::Roles::Logger','App::EventStreamr::Roles::ProcessControl');

1;
