#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml;  charset= UTF-8A');

my $title =$q->param('title');
my $text = $q->param('text');
my $owner = $q->param('owner');

print STDERR "$title,$text,$owner\n";

my @salidaConsulta;
if(defined($title) and defined($owner)){
  print STDERR "se lleno los campos necesarioo\n";
  @salidaConsulta =buscarBD($owner, $title);
  if(@salidaConsulta){
    print STDERR "se procedera a insertar nuevo texto";
    insertBD($owner, $title, $text);
    my @textModif = insertBD($owner, $title, $text);
    push(@textModif, $title);
    print STDERR @textModif;
    my $cuerpoXML =renderCuerpo(@textModif);
    print renderXML($cuerpoXML);
  }else{
    print STDERR "no se encontro dichos datos\n";
    print renderXML();
  }
}else{
  print STDERR "No lleno todos los campos\n";
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


sub insertBD{   #Ademas esta subrutina me devolvera lo solicitado en la tarea, para no abr                 #para no abrir nuevamente la BD
  my $owner =$_[0];
  my $title = $_[1];
  my $text = $_[2];
  my $user = 'alumno';
  my $password = 'pweb1';
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.1.5';
  my $dbh = DBI->connect($dsn, $user, $password) or die
  die("No se pudo conectar!");
  my $sql = "UPDATE Articles SET text=? WHERE owner=? AND title=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($text,$owner, $title);
  $sth->finish;
  my $sql2 = "SELECT text FROM Articles WHERE owner=? AND title=?";
  my $sth1 = $dbh->prepare($sql2);
  $sth1->execute($owner, $title);
  my @articles;
  while (my @row=$sth1->fetchrow_array){
    push(@articles, @row);
  }
  return @articles;
  $dbh->disconnect;
}


sub renderCuerpo{
  my $text = $_[0];
  my $title = $_[1];
  my $cuerpo = <<"CUERPO";
                 <title>$title</title>
                 <text>$text</text>
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
