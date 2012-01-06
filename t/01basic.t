use Test::More tests => 6;
BEGIN { use_ok('Object::Tap') };

{
	package Local::MyClass1;
	BEGIN { Object::Tap->import }
	use Object::DOES;
	sub new { bless [@_] }
}

isa_ok 'Object::Tap' => 'Object::Role';
ok(Object::Tap->DOES('Object::Role'));
ok(Local::MyClass1->DOES('Object::Tap'));

is ${ &Object::Tap::EVAL }, 'EVAL';
is ${ &Object::Tap::NO_EVAL }, 'NO_EVAL';
