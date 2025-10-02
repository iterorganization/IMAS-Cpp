<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
   xmlns:exsl="http://exslt.org/common"
   xmlns:my="http://localhost.localdomain/localns"
   exclude-result-prefixes="my"
   extension-element-prefixes="exsl">
   <xsl:include href="./identifiers.common.xsl"/>

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<!-- MAIN, FILE GENERATION -->
<xsl:template match="/constants">

  <!-- C++ Header FILE -->
  <exsl:document href="{$prefix}{$name}.h" method="text">
    <xsl:text>#ifndef H_</xsl:text>
    <xsl:value-of select="my:upall($name)"/>
    <xsl:text>&#xA;#define H_</xsl:text>
    <xsl:value-of select="my:upall($name)"/><xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates select="header" mode="C"/>
    <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:apply-templates select="include[@name='C']"/><xsl:text>&#xA;&#xA;</xsl:text>
    
    <xsl:text>&#xA;</xsl:text>
    <xsl:if test="//constants[@create_mapping_function]">
      <xsl:text>#include &lt;string&gt;&#xA;</xsl:text>
      <xsl:text>#include &lt;stdexcept&gt;&#xA;</xsl:text>
      <xsl:text>&#xA;</xsl:text>
      <xsl:text>class </xsl:text><xsl:value-of select="$name"/><xsl:text> {&#xA;</xsl:text>
      <xsl:text>public:&#xA;</xsl:text>
      <xsl:text>    static int get_index(const std::string&amp; name);&#xA;</xsl:text>
      <xsl:text>    static std::string get_description(int idx);&#xA;</xsl:text>
      <xsl:text>    static std::string get_name(int idx);&#xA;</xsl:text>
      <xsl:text>    &#xA;</xsl:text>
      <xsl:text>    static bool get_type_data_by_name(const std::string&amp; name, int&amp; index, std::string&amp; originalname,std::string&amp; description);&#xA;</xsl:text>
      <xsl:text>    &#xA;</xsl:text>
      <xsl:text>    // Setter for an object&#xA;</xsl:text>
      <xsl:text>    template&lt;typename T&gt;&#xA;</xsl:text>
      <xsl:text>    static void set_identifier(T&amp; obj, const std::string&amp; name) {&#xA;</xsl:text>
      <xsl:text>        int temp_index;&#xA;</xsl:text>
      <xsl:text>        std::string temp_name;&#xA;</xsl:text>
      <xsl:text>        std::string temp_description;&#xA;</xsl:text>
      <xsl:text>        &#xA;</xsl:text>
      <xsl:text>        try {&#xA;</xsl:text>
      <xsl:text>            get_type_data_by_name(name, temp_index, temp_name, temp_description);&#xA;</xsl:text>
      <xsl:text>            obj.index = temp_index;&#xA;</xsl:text>
      <xsl:text>            obj.name = temp_name;&#xA;</xsl:text>
      <xsl:text>            obj.description = temp_description;&#xA;</xsl:text>
      <xsl:text>        } catch (const std::invalid_argument&amp; e) {&#xA;</xsl:text>
      <xsl:text>            // Re-throw with more context&#xA;</xsl:text>
      <xsl:text>            throw std::invalid_argument("Failed to set identifier: " + std::string(e.what()));&#xA;</xsl:text>
      <xsl:text>        }&#xA;</xsl:text>
      <xsl:text>    }&#xA;</xsl:text>
      <xsl:text>    &#xA;</xsl:text>
      <xsl:text>    // Setter for an array &#xA;</xsl:text>
      <xsl:text>    template&lt;typename T, size_t N&gt;&#xA;</xsl:text>
      <xsl:text>    static void set_identifier(T&amp; obj, const std::string (&amp;names)[N]) {&#xA;</xsl:text>
      <xsl:text>        // Resize object array to match name array size&#xA;</xsl:text>
      <xsl:text>        obj.indices.resize(N);&#xA;</xsl:text>
      <xsl:text>        obj.names.resize(N);&#xA;</xsl:text>
      <xsl:text>        obj.descriptions.resize(N);&#xA;</xsl:text>
      <xsl:text>        &#xA;</xsl:text>
      <xsl:text>        for (size_t i = 0; i &lt; N; ++i) {&#xA;</xsl:text>
      <xsl:text>            int temp_index;&#xA;</xsl:text>
      <xsl:text>            std::string temp_name;&#xA;</xsl:text>
      <xsl:text>            std::string temp_description;&#xA;</xsl:text>
      <xsl:text>            &#xA;</xsl:text>
      <xsl:text>            try {&#xA;</xsl:text>
      <xsl:text>                get_type_data_by_name(names[i], temp_index, temp_name, temp_description);&#xA;</xsl:text>
      <xsl:text>                obj.indices(i) = temp_index;&#xA;</xsl:text>
      <xsl:text>                obj.names(i) = temp_name;&#xA;</xsl:text>
      <xsl:text>                obj.descriptions(i) = temp_description;&#xA;</xsl:text>
      <xsl:text>            } catch (const std::invalid_argument&amp; e) {&#xA;</xsl:text>
      <xsl:text>                // Re-throw with array index context&#xA;</xsl:text>
      <xsl:text>                throw std::invalid_argument("Failed to set identifier at index " + std::to_string(i) + ": " + std::string(e.what()));&#xA;</xsl:text>
      <xsl:text>            }&#xA;</xsl:text>
      <xsl:text>        }&#xA;</xsl:text>
      <xsl:text>    }&#xA;</xsl:text>
      <xsl:text>};&#xA;</xsl:text>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:text>#endif</xsl:text>
  </exsl:document>
  
  <exsl:document href="{$prefix}{$name}.cpp" method="text">
    <xsl:text>#include "</xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text>.h"&#xA;</xsl:text>
    <xsl:if test="//constants[@create_mapping_function]">
      <xsl:call-template name="class_implementation"/>
    </xsl:if>
  </exsl:document>
