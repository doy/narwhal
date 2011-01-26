package Narwhal::Component::Wiki;
use Moose;

use Narwhal::Page;

has kioku => (
    isa      => 'KiokuX::Model',
    required => 1,
    handles  => 'KiokuDB::Role::API',
);

has tt => (
    isa      => 'Template',
    required => 1,
    handles  => ['process'],
);

has scope => (
    is      => 'ro',
    isa     => 'KiokuDB::LiveObjects::Scope',
    lazy    => 1,
    default => sub { shift->new_scope },
);

sub BUILD {
    my $self = shift;
    $self->scope;
}

sub page {
    my $self = shift;
    my ($req, $page) = @_;
    my $page_obj = $self->lookup("page:$page");
    return $req->new_response(404)
        unless $page_obj;
    my $out;
    $self->process('page.tt', { uri_for => sub { '/' . $req->uri_for({@_}) }, text => $page_obj->text, page => $page }, \$out);
    return $req->new_response(200, [], $out);
}

sub edit {
    my $self = shift;
    my ($req, $page) = @_;
    if ($req->method eq 'POST') {
        my $page_obj = Narwhal::Page->new(text => $req->param('text'));
        $self->txn_do(sub {
            $self->delete("page:$page");
            $self->insert("page:$page" => $page_obj);
        });
        my $res = $req->new_response(303);
        $res->location('/' . $req->uri_for({controller => 'wiki', action => 'page', page_name => $page}));
        return $res;
    }
    else {
        my $page_obj = $self->lookup("page:$page");
        my $out;
        $self->process('edit.tt', { uri_for => sub { '/' . $req->uri_for({@_}) }, text => ($page_obj ? $page_obj->text : ''), page => $page }, \$out);
        return $req->new_response(200, [], $out);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
