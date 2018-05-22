<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
    <xsl:output method="text"/>
    <xsl:strip-space elements="*"/>

    <!-- Initial code -->
    <xsl:template match="IDSs">


<!--============ Includes   ===========-->
<xsl:text>#include &lt;stdlib.h>&#10;</xsl:text>
<xsl:text>#include &lt;time.h>&#10;</xsl:text>
<xsl:text>#include "UALClasses.h"&#10;</xsl:text>

<xsl:text>#include "helper.h"&#10;</xsl:text>

<xsl:text>using namespace IdsNs;&#10;</xsl:text>
<xsl:text>int randseed = (int)time(NULL);&#10;</xsl:text>
<xsl:text>&#10;</xsl:text>

<xsl:text>const int TEST_SHOT = 9999;&#10;</xsl:text>
<xsl:text>const int TEST_RUN = 9999;&#10;</xsl:text>
     
	
	  


  
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
    
  
  <!--

        <xsl:text>double* getTime() {&#10;</xsl:text>
        <xsl:text>&#9;return (new double[8]);&#10;</xsl:text>
        <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
-->

     	<xsl:apply-templates select="child::IDS" mode="set_non_timed"/>
        <xsl:apply-templates select="child::IDS" mode="set_timed"/>

        <xsl:apply-templates select="child::IDS" mode="put"/>
        <xsl:apply-templates select="child::IDS" mode="get"/>

  	<xsl:apply-templates select="child::IDS" mode="putSlice"/>
        <xsl:apply-templates select="child::IDS" mode="getSlice"/>
<!--
                 <xsl:apply-templates select="child::IDS[@name='transport_solver_numerics']" mode="put"/>
                 <xsl:apply-templates select="child::IDS[@name='transport_solver_numerics']" mode="get"/>
        
             <xsl:apply-templates select="child::IDS[@name='transport_solver_numerics']" mode="putSlice"/>
                 <xsl:apply-templates select="child::IDS[@name='transport_solver_numerics']" mode="getSlice"/>
-->


        <xsl:text> int main(int argc, char** argv){&#10;</xsl:text>


        <xsl:apply-templates select="child::IDS" mode="test"/>

	<xsl:text>&#9;return finalStatus;&#10;</xsl:text>
        <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>

    </xsl:template>




    <!-- IDS perform the tests -->
<!--
    <xsl:template match="IDS[@name='transport_solver_numerics']" mode="test">
-->

 <xsl:template match="IDS" mode="test">
    	<xsl:text>&#9;// </xsl:text><xsl:value-of select="@name"/><xsl:text>&#10;</xsl:text>
        <xsl:text>&#9;&#9;</xsl:text><xsl:value-of select="@name"/><xsl:text>_put();&#10;</xsl:text>
        <xsl:text>&#9;&#9;</xsl:text><xsl:value-of select="@name"/><xsl:text>_get();&#10;</xsl:text>

        <xsl:text>&#9;&#9;</xsl:text><xsl:value-of select="@name"/><xsl:text>_putSlice();&#10;</xsl:text>
        <xsl:text>&#9;&#9;</xsl:text><xsl:value-of select="@name"/><xsl:text>_getSlice();&#10;</xsl:text>
 
	<xsl:text>&#10;</xsl:text>
    </xsl:template>

    

    <xsl:template match="IDS" mode="set_non_timed">
        <xsl:text>void </xsl:text><xsl:value-of select="@name"/><xsl:text>_setNonTimed(){&#10;</xsl:text>
        <xsl:text>&#9;printf("Calling setNonTimed() on </xsl:text><xsl:value-of select="@name"/><xsl:text>\n");&#10;</xsl:text>
	 <xsl:apply-templates select="field" mode="putStatic"/>
	<xsl:text>}&#10;</xsl:text>
       <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="IDS" mode="set_timed">
        <xsl:text>void </xsl:text><xsl:value-of select="@name"/><xsl:text>_setTimed(int timeIdx){&#10;</xsl:text>
        <xsl:text>&#9;printf("Calling setNonTimed() on </xsl:text><xsl:value-of select="@name"/><xsl:text>\n");&#10;</xsl:text>
	 <xsl:apply-templates select="field" mode="putDynamic"/>
	<xsl:text>}&#10;</xsl:text>
       <xsl:text>&#10;</xsl:text>
    </xsl:template>



    <!-- IDS put()-->
    <xsl:template match="IDS" mode="put">
        <xsl:text>!====================================================================================&#10;</xsl:text>
        <xsl:text>!&#9;&#9; PUT </xsl:text><xsl:value-of select="@name"/> <xsl:text> &#10;</xsl:text>
        <xsl:text>!====================================================================================&#10;</xsl:text>
        <xsl:text>void </xsl:text><xsl:value-of select="@name"/><xsl:text>_put(){&#10;</xsl:text>
        <xsl:text>&#9;printf("Testing put() on </xsl:text><xsl:value-of select="@name"/><xsl:text>\n");&#10;</xsl:text>
	<xsl:text>&#9;IDS imas = IDS(  TEST_SHOT, TEST_RUN, -1, -1);&#10;</xsl:text>
        <xsl:text>&#9;srand(randseed);&#10;</xsl:text>
        <xsl:text>&#9;imas.create();&#10;</xsl:text>
        <xsl:text>&#9;IDS::</xsl:text><xsl:value-of select="@name"/><xsl:text> ids = imas._</xsl:text><xsl:value-of select="@name"/><xsl:text>;&#10;</xsl:text>
     <!--   <xsl:text>&#9;for (int occurrence = 0; occurrence &lt; </xsl:text><xsl:value-of select="@maxoccur"/><xsl:text> + 1; occurrence++) {&#10;</xsl:text>
     -->  
	<xsl:apply-templates select="field" mode="put">
                  	<xsl:with-param name="dynamicOnly" select="false()"/>
			<xsl:with-param name="staticOnly" select="false()"/>
                </xsl:apply-templates>
       <xsl:text>&#9;&#9;ids.put(0);&#10;</xsl:text>
<!--	 <xsl:text>&#9;&#9;ids.put(occurrence);&#10;</xsl:text>
   -     <xsl:text>&#9;}&#10;</xsl:text>
    
   -->   
 <xsl:text>&#9;imas.close();&#10;</xsl:text>
<xsl:text>}&#10;</xsl:text>
       <xsl:text>&#10;</xsl:text>
    </xsl:template>


    <!-- IDS putSlice()-->
    <xsl:template match="IDS" mode="putSlice">
        <xsl:text>!====================================================================================&#10;</xsl:text>
        <xsl:text>!&#9;&#9; PUT SLICE </xsl:text><xsl:value-of select="@name"/> <xsl:text> &#10;</xsl:text>
        <xsl:text>!====================================================================================&#10;</xsl:text>
        <xsl:text>void </xsl:text><xsl:value-of select="@name"/><xsl:text>_putSlice() {&#10;</xsl:text>
        <xsl:text>&#9;printf("Testing putSlice() on </xsl:text><xsl:value-of select="@name"/><xsl:text>\n");&#10;</xsl:text>
        <xsl:text>&#9;srand(randseed);&#10;</xsl:text>

	<xsl:text>&#9;IDS imas = IDS(  TEST_SHOT, TEST_RUN, -1, -1);&#10;</xsl:text>
        <xsl:text>&#9;imas.create();&#10;</xsl:text>
       	<xsl:text>&#9;IDS::</xsl:text><xsl:value-of select="@name"/><xsl:text> ids = imas._</xsl:text><xsl:value-of select="@name"/><xsl:text>;&#10;</xsl:text>
     <!--   <xsl:text>&#9;for (int occurrence = 0; occurrence &lt; </xsl:text><xsl:value-of select="@maxoccur"/><xsl:text> + 1; occurrence++) {&#10;</xsl:text>
	<xsl:text>&#9;&#9;&#9;printf(" --- Testing occurrence : %d\n", i);&#10;</xsl:text>
     -->  
	

<xsl:text>&#9;&#9;for (int j = 0; j &lt; noOfSlices; j++) { &#10;</xsl:text>
 	<xsl:text>&#9;&#9;{&#10;</xsl:text>
	<xsl:text>&#9;&#9;&#9;printf(" --- --- Testing slice : %d\n", j);&#10;</xsl:text>
	<xsl:text>&#9;&#9;&#9;if (j == 1) &#10;</xsl:text>
	<xsl:text>&#9;&#9;&#9;{&#10;</xsl:text>
		<xsl:text>&#9;&#9;&#9;if (j == 1) then &#10;</xsl:text>
		<xsl:text>&#9;&#9;&#9;&#9;</xsl:text><xsl:value-of select="@name"/><xsl:text>_setNonTimed();&#10;</xsl:text> 
       		<xsl:text>&#9;&#9;&#9;&#9;</xsl:text><xsl:value-of select="@name"/><xsl:text>_setTimed(j);&#10;</xsl:text> 
        	<xsl:text>&#9;&#9;&#9;&#9;ids.put(0);&#10;</xsl:text>
		<xsl:text>&#9;&#9;else&#10;</xsl:text>
		<xsl:text>&#9;&#9;{&#10;</xsl:text>
       		<xsl:text>&#9;&#9;&#9;&#9;</xsl:text><xsl:value-of select="@name"/><xsl:text>_setTimed(j);&#10;</xsl:text> 
		<xsl:text>&#9;&#9;&#9;&#9;ids.putSlice(0);&#10;</xsl:text>
		<xsl:text>&#9;&#9;}&#10;</xsl:text>

	 <xsl:text>&#9;&#9;&#9;//call ids_deallocate(ids)&#10;</xsl:text>
	  <xsl:text>&#9;&#9;&#9;}&#10;</xsl:text>
     <xsl:text>&#9;imas.close();&#10;</xsl:text>
        <xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    

    <!-- IDS get()-->

    <xsl:template match="IDS" mode="get">
        <xsl:text>!====================================================================================&#10;</xsl:text>
        <xsl:text>!&#9;&#9; GET </xsl:text><xsl:value-of select="@name"/> <xsl:text> &#10;</xsl:text>
        <xsl:text>!====================================================================================&#10;</xsl:text>
        <xsl:text>void </xsl:text><xsl:value-of select="@name"/><xsl:text>_get() {&#10;</xsl:text>
        <xsl:text>&#9;printf("Testing get() on </xsl:text><xsl:value-of select="@name"/><xsl:text>\n");&#10;</xsl:text>
        <xsl:text>&#9;int status = 0;&#10;</xsl:text>
	<xsl:text>&#9;IDS imas = IDS(  TEST_SHOT, TEST_RUN, -1, -1);&#10;</xsl:text>
        <xsl:text>&#9;srand(randseed);&#10;</xsl:text>
        <xsl:text>&#9;imas.open();&#10;</xsl:text>
        <xsl:text>&#9;IDS::</xsl:text><xsl:value-of select="@name"/><xsl:text> ids = imas._</xsl:text><xsl:value-of select="@name"/><xsl:text>;&#10;</xsl:text>
 <!--       <xsl:text>&#9;for (int occurrence = 0; occurrence &lt; </xsl:text><xsl:value-of select="@maxoccur"/><xsl:text> + 1; occurrence++) {&#10;</xsl:text>
   	<xsl:text>&#9;&#9;ids.get(occurrence);&#10;</xsl:text>
-->
	<xsl:text>&#9;&#9;ids.get(0);&#10;</xsl:text>
   	       	<xsl:apply-templates select="field" mode="get">
                  	<xsl:with-param name="dynamicOnly" select="false()"/>
			<xsl:with-param name="staticOnly" select="false()"/>
                </xsl:apply-templates>
    
<!--      <xsl:text>&#9;}&#10;</xsl:text>
   
    -->    
  <xsl:text>&#9;imas.close();&#10;</xsl:text>
	<xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>


   <!-- IDS getSlice()-->
    <xsl:template match="IDS" mode="getSlice">
        <xsl:text>void </xsl:text><xsl:value-of select="@name"/><xsl:text>_getSlice()  {&#10;</xsl:text>
        <xsl:text>!====================================================================================&#10;</xsl:text>
        <xsl:text>!&#9;&#9; GET SLICE </xsl:text><xsl:value-of select="@name"/> <xsl:text> &#10;</xsl:text>
        <xsl:text>!====================================================================================&#10;</xsl:text>
        <xsl:text>&#9;printf("Testing getSlice() on </xsl:text><xsl:value-of select="@name"/><xsl:text>\n");&#10;</xsl:text>
        <xsl:text>&#9;int status = 0;&#10;</xsl:text>
	<xsl:text>&#9;IDS imas = IDS(  TEST_SHOT, TEST_RUN, -1, -1);&#10;</xsl:text>
        <xsl:text>&#9;srand(randseed);&#10;</xsl:text>
        <xsl:text>&#9;imas.open();&#10;</xsl:text>
        <xsl:text>&#9;IDS::</xsl:text><xsl:value-of select="@name"/><xsl:text> ids = imas._</xsl:text><xsl:value-of select="@name"/><xsl:text>;&#10;</xsl:text>
   <!--     <xsl:text>&#9;for (int occurrence = 0; occurrence &lt; </xsl:text><xsl:value-of select="@maxoccur"/><xsl:text> + 1; occurrence++) {&#10;</xsl:text>
-->	
	<!--<xsl:apply-templates select="field" mode="getSlice"/> 

        -->
	<xsl:text>&#9;&#9;for (int j = 0; j &lt; noOfSlices ; j++) {&#10;</xsl:text>
	<xsl:text>&#9;&#9;{&#10;</xsl:text>
 	<xsl:text>&#9;&#9;&#9;printf(" --- --- Testing slice : %d\n", j);&#10;</xsl:text>


	<xsl:text>&#9;&#9;&#9;ids.getSlice(0, getTimeScalar(j), CLOSEST_SAMPLE);&#10;</xsl:text> 

	<xsl:text>&#9;&#9;&#9;if (j == 1)&#10;</xsl:text>
	<xsl:text>&#9;&#9;&#9;{&#10;</xsl:text>
	<xsl:text>  &#10;</xsl:text>
	<xsl:text>&#9;&#9;&#9;// ======================== GET STATIC DATA (ONCE) =====================  &#10;</xsl:text>
	<xsl:apply-templates select="field" mode="getSlice">
                  	<xsl:with-param name="dynamicOnly" select="false()"/>
			<xsl:with-param name="staticOnly" select="true()"/>
                </xsl:apply-templates>

	<xsl:text>&#9;&#9;&#9;// ======================== GET STATIC DATA (ONCE) =====================  &#10;</xsl:text>

	<xsl:text>&#9;&#9;&#9;}&#10;</xsl:text>
	<xsl:text>&#9;&#9;// ======================== GET DYNAMIC DATA (LOOP) =====================  &#10;</xsl:text>
  		<xsl:apply-templates select="field" mode="getSlice">
                  	<xsl:with-param name="dynamicOnly" select="true()"/>
			<xsl:with-param name="staticOnly" select="false()"/>
                </xsl:apply-templates>
	<xsl:text>&#9;&#9;// ======================== GET DYNAMIC DATA (LOOP) =====================  &#10;</xsl:text>
		 <!-- <xsl:text>&#9;call ids_deallocate(ids)&#10;</xsl:text> -->
  	<xsl:text>&#9;&#9;&#9;}&#10;</xsl:text>
	    <!--      <xsl:text>&#9;}&#10;</xsl:text>
     --> 
        <xsl:text>&#9;&#10;</xsl:text>
 	<xsl:text>&#9;imas.close();&#10;</xsl:text> 
	<xsl:text>}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    

 
  <xsl:template match="field" mode="putDynamic">



	<xsl:if test="@type ='dynamic' or @data_type='structure' or @data_type='struct_array'"> <!-- This skips the routine for non timed fields -->
	<xsl:text>&#10;&#9;&#9;&#9;//// </xsl:text><xsl:value-of select="@name"/> : <xsl:value-of select="@path"/> : <xsl:value-of select="@data_type"/> : :<xsl:value-of select="@type"/>:<xsl:text>&#10;</xsl:text>
		<xsl:apply-templates select="." mode="put">
                	<xsl:with-param name="dynamicOnly" select="true()"/>
			<xsl:with-param name="staticOnly" select="false()"/>
                </xsl:apply-templates>
	</xsl:if>
    </xsl:template>


 <xsl:template match="field" mode="putStatic">

<xsl:if test="@type !='dynamic' or not(@type) or @data_type='structure' or (@data_type='struct_array' and @type !='dynamic')"> <!-- This skips the routine for timed fields when using this template in PUT_NON_TIMED mode -->

	<xsl:text>&#10;&#9;&#9;&#9;///STATIC!! </xsl:text><xsl:value-of select="@name"/> : <xsl:value-of select="@path"/> : <xsl:value-of select="@data_type"/> : :<xsl:value-of select="@type"/>:<xsl:text>&#10;</xsl:text>


		<xsl:apply-templates select="." mode="put">
                  	<xsl:with-param name="dynamicOnly" select="false()"/>
			<xsl:with-param name="staticOnly" select="true()"/>
                </xsl:apply-templates>
	</xsl:if>
    </xsl:template>

    <!-- field put() -->
    <xsl:template match="field[not(@data_type='structure' or @data_type='struct_array')]" mode="put">
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>

	<xsl:call-template name="COMMENT_FIELD"/>
        <xsl:call-template name="setValue">
          <xsl:with-param name="path" select="translate(@path, '/', '.')"/>
		<xsl:with-param name="slice" select="false()"/>
	    	<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
   	    	<xsl:with-param name="staticOnly" select="$staticOnly"/>

	</xsl:call-template>
    </xsl:template>

    <!-- field putSlice() -->
    <xsl:template match="field[not(@data_type='structure' or @data_type='struct_array')]" mode="putSlice">
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
	<xsl:call-template name="COMMENT_FIELD"/>
        <xsl:call-template name="setValue">
          <xsl:with-param name="path" select="translate(@path, '/', '.')"/>
		<xsl:with-param name="slice" select="true()"/>
	    	<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
   	    	<xsl:with-param name="staticOnly" select="$staticOnly"/>

	</xsl:call-template>
    </xsl:template>

    <!-- field put() for array of structures -->
    <xsl:template match="field[@data_type='struct_array']" mode="put">
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
		<xsl:call-template name="COMMENT_FIELD"/>
      <xsl:call-template name="putStructArray">
            <xsl:with-param name="path" select="concat(translate(@path, '/', '.'), '(0)')"/>
	<xsl:with-param name="slice" select="false()"/>
	    	<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
   	    	<xsl:with-param name="staticOnly" select="$staticOnly"/>
        </xsl:call-template>
   </xsl:template>

  <!-- field put() for array of structures -->
    <xsl:template match="field[@data_type='structure']" mode="put">
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
		<xsl:call-template name="COMMENT_FIELD"/>
      <xsl:call-template name="putStructArray">
            <xsl:with-param name="path" select="translate(@path, '/', '.')"/>
	<xsl:with-param name="slice" select="false()"/>
	    	<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
   	    	<xsl:with-param name="staticOnly" select="$staticOnly"/>
        </xsl:call-template>
   </xsl:template>
  

    <!-- field put() for array of structures -->
    <xsl:template match="field[@data_type='struct_array']" mode="putSlice">
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
		<xsl:call-template name="COMMENT_FIELD"/>
      <xsl:call-template name="putStructArray">
            <xsl:with-param name="path" select="concat(translate(@path, '/', '.'), '(0)')"/>
	<xsl:with-param name="slice" select="true()"/>
	    	<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
   	    	<xsl:with-param name="staticOnly" select="$staticOnly"/>
        </xsl:call-template>
    </xsl:template>

  <!-- field put() for array of structures -->
    <xsl:template match="field[@data_type='structure']" mode="putSlice">
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
		<xsl:call-template name="COMMENT_FIELD"/>
      <xsl:call-template name="putStructArray">
            <xsl:with-param name="path" select="translate(@path, '/', '.')"/>
	<xsl:with-param name="slice" select="true()"/>
	    	<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
   	    	<xsl:with-param name="staticOnly" select="$staticOnly"/>
        </xsl:call-template>
   </xsl:template>


    <xsl:template name="putStructArray">
        <xsl:param name="path"/>
	<xsl:param name="slice"/>
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>


 	<xsl:if test="@data_type='struct_array'">
	<xsl:if test="(not($dynamicOnly) and ( (@type !='dynamic' or not(@type)) and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])))
	or
	(not($staticOnly) and (@type='dynamic' or ancestor::field[@type='dynamic' and @data_type='struct_array']))"> 
	<xsl:text>&#9;&#9;if(ids.</xsl:text><xsl:value-of select="substring($path, 1, string-length($path) - 3)"/><xsl:text>.extent(0) &gt; 0) then&#10;</xsl:text>
		<xsl:text>&#9;&#9;&#9;ids.</xsl:text><xsl:value-of select="substring($path, 1, string-length($path) - 3)"/><xsl:text>.resize(1);&#10;</xsl:text>
	</xsl:if>
	</xsl:if>
        <xsl:for-each select="field[not(@data_type='struct_array' or @data_type='structure')]">
		<xsl:call-template name="COMMENT_FIELD"/>
	     	<xsl:call-template name="setValue">
        		<xsl:with-param name="path" select="concat($path, '.', @name)"/>
			<xsl:with-param name="slice" select="$slice"/>
			<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
			<xsl:with-param name="staticOnly" select="$staticOnly"/>
		</xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="field[@data_type='structure']">
	  <xsl:call-template name="COMMENT_FIELD"/>
	  <xsl:call-template name="putStructArray">
                <xsl:with-param name="path" select="concat($path, '.', @name)"/>
		<xsl:with-param name="slice" select="$slice"/>
		<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
		<xsl:with-param name="staticOnly" select="$staticOnly"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="field[@data_type='struct_array']">
	    <xsl:call-template name="COMMENT_FIELD"/>
            <xsl:call-template name="putStructArray">
                <xsl:with-param name="path" select="concat($path, '.', @name, '(0)')"/>
		<xsl:with-param name="slice" select="$slice"/>
		<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
		<xsl:with-param name="staticOnly" select="$staticOnly"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template> 


    <!-- field get() -->
    <xsl:template match="field[not(@data_type='structure' or @data_type='struct_array')]" mode="get">
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
	<xsl:call-template name="COMMENT_FIELD"/>
		<xsl:call-template name="COMMENT_FIELD"/>
	     	<xsl:call-template name="setValue">
        		<xsl:with-param name="path" select="translate(@path, '/', '.')"/>
			<xsl:with-param name="slice" select="false()"/>
			<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
			<xsl:with-param name="staticOnly" select="$staticOnly"/>
		</xsl:call-template>
    </xsl:template>


    <!-- field get() for array of structures -->
    <xsl:template match="field[@data_type='struct_array']" mode="get">
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
	<xsl:call-template name="COMMENT_FIELD"/>
       <xsl:call-template name="getStructArray">
            <xsl:with-param name="path" select="concat(translate(@path, '/', '.'), '(0)')"/>
	     <xsl:with-param name="slice" select="false()"/>
	    	<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
   	    	<xsl:with-param name="staticOnly" select="$staticOnly"/>
        </xsl:call-template>
  </xsl:template>

    <xsl:template match="field[@data_type='structure']" mode="get">
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
	<xsl:call-template name="COMMENT_FIELD"/>
       <xsl:call-template name="getStructArray">
            <xsl:with-param name="path" select="translate(@path, '/', '.')"/>
	     <xsl:with-param name="slice" select="false()"/>
	    	<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
   	    	<xsl:with-param name="staticOnly" select="$staticOnly"/>
        </xsl:call-template>
  </xsl:template>

    <!-- field getSlice() -->
    <xsl:template match="field[not(@data_type='structure' or @data_type='struct_array')]" mode="getSlice">
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
   <xsl:call-template name="COMMENT_FIELD"/>
		<xsl:call-template name="COMMENT_FIELD"/>
	     	<xsl:call-template name="getValue">
       			<xsl:with-param name="path" select="translate(@path, '/', '.')"/>
			<xsl:with-param name="slice" select="true()"/>
			<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
			<xsl:with-param name="staticOnly" select="$staticOnly"/>
		</xsl:call-template>
    </xsl:template>

        

    <!-- field get() for array of structures -->
    <xsl:template match="field[@data_type='struct_array']" mode="getSlice">
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
	<xsl:call-template name="COMMENT_FIELD"/>
      <xsl:call-template name="getStructArray">
            <xsl:with-param name="path" select="concat(translate(@path, '/', '.'), '(0)')"/>
	     <xsl:with-param name="slice" select="true()"/>
	    	<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
   	    	<xsl:with-param name="staticOnly" select="$staticOnly"/>
        </xsl:call-template>
    </xsl:template>

    <!-- field get() for array of structures -->
    <xsl:template match="field[@data_type='structure']" mode="getSlice">
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
	<xsl:call-template name="COMMENT_FIELD"/>
      <xsl:call-template name="getStructArray">
            <xsl:with-param name="path" select="translate(@path, '/', '.')"/>
	     <xsl:with-param name="slice" select="true()"/>
	    	<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
   	    	<xsl:with-param name="staticOnly" select="$staticOnly"/>
        </xsl:call-template>
    </xsl:template>
    


    <xsl:template name="getStructArray">
        <xsl:param name="path"/>
	<xsl:param name="slice"/>
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
        <xsl:for-each select="field[not(@data_type='struct_array' or @data_type='structure')]">
		<xsl:call-template name="COMMENT_FIELD"/>
	     	<xsl:call-template name="getValue">
        		<xsl:with-param name="path" select="concat($path, '.', @name)"/>
			<xsl:with-param name="slice" select="$slice"/>
			<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
			<xsl:with-param name="staticOnly" select="$staticOnly"/>
		</xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="field[@data_type='structure']">
   		<xsl:call-template name="COMMENT_FIELD"/>
		<xsl:call-template name="getStructArray">
                	<xsl:with-param name="path" select="concat($path, '.', @name)"/>
		   	<xsl:with-param name="slice" select="$slice"/>
		<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
		<xsl:with-param name="staticOnly" select="$staticOnly"/>
            	</xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="field[@data_type='struct_array']">
      		<xsl:call-template name="COMMENT_FIELD"/>
            <xsl:call-template name="getStructArray">
                <xsl:with-param name="path" select="concat($path, '.', @name, '(0)')"/>
		 <xsl:with-param name="slice" select="$slice"/>
		<xsl:with-param name="dynamicOnly" select="$dynamicOnly"/>
		<xsl:with-param name="staticOnly" select="$staticOnly"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
   <xsl:template name="getValue">
        <xsl:param name="path"/>
	<xsl:param name="slice"/>
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
	
	<xsl:if test="(not($dynamicOnly) and ( (@type !='dynamic' or not(@type)) and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])))
	or
	(not($staticOnly) and (@type='dynamic' or ancestor::field[@type='dynamic' and @data_type='struct_array']))"> 

	<xsl:choose>
		<xsl:when test="@name='homogeneous_time'">
			<xsl:text>&#9;&#9;// NOT TESTED: ids.</xsl:text><xsl:value-of select="@path"/><xsl:text> = 1;&#10;</xsl:text>
		</xsl:when>
		<xsl:when test="@name='time' and @type='dynamic' and (@data_type='flt_1d_type' or @data_type='FLT_1D') ">
			<xsl:choose>
				<xsl:when test="$slice and @type='dynamic' and not(ancestor::field[@data_type='struct_array' and @maxoccur='unbounded'])  ">
      					<xsl:text>&#9;&#9;status = assertTime(ids.</xsl:text><xsl:value-of select="$path"/><xsl:text>, true);&#10;</xsl:text>
					<xsl:text>&#9;&#9;checkStatus(status);&#10;</xsl:text>
        			</xsl:when>
	        		<xsl:otherwise>
					<xsl:text>&#9;&#9;status = assertTime(ids.</xsl:text><xsl:value-of select="$path"/><xsl:text>, false);&#10;</xsl:text>
					<xsl:text>&#9;&#9;checkStatus(status);&#10;</xsl:text>
     	        		</xsl:otherwise>
            		</xsl:choose>
		</xsl:when>

  		<xsl:otherwise>
 			<xsl:choose>
	   			<xsl:when test="$slice and @type='dynamic' and not(ancestor::field[@data_type='struct_array' and @maxoccur='unbounded'])  ">
					<xsl:text>&#9;&#9;status = assertField(ids.</xsl:text><xsl:value-of select="$path"/><xsl:text>, "</xsl:text><xsl:value-of select="ancestor::IDS/@name"/><xsl:text>/</xsl:text><xsl:value-of select="@path"/><xsl:text>", true);&#10;</xsl:text>
					<xsl:text>&#9;&#9;checkStatus(status);&#10;</xsl:text>
        			</xsl:when>
	        		<xsl:otherwise>
					<xsl:text>&#9;&#9;status = assertField(ids.</xsl:text><xsl:value-of select="$path"/><xsl:text>, "</xsl:text><xsl:value-of select="ancestor::IDS/@name"/><xsl:text>/</xsl:text><xsl:value-of select="@path"/><xsl:text>", false);&#10;</xsl:text>
					<xsl:text>&#9;&#9;checkStatus(status);&#10;</xsl:text>
     	        		</xsl:otherwise>
            		</xsl:choose>

         
		</xsl:otherwise>
    	</xsl:choose>
  </xsl:if>
   </xsl:template>



   <xsl:template name="setValue">
        <xsl:param name="path"/>
	<xsl:param name="slice"/>
	<xsl:param name="dynamicOnly"/>
	<xsl:param name="staticOnly"/>
	
	<xsl:if test="(not($dynamicOnly) and ( (@type !='dynamic' or not(@type)) and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])))
	or
	(not($staticOnly) and (@type='dynamic' or ancestor::field[@type='dynamic' and @data_type='struct_array']))"> 

	<xsl:choose>
		<xsl:when test="@name='homogeneous_time'">
			<xsl:text>&#9;&#9;ids.</xsl:text><xsl:value-of select="$path"/><xsl:text> = 1;&#10;</xsl:text>
		</xsl:when>
		<xsl:when test="@name='time' and @type='dynamic' and (@data_type='flt_1d_type' or @data_type='FLT_1D') ">
			<xsl:choose>
				<xsl:when test="$slice and @type='dynamic' and not(ancestor::field[@data_type='struct_array' and @maxoccur='unbounded'])  ">
      					<xsl:text>&#9;&#9;setTime(ids.</xsl:text><xsl:value-of select="$path"/><xsl:text>, true);&#10;</xsl:text>
        			</xsl:when>
	        		<xsl:otherwise>
					<xsl:text>&#9;&#9;setTime(ids.</xsl:text><xsl:value-of select="$path"/><xsl:text>, false);&#10;</xsl:text>
     	        		</xsl:otherwise>
            		</xsl:choose>
		</xsl:when>

  		<xsl:otherwise>
 			<xsl:choose>
				<xsl:when test="$slice and @type='dynamic' and not(ancestor::field[@data_type='struct_array' and @maxoccur='unbounded'])  ">
      					<xsl:text>&#9;&#9;setValue(ids.</xsl:text><xsl:value-of select="$path"/><xsl:text>, true);&#10;</xsl:text>
        			</xsl:when>
	        		<xsl:otherwise>
					<xsl:text>&#9;&#9;setValue(ids.</xsl:text><xsl:value-of select="$path"/><xsl:text>, false);&#10;</xsl:text>
     	        		</xsl:otherwise>
            		</xsl:choose>
		</xsl:otherwise>
    	</xsl:choose>
  </xsl:if>
   </xsl:template>
<!--
            <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">         <xsl:text>&#9;&#9;ids.</xsl:text><xsl:value-of select="$path"/><xsl:text> = getString(</xsl:text></xsl:when>
            <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">    <xsl:text>new Vect1DString((String[]) getArray(Types.STRING, 1))</xsl:text></xsl:when>

            <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">          <xsl:text>&#9;&#9;ids.</xsl:text><xsl:value-of select="$path"/><xsl:text> = getDouble(</xsl:text></xsl:when>
            <xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">      <xsl:text>&#9;&#9;setArray(ids.</xsl:text><xsl:value-of select="$path"/><xsl:text>,3</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_2D'">     <xsl:text>new Vect2DDouble(1, 2, (double[]) getArray(Types.DOUBLE, 2))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_3D'">   <xsl:text>new Vect3DDouble(1, 1, 3, (double[]) getArray(Types.DOUBLE, 3))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_4D'">   <xsl:text>new Vect4DDouble(1, 1, 1, 4, (double[]) getArray(Types.DOUBLE, 4))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_5D'">   <xsl:text>new Vect5DDouble(1, 1, 1, 1, 5, (double[]) getArray(Types.DOUBLE, 5))</xsl:text></xsl:when>
            <xsl:when test="@data_type='FLT_6D'">	<xsl:text>new Vect6DDouble(1, 1, 1, 1, 1, 6, (double[]) getArray(Types.DOUBLE, 6))</xsl:text></xsl:when>

            <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">      <xsl:text>&#9;&#9;ids.</xsl:text><xsl:value-of select="$path"/><xsl:text> = getInteger(</xsl:text></xsl:when>
            <xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">      <xsl:text>&#9;&#9;setArray(ids.</xsl:text><xsl:value-of select="$path"/><xsl:text>,3</xsl:text></xsl:when>
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
     <xsl:choose>
 <xsl:when test="$slice and @type='dynamic' and not(ancestor::field[@data_type='struct_array' and @maxoccur='unbounded'])  ">
      		  <xsl:text>, true);</xsl:text>
        	</xsl:when>
	        <xsl:otherwise>
			  <xsl:text>, false);</xsl:text>
     	        </xsl:otherwise>
            </xsl:choose>
	<xsl:text>&#9;&#9;</xsl:text>
   

	<xsl:text>&#10;</xsl:text>
    </xsl:template>
-->
        <!--Documentation for a single field-->
    <xsl:template name = "COMMENT_FIELD">
        <xsl:text>&#xA;</xsl:text>
 	<xsl:choose>
 	<xsl:when test="@data_type='struct_array' or @data_type='structure'">
		<xsl:text>&#009;&#009;//-----------------------------------------------------------------------------------------#&#xA;</xsl:text>
		<xsl:if test="@data_type='structure'">
			<xsl:text>&#009;&#009;//  STRUCTURE &#xA;</xsl:text>
	 	</xsl:if>
		<xsl:if test="@type='dynamic' and @maxoccur='unbounded' and @data_type='struct_array'">
			<xsl:text>&#009;&#009;//  ARRAY of TYPE 3 &#xA;</xsl:text>
	 	</xsl:if>
    	 	<xsl:if test="(not(@type) or @type!='dynamic') and @maxoccur='unbounded' and @data_type='struct_array'">
			<xsl:text>&#009;&#009;//  ARRAY of TYPE 2 &#xA;</xsl:text>
	  	</xsl:if>

		<xsl:if test="@maxoccur!='unbounded' and @data_type='struct_array'">
			<xsl:text>&#009;&#009;//  ARRAY of TYPE 1 &#xA;</xsl:text>
		</xsl:if>
		<xsl:text>&#009;&#009;//  </xsl:text><xsl:value-of select="@name"/>:<xsl:value-of select="@path"/>:<xsl:value-of select="@data_type"/>:<xsl:value-of select="@type"/>:<xsl:text>&#xA;</xsl:text>
		<xsl:text>&#009;&#009;//-----------------------------------------------------------------------------------------#&#xA;</xsl:text>
	</xsl:when>
	<xsl:otherwise>
		<xsl:text>&#009;&#009;//  </xsl:text><xsl:value-of select="@name"/>:<xsl:value-of select="@path"/>:<xsl:value-of select="@data_type"/>:<xsl:value-of select="@type"/>:<xsl:text>&#xA;</xsl:text>
	</xsl:otherwise>
 </xsl:choose>
    </xsl:template>
   


    
</xsl:stylesheet>