</xsl:template>
<!-- Simple class implementation -->
<xsl:template name="class_implementation">
    <xsl:text>&#xA;</xsl:text>
    <xsl:text>// Implementation of </xsl:text><xsl:value-of select="$name"/><xsl:text> class&#xA;</xsl:text>
    <xsl:text>&#xA;</xsl:text>

    <!-- get_index method -->
    <xsl:if test="int!='' and */@name!=''">
      <xsl:text>int </xsl:text><xsl:value-of select="$name"/><xsl:text>::get_index(const std::string&amp; name) {&#xA;</xsl:text>
      <xsl:for-each select="//constants/int[@name]">
        <xsl:text>    if (name == "</xsl:text><xsl:value-of select="@name"/><xsl:text>") {&#xA;</xsl:text>
        <xsl:text>        return </xsl:text><xsl:value-of select="."/><xsl:text>;&#xA;</xsl:text>
        <xsl:text>    }&#xA;</xsl:text>
        <xsl:if test="@alias">
          <xsl:text>    if (name == "</xsl:text><xsl:value-of select="@alias"/><xsl:text>") {&#xA;</xsl:text>
          <xsl:text>        return </xsl:text><xsl:value-of select="."/><xsl:text>;&#xA;</xsl:text>
          <xsl:text>    }&#xA;</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>    return -999999999; // Unknown identifier&#xA;</xsl:text>
      <xsl:text>}&#xA;&#xA;</xsl:text>
    </xsl:if>

    <!-- get_description method -->
    <xsl:if test="int!=''">
      <xsl:text>std::string </xsl:text><xsl:value-of select="$name"/><xsl:text>::get_description(int idx) {&#xA;</xsl:text>
      <xsl:text>    switch(idx) {&#xA;</xsl:text>
      <xsl:for-each select="//constants/int[@name]">
        <xsl:text>        case </xsl:text>
        <xsl:value-of select="."/>    
        <xsl:text>:&#xA;</xsl:text>
        <xsl:text>            return "</xsl:text>
        <xsl:value-of select="@description"/>    
        <xsl:text>";&#xA;</xsl:text>
      </xsl:for-each>
      <xsl:text>    }&#xA;</xsl:text>
      <xsl:text>    return "unknown";&#xA;</xsl:text>
      <xsl:text>}&#xA;&#xA;</xsl:text>
    </xsl:if>

    <!-- get_name method -->
    <xsl:if test="int!=''">
      <xsl:text>std::string </xsl:text><xsl:value-of select="$name"/><xsl:text>::get_name(int idx) {&#xA;</xsl:text>
      <xsl:text>    switch(idx) {&#xA;</xsl:text>
      <xsl:for-each select="//constants/int[@name]">
        <xsl:text>        case </xsl:text>
        <xsl:value-of select="."/>    
        <xsl:text>:&#xA;</xsl:text>
        <xsl:text>            return "</xsl:text>
        <xsl:value-of select="@name"/>    
        <xsl:text>";&#xA;</xsl:text>
      </xsl:for-each>
      <xsl:text>    }&#xA;</xsl:text>
      <xsl:text>    return "unknown";&#xA;</xsl:text>
      <xsl:text>}&#xA;&#xA;</xsl:text>
    </xsl:if>

    <!-- get_type_data_by_name method -->
    <xsl:if test="int!='' and */@name!=''">
      <xsl:text>bool </xsl:text><xsl:value-of select="$name"/><xsl:text>::get_type_data_by_name(const std::string&amp; name, int&amp; index, std::string&amp; originalname, std::string&amp; description) {&#xA;</xsl:text>
      <xsl:for-each select="//constants/int[@name]">
        <xsl:text>    if (name == "</xsl:text><xsl:value-of select="@name"/><xsl:text>") {&#xA;</xsl:text>
        <xsl:text>        index = </xsl:text><xsl:value-of select="."/><xsl:text>;&#xA;</xsl:text>
        <xsl:text>        originalname = "</xsl:text><xsl:value-of select="@name"/><xsl:text>";&#xA;</xsl:text>
        <xsl:text>        description = "</xsl:text><xsl:value-of select="@description"/><xsl:text>";&#xA;</xsl:text>
        <xsl:text>        return true;&#xA;</xsl:text>
        <xsl:text>    }&#xA;</xsl:text>
        <xsl:if test="@alias">
          <xsl:text>    if (name == "</xsl:text><xsl:value-of select="@alias"/><xsl:text>") {&#xA;</xsl:text>
          <xsl:text>        index = </xsl:text><xsl:value-of select="."/><xsl:text>;&#xA;</xsl:text>
          <xsl:text>        originalname = "</xsl:text><xsl:value-of select="@name"/><xsl:text>";&#xA;</xsl:text>
          <xsl:text>        description = "</xsl:text><xsl:value-of select="@description"/><xsl:text>";&#xA;</xsl:text>
          <xsl:text>        return true;&#xA;</xsl:text>
          <xsl:text>    }&#xA;</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>    // Unknown identifier - throw exception&#xA;</xsl:text>
      <xsl:text>    throw std::invalid_argument("Unknown identifier: '" + name + "'");&#xA;</xsl:text>
      <xsl:text>}&#xA;&#xA;</xsl:text>
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

<xsl:template match="comment" mode="C">
  <xsl:call-template name="replace-string">
    <xsl:with-param name="text" select="concat('&#xA;',text())"/>
    <xsl:with-param name="replace" select="'&#xA;'"/>
    <xsl:with-param name="with" select="'&#xA;// '"/>
  </xsl:call-template>
  <xsl:text>&#xA;</xsl:text>
</xsl:template>

</xsl:stylesheet>