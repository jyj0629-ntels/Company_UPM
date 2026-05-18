#ifndef __defODAHpp__
#define __defODAHpp__

#include <unistd.h>
#include <time.h>
#include <stdint.h>

#ifndef uint32_t
    typedef unsigned int uint32_t;
#endif
#ifndef int16_t
    typedef short int int16_t;
#endif
#ifndef uint16_t
    typedef unsigned short int uint16_t;
#endif

#define HA_ACTIVE_MODE   100 
#define HA_STANDBY_MODE  101

#define ODA_NODE_STATUS_UP    'U'
#define ODA_NODE_STATUS_DOWN  'D'
#define ODA_SM_RBUS_ID        "99"

typedef struct
{
    char   node_[20] ;
    char   status_ ;
    time_t time_ ;
} ST_NODE_STATUS ;


#define HA_ACT_DEFAULT 1
#define HA_ACT_CHANGE  2

#define ODA_LOCATION_WRONG       99
#define ODA_LOCATION_ROAMING      0
#define ODA_LOCATION_WCDMA_CELL   1
#define ODA_LOCATION_WCDMA_FEMTO  2
#define ODA_LOCATION_LTE_CELL     3
#define ODA_LOCATION_LTE_FEMTO    4
#define ODA_ZONE_CD_SIZE         20

typedef struct
{
    int eNodeBId_ ;
    int CellId_ ;
    int nw_ ;
} ST_LTE_CELL ;

typedef struct
{
    int eNB_ ;
    int section_ ;
    int nw_ ;
} ST_LTE_FEMTO ;

typedef struct
{
    unsigned char WMSC_ID ;
    unsigned char RNC_ID ;
    unsigned char NODEB_ID ;
    unsigned char SECTOR_ID ;
} ST_WCDMA_CELL ;


typedef struct
{
    unsigned char  WMSC_ID ;
    unsigned char  RNC_ID ;
    unsigned char  NODEB_ID ;
    unsigned char  SECTOR_ID ;
    unsigned short FEMTO_NODEB_ID ;
} ST_WCDMA_FEMTO ;

typedef struct 
{
    char            cOFCSName_[20];
    char            cOFCSIP_  [20];
    uint32_t        nOFCSIP_;
    uint16_t        md5use;
    uint32_t        radiuscnt[3];
    uint32_t        thresHold_ ;
    char            thStatus_ ;
    time_t          last_ ;
    char            status_ ;

    int32_t         prevRadiusCnt_[5][3] ;
} ST_RI_OFCS_INFO ;

#define ODA_RM_STATISTICS_TOTAL         0
#define ODA_RM_STATISTICS_START         1 
#define ODA_RM_STATISTICS_INTRIM        2
#define ODA_RM_STATISTICS_STOP          3
#define ODA_RM_STATISTICS_TA_RELAY      4
#define ODA_RM_STATISTICS_ROAMING       5
#define ODA_RM_STATISTICS_SKIP          6

#define ODA_RADIUS_TYPE_START           1
#define ODA_RADIUS_TYPE_STOP            2
#define ODA_RADIUS_TYPE_INTRIM          3

#define ODA_RI_MAX_OFCS                50
#define ODA_RM_MAX_WORKER              50
#define ODA_RM_MAX_OFCS               200 
#define ODA_SM_MAX_LOADER              20

#define ODA_RADIUS_PRESVATION_STOP     14

/**************************************
// Not Use 
#define ODA_NM_MAX_WORKER              20
#define ODA_ZM_MAX_LOADER              20
#define ODA_ZM_STATUS_IN                1
#define ODA_ZM_STATUS_OUT               2
#define ODA_ZM_MAX_CELL            300000

typedef struct
{
    char          cKey_    [20] ;
    char          cZoneCD_ [ODA_ZONE_CD_SIZE+1];
} ST_ZM_CELL ;

******************************************/

