use Test::More;
eval "use Test::Pod::Coverage 1.00";
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage" if $@;

my @modules = all_modules( qw( ../lib ../bin ../sbin lib ) );

plan tests => scalar(@modules);

map { pod_coverage_ok( $_ ) } @modules;

