#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;


my $q = CGI->new;
print $q->header('text/xml');

my $user = $q->param('user');
my $password = $q->param('password');

if(defined($user) and defined($password)){
    my @datos = checkLogin($user, $password);
    if(@datos){
      print renderBody(@datos);
    }else{
      print notFound();
    }
}else{
    print notFound()
}

sub checkLogin{
  my $userQuery = $_[0];
  my $passwordQuery = $_[1];
                  
  my $user = 'alumno';
  my $password = 'pweb1';
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';
  my $dbh = DBI->connect($dsn, $user, $password) or die("No se pudo conectar!");
              
  my $sql = "SELECT * FROM Users WHERE userName=? AND password=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($userQuery, $passwordQuery);
  my @row = $sth->fetchrow_array;
  $sth->finish;
  $dbh->disconnect;
  return @row;
}
sub notFound{
  my $body = << "XML";
<?xml version='1.0' encoding='utf-8'?> 
  <user>
  </user>
XML
  return $body;
}
sub renderBody{
  my $owner = $_[0];
  my $firstName = $_[3];
  my $lastName = $_[2];
  my $body = << "XML";
<?xml version='1.0' encoding='utf-8'?>
    <user>
      <owner>$owner</owner>
      <firstName>$firstName</firstName>
      <lastName>$lastName</lastName>
    </user>
XML
  return $body;
}