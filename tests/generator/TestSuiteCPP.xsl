<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
    <xsl:output method="text"/>
    <xsl:strip-space elements="*"/>

    <!-- Initial code -->
    <xsl:template match="IDSs">


<!--============ Includes   ===========-->
#include &lt;stdlib.h>
#include &lt;time.h>
#include "UALClasses.h"

#include "helper.cpp"

using namespace IdsNs;
<xsl:text>&#10;</xsl:text>

   	<xsl:text>const int TEST_SHOT = 9999;&#10;</xsl:text>
        <xsl:text>const int TEST_RUN = 9999;&#10;</xsl:text>
     
	
	  <xsl:text>IDS imas = IDS(  TEST_SHOT, TEST_RUN, -1, -1);&#10;</xsl:text>


  
        <xsl:text>&#10;</xsl:text>


<!--	
       <xsl:text>public static void imasTest() throws Exception {&#10;</xsl:text>
       <xsl:text>&#9;java.util.ArrayList idss = imas.getAvailableIDSs();&#10;</xsl:text>
       <xsl:text>&#9;printf("List of available CPOs\n");&#10;</xsl:text>
       <xsl:text>&#9;for(int i=0; i  &lt; idss.size();i++) {&#10;</xsl:text>
       <xsl:text>&#9;&#9;printf(idss.get(i));&#10;</xsl:text>
       <xsl:text>&#9;}&#10;</xsl:text>
       <xsl:text>&#10;</xsl:text>
       <xsl:text>&#9;printf("\nNumber of occurences\n");&#10;</xsl:text>
       <xsl:text>&#9;for(int i=0; i &lt; idss.size();i++) {&#10;</xsl:text>
       <xsl:text>&#9;&#9;int occur = imas.getMaxOccurences((String)idss.get(i));&#10;</xsl:text>
       <xsl:text>&#9;&#9;System.out.format("%2d - %s\n",occur, (String)idss.get(i));&#10;</xsl:text>
       <xsl:text>&#9;}&#10;</xsl:text>
       <xsl:text>&#10;</xsl:text>
       <xsl:text>&#9;}&#10;</xsl:text>
       <xsl:text>&#10;</xsl:text>
    -->   
    
  
  

        <xsl:text>double* getTime() {&#10;</xsl:text>
        <xsl:text>&#9;return (new double[8]);&#10;</xsl:text>
        <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>

   
<!--
        <xsl:text>private static void assertField(Object observed, Object expected, String fieldname) {&#10;</xsl:text>
        <xsl:text>&#9;assert observed != null : fieldname + " is NULL!";&#10;</xsl:text>
        <xsl:text>&#9;String className = observed.getClass().toString();&#10;</xsl:text>
        <xsl:text>&#9;if (className.contains("Vect")) {&#10;</xsl:text>
        <xsl:text>&#9;&#9;Object oarray = null, earray = null;&#10;</xsl:text>
        <xsl:text>&#9;&#9;try {&#10;</xsl:text>
        <xsl:text>&#9;&#9;&#9;oarray = observed.getClass().getMethod("getArray").invoke(observed);&#10;</xsl:text>
        <xsl:text>&#9;&#9;&#9;earray = expected.getClass().getMethod("getArray").invoke(expected);&#10;</xsl:text>
        <xsl:text>&#9;&#9;} catch (Exception e) {&#10;</xsl:text>
        <xsl:text>&#9;&#9;&#9;printf(fieldname + " : error, observed=" + observed + ", expected=" + expected);&#10;</xsl:text>
        <xsl:text>&#9;&#9;&#9;e.printStackTrace();&#10;</xsl:text>
        <xsl:text>&#9;&#9;}&#10;</xsl:text>
        <xsl:text>&#9;&#9;if (className.contains("Boolean"))&#10;</xsl:text>
        <xsl:text>&#9;&#9;&#9;assert Arrays.equals((boolean[]) oarray, (boolean[]) earray) : fieldname + " : different values, observed=" + Arrays.toString((boolean[]) oarray) + ", expected=" + Arrays.toString((boolean[]) earray);&#10;</xsl:text>
        <xsl:text>&#9;&#9;if (className.contains("Double"))&#10;</xsl:text>
        <xsl:text>&#9;&#9;&#9;assert Arrays.equals((double[]) oarray, (double[]) earray) : fieldname + " : different values, observed=" + Arrays.toString((double[]) oarray) + ", expected=" + Arrays.toString((double[]) earray);&#10;</xsl:text>
        <xsl:text>&#9;&#9;if (className.contains("Float"))&#10;</xsl:text>
        <xsl:text>&#9;&#9;&#9;assert Arrays.equals((float[]) oarray, (float[]) earray) : fieldname + " : different values, observed=" + Arrays.toString((float[]) oarray) + ", expected=" + Arrays.toString((float[]) earray);&#10;</xsl:text>
        <xsl:text>&#9;&#9;if (className.contains("Int"))&#10;</xsl:text>
        <xsl:text>&#9;&#9;&#9;assert Arrays.equals((int[]) oarray, (int[]) earray) : fieldname + " : different values, observed=" + Arrays.toString((int[]) oarray) + ", expected=" + Arrays.toString((int[]) earray);&#10;</xsl:text>
        <xsl:text>&#9;&#9;if (className.contains("String"))&#10;</xsl:text>
        <xsl:text>&#9;&#9;&#9;assert Arrays.equals((String[]) oarray, (String[]) earray) : fieldname + " : different values, observed=" + Arrays.toString((String[]) oarray) + ", expected=" + Arrays.toString((String[]) earray);&#10;</xsl:text>
       <xsl:text>&#9;&#9;if (className.contains("Complex"))&#10;</xsl:text>
        <xsl:text>&#9;&#9;&#9;assert Arrays.equals((UALComplexNumber[]) oarray, (UALComplexNumber[]) earray) : fieldname + " : different values, observed=" + Arrays.toString((UALComplexNumber[]) oarray) + ", expected=" + Arrays.toString((UALComplexNumber[]) earray);&#10;</xsl:text>
   
        <xsl:text>&#9;} else&#10;</xsl:text>
        <xsl:text>&#9;&#9;assert observed.hashCode() == expected.hashCode() : fieldname + " : different values, observed=" + observed + ", expected=" + expected;&#10;</xsl:text>
        <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
-->
<!--

        <xsl:apply-templates select="child::IDS" mode="put"/>
        <xsl:apply-templates select="child::IDS" mode="get"/>

  	<xsl:apply-templates select="child::IDS" mode="putSlice"/>
        <xsl:apply-templates select="child::IDS" mode="getSlice"/>

-->

                 <xsl:apply-templates select="child::IDS[@name='core_transport']" mode="put"/>
                 <xsl:apply-templates select="child::IDS[@name='core_transport']" mode="get"/>
        
             <xsl:apply-templates select="child::IDS[@name='core_transport']" mode="putSlice"/>
                 <xsl:apply-templates select="child::IDS[@name='core_transport']" mode="getSlice"/>

        <xsl:text>void initPut()&#10;</xsl:text>
        <xsl:text>{&#10;</xsl:text>
        <xsl:text>&#9;&#9;&#9;imas.create();&#10;</xsl:text>
        <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>

        <xsl:text>void initGet() &#10;</xsl:text>
        <xsl:text>{&#10;</xsl:text>
        <xsl:text>&#9;&#9;&#9;imas.open();&#10;</xsl:text>
        <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
	

        <xsl:text>void finish()&#10;</xsl:text>
	     <xsl:text>{&#10;</xsl:text>
        <xsl:text>&#9;imas.close();&#10;</xsl:text>
        <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
 
        <xsl:text> int main(int argc, char** argv){&#10;</xsl:text>


        <xsl:apply-templates select="child::IDS" mode="test"/>

        <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>

    </xsl:template>




    <!-- IDS perform the tests -->


    <xsl:template match="IDS[@name='core_transport']" mode="test">
<!--
 <xsl:template match="IDS" mode="test">
-->

	<xsl:text>&#9;&#9;initPut();&#10;</xsl:text> 
        <xsl:text>&#9;&#9;</xsl:text><xsl:value-of select="@name"/><xsl:text>_put();&#10;</xsl:text>
	<xsl:text>&#9;&#9;finish();&#10;</xsl:text> 
	<xsl:text>&#9;&#9;initGet();&#10;</xsl:text> 
        <xsl:text>&#9;&#9;</xsl:text><xsl:value-of select="@name"/><xsl:text>_get();&#10;</xsl:text>
	<xsl:text>&#9;&#9;finish();&#10;</xsl:text> 
 <!--    	<xsl:text>&#9;&#9;initPut();&#10;</xsl:text> 
        <xsl:text>&#9;&#9;</xsl:text><xsl:value-of select="@name"/><xsl:text>_putSlice();&#10;</xsl:text>
	<xsl:text>&#9;&#9;finish();&#10;</xsl:text> 
   	<xsl:text>&#9;&#9;initGet();&#10;</xsl:text> 
        <xsl:text>&#9;&#9;</xsl:text><xsl:value-of select="@name"/><xsl:text>_getSlice();&#10;</xsl:text>
	<xsl:text>&#9;&#9;finish();&#10;</xsl:text> 
   -->
	<xsl:text>&#10;</xsl:text>
    </xsl:template>

    
    <!-- IDS put()-->
    <xsl:template match="IDS" mode="put">
        <xsl:text>void </xsl:text><xsl:value-of select="@name"/><xsl:text>_put(){&#10;</xsl:text>
        <xsl:text>&#9;printf("Testing put() on </xsl:text><xsl:value-of select="@name"/><xsl:text>\n");&#10;</xsl:text>
        <xsl:text>&#9;srand(randseed);&#10;</xsl:text>
        <xsl:text>&#9;IDS::</xsl:text><xsl:value-of select="@name"/><xsl:text> ids = imas._</xsl:text><xsl:value-of select="@name"/><xsl:text>;&#10;</xsl:text>
     <!--   <xsl:text>&#9;for (int occurrence = 0; occurrence &lt; </xsl:text><xsl:value-of select="@maxoccur"/><xsl:text> + 1; occurrence++) {&#10;</xsl:text>
     -->   <xsl:apply-templates select="field" mode="put"/>
        <xsl:text>&#9;&#9;ids.put(0);&#10;</xsl:text>
	<!-- <xsl:text>&#9;&#9;ids.put(occurrence);&#10;</xsl:text>
   -     <xsl:text>&#9;}&#10;</xsl:text>
    -->    <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>


    <!-- IDS putSlice()-->
    <xsl:template match="IDS" mode="putSlice">
        <xsl:text>void </xsl:text><xsl:value-of select="@name"/><xsl:text>_putSlice() {&#10;</xsl:text>
        <xsl:text>&#9;printf("Testing putSlice() on </xsl:text><xsl:value-of select="@name"/><xsl:text>\n");&#10;</xsl:text>
                <xsl:text>&#9;srand(randseed);&#10;</xsl:text>
        <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    

    <!-- IDS get()-->
    <xsl:template match="IDS" mode="get">
        <xsl:text>void </xsl:text><xsl:value-of select="@name"/><xsl:text>_get() {&#10;</xsl:text>
        <xsl:text>&#9;printf("Testing get() on </xsl:text><xsl:value-of select="@name"/><xsl:text>\n");&#10;</xsl:text>

        <xsl:text>&#9;srand(randseed);&#10;</xsl:text>
        <xsl:text>&#9;IDS::</xsl:text><xsl:value-of select="@name"/><xsl:text> ids = imas._</xsl:text><xsl:value-of select="@name"/><xsl:text>;&#10;</xsl:text>
 <!--       <xsl:text>&#9;for (int occurrence = 0; occurrence &lt; </xsl:text><xsl:value-of select="@maxoccur"/><xsl:text> + 1; occurrence++) {&#10;</xsl:text>
   	<xsl:text>&#9;&#9;ids.get(occurrence);&#10;</xsl:text>
-->
	<xsl:text>&#9;&#9;ids.get(0);&#10;</xsl:text>
   	<xsl:apply-templates select="field" mode="get"/> 
  <!--      <xsl:text>&#9;}&#10;</xsl:text>
    -->    <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>


   <!-- IDS get()-->
    <xsl:template match="IDS" mode="getSlice">
        <xsl:text>void </xsl:text><xsl:value-of select="@name"/><xsl:text>_getSlice()  {&#10;</xsl:text>
        <xsl:text>&#9;printf("Testing getSlice() on </xsl:text><xsl:value-of select="@name"/><xsl:text>\n");&#10;</xsl:text>
        <xsl:text>&#9;srand(randseed);&#10;</xsl:text>
        <xsl:text>&#9;IDS::</xsl:text><xsl:value-of select="@name"/><xsl:text> ids = imas._</xsl:text><xsl:value-of select="@name"/><xsl:text>;&#10;</xsl:text>
        <xsl:text>&#9;for (int occurrence = 0; occurrence &lt; </xsl:text><xsl:value-of select="@maxoccur"/><xsl:text> + 1; occurrence++) {&#10;</xsl:text>
 	<xsl:text>&#9;&#9;ids.getSlice(occurrence, 0.0, CLOSEST_SAMPLE);&#10;</xsl:text>
	<!-- <xsl:apply-templates select="field" mode="getSlice"/> -->
        <xsl:text>&#9;}&#10;</xsl:text>
        <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    

    <!-- field put() -->
    <xsl:template match="field[not(@data_type='structure' or @data_type='struct_array')]" mode="put">
        <xsl:call-template name="setValue">
          <xsl:with-param name="path" select="translate(@path, '/', '.')"/>
	</xsl:call-template>
    </xsl:template>


    <!-- field put() for array of structures -->
    <xsl:template match="field[@data_type='struct_array']" mode="put">
       <xsl:call-template name="putStructArray">
            <xsl:with-param name="path" select="concat(translate(@path, '/', '.'), '(0)')"/>
            <xsl:with-param name="resize" select="true()"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="putStructArray">
        <xsl:param name="path"/>
        <xsl:param name="resize"/>
        <xsl:if test="$resize"><xsl:text>&#9;&#9;ids.</xsl:text><xsl:value-of select="substring($path, 1, string-length($path) - 3)"/><xsl:text>.resize(1);&#10;</xsl:text>
	</xsl:if>
        <xsl:for-each select="field[not(@data_type='struct_array' or @data_type='structure')]">
	     	<xsl:call-template name="setValue">
        	  <xsl:with-param name="path" select="concat($path, '.', @name)"/>
		</xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="field[@data_type='structure']">
            <xsl:call-template name="putStructArray">
                <xsl:with-param name="path" select="concat($path, '.', @name)"/>
                <xsl:with-param name="resize" select="false()"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="field[@data_type='struct_array']">
            <xsl:call-template name="putStructArray">
                <xsl:with-param name="path" select="concat($path, '.', @name, '(0)')"/>
                <xsl:with-param name="resize" select="true()"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template> 


    <!-- field get() -->
    <xsl:template match="field[not(@data_type='structure' or @data_type='struct_array')]" mode="get">
    <xsl:choose>
	
	  <xsl:when test="@name='homogeneous_time'">              <xsl:text>&#9;&#9;// NOT TESTED: ids.</xsl:text><xsl:value-of select="@path"/><xsl:text> = 1;&#10;</xsl:text></xsl:when>
      <xsl:otherwise>
		   <xsl:text>&#9;&#9;assertField(ids.</xsl:text><xsl:value-of select="translate(@path, '/', '.')"/><xsl:text>, "</xsl:text><xsl:value-of select="ancestor::IDS/@name"/><xsl:text>/</xsl:text><xsl:value-of select="@path"/><xsl:text>");&#10;</xsl:text>
		</xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- field get() for array of structures -->
    <xsl:template match="field[@data_type='struct_array']" mode="get">
       <xsl:call-template name="getStructArray">
            <xsl:with-param name="path" select="concat(translate(@path, '/', '.'), '(0)')"/>
	     <xsl:with-param name="slice" select="false()"/>
        </xsl:call-template>
  </xsl:template>



    <!-- field getSlice() -->
    <xsl:template match="field[not(@data_type='structure' or @data_type='struct_array')]" mode="getSlice">


        <xsl:text>&#9;&#9;assertField(ids.</xsl:text><xsl:value-of select="translate(@path, '/', '.')"/><xsl:text>, "</xsl:text><xsl:value-of select="ancestor::IDS/@name"/><xsl:text>/</xsl:text><xsl:value-of select="@path"/><xsl:text>");&#10;</xsl:text>
    </xsl:template>


    <!-- field get() for array of structures -->
    <xsl:template match="field[@data_type='struct_array']" mode="getSlice">
        <xsl:call-template name="getStructArray">
            <xsl:with-param name="path" select="concat(translate(@path, '/', '.'), '(0)')"/>
	     <xsl:with-param name="slice" select="true()"/>
        </xsl:call-template>
    </xsl:template>
    


    <xsl:template name="getStructArray">
        <xsl:param name="path"/>
	<xsl:param name="slice"/>
        <xsl:for-each select="field[not(@data_type='struct_array' or @data_type='structure')]">
            <xsl:choose>
                <xsl:when test="$slice and @type='dynamic' and not(ancestor::field[@data_type='struct_array' and @maxoccur='unbounded'])  ">
      		  <xsl:text>&#9;&#9;assertField(ids.</xsl:text><xsl:value-of select="concat($path, '.', @name)"/><xsl:text>, </xsl:text><xsl:call-template name="type2value4slice"/><xsl:text>, "</xsl:text><xsl:value-of select="ancestor::IDS/@name"/><xsl:text>/</xsl:text><xsl:value-of select="@path"/><xsl:text>");&#10;</xsl:text>
        	</xsl:when>
	        <xsl:otherwise>
	<!--        <xsl:text>&#9;&#9;assertField(ids.</xsl:text><xsl:value-of select="concat($path, '.', @name)"/><xsl:text>, </xsl:text><xsl:call-template name="type2value"/><xsl:text>, "</xsl:text><xsl:value-of select="ancestor::IDS/@name"/><xsl:text>/</xsl:text><xsl:value-of select="@path"/><xsl:text>");&#10;</xsl:text>
       --> <xsl:text>&#9;&#9;assertField(ids.</xsl:text><xsl:value-of select="concat($path, '.', @name)"/><xsl:text>, "</xsl:text><xsl:value-of select="ancestor::IDS/@name"/><xsl:text>/</xsl:text><xsl:value-of select="@path"/><xsl:text>");&#10;</xsl:text>
     	        </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="field[@data_type='structure']">
            <xsl:call-template name="getStructArray">
                <xsl:with-param name="path" select="concat($path, '.', @name)"/>
		   <xsl:with-param name="slice" select="$slice"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="field[@data_type='struct_array']">
            <xsl:call-template name="getStructArray">
                <xsl:with-param name="path" select="concat($path, '.', @name, '(0)')"/>
		 <xsl:with-param name="slice" select="$slice"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    
   <xsl:template name="setValue">
        <xsl:param name="path"/>

	<xsl:text>&#9;&#9;</xsl:text>
        <xsl:choose>
	
	  <xsl:when test="@name='homogeneous_time'">              <xsl:text>&#9;&#9;ids.</xsl:text><xsl:value-of select="$path"/><xsl:text> = 1;&#10;</xsl:text></xsl:when>

	
      <!-- <xsl:when test="@name='time'  and (@data_type='flt_1d_type' or @data_type='FLT_1D') ">              <xsl:text>getTime()</xsl:text></xsl:when>
-->
            <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">         <xsl:text>&#9;&#9;ids.</xsl:text><xsl:value-of select="$path"/><xsl:text> = getString();&#10;</xsl:text></xsl:when>
            <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">    <xsl:text>new Vect1DString((String[]) getArray(Types.STRING, 1))</xsl:text></xsl:when>

            <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">          <xsl:text>&#9;&#9;ids.</xsl:text><xsl:value-of select="$path"/><xsl:text> = getDouble();&#10;</xsl:text></xsl:when>
            <xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">      <xsl:text>&#9;&#9;setArray(ids.</xsl:text><xsl:value-of select="$path"/><xsl:text>,3);&#10;</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_2D'">     <xsl:text>new Vect2DDouble(1, 2, (double[]) getArray(Types.DOUBLE, 2))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_3D'">   <xsl:text>new Vect3DDouble(1, 1, 3, (double[]) getArray(Types.DOUBLE, 3))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_4D'">   <xsl:text>new Vect4DDouble(1, 1, 1, 4, (double[]) getArray(Types.DOUBLE, 4))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_5D'">   <xsl:text>new Vect5DDouble(1, 1, 1, 1, 5, (double[]) getArray(Types.DOUBLE, 5))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_6D'">	<xsl:text>new Vect6DDouble(1, 1, 1, 1, 1, 6, (double[]) getArray(Types.DOUBLE, 6))</xsl:text></xsl:when>

            <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">      <xsl:text>&#9;&#9;ids.</xsl:text><xsl:value-of select="$path"/><xsl:text> = getInteger();&#10;</xsl:text></xsl:when>
            <xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">      <xsl:text>&#9;&#9;setArray(ids.</xsl:text><xsl:value-of select="$path"/><xsl:text>,3);&#10;</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_2D'">      <xsl:text>new Vect2DInt(1, 2, (int[]) getArray(Types.INTEGER, 2))</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_3D'">  <xsl:text>new Vect3DInt(1, 1, 3, (int[]) getArray(Types.INTEGER, 3))</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_4D'">  <xsl:text>new Vect4DInt(1, 1, 1, 4, (int[]) getArray(Types.INTEGER, 4))</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_5D'">   <xsl:text>new Vect5DInt(1, 1, 1, 1, 5, (int[]) getArray(Types.INTEGER, 5))</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_6D'">  <xsl:text>new Vect6DInt(1, 1, 1, 1, 1, 6, (int[]) getArray(Types.INTEGER, 6))</xsl:text></xsl:when>

     	    
	    <xsl:otherwise>
	       <xsl:message terminate="yes">     
		             <xsl:text>&#xA; UNKNOWN TYPE:   </xsl:text>  <xsl:value-of select="@data_type"/>  : <xsl:value-of select="@path"/>   : <xsl:value-of select="@maxoccur"/>   :  <xsl:value-of select="@type"/> 
		</xsl:message>
		</xsl:otherwise>
        </xsl:choose>
    </xsl:template>


   <xsl:template name="getValue">

        <xsl:choose>
	
	  <xsl:when test="@name='homogeneous_time'">              <xsl:text>// homogeneous_time not tested </xsl:text></xsl:when>

	
      <!-- <xsl:when test="@name='time'  and (@data_type='flt_1d_type' or @data_type='FLT_1D') ">              <xsl:text>getTime()</xsl:text></xsl:when>
-->
            <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">        <xsl:text>getString()</xsl:text></xsl:when>
            <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">    <xsl:text>new Vect1DString((String[]) getArray(Types.STRING, 1))</xsl:text></xsl:when>

            <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">          <xsl:text>getDouble()</xsl:text></xsl:when>
            <xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">     <xsl:text>getDoubleArray(3)</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_2D'">     <xsl:text>new Vect2DDouble(1, 2, (double[]) getArray(Types.DOUBLE, 2))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_3D'">   <xsl:text>new Vect3DDouble(1, 1, 3, (double[]) getArray(Types.DOUBLE, 3))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_4D'">   <xsl:text>new Vect4DDouble(1, 1, 1, 4, (double[]) getArray(Types.DOUBLE, 4))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_5D'">   <xsl:text>new Vect5DDouble(1, 1, 1, 1, 5, (double[]) getArray(Types.DOUBLE, 5))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_6D'">	<xsl:text>new Vect6DDouble(1, 1, 1, 1, 1, 6, (double[]) getArray(Types.DOUBLE, 6))</xsl:text></xsl:when>

            <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">        <xsl:text>getInteger()</xsl:text></xsl:when>
            <xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">       <xsl:text>getIntegerArray(3)</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_2D'">      <xsl:text>new Vect2DInt(1, 2, (int[]) getArray(Types.INTEGER, 2))</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_3D'">  <xsl:text>new Vect3DInt(1, 1, 3, (int[]) getArray(Types.INTEGER, 3))</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_4D'">  <xsl:text>new Vect4DInt(1, 1, 1, 4, (int[]) getArray(Types.INTEGER, 4))</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_5D'">   <xsl:text>new Vect5DInt(1, 1, 1, 1, 5, (int[]) getArray(Types.INTEGER, 5))</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_6D'">  <xsl:text>new Vect6DInt(1, 1, 1, 1, 1, 6, (int[]) getArray(Types.INTEGER, 6))</xsl:text></xsl:when>

     	    
	    <xsl:otherwise>
	       <xsl:message terminate="yes">     
		             <xsl:text>&#xA; UNKNOWN TYPE:   </xsl:text>  <xsl:value-of select="@data_type"/>  : <xsl:value-of select="@path"/>   : <xsl:value-of select="@maxoccur"/>   :  <xsl:value-of select="@type"/> 
		</xsl:message>
		</xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="type2value">

        <xsl:choose>
	
	  <xsl:when test="@name='homogeneous_time'">              <xsl:text>1</xsl:text></xsl:when>

	
      <!-- <xsl:when test="@name='time'  and (@data_type='flt_1d_type' or @data_type='FLT_1D') ">              <xsl:text>getTime()</xsl:text></xsl:when>
-->
            <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">        <xsl:text>getString()</xsl:text></xsl:when>
            <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">    <xsl:text>new Vect1DString((String[]) getArray(Types.STRING, 1))</xsl:text></xsl:when>

            <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">          <xsl:text>getDouble()</xsl:text></xsl:when>
            <xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">     <xsl:text>getDoubleArray(3)</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_2D'">     <xsl:text>new Vect2DDouble(1, 2, (double[]) getArray(Types.DOUBLE, 2))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_3D'">   <xsl:text>new Vect3DDouble(1, 1, 3, (double[]) getArray(Types.DOUBLE, 3))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_4D'">   <xsl:text>new Vect4DDouble(1, 1, 1, 4, (double[]) getArray(Types.DOUBLE, 4))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_5D'">   <xsl:text>new Vect5DDouble(1, 1, 1, 1, 5, (double[]) getArray(Types.DOUBLE, 5))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_6D'">	<xsl:text>new Vect6DDouble(1, 1, 1, 1, 1, 6, (double[]) getArray(Types.DOUBLE, 6))</xsl:text></xsl:when>

            <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">        <xsl:text>getInteger()</xsl:text></xsl:when>
            <xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">       <xsl:text>getIntegerArray(3)</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_2D'">      <xsl:text>new Vect2DInt(1, 2, (int[]) getArray(Types.INTEGER, 2))</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_3D'">  <xsl:text>new Vect3DInt(1, 1, 3, (int[]) getArray(Types.INTEGER, 3))</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_4D'">  <xsl:text>new Vect4DInt(1, 1, 1, 4, (int[]) getArray(Types.INTEGER, 4))</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_5D'">   <xsl:text>new Vect5DInt(1, 1, 1, 1, 5, (int[]) getArray(Types.INTEGER, 5))</xsl:text></xsl:when>
            <xsl:when test="@data_type='INT_6D'">  <xsl:text>new Vect6DInt(1, 1, 1, 1, 1, 6, (int[]) getArray(Types.INTEGER, 6))</xsl:text></xsl:when>

     	    
	    <xsl:otherwise>
	       <xsl:message terminate="yes">     
		             <xsl:text>&#xA; UNKNOWN TYPE:   </xsl:text>  <xsl:value-of select="@data_type"/>  : <xsl:value-of select="@path"/>   : <xsl:value-of select="@maxoccur"/>   :  <xsl:value-of select="@type"/> 
		</xsl:message>
		</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
   
      <xsl:template name="type2value4slice">
        <xsl:choose>
	      <xsl:when test="@name='homogeneous_time'">              <xsl:text>1</xsl:text>	      </xsl:when>
       	      <xsl:when test="@name='time' and (@data_type='flt_1d_type' or @data_type='FLT_1D')">   <xsl:text>getTime()</xsl:text></xsl:when> 
              <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">                         <xsl:text>getString()</xsl:text></xsl:when>
              <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">                      <xsl:text>(new Vect1DString((String[]) getArray(Types.STRING, 1))).getElementAt(0)</xsl:text></xsl:when>
              <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">                         <xsl:text>getDouble()</xsl:text></xsl:when>
              <xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">             <xsl:text>new Vect1DDouble((double[]) getArray(Types.DOUBLE, 1))</xsl:text></xsl:when>
              <xsl:when test="@data_type='FLT_2D'">     <xsl:text>(new Vect2DDouble(1, 2, (double[]) getArray(Types.DOUBLE, 2))).getElementAt(0)</xsl:text></xsl:when>
              <xsl:when test="@data_type='FLT_3D'">   <xsl:text>(new Vect3DDouble(1, 1, 3, (double[]) getArray(Types.DOUBLE, 3))).getElementAt(0)</xsl:text></xsl:when>
              <xsl:when test="@data_type='FLT_4D'">   <xsl:text>(new Vect4DDouble(1, 1, 1, 4, (double[]) getArray(Types.DOUBLE, 4))).getElementAt(0)</xsl:text></xsl:when>
              <xsl:when test="@data_type='FLT_5D'">   <xsl:text>(new Vect5DDouble(1, 1, 1, 1, 5, (double[]) getArray(Types.DOUBLE, 5))).getElementAt(0)</xsl:text></xsl:when>
              <xsl:when test="@data_type='FLT_6D'">	<xsl:text>(new Vect6DDouble(1, 1, 1, 1, 1, 6, (double[]) getArray(Types.DOUBLE, 6))).getElementAt(0)</xsl:text></xsl:when>
              
	      <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">        <xsl:text>(getInteger()</xsl:text></xsl:when>
              <xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">       <xsl:text>new Vect1DInt((int[]) getArray(Types.INTEGER, 1))</xsl:text></xsl:when>
              <xsl:when test="@data_type='INT_2D'">      <xsl:text>(new Vect2DInt(1, 2, (int[]) getArray(Types.INTEGER, 2))).getElementAt(0)</xsl:text></xsl:when>
              <xsl:when test="@data_type='INT_3D'">  <xsl:text>(new Vect3DInt(1, 1, 3, (int[]) getArray(Types.INTEGER, 3))).getElementAt(0)</xsl:text></xsl:when>
              <xsl:when test="@data_type='INT_4D'">  <xsl:text>(new Vect4DInt(1, 1, 1, 4, (int[]) getArray(Types.INTEGER, 4))).getElementAt(0)</xsl:text></xsl:when>
              <xsl:when test="@data_type='INT_5D'">   <xsl:text>(new Vect5DInt(1, 1, 1, 1, 5, (int[]) getArray(Types.INTEGER, 5))).getElementAt(0)</xsl:text></xsl:when>
              <xsl:when test="@data_type='INT_6D'">  <xsl:text>(new Vect6DInt(1, 1, 1, 1, 1, 6, (int[]) getArray(Types.INTEGER, 6))).getElementAt(0)</xsl:text></xsl:when>
	      <xsl:otherwise>
	         <xsl:message terminate="yes">     
		      <xsl:text>&#xA; UNKNOWN TYPE:   </xsl:text>  <xsl:value-of select="@data_type"/>  : <xsl:value-of select="@path"/>   : <xsl:value-of select="@maxoccur"/>   :  <xsl:value-of select="@type"/> 
		</xsl:message>
	      </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
