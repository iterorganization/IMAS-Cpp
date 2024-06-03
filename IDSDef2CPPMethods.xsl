<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating  C++ access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"  version="2.0" extension-element-prefixes="yaslt">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>



<xsl:param name="DD_GIT_DESCRIBE" as="xs:string" required="yes"/>
<xsl:param name="AL_GIT_DESCRIBE" as="xs:string" required="yes"/>

<xsl:variable name="version_regex" select="'^([0-9]+)\.([0-9]+)\.([0-9]+)([+-].*)?$'"/>
<xsl:variable name="DD_MAJOR" as="xs:integer" select="xs:integer(replace($DD_GIT_DESCRIBE, $version_regex, '$1'))"/>
<xsl:variable name="DD_MINOR" as="xs:integer" select="xs:integer(replace($DD_GIT_DESCRIBE, $version_regex, '$2'))"/>
<xsl:variable name="DD_PATCH" as="xs:integer" select="xs:integer(replace($DD_GIT_DESCRIBE, $version_regex, '$3'))"/>

<xsl:variable name="HLI_MAJOR" as="xs:integer" select="xs:integer(replace($AL_GIT_DESCRIBE, $version_regex, '$1'))"/>
<xsl:variable name="HLI_MINOR" as="xs:integer" select="xs:integer(replace($AL_GIT_DESCRIBE, $version_regex, '$2'))"/>
<xsl:variable name="HLI_PATCH" as="xs:integer" select="xs:integer(replace($AL_GIT_DESCRIBE, $version_regex, '$3'))"/>

<xsl:template match="/IDSs">
<xsl:result-document href="src/ALMethods.cpp" standalone="yes" method="text">

#include "ALClasses.h"

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

const std::string IdsNs::al_cpp_version = "<xsl:value-of select="$AL_GIT_DESCRIBE"/>";
const int IdsNs::al_cpp_major_version = <xsl:value-of select="$HLI_MAJOR"/>;
const int IdsNs::al_cpp_minor_version = <xsl:value-of select="$HLI_MINOR"/>;
const int IdsNs::al_cpp_patch_version = <xsl:value-of select="$HLI_PATCH"/>;

const std::string IdsNs::al_dd_version = "<xsl:value-of select="$DD_GIT_DESCRIBE"/>";
const int IdsNs::al_dd_major_version = <xsl:value-of select="$DD_MAJOR"/>;
const int IdsNs::al_dd_minor_version = <xsl:value-of select="$DD_MINOR"/>;
const int IdsNs::al_dd_patch_version = <xsl:value-of select="$DD_PATCH"/>;

IdsNs::IDS::IDS()
{
	treeName = "ids";
	connected = false;
	pulse = refPulse = run = refRun = -1;
	backend = defaultBackend();
}

IdsNs::IDS::IDS(int pulse, int run, int refPulse, int refRun)
{
	treeName = "ids";
	connected = false;
	this-&gt; pulse = pulse;
	this-&gt;run = run;
	this-&gt;refPulse = refPulse;
	this-&gt;refRun = refRun;
	pulseCtx = -1;
	backend = defaultBackend();
}
IdsNs::IDS::IDS(int pulseCtx)
{
	treeName = "ids";
	connected = true;
	this->pulseCtx = pulseCtx;
	this->setPulseCtx(pulseCtx);
	int defbackend;
	al_get_backendID(pulseCtx,&amp;defbackend);
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

    al_status = al_begin_dataentry_action(uri, mode, &amp;pulseCtx);
    if (al_status.code &lt; 0)
    {
    printf("Error opening URI %s\n%s\n", "al_begin_dataentry_action", al_status.message);
    return al_status.code;
    }

    this->pulseCtx = pulseCtx;
    this->connected = true;
    this->setPulseCtx(pulseCtx);
   	return al_status.code;
}

