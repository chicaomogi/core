/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Document generator - HTML output
 *
 * Copyright 2009 April White <april users.sourceforge.net>
 * www - http://harbour-project.org
 *
 * Portions of this project are based on hbdoc
 *    Copyright 1999-2003 Luiz Rafael Culik <culikr@uol.com.br>
 *    Copyright 2000 Luiz Rafael Culik <culik@sl.conex.net>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include "hbclass.ch"
#include "inkey.ch"
#include "fileio.ch"
#include "hbdoc2.ch"

#ifdef __PLATFORM__DOS
   #define EXTENSION "htm"
#else
   #define EXTENSION "html"
#endif

CLASS GenerateHTML2 FROM GenerateHTML
   METHOD NewIndex( cFolder, cFilename, cTitle )
   METHOD NewDocument( cFolder, cFilename, cTitle )
ENDCLASS

METHOD NewDocument( cFolder, cFilename, cTitle ) CLASS GenerateHTML2
   ::lNewDocumentModel := .T.
   super:NewDocument( cFolder, cFilename, cTitle, EXTENSION )
   RETURN self

METHOD NewIndex( cFolder, cFilename, cTitle ) CLASS GenerateHTML2
   ::lNewDocumentModel := .T.
   super:NewIndex( cFolder, cFilename, cTitle, EXTENSION )
   RETURN self

CLASS GenerateHTML FROM TPLGenerate
HIDDEN:
   METHOD RecreateStyleDocument( cStyleFile )
   METHOD OpenTag( cText, ... )
   METHOD Tagged( cText, cTag, ... )
   METHOD CloseTag( cText )
   METHOD Append( cText, cFormat )
   METHOD Newline() INLINE FWrite( ::nHandle, "<br />" + HB_OSNewLine() ), self

   CLASSDATA lCreateStyleDocument AS LOGICAL INIT .T.
   DATA TargetFilename AS STRING INIT ""

PROTECTED:
   DATA lNewDocumentModel AS LOGICAL INIT .F.

EXPORTED:
   METHOD NewFile() HIDDEN
   METHOD NewIndex( cFolder, cFilename, cTitle )
   METHOD NewDocument( cFolder, cFilename, cTitle )
   METHOD AddEntry( oEntry )
   //~ METHOD AddIndex( oEntry ) HIDDEN
   METHOD AddReference( oEntry, cReference, cSubReference )
   METHOD BeginSection( cSection, cFilename )
   METHOD EndSection( cSection, cFilename )
   METHOD Generate()

   METHOD WriteEntry( cField, oEntry, lPreformatted, nIndent ) HIDDEN
ENDCLASS

METHOD NewFile() CLASS GenerateHTML
   IF ::lNewDocumentModel
      FWrite( ::nHandle, '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' + HB_OSNewLine() )
   ELSE
      FWrite( ::nHandle, '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2//EN">' + HB_OSNewLine() )
   ENDIF

   ::OpenTag( "html" )
   ::OpenTag( "head" )

   ::Append( ::cTitle /* + IIf( Empty( ::cDescription ), "", " - " + ::cDescription ) */, "title" )
   ::OpenTag( "meta", "name", "generator", "content", "Harbour examples/hbdoc2" )
   ::OpenTag( "meta", "name", "keywords", "content", "Harbour project, Clipper, xBase, database, Free Software, GNU, compiler, cross platform, 32-bit, FiveWin" )

   IF ::lNewDocumentModel
#define STYLEFILE "hrb_doc.css"
      IF ::lCreateStyleDocument
         ::lCreateStyleDocument := .F.
         ::RecreateStyleDocument( STYLEFILE )
      ENDIF
      ::OpenTag( "link", "rel", "stylesheet", "type", "text/css", "href", STYLEFILE )
#undef STYLEFILE
   ENDIF

   ::CloseTag( "head" )
   ::OpenTag( "body" )
   ::Append( ::cTitle, "h1" )
   /* IF ! Empty( ::cDescription )
      ::Append( ::cDescription, "h2" )
   ENDIF */

   RETURN self

METHOD NewDocument( cFolder, cFilename, cTitle ) CLASS GenerateHTML
   super:NewDocument( cFolder, cFilename, cTitle, EXTENSION )
   ::NewFile()
   RETURN self

METHOD NewIndex( cFolder, cFilename, cTitle ) CLASS GenerateHTML
   super:NewIndex( cFolder, cFilename, cTitle, EXTENSION )
   ::NewFile()
   RETURN self

