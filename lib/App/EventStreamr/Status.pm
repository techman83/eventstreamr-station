package App::EventStreamr::Status;
use Method::Signatures;
use JSON;
use Scalar::Util::Reftype;
use Moo;
use namespace::clean;

# ABSTRACT: A status object

# VERSION: Generated by DZP::OurPkg:Version

=head1 SYNOPSIS

This package provides core status notification methods.

=head1 DESCRIPTION

Whilst at it's core EventStreamr Starts/Stops processes, the ability 
to notify when something goes wrong and can't be fixed by itself is
the primary job.

It provides some convinience methods to keep the Run/Stop code nice 
and simple. It also is intended to be passed around as a reference
to ensure state is maintained across the application.

=cut

#my $ConfigRef = sub {
#  croak "config isn't a 'App::EventStreamr::Config' object!" unless reftype( $_[0] )->class eq "App::EventStreamr::Config";
#};

has 'status'      => ( is => 'rw' );
has 'config'      => ( is => 'rw' );

method starting($id,$type) {
  # TODO: Logging here once log role exists
  $self->{status}{$id}{runcount} = $self->{status}{$id}{runcount} ? $self->{status}{$id}{runcount} + 1 : 1;
  $self->{status}{$id}{running} = 0;
  $self->{status}{$id}{status} = "starting";
  $self->{status}{$id}{state} = "soft";
  $self->{status}{$id}{type} = $type;
  $self->post_status();
}

method stopping($id) {
  # TODO: Logging here once log role exists
  $self->{status}{$id}{status} = "stopping";
  $self->{status}{$id}{state} = "soft";
  $self->post_status();
}

method restarting($id) {
  # TODO: Logging here once log role exists
  $self->{status}{$id}{status} = "restarting";
  $self->{status}{$id}{state} = "soft";
  $self->post_status();
}

method set_state($state,$id) {
  if (defined $self->{status}{$id}{running} &&
      $self->{status}{$id}{running} != $state) {
    # TODO: Logging here once log role exists
    $self->{status}{$id}{runcount} = 0;
    $self->{status}{$id}{running} = $state;
    $self->{status}{$id}{status} = $state ? 'started' : 'stopped';
    $self->{status}{$id}{state} = "hard";
    $self->{status}{$id}{timestamp} = time;
    $self->post_status();
    return 1;
  }
  return 0;
}

method threshold($id,$status = "failed") {
  my $age = $self->{status}{$id}{timestamp} ? time - $self->{status}{$id}{timestamp} : 0;
  if ( defined $self->{status}{$id}{runcount} && 
  ($self->{status}{$id}{runcount} > 5 && (time % 10) != 0) ) {
    $self->{status}{$id}{status} = $status;
    $self->{status}{$id}{state} = "hard";
    # TODO: Logging here once log role exists
    #("$id failed to start (count=$self->{device_control}{$device->{id}}{runcount}, died=$age secs ago)");
    $self->post_status();
    return 1;
  }
  return 0;
}

method post_status {
  if ($self->config) {
    my $json = to_json($self->{status});
    my %post_data = (
      content => $json,
      'content-type' => 'application/json',
      'content-length' => length($json),
    );
    my $post = $self->config->http->post(
      $self->config->api_url."/status",
      \%post_data,
    );

    if ( $self->config->controller ) {
      my $data;
      $data->{key} = "status";
      $data->{value} = $self->{status};

      %post_data = (
        content => $json,
        headers => {
          'station-mgr' => 1,
          'Content-Type' => 'application/json',
        }
      );

      $post = $self->config->http->post(
        $self->config->controller."/api/stations/".$self->config->macaddress."/partial", 
        \%post_data,
      );
    }
  }
}

1;
