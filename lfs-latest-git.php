#! /usr/bin/php
<?php
$dirs = array();
$vers = array();

date_default_timezone_set( "GMT" );
$date = date( "Y-m-d H:i:s" );

// Special cases
$exceptions = array();
//$exceptions[ 'gmp' ] = "UPDIR=/.*(gmp-\d[\d\.-]*\d).*/:DOWNDIR=";

$regex = array();
//$regex[ 'bzip2'    ] = "/^.*current version is ([\d\.]+).*$/";
$regex[ 'check'    ] = "/^.*Check (\d[\d\.]+\d).*$/";
$regex[ 'intltool' ] = "/^.*Latest version is (\d[\d\.]+\d).*$/";
$regex[ 'less'     ] = "/^.*current released version is less-(\d+).*$/";
$regex[ 'mpfr'     ] = "/^mpfr-([\d\.]+)\.tar.*$/";
$regex[ 'Python'   ] = "/^.*Latest Python 3.*Python (3[\d\.]+\d).*$/";
$regex[ 'systemd'  ] = "/^.*systemd v([\d]+)$/";
//$regex[ 'sysvinit' ] = "/^.*sysvinit-([\d\.]+)dsf\.tar.*$/";
$regex[ 'tzdata'   ] = "/^.*tzdata([\d]+[a-z]).*$/";
$regex[ 'xz'       ] = "/^.*xz-([\d\.]*\d).*$/";
$regex[ 'zlib'     ] = "/^.*zlib ([\d\.]*\d).*$/";

function find_max( $lines, $regex_match, $regex_replace )
{
  $a = array();
  if ( ! is_array( $lines ) ) return -1;

  foreach ( $lines as $line )
  {
     if ( ! preg_match( $regex_match, $line ) ) continue;

     // Isolate the version and put in an array
     $slice = preg_replace( $regex_replace, "$1", $line );
     if ( strcmp( $slice, $line ) == 0 ) continue;

     array_push( $a, $slice );
  }

  // SORT_NATURAL requires php-5.4.0 or later
  rsort( $a, SORT_NATURAL );  // Max version is at the top
  return ( isset( $a[0] ) ) ? $a[0] : -2;
}

function find_even_max( $lines, $regex_match, $regex_replace )
{
  $a = array();
  foreach ( $lines as $line )
  {
     if ( ! preg_match( $regex_match, $line ) ) continue;

     // Isolate the version and put in an array
     $slice = preg_replace( $regex_replace, "$1", $line );

     if ( "x$slice" == "x$line" ) continue;

     // Skip odd numbered minor versions and minors > 80
     list( $major, $minor, $rest ) = explode( ".", $slice . ".0" );
     if ( $minor % 2 == 1  ) continue;
     if ( $minor     >  80 ) continue;
     array_push( $a, $slice );
  }

  rsort( $a, SORT_NATURAL );  // Max version is at the top
  return ( isset( $a[0] ) ) ? $a[0] : -2;
}

function http_get_file( $url )
{
  if ( ! preg_match( "/sourceforge/", $url ) &&
       ! preg_match( "/mpfr/",        $url ) &&
       ! preg_match( "/psmisc/",      $url ) )
  {
    exec( "curl --location --silent --max-time 30 $url", $dir );

    $s   = implode( "\n", $dir );
    $dir = strip_tags( $s );
    return explode( "\n", $dir );
  }
  else if ( preg_match( "/mpfr/", $url ) )
  {
    # There seems to be a problem with the mpfs certificate
    exec( "curl --location --silent --insecure --max-time 30 $url", $dir );
    $s   = implode( "\n", $dir );
    $dir = strip_tags( $s );
    return explode( "\n", $dir );
  }
  else
  {
    exec( "lynx -dump $url 2>/dev/null", $lines );
    return $lines;
  }
}

function max_parent( $dirpath, $prefix )
{
  // First, remove a directory
  $dirpath  = rtrim  ( $dirpath, "/" );    // Trim any trailing slash
  $position = strrpos( $dirpath, "/" );
  $dirpath  = substr ( $dirpath, 0, $position );

  $lines = http_get_file( $dirpath );

  $regex_match   = "#${prefix}[\d\.]+/#";
  $regex_replace = "#^.*(${prefix}[\d\.]+)/.*$#";
  $max           = find_max( $lines, $regex_match, $regex_replace );

  return "$dirpath/$max";
}

