# This Build.PL for Object-Tap was generated by
# Dist::Zilla::Plugin::ModuleBuildTiny::Fallback 0.004
if (eval 'use Module::Build::Tiny 0.036; 1')
{
    print "Congratulations, your toolchain understands 'configure_requires'!\n\n";

    # This section was for Object-Tap was generated by Dist::Zilla::Plugin::ModuleBuildTiny 0.006.
    use 5.006;
    # use Module::Build::Tiny 0.036;
    Build_PL();
}
else
{
    $ENV{PERL_MB_FALLBACK_SILENCE_WARNING} or warn <<'EOW';
*** WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING ***

If you're seeing this warning, your toolchain is really, really old* and you'll
almost certainly have problems installing CPAN modules from this century. But
never fear, dear user, for we have the technology to fix this!

If you're using CPAN.pm to install things, then you can upgrade it using:

    cpan CPAN

If you're using CPANPLUS to install things, then you can upgrade it using:

    cpanp CPANPLUS

If you're using cpanminus, you shouldn't be seeing this message in the first
place, so please file an issue on github.

This public service announcement was brought to you by the Perl Toolchain
Gang, the irc.perl.org #toolchain IRC channel, and the number 42.

----

* Alternatively, you are running this file manually, in which case you need
to learn to first fulfill all configure requires prerequisites listed in
META.yml or META.json -- or use a cpan client to install this distribution.

You can also silence this warning for future installations by setting the
PERL_MB_FALLBACK_SILENCE_WARNING environment variable, but please don't do
that until you fix your toolchain as described above.

EOW
    sleep 10 if -t STDIN && (-t STDOUT || !(-f STDOUT || -c STDOUT));


    # This section was was automatically generated by Dist::Zilla::Plugin::ModuleBuild v5.019.
    use strict;
    use warnings;

    require Module::Build; Module::Build->VERSION(0.28);


    my %module_build_args = (
      "build_requires" => {},
      "configure_requires" => {
        "ExtUtils::MakeMaker" => "6.30",
        "Module::Build::Tiny" => "0.036"
      },
      "dist_abstract" => "Tap into a series of method calls to alter an object",
      "dist_author" => [
        "Matt S Trout (mst) <mst\@shadowcat.co.uk>"
      ],
      "dist_name" => "Object-Tap",
      "dist_version" => "1.000004",
      "license" => "perl",
      "module_name" => "Object::Tap",
      "recommends" => {},
      "recursive_test_files" => 1,
      "requires" => {},
      "script_files" => [],
      "test_requires" => {}
    );


    my %fallback_build_requires = ();


    unless ( eval { Module::Build->VERSION(0.4004) } ) {
      delete $module_build_args{test_requires};
      $module_build_args{build_requires} = \%fallback_build_requires;
    }

    my $build = Module::Build->new(%module_build_args);

    $build->create_build_script;
}