METHOD BeginSection( cSection, cFilename ) CLASS  GenerateHTML
//~ HB_SYMBOL_UNUSED( cFilename )
   IF ::IsIndex()
      If cFilename == ::cFilename
         ::OpenTag( "a", "name", cSection ):Append( cSection, "h" + HB_NTOS( ::Depth + 2 ) ):CloseTag( "a" )//:Newline()
      ELSE
         ::OpenTag( "a", "href", cFilename + "." + ::cExtension + "#" + cSection ):Append( cSection, "h" + HB_NTOS( ::Depth + 2 ) ):CloseTag( "a" )//:Newline()
      ENDIF
   ELSE
      ::OpenTag( "a", "name", cSection ):Append( cSection, "h" + HB_NTOS( ::Depth + 2 ) ):CloseTag( "a" )//:Newline()
   ENDIF
   ::TargetFilename := cFilename
   ::Depth++
   RETURN self

METHOD EndSection( cSection, cFilename ) CLASS  GenerateHTML
HB_SYMBOL_UNUSED( cSection )
HB_SYMBOL_UNUSED( cFilename )
   ::Depth--
   //~ FWrite( ::nHandle, Replicate( Chr(9), ::Depth ) + [</Section>] + HB_OSNewLine() )
   RETURN self

METHOD AddReference( oEntry, cReference, cSubReference ) CLASS GenerateHTML
   IF HB_IsObject( oEntry ) .AND. oEntry:ClassName == "ENTRY"
      ::OpenTag( "a", "href", ::TargetFilename + "." + ::cExtension + "#" + oEntry:Filename ):Append( oEntry:Name ):CloseTag( "a" ):Append( oEntry:OneLiner ):Newline()
   ELSE
      IF cSubReference == NIL
         ::OpenTag( "a", "href", cReference + "." + ::cExtension /* + "#" + oEntry:Filename */ ):Append( oEntry ):CloseTag( "a" ):Newline()
      ELSE
         ::OpenTag( "a", "href", cReference + "." + ::cExtension + "#" + cSubReference ):Append( oEntry ):CloseTag( "a" ):Newline()
      ENDIF
   ENDIF
   RETURN self

//~ METHOD AddIndex( oEntry ) CLASS GenerateHTML
   //~ ::OpenTag( "a", "href", ::TargetFilename + "." + ::cExtension + "#" + oEntry:Filename ):Append( oEntry:Name ):CloseTag( "a" ):Append( oEntry:OneLiner ):Newline()
   //~ RETURN self

METHOD AddEntry( oEntry ) CLASS GenerateHTML
   LOCAL idx

   FOR idx := 1 TO Len( oEntry:Fields )
      IF oEntry:Fields[ idx ][ 1 ] == "NAME"
         ::OpenTag( "a", "name", oEntry:filename ):OpenTag( "h4" ):Append( oEntry:Name ):CloseTag( "h4" ):CloseTag( "a" )
      ELSEIF oEntry:IsField( oEntry:Fields[ idx ][ 1 ] ) .AND. oEntry:IsOutput( oEntry:Fields[ idx ][ 1 ] ) .AND. Len( oEntry:&( oEntry:Fields[ idx ][ 1 ] ) ) > 0
         ::WriteEntry( oEntry:Fields[ idx ][ 1 ], oEntry, oEntry:IsPreformatted( oEntry:Fields[ idx ][ 1 ] ) )
      ENDIF
   NEXT

   RETURN self

METHOD Generate() CLASS GenerateHTML
   IF ! Empty( ::nHandle )
      ::CloseTag( "body" )
      ::CloseTag( "html" )
      FClose( ::nHandle )
      ::nHandle := 0
   ENDIF
   RETURN self

METHOD PROCEDURE WriteEntry( cField, oEntry, lPreformatted, nIndent ) CLASS GenerateHTML
   LOCAL cCaption := oEntry:FieldName( cField )
   LOCAL cEntry := oEntry:&( cField )
// TODO: change this to search the CSS document itself
   LOCAL cTagClass := IIf( LOWER( cField ) + "|" $ "name|oneliner|examples|tests|", LOWER( cField ), "itemtext" )

   IF ! Empty( cEntry )
      DEFAULT cCaption TO ""
      DEFAULT nIndent TO 0
      //~ DEFAULT lPreformatted TO .F.
      //~ DEFAULT cTagClass TO "itemtext"

      IF Len( cCaption ) > 0 /* .AND. nIndent > 0 */
         IF ::lNewDocumentModel
            ::Tagged( cCaption, "div", "class", "itemtitle" )
         ELSE
            ::Append( cCaption, "h5" )
         ENDIF
      ENDIF

      IF ::lNewDocumentModel
      ELSE
         ::OpenTag( "dl" )
      ENDIF

      IF lPreformatted
         IF ::lNewDocumentModel
            ::OpenTag( "pre", IIf( cTagClass != NIL, "class", ), cTagClass )
         ELSE
            ::OpenTag( "dd" ):OpenTag( "pre" )
         ENDIF
         DO WHILE Len( cEntry ) > 0
            ::Append( Indent( Parse( @cEntry, HB_OSNewLine() ), 0, , .T. ), "" )
            //~ IF Len( cEntry ) > 0 .AND. ! lPreformatted
               //~ FWrite( ::nHandle, HB_OSNewLine() )
            //~ ENDIF
         ENDDO
         IF ::lNewDocumentModel
            ::CloseTag( "pre" )
         ELSE
            ::CloseTag( "pre" ):CloseTag( "dd" )
         ENDIF
      ELSE
         DO WHILE Len( cEntry ) > 0
            IF ::lNewDocumentModel
               ::OpenTag( "div", "class", cTagClass )
            ELSE
               ::OpenTag( "dd" ):OpenTag( "p" )
            ENDIF
            ::Append( Indent( Parse( @cEntry, HB_OSNewLine() ), 0, 70 ), "" ):Newline()
            IF ::lNewDocumentModel
               ::CloseTag( "div" )
            ELSE
               ::CloseTag( "dd" )
            ENDIF
         ENDDO
      ENDIF
      IF ::lNewDocumentModel
      ELSE
         ::CloseTag( "dl" )
      ENDIF
   ENDIF