function get_packages( $package, $dirpath )
{
  global $exceptions;
  global $regex;

//if ( $package != "psmisc" ) return 0; // debug

if ( $package == "bc"         ) $dirpath = "https://github.com/gavinhoward/bc/releases";
if ( $package == "check"      ) $dirpath = "https://github.com/libcheck/check/releases";
if ( $package == "e2fsprogs"  ) $dirpath = "https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs";
if ( $package == "expat"      ) $dirpath = "https://sourceforge.net/projects/expat/files";
if ( $package == "elfutils"   ) $dirpath = "https://sourceware.org/ftp/elfutils";
if ( $package == "expect"     ) $dirpath = "https://sourceforge.net/projects/expect/files";
if ( $package == "eudev"      ) $dirpath = "https://github.com/eudev-project/eudev/releases";
if ( $package == "file"       ) $dirpath = "https://github.com/file/file/tags";
if ( $package == "flex"       ) $dirpath = "https://github.com/westes/flex/releases";
if ( $package == "gcc"        ) $dirpath = max_parent( $dirpath, "gcc-" );
if ( $package == "iana-etc"   ) $dirpath = "https://github.com/Mic92/iana-etc/releases";
if ( $package == "intltool"   ) $dirpath = "https://launchpad.net/intltool/trunk";
if ( $package == "libffi"     ) $dirpath = "https://github.com/libffi/libffi/releases";
if ( $package == "meson"      ) $dirpath = "https://github.com/mesonbuild/meson/releases";
if ( $package == "mpc"        ) $dirpath = "https://ftp.gnu.org/gnu/mpc";
if ( $package == "mpfr"       ) $dirpath = "https://mpfr.loria.fr/mpfr-current";
if ( $package == "ncurses"    ) $dirpath = "https://invisible-mirror.net/archives/ncurses";
if ( $package == "ninja"      ) $dirpath = "https://github.com/ninja-build/ninja/releases";
if ( $package == "procps-ng"  ) $dirpath = "https://gitlab.com/procps-ng/procps/-/tags";
if ( $package == "psmisc"     ) $dirpath = "https://gitlab.com/psmisc/psmisc/-/tags";
if ( $package == "Python"     ) $dirpath = "https://www.python.org/downloads/source/";
if ( $package == "shadow"     ) $dirpath = "https://github.com/shadow-maint/shadow/releases";
if ( $package == "sysvinit"   ) $dirpath = "https://github.com/slicer69/sysvinit/releases";
if ( $package == "MarkupSafe" ) $dirpath = "https://pypi.python.org/pypi/MarkupSafe/";
if ( $package == "Jinja"      ) $dirpath = "https://pypi.python.org/pypi/Jinja2/";
if ( $package == "systemd"    ) $dirpath = "https://github.com/systemd/systemd/releases";
//if ( $package == "tcl"        ) $dirpath = "https://sourceforge.net/projects/tcl/files";
if ( $package == "tcl"        ) $dirpath = "https://www.tcl.tk/software/tcltk/download.html";
if ( $package == "util-linux" ) $dirpath = max_parent( $dirpath, "v." );
if ( $package == "vim"        ) $dirpath = "https://github.com/vim/vim/tags";
if ( $package == "wheel"      ) $dirpath = "https://pypi.org/project/wheel/#files";
if ( $package == "zstd"       ) $dirpath = "https://github.com/facebook/zstd/releases";

  // Check for ftp
  if ( preg_match( "/^ftp/", $dirpath ) )
  {
    echo "ftp should not occur\n";
  /*
    $dirpath  = substr( $dirpath, 6 );           // Remove ftp://
    $dirpath  = rtrim ( $dirpath, "/" );         // Trim any trailing slash
    $position = strpos( $dirpath, "/" );         // Divide at first slash
    $server   = substr( $dirpath, 0, $position );
    $path     = substr( $dirpath, $position );

    $conn = ftp_connect( $server );
    ftp_login( $conn, "anonymous", "" );

    // See if we need special handling
    if ( isset( $exceptions[ $package ] ) )
    {
       $specials = explode( ":", $exceptions[ $package ] );

       foreach ( $specials as $i )
       {
          list( $op, $regexp ) = explode( "=", $i );

          switch ($op)
          {
            case "UPDIR":
              // Remove last dir from $path
              $position = strrpos( $path, "/" );
              $path = substr( $path, 0, $position );

              // Get dir listing
              $lines = ftp_rawlist ($conn, $path);
              $max   = find_max( $lines, $regexp, $regexp );
              break;

            case "DOWNDIR":
              // Append found directory
              $path .= "/$max";
              break;

            default:
              echo "Error in specials array for $package\n";
              return -5;
              break;
          }
       }
    }

    $lines = ftp_rawlist ($conn, $path);
    ftp_close( $conn );
*/
  }
  else // http(s)
  {
     // Customize http directories as needed
     if ( $package == "tzdata" )
     {
        // Remove two directories
        $dirpath  = rtrim  ( $dirpath, "/" );    // Trim any trailing slash
        $position = strrpos( $dirpath, "/" );
        $dirpath  = substr ( $dirpath, 0, $position );
        $position = strrpos( $dirpath, "/" );
        $dirpath  = substr ( $dirpath, 0, $position );
     }

     $lines = http_get_file( $dirpath );
     if ( ! is_array( $lines ) ) return -6;
  } // End fetch

  if ( isset( $regex[ $package ] ) )
  {
     // Custom search for latest package name
     foreach ( $lines as $l )
     {
        $ver = preg_replace( $regex[ $package ], "$1", $l );
        if ( $ver == $l ) continue;
        return $ver;  // Return first match of regex
     }

     return -7;  // This is an error
  }

  if ( $package == "perl" )  // Custom for perl
  {
     $tmp = array();

     foreach ( $lines as $l )
     {
        if ( preg_match( "/sperl/", $l ) ) continue; // Don't want this
        $ver = preg_replace( "/^.*perl-([\d\.]+\d)\.tar.*$/", "$1", $l );
        if ( $ver == $l ) continue;
        list( $s1, $s2, $rest ) = explode( ".", $ver );
        if ( $s2 % 2 == 1 ) continue; // Remove odd minor versions
        array_push( $tmp, $l );
     }

     $lines = $tmp;
  }

  if ( $package == "attr" ||
       $package == "acl"  )
  {
     return find_max( $lines, "/$package/", "/^.*$package-([\d\.-]*\d).tar.*$/" );
  }

  if ( $package == "e2fsprogs" )
     return find_max( $lines, "/v\d/", "/^.*v(\d[\d\.]+\d).*$/" );

  if ( $package == "eudev" )
     return find_max( $lines, "/Release/", "/^.*Release (\d[\d\.]+\d).*$/" );

  if ( $package == "expect" )
     return find_max( $lines, "/expect/", "/^.*expect(\d[\d\.]+\d).tar.*$/" );

  if ( $package == "elfutils" )
     return find_max( $lines, "/^\d/", "/^(\d[\d\.]+\d)\/.*$/" );

  if ( $package == "iana-etc" )
     return find_max( $lines, "/^\s*20\d\d/", "/^\s+(\d+).*$/" );

  if ( $package == "meson" )
     return find_max( $lines, "/^\s+\d\./", "/^\s+([\d\.]+)$/" );

  if ( $package == "shadow" )
     return find_max( $lines, "/^\s+\d\./", "/^\s+([\d\.]+)$/" );

  if ( $package == "sysvinit" )
     return find_max( $lines, "/^\s+\d\./", "/^\s+([\d\.]+)$/" );

  if ( $package == "XML-Parser" )
  {
     $max = find_max( $lines, "/$package/", "/^.*$package-([\d\._]*\d).tar.*$/" );
     # 2.44_01 is a developer release
     if ( $max == "2.44_01" ) { return "2.44"; }
     return $max;
  }

  if ( $package == "tcl" )
     return find_max( $lines, "/tcl\d/", "/^.*tcl(\d\.[\d\.]*\d)-src.*$/" );

  if ( $package == "ninja" )
     return find_max( $lines, "/v\d/", "/^.*v(\d[\d\.]*\d).*$/" );

  if ( $package == "gmp" )
     return find_max( $lines, "/$package/", "/^.*$package-([\d\._]*\d[a-z]?).tar.*$/" );

  if ( $package == "dbus" )
     return find_even_max( $lines, "/$package/", "/^.*$package-([\d\.]+).tar.*$/" );

  if ( $package == "file" )
  {
     $max = find_max( $lines, "/FILE5/", "/^.*FILE(5_\d+)*$/" );
     return str_replace( "_", ".", $max );
  }

  if ( $package == "libffi" )
     return find_max( $lines, "/v\d/", "/^.*v([\d\.]+)$/" );

  if ( $package == "procps-ng" )
     return find_max( $lines, "/v\d/", "/^.*v([\d\.]+)$/" );

  if ( $package == "psmisc" )
     return find_max( $lines, "/v\d/", "/^.*v([\d\.]+).tar.*$/" );

  if ( $package == "grub" )
     return find_max( $lines, "/grub/", "/^.*grub-([\d\.]+).tar.xz.*$/" );

  if ( $package == "Jinja" )
     return find_max( $lines, "/Jinja/", "/^.*Jinja2 ([\d\.]+).*$/" );

  if ( $package == "openssl" )
     return find_max( $lines, "/openssl/", "/^.*openssl-([\d\.p]*\d.?).tar.*$/" );

  if ( $package == "vim" )
     return find_max( $lines, "/v\d\./", "/^.*v([\d\.]+).*$/" );

  if ( $package == "zstd" )
     return find_max( $lines, "/Zstandard v/", "/^.*v([\d\.]+).*$/" );

  // Most packages are in the form $package-n.n.n
  // Occasionally there are dashes (e.g. 201-1)
  return find_max( $lines, "/$package/", "/^.*$package-([\d\.-]*\d)\.tar.*$/" );
}

