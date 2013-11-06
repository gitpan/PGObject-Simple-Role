#!perl 

use strict;
use warnings;
use Test::More;

# Ensure a recent version of Test::Pod
my $min_tp = 1.22;
eval "use Test::Pod $min_tp";
if ($@){ 
    plan skip_all => "Test::Pod $min_tp required for testing POD";
} elsif (!$ENV{RELEASE_TESTING}){
     plan skip_all => "Author tests not required for installation";
} 


all_pod_files_ok();
