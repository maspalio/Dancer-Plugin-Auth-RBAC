use strict;
use warnings;
use Test::More tests => 16, import => ['!pass'];
use Test::Exception;

BEGIN {
        use_ok 'Dancer', ':syntax';
        use_ok 'Dancer::Plugin::Authorize';
}

my @settings    = <DATA>;
set session     => "YAML";
set session_dir => "./t/sessions";
set plugins     => from_yaml("@settings");

diag 'access control tested (user01 has user and guest roles)';
my $auth = auth('user01', 'foobar');
ok 'Dancer::Plugin::Authorize' eq ref $auth, 'instance initiated';
ok !$auth->errors, 'login successful, no errors';
ok $auth->can("manage accounts"), 'user01 can manage accounts';
ok $auth->can("manage accounts", "view"), 'user01 can manage accounts and view';
ok $auth->can("manage accounts", "create"), 'user01 can manage accounts and create';
ok !$auth->can("manage accounts", "update"), 'user01 cannot manage accounts and update';
ok !$auth->can("manage accounts", "delete"), 'user01 cannot manage accounts and delete';
$auth->revoke;

diag 'access control tested (user02 has admin role)';
$auth = auth('user02', 'barbaz');
ok 'Dancer::Plugin::Authorize' eq ref $auth, 'instance initiated';
ok !$auth->errors, 'login successful, no errors';
ok $auth->can("manage accounts"), 'user01 can manage accounts';
ok $auth->can("manage accounts", "view"), 'user01 can manage accounts and view';
ok $auth->can("manage accounts", "create"), 'user01 can manage accounts and create';
ok $auth->can("manage accounts", "update"), 'user01 can manage accounts and update';
ok $auth->can("manage accounts", "delete"), 'user01 can manage accounts and delete';
$auth->revoke;

__END__
Authorize:
  credentials:
    class: Config
    options:
      accounts:
        user01:
          password: foobar
          roles:
            - guest
            - user
        user02:
          password: barbaz
          roles:
            - admin
  permissions:
    class: Config
    options:
      control:
        admin:
          permissions:
            manage accounts:
              operations:
                - view
                - create
                - update
                - delete
        user:
          permissions:
            manage accounts:
              operations:
                - view
                - create
        guests:
          permissions:
            manage accounts:
              operations:
                - view