function get_current()
{
   global $dirs;
   global $vers;

   // Fetech from git and get wget-list
   $current = array();
   #$lfssvn = "svn://svn.linuxfromscratch.org/LFS/trunk";
   $lfsgit = "git://git.linuxfromscratch.org/lfs.git";

   $tmpdir = exec( "mktemp -d /tmp/lfscheck.XXXXXX" );
   $cdir   = getcwd();
   chdir( $tmpdir );
   #exec ( "svn --quiet export $lfssvn LFS" );
   exec ( "git clone $lfsgit LFS" );

   # Make version.ent
   chdir( "$tmpdir/LFS" );
   exec ( "./git-version.sh systemd" );

   chdir( $cdir );

   $PAGE       = "$tmpdir/LFS/chapter03/chapter03.xml";
   $STYLESHEET = "$tmpdir/LFS/stylesheets/wget-list.xsl";

   exec( "xsltproc --xinclude --nonet $STYLESHEET $PAGE", $current );
   exec( "rm -rf $tmpdir" );

   foreach ( $current as $line )
   {
      $file = basename( $line ) . "\n";
      if ( preg_match( "/patch$/", $file ) ) { continue; } // Skip patches

      $file = preg_replace( "/bz2/", '', $file ); // The 2 confusses the regex

      $file        = rtrim( $file );
      $pkg_pattern = "/(\D*).*/";
      //$pattern     = "/\D*(\d.*\d)\D*/";
      $pattern     = "/\D*(\d.*\d)\D*/";

      if ( preg_match( "/e2fsprogs/", $file ) )
      {
        $pattern = "/e2\D*(\d.*\d)\D*/";
        $pkg_pattern = "/(e2\D*).*/";
      }

      else if ( preg_match( "/tzdata/", $file ) )
      {
        $pattern = "/\D*(\d.*[a-z])\.tar\D*/";
      }

      else if ( preg_match( "/openssl/", $file ) )
      {
        $pattern = "/\D*(\d.*\d.*).tar.*$/";
      }

      else if ( preg_match( "/gmp/", $file ) )
      {
        $pattern = "/\D*(\d.*[a-z]*)\.tar\D*/";
      }

      else if ( preg_match( "/systemd-man-pages/", $file ) ) continue;
      else if ( preg_match( "/python/"         , $file ) ) continue;

      $version = preg_replace( $pattern, "$1", $file );   // Isolate version
      $version = preg_replace( "/^\d-/", "", $version );  // Remove leading #-

      // Touch up package names
      $pkg_name = preg_replace( $pkg_pattern, "$1", $file );
      $pkg_name = trim( $pkg_name, "-" );

      if ( preg_match( "/bzip|iproute/", $pkg_name ) ) { $pkg_name .= "2"; }
      if ( preg_match( "/^m$/"         , $pkg_name ) ) { $pkg_name .= "4"; }
      if ( preg_match( "/shadow/"      , $pkg_name ) ) { $pkg_name  = "shadow"; }

      $dirs[ $pkg_name ] = dirname( $line );
      $vers[ $pkg_name ] = $version;
   }
}

