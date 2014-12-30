package App::EventStreamr::DVswitch::Mixer;
use Method::Signatures;
use Moo;
use namespace::clean;

# ABSTRACT: A DVswitch Process

# VERSION: Generated by DZP::OurPkg:Version

=head1 SYNOPSIS

This Provides a pre-configured DVswitch process.

=head1 DESCRIPTION

This largely extends L<App::EventStreamr::Process>, provides
default cmds that can be overridden in the configuration.

=cut

extends 'App::EventStreamr::Process';

has 'cmd'         => ( is => 'ro', lazy => 1, builder => 1 );
has 'id'          => ( is => 'ro', default => sub { 'dvswitch' } );
has 'type'        => ( is => 'ro', default => sub { 'mixer' } );

method _build_cmd() {
  my $command = $self->{config}{commands}{dvswitch} ? $self->{config}{commands}{dvswitch} : 'dvswitch -h 0.0.0.0 -p $port';
  
  my %cmd_vars =  (
    port    => $self->{config}{mixer}{port},
  );

  $command =~ s/\$(\w+)/$cmd_vars{$1}/g;
  return $command;
}

1;
