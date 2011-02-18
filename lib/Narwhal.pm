package Narwhal;
use OX;
use Narwhal::RouteBuilder::HTTPMethod;

with 'OX::Role::WithAppRoot';

config kioku_dsn => 'dbi:SQLite:narwhal.db';
config kioku_extra_args => sub { { create => 1 } };
config template_root => sub {
    shift->param('app_root')->subdir('root', 'templates')
}, (app_root => depends_on('/app_root'));

component Redirect => 'Narwhal::Component::Redirect';

component WikiPage => 'Narwhal::Component::Wiki::Page', (
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

component Kioku => 'KiokuX::Model', (
    dsn        => depends_on('/Config/kioku_dsn'),
    extra_args => depends_on('/Config/kioku_extra_args'),
);

router as {
    route '/' => 'redirect.permanent', (
        to => '/page/main',
    );
    route '/page/:page_name' => 'page', (
        page_name => { isa => 'Str' },
    );
    route '/edit/:page_name' => 'edit', (
        page_name => { isa => 'Str' },
    );
}, (
    redirect => depends_on('/Component/Redirect'),
    page     => depends_on('/Component/WikiPage'),
    edit     => depends_on('/Component/WikiEdit'),
);

no OX;
1;
