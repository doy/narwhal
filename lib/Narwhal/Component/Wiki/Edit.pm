package Narwhal::Component::Wiki::Edit;
use Moose;

with 'Narwhal::Component::Role::Wiki';

sub get {
    my $self = shift;
    my ($req, $page) = @_;

    my $page_obj = $self->lookup("page:$page");

    $self->render(
        $req,
        'edit.tt',
        {
            text => ($page_obj ? $page_obj->text : ''),
            page => $page,
        }
    );
}

sub post {
    my $self = shift;
    my ($req, $page) = @_;

    my $page_obj = Narwhal::Page->new(text => $req->param('text'));
    $self->txn_do(sub {
        $self->delete("page:$page");
        $self->insert("page:$page" => $page_obj);
    });
    my $res = $req->new_response(303);
    $res->location(
        $req->uri_for({
            action     => 'page',
            page_name  => $page
        })
    );
    return $res;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