METHOD OpenTag( cText, ... ) CLASS GenerateHTML
   LOCAL aArgs := HB_AParams()
   LOCAL cTag := cText
   LOCAL idx

   FOR idx := 2 TO Len( aArgs ) STEP 2
      cTag += " " + aArgs[ idx ] + "=" + Chr(34) + aArgs[ idx + 1 ] + Chr(34)
   NEXT

   FWrite( ::nHandle, "<" + cTag + ">" + HB_OSNewLine() )

   RETURN self

METHOD Tagged( cText, cTag, ... ) CLASS GenerateHTML
   LOCAL aArgs := HB_AParams()
   LOCAL cResult := "<" + cTag
   LOCAL idx

   FOR idx := 3 TO Len( aArgs ) STEP 2
      cResult += " " + aArgs[ idx ] + "=" + Chr(34) + aArgs[ idx + 1 ] + Chr(34)
   NEXT

   FWrite( ::nHandle, cResult + ">" + cText + "</" + cTag + ">" + /* "4" + */ HB_OSNewLine() )

   RETURN self

METHOD CloseTag( cText ) CLASS GenerateHTML
   FWrite( ::nHandle, "</" + cText + ">" + HB_OSNewLine() )

   IF cText == "html"
      FClose( ::nHandle )
      ::nHandle := 0
   ENDIF

   RETURN self

METHOD Append( cText, cFormat ) CLASS GenerateHTML
   LOCAL cResult := cText
   LOCAL aFormat
   LOCAL idx

   IF Len( cResult ) > 0

      DEFAULT cFormat TO ""

      aFormat := p_aConversionList
      FOR idx := 1 TO Len( aFormat ) STEP 2
         cResult := StrTran( cResult, Chr( aFormat[ idx ] ), "&" + aFormat[ idx + 1 ] + ";" )
      NEXT

      aFormat := Split( cFormat, "," )
      FOR idx := Len( aFormat ) TO 1 STEP -1
         cResult := "<" + aFormat[ idx ] + ">" + cResult + "</" + aFormat[ idx ] + ">"
      NEXT

      DO WHILE Right( cResult, Len( HB_OSNewLine() ) ) == HB_OSNewLine()
         cResult := SubStr( cResult, 1, Len( cResult ) - Len( HB_OSNewLine() ) )
      ENDDO

      FWrite( ::nHandle, cResult + HB_OSNewLine() )

   ENDIF

   RETURN self

METHOD RecreateStyleDocument( cStyleFile ) CLASS GenerateHTML
   LOCAL nHandle

   IF ( nHandle := FCreate( ::cFolder + p_hsSwitches[ "PATH_SEPARATOR" ] + cStyleFile ) ) > 0
      FWrite( nHandle, ;
         "/* Harbour Documents Stylesheet (" + cStyleFile + ") */" + HB_OSNewLine() + ;
         "body {font-family:arial;font-size:14px;line-height:18px;}" + HB_OSNewLine() + ;
         /* ".classtitle {font-weight:bold;font-size:22px;padding-bottom:4px;}" + HB_OSNewLine() + */ ;
         ".name {font-weight:bold;font-size:18px;margin-left:0px;padding-top:0px;padding-bottom:4px;}" + HB_OSNewLine() + ;
         ".oneliner {font-style:italic;margin-bottom:12px;}" + HB_OSNewLine() + ;
         ".itemtitle {font-weight:bold;margin-left:0px;padding-top:0px;padding-bottom:4px;}" + HB_OSNewLine() + ;
         ".itemtext {margin-left:10px;padding-bottom:4px;}" + HB_OSNewLine() + ;
         ".examples {margin-left:10px;padding-bottom:4px;}" + HB_OSNewLine() + ;
         ".tests {margin-left:10px;padding-bottom:4px;}" + HB_OSNewLine() + ;
         "" ;
      )

      FClose( nHandle )
   ELSE
      // TODO: raise an error, could not create style file
   ENDIF

   RETURN self