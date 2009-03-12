package Email::MIME::Kit::Assembler::TextifyHTML;
use Moose;
extends 'Email::MIME::Kit::Assembler::Standard';

use HTML::FormatText::WithLinks;

has html_args => (
  is  => 'ro',
  isa => 'ArrayRef',
  default => sub { [] },
);

has formatter_args => (
  is  => 'ro',
  isa => 'HashRef',
  default => sub {
    return {
      before_link => '',
      after_link  => ' [%l]',
      footnote    => '',
      leftmargin  => 0,
    };
  },
);

has formatter => (
  is   => 'ro',
  isa  => 'HTML::FormatText::WithLinks',
  lazy => 1,
  init_arg => undef,
  default  => sub {
    my ($self) = @_;
    HTML::FormatText::WithLinks->new(
      %{ $self->formatter_args },
    );
  }
);

around assemble => sub {
  my ($orig, $self, $arg) = @_;
  my $local_arg = { %$arg };

  for my $key (@{ $self->html_args }) {
    warn "checking on $key\n";
    next unless defined $local_arg->{ $key };
    $local_arg->{ $key } = $self->formatter->parse($local_arg->{ $key });
  }

  return $self->$orig($local_arg);
};

no Moose;
1;
