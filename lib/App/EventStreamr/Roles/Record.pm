package App::EventStreamr::Roles::Record;

use v5.010;
use strict;
use warnings;
use Method::Signatures 20140224; # libmethod-signatures-perl
use Proc::Daemon; # libproc-daemon-perl
use Proc::ProcessTable; # libproc-processtable-perl

use Moo::Role; # libmoo-perl

# ABSTRACT: A recording role

# VERSION: Generated by DZP::OurPkg:Version

=head1 SYNOPSIS

This is a role wraps around the 'run_stop' of a process.

=head1 DESCRIPTION

This is a Role that can be consumed to ensure the path exists 
before allowing the record process to take place.

It requires a 'run_stop' method, so really should only be consumed
by processes that extend L<App::EventStreamr::Process>.

=cut

requires 'run_stop','status','config';

has 'record_path'         => ( is => 'ro', lazy => 1, builder => 1 );

method _build_record_path() {
  my $command = $self->{config}{commands}{dvswitch} ? $self->{config}{commands}{dvswitch} : 'dvswitch -h 0.0.0.0 -p $port';
  
  my %cmd_vars =  (
    port    => $self->{config}{mixer}{port},
  );

  $command =~ s/\$(\w+)/$cmd_vars{$1}/g;
  return $command;
}

around 'run_stop' => sub {
  my $orig = shift;
  my $self = shift;
  $orig->();
};

1;
