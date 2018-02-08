
#idea from https://hub.docker.com/_/perl/

# cpanfile format documentation
#        http://search.cpan.org/~miyagawa/Module-CPANfile-1.1002/lib/cpanfile.pod
#
# for use with Carton
#        http://search.cpan.org/~miyagawa/Carton-v1.0.28/lib/Carton.pm



requires 'Plack', '1.0'; # 1.0 or newer
requires 'JSON', '>= 2.00, < 2.80';

recommends 'JSON::XS', '2.0';
conflicts 'JSON', '< 1.0';

on 'test' => sub {
    requires 'Test::More', '>= 0.96, < 2.0';
    recommends 'Test::TCP', '1.12';
};

on 'develop' => sub {
    recommends 'Devel::NYTProf';
};

feature 'sqlite', 'SQLite support' => sub {
    recommends 'DBD::SQLite';
};
