package App::EventStreamr::Roles::Logger;

use Log::Log4perl;
use Method::Signatures;
use Moo::Role;

# ABSTRACT: Logging for EventStreamr

# VERSION: Generated by DZP::OurPkg:Version

=head1 SYNOPSIS

Provides a central logging service for EventStreamr

=head1 DESCRIPTION

  with('App::EventStreamr::Roles::Logger');

Can be consumed by any EventStreamr package. Config must exist for 
it to end up in the central log.

Inspiratation/Credit here -> http://stackoverflow.com/questions/3018528/making-self-logging-modules-with-loglog4perl

=cut

my @methods = qw(
  log trace debug info warn error fatal
  is_trace is_debug is_info is_warn is_error is_fatal
  logexit logwarn error_warn logdie error_die
  logcarp logcluck logcroak logconfess
);

has _logger => (
  is => 'ro',
  isa => sub { 'Log::Log4perl::Logger' },
  lazy => 1,
  builder => 1,
  handles => \@methods,
);

has _log_path   => ( is => 'ro', lazy => 1, builder => 1 );
has _log_level  => ( is => 'ro', lazy => 1, builder => 1 );
has log_config  => ( is => 'ro', lazy => 1, builder => 1 );

method _build_log_config() {
  my $log_level = $self->_log_level || "INFO, LOG1";
  my $log_path = $self->_log_path || "/tmp";
  return qq(
    log4perl.rootLogger              = $log_level
    log4perl.appender.SCREEN         = Log::Log4perl::Appender::Screen
    log4perl.appender.SCREEN.stderr  = 0
    log4perl.appender.SCREEN.layout  = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.SCREEN.layout.ConversionPattern = %m %n
    log4perl.appender.LOG1           = Log::Log4perl::Appender::File
    log4perl.appender.LOG1.utf8      = 1
    log4perl.appender.LOG1.filename  = $log_path/eventstreamr.log
    log4perl.appender.LOG1.mode      = append
    log4perl.appender.LOG1.layout    = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.LOG1.layout.ConversionPattern = %d %p %m %n
  );
}

method _build__log_level() {
  if ( defined $self->{config}){
    return $self->{config}{log_level};
  } elsif (defined $self->{log_level}) {
    return $self->{log_level};
  }
}

method _build__log_path() {
  if (defined $self->{config}) {
    return $self->{config}{config_path};
  } elsif (defined $self->{config_path}) {
    return $self->{config_path};
  }
}

around $_ => sub {
  my $orig = shift;
  my $this = shift;

  # one level for this method itself
  # two levels for Class:;MOP::Method::Wrapped (the "around" wrapper)
  # one level for Moose::Meta::Method::Delegation (the "handles" wrapper)
  local $Log::Log4perl::caller_depth;
  $Log::Log4perl::caller_depth += 4;

  my $return = $this->$orig(@_);

  $Log::Log4perl::caller_depth -= 4;
  return $return;

} foreach @methods;

method _build__logger() {
  my $this = shift;

  my $loggerName = ref($this);
  $self->log_config;
  Log::Log4perl->init_once(\$self->log_config);
  return Log::Log4perl->get_logger($loggerName)
}

1;