int IdsNs::IDS::openEnv(const char *user, const char *tokamak, const char *version, const char *option/* = nullptr*/)
{
    int pulseCtx;
    al_status_t al_status;
    char* uri;
    al_status = al_build_uri_from_legacy_parameters(this->backend, this->pulse, this->run, user, tokamak, version, option, &amp;uri);
    if (al_status.code != 0)
    {
        printf("Error building URI %s\n%s\n", "al_build_uri_from_legacy_parameters", al_status.message);
    	return al_status.code;
    }
    al_status = al_begin_dataentry_action(uri, OPEN_PULSE, &amp;pulseCtx);
    if (al_status.code != 0)
    {
        BACKEND fallback = this->fallbackBackend();
	if (fallback != NO_BACKEND)
  	{
	    printf("WARNING: the pulse file is not available with backend %d, now attempting to access it with the fallback backend %d\n",this->backend,fallback);
	    this->backend = fallback;
	    al_status = al_build_uri_from_legacy_parameters(this->backend, this->pulse, this->run, user, tokamak, version, option, &amp;uri);
	    if (al_status.code != 0)
	    {
                printf("Error building URI %s\n%s\n", "al_build_uri_from_legacy_parameters", al_status.message);
    		return al_status.code;
	    }
	    al_status = al_begin_dataentry_action(uri, OPEN_PULSE, &amp;pulseCtx);
	}
	if (al_status.code != 0)
	{
            printf("Error opening imas pulse %d, run %d: %s\n%s\n", pulse, run, "al_begin_dataentry_action", al_status.message);
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
    al_status = al_build_uri_from_legacy_parameters(this->backend, this->pulse, this->run, user, tokamak, version, option, &amp;uri);
	if (al_status.code &lt; 0)
	{
		printf("Error building URI %s\n%s\n", "al_build_uri_from_legacy_parameters", al_status.message);
    	return al_status.code;
	}
    al_status = al_begin_dataentry_action(uri, FORCE_CREATE_PULSE, &amp;pulseCtx);
    if (al_status.code &lt; 0)
	{
    printf("Error opening imas pulse %d, run %d: %s\n%s\n", pulse, run, "al_begin_dataentry_action", al_status.message);
        return al_status.code;
	}

	this->pulseCtx = pulseCtx;
	this->connected = true;
	this->setPulseCtx(pulseCtx);
	return al_status.code;
}

int IdsNs::IDS::close()
{
  	al_status_t al_status = al_close_pulse(this->pulseCtx, CLOSE_PULSE);
    if(al_status.code != 0)
	{
		printf("Error opening imas pulse %d, run %d: %s\n %s\n", pulse, run, "al_close_pulse", al_status.message);
        return al_status.code;
	}
    al_end_action(this->pulseCtx);
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

 int IdsNs::IDS::list_all_occurrences(int idx, const char *ids_name, const char *node_path, std::vector&lt;string&gt; &amp;node_content_list, std::vector&lt;int&gt; &amp;occurrence_list)
{

    int opCtx = -1;
    int* al_occurrences_list;
    int size;
    al_status_t status = al_get_occurrences(idx, ids_name, &amp;al_occurrences_list, &amp;size);

	node_content_list.resize(0);
    occurrence_list.resize(0);

    if (status.code &lt; 0) {
      printf("IMAS:list_all_occurrences:Failed. Error calling al_get_occurrences for IDS name %s (idx=%d):\n\r%s", ids_name, idx, status.message);
      return status.code;
    }

    if (size&gt;0) {
        node_content_list.resize(size);
        occurrence_list.resize(size);
    }
    
    for (int i = 0; i&lt;size; i++) occurrence_list[i] = al_occurrences_list[i];
    if (node_path &amp;&amp; strlen(node_path) &gt; 0) {
        std::vector&lt;string&gt; replies(size);
        std::vector&lt;string&gt; ids_full_names(size);
        int n_max = 0;
        std::string ids_name_str(ids_name);

        for (int i = 0; i&lt;size; i++) {
            if (al_occurrences_list[i]&gt;0) ids_full_names[i] = ids_name_str+"/"+std::to_string(al_occurrences_list[i]);
            else ids_full_names[i] = ids_name;

            status = al_begin_global_action(idx, ids_full_names[i].c_str(), "", READ_OP, &amp;opCtx);
            if (status.code &lt; 0) {
                printf("IMAS:list_all_occurrences:Failed. Error calling al_begin_global_action %s\n\r",  status.message);
                return status.code;
            }

            int retSize[MAXDIM] = {0};
            char* ptrChar = NULL;
            status = al_read_data(opCtx, node_path, "", (void**)&amp;ptrChar, CHAR_DATA, 1, &amp;retSize[0]);
            if (status.code &lt; 0) {
                printf("IMAS:list_all_occurrences:Failed. Error calling al_read_data %s\n\r",  status.message);
                return status.code;
            }

            if (ptrChar == NULL) {
                replies[i] == "";
            } else {
			replies[i] = ptrChar;
			}
			
            status = al_end_action(opCtx);
            if (status.code &lt; 0) {
                printf("IMAS:imas_list_all_occurrences:Failed. Error calling al_end_action %s\n\r",  status.message);
                return status.code;
            }

            if (retSize[0] &gt; n_max)
                n_max = retSize[0];
        }

        for (int i = 0; i &lt; size; i++)  node_content_list[i] = replies[i];

    } else {
        for (int i = 0; i &lt; size; i++) node_content_list[i] = "";
    }


    return 0;
}


ostream &amp;IdsNs::operator &lt;&lt; (ostream &amp;os, const IDS &amp;obj)
{
os &lt;&lt; "TreeName: ";
os &lt;&lt; obj.treeName;
os &lt;&lt; "\nPulse: ";
os &lt;&lt;obj.pulse;
os &lt;&lt;"\nRun: ";
os &lt;&lt;obj.run;
os &lt;&lt;"\nRef pulse: ";
os &lt;&lt;obj.refPulse;
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
#include "ALDef.h"
#include "<xsl:value-of select="@name"/>_IDSBase.h"
#include &lt;regex&gt;

using namespace IdsNs;

IdsNs::<xsl:value-of select="@name"/>_IDSBase::<xsl:value-of select="@name"/>_IDSBase()
{
<xsl:apply-templates select="field" mode="CONSTRUCTOR"/>
}


int IdsNs::<xsl:value-of select="@name"/>_IDSBase::get()
{
	return this->get(0);
}

bool IdsNs::<xsl:value-of select="@name"/>_IDSBase::isDefined()
{
    int idsTimeMode = this->ids_properties.homogeneous_time;

	if (idsTimeMode == IDS_TIME_MODE_HETEROGENEOUS) 
        return true;

	if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS) 
        return true;

	if (idsTimeMode == IDS_TIME_MODE_INDEPENDENT) 
        return true;

	return false;
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::get(int iOccurrence)
{
        int status = 0;
        al_status_t al_status;
        char *str;
        const char *idsName = "<xsl:value-of select="@name"/>";
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
    al_status = al_begin_global_action(pulseCtx, idsFullName.c_str(), "", READ_OP, &amp;getOpCtx);

	if(al_status.code &lt; 0) {
        printf("GET: error calling al_begin_global_action for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
		return al_status.code;
    }

	ctx = getOpCtx;
        al_status = al_bind_readback_plugins(ctx); //binding readback plugins just before the get() operation
        if(al_status.code &lt; 0) {
            printf("GET: error calling al_bind_readback_plugins for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
                return al_status.code;
        }
 	<xsl:apply-templates select="field" mode="GET_SINGLE"/>
	al_status = al_unbind_readback_plugins(ctx); //unbinding readback plugins just after the get() operation
        if(al_status.code &lt; 0) {
            printf("GET: error calling al_unbind_readback_plugins for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
                return al_status.code;
        } 
	al_end_action(ctx);
	
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
	const char *idsName = "<xsl:value-of select="@name"/>";
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

		// Automatic validation
  char* disableAutomaticValidationStr = getenv("IMAS_AL_DISABLE_VALIDATE");
	int disableAutomaticValidationInt = 0;
	if (disableAutomaticValidationStr != NULL) {
    disableAutomaticValidationInt = atoi(disableAutomaticValidationStr);
	}
	if (!(disableAutomaticValidationInt == 1))
    this->validate();

	idsTimeMode = ids_properties.homogeneous_time;
	if (idsTimeMode == IDS_TIME_MODE_UNKNOWN)
	{
		printf("Warning: IDS <xsl:value-of select="@name"/> is found to be EMPTY (homogeneous_time undefined). PUT quits with no action.");
   		return 0;
	}

	if(iOccurrence &gt;= 1)
        idsFullName += "/" + std::to_string(iOccurrence);

    <xsl:if test="@type='constant'">
    if( idsTimeMode != IDS_TIME_MODE_INDEPENDENT )
    {
        ids_properties.homogeneous_time = IDS_TIME_MODE_INDEPENDENT;
        idsTimeMode = IDS_TIME_MODE_INDEPENDENT;
        printf("AL warning: ids_properties/homogeneous_time has been set to IDS_TIME_MODE_INDEPENDENT for the constant IDS '%s', please check the program which has filled this IDS since this is the mandatory value for a constant IDS.", idsFullName.c_str());
    }
    </xsl:if>
	
	deleteAll(iOccurrence);

	// Open put context
	al_status = al_begin_global_action(pulseCtx, idsFullName.c_str(), "", WRITE_OP, &amp;putOpCtx);

	if(al_status.code &lt; 0) {
        printf("PUT: error calling al_begin_global_action for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
        return al_status.code;
    }

	ctx = putOpCtx;

	<xsl:apply-templates select="field" mode="PUT_SINGLE">
		<xsl:with-param name="dynamic_only" select="'no'"/>
	</xsl:apply-templates>

        al_status = al_write_plugins_metadata(ctx); //writing plugins metadata just after the put() operation
        if(al_status.code &lt; 0) {
        printf("PUT: error calling al_write_plugins_metadata for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
                return al_status.code;
        }
	al_end_action(putOpCtx);
	
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
	const char *idsName = "<xsl:value-of select="@name"/>";
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

	// Automatic validation
    char* disableAutomaticValidationStr = getenv("IMAS_AL_DISABLE_VALIDATE");
	int disableAutomaticValidationInt = 0;
	if (disableAutomaticValidationStr != NULL) {
    disableAutomaticValidationInt = atoi(disableAutomaticValidationStr);
	}
	if (!(disableAutomaticValidationInt == 1))
    this->validate();
	
	idsTimeMode = ids_properties.homogeneous_time;
	if (idsTimeMode == IDS_TIME_MODE_UNKNOWN) 
	{
		printf("Warning: IDS <xsl:value-of select="@name"/> is found to be EMPTY (homogeneous_time undefined). PUTSLICE quits with no action.\n");
   		return 0;
	}

	if(iOccurrence &gt;= 1)
        idsFullName += "/" + std::to_string(iOccurrence);

    <xsl:if test="@type='constant'">
    if( idsTimeMode != IDS_TIME_MODE_INDEPENDENT )
    {
        ids_properties.homogeneous_time = IDS_TIME_MODE_INDEPENDENT;
        idsTimeMode = IDS_TIME_MODE_INDEPENDENT;
        printf("AL warning: ids_properties/homogeneous_time has been set to IDS_TIME_MODE_INDEPENDENT for the constant IDS '%s', please check the program which has filled this IDS since this is the mandatory value for a constant IDS.", idsFullName.c_str());
    }
    </xsl:if>

    if (idsTimeMode == IDS_TIME_MODE_INDEPENDENT) 
    {
        printf("Warning: IDS '<xsl:value-of select="@name"/>' time mode 'independent'. PUTSLICE quits with no action.\n");
        return 0;
    }

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
	al_status = al_begin_slice_action(pulseCtx, idsFullName.c_str(), WRITE_OP, UNDEFINED_TIME, UNDEFINED_INTERP, &amp;putSliceOpCtx);
	
	if(al_status.code &lt; 0) {
        printf("PUT_SLICE: error calling al_begin_slice_action for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
		return al_status.code;
    }

	ctx = putSliceOpCtx;
	
	<xsl:apply-templates select="field" mode="PUT_SINGLE">
		<xsl:with-param name="dynamic_only" select="'yes'"/>
	</xsl:apply-templates>
	
	al_status = al_write_plugins_metadata(ctx); //writing plugins metadata just after the putSlice() operation
        if(al_status.code &lt; 0) {
        printf("PUT_SLICE: error calling al_write_plugins_metadata for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
                return al_status.code;
        }
        al_end_action(putSliceOpCtx);
	return 0;
}



int IdsNs::<xsl:value-of select="@name"/>_IDSBase::deleteAll(int iOccurrence)
{
    int status = 0;
    al_status_t al_status;
	const char *idsName = "<xsl:value-of select="@name"/>";
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
    al_status = al_begin_global_action(pulseCtx, idsFullName.c_str(), "", WRITE_OP, &amp;deleteOpCtx);

	if(al_status.code &lt; 0) {
        printf("DELETE_ALL: error calling al_begin_global_action for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
		return al_status.code;
    }

	ctx = deleteOpCtx;

	<xsl:apply-templates select="field" mode="DELETE"/>

	al_end_action(ctx);
	
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
<xsl:choose>
  <xsl:when test="@type='constant'">
    // for static IDSes only GET method is called
	return this->get(iOccurrence);
  </xsl:when>
  <xsl:otherwise>
    int status = 0;
    al_status_t al_status;
	const char *idsName = "<xsl:value-of select="@name"/>";
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
    al_status = al_begin_slice_action(pulseCtx, idsFullName.c_str(), READ_OP, inTime, interpolMode, &amp;getSliceOpCtx);
	
	if(al_status.code &lt; 0) {
        printf("GET_SLICE: error calling al_begin_slice_action for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
		return al_status.code;
    }

	ctx = getSliceOpCtx;
	al_status = al_bind_readback_plugins(ctx); //binding readback plugins just before the get_slice() operation
        if(al_status.code &lt; 0) {
            printf("GET_SLICE: error calling al_bind_readback_plugins for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
                return al_status.code;
        }
	<xsl:apply-templates select="field" mode="GET_SINGLE">
		<xsl:with-param name="dynamic_only" select="'yes'"/>
	</xsl:apply-templates>
	al_status = al_unbind_readback_plugins(ctx); //unbinding readback plugins just after the get_slice() operation
        if(al_status.code &lt; 0) {
            printf("GET: error calling al_unbind_readback_plugins for %s IDS: %s\n", idsFullName.c_str(), al_status.message);
                return al_status.code;
        } 
	al_end_action(getSliceOpCtx);

	return 0;
  </xsl:otherwise>
</xsl:choose>
}


 <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT"/> 
<xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_GET"/> 

  <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT_SLICE"/>

<xsl:apply-templates select=".//field[@data_type='structure'] " mode="METHOD_DELETE_ALL"/>
<xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_RESET"/>

void IdsNs::<xsl:value-of select="@name"/>_IDSBase::validate() const {
	int idsTimeMode = ids_properties.homogeneous_time;;
	int idsTimeSize = 0;
	int arraySize = -1;
	bool check = true;
	bool error = true;
	int i = 0;
  std::vector&lt;string&gt; indicesStr;
  std::vector&lt;int&gt; indicesVal;

	if (idsTimeMode != IDS_TIME_MODE_HOMOGENEOUS &amp;&amp;
		idsTimeMode != IDS_TIME_MODE_HETEROGENEOUS &amp;&amp;
		idsTimeMode != IDS_TIME_MODE_INDEPENDENT) {
		  throw IdsNs::ValidationException("ids_properties.homogeneous_time wrong value");
	}

	<xsl:if test="not(@type='constant')">	
	idsTimeSize = this->time.extent(0);
	</xsl:if>

	<xsl:apply-templates select = "field" mode = "VALIDATE_CHILD"/>
	<xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_1D"> <xsl:with-param name="currpath" select="''"/> </xsl:apply-templates>
    <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_2D"> <xsl:with-param name="currpath" select="''"/> </xsl:apply-templates>
    <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_3D"> <xsl:with-param name="currpath" select="''"/> </xsl:apply-templates>
    <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_4D"> <xsl:with-param name="currpath" select="''"/> </xsl:apply-templates>
    <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_5D"> <xsl:with-param name="currpath" select="''"/> </xsl:apply-templates>
    <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_6D"> <xsl:with-param name="currpath" select="''"/> </xsl:apply-templates>	
	<xsl:apply-templates select="field" mode="VALIDATE_CHILD_FIXED_SIZE"/>
}

<xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE"/>

<xsl:apply-templates select="." mode="DUMP"/>
 </xsl:result-document>



</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_VALIDATE">
     <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:call-template name="COMMENT_FIELD"/>
    <xsl:text> void IdsNs::</xsl:text> <xsl:value-of select="ancestor::IDS/@name"/>_IDSBase::<xsl:value-of select="fn:replace(@path,'/','::')"/><xsl:text>::validate(int idsTimeMode, int idsTimeSize) const&#xA;</xsl:text>
{
	int arraySize = -1;
	bool check = true;
	bool error = true;
	int i = 0;
  std::vector&lt;string&gt; indicesStr;
  std::vector&lt;int&gt; indicesVal;

	<xsl:apply-templates select = "field" mode = "VALIDATE_CHILD"/>
    <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_1D"> <xsl:with-param name="currpath" select="normalize-space(@path_doc)"/> <xsl:with-param name="containing" select="@path_doc"/> </xsl:apply-templates>
    <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_2D"> <xsl:with-param name="currpath" select="normalize-space(@path_doc)"/> <xsl:with-param name="containing" select="@path_doc"/> </xsl:apply-templates>
    <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_3D"> <xsl:with-param name="currpath" select="normalize-space(@path_doc)"/> <xsl:with-param name="containing" select="@path_doc"/> </xsl:apply-templates>
    <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_4D"> <xsl:with-param name="currpath" select="normalize-space(@path_doc)"/> <xsl:with-param name="containing" select="@path_doc"/> </xsl:apply-templates>
    <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_5D"> <xsl:with-param name="currpath" select="normalize-space(@path_doc)"/> <xsl:with-param name="containing" select="@path_doc"/> </xsl:apply-templates>
    <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_6D"> <xsl:with-param name="currpath" select="normalize-space(@path_doc)"/> <xsl:with-param name="containing" select="@path_doc"/> </xsl:apply-templates>
	<xsl:apply-templates select="field" mode="VALIDATE_CHILD_FIXED_SIZE"/>
}
</xsl:template>


<xsl:template match="field" mode="VALIDATE_DESCENDENTS">
<xsl:param name="currpath"/>
<xsl:param name="containing"/>
  <xsl:variable name="descendant-validations">
 <xsl:if test="@data_type = 'struct_array'">
  <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_1D"> <xsl:with-param name="currpath" select="$currpath"/> <xsl:with-param name="containing" select="concat($containing,'/',@name,'(',substring-before(substring-after(@path_doc,concat('/',@name,'(')),')'),')')"/> </xsl:apply-templates>
  <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_2D"> <xsl:with-param name="currpath" select="$currpath"/> <xsl:with-param name="containing" select="concat($containing,'/',@name,'(',substring-before(substring-after(@path_doc,concat('/',@name,'(')),')'),')')"/> </xsl:apply-templates>
  <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_3D"> <xsl:with-param name="currpath" select="$currpath"/> <xsl:with-param name="containing" select="concat($containing,'/',@name,'(',substring-before(substring-after(@path_doc,concat('/',@name,'(')),')'),')')"/> </xsl:apply-templates>
  <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_4D"> <xsl:with-param name="currpath" select="$currpath"/> <xsl:with-param name="containing" select="concat($containing,'/',@name,'(',substring-before(substring-after(@path_doc,concat('/',@name,'(')),')'),')')"/> </xsl:apply-templates>
  <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_5D"> <xsl:with-param name="currpath" select="$currpath"/> <xsl:with-param name="containing" select="concat($containing,'/',@name,'(',substring-before(substring-after(@path_doc,concat('/',@name,'(')),')'),')')"/> </xsl:apply-templates>
  <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_6D"> <xsl:with-param name="currpath" select="$currpath"/> <xsl:with-param name="containing" select="concat($containing,'/',@name,'(',substring-before(substring-after(@path_doc,concat('/',@name,'(')),')'),')')"/> </xsl:apply-templates>
  </xsl:if> 
  <xsl:if test="@data_type = 'structure'">
  <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_1D"> <xsl:with-param name="currpath" select="$currpath"/> <xsl:with-param name="containing" select="concat($containing,'/',@name)"/> </xsl:apply-templates>
  <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_2D"> <xsl:with-param name="currpath" select="$currpath"/> <xsl:with-param name="containing" select="concat($containing,'/',@name)"/> </xsl:apply-templates>
  <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_3D"> <xsl:with-param name="currpath" select="$currpath"/> <xsl:with-param name="containing" select="concat($containing,'/',@name)"/> </xsl:apply-templates>
  <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_4D"> <xsl:with-param name="currpath" select="$currpath"/> <xsl:with-param name="containing" select="concat($containing,'/',@name)"/> </xsl:apply-templates>
  <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_5D"> <xsl:with-param name="currpath" select="$currpath"/> <xsl:with-param name="containing" select="concat($containing,'/',@name)"/> </xsl:apply-templates>
  <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_6D"> <xsl:with-param name="currpath" select="$currpath"/> <xsl:with-param name="containing" select="concat($containing,'/',@name)"/> </xsl:apply-templates>
  </xsl:if> 
  </xsl:variable>
  <xsl:if test="@data_type = 'structure'">
  <!-- !begin <xsl:value-of select="concat($containing,'/',@name)"/> -->
  <xsl:variable name="descendant-text"> 
  <xsl:apply-templates select="field[@data_type='struct_array' or @data_type='structure']" mode="VALIDATE_DESCENDENTS">
   <xsl:with-param name="currpath" select="$currpath"/>
   <xsl:with-param name="containing" select="concat($containing,'/',@name)"/>
  </xsl:apply-templates>
  </xsl:variable>
  <xsl:if test="normalize-space($descendant-text)"> <xsl:value-of select="$descendant-text"/> </xsl:if>
  <xsl:if test="normalize-space($descendant-validations)"> <xsl:value-of select="$descendant-validations"/>  </xsl:if>
  </xsl:if>
  <xsl:if test="@data_type = 'struct_array'">
  <!-- !begin <xsl:value-of select="concat($containing,'/',@name,'(',substring-before(substring-after(@path_doc,concat('/',@name,'(')),')'),')')"/> -->
  <xsl:variable name="descendant-text"> 
  <xsl:apply-templates select="field[@data_type='struct_array' or @data_type='structure']" mode="VALIDATE_DESCENDENTS">
   <xsl:with-param name="currpath" select="$currpath"/>
   <xsl:with-param name="containing" select="concat($containing,'/',@name,'(',substring-before(substring-after(@path_doc,concat('/',@name,'(')),')'),')')"/>
  </xsl:apply-templates>
  </xsl:variable>
  <xsl:if test="normalize-space($descendant-text) or normalize-space($descendant-validations)">
  for (int <xsl:value-of select="substring-before(substring-after(@path_doc,concat('/',@name,'(')),')')"/>= 0; <xsl:value-of select="substring-before(substring-after(@path_doc,concat('/',@name,'(')),')')"/> &lt; this-&gt;<xsl:value-of select="replace(concat($containing,'.',@name),'/','.')"/>.extent(0); <xsl:value-of select="substring-before(substring-after(@path_doc,concat('/',@name,'(')),')')"/>++) {
  <xsl:value-of select="$descendant-text"/>
  <xsl:value-of select="$descendant-validations"/>
  }
  </xsl:if>
  </xsl:if> 
</xsl:template>


<xsl:template match="field" mode="VALIDATE_CHILD">
    <xsl:choose>
      <xsl:when test="@data_type='structure'">
  // Validation of <xsl:value-of select = "@path"/>
        try{
        <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_1D"> <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/> <xsl:with-param name="containing" select="@name"/> </xsl:apply-templates>
        <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_2D"> <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/> <xsl:with-param name="containing" select="@name"/> </xsl:apply-templates>
        <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_3D"> <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/> <xsl:with-param name="containing" select="@name"/> </xsl:apply-templates>
        <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_4D"> <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/> <xsl:with-param name="containing" select="@name"/> </xsl:apply-templates>
        <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_5D"> <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/> <xsl:with-param name="containing" select="@name"/> </xsl:apply-templates>
        <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_6D"> <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/> <xsl:with-param name="containing" select="@name"/> </xsl:apply-templates>
        <xsl:apply-templates select="field[@data_type='struct_array' or @data_type='structure']" mode="VALIDATE_DESCENDENTS">
        <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/>
        <xsl:with-param name="containing" select="@name"/>
        </xsl:apply-templates>
        this-&gt;<xsl:value-of select="@name"/>.validate(idsTimeMode, idsTimeSize );
        }
        catch (ValidationException ve) {
          throw ValidationException(ve.what());
        }
      </xsl:when>
      <xsl:when test="@data_type='struct_array'">
            <xsl:variable name="act_index">
            <xsl:choose>
                <xsl:when test="contains(@path_doc,'/')">
                <xsl:value-of select="substring-before(substring-after(@path_doc,concat('/',@name,'(')),')')"/>
                </xsl:when>
                <xsl:otherwise>
                <xsl:value-of select="substring-before(substring-after(@path_doc,concat(@name,'(')),')')"/>
                </xsl:otherwise>
            </xsl:choose>
            </xsl:variable>
          arraySize = this-&gt;<xsl:value-of select = "@name"/>.extent(0);
          // Validation of <xsl:value-of select = "@path"/>
          for(int <xsl:value-of select = "$act_index"/> = 0; <xsl:value-of select = "$act_index"/> &lt;arraySize; <xsl:value-of select = "$act_index"/>++)
          {
            try {
                <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_1D"> <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/> <xsl:with-param name="containing" select="concat(@name,'(',$act_index,')')"/> </xsl:apply-templates>
                <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_2D"> <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/> <xsl:with-param name="containing" select="concat(@name,'(',$act_index,')')"/> </xsl:apply-templates>
                <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_3D"> <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/> <xsl:with-param name="containing" select="concat(@name,'(',$act_index,')')"/> </xsl:apply-templates>
                <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_4D"> <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/> <xsl:with-param name="containing" select="concat(@name,'(',$act_index,')')"/> </xsl:apply-templates>
                <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_5D"> <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/> <xsl:with-param name="containing" select="concat(@name,'(',$act_index,')')"/> </xsl:apply-templates>
                <xsl:apply-templates select="." mode="VALIDATE_2_DESCENDANT_6D"> <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/> <xsl:with-param name="containing" select="concat(@name,'(',$act_index,')')"/> </xsl:apply-templates>
                <xsl:apply-templates select="field[@data_type='struct_array' or @data_type='structure']" mode="VALIDATE_DESCENDENTS">
                <xsl:with-param name="currpath" select="normalize-space(../@path_doc)"/>
                <xsl:with-param name="containing" select="concat(@name,'(',$act_index,')')"/>
                </xsl:apply-templates>
                this-&gt;<xsl:value-of select = "@name"/>(<xsl:value-of select = "$act_index"/>).validate(idsTimeMode, idsTimeSize );
			}
            catch (ValidationException ve) {
              std::string errMsg(ve.what());
              errMsg = std::regex_replace(errMsg, std::regex("<xsl:value-of select = "substring-before(substring-after(@path_doc,concat(@name,'(')),')')"/>"),std::to_string(<xsl:value-of select = "$act_index"/>) );
              throw ValidationException(errMsg);
            }
          }
      </xsl:when>
    </xsl:choose>
  </xsl:template>

    <xsl:template match="IDS" mode="VALIDATE_2_DESCENDANT_1D">
<xsl:param name="currpath"/>
<xsl:apply-templates select="descendant-or-self::field[(@data_type='struct_array' or  @data_type='flt_1d_type' or @data_type='FLT_1D'
or @data_type='int_1d_type' or @data_type='INT_1D'
or @data_type='cpx_1d_type' or @data_type='CPX_1D' or @data_type='STR_1D') and (substring-before(@path_doc,concat(@name,'('))='/' or not(contains(@path_doc,('/'))))]" mode="VALIDATE_DESCENDANT_SINGLE">
<xsl:with-param name="currpath" select="$currpath"/>
<xsl:with-param name="dimension" select="'0'"/>
</xsl:apply-templates>
</xsl:template> 

<xsl:template match="IDS" mode="VALIDATE_2_DESCENDANT_2D">
<xsl:param name="currpath"/>
<xsl:apply-templates select="descendant-or-self::field[(@data_type='FLT_2D' or @data_type='INT_2D' or @data_type='CPX_2D') and (substring-before(@path_doc,concat(@name,'('))='/' or not(contains(@path_doc,('/'))))]" mode="VALIDATE_DESCENDANT_SINGLE_2D">
<xsl:with-param name="currpath" select="$currpath"/>
</xsl:apply-templates>
</xsl:template> 

<xsl:template match="IDS" mode="VALIDATE_2_DESCENDANT_3D">
<xsl:param name="currpath"/>
<xsl:apply-templates select="descendant-or-self::field[(@data_type='FLT_3D' or @data_type='INT_3D' or @data_type='CPX_3D') and (substring-before(@path_doc,concat(@name,'('))='/' or not(contains(@path_doc,('/'))))]" mode="VALIDATE_DESCENDANT_SINGLE_3D">
<xsl:with-param name="currpath" select="$currpath"/>
</xsl:apply-templates>
</xsl:template> 

<xsl:template match="IDS" mode="VALIDATE_2_DESCENDANT_4D">
<xsl:param name="currpath"/>
<xsl:apply-templates select="descendant-or-self::field[(@data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D') and (substring-before(@path_doc,concat(@name,'('))='/' or not(contains(@path_doc,('/'))))]" mode="VALIDATE_DESCENDANT_SINGLE_4D">
<xsl:with-param name="currpath" select="$currpath"/>
</xsl:apply-templates>
</xsl:template> 

<xsl:template match="IDS" mode="VALIDATE_2_DESCENDANT_5D">
<xsl:param name="currpath"/>
<xsl:apply-templates select="descendant-or-self::field[(@data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D') and (substring-before(@path_doc,concat(@name,'('))='/' or not(contains(@path_doc,('/'))))]" mode="VALIDATE_DESCENDANT_SINGLE_5D">
<xsl:with-param name="currpath" select="$currpath"/>
</xsl:apply-templates>
</xsl:template> 

<xsl:template match="IDS" mode="VALIDATE_2_DESCENDANT_6D">
<xsl:param name="currpath"/>
<xsl:apply-templates select="descendant-or-self::field[(@data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D') and (substring-before(@path_doc,concat(@name,'('))='/' or not(contains(@path_doc,('/'))))]" mode="VALIDATE_DESCENDANT_SINGLE_6D">
<xsl:with-param name="currpath" select="$currpath"/>
</xsl:apply-templates>
</xsl:template> 

<xsl:template match="field" mode="VALIDATE_2_DESCENDANT_1D">
<xsl:param name="currpath"/>
<xsl:param name="containing"/>
<xsl:apply-templates select="descendant-or-self::field[(@data_type='struct_array' or  @data_type='flt_1d_type' or @data_type='FLT_1D'
or @data_type='int_1d_type' or @data_type='INT_1D'
or @data_type='cpx_1d_type' or @data_type='CPX_1D' or @data_type='STR_1D') and contains(@path_doc,$containing) and substring-before(concat('/',substring-after(@path_doc,concat($containing,'/'))),concat(@name,'('))='/']" mode="VALIDATE_DESCENDANT_SINGLE">
<xsl:with-param name="currpath" select="$currpath"/>
<xsl:with-param name="dimension" select="'0'"/>
</xsl:apply-templates>
</xsl:template> 

<xsl:template match="field" mode="VALIDATE_2_DESCENDANT_2D">
<xsl:param name="currpath"/>
<xsl:param name="containing"/>
<xsl:apply-templates select="descendant-or-self::field[(@data_type='FLT_2D' or @data_type='INT_2D' or @data_type='CPX_2D') and contains(@path_doc,$containing) and substring-before(concat('/',substring-after(@path_doc,concat($containing,'/'))),concat(@name,'('))='/']" mode="VALIDATE_DESCENDANT_SINGLE_2D">
<xsl:with-param name="currpath" select="$currpath"/>
</xsl:apply-templates>
</xsl:template> 

<xsl:template match="field" mode="VALIDATE_2_DESCENDANT_3D">
<xsl:param name="currpath"/>
<xsl:param name="containing"/>
<xsl:apply-templates select="descendant-or-self::field[(@data_type='FLT_3D' or @data_type='INT_3D' or @data_type='CPX_3D') and contains(@path_doc,$containing) and substring-before(concat('/',substring-after(@path_doc,concat($containing,'/'))),concat(@name,'('))='/']" mode="VALIDATE_DESCENDANT_SINGLE_3D">
<xsl:with-param name="currpath" select="$currpath"/>
</xsl:apply-templates>
</xsl:template> 

<xsl:template match="field" mode="VALIDATE_2_DESCENDANT_4D">
<xsl:param name="currpath"/>
<xsl:param name="containing"/>
<xsl:apply-templates select="descendant-or-self::field[(@data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D') and contains(@path_doc,$containing) and substring-before(concat('/',substring-after(@path_doc,concat($containing,'/'))),concat(@name,'('))='/']" mode="VALIDATE_DESCENDANT_SINGLE_4D">
<xsl:with-param name="currpath" select="$currpath"/>
</xsl:apply-templates>
</xsl:template> 

<xsl:template match="field" mode="VALIDATE_2_DESCENDANT_5D">
<xsl:param name="currpath"/>
<xsl:param name="containing"/>
<xsl:apply-templates select="descendant-or-self::field[(@data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D') and contains(@path_doc,$containing) and substring-before(concat('/',substring-after(@path_doc,concat($containing,'/'))),concat(@name,'('))='/']" mode="VALIDATE_DESCENDANT_SINGLE_5D">
<xsl:with-param name="currpath" select="$currpath"/>
</xsl:apply-templates>
</xsl:template> 

<xsl:template match="field" mode="VALIDATE_2_DESCENDANT_6D">
<xsl:param name="currpath"/>
<xsl:param name="containing"/>
<xsl:apply-templates select="descendant-or-self::field[(@data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D') and contains(@path_doc,$containing) and substring-before(concat('/',substring-after(@path_doc,concat($containing,'/'))),concat(@name,'('))='/']" mode="VALIDATE_DESCENDANT_SINGLE_6D">
<xsl:with-param name="currpath" select="$currpath"/>
</xsl:apply-templates>
</xsl:template> 


    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE_2D">
      <xsl:param name="currpath"/>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'0'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'1'"/>
      </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE_3D">
      <xsl:param name="currpath"/>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'0'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'1'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'2'"/>
      </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE_4D">
      <xsl:param name="currpath"/>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'0'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'1'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'2'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'3'"/>
      </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE_5D">
      <xsl:param name="currpath"/>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'0'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'1'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'2'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'3'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'4'"/>
      </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE_6D">
      <xsl:param name="currpath"/>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'0'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'1'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'2'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'3'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'4'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'5'"/>
      </xsl:apply-templates>
    </xsl:template> 

    <!-- write the check statements to check the <dimension> of the current field -->
    <!-- <currpath> is the deeper comon ancestor of the reference coordinate and the current field -->
    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:param name="currpath"/>
    <xsl:param name="dimension"/>
    <xsl:variable name="coord_same_as">
    <xsl:apply-templates select="." mode="get_coordinate_string">
      <xsl:with-param name="dimension" select="$dimension"/>
      <xsl:with-param name="same_as" select="'yes'"/>
    </xsl:apply-templates>
    </xsl:variable>

    <xsl:if test="not($coord_same_as='1...N')">
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE_CHECKS">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="$dimension"/>
        <xsl:with-param name="coord" select="$coord_same_as"/>
        <xsl:with-param name="targetdim" select="$dimension"/>
      </xsl:apply-templates>
    </xsl:if>


    <xsl:variable name="coord">
    <xsl:apply-templates select="." mode="get_coordinate_string">
      <xsl:with-param name="dimension" select="$dimension"/>
      <xsl:with-param name="same_as" select="'no'"/>
    </xsl:apply-templates>
    </xsl:variable>

        <xsl:if test="not($coord='1...N')">
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE_CHECKS">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="$dimension"/>
        <xsl:with-param name="coord" select="$coord"/>
        <xsl:with-param name="targetdim" select="'0'"/>
      </xsl:apply-templates>
    </xsl:if>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE_CHECKS">
    <xsl:param name="currpath"/>
    <xsl:param name="dimension"/>
    <xsl:param name="coord"/>
    <xsl:param name="targetdim"/>
    <xsl:variable name="ispresent">
      <xsl:choose>
      <xsl:when test="$currpath='' and not($coord='') and not(contains($coord, '1...'))">
          <xsl:value-of select="'yes'"/>
      </xsl:when>
      <xsl:when test="contains($coord,'OR')">
      <xsl:apply-templates select="ancestor::field[@path_doc = $currpath]" mode="ISPRESENT_PATH_DOC">
        <xsl:with-param name="path_doc_to_check" select="substring-before($coord,' OR')"/>
      </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="ancestor::field[@path_doc = $currpath]" mode="ISPRESENT_PATH_DOC">
        <xsl:with-param name="path_doc_to_check" select="$coord"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
    </xsl:variable>
     <xsl:variable name="prefix" select="substring-before(@path_doc,concat('/',@name,'('))"/>
    <!-- find the relative coordinate from the current field path and the target field path -->
    <xsl:variable name="relativecoord">
    <xsl:if test="not($currpath='')">
    <xsl:choose>
      <xsl:when test="contains($coord,'OR')">
        <xsl:value-of select="substring-after(substring-before($coord,'OR'),concat($currpath,'/'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring-after($coord,concat($currpath,'/'))"/>
      </xsl:otherwise>
    </xsl:choose>
    </xsl:if>
    <xsl:if test="$currpath=''">
    <xsl:choose>
      <xsl:when test="contains($coord,'OR')">
        <xsl:value-of select="substring-before($coord,'OR')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$coord"/>
      </xsl:otherwise>
    </xsl:choose>
    </xsl:if>
    </xsl:variable>
      <!-- find the relative coordinate from the current field path and the checked field -->
    <!-- <xsl:variable name="relativepath" select="substring-after(concat($prefix,'/',@name),concat($currpath,'/'))"/> -->
    <xsl:variable name="relativepath">
    <xsl:if test="not($currpath='')">
        <xsl:value-of select="substring-after(concat($prefix,'/',@name),concat($currpath,'/'))"/>
    </xsl:if>
    <xsl:if test="$currpath=''">
        <xsl:value-of select="$prefix"/>
    </xsl:if>
    </xsl:variable>
    <xsl:variable name="child">
      <xsl:choose>
          <xsl:when test="contains($relativepath,'/')">
          <xsl:value-of select="substring-before($relativepath,'/')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$relativepath"/>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:variable>
    <!-- verify if the current field is the deeper common ancestor of the target coordinate field and the checked field -->
    <xsl:variable name="test">
      <xsl:choose>
        <!-- validation logic: the time coordinate are passed by argument of each validation routines so no need to check if at level of IDS -->
        <xsl:when test="($coord='time' or contains($coord,'IDS:')) and $currpath=''">
          <xsl:value-of select="''"/>
        </xsl:when>
        <xsl:when test="contains($relativecoord,'/')">
          <xsl:value-of select="$child=substring-before($relativecoord,'/')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$child=$relativecoord"/>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:variable> 
	<xsl:variable name="root">
        <xsl:if test="not($currpath='')">
                            <xsl:value-of select="concat($currpath,'/')"/>
        </xsl:if>
        <xsl:if test="$currpath=''">
          <xsl:value-of select="concat($currpath,'/')"/>
        </xsl:if>
        </xsl:variable>
	<xsl:variable name="onecoord">
        <xsl:if test="not(contains($coord,' OR'))">
           <xsl:value-of select="$coord"/>
        </xsl:if>
        <xsl:if test="contains($coord,' OR')">
          <xsl:value-of select="substring-before($coord,' OR')"/>
        </xsl:if>
        </xsl:variable>
	<xsl:variable name="is-index-dep">
	<xsl:if test="$root='/'">
          <xsl:if test="contains($onecoord,'(itime') and not(contains($onecoord,'(itime)/time'))">
          <xsl:value-of select="'yes'"/>
        </xsl:if>
	</xsl:if>
	<xsl:if test="not($root='/')">
	  <xsl:if test="contains(substring-after($onecoord,$root),'(itime') and not(contains($onecoord,'(itime)/time'))">
          <xsl:value-of select="'yes'"/>
        </xsl:if>
        </xsl:if>
	</xsl:variable>
    <!-- missing IDS coordinate exception--> 
    <xsl:if test="starts-with($coord,$currpath) and contains($ispresent,'yes')  and not($is-index-dep='yes')">
      <xsl:if test="$test='false'">
    // validation of <xsl:value-of select="@path"/> dimension <xsl:value-of select="number($dimension)"/>
        <xsl:variable name="newpath">
          <xsl:if test="not($currpath='')">
            <xsl:value-of select="substring-after(@path,concat(ancestor::field[@path_doc = $currpath]/@path,'/'))"/>
          </xsl:if>
          <xsl:if test="$currpath=''">
            <xsl:value-of select="@path"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="root">
          <xsl:if test="not($currpath='')">
            <xsl:value-of select="concat($currpath,'/')"/>
          </xsl:if>
          <xsl:if test="$currpath=''">
            <xsl:value-of select="concat($currpath,'/')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:apply-templates select="." mode="VALIDATE_PATH_SINGLE">
        <xsl:with-param name="newpath" select="$newpath"/>
        <xsl:with-param name="root" select="$root"/>
        <xsl:with-param name="string" select="''"/>
        <xsl:with-param name="dimension" select="$dimension"/>
        <xsl:with-param name="coord" select="$coord"/>
        <xsl:with-param name="targetdim" select="$targetdim"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:if>
    </xsl:template>

    <!-- return yes if some field exist like @path_doc equals to the parameter path_doc_to_check -->
    <xsl:template match="field" mode="ISPRESENT_PATH_DOC">
    <xsl:param name="path_doc_to_check"/>
      <xsl:if test="descendant-or-self::field[contains(@path_doc,$path_doc_to_check)]">
        <xsl:value-of select="'yes'"/>
      </xsl:if >
    </xsl:template> 


   <xsl:template match="field" mode="get_coordinate_string">
    <xsl:param name="dimension"/>
    <xsl:param name="same_as"/>
      <xsl:choose>
        <xsl:when test="$dimension='0'">
          <xsl:if test="$same_as='yes'">
          <xsl:value-of select="@coordinate1_same_as"/>
          </xsl:if>
          <xsl:if test="not($same_as='yes')">
          <xsl:value-of select="@coordinate1"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$dimension='1'">
          <xsl:if test="$same_as='yes'">
          <xsl:value-of select="@coordinate2_same_as"/>
          </xsl:if>
          <xsl:if test="not($same_as='yes')">
          <xsl:value-of select="@coordinate2"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$dimension='2'">
          <xsl:if test="$same_as='yes'">
          <xsl:value-of select="@coordinate3_same_as"/>
          </xsl:if>
          <xsl:if test="not($same_as='yes')">
          <xsl:value-of select="@coordinate3"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$dimension='3'">
          <xsl:if test="$same_as='yes'">
          <xsl:value-of select="@coordinate4_same_as"/>
          </xsl:if>
          <xsl:if test="not($same_as='yes')">
          <xsl:value-of select="@coordinate4"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$dimension='4'">
          <xsl:if test="$same_as='yes'">
          <xsl:value-of select="@coordinate5_same_as"/>
          </xsl:if>
          <xsl:if test="not($same_as='yes')">
          <xsl:value-of select="@coordinate5"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$dimension='5'">
          <xsl:if test="$same_as='yes'">
          <xsl:value-of select="@coordinate6_same_as"/>
          </xsl:if>
          <xsl:if test="not($same_as='yes')">
          <xsl:value-of select="@coordinate6"/>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:template>

    <xsl:template match="field" mode="VALIDATE_PATH_SINGLE">
      <xsl:param name="newpath"/>
      <xsl:param name="root"/>
      <xsl:param name="string"/>
      <xsl:param name="dimension"/>
      <xsl:param name="coord"/>
      <xsl:param name="targetdim"/>
      <xsl:if test="contains($newpath,'/')">
      <xsl:choose>
        <xsl:when test="ancestor::field[@name = substring-before($newpath,'/')]/@data_type='structure'">
          <xsl:variable name="act_struct" select="ancestor::field[@name = substring-before($newpath,'/')]/@name" />
          <xsl:apply-templates select="." mode="VALIDATE_PATH_SINGLE">
          <xsl:with-param name="newpath" select="substring-after($newpath,'/')"/>
          <xsl:with-param name="root" select="$root"/>
          <xsl:with-param name="string" select="concat($string,$act_struct,'.')"/>
          <xsl:with-param name="dimension" select="$dimension"/>
          <xsl:with-param name="coord" select="$coord"/>
          <xsl:with-param name="targetdim" select="$targetdim"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="ancestor::field[@name = substring-before($newpath,'/')]/@data_type='struct_array'">
        <xsl:variable name="act_struct" select="ancestor::field[@name = substring-before($newpath,'/')]/@name" />
        <xsl:variable name="act_index" select="substring-before(substring-after(ancestor::field[@name = substring-before($newpath,'/')]/@path_doc,concat($act_struct,'(')),')')"/>
        <!-- indicesStr.push_back("<xsl:value-of select="$act_index"/>");
        for(int <xsl:value-of select="$act_index"/>=0; <xsl:value-of select="$act_index"/>&lt;this-><xsl:value-of select="$string"/><xsl:value-of select="$act_struct"/>.extent(0); <xsl:value-of select="$act_index"/>++) {
          indicesVal.push_back(<xsl:value-of select="$act_index"/>); -->
          <xsl:variable name="act_index">
            <xsl:if test="contains(ancestor::field[@name = substring-before($newpath,'/')]/@path_doc,'/')">
            <xsl:value-of select="substring-before(substring-after(ancestor::field[@name = substring-before($newpath,'/')]/@path_doc,concat('/',$act_struct,'(')),')')"/>
            </xsl:if>
            <xsl:if test="not(contains(ancestor::field[@name = substring-before($newpath,'/')]/@path_doc,'/'))">
            <xsl:value-of select="substring-before(substring-after(ancestor::field[@name = substring-before($newpath,'/')]/@path_doc,concat($act_struct,'(')),')')"/>
            </xsl:if>
          </xsl:variable>
          <xsl:apply-templates select="." mode="VALIDATE_PATH_SINGLE">
          <xsl:with-param name="newpath" select="substring-after($newpath,'/')"/>
          <xsl:with-param name="root" select="$root"/>
          <xsl:with-param name="string" select="concat($string,$act_struct,'(',$act_index,').')"/>
          <xsl:with-param name="dimension" select="$dimension"/>
          <xsl:with-param name="coord" select="$coord"/>
          <xsl:with-param name="targetdim" select="$targetdim"/>
          </xsl:apply-templates>
          <!-- indicesVal.pop_back();
          }
          indicesStr.pop_back(); -->
        </xsl:when>
      </xsl:choose>
      </xsl:if>

      <xsl:variable name="istimeslice">
  <xsl:if test="contains($coord,' OR')">
	<xsl:if test="not($root='/')">
		<xsl:if test="contains(substring-before(substring-after($coord,$root),' OR'),'(itime)')">
		<xsl:if test="not(contains(concat($string,@name),'(itime)'))">
			<xsl:value-of select="'yes'"/>
		</xsl:if>
		</xsl:if>
	</xsl:if>
	<xsl:if test="$root='/'">
		<xsl:if test="contains(substring-before($coord,' OR'),'(itime)')">
		<xsl:if test="not(contains(concat($string,@name),'(itime)'))">
			<xsl:value-of select="'yes'"/>
		</xsl:if>
		</xsl:if>
	</xsl:if>
  </xsl:if>
  <xsl:if test="not($root='/')">
  <xsl:if test="not(contains($coord,' OR'))">
    <xsl:if test="contains(substring-after($coord,$root),'(itime)')">
      <xsl:if test="not(contains(concat($string,@name),'(itime)'))">
        <xsl:value-of select="'yes'"/>
      </xsl:if>
    </xsl:if>
  </xsl:if>
  </xsl:if>
  <xsl:if test="$root='/'">
	<xsl:if test="not(contains($coord,' OR'))">
		<xsl:if test="contains($coord,'(itime)')">
		<xsl:if test="not(contains(concat($string,@name),'(itime)'))">
			<xsl:value-of select="'yes'"/>
		</xsl:if>
		</xsl:if>
	</xsl:if>
  </xsl:if>
  </xsl:variable>
  <xsl:if test="not(contains($newpath,'/')) and not($istimeslice='yes')"><!-- and ( (contains($string,'(itime)') and contains($coord,'(itime)')) or  (not(contains($string,'(itime)')) and not(contains($coord,'(itime)'))) )-->
        arraySize = this-><xsl:value-of select="$string"/><xsl:value-of select="@name"/>.extent(<xsl:value-of select="number($dimension)"/>);
        if (arraySize > 0) {
		<xsl:if test="@type='dynamic' and ends-with($coord,'/time')">
        if (idsTimeMode == IDS_TIME_MODE_HETEROGENEOUS ) {
        </xsl:if>
          check = true;
          error = true;
          i = 0;
          <xsl:apply-templates select="." mode="check-target-indices"><xsl:with-param name="coord" select="$coord"/><xsl:with-param name="relativepathdoc" select="$root"/></xsl:apply-templates>
          <xsl:apply-templates select="." mode="possible-coordinates"><xsl:with-param name="coord" select="$coord"/><xsl:with-param name="relativepathdoc" select="$root"/><xsl:with-param name="self" select="concat($string,@name)"/></xsl:apply-templates>
          if (i&gt;1) { 
            std::string errMsg("Element '<xsl:value-of select="@path_doc"/>' must have its coordinate in dimension <xsl:value-of select="number($dimension)"/> (any of <xsl:value-of select="$coord"/>) filled.");
            for(int id=0; id&lt;indicesStr.size();id++) errMsg = std::regex_replace(errMsg, std::regex(indicesStr[id]),std::to_string(indicesVal[id]));
            throw ValidationException(errMsg);
          }
          if(check) {
            <xsl:apply-templates select="." mode="check-possible-coordinates">
              <xsl:with-param name="coord" select="$coord"/>
              <xsl:with-param name="relativepathdoc" select="$root"/>
              <xsl:with-param name="dimension" select="$dimension"/>
              <xsl:with-param name="self" select="concat($string,@name)"/>
              <xsl:with-param  name="targetdim" select="$targetdim"/>
            </xsl:apply-templates> 
          }

            <xsl:apply-templates select="." mode="check-specific-coordinates">
              <xsl:with-param name="coord" select="$coord"/>
              <xsl:with-param name="relativepathdoc" select="$root"/>
              <xsl:with-param name="dimension" select="$dimension"/>
              <xsl:with-param name="self" select="concat($string,@name)"/>
            </xsl:apply-templates>
          if (error) { 
            std::string errMsg("Element '<xsl:value-of select="@path_doc"/>' must have its coordinate in dimension <xsl:value-of select="number($dimension)"/> (any of <xsl:value-of select="$coord"/>) filled.");
            for(int id=0; id&lt;indicesStr.size();id++) errMsg = std::regex_replace(errMsg, std::regex(indicesStr[id]),std::to_string(indicesVal[id]));
            throw ValidationException(errMsg);
          }
      <xsl:if test="@type='dynamic' and ends-with($coord,'/time')">
        }
        if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS ) {
          if(arraySize != idsTimeSize) {
            std::stringstream shapestrss;
            shapestrss &lt;&lt; this-><xsl:value-of select="$string"/><xsl:value-of select="@name"/>.shape();
            std::string errMsg("Element '<xsl:value-of select="@path_doc"/>' has incorrect shape "+shapestrss.str()+": its coordinate in dimension 1 ('time') has size "+std::to_string(idsTimeSize)+".");
            for(int id=0; id&lt;indicesStr.size();id++) errMsg = std::regex_replace(errMsg, std::regex(indicesStr[id]),std::to_string(indicesVal[id]));
            throw ValidationException(errMsg);
          }
        }
        if (idsTimeMode == IDS_TIME_MODE_INDEPENDENT ) {
          if(arraySize != 0) {
			      std::stringstream shapestrss;
		        shapestrss &lt;&lt; this-><xsl:value-of select="$string"/><xsl:value-of select="@name"/>.shape();
            std::string errMsg("Element '<xsl:value-of select="@path_doc"/> ' has incorrect shape "+shapestrss.str()+": dimension 1 must have size 0.");
            for(int id=0; id&lt;indicesStr.size();id++) errMsg = std::regex_replace(errMsg, std::regex(indicesStr[id]),std::to_string(indicesVal[id]));
            throw ValidationException(errMsg);
          }
        }
        </xsl:if>
	 	}
      </xsl:if> 
      <xsl:if test="not(contains($newpath,'/')) and $istimeslice='yes'">
      <xsl:if test="@type='dynamic' and ends-with($coord,'/time')">
      arraySize = this-><xsl:value-of select="$string"/><xsl:value-of select="@name"/>.extent(<xsl:value-of select="number($dimension)"/>);
      if (arraySize != 0) {
      if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS ) {
        if(arraySize != idsTimeSize) {
			      std::stringstream shapestrss;
			      shapestrss &lt;&lt; this-><xsl:value-of select="$string"/><xsl:value-of select="@name"/>.shape();
            std::string errMsg("Element '<xsl:value-of select="@path_doc"/>' has incorrect shape "+shapestrss.str()+": its coordinate in dimension <xsl:value-of select="number($dimension)+1"/> ('time') has size "+std::to_string(idsTimeSize)+".");
            for(int id=0; id&lt;indicesStr.size();id++) errMsg = std::regex_replace(errMsg, std::regex(indicesStr[id]),std::to_string(indicesVal[id]));
            throw ValidationException(errMsg);
            }
        }
      }
      if (idsTimeMode == IDS_TIME_MODE_HETEROGENEOUS ) {
        for (int itime = 0; itime&lt;arraySize;itime++) {
            if (!(this-><xsl:value-of select="@name"/>(itime).time != EMPTY_DOUBLE)) { 
              std::string errMsg("Time coordinate of '<xsl:value-of select="@name"/>' (<xsl:value-of select="@name"/>(itime)/time) has empty values.");
              for(int id=0; id&lt;indicesStr.size();id++) errMsg = std::regex_replace(errMsg, std::regex(indicesStr[id]),std::to_string(indicesVal[id]));
              throw ValidationException(errMsg);
            }
          }
        }
      </xsl:if>
      </xsl:if>
      </xsl:template> 

      <xsl:template match='field' mode="possible-coordinates">
      <xsl:param name="coord"/>
      <xsl:param name="relativepathdoc"/>
      <xsl:param name="self"/>
      <xsl:if test="contains($coord,' OR')">
      <xsl:variable name="target">
          <xsl:if test="not($relativepathdoc='/')">
            <xsl:value-of select="replace(substring-before(substring-after($coord,$relativepathdoc),' OR'),'/','.')"/>
          </xsl:if>
          <xsl:if test="$relativepathdoc='/'">
              <xsl:value-of select="replace(substring-before($coord,' OR'),'/','.')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="resolved_target">
        <xsl:apply-templates select="." mode="resolve_indices">
          <xsl:with-param name="target" select="$target"/>
          <xsl:with-param name="string-resolved" select="''"/>
        </xsl:apply-templates>
        </xsl:variable>
      <xsl:if test="not(contains(substring-before($coord,' OR'),'1...'))">
          if (this-><xsl:value-of select="$resolved_target"/>.extent(0) != 0) i = i + 1;
      </xsl:if>
      <xsl:apply-templates select="." mode="possible-coordinates">
        <xsl:with-param name="coord" select="substring-after($coord,' OR')"/>
        <xsl:with-param name="relativepathdoc" select="$relativepathdoc"/>
        <xsl:with-param name="self" select="$self"/>
      </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="not(contains($coord,' OR'))">
       <xsl:variable name="target">
        <xsl:if test="not($relativepathdoc='/')">
          <xsl:value-of select="replace(substring-after($coord,$relativepathdoc),'/','.')"/>
        </xsl:if>
        <xsl:if test="$relativepathdoc='/'">
            <xsl:value-of select="replace($coord,'/','.')"/>
        </xsl:if>
      </xsl:variable>
      <xsl:variable name="resolved_target">
      <xsl:apply-templates select="." mode="resolve_indices">
        <xsl:with-param name="target" select="$target"/>
        <xsl:with-param name="string-resolved" select="''"/>
      </xsl:apply-templates>
      </xsl:variable>
      <xsl:if test="not(contains($coord,'1...'))">
			if (this-><xsl:value-of select="$resolved_target"/>.extent(0) != 0) i = i + 1;
      </xsl:if>
          if (i!=1) { 
            check = false;
          } 
      </xsl:if>
      </xsl:template>

      <xsl:template match='field' mode="resolve_indices">
      <xsl:param name="target"/>
      <xsl:param name="string-resolved"/>
      <xsl:if test="contains($target,'(')">
        <xsl:variable name="indexstr">
          <xsl:apply-templates select="." mode="get_indices">
            <xsl:with-param name="target" select="$target"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="resolved_indexstr">
        <xsl:if test="matches($indexstr, '^[0-9]+$')">
          <xsl:value-of select="number($indexstr)-1"/>
        </xsl:if>
        <xsl:if test="matches($indexstr, '^itime|i[1-9]$')">
          <xsl:value-of select="$indexstr"/>
        </xsl:if>
        <xsl:if test="not(matches($indexstr, '^[0-9]+$') or matches($indexstr, '^itime|i[1-9]$'))">
          <xsl:value-of select="concat('this->',$indexstr,'-1')"/>
        </xsl:if>
        </xsl:variable>
        <xsl:apply-templates select="." mode="resolve_indices">
            <xsl:with-param name="target" select="substring-after($target,concat($indexstr,')'))"/>
            <xsl:with-param name="string-resolved" select="concat($string-resolved,substring-before($target,concat($indexstr,')')), concat($resolved_indexstr,')'))"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="not(contains($target,'('))">
        <xsl:value-of select="concat($string-resolved, $target)"/>
      </xsl:if>
      </xsl:template>

      <!-- the get_indices function return the sub-string between parenthesis
            process(i1)/coordinate_index ===> i1
            struct(process(i1)/coordinate_index)/substruc ===> process(i1)/coordinate_index
      -->
      <xsl:template match='field' mode="get_indices">
      <xsl:param name="target"/>
      <xsl:variable name="partialindex" select="substring-before(substring-after($target,'('),')')"/>
      <xsl:if test="contains($partialindex,'(')">
        <xsl:value-of select="concat($partialindex,')',substring-before(substring-after($target,concat($partialindex,')')),')'))"/>
        <!-- <xsl:value-of select="concat($partialindex,substring-before(substring-after($target,concat($partialindex,')')),')'))"/> -->
      </xsl:if>
      <xsl:if test="not(contains($partialindex,'('))">
        <xsl:value-of select="$partialindex"/>
      </xsl:if>
      </xsl:template>


      <xsl:template match='field' mode="check-possible-coordinates">
      <xsl:param name="coord"/>
      <xsl:param name="relativepathdoc"/>
      <xsl:param name="dimension"/>
      <xsl:param name="self"/>
      <xsl:param name="targetdim"/>
      <xsl:if test="contains($coord,' OR')">
            <xsl:variable name="target">
              <xsl:if test="not($relativepathdoc='/')">
                <xsl:value-of select="replace(substring-before(substring-after($coord,$relativepathdoc),' OR'),'/','.')"/>
              </xsl:if>
              <xsl:if test="$relativepathdoc='/'">
                  <xsl:value-of select="replace(substring-before($coord,' OR'),'/','.')"/>
              </xsl:if>
            </xsl:variable>
            <xsl:variable name="resolved_target">
            <xsl:apply-templates select="." mode="resolve_indices">
              <xsl:with-param name="target" select="$target"/>
              <xsl:with-param name="string-resolved" select="''"/>
            </xsl:apply-templates>
            </xsl:variable>
            <xsl:if test="not(contains(substring-before($coord,' OR'),'1...'))">
            if (this-><xsl:value-of select="$resolved_target"/>.extent(0)) {
              if (arraySize == this-><xsl:value-of select="$resolved_target"/>.extent(<xsl:value-of select="number($targetdim)"/>)) {
                error = false;
              } 
              <xsl:if test="not(contains($coord,'1...'))">
              else {
                if (this-><xsl:value-of select="$resolved_target"/>.extent(<xsl:value-of select="number($targetdim)"/>)!=0) {
                  std::stringstream shapestrss;
                  shapestrss &lt;&lt; this-><xsl:value-of select="$self"/>.shape();
                  std::string errMsg("Element '<xsl:value-of select="@path_doc"/>' has incorrect shape "+shapestrss.str()+": its coordinate in dimension <xsl:value-of select="number($dimension)+1"/> (<xsl:value-of select="substring-before($coord,' OR')"/>) has size "+std::to_string(this-><xsl:value-of select="$resolved_target"/>.extent(<xsl:value-of select="number($targetdim)"/>))+".");
                  for(int id=0; id&lt;indicesStr.size();id++) errMsg = std::regex_replace(errMsg, std::regex(indicesStr[id]),std::to_string(indicesVal[id]));
                  throw ValidationException(errMsg);
                }
			        }
        </xsl:if>
            } 
            </xsl:if>
      <xsl:apply-templates select="." mode="check-possible-coordinates">
        <xsl:with-param name="coord" select="substring-after($coord,' OR')"/>
        <xsl:with-param name="relativepathdoc" select="$relativepathdoc"/>
        <xsl:with-param  name="dimension" select="$dimension"/>
        <xsl:with-param  name="self" select="$self"/>
        <xsl:with-param  name="targetdim" select="$targetdim"/>
      </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="not(contains($coord,' OR'))">
            <xsl:variable name="target">
              <xsl:if test="not($relativepathdoc='/')">
                <xsl:value-of select="replace(substring-after($coord,$relativepathdoc),'/','.')"/>
              </xsl:if>
              <xsl:if test="$relativepathdoc='/'">
                  <xsl:value-of select="replace($coord,'/','.')"/>
              </xsl:if>
            </xsl:variable>
            <xsl:variable name="resolved_target">
            <xsl:apply-templates select="." mode="resolve_indices">
              <xsl:with-param name="target" select="$target"/>
              <xsl:with-param name="string-resolved" select="''"/>
            </xsl:apply-templates>
            </xsl:variable>
            <xsl:if test="not(contains($coord,'1...'))">
			if (this-><xsl:value-of select="$resolved_target"/>.extent(0)) {
				if (arraySize == this-><xsl:value-of select="$resolved_target"/>.extent(<xsl:value-of select="number($targetdim)"/>)) {
					error = false;
				} else {
					if (this-><xsl:value-of select="$resolved_target"/>.extent(<xsl:value-of select="number($targetdim)"/>)!=0) {
						std::stringstream shapestrss;
						shapestrss &lt;&lt; this-><xsl:value-of select="$self"/>.shape();
					  std::string errMsg("Element '<xsl:value-of select="@path_doc"/>' has incorrect shape "+shapestrss.str()+": its coordinate in dimension <xsl:value-of select="number($dimension)+1"/> (<xsl:value-of select="$coord"/>) has size "+std::to_string(this-><xsl:value-of select="$resolved_target"/>.extent(<xsl:value-of select="number($targetdim)"/>))+".");
            for(int id=0; id&lt;indicesStr.size();id++) errMsg = std::regex_replace(errMsg, std::regex(indicesStr[id]),std::to_string(indicesVal[id]));
            throw ValidationException(errMsg);
          }
				}
			} 
            </xsl:if>
      </xsl:if>
      </xsl:template>

      <xsl:template match='field' mode="check-specific-coordinates">
      <xsl:param name="coord"/>
      <xsl:param name="relativepathdoc"/>
      <xsl:param name="dimension"/>
      <xsl:param name="self"/>
      <xsl:if test="contains($coord,' OR')">
            <xsl:variable name="target" select="replace(substring-before(substring-after($coord,$relativepathdoc),' OR'),'/','.')"/>
            <xsl:if test="contains(substring-before($coord,' OR'),'1...')">
            if (error &amp;&amp; arraySize == <xsl:value-of select="substring-after($coord,'1...')"/>) {  
            error = false; 
	          }
            </xsl:if>
      <xsl:apply-templates select="." mode="check-specific-coordinates">
        <xsl:with-param name="coord" select="substring-after($coord,' OR')"/>
        <xsl:with-param name="relativepathdoc" select="$relativepathdoc"/>
        <xsl:with-param  name="dimension" select="$dimension"/>
        <xsl:with-param  name="self" select="$self"/>
      </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="not(contains($coord,' OR'))">
            <xsl:variable name="target" select="replace(substring-after($coord,$relativepathdoc),'/','.')"/>
            <xsl:if test="contains($coord,'1...')">
            if (error &amp;&amp; arraySize == <xsl:value-of select="substring-after($coord,'1...')"/>) {   
            error = false; 
            }
            </xsl:if>
      </xsl:if>
      </xsl:template>

      <xsl:template match="field" mode="VALIDATE_CHILD_FIXED_SIZE">
        <xsl:choose>
          <xsl:when test="@data_type='struct_array' or @data_type='flt_1d_type' or @data_type='FLT_1D'
              or @data_type='int_1d_type' or @data_type='INT_1D'
              or @data_type='cpx_1d_type' or @data_type='CPX_1D'">

              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate1"/>
                <xsl:with-param name="dimension" select="'0'"/>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="@data_type='FLT_2D' or @data_type='INT_2D' or @data_type='CPX_2D'">

              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate1"/>
                <xsl:with-param name="dimension" select="'0'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate2"/>
                <xsl:with-param name="dimension" select="'1'"/>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="@data_type='FLT_3D' or @data_type='INT_3D' or @data_type='CPX_3D'">

              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate1"/>
                <xsl:with-param name="dimension" select="'0'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate2"/>
                <xsl:with-param name="dimension" select="'1'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate3"/>
                <xsl:with-param name="dimension" select="'2'"/>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="@data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D'">

              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate1"/>
                <xsl:with-param name="dimension" select="'0'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate2"/>
                <xsl:with-param name="dimension" select="'1'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate3"/>
                <xsl:with-param name="dimension" select="'2'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate4"/>
                <xsl:with-param name="dimension" select="'3'"/>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="@data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D'">

              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate1"/>
                <xsl:with-param name="dimension" select="'0'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate2"/>
                <xsl:with-param name="dimension" select="'1'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate3"/>
                <xsl:with-param name="dimension" select="'2'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate4"/>
                <xsl:with-param name="dimension" select="'3'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate5"/>
                <xsl:with-param name="dimension" select="'4'"/>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="@data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D'">

              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate1"/>
                <xsl:with-param name="dimension" select="'0'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate2"/>
                <xsl:with-param name="dimension" select="'1'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate3"/>
                <xsl:with-param name="dimension" select="'2'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate4"/>
                <xsl:with-param name="dimension" select="'3'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate5"/>
                <xsl:with-param name="dimension" select="'4'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate6"/>
                <xsl:with-param name="dimension" select="'5'"/>
              </xsl:apply-templates>
          </xsl:when>
        </xsl:choose>
        </xsl:template>


		<xsl:template match="field" mode="VALIDATE_FIXED_SIZE_COORDINATES">
      <xsl:param name="coord"/>
      <xsl:param name="dimension"/>
        <xsl:if test="not(contains($coord,' OR ')) and contains($coord, '1...') and not(contains($coord, '1...N')) and not(string(number(substring-after($coord,'1...')))='NaN')">
        // validation of <xsl:value-of select="@path"/> dimension <xsl:value-of select="number($dimension)"/>
          arraySize = this-><xsl:value-of select = "@name"/>.extent(<xsl:value-of select="number($dimension)"/>);
          if (arraySize != 0) {
            if (arraySize != <xsl:value-of select = "substring-after($coord,'1...')"/>) {
			  std::stringstream shapestrss;
			  shapestrss &lt;&lt; this-><xsl:value-of select="@name"/>.shape();
              throw ValidationException("Element '<xsl:value-of select="@path_doc"/>' has incorrect shape "+shapestrss.str()+": dimension <xsl:value-of select="number($dimension)+1"/> must have size <xsl:value-of select = "substring-after($coord,'1...')"/>.");
            }
          }
        </xsl:if>
        <xsl:if test="$coord='time'">
        // validation of <xsl:value-of select="@path"/> dimension <xsl:value-of select="number($dimension)"/>
        arraySize = this-><xsl:value-of select = "@name"/>.extent(<xsl:value-of select="number($dimension)"/>);
        if (arraySize != 0) {
          if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS ) {
            if(arraySize != idsTimeSize) {
            std::stringstream shapestrss;
			shapestrss &lt;&lt; this-><xsl:value-of select="@name"/>.shape();
            std::string errMsg("Element '<xsl:value-of select="@path_doc"/>' has incorrect shape "+shapestrss.str()+": its coordinate in dimension <xsl:value-of select="number($dimension)+1"/> ('time') has size "+std::to_string(idsTimeSize)+".");
            for(int id=0; id&lt;indicesStr.size();id++) errMsg = std::regex_replace(errMsg, std::regex(indicesStr[id]),std::to_string(indicesVal[id]));
            throw ValidationException(errMsg);
            }
          }
        }
        </xsl:if>
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
			al_status = al_delete_data(ctx, fieldPath.c_str());
			if (al_status.code != 0)
			{	
				al_end_action(ctx);
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

				al_status = al_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize, &amp;aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
				{	
					al_end_action(ctx);
					return al_status.code; 
				}

				if(aosCtx&gt;0 &amp;&amp; arraySize&gt;0 &amp;&amp; <xsl:value-of select="@name"/>.size() == 0)
					<xsl:value-of select="@name"/>.resize(arraySize);

				for( int i = 0; i &lt;arraySize; i++){
                    status = <xsl:value-of select="@name"/>(i).<xsl:value-of select="$methodName"/>(aosCtx, idsTimeMode, idsFullName);
					if (status &lt; 0)
					{	
						al_end_action(ctx);
						return status; 
					}
					al_status = al_iterate_over_arraystruct(aosCtx, 1);
					if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
					{	
						al_end_action(aosCtx);
						al_end_action(ctx);
						return al_status.code; 
					}
				}
				al_status = al_end_action(aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))  
				{	
					al_end_action(ctx);
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

				al_status = al_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize, &amp;aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__)) 
				{	
					al_end_action(ctx);
					return al_status.code;
				}

				if(aosCtx&gt;0 &amp;&amp; arraySize&gt;0 &amp;&amp; <xsl:value-of select="@name"/>.size() == 0)
					<xsl:value-of select="@name"/>.resize(arraySize);

				for( int i = 0; i &lt;arraySize; i++){
                    status = <xsl:value-of select="@name"/>(i).<xsl:value-of select="$methodName"/>(aosCtx, idsTimeMode, idsFullName);
                    if (status &lt; 0)
					{	
						al_end_action(ctx);
						return status;
					}
					al_status = al_iterate_over_arraystruct(aosCtx, 1);
					if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
					{	
						al_end_action(aosCtx);
						al_end_action(ctx);
						return al_status.code; 
					}
				}
				al_status = al_end_action(aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
				{	
					al_end_action(ctx);
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
				al_status = al_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize, &amp;aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))  
				{	
					al_end_action(ctx);
					return al_status.code;
				}

				if(aosCtx&gt;0 &amp;&amp; arraySize&gt;0 &amp;&amp; <xsl:value-of select="@name"/>.size() == 0)
					<xsl:value-of select="@name"/>.resize(arraySize);

				for( int i = 0; i &lt;arraySize; i++){
                    status = <xsl:value-of select="@name"/>(i).<xsl:value-of select="$methodName"/>(aosCtx, idsTimeMode, idsFullName);
                    if (status &lt; 0)
					{	
						al_end_action(ctx);
                        return status;
					}
					al_status = al_iterate_over_arraystruct(aosCtx, 1);
					if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
					{	
						al_end_action(aosCtx);
						al_end_action(ctx);
                        return al_status.code;
					}
				}
				al_status = al_end_action(aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))  
				{	
					al_end_action(ctx);
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
                al_status = IdsNs::Ids::writeData(ctx, idsFullName, fieldPath, timeBasePath, getALVersion(), "<xsl:value-of select="@lifecycle_status"/>");
            </xsl:when>
            <xsl:when test="(@data_type='str_type' or @data_type='STR_0D') and @path='ids_properties/version_put/access_layer_language'">
                al_status = IdsNs::Ids::writeData(ctx, idsFullName, fieldPath, timeBasePath, "cpp-<xsl:value-of select="$AL_GIT_DESCRIBE"/>", "<xsl:value-of select="@lifecycle_status"/>");
            </xsl:when>
            <xsl:otherwise>
                al_status = IdsNs::Ids::writeData(ctx, idsFullName, fieldPath, timeBasePath, this-><xsl:value-of select="@name"/>, "<xsl:value-of select="@lifecycle_status"/>");
            </xsl:otherwise>
        </xsl:choose>
        if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
        {   
            al_end_action(ctx);
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
			al_status = al_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize, &amp;aosCtx);
			if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__)) 
			{	
				al_end_action(ctx);
				return al_status.code;
			}

			if(aosCtx > 0 &amp;&amp; arraySize > 0)
			{	
				<xsl:value-of select="@name"/>.resize(arraySize);
				for( int i = 0; i &lt;arraySize; i++){
					status = <xsl:value-of select="@name"/>(i).get(aosCtx, idsTimeMode);
                    if (status &lt; 0)
					{	
						al_end_action(ctx);
                        return status;
					}
					al_status = al_iterate_over_arraystruct(aosCtx, 1);
					if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
					{	
						al_end_action(aosCtx);
						al_end_action(ctx);
                        return al_status.code;
					}
				}
				al_status = al_end_action(aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))  
				{	
					al_end_action(ctx);
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
			al_status = al_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize, &amp;aosCtx);
			if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__)) 
			{	
					al_end_action(ctx);
                    return al_status.code;
			}

			if(aosCtx > 0 &amp;&amp; arraySize > 0)
			{	
				<xsl:value-of select="@name"/>.resize(arraySize);
				for( int i = 0; i &lt;arraySize; i++){
					status = <xsl:value-of select="@name"/>(i).get(aosCtx, idsTimeMode);
                    if (status &lt; 0)
					{	
						al_end_action(ctx);
                        return status;
					}
					al_status = al_iterate_over_arraystruct(aosCtx, 1);
					if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
					{	
						al_end_action(aosCtx);
						al_end_action(ctx);
                        return al_status.code;
					}
				}
				al_status = al_end_action(aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__)) 
				{	
					al_end_action(ctx);
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
			al_status = al_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize, &amp;aosCtx);
			if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))  
			{	
				al_end_action(ctx);
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
						    al_end_action(ctx);
                            return status;
					    }
					    al_status = al_iterate_over_arraystruct(aosCtx, 1);
					    if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))
					    {	
						    al_end_action(aosCtx);
						    al_end_action(ctx);
                            return al_status.code;
					    }
				    }
                }
				al_status = al_end_action(aosCtx);
				if (IdsNs::Ids::isError(al_status, __FILE__, __LINE__, __func__))  
				{	
					al_end_action(ctx);
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
			al_end_action(ctx);
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

<xsl:template match='field' mode="check-target-indices">
      <xsl:param name="coord"/>
      <xsl:param name="relativepathdoc"/>
      <xsl:if test="contains($coord,' OR')">
        <xsl:variable name="target">
          <xsl:if test="not($relativepathdoc='/')">
            <xsl:value-of select="replace(substring-before(substring-after($coord,$relativepathdoc),' OR'),'/','.')"/>
          </xsl:if>
          <xsl:if test="$relativepathdoc='/'">
              <xsl:value-of select="replace(substring-before($coord,' OR'),'/','.')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:apply-templates select="." mode="check_indices">
            <xsl:with-param name="target" select="$target"/>
            <xsl:with-param name="string-resolved" select="''"/>
            <xsl:with-param name="string-error" select="''"/>
        </xsl:apply-templates>
      <xsl:apply-templates select="." mode="check-target-indices">
        <xsl:with-param name="coord" select="substring-after($coord,' OR')"/>
        <xsl:with-param name="relativepathdoc" select="$relativepathdoc"/>
      </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="not(contains($coord,' OR'))">
      <xsl:variable name="target">
        <xsl:if test="not($relativepathdoc='/')">
          <xsl:value-of select="replace(substring-after($coord,$relativepathdoc),'/','.')"/>
        </xsl:if>
        <xsl:if test="$relativepathdoc='/'">
            <xsl:value-of select="replace($coord,'/','.')"/>
        </xsl:if>
      </xsl:variable>
      <xsl:apply-templates select="." mode="check_indices">
            <xsl:with-param name="target" select="$target"/>
            <xsl:with-param name="string-resolved" select="''"/>
            <xsl:with-param name="string-error" select="''"/>
        </xsl:apply-templates>
      </xsl:if>
      </xsl:template>

      <xsl:template match='field' mode="check_indices">
      <xsl:param name="target"/>
      <xsl:param name="string-resolved"/>
      <xsl:param name="string-error"/>
      <xsl:if test="contains($target,'(')">
        <xsl:variable name="indexstr">
          <xsl:apply-templates select="." mode="get_indices">
            <xsl:with-param name="target" select="$target"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="resolved_indexstr">
        <xsl:if test="matches($indexstr, '^[0-9]+$')">
          <xsl:value-of select="$indexstr"/>
        </xsl:if>
        <xsl:if test="matches($indexstr, '^itime|i[1-9]$')">
          <xsl:value-of select="''"/>
        </xsl:if>
        <xsl:if test="not(matches($indexstr, '^[0-9]+$')) and not(matches($indexstr, '^itime|i[1-9]$'))">
          <xsl:value-of select="concat('this->',$indexstr)"/>
        </xsl:if>
	</xsl:variable>
  <xsl:variable name="indexid_str">
    <xsl:if test="starts-with($target,'.')">  <xsl:value-of select="substring-before(substring-after($target,'.'),'(')"/>_id </xsl:if>
    <xsl:if test="not(starts-with($target,'.'))">  <xsl:value-of select="substring-before($target,'(')"/>_id </xsl:if>
  </xsl:variable>
   <xsl:if test="$resolved_indexstr != ''">
	  <xsl:if test="not(matches($resolved_indexstr, '^[0-9]+$'))">
          if (<xsl:value-of select="$resolved_indexstr"/>==EMPTY_INT) {
            throw ValidationException("<xsl:value-of select="replace(replace($resolved_indexstr,'\(','(&quot;+std::to_string('),'\)',')+&quot;)')"/> is not valid ("+std::to_string(EMPTY_INT)+").");
          }
          </xsl:if>
          std::string <xsl:value-of select="$indexid_str"/> =
          <xsl:if test="matches($indexstr, '^[0-9]+$')">
            std::to_string(<xsl:value-of select="$resolved_indexstr"/>-1);
          </xsl:if>
          <xsl:if test="not(matches($indexstr, '^[0-9]+$')) and not(matches($indexstr, '^itime|i[1-9]$'))">
            std::to_string(<xsl:value-of select="$resolved_indexstr"/>-1);
          </xsl:if>
	        if (<xsl:value-of select="concat('this->',$string-resolved,substring-before($target,'('))"/>.extent(0)&lt;=<xsl:value-of select="$resolved_indexstr"/>-1) { 
            throw ValidationException("<xsl:value-of select="concat($string-error,replace(replace(concat(substring-before($target,concat($indexstr,')')), concat($indexid_str,')') ),'\(','(&quot;+'),'\)','+&quot;)'))"/> is not allocated.");
          }
        </xsl:if>
        <xsl:apply-templates select="." mode="check_indices">
            <xsl:with-param name="target" select="substring-after($target,concat($indexstr,')'))"/>
            <xsl:with-param name="string-resolved" select="concat($string-resolved,substring-before($target,concat($indexstr,')')), concat(concat($resolved_indexstr,'-1'),')') )"/>
            <xsl:with-param name="string-error" select="concat($string-error,replace(replace(concat(substring-before($target,concat($indexstr,')')), concat($indexid_str,')') ),'\(','(&quot;+'),'\)','+&quot;)'))"/>
          </xsl:apply-templates>
      </xsl:if>      
</xsl:template>


</xsl:stylesheet>
