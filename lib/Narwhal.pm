package Narwhal;
use OX;
use Narwhal::RouteBuilder::HTTPMethod;

with 'OX::Role::WithAppRoot';

has dsn => (
    is      => 'ro',
    isa     => 'Str',
    default => 'dbi:SQLite:narwhal.db',
);

config kioku_dsn => sub {
    my ($s, $app) = @_;
    $app->dsn;
};
config kioku_extra_args => sub { { create => 1 } };
config template_root => sub {
    shift->param('app_root')->subdir('root', 'templates')
}, (app_root => depends_on('/app_root'));

component Redirect => 'Narwhal::Component::Redirect';

component Wiki => 'Narwhal::Component::Wiki', (
    kioku => depends_on('/Component/Kioku'),
    tt    => depends_on('/Component/TT'),
);

component WikiEdit => 'Narwhal::Component::Wiki::Edit', (
    kioku => depends_on('/Component/Kioku'),
    tt    => depends_on('/Component/TT'),
);

# turn these two into specialized classes later
component TT => 'OX::View::TT', (
    template_root => depends_on('/Config/template_root'),
);

component Kioku => 'Narwhal::Component::Model', (
    dsn        => depends_on('/Config/kioku_dsn'),
    extra_args => depends_on('/Config/kioku_extra_args'),
);

router as {
    route '/' => 'redirect.permanent', (
        to => '/page/main',
    );
    route '/page/:page_name' => 'wiki.view', (
        page_name => { isa => 'Str' },
    );
    route '/edit/:page_name' => 'http-method:edit', (
        page_name => { isa => 'Str' },
    );
    route '/page/:page_name/:rev' => 'wiki.view_old', (
        page_name => { isa => 'Str' },
        rev       => { isa => qr/^[0-9a-f]{40}$/ },
    );
    route '/history/:page_name' => 'wiki.history', (
        page_name => { isa => 'Str' },
    );
}, (
    redirect => depends_on('/Component/Redirect'),
    wiki     => depends_on('/Component/Wiki'),
    edit     => depends_on('/Component/WikiEdit'),
);

no OX;
1;
