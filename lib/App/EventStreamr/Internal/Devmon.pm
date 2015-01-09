package App::EventStreamr::Internal::Devmon;
use Method::Signatures;
use Moo;
use namespace::clean;

# ABSTRACT: An EventStreamr API Process

# VERSION: Generated by DZP::OurPkg:Version

=head1 SYNOPSIS

This manages the internal EventStreamr API

=head1 DESCRIPTION

This largely extends L<App::EventStreamr::Process>, provides
default cmds that can be overridden in the configuration.

=cut

extends 'App::EventStreamr::Process';

has 'cmd'         => ( is => 'ro', default => sub { "eventstreamr-devmon.pl" } );
has 'name'        => ( is => 'ro', default => sub { 'devmon' } );
has 'id'          => ( is => 'ro', default => sub { 'devmon' } );
has 'type'        => ( is => 'ro', default => sub { 'internal' } );

# We're special, we should always be running
method _run() {
  $self->{config}{control}{$self->{id}}{run} = 1;
  return 1;
}

# And we shouldn't be restarted
method _restart() {
  return 0;
}

1;
