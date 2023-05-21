#/usr/bin/env perl

use IO::Handle;
use CM::Cdist::Helper qw(cmd_ensure);


cmd_ensure( @ARGV );