typedef struct 
{
    char            cOFCSName_[20];
    char            cOFCSIP_[20] ;
    uint32_t        nOFCSIP_;
    uint32_t        nStatistics_[10];
    uint32_t        nSum_ ;

    uint32_t        nErrStatistics_[12] ;
    uint32_t        nErrSum_ ;    
} ST_RM_OFCS_INFO ;

typedef struct
{
    char              cUserNm_   [12] ;  // MDN
    char              cMIN_      [11] ;
    char              cIMSI_     [16] ;
    char              cMSISDN_   [15] ;
    char              cAPN_      [32] ;
    unsigned char     cIP_       [4] ; // IPV4 , IPV6?? 
    unsigned char     cIPV6_     [16] ;
    unsigned char     cSGWIP_    [4] ;
    unsigned char     cPGWIP_    [4] ;
    unsigned char     cSessionID_[20] ;
    unsigned char     cMCCMNC_   [10] ;
    int               nRDType_ ;
    int               nRATType_ ;
    char              cLocationInfo_[64] ;
    time_t            time_ ;
    char              nLocationType_ ;
    ST_LTE_CELL       LTECell_;
    ST_LTE_FEMTO      LTEFemto_ ;
    ST_WCDMA_CELL     WCDMACell_ ;
    ST_WCDMA_FEMTO    WCDMAFemto_ ;
    int64_t           nInputOctets_ ;
    int64_t           nOutputOctets_ ;
    int64_t           nInputPackets_ ;
    int64_t           nOutputPackets_ ;
    short             nInputGigawords_ ;
    short             nOutputGigawords_;
    int               nStopCause_ ;

    char              isIPV4_ ;
    char              isIPV6_ ;
    char              key_[64] ;

} ST_ODA_RESULT ;

typedef struct
{
    char              cUserNm_   [12] ;  // MDN
    char              cTimestamp_[20] ;
    char              cCurrZone_ [12] ;
    char              cPrevZone_ [12] ;
} ST_ODA_ZONE_NOTI ;

typedef struct
{
    time_t now_ ;
    int    status_ ; 
} ST_ODA_STATUS ;

typedef struct
{
    unsigned char     cIP_       [4]  ;
    unsigned char     cIPV6_     [10] ;
    char              cUserNm_   [12] ;  // MDN
    char              cMIN_      [11] ;
    char              cIMSI_     [16] ;
    char              cMSISDN_   [15] ;
    unsigned char     cPGWIP_    [4] ;
    char              cSessionID_[20] ;
    char              cMCCMNC_   [10] ;
    char              cLocationInfo_[64] ;
    char              nLocationType_ ;
    int               nRATType_ ;
    time_t            time_ ;
    char              key_[32] ;
} ST_ODA_SM_MEMORY ;


#define ODA_DB_ALARM                "SPM10001" 
#define ODA_EMS_DB_ALARM            "SPM10002" 
#define ODA_STATUS_NOTI_IF_ALARM    "SPM10003" 
#define ODA_LOCAL_RBUS_IF_ALARM     "SPM10004" 
#define ODA_RI_NO_DATA_ALARM        "SPM10011" 
#define ODA_RI_HAS_DATA_ALARM       "SPM10012"
#define ODA_RI_THRESHOLD_O_ALARM    "SPM10013" 
#define ODA_RI_THRESHOLD_R_ALARM    "SPM10014"
#define ODA_RI_INVALID_NODE         "SPM10015"
#define ODA_RF_SM_RBUS_IF_ALARM     "SPM10022"
#define ODA_RF_TA_RBUS_IF_ALARM     "SPM10022"
#define ODA_RF_UDR_AVP_ALARM        "SPM10031"

#define ODA_IF_FAIL_ALARM           "SPM11101"
#define ODA_IF_NORM_ALARM           "SPM11102"
#define ODA_SM_ABNR_ALARM           "SPM11103"
#define ODA_SM_NORM_ALARM           "SPM11104"

#endif