function mail_to_lfs()
{
   global $date;
   global $vers;
   global $dirs;

   $to      = "lfs-book@lists.linuxfromscratch.org";
   $from    = "bdubbs@linuxfromscratch.org";
   $subject = "LFS Package Currency Check - $date GMT";
   $headers = "From: bdubbs@linuxfromscratch.org";

   $message = "Package         LFS      Upstream  Flag\n\n";

   foreach ( $dirs as $pkg => $dir )
   {
      //if ( $pkg != "gmp" ) continue;  //debug
      $v = get_packages( $pkg, $dir );

      $flag = ( $vers[ $pkg ] != $v ) ? "*" : "";

      // Pad for output
      $pad = "                ";
      $p   = substr( $pkg          . $pad, 0, 15 );
      $l   = substr( $vers[ $pkg ] . $pad, 0, 10 );
      $c   = substr( $v            . $pad, 0, 10 );

      $message .= "$p $l $c $flag\n";
   }

   exec ( "echo '$message' | mailx -r $from -s '$subject' $to" );
}

function html()
{

   global $date;
   global $vers;
   global $dirs;

   echo "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN'
                      'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'>
<head>
<title>LFS Package Currency Check - $date</title>
<style type='text/css'>
h1, h2 {
   text-align      : center;
}

table {
   border-width    : 1px;
   border-spacing  : 0px;
   border-style    : outset;
   border-color    : gray;
   border-collapse : separate;
   background-color: white;
   margin          : 0px auto;
}

table th {
   border-width    : 1px;
   padding         : 2px;
   border-style    : inset;
   border-color    : gray;
   background-color: white;
}

table td {
   border-width    : 1px;
   padding         : 2px;
   border-style    : inset;
   border-color    : gray;
   background-color: white;
}
</style>

</head>
<body>
<h1>LFS Package Currency Check</h1>
<h2>As of $date GMT</h1>

<table>
<tr><th>LFS Package</th> <th>LFS Version</th> <th>Latest</th> <th>Flag</th></tr>\n";

   // Get the latest version of each package
   foreach ( $dirs as $pkg => $dir )
   {
      $v    = get_packages( $pkg, $dir );
      $flag = ( $vers[ $pkg ] != $v ) ? "*" : "";
      echo "<tr><td>$pkg</td> <td>${vers[ $pkg ]}</td> <td>$v</td> <td>$flag</td></tr>\n";
   }

   echo "</table>
</body>
</html>\n";

}

function write_to_stdout()
{

   global $date;
   global $vers;
   global $dirs;

   echo "
LFS Package Currency Check
As of $date GMT

LFS Package     LFS Version Latest Flag\n";

   // Get the latest version of each package
   foreach ( $dirs as $pkg => $dir )
   {
      $p_name    = sprintf( "%-15s", $pkg );       // package name formatted

      $b_version = $vers[ $pkg ];                 // book version
      $b_string  = sprintf( "%-11s", $b_version ); // book version formatted

      $latest    = get_packages( $pkg, $dir );    // latest version
      $l_string  = sprintf( "%-6s", $latest );     // latest version formatted

      $flag = ( $b_version != $latest ) ? "*" : "";
      echo "$p_name $b_string $l_string  $flag\n";
   }
}

get_current();  // Get what is in the book
mail_to_lfs();
//html();  // Write html output
//write_to_stdout();  // For debugging
?>
