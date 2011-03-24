package Narwhal;
use OX;

use MooseX::Types::Path::Class;

with 'OX::Role::WithAppRoot';

has kioku_dsn => (
    is    => 'ro',
    isa   => 'Str',
    value => 'dbi:SQLite:narwhal.db',
);

has kioku_extra_args => (
    is    => 'ro',
    isa   => 'HashRef',
    block => sub { { create => 1 } },
);

has template_root => (
    is     => 'ro',
    isa    => 'Path::Class::Dir',
    coerce => 1,
    block  => sub { shift->param('app_root')->subdir('root', 'templates') },
    dependencies => ['app_root'],
);

has redirect => (
    is  => 'ro',
    isa => 'Narwhal::Component::Redirect',
);

has wiki => (
    is  => 'ro',
    isa => 'Narwhal::Component::Wiki',
    dependencies => ['kioku', 'tt'],
);

has wiki_edit => (
    is  => 'ro',
    isa => 'Narwhal::Component::Wiki::Edit',
    dependencies => ['kioku', 'tt'],
);

has tt => (
    is  => 'ro',
    isa => 'OX::View::TT',
    dependencies => ['template_root'],
);

has kioku => (
    is => 'ro',
    isa => 'Narwhal::Component::Model',
    dependencies => {
        dsn        => 'kioku_dsn',
        extra_args => 'kioku_extra_args',
    },
);

router ['Narwhal::RouteBuilder::HTTPMethod'], as {
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
    redirect => depends_on('redirect'),
    wiki     => depends_on('wiki'),
    edit     => depends_on('wiki_edit'),
);

no OX;
1;
