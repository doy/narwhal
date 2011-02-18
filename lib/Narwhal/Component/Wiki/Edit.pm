package Narwhal::Component::Wiki::Edit;
use Moose;

use Narwhal::Page;
use Narwhal::User;

with 'Narwhal::Component::Role::Wiki';

sub get {
    my $self = shift;
    my ($req, $page_name) = @_;

    my $page = $self->lookup("page:$page_name");

    my %template_env = (
        page => $page_name,
        text => '',
    );

    if ($page) {
        %template_env = (
            %template_env,
            text     => $page->text,
            author   => $page->author,
            modified => $page->modification_date,
        );
    }

    $self->render($req, 'edit.tt', \%template_env);
}

sub post {
    my $self = shift;
    my ($req, $page_name) = @_;

    $self->txn_do(sub {
        my $page = $self->lookup("page:$page_name");
        my $user_id = 'foo'; # XXX
        my $user = $self->lookup("user:$user_id")
                || Narwhal::User->new(id => $user_id);
        if ($page) {
            $page->new_revision(
                text   => $req->param('text'),
                author => $user,
            );
        }
        else {
            $page = Narwhal::Page->new_page(
                id     => $page_name,
                text   => $req->param('text'),
                author => $user,
            );
        }
        $self->store($page);
    });
    my $res = $req->new_response(303);
    $res->location(
        $req->uri_for({
            action     => 'page',
            page_name  => $page_name,
        })
    );
    return $res;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
