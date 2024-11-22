<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>

<xsl:stylesheet 
   xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" 
   xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
   xmlns:exsl="http://exslt.org/common"
   xmlns:str="http://exslt.org/strings"
   xmlns:func="http://exslt.org/functions"
   xmlns:my="http://localhost.localdomain/localns"
   exclude-result-prefixes="my"
   extension-element-prefixes="yaslt exsl func str">
   <xsl:include href="./identifiers.common.xsl"/>

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<!-- MAIN, FILE GENERATION -->
<xsl:template match="/constants">

  <!-- C FILE -->
  <exsl:document href="{$prefix}{$name}.h" method="text">
    <xsl:text>#ifndef H_</xsl:text>
    <xsl:value-of select="my:upall($name)"/>
    <xsl:text>&#xA;#define H_</xsl:text>
    <xsl:value-of select="my:upall($name)"/><xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates select="header" mode="C"/>
    <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:apply-templates select="include[@name='C']"/><xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:apply-templates select="*[name()!='header' and name()!='include']" mode="C"/>
    <xsl:text>&#xA;</xsl:text>
    <xsl:if test="//constants[@create_mapping_function]">
      <xsl:text>typedef struct imas_</xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text> {&#xA;</xsl:text>
      <xsl:text>  int type_index;&#xA;</xsl:text>
      <xsl:text>  const char* type_name;&#xA;</xsl:text>
      <xsl:text>  const char* type_description;&#xA;</xsl:text>
      <xsl:text>#if defined(__cplusplus)&#xA;</xsl:text>
      <xsl:text>  imas_</xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>  get_all(int idx);&#xA;</xsl:text>
      <xsl:text>  int get_type_index(const char* name);&#xA;</xsl:text>
      <xsl:text>  const char* get_type_name(int idx);&#xA;</xsl:text>
      <xsl:text>  const char* get_type_description(int idx);&#xA;</xsl:text>
      <xsl:text>#endif //defined(__cplusplus);&#xA;</xsl:text>
      <xsl:text>}&#xA;</xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>;&#xA;&#xA;</xsl:text>

      <xsl:text>#if defined(__cplusplus)&#xA;</xsl:text>
      <xsl:text>extern "C" {&#xA;</xsl:text>
      <xsl:text>#endif //defined(__cplusplus)&#xA;</xsl:text>

      <xsl:value-of select="$name"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>_get_all(int idx);&#xA;</xsl:text>
      <xsl:text>int </xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>_get_type_index(const char* name);&#xA;</xsl:text>
      <xsl:text>const char* </xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>_get_type_name(int idx);&#xA;</xsl:text>
      <xsl:text>const char* </xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>_get_type_description(int idx);&#xA;</xsl:text>

      <xsl:text>#if defined(__cplusplus)&#xA;</xsl:text>
      <xsl:text>}&#xA;</xsl:text>
      <xsl:text>#endif //defined(__cplusplus)&#xA;</xsl:text>
    </xsl:if>
     <xsl:text>#endif</xsl:text>
  </exsl:document>
  
  <exsl:document href="{$prefix}{$name}.cpp" method="text">
    <xsl:text>#include &#60;</xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text>.h&#62;&#xA;</xsl:text>
    <xsl:if test="//constants[@create_mapping_function]">
      <xsl:call-template name="translations_C"/>
    </xsl:if>
  </exsl:document>
   <!-- DOCBOOK FILE -->
  <exsl:document href="{$prefix}{$name}.xml" method="text">
    <xsl:call-template name="docbook"/>
  </exsl:document>
</xsl:template>
  
