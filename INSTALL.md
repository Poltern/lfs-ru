Инструкции по конвертации книги LFS в другие форматы

После того, как был загружен исходный код этой книги, необходимо настроить 
программное обеспечение, для того, чтобы вы могли выполнить конвертацию 
исходного кода в формате XML в другой формат, например - в HTML, TXT или PDF.

Нет необходимости изучать этот документ, если Вас интересует только изменение 
исходного кода XML и отправка его фрагментов в списки рассылок lfs-book или 
lfs-dev. Вместо этого, Вам следует прочитать руководство редактора LFS. 
Посетите официальный сайт LFS http://www.linuxfromscratch.org, или одно из 
зеркал, для получения дополнительной информации.

-------------------------------------------------------------------------------

Если необходимо выполнить конвертацию книги из XML в HTML, установите 
следующие пакеты:

* libxml2
  - https://www.linuxfromscratch.org/blfs/view/svn/general/libxml2.html

* libxslt
  - https://www.linuxfromscratch.org/blfs/view/svn/general/libxslt.html

* DocBook 4.5 XML DTD
  - https://www.linuxfromscratch.org/blfs/view/svn/pst/docbook.html

* DocBook XSL Stylesheets
  - https://www.linuxfromscratch.org/blfs/view/svn/pst/docbook-xsl.html

* HTMLTidy
  - https://www.linuxfromscratch.org/blfs/view/svn/general/tidy-html5.html

-------------------------------------------------------------------------------

Если необходимо выполнить конвертацию книги из XML в TXT, установите 
перечисленные выше пакеты, а затем установите следующие:

* lynx
  - https://www.linuxfromscratch.org/blfs/view/svn/basicnet/lynx.html

-------------------------------------------------------------------------------

Если необходимо выполнить конвертацию книги из XML в PDF, установите 
перечисленные выше пакеты (кроме lynx), а затем установите следующие:

* JDK
  - https://www.linuxfromscratch.org/blfs/view/svn/general/openjdk.html

* FOP and JAI
  - https://www.linuxfromscratch.org/blfs/view/svn/pst/fop.html
