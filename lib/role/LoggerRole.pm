package Role::LoggerRole;

use Moose::Role;

requires 'info';
requires 'error';

1;
