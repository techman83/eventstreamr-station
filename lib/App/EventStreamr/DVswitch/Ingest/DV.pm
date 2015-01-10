package App::EventStreamr::DVswitch::Ingest::DV;
use Method::Signatures;
use Moo;
use namespace::clean;

# ABSTRACT: A DVswitch DV Process

# VERSION: Generated by DZP::OurPkg:Version

=head1 SYNOPSIS

This Provides a DV ingest process.

=head1 DESCRIPTION

This largely extends L<App::EventStreamr::Process>, provides
default cmds that can be overridden in the configuration.

=cut

extends 'App::EventStreamr::Process';

has 'cmd'         => ( is => 'ro', lazy => 1, builder => 1 );
has 'cmd_regex'   => ( is => 'ro', lazy => 1, builder => 1 );
has 'id'          => ( is => 'ro', required => 1 );
has 'device'      => ( is => 'ro', required => 1 );
has 'type'        => ( is => 'ro', default => sub { 'ingest' } );

method _build_cmd() {
  my $command = $self->{config}{commands}{dv} ? $self->{config}{commands}{dv} : 'dvsource-firewire -h $host -p $port -c $id';
  
  my %cmd_vars =  (
    device  => $self->device,
    host    => $self->{config}{mixer}{host},
    port    => $self->{config}{mixer}{port},
    id      => $self->{id},
  );

  $command =~ s/\$(\w+)/$cmd_vars{$1}/g;
  return $command;
}

method _build_cmd_regex() {
  return qr:dvgrab.+$self->{id}.*:;
}

with('App::EventStreamr::DVswitch::Roles::MixerWait');

1;
