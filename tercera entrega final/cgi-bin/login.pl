#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml;charset=UTF-8');

my $user = $q->param('user');
my $password = $q->param('password');

print STDERR "$user\n";
print STDERR "$password\n";
my @respuesta;
if(defined($user) and defined($password)){
  @respuesta =checkLogin($user, $password);
  print STDERR "len ".scalar(@respuesta)."\n";
  print STDERR "salida :@respuesta\n";
  print STDERR "Se ingre todos los capos\n";
  if(checkLogin($user, $password)){
    print STDERR "@respuesta\n";
    my $cuerpoXML =renderCuerpo(@respuesta);
    print renderXML($cuerpoXML);
  }else{
    print STDERR "no hay coincidecnias\n";
    print renderXML('Hola segundo');

  }


}else{
  print STDERR "No ingreso los dos datos\n";
  print renderXML('Hola');
}


sub checkLogin{
  my $userQuery = $_[0];
  my $passwordQuery = $_[1];

  my $user = 'alumno';
  my $password = 'pweb1';
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';
  my $dbh = DBI->connect($dsn, $user, $password) or die
  die("No se pudo conectar!");

  my $sql = "SELECT * FROM Users WHERE userName=? AND password=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($userQuery, $passwordQuery);
  my @row = $sth->fetchrow_array;
  $sth->finish;
  $dbh->disconnect;
  return @row;
  print "salida de funcion@row\n";
}

sub renderCuerpo{
  my @linea = @_;
  my $cuerpo = <<"CUERPO";
      <owner>$linea[0]</owner>
      <firstName>$linea[3]</firstName>
      <lastName>$linea[2]</lastName>
CUERPO
  return $cuerpo;
}

sub renderXML{
  my $cuerpoxml = $_[0];
  my $xml = <<"XML";
<?xml version='1.0' encoding= 'utf-8'?>
  <user>
   $cuerpoxml
  </user>
XML
  return $xml
}
