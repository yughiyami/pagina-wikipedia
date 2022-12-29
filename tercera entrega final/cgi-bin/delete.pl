#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q =CGI->new;
print $q->header('text/xml; charset=UTF-8');
my $owner = $q->param('owner');
my $title = $q->param('title');

print STDERR "$owner.$title";

if(defined($owner) and defined($title)){
  print STDERR "campos llenos\n";
  my @articles =buscarBD($owner, $title);
  if(@articles){       #si ha encontrado , entonces procedera a eliminar
    print STDERR "se borraa@articles";
    my $renderCuerpo= renderCuerpo($owner, $title);
    print renderXML($renderCuerpo);
    eliminarBD($owner, $title);

  }else{
    print STDERR "no existe esos datos\n";
    print renderXML();
  }
}else{
  print STDERR "no lleno nada\n";
  print renderXML();
}

sub buscarBD{
  my $owner =$_[0];
  my $title = $_[1];
  my $user = 'alumno';
  my $password = 'pweb1';
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';
  my $dbh = DBI->connect($dsn, $user, $password) or die
  die("No se pudo conectar!");
  my $sql = "SELECT title FROM Articles WHERE owner=? AND title=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($owner,$title);
  my @articles;
  while(my @row=$sth->fetchrow_array){
    push(@articles, @row);

  }

  $sth->finish;
  $dbh->disconnect;
  return @articles;
}

sub eliminarBD{
  my $owner =$_[0];
  my $title = $_[1];
  my $user = 'alumno';
  my $password = 'pweb1';
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.1.5';
  my $dbh = DBI->connect($dsn, $user, $password) or die
  die("No se pudo conectar!");
  my $sql = "DELETE FROM Articles WHERE owner=? AND title=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($owner,$title);
  $sth->finish;
  $dbh->disconnect;
}

sub renderCuerpo{
  my $owner = $_[0];
  my $title = $_[1];
  my $cuerpo = <<"CUERPO";
            <owner>$owner</owner>
                <title>$title</title>
CUERPO
  return $cuerpo;
}

sub renderXML{
  my $cuerpoxml = $_[0];
  my $xml = <<"XML";
<?xml version='1.0' encoding= 'utf-8'?>
      <article>
        $cuerpoxml
      </article>
XML
  return $xml
}
