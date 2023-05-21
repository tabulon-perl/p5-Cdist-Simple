package Cdist::Simple::Util;

our $VERSION = '0.001000';

use v5.14;  # Exporter::Almighty requires perl v5.12+.
use strict;
use warnings;

use List::Util        qw( pairs uniq );
use Text::ParseWords  qw( shellwords );
use Text::Trim        qw( trim );

our %EXPORT_TAGS;
BEGIN {
  %EXPORT_TAGS = (
    io       => [ qw( cat slurp ) ],
    list     => [ qw( flat ) ],
    misc     => [ qw( tag_group )  ],
    text     => [ qw( trim ) ],
    words    => [ qw( shellwords )],
  );
}
#use Exporter::Shiny ( map { ref $_ ? @$_ : $_} values %EXPORT_TAGS );
use Exporter::Handy -exporter_setup => 1;
export (
  tags ( { sigil => ':'},
    io    => [ qw( cat slurp ) ],
    list  => [ qw( flat ) ],
    text  => [ qw( trim ) ],
    words => [ qw( shellwords )],
  ),
);

#== General purpose UTILITIES

# File
sub cat   { goto &slurp }
sub slurp {
    my ($path) = @_;
    ## no critic
    return unless open( my $fh, $path );
    local ($/);
    <$fh>
}

# List
sub _is_plain_arrayref { ref( $_[0] ) eq 'ARRAY' }
sub flat(@) { # shamelessly copied from: [List::Flat](https://metacpan.org/pod/List::Flat)
  my @results;

  while (@_) {
    if ( _is_plain_arrayref( my $element = shift @_ ) ) {
        unshift @_, @{$element};
    }
    else {
        push @results, $element;
    }
  }
  return wantarray ? @results : \@results;  ## no critic
}


# Exporting
sub tag_group {
  # useful for building grouped tags for Exporter::Almighty, or just plain %EXPORT_TAGS
  my $name  = ( @_ && !ref( $_[0] ) ) ? shift : undef;
  my %items = %{; shift };
  my %opt   = %{; delete $items{''} // {} };

  $name = delete $opt{name} unless defined $name;
  return unless $name // '';

  my $sep   = $opt{sep} // '_';
  my @pfx   = @{; $opt{pfx} // [ "${name}${sep}" ] };

  my @tags;
  for my $pfx (@pfx) {
    for my $key (sort keys %items) {
      my $value  = $items{$key};
      push @tags, ( "${pfx}${key}" => $value );
    }
  }
  # umbrella entry (that encompasses all subtags)
  push @tags, ( $name => [ map {; $_//'' ? (":$_") : () } ( sort keys %{ +{ @tags } }) ] );

  @tags
}

sub make_tags(@) {
  resolve_tag_groups(@_);
}
sub resolve_tag_groups(@) {
  my @res;
  while (@_) {
    my ($k, $v) = (shift, shift);
    ref( $v ) eq 'HASH' and do { unshift @_, tag_group( $k, $v ); next };
    push @res, ( $k, $v );
  }
  @res
}

sub expand_tags(@) {
  local $_;
  my $tags =  @_ && ref($_[0]) eq q(HASH) ? shift : {};
  my %tags = resolve_tag_groups(%$tags);
  my %seen;
  my @res;

  while (@_) {
    $_ = shift;
    next unless defined;
    ref($_) eq 'ARRAY' and do { unshift @_, @$_; next };

    next if exists $seen{$_} && ( $seen{$_} // 0 );
    $seen{$_} = 1;

    m/^([:-](.*))$/ and do {
      unshift @_, delete $tags{$1} // (), delete $tags{$2} // ();
      next;
    };
    push @res, $_;
  }
  @res
}

1;
