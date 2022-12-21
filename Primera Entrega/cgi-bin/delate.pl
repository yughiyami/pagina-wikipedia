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
    <title>Página Eliminada</title>
  </head>
  <body>
HTML

#CGI part
my $cgi = CGI->new;
my $name = $cgi->param('name');

#Database part
my $user= 'alumno';
my $password = 'pweb1';
my $dsn = "DBI:MariaDB:database=pweb1;host=192.168.1.8";
my $dbh = DBI->connect($dsn, $user, $password) or die ("No se puede conectar");
#Eliminar datos
my $sth = $dbh->prepare("DELETE from Wiki WHERE name=?");
$sth->execute($name);

$dbh->disconnect;

print <<HTML;
    <div class="form-box">
        <h1 class="title-delete">Página eliminada con éxito</h1>
        <form action="list.pl">
           <input class="boton" type="submit" value="VOLVER\n A LA LISTA" />
        </form>
    </div>
  </body>
</html>
HTML