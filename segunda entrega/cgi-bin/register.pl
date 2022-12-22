#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml');

my $userName = $q->param('userName');
my $password = $q->param('password');
my $firstName = $q->param('firstName');
my $lastName = $q->param('lastName');

if(defined($userName) && defined($password) && defined($firstName) && defined($lastName)){
  insertaBD($userName, $password, $firstName, $lastName);
  my $cuerpoXML= renderBody($userName, $firstName, $lastName);
  print renderXML($cuerpoXML);
}else{
  print renderXML();
}
sub insertaBD{
  my $user = 'alumno';
  my $password = 'pweb1';
  my $userName = $_[0];
  my $pwd = $_[1];
  my $fn = $_[2];
  my $ln = $_[3];
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';
  my $dbh = DBI->connect($dsn, $user, $password) or die("No se pudo conectar!");
  my $sql = "INSERT INTO Users(userName,password,firstName,lastName)VALUES(?,?,?,?)";
  my $sth = $dbh->prepare($sql);
  $sth->execute($userName,$pwd,$fn,$ln);
  $sth->finish;
  $dbh->disconnect;
}

sub renderBody{
  my $userName = $_[0];
  my $fn = $_[1];
  my $ln = $_[2];
  my $cuerpo = <<"BODY";
    <owner>$userName</owner>
    <firstName>$fn</firstName>
    <lastName>$ln</lastName>
BODY
  return $cuerpo;
}

sub renderXML{
  my $cuerpo = "";
  if(defined($_[0])){
    $cuerpo .= $_[0];
  }
    my $xml = <<"XML";
<?xml version='1.0' encoding= 'utf-8'?>
    <user>
      $cuerpo
    </user>
XML
return $xml
}