<!-- Translations between VALUE, NAME and DESCRIPTION -->
<xsl:template name="translations_C">
    <xsl:text>#include &#60;string.h&#62;&#xA;</xsl:text>
    <xsl:text>&#xA;</xsl:text>
    <xsl:text>#if defined(__cplusplus)&#xA;</xsl:text>

    <!-- Translation from VALUE to NAME DESCRIPTION and VALUE -->
    <xsl:if test="int!='' and */@unique='yes'">
      <xsl:text>// Function returning the NAME DESCRIPTION and VALUE of the type with index IDX.&#xA;</xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>::get_all(int idx) {&#xA;</xsl:text>
      <xsl:text>  </xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text> type_struct;&#xA;</xsl:text>
      <xsl:text>  type_struct.type_name = </xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>_get_type_name(idx);&#xA;</xsl:text>
      <xsl:text>  type_struct.type_description = </xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>_get_type_description(idx);&#xA;</xsl:text>
      <xsl:text>  type_struct.type_index = </xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>_get_type_index(type_struct.type_name);&#xA;</xsl:text>
      <xsl:text>  return type_struct;&#xA;</xsl:text>
      <xsl:text>}&#xA;&#xA;</xsl:text>
    </xsl:if>

    <!-- Translation from NAME to VALUE -->
    <xsl:if test="int!='' and */@name!=''">
      <xsl:text>// Function returning the VALUE of the type with name NAME.&#xA;</xsl:text>
      <xsl:text>int </xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>::get_type_index(const char* name) {&#xA;</xsl:text>
      <xsl:text>  int type_index=-999999999;&#xA;</xsl:text>
      <xsl:for-each select="int[@name]">
        <xsl:text>  if(strcmp(name, "</xsl:text>
        <xsl:value-of select="@name"/>    
        <xsl:text>") == 0) {&#xA;</xsl:text>
        <xsl:text>    return </xsl:text>
        <xsl:value-of select="."/>    
        <xsl:text>;&#xA;  }&#xA;</xsl:text>
      </xsl:for-each>
      <xsl:text>  return type_index;&#xA;</xsl:text>
      <xsl:text>}&#xA;&#xA;</xsl:text>
    </xsl:if>

    <!-- Translation from VALUE to NAME -->
    <xsl:if test="int!='' and */@unique='yes'">
      <xsl:text>// Function returning the NAME of the type with index IDX.&#xA;</xsl:text>
      <xsl:text>const char* </xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>::get_type_name(int idx) {&#xA;</xsl:text>
      <xsl:text>  switch(idx) {&#xA;</xsl:text>
      <xsl:for-each select="int[@name]">
        <xsl:text>    case (</xsl:text>
        <xsl:value-of select="."/>    
        <xsl:text>):&#xA;</xsl:text>
        <xsl:text>      return "</xsl:text>
        <xsl:value-of select="@name"/>    
        <xsl:text>";&#xA;      break;&#xA;</xsl:text>
      </xsl:for-each>
      <xsl:text>  }&#xA;</xsl:text>
      <xsl:text>  return "unknown";&#xA;</xsl:text>
      <xsl:text>}&#xA;&#xA;</xsl:text>
    </xsl:if>

    <!-- Translation from VALUE to DESCRIPTION -->
    <xsl:if test="int!='' and */@unique='yes'">
      <xsl:text>// Function returning the DESCRIPTION of the type with index IDX.&#xA;</xsl:text>
      <xsl:text>const char* </xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>::get_type_description(int idx) {&#xA;</xsl:text>
      <xsl:text>  switch(idx) {&#xA;</xsl:text>
      <xsl:for-each select="*[@unique]">
        <xsl:text>    case (</xsl:text>
        <xsl:value-of select="."/>    
        <xsl:text>):&#xA;</xsl:text>
        <xsl:text>      return "</xsl:text>
        <xsl:value-of select="@description"/>    
        <xsl:text>";&#xA;      break;&#xA;</xsl:text>
      </xsl:for-each>
      <xsl:text>  }&#xA;</xsl:text>
      <xsl:text>  return "Unknown";&#xA;</xsl:text>
      <xsl:text>}&#xA;&#xA;</xsl:text>
    </xsl:if>
 
    <xsl:text>#endif //defined(__cplusplus)&#xA;</xsl:text>
 
    <xsl:if test="int!='' and */@unique='yes'">
    <xsl:value-of select="$name"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text>_get_all(int idx) {&#xA;</xsl:text>
    <xsl:text>  </xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text>  type_struct;&#xA;</xsl:text>
    <xsl:text>  return type_struct.get_all(idx);&#xA;</xsl:text>
    <xsl:text>};&#xA;</xsl:text>
    </xsl:if>
 
    <xsl:if test="int!='' and */@name!=''">
    <xsl:text>int </xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text>_get_type_index(const char* name) {&#xA;</xsl:text>
    <xsl:text>  </xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text>  type_struct;&#xA;</xsl:text>
    <xsl:text>  return type_struct.get_type_index(name);&#xA;</xsl:text>
    <xsl:text>};&#xA;</xsl:text>
    </xsl:if>
 
    <xsl:if test="int!='' and */@unique='yes'">
    <xsl:text>const char* </xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text>_get_type_name(int idx) {&#xA;</xsl:text>
    <xsl:text>  </xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text>  type_struct;&#xA;</xsl:text>
    <xsl:text>  return type_struct.get_type_name(idx);&#xA;</xsl:text>
    <xsl:text>};&#xA;</xsl:text>
    </xsl:if>
 
    <xsl:if test="int!='' and */@unique='yes'">
    <xsl:text>const char* </xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text>_get_type_description(int idx) {&#xA;</xsl:text>
    <xsl:text>  </xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text>  type_struct;&#xA;</xsl:text>
    <xsl:text>  return type_struct.get_type_description(idx);&#xA;</xsl:text>
    <xsl:text>};&#xA;</xsl:text>
    </xsl:if>
</xsl:template>

<!-- C TEMPLATES -->

<xsl:template match="header" mode="C">
  <xsl:call-template name="replace-string">
    <xsl:with-param name="text" select="concat('&#xA;',text())"/>
    <xsl:with-param name="replace" select="'&#xA;'"/>
    <xsl:with-param name="with" select="'&#xA;// '"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="int|float" mode="C">
  <xsl:text>#define </xsl:text>
  <xsl:value-of select="@name"/>
  <xsl:text>&#009;&#009; </xsl:text>
  <xsl:value-of select="."/>
  <xsl:value-of select="my:desc('//')"/>
</xsl:template>

<xsl:template match="string" mode="C">
  <xsl:text>#define </xsl:text>
  <xsl:value-of select="@name"/>
  <xsl:text>&#009;&#009; "</xsl:text>
  <xsl:value-of select="."/><xsl:text>"</xsl:text>
  <xsl:value-of select="my:desc('//')"/>
</xsl:template>

<xsl:template match="comment" mode="C">
  <xsl:call-template name="replace-string">
    <xsl:with-param name="text" select="concat('&#xA;',text())"/>
    <xsl:with-param name="replace" select="'&#xA;'"/>
    <xsl:with-param name="with" select="'&#xA;// '"/>
  </xsl:call-template>
  <xsl:text>&#xA;</xsl:text>
</xsl:template>

</xsl:stylesheet>
