package App::EventStreamr::DVswitch::Youtube;
use Method::Signatures;
use Moo;
use namespace::clean;

# ABSTRACT: A YouTube Stream Process

# VERSION: Generated by DZP::OurPkg:Version

=head1 SYNOPSIS

This Provides a pre-configured YouTube process.

=head1 DESCRIPTION

This largely extends L<App::EventStreamr::Process>, provides
default cmds that can be overridden in the configuration.

=cut

extends 'App::EventStreamr::Process';

has 'cmd'         => ( is => 'ro', lazy => 1, builder => 1 );
has 'cmd_regex'   => ( is => 'ro', lazy => 1, builder => 1 );
has 'id'          => ( is => 'ro', default => sub { 'youtube' } );
has 'type'        => ( is => 'ro', default => sub { 'stream' } );
has 'avlib'       => ( is => 'ro', lazy => 1, builder => 1 );

method _build_avlib() {
  # TODO: This makes assumptions
  if ( -e '/usr/bin/avconv' ) {
    return 'avconv';
  } else {
    return 'ffmpeg';
  }
}

method _build_cmd() {
  my $command = 'dvsink-command -h $host -p $port -- '.$self->avlib.' -i - -deinterlace -vcodec libx264 -pix_fmt yuv420p -vf scale=-1:480 -preset $preset -r $fps -g $gop -b:v $bitrate -acodec libmp3lame -ar 44100 -threads 6 -qscale 3 -b:a 256000 -bufsize 512k -f flv "$url/$key"';

  my $gop = ($self->{config}{youtube}{fps} * 2);

  my %cmd_vars = (
                  host      => $self->{config}{mixer}{host},
                  port      => $self->{config}{mixer}{port},
                  preset    => $self->{config}{youtube}{preset},
                  fps       => $self->{config}{youtube}{fps},
                  gop       => $gop,
                  bitrate   => $self->{config}{youtube}{bitrate},
                  url       => $self->{config}{youtube}{url},
                  key       => $self->{config}{youtube}{key},
  );

  $command =~ s/\$(\w+)/$cmd_vars{$1}/g;
  return $command;
}

method _build_cmd_regex() {
    return qr|$self->{config}{youtube}{url}/$self->{config}{youtube}{key}|;
}

with('App::EventStreamr::DVswitch::Roles::MixerWait');

1;