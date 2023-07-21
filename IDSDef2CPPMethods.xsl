<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating  C++ access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"  version="2.0" extension-element-prefixes="yaslt">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>



<xsl:param name="DD_GIT_DESCRIBE" as="xs:string" required="yes"/>
<xsl:param name="UAL_GIT_DESCRIBE" as="xs:string" required="yes"/>

<xsl:template match="/IDSs">
<xsl:result-document href="src/UALMethods.cpp" standalone="yes" method="text">

#include "UALClasses.h"

using namespace IdsNs;
<!--
#define NON_TIMED    0
#define TIMED       1
#define TIMED_CLEAR 2
/*#define DEBUG*/


#ifdef DEBUG
void checkStatus(int status) {if(status) printf("%s\n", // imas_last_errmsg());}
#else
void checkStatus(int status){}
#endif
-->

IdsNs::IDS::IDS()
{
	treeName = "ids";
	connected = false;
	shot = refShot = run = refRun = -1;
	backend = defaultBackend();
}

IdsNs::IDS::IDS(int shot, int run, int refShot, int refRun)
{
	treeName = "ids";
	connected = false;
	this-&gt; shot = shot;
	this-&gt;run = run;
	this-&gt;refShot = refShot;
	this-&gt;refRun = refRun;
	pulseCtx = -1;
	backend = defaultBackend();
}
IdsNs::IDS::IDS(int pulseCtx)
{
	treeName = "ids";
	connected = true;
//this-&gt; shot = ual_get_shot(idx);
//this-&gt;run = ual_get_run(idx);
//this-&gt;refShot =  ual_get_shot(idx);
//this-&gt;refRun = ual_get_run(idx);
	this->pulseCtx = pulseCtx;
	this->setPulseCtx(pulseCtx);
	int defbackend;
	ual_get_backendID(pulseCtx,&amp;defbackend);
	backend = static_cast&lt;BACKEND&gt;(defbackend);
}

BACKEND IdsNs::IDS::defaultBackend() 
{
   BACKEND backend = MDSPLUS_BACKEND;
   char* backend_value;
   backend_value = getenv("IMAS_AL_DEFAULT_BACKEND");
   if (backend_value != NULL) {
      int backendID = atoi(backend_value);
      backend = static_cast&lt;BACKEND&gt;(backendID);
   }
   return backend;
}

BACKEND IdsNs::IDS::fallbackBackend() 
{
   BACKEND backend = NO_BACKEND;
   char* backend_value;
   backend_value = getenv("IMAS_AL_FALLBACK_BACKEND");
   if (backend_value != NULL) {
      int backendID = atoi(backend_value);
      backend = static_cast&lt;BACKEND&gt;(backendID);
   }
   return backend;
}

// Will be deprecated in the future!
void IdsNs::IDS::setExpIdx(int pulseCtx) 
{
    this->setPulseCtx(pulseCtx);
}

void IdsNs::IDS::setPulseCtx(int pulseCtx)
{
    this->pulseCtx = pulseCtx;
<xsl:apply-templates select="IDS" mode="SET_PULSE_CTX"/>
}

// Will be deprecated in the future!
int IdsNs::IDS::getIdx() 
{
    return this->getPulseCtx();
}

int IdsNs::IDS::open(const char *uri, int mode)
{
    int pulseCtx;
    al_status_t al_status;

    al_status = ual_begin_dataentry_action(uri, mode, &amp;pulseCtx);
    if (al_status.code &lt; 0)
    {
    printf("Error opening URI %s\n%s\n", "ual_begin_dataentry_action", al_status.message);
    return al_status.code;
    }

    this->pulseCtx = pulseCtx;
    this->connected = true;
    this->setPulseCtx(pulseCtx);
}

int IdsNs::IDS::openEnv(const char *user, const char *tokamak, const char *version, const char *option/* = nullptr*/)
{
    int pulseCtx;
    al_status_t al_status;
    char* uri;
    al_status = ual_build_uri_from_legacy_parameters(this->backend, this->shot, this->run, user, tokamak, version, option, &amp;uri);
    if (al_status.code != 0)
    {
        printf("Error building URI %s\n%s\n", "ual_build_uri_from_legacy_parameters", al_status.message);
    	return al_status.code;
    }
    al_status = ual_begin_dataentry_action(uri, OPEN_PULSE, &amp;pulseCtx);
    if (al_status.code != 0)
    {
        BACKEND fallback = this->fallbackBackend();
	if (fallback != NO_BACKEND)
  	{
	    printf("WARNING: the pulse file is not available with backend %d, now attempting to access it with the fallback backend %d\n",this->backend,fallback);
	    this->backend = fallback;
	    al_status = ual_build_uri_from_legacy_parameters(this->backend, this->shot, this->run, user, tokamak, version, option, &amp;uri);
	    if (al_status.code != 0)
	    {
                printf("Error building URI %s\n%s\n", "ual_build_uri_from_legacy_parameters", al_status.message);
    		return al_status.code;
	    }
	    al_status = ual_begin_dataentry_action(uri, OPEN_PULSE, &amp;pulseCtx);
	}
	if (al_status.code != 0)
	{
            printf("Error opening imas shot %d, run %d: %s\n%s\n", shot, run, "ual_begin_dataentry_action", al_status.message);
	    return al_status.code;
	}
    }
    this->pulseCtx = pulseCtx;
    this->connected = true;
    this->setPulseCtx(pulseCtx);
    return al_status.code;
}

int IdsNs::IDS::createEnv(const char *user, const char *tokamak, const char *version, const char *option/* = nullptr*/)
{
	int pulseCtx = -1;
	al_status_t al_status;

    char* uri;
    al_status = ual_build_uri_from_legacy_parameters(this->backend, this->shot, this->run, user, tokamak, version, option, &amp;uri);
	if (al_status.code &lt; 0)
	{
		printf("Error building URI %s\n%s\n", "ual_build_uri_from_legacy_parameters", al_status.message);
    	return al_status.code;
	}
    al_status = ual_begin_dataentry_action(uri, FORCE_CREATE_PULSE, &amp;pulseCtx);
    if (al_status.code &lt; 0)
	{
    printf("Error opening imas shot %d, run %d: %s\n%s\n", shot, run, "ual_begin_dataentry_action", al_status.message);
        return al_status.code;
	}

	this->pulseCtx = pulseCtx;
	this->connected = true;
	this->setPulseCtx(pulseCtx);
	return al_status.code;
}

int IdsNs::IDS::close()
{
  	al_status_t al_status = ual_close_pulse(this->pulseCtx, CLOSE_PULSE);
    if(al_status.code != 0)
	{
		printf("Error opening imas shot %d, run %d: %s\n %s\n", shot, run, "ual_close_pulse", al_status.message);
        return al_status.code;
	}
    ual_end_action(this->pulseCtx);
    return 0;
}



int IdsNs::IDS::getTime(char *path, IMASArray&lt;double,1&gt; &amp;time)
{
int retSamples;
double *doubleArray;
int dim;

if(!connected) return -1;
int status ;//= beginIdsGet(expIdx,path,TIMED,&amp;retSamples);
//checkStatus(status);
if(status) return status;
////status = getVect1DDouble(expIdx, path, "time", &amp;doubleArray, &amp;dim);
//checkStatus(status);
if(!status) {
IMASArray&lt;double,1&gt; newArray(doubleArray, shape(dim), duplicateData, fortranArray);
time.resize(newArray.shape());
time = newArray;
free(doubleArray);
}
////endIdsGet(expIdx, path);
return status;
}

IdsNs::IDS::~IDS()
{
/*if(expIdx != -1)
// imas_close(expIdx);*/
}
<!--
char * str2char(string str)
{
char *cyb;
cyb = new char[512];
strcpy(cyb, str.c_str());
return cyb;
}

string int2str(int i, int j)
{
int r;
r= i+j;
ostringstream convert;   // stream used for the conversion
convert &lt;&lt; r;      // insert the textual representation of 'Number' in the characters in the stream

return(convert.str());
}
-->

 <xsl:apply-templates select="IDS" mode="CLASS_DEFINITION"/> 

ostream &amp;IdsNs::operator &lt;&lt; (ostream &amp;os, const IDS &amp;obj)
{
os &lt;&lt; "TreeName: ";
os &lt;&lt; obj.treeName;
os &lt;&lt; "\nShot: ";
os &lt;&lt;obj.shot;
os &lt;&lt;"\nRun: ";
os &lt;&lt;obj.run;
os &lt;&lt;"\nRef Shot: ";
os &lt;&lt;obj.refShot;
os &lt;&lt;"\nRef Run: ";
os &lt;&lt;obj.refRun;
os &lt;&lt;"\nBackend: ";
os &lt;&lt;obj.backend;
os &lt;&lt;((obj.connected)?"\nConnected":"\nNot Connected");
return os;
}

 </xsl:result-document>
</xsl:template>

        <!--Documentation for a single field-->
    <xsl:template name = "COMMENT_FIELD">
        <xsl:text>&#xA;</xsl:text>
	<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
	<xsl:text>//  </xsl:text><xsl:value-of select="@name"/>:<xsl:value-of select="@path"/>:<xsl:value-of select="@data_type"/>:<xsl:value-of select="@type"/>:<xsl:text>&#xA;</xsl:text>
	<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>

	  <xsl:if test="@type='dynamic' and @maxoccur='unbounded' and @data_type='struct_array'">
		<xsl:text>//  ARRAY of TYPE 3 &#xA;</xsl:text>
		<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>

	  </xsl:if>
     <xsl:if test="(not(@type) or @type!='dynamic') and @maxoccur='unbounded' and @data_type='struct_array'">
		<xsl:text>//  ARRAY of TYPE 2  &#xA;</xsl:text>
		<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>

	  </xsl:if>

	       <xsl:if test="@maxoccur!='unbounded' and @data_type='struct_array'">
		<xsl:text>//  ARRAY of TYPE 1  &#xA;</xsl:text>
		<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>

	  </xsl:if>
    </xsl:template>


<!--=================================================-->
<!--                 set idx in IDS                  -->
<!--=================================================-->

<xsl:template match="IDS" mode="SET_PULSE_CTX">
_<xsl:value-of select="@name"/>.setPulseCtx(pulseCtx);
</xsl:template>

<!--=================================================-->
<!--               print IDS content                 -->
<!--=================================================-->
<!--YBYBDUMP -->
<xsl:template match="IDS" mode="DUMP">
ostream &amp;IdsNs::operator &lt;&lt; (ostream &amp;os, const <xsl:value-of select="@name"/>_IDSBase &amp;obj)
{
<xsl:apply-templates select="field" mode="DUMP">
	<xsl:with-param name="level" select="1"/>
	<xsl:with-param name="idxpath" select="'obj'"/>
</xsl:apply-templates>
return os;
}
</xsl:template>
<!--   -->
<!--=================================================-->
<!--               define IDS content                -->
<!--=================================================-->

<xsl:template match="IDS" mode="CLASS_DEFINITION">
<xsl:result-document href="src/ids/{@name}_IDSBase.cpp" standalone="yes" method="text">
#include "IdsDef.h"
#include "UALDef.h"
#include "<xsl:value-of select="@name"/>_IDSBase.h"

using namespace IdsNs;

IdsNs::<xsl:value-of select="@name"/>_IDSBase::<xsl:value-of select="@name"/>_IDSBase()
{
<xsl:apply-templates select="field" mode="CONSTRUCTOR"/>
}



int IdsNs::<xsl:value-of select="@name"/>_IDSBase::get()
{
	return this->get(0);
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::get(int iOccurrence)
{
        int status = 0;
        al_status_t al_status;
        char *str;
        char *idsName = "<xsl:value-of select="@name"/>";
        std::string idsFullName = std::string(idsName);
        int pulseCtx = this->pulseCtx;
        int getOpCtx = -1;
        int ctx = -1;
        int aosCtx = -1;
        std::string fieldPath;
        std::string timeBasePath;
        int idsTimeMode = IDS_TIME_MODE_UNKNOWN;
        int arraySize;

	if(!connected)
		return -1;
	
	if(iOccurrence &gt;= 1)
        idsFullName += "/" + std::to_string(iOccurrence);

    al_status = IdsNs::Ids::readIdsTimeMode(pulseCtx, idsFullName.c_str(), idsTimeMode );
    if(al_status.code &lt; 0) {
        printf("GET: error reading homogeneous time for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
        return al_status.code;
    }

    //reset the ids content
    clear();

	// Open get context
    al_status = ual_begin_global_action(pulseCtx, idsFullName.c_str(), "", READ_OP, &amp;getOpCtx);

	if(al_status.code &lt; 0) {
        printf("GET: error calling ual_begin_global_action for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
		return al_status.code;
    }

	ctx = getOpCtx;
        al_status = ual_bind_readback_plugins(ctx); //binding readback plugins just before the get() operation
        if(al_status.code &lt; 0) {
            printf("GET: error calling ual_bind_readback_plugins for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
                return al_status.code;
        }
 	<xsl:apply-templates select="field" mode="GET_SINGLE"/>
	al_status = ual_unbind_readback_plugins(ctx); //unbinding readback plugins just after the get() operation
        if(al_status.code &lt; 0) {
            printf("GET: error calling ual_unbind_readback_plugins for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
                return al_status.code;
        } 
	ual_end_action(ctx);
	
	return 0;
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::put()
{
	return this->put(0);
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::put(int iOccurrence)
{
	int status = 0;
	al_status_t al_status;
	char *idsName = "<xsl:value-of select="@name"/>";
    std::string idsFullName = std::string(idsName);
	int pulseCtx = this->pulseCtx;
	int putOpCtx = -1;
	int ctx = -1;
	int aosCtx = -1;
	std::string fieldPath;
	std::string timeBasePath;
	int idsTimeMode = IDS_TIME_MODE_UNKNOWN;
	int arraySize;

	if (!connected)
		return -1;

	idsTimeMode = ids_properties.homogeneous_time;
	if (idsTimeMode == IDS_TIME_MODE_UNKNOWN)
	{
		printf("Warning: IDS <xsl:value-of select="@name"/> is found to be EMPTY (homogeneous_time undefined). PUT quits with no action.");
   		return 0;
	}

    if( idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS &amp;&amp; this->time.size() &lt; 1 )
    {
        printf("ERROR: Time vector of homogeneous IDS '<xsl:value-of select="@name"/>' cannot be EMPTY. ");
        return -1;
    }

	if(iOccurrence &gt;= 1)
        idsFullName += "/" + std::to_string(iOccurrence);
	
	deleteAll(iOccurrence);

	// Open put context
	al_status = ual_begin_global_action(pulseCtx, idsFullName.c_str(), "", WRITE_OP, &amp;putOpCtx);

	if(al_status.code &lt; 0) {
        printf("PUT: error calling ual_begin_global_action for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
        return al_status.code;
    }

	ctx = putOpCtx;

	<xsl:apply-templates select="field" mode="PUT_SINGLE">
		<xsl:with-param name="dynamic_only" select="'no'"/>
	</xsl:apply-templates>

        al_status = ual_write_plugins_metadata(ctx); //writing plugins metadata just after the put() operation
        if(al_status.code &lt; 0) {
        printf("PUT: error calling ual_write_plugins_metadata for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
                return al_status.code;
        }
	ual_end_action(putOpCtx);
	
	return 0;
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::putSlice()
{
	return this->putSlice(0);
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::putSlice(int iOccurrence)
{
    int status = 0;
    al_status_t al_status;
	char *idsName = "<xsl:value-of select="@name"/>";
    std::string idsFullName = std::string(idsName);
	int pulseCtx = this->pulseCtx;
	int putSliceOpCtx = -1;
	int ctx = -1;
	int aosCtx = -1;
	std::string fieldPath;
	std::string timeBasePath;
	int idsTimeMode = IDS_TIME_MODE_UNKNOWN;
	int arraySize;
    int storedTimeMode = IDS_TIME_MODE_UNKNOWN;

	if(!connected)
		return -1;
	
	idsTimeMode = ids_properties.homogeneous_time;
	if (idsTimeMode == IDS_TIME_MODE_UNKNOWN) 
	{
		printf("Warning: IDS <xsl:value-of select="@name"/> is found to be EMPTY (homogeneous_time undefined). PUTSLICE quits with no action.\n");
   		return 0;
	}

    if (idsTimeMode == IDS_TIME_MODE_INDEPENDENT) 
    {
        printf("Warning: IDS '<xsl:value-of select="@name"/>' time mode 'independent'. PUTSLICE quits with no action.\n");
        return 0;
    }

    if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS &amp;&amp;  this->time.size() &lt; 1 )
    {
        printf("ERROR: Time vector of homogeneous IDS '<xsl:value-of select="@name"/>' cannot be EMPTY. \n");
        return -1;
    }

	if(iOccurrence &gt;= 1)
        idsFullName += "/" + std::to_string(iOccurrence);

    /***   Checking homogeneous_time read from file   ***/

    al_status = IdsNs::Ids::readIdsTimeMode(pulseCtx, idsFullName.c_str(), storedTimeMode );
    if(al_status.code &lt; 0)  {
        printf("PUT_SLICE: error reading homogeneous time for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
        return al_status.code;
    }

    // adding slice to an empty IDS
    if( storedTimeMode == IDS_TIME_MODE_UNKNOWN)
    {
        return this->put(iOccurrence);
    }
    else if( storedTimeMode != idsTimeMode)    // time mode conflict
    {
       printf("ERROR! IDS '<xsl:value-of select="@name"/>': time dependency mode ('%s') differs from value stored in IDS ('%s')!\n", IdsNs::Ids::timeModeToString(idsTimeMode ), IdsNs::Ids::timeModeToString(storedTimeMode));
       return -1;
    }


    /***   Put slice   ***/
	// Open put context
	al_status = ual_begin_slice_action(pulseCtx, idsFullName.c_str(), WRITE_OP, UNDEFINED_TIME, UNDEFINED_INTERP, &amp;putSliceOpCtx);
	
	if(al_status.code &lt; 0) {
        printf("PUT_SLICE: error calling ual_begin_slice_action for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
		return al_status.code;
    }

	ctx = putSliceOpCtx;
	
	<xsl:apply-templates select="field" mode="PUT_SINGLE">
		<xsl:with-param name="dynamic_only" select="'yes'"/>
	</xsl:apply-templates>
	
	al_status = ual_write_plugins_metadata(ctx); //writing plugins metadata just after the putSlice() operation
        if(al_status.code &lt; 0) {
        printf("PUT_SLICE: error calling ual_write_plugins_metadata for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
                return al_status.code;
        }
        ual_end_action(putSliceOpCtx);
	return 0;
}



int IdsNs::<xsl:value-of select="@name"/>_IDSBase::deleteAll(int iOccurrence)
{
    int status = 0;
    al_status_t al_status;
	char *idsName = "<xsl:value-of select="@name"/>";
    std::string idsFullName = std::string(idsName);
	int pulseCtx = this->pulseCtx;
	int deleteOpCtx = -1;
	int ctx = -1;
	int aosCtx = -1;
	std::string fieldPath;
	int arraySize;

	if(!connected)
		return -1;
        
	if(iOccurrence &gt;= 1)
        idsFullName += "/" + std::to_string(iOccurrence);

	// Open put context
    al_status = ual_begin_global_action(pulseCtx, idsFullName.c_str(), "", WRITE_OP, &amp;deleteOpCtx);

	if(al_status.code &lt; 0) {
        printf("DELETE_ALL: error calling ual_begin_global_action for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
		return al_status.code;
    }

	ctx = deleteOpCtx;

	<xsl:apply-templates select="field" mode="DELETE"/>

	ual_end_action(ctx);
	
	return 0;
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::deleteAll()
{
	return this->deleteAll(0);
}

void IdsNs::<xsl:value-of select="@name"/>_IDSBase::clear()
{
	int arraySize = -1;
<xsl:apply-templates select="field" mode="RESET"/>
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::getSlice(double inTime, char interpolMode)
{
	return this->getSlice(0, inTime, interpolMode);
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::getSlice(int iOccurrence, double inTime, char interpolMode)
{
    int status = 0;
    al_status_t al_status;
	char *idsName = "<xsl:value-of select="@name"/>";
    std::string idsFullName = std::string(idsName);
	int pulseCtx = this->pulseCtx;
	int getSliceOpCtx = -1;
	int ctx = -1;
	int aosCtx = -1;
	std::string fieldPath;
	std::string timeBasePath;
	int idsTimeMode = IDS_TIME_MODE_UNKNOWN;
	int arraySize;

	if(!connected)
		return -1;
	
	if(iOccurrence &gt;= 1)
        idsFullName += "/" + std::to_string(iOccurrence);

    al_status = IdsNs::Ids::readIdsTimeMode(pulseCtx, idsFullName.c_str(), idsTimeMode );
    if(al_status.code &lt; 0) {
        printf("GET_SLICE: error reading homogeneous time for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
        return al_status.code;
    }
	
	//reset the ids content
    clear();

	// Open put context
    al_status = ual_begin_slice_action(pulseCtx, idsFullName.c_str(), READ_OP, inTime, interpolMode, &amp;getSliceOpCtx);
	
	if(al_status.code &lt; 0) {
        printf("GET_SLICE: error calling ual_begin_slice_action for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
		return al_status.code;
    }

	ctx = getSliceOpCtx;
	al_status = ual_bind_readback_plugins(ctx); //binding readback plugins just before the get_slice() operation
        if(al_status.code &lt; 0) {
            printf("GET_SLICE: error calling ual_bind_readback_plugins for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
                return al_status.code;
        }
	<xsl:apply-templates select="field" mode="GET_SINGLE">
		<xsl:with-param name="dynamic_only" select="'yes'"/>
	</xsl:apply-templates>
	al_status = ual_unbind_readback_plugins(ctx); //unbinding readback plugins just after the get_slice() operation
        if(al_status.code &lt; 0) {
            printf("GET: error calling ual_unbind_readback_plugins for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
                return al_status.code;
        } 
	ual_end_action(getSliceOpCtx);

	return 0;
}
 <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT"/> 
<xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_GET"/> 

  <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT_SLICE"/>

<xsl:apply-templates select=".//field[@data_type='structure'] " mode="METHOD_DELETE_ALL"/>
<xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_RESET"/>


<xsl:apply-templates select="." mode="DUMP"/>
 </xsl:result-document>



</xsl:template>


<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_PUT">
     <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:call-template name="COMMENT_FIELD"/>
    <xsl:text> int IdsNs::</xsl:text> <xsl:value-of select="ancestor::IDS/@name"/>_IDSBase::<xsl:value-of select="fn:replace(@path,'/','::')"/><xsl:text>::put(int ctx, int idsTimeMode, const std::string &amp;idsFullName)&#xA;</xsl:text>
{
	int status = -1;
    al_status_t al_status;
	int arraySize = -1;
	int aosCtx = -1;
	std::string fieldPath = "";
	std::string timeBasePath = "";

	<xsl:apply-templates select="field" mode="PUT_SINGLE">
		<xsl:with-param name="dynamic_only" select="'no'"/>
	</xsl:apply-templates>

	return 0;
}
</xsl:template>



<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_PUT_SLICE">
<xsl:if test="descendant-or-self::field[@type='dynamic'] or ancestor::field[@type='dynamic' and @data_type='struct_array']">
     <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:call-template name="COMMENT_FIELD"/>
    <xsl:text> int IdsNs::</xsl:text> <xsl:value-of select="ancestor::IDS/@name"/>_IDSBase::<xsl:value-of select="fn:replace(@path,'/','::')"/><xsl:text>::putSlice(int ctx, int idsTimeMode, const std::string &amp;idsFullName)&#xA;</xsl:text>
{
	int status = -1;
    al_status_t al_status;
	int arraySize = -1;
	int aosCtx = -1;
	std::string fieldPath = "";
	std::string timeBasePath = "";

	<xsl:apply-templates select="field" mode="PUT_SINGLE">
		<xsl:with-param name="dynamic_only" select="'yes'"/>
	</xsl:apply-templates>

	return 0;
}
</xsl:if>
</xsl:template>


<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_GET">
     <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:call-template name="COMMENT_FIELD"/>
<xsl:text> int IdsNs::</xsl:text> <xsl:value-of select="ancestor::IDS/@name"/>_IDSBase::<xsl:value-of select="fn:replace(@path,'/','::')"/><xsl:text>::get(int ctx, int idsTimeMode)&#xA;</xsl:text>
{
	int status = -1;
    al_status_t al_status;
	int arraySize = -1;
	int aosCtx = -1;
	std::string fieldPath = "";
	std::string timeBasePath = "";

	<xsl:apply-templates select="field" mode="GET_SINGLE"/>


	return 0;
}
</xsl:template>

<xsl:template match="field[@data_type='structure']" mode="METHOD_DELETE_ALL">
<xsl:if test="not(ancestor::field[@data_type='struct_array'])">
     <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:call-template name="COMMENT_FIELD"/>
<xsl:text> int IdsNs::</xsl:text> <xsl:value-of select="ancestor::IDS/@name"/>_IDSBase::<xsl:value-of select="fn:replace(@path,'/','::')"/><xsl:text>::deleteAll(int ctx)&#xA;</xsl:text>
{
	int status = -1;
    al_status_t al_status;
	std::string fieldPath = "";

	<xsl:apply-templates select="field" mode="DELETE"/>


	return 0;
}
</xsl:if>
</xsl:template>

<xsl:template match="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_RESET">
     <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:call-template name="COMMENT_FIELD"/>
<xsl:text> void IdsNs::</xsl:text> <xsl:value-of select="ancestor::IDS/@name"/>_IDSBase::<xsl:value-of select="fn:replace(@path,'/','::')"/><xsl:text>::clear()&#xA;</xsl:text>
{
	int arraySize = -1;
    <xsl:apply-templates select="field" mode="RESET"/>
}
</xsl:template>

<!--=================================================-->
<!--              field initialization               -->
<!--=================================================-->
<xsl:template match="field" mode="CONSTRUCTOR">
<xsl:choose>
	<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
		<xsl:value-of select="translate(@path,'/','.')"/>=EMPTY_INT;
	</xsl:when>
	<xsl:when test="@name='xs:double'">
		<xsl:value-of select="translate(@path,'/','.')"/>=EMPTY_DOUBLE;
	</xsl:when>
	<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
		<xsl:value-of select="translate(@path,'/','.')"/>=EMPTY_DOUBLE;
	</xsl:when>
    <xsl:when test="@data_type='cpx_type' or @data_type='CPX_0D'">
        <xsl:value-of select="translate(@path,'/','.')"/>=EMPTY_COMPLEX;
    </xsl:when>
	<!-- Note that this template only initializes scalar field that are at the upper tree level.
Scalar fields that are inside structures and arrays of structures
are initialized by the constructors of the respective subclasses.
See IDSDef2Classes.xsl  -->
</xsl:choose>
</xsl:template>

<!--=================================================-->
<!--                 delete fields                   -->
<!--=================================================-->

<xsl:template match="field" mode="DELETE">
	<xsl:call-template name="COMMENT_FIELD"/>
	<xsl:choose>
		<xsl:when test="@data_type='structure'">
			status = <xsl:value-of select="@name"/>.deleteAll(ctx);
			if (status != 0)
				return status;
		</xsl:when>
		<xsl:otherwise>
			fieldPath = "<xsl:value-of select="@path"/>";
			al_status = ual_delete_data(ctx, fieldPath.c_str());
			if (al_status.code != 0)
			{	
				ual_end_action(ctx);
				return al_status.code; 
			}
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--=====================================================================================================================================-->
<!--                  reset fields content to default values                                                                                                      -->
<!--=====================================================================================================================================-->


<xsl:template match="field" mode="RESET">
    <xsl:call-template name="COMMENT_FIELD"/>
    <xsl:choose>
        <xsl:when test="@data_type='structure'">
            <xsl:value-of select="@name"/>.clear();
        </xsl:when>
        <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
            <xsl:value-of select = "@name"/> = EMPTY_INT;
        </xsl:when>
        <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
            <xsl:value-of select = "@name"/> = EMPTY_DOUBLE;
        </xsl:when>
        <xsl:when test="@data_type='cpx_type' or @data_type='CPX_0D'">
            <xsl:value-of select = "@name"/> = EMPTY_COMPLEX;
        </xsl:when>
        <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
            <xsl:value-of select = "@name"/>.clear();
        </xsl:when>
		<xsl:when test="@data_type='struct_array' ">
			arraySize = <xsl:value-of select = "@name"/>.extent(0);
			for( int i = 0; i &lt;arraySize; i++){
				<xsl:value-of select="@name"/>(i).clear();
			}
            <xsl:value-of select = "@name"/>.free();
        </xsl:when>
        <xsl:when test="
                  @data_type='str_1d_type' or @data_type='STR_1D'">
          <xsl:value-of select = "@name"/>.free();
        </xsl:when>
		<xsl:when test="
           @data_type='flt_1d_type' or @data_type='FLT_1D'
        or @data_type='int_1d_type' or @data_type='INT_1D'
        or @data_type='cpx_1d_type' or @data_type='CPX_1D'
        or @data_type='FLT_2D' or @data_type='INT_2D' or @data_type='CPX_2D'
        or @data_type='FLT_3D' or @data_type='INT_3D' or @data_type='CPX_3D'
        or @data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D'
        or @data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D'
        or @data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D' ">

            
            if (<xsl:value-of select = "@name"/>.getDeletionPolicy() == blitz::neverDeleteData)
	           free( <xsl:value-of select = "@name"/>.data());
            <xsl:value-of select = "@name"/>.free();
        </xsl:when>
        <xsl:otherwise>
            //Doc GET <xsl:value-of select="@path"/> : PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!--=================================================-->
<!--               discard old cache                 -->
<!--=================================================-->

<xsl:template match="field" mode="DISCARD_OLD_CACHE">
<xsl:choose>
	<xsl:when test="@timed = 'yes'">
		// imas_discard_old_mem(expIdx, path, "<xsl:value-of select="@path"/>", time);
	</xsl:when>
</xsl:choose>
<xsl:choose>
	<xsl:when test="@data_type='structure'">
		<xsl:apply-templates select="field" mode="DISCARD_OLD_CACHE"/>
	</xsl:when>
</xsl:choose>
</xsl:template>

<!--=================================================-->
<!--                 discard cache                   -->
<!--=================================================-->

<xsl:template match="field" mode="DISCARD_CACHE">
<xsl:choose>
	<xsl:when test="@data_type='structure'">
		<xsl:apply-templates select="field" mode="DISCARD_CACHE"/>
	</xsl:when>
	<xsl:otherwise>
		// imas_discard_mem(expIdx, path, "<xsl:value-of select="@path"/>");
	</xsl:otherwise>
</xsl:choose>
</xsl:template>


<!--=================================================-->
<!--              print field content                -->
<!--=================================================-->
<!-- YBYBDUMP -->
<xsl:template match="field" mode="DUMP">
<xsl:param name="level"/>
<xsl:param name="idxpath"/>

<xsl:param name="currentidxpath" select="concat($idxpath,'.',@name)"/>

<xsl:choose>
	<xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
		os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
		if(<xsl:value-of select="$currentidxpath"/>.empty())
		os &lt;&lt; "EMPTY";
		else
		os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;
	</xsl:when>
	<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
		os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
		if(<xsl:value-of select="$currentidxpath"/> == EMPTY_INT)
		os &lt;&lt; "EMPTY";
		else
		os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;
	</xsl:when>
	<xsl:when test="@name='xs:boolean'">
		os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
		if(<xsl:value-of select="$currentidxpath"/> == EMPTY_INT)
		os &lt;&lt; "EMPTY";
		else
		os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;
	</xsl:when>
	<xsl:when test="@name='xs:double'">
		os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
		if(<xsl:value-of select="$currentidxpath"/> == EMPTY_DOUBLE)
		os &lt;&lt; "EMPTY";
		else
		os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;
	</xsl:when>
	<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
		os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
		if(<xsl:value-of select="$currentidxpath"/> == EMPTY_DOUBLE)
		os &lt;&lt; "EMPTY";
		else
		os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;
	</xsl:when>
    <xsl:when test="@data_type='cpx_type' or @data_type='CPX_0D'">
        os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
        if(<xsl:value-of select="$currentidxpath"/> == EMPTY_COMPLEX)
        os &lt;&lt; "EMPTY";
        else
        os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;
    </xsl:when>
	<xsl:when test="@data_type='structure'">
		<xsl:apply-templates select="field" mode="DUMP">
			<xsl:with-param name="level" select="$level"/>
			<xsl:with-param name="idxpath" select="$currentidxpath"/>
		</xsl:apply-templates>
	</xsl:when>
	<xsl:when test="@data_type='struct_array'">
		for (int i<xsl:value-of select="$level"/> = 0; i<xsl:value-of select="$level"/> &lt; <xsl:value-of select="$idxpath"/>.<xsl:value-of select="@name"/>.extent(0); i<xsl:value-of select="$level"/>++) {
		<xsl:apply-templates select="field" mode="DUMP">
			<xsl:with-param name="level" select="$level + 1"/>
			<xsl:with-param name="idxpath" select="concat($currentidxpath,'(i',$level,')')"/>
		</xsl:apply-templates>
		}
	</xsl:when>
	<xsl:otherwise>
		os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
		if(<xsl:value-of select="$currentidxpath"/>.extent(0) == 0)
		os &lt;&lt; "EMPTY";
		else
		os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;

	</xsl:otherwise>
</xsl:choose>
</xsl:template>


<!--=================================================-->
<!--       put field       -->
<!--=================================================-->

<xsl:template match="field" mode="PUT_SINGLE">
<xsl:param name="dynamic_only"/>
    <xsl:call-template name="COMMENT_FIELD"/>
<xsl:if test="$dynamic_only !='yes' or descendant-or-self::field[@type='dynamic'] or ancestor::field[@type='dynamic' and @data_type='struct_array']">

<xsl:variable name="methodName">
	        <xsl:choose>
		        <xsl:when test="$dynamic_only !='yes'" >
	                	<xsl:value-of select="'put'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'putSlice'" />
	                </xsl:otherwise>
	        </xsl:choose>
	</xsl:variable>
<xsl:choose>
<!--========== Regular structures ==========-->
    <!-- YB 2014 -->
		<xsl:when test="@data_type='structure'">
          status = <xsl:value-of select="@name"/>.<xsl:value-of select="$methodName"/>(ctx, idsTimeMode, idsFullName);
		  if (status &lt; 0)
			return status;
		</xsl:when>

<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
		<xsl:when test="@data_type='struct_array' and @maxoccur!='unbounded'">
			<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="ancestor::field[@data_type='struct_array']">
					fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
				</xsl:when>
  				<xsl:otherwise>
   			 		fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
  				</xsl:otherwise>
			</xsl:choose>
			timeBasePath = "";
			arraySize = <xsl:value-of select = "@name"/>.extent(0);

				al_status = ual_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize, &amp;aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
				{	
					ual_end_action(ctx);
					return al_status.code; 
				}

				for( int i = 0; i &lt;arraySize; i++){
                    status = <xsl:value-of select="@name"/>(i).<xsl:value-of select="$methodName"/>(aosCtx, idsTimeMode, idsFullName);
					if (status &lt; 0)
					{	
						ual_end_action(ctx);
						return status; 
					}
					al_status = ual_iterate_over_arraystruct(aosCtx, 1);
					if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
					{	
						ual_end_action(aosCtx);
						ual_end_action(ctx);
						return al_status.code; 
					}
				}
				al_status = ual_end_action(aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))  
				{	
					ual_end_action(ctx);
					return al_status.code; 
				}
			
		</xsl:when>
 		<xsl:when  test="@data_type='struct_array' and @maxoccur='unbounded' and (@type!='dynamic' or not(@type))">
		
			<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="ancestor::field[@data_type='struct_array']">
					fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
	//<xsl:value-of select="ancestor::field[@data_type='struct_array'][1]/@path"/>

	//<xsl:value-of  select="@path"/>
				</xsl:when>
  				<xsl:otherwise>
   			 		fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
  				</xsl:otherwise>
			</xsl:choose>
			timeBasePath = "";
			arraySize = <xsl:value-of select = "@name"/>.extent(0);

				al_status = ual_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize, &amp;aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__)) 
				{	
					ual_end_action(ctx);
					return al_status.code;
				}

				for( int i = 0; i &lt;arraySize; i++){
                    status = <xsl:value-of select="@name"/>(i).<xsl:value-of select="$methodName"/>(aosCtx, idsTimeMode, idsFullName);
                    if (status &lt; 0)
					{	
						ual_end_action(ctx);
						return status;
					}
					al_status = ual_iterate_over_arraystruct(aosCtx, 1);
					if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
					{	
						ual_end_action(aosCtx);
						ual_end_action(ctx);
						return al_status.code; 
					}
				}
				al_status = ual_end_action(aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
				{	
					ual_end_action(ctx);
					return al_status.code; 
				}
		</xsl:when>
		<xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'">

			<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="ancestor::field[@data_type='struct_array']">
					fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
					if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS) 
          					timeBasePath = "/time";
       					else
						timeBasePath = &quot;<xsl:call-template  name="printAosRelativePath"/>/time&quot;;
	//<xsl:value-of select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	//<xsl:value-of select="@path"/>
				</xsl:when>
  				<xsl:otherwise>
   			 		fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
					if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS) 
          					timeBasePath = "/time";
       					else
						timeBasePath = &quot;<xsl:value-of select="@path"/>/time&quot;;
  				</xsl:otherwise>
			</xsl:choose>
			arraySize = <xsl:value-of select = "@name"/>.extent(0);
			if(idsTimeMode != IDS_TIME_MODE_INDEPENDENT)
			{	
				al_status = ual_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize, &amp;aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))  
				{	
					ual_end_action(ctx);
					return al_status.code;
				}

				for( int i = 0; i &lt;arraySize; i++){
                    status = <xsl:value-of select="@name"/>(i).<xsl:value-of select="$methodName"/>(aosCtx, idsTimeMode, idsFullName);
                    if (status &lt; 0)
					{	
						ual_end_action(ctx);
                        return status;
					}
					al_status = ual_iterate_over_arraystruct(aosCtx, 1);
					if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
					{	
						ual_end_action(aosCtx);
						ual_end_action(ctx);
                        return al_status.code;
					}
				}
				al_status = ual_end_action(aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))  
				{	
					ual_end_action(ctx);
                    return al_status.code;
				}
					 
 			}
		</xsl:when>



	<xsl:when test="
		   @data_type='str_type' or @data_type='STR_0D'
		or @data_type='str_1d_type' or @data_type='STR_1D'
		or @data_type='int_type' or @data_type='INT_0D'
		or @data_type='flt_type' or @data_type='FLT_0D' 
		or @data_type='flt_1d_type' or @data_type='FLT_1D'
		or @data_type='int_1d_type' or @data_type='INT_1D'
        or @data_type='cpx_type' or @data_type='CPX_0D' 
        or @data_type='cpx_1d_type' or @data_type='CPX_1D'
		or @data_type='FLT_2D' or @data_type='INT_2D' or @data_type='CPX_2D'
		or @data_type='FLT_3D' or @data_type='INT_3D' or @data_type='CPX_3D'
		or @data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D'
		or @data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D'
		or @data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D'">
		<xsl:choose>
			<xsl:when test="ancestor::field[@data_type='struct_array']">
				fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
			</xsl:when>
  			<xsl:otherwise>
   			 	fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
  			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])">
            if( idsTimeMode != IDS_TIME_MODE_INDEPENDENT)
            {
    		    if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS) 
			        timeBasePath="/time";
    		    else
       			    timeBasePath=&quot;<xsl:value-of select="@timebasepath"/>&quot;;
  			</xsl:when>
  			<xsl:otherwise>
    				timeBasePath = "";
  			</xsl:otherwise>
		</xsl:choose>
        <xsl:choose>
            <xsl:when test="(@data_type='str_type' or @data_type='STR_0D') and @path='ids_properties/version_put/data_dictionary'">
                al_status = IdsNs::Ids::writeData(ctx, idsFullName, fieldPath, timeBasePath, "<xsl:value-of select="$DD_GIT_DESCRIBE"/>", "<xsl:value-of select="@lifecycle_status"/>");
            </xsl:when>
            <xsl:when test="(@data_type='str_type' or @data_type='STR_0D') and @path='ids_properties/version_put/access_layer'">
                al_status = IdsNs::Ids::writeData(ctx, idsFullName, fieldPath, timeBasePath, "<xsl:value-of select="$UAL_GIT_DESCRIBE"/>", "<xsl:value-of select="@lifecycle_status"/>");
            </xsl:when>
            <xsl:when test="(@data_type='str_type' or @data_type='STR_0D') and @path='ids_properties/version_put/access_layer_language'">
                al_status = IdsNs::Ids::writeData(ctx, idsFullName, fieldPath, timeBasePath, "cpp", "<xsl:value-of select="@lifecycle_status"/>");
            </xsl:when>
            <xsl:otherwise>
                al_status = IdsNs::Ids::writeData(ctx, idsFullName, fieldPath, timeBasePath, this-><xsl:value-of select="@name"/>, "<xsl:value-of select="@lifecycle_status"/>");
            </xsl:otherwise>
        </xsl:choose>
        if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
        {   
            ual_end_action(ctx);
            return al_status.code;
        }
        <xsl:if test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])">
            }
        </xsl:if>
	</xsl:when>
		<xsl:otherwise>
			//Doc Put <xsl:value-of select="@path"/> : PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
		</xsl:otherwise>
	</xsl:choose>
</xsl:if>
</xsl:template>




<!-- 2014 YBYB-->
<!--=================================================-->
<!--       put field of a time-independent IDS       -->
<!--=================================================-->

<xsl:template match="field" mode="GET_SINGLE">
    <xsl:call-template name="COMMENT_FIELD"/>
<xsl:choose>
<!--========== Regular structures ==========-->
    <!-- YB 2014 -->
		<xsl:when test="@data_type='structure'">
		status = <xsl:value-of select="@name"/>.get(ctx, idsTimeMode);
		if (status != 0)
			return status;
		</xsl:when>

<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
		<xsl:when test="@data_type='struct_array' and @maxoccur!='unbounded'">
			<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="ancestor::field[@data_type='struct_array']">
					fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;	
	//<xsl:value-of select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	//<xsl:value-of select="@path"/>
				</xsl:when>
  				<xsl:otherwise>
   			 		fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
  				</xsl:otherwise>
			</xsl:choose>
			timeBasePath = "";
			al_status = ual_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize, &amp;aosCtx);
			if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__)) 
			{	
				ual_end_action(ctx);
				return al_status.code;
			}

			if(aosCtx > 0 &amp;&amp; arraySize > 0)
			{	
				<xsl:value-of select="@name"/>.resize(arraySize);
				for( int i = 0; i &lt;arraySize; i++){
					status = <xsl:value-of select="@name"/>(i).get(aosCtx, idsTimeMode);
                    if (status &lt; 0)
					{	
						ual_end_action(ctx);
                        return status;
					}
					al_status = ual_iterate_over_arraystruct(aosCtx, 1);
					if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
					{	
						ual_end_action(aosCtx);
						ual_end_action(ctx);
                        return al_status.code;
					}
				}
				al_status = ual_end_action(aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))  
				{	
					ual_end_action(ctx);
                    return al_status.code;
				}
 			}
		</xsl:when>
 		<xsl:when  test="@data_type='struct_array' and @maxoccur='unbounded' and (@type!='dynamic' or not(@type))">	
			<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="ancestor::field[@data_type='struct_array']">
					fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
	//<xsl:value-of select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	//<xsl:value-of select="@path"/>
				</xsl:when>
  				<xsl:otherwise>
   			 		fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
  				</xsl:otherwise>
			</xsl:choose>
			timeBasePath = "";
			al_status = ual_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize, &amp;aosCtx);
			if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__)) 
			{	
					ual_end_action(ctx);
                    return al_status.code;
			}

			if(aosCtx > 0 &amp;&amp; arraySize > 0)
			{	
				<xsl:value-of select="@name"/>.resize(arraySize);
				for( int i = 0; i &lt;arraySize; i++){
					status = <xsl:value-of select="@name"/>(i).get(aosCtx, idsTimeMode);
                    if (status &lt; 0)
					{	
						ual_end_action(ctx);
                        return status;
					}
					al_status = ual_iterate_over_arraystruct(aosCtx, 1);
					if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
					{	
						ual_end_action(aosCtx);
						ual_end_action(ctx);
                        return al_status.code;
					}
				}
				al_status = ual_end_action(aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__)) 
				{	
					ual_end_action(ctx);
                    return al_status.code;
				}
 			}
		</xsl:when>
		<xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'">
			<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
            if (idsTimeMode != IDS_TIME_MODE_INDEPENDENT) 
            {
			<xsl:choose>
				<xsl:when test="ancestor::field[@data_type='struct_array']">
					fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
					if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS) 
          					timeBasePath = "/time";
       					else
						timeBasePath = &quot;<xsl:call-template  name="printAosRelativePath"/>/time&quot;;
				</xsl:when>
  				<xsl:otherwise>
   			 		fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
					if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS)  
          					timeBasePath = "/time";
       					else
						timeBasePath = &quot;<xsl:value-of select="@path"/>/time&quot;;
  				</xsl:otherwise>
			</xsl:choose>
			al_status = ual_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize, &amp;aosCtx);
			if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))  
			{	
				ual_end_action(ctx);
                return al_status.code;
			}

			if(aosCtx > 0 )
			{	
                if(arraySize > 0)
                {   
				    <xsl:value-of select="@name"/>.resize(arraySize);
				    for( int i = 0; i &lt;arraySize; i++){
					    status = <xsl:value-of select="@name"/>(i).get(aosCtx, idsTimeMode);
					    if (status &lt; 0)
					    {	
						    ual_end_action(ctx);
                            return status;
					    }
					    al_status = ual_iterate_over_arraystruct(aosCtx, 1);
					    if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
					    {	
						    ual_end_action(aosCtx);
						    ual_end_action(ctx);
                            return al_status.code;
					    }
				    }
                }
				al_status = ual_end_action(aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))  
				{	
					ual_end_action(ctx);
                    return al_status.code;
				}
 			}
        }
		</xsl:when>

	<xsl:when test="
		   @data_type='str_type' or @data_type='STR_0D'
		or @data_type='str_1d_type' or @data_type='STR_1D'
		or @data_type='int_type' or @data_type='INT_0D'
		or @data_type='flt_type' or @data_type='FLT_0D' 
		or @data_type='flt_1d_type' or @data_type='FLT_1D'
		or @data_type='int_1d_type' or @data_type='INT_1D'
        or @data_type='cpx_type' or @data_type='CPX_0D' 
        or @data_type='cpx_1d_type' or @data_type='CPX_1D'
        or @data_type='FLT_2D' or @data_type='INT_2D' or @data_type='CPX_2D'
        or @data_type='FLT_3D' or @data_type='INT_3D' or @data_type='CPX_3D'
        or @data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D'
        or @data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D'
        or @data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D'">
		<xsl:choose>
			<xsl:when test="ancestor::field[@data_type='struct_array']">
				fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
			</xsl:when>
  			<xsl:otherwise>
   			 	fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
  			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])">
            if (idsTimeMode != IDS_TIME_MODE_INDEPENDENT) 
            {
                if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS) 
			    timeBasePath="/time";
                else
                    timeBasePath=&quot;<xsl:value-of select="@timebasepath"/>&quot;;
  			</xsl:when>
  			<xsl:otherwise>
    				timeBasePath = "";
  			</xsl:otherwise>
		</xsl:choose>
		al_status = IdsNs::Ids::readData(ctx, fieldPath, timeBasePath, this-><xsl:value-of select="@name"/>);
		if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__)) 
		{	
			ual_end_action(ctx);
            return al_status.code;
		}
        <xsl:if test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])">
        }
        </xsl:if>
	</xsl:when>
		<xsl:otherwise>
			//Doc GET <xsl:value-of select="@path"/> : PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name ="printAosRelativePath">
	<xsl:variable name="AoSPath" select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	<xsl:variable name="elementPath" select="@path"/>

	<xsl:value-of select="replace($elementPath,concat($AoSPath,'/'),'')"/>
</xsl:template>


</xsl:stylesheet>
