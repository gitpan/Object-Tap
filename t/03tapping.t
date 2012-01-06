use Test::More tests => 9;

{
	package Local::MyClass1;
	use Object::Tap;
	sub new { bless [@_] }
	sub is_999 { Test::More::is $_[1], 999, $_[2]; return 'Foo' }
	sub ok_method { Test::More::ok 1, 'ok method' }
	sub inc { $_[0]->[0]++ }
}

is
	'Local::MyClass1'->tap( sub { return 'Foo' } ),
	'Local::MyClass1',
	'tap as class method returns invocant';

my $o = Local::MyClass1->new(0);

is
	$o->tap( sub { return 'Foo' } ),
	$o,
	'tap as object method returns invocant';

{
	my $r = $o->tap('ok_method');
	is $r, $o;
}

{
	my $r = $o->tap(is_999 => [999, 'named method call plus parameters']);
	is $r, $o;
}

is $o->tap(qw/inc inc inc inc/)->[0], 4, 'multiple taps in a single call.';

ok $o->tap(\"EVAL", sub { die "died" }), "\\EVAL";

local $@ = undef;
eval {
	$o->tap(\"EVAL", sub { die "died" }, \"NO_EVAL", sub { die "fooey" });
};
like $@, qr'fooey', "\\NO_EVAL";