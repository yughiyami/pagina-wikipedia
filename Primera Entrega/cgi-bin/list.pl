#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

print "Content-type: text/html\n\n";
print <<HTML;
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <link rel="stylesheet" href="../css/styles.css" />
    <title>Listado de páginas</title>
  </head>
  <body>
    <div class="form-box">
         <h1>Nuestras páginas de wiki</h1>
HTML

#Base de datos
my $user = 'alumno';
my $password = 'pweb1';
my $dsn = "DBI:MariaDB:database=pweb1;host=192.168.1.8";
my $dbh = DBI->connect($dsn, $user, $password) or die("No se pudo conectar!");;

my $sth = $dbh->prepare("SELECT name FROM Wiki");
$sth->execute();
print "<ul>\n";
while(my @row = $sth->fetchrow_array){
    print "<li class='paginas'>\n";
      print "<a href='view.pl?name=@row'>@row</a>\n";
      print "<a href='delete.pl?name=@row'><button>X</button></a>\n";
      print "<a href='edit.pl?name=@row'><button>E</button></a>\n";
    print "</li>\n";
}
print "</ul>\n";
$sth->finish;
$dbh->disconnect;

print <<HTML;
      <a href="./../new.html">Nueva Página</a><br>
      <a href="./../index.html">Volver al Inicio</a>
    </div>
  </body>
</html>
HTML