#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include "CRBusGlobalAPI.hpp"
#include "defODA.hpp"
#include "NLCStopWatch.hpp"

void ConvStrToRadiusIPV4(char *_ip,unsigned char *_dest)
{
    char  buffer[10] ;
    char *ptr ;
    int   cnt ;

    ptr = _ip ;
    cnt = 0  ;
    while(*ptr)
    {
        if ( *ptr == '.' )
        {
            buffer[cnt] = 0x00 ;
            *_dest++ = atoi(buffer) ;
            cnt = 0 ;
        }
        else
        {
            buffer[cnt++] = *ptr ;
        }
        ptr++ ;
    }

    buffer[cnt] = 0x00 ;
    *_dest = atoi(buffer) ;
}

int main(int argc,char *argv[])
{
    CRBusGlobalAPI *apiObj ;
    ST_ODA_RESULT  data ;
    ST_ODA_RESULT *sendPtr ;
    char           buffer[1024] ;
    char          *itemList[20] ;
    int            itemIndex ;
    char          *ptr ;
    FILE          *fp ;
    int            sendCount;
    char          *sendBuffer;
    int            totalSendCount ;
    char*         token;
    unsigned int dIP[4];
    int ipIndex = 0;

    if ( !argv[1] || !argv[2] || !argv[3] )
    {
        printf("argument mismatch!\n") ;
        printf(">ODA_SIM RBUS_QUEUE_NAME DATA_FILE_NAME RBUS_CFG_NAME\n") ;
        exit(0); 
    }

    sendBuffer = (char *)malloc(sizeof(ST_ODA_RESULT)*1500) ;
    
    apiObj = new CRBusGlobalAPI("01",argv[1],"ODA-SIM",0) ;
    if ( !apiObj )
    {
        printf("[%s-%d] new keyword error\n",__FILE__,__LINE__) ;
        exit(0); 
    }

    if ( apiObj->Initial(argv[3]) != RBUS_API_OK)
    {
        printf("[%s-%d] RBUS Initial() fail!-%s\n",__FILE__,__LINE__,apiObj->GetAPIErrorMessage()) ;
        exit(0);
    }
    if ( apiObj->Open(RBUS_ACCESS_WRITE | RBUS_ACCESS_GLOBAL | RBUS_ACCESS_ASYNC) != RBUS_API_OK )
    {
        printf("[%s-%d] RBUS Open() fail!-%s\n",__FILE__,__LINE__,apiObj->GetAPIErrorMessage()) ;
        exit(0);
    }

    sendCount      = 0 ;
    totalSendCount = 0 ;

    sendPtr = (ST_ODA_RESULT *)sendBuffer ;

    fp = fopen(argv[2],"r") ;
    if ( !fp )
    {
        printf("file(%s) open error!\n",argv[2]) ;
        exit(0);
    }

    int mc=0;
    //while(fgets(buffer,1024,fp) != NULL )
    while(1)
    {
        usleep(100);
        #if 1
        if(fgets(buffer,1024,fp)==NULL)
        {
                fseek(fp,0,SEEK_SET);
                mc++;

                if(mc == 100000)
                        break;

                continue;
        }
        #endif

        memset(&dIP, 0, 4);
        ipIndex = 0;
        memset(&data, 0, sizeof(ST_ODA_RESULT));

        buffer[strlen(buffer)] = 0 ;

        ptr = buffer ;
        itemIndex = 0 ;

        memset(itemList,0x00,sizeof(itemList)) ;

        if((token=strtok(ptr,","))!=NULL)
                itemList[itemIndex] = token ;

        while((token=strtok(NULL,","))!=NULL)
                itemList[++itemIndex] = token;

        strcpy (data.cUserNm_,itemList[0]) ;
        ConvStrToRadiusIPV4(itemList[1],data.cPGWIP_) ;
        sprintf(data.key_    ,"%s",itemList[2]) ;

        if ( strcmp(itemList[3],"W") == 0 )
            data.nRATType_ = 1 ;
        else
            data.nRATType_ = 6 ;


        data.time_ = time(0) ;
    
        if ( strcmp(itemList[3],"W") == 0 && strcmp(itemList[4],"C") == 0 )
        {
            data.nLocationType_       = ODA_LOCATION_WCDMA_CELL ;
            data.WCDMACell_.WMSC_ID   = atoi(itemList[5]) ;
            data.WCDMACell_.RNC_ID    = atoi(itemList[6]) ;
            data.WCDMACell_.NODEB_ID  = atoi(itemList[7]) ;
            data.WCDMACell_.SECTOR_ID = 0 ;

            if(itemList[8]!=NULL)
                sprintf(data.cAPN_, itemList[8]);
            
            if(itemList[9]!=NULL)
                data.time_ = data.time_ - atoi(itemList[9]);

            if(itemList[10]!=NULL)
            {
                if((token=strtok(itemList[10],"."))!=NULL)
                        dIP[ipIndex] = atoi(token) ;

                while((token=strtok(NULL,"."))!=NULL)
                {
                        if(ipIndex < 4)
                                dIP[++ipIndex] = atoi(token);
                }
            }
        }
        if ( strcmp(itemList[3],"W") == 0 && strcmp(itemList[4],"F") == 0 )
        {
            data.nLocationType_       = ODA_LOCATION_WCDMA_FEMTO ;
            data.WCDMAFemto_.WMSC_ID        = atoi(itemList[5]) ;
            data.WCDMAFemto_.RNC_ID         = atoi(itemList[6]) ;
            // data.WCDMAFemto_.NODEB_ID     = atoi(itemList[7]) ;
            data.WCDMAFemto_.SECTOR_ID      = 0 ;
            data.WCDMAFemto_.FEMTO_NODEB_ID = atoi(itemList[7]) ;
            
            if(itemList[8]!=NULL)
                sprintf(data.cAPN_, itemList[8]);
           
            if(itemList[9]!=NULL)
                 data.time_ = data.time_ - atoi(itemList[9]);

            if(itemList[10]!=NULL)
            {
                if((token=strtok(itemList[10],"."))!=NULL)
                        dIP[ipIndex] = atoi(token) ;

                while((token=strtok(NULL,"."))!=NULL)
                {
                        if(ipIndex < 4)
                                dIP[++ipIndex] = atoi(token);
                }
            }
        }
        if ( strcmp(itemList[3],"L") == 0 && strcmp(itemList[4],"C") == 0 )
        {
            data.nLocationType_     = ODA_LOCATION_LTE_CELL ;
            data.LTECell_.eNodeBId_ = atoi(itemList[5]) ;
            data.LTECell_.CellId_   = atoi(itemList[6]) ;

            if(itemList[7]!=NULL)
                sprintf(data.cAPN_, itemList[7]);

            if(itemList[8]!=NULL)
                data.time_ = data.time_ - atoi(itemList[8]);

            if(itemList[9]!=NULL)
            {
                //printf("IP Address : %s\n", itemList[9]);
                if((token=strtok(itemList[9],"."))!=NULL)
                        dIP[ipIndex] = atoi(token) ;

                while((token=strtok(NULL,"."))!=NULL)
                {
                        if(ipIndex < 4)
                                dIP[++ipIndex] = atoi(token);
                }
            }
        }
        if ( strcmp(itemList[3],"L") == 0 && strcmp(itemList[4],"F") == 0 )
        {
            data.nLocationType_     = ODA_LOCATION_LTE_FEMTO ;
            data.LTEFemto_.section_ = atoi(itemList[5]) ;
            
            if(itemList[6]!=NULL)
                sprintf(data.cAPN_, itemList[6]);

            if(itemList[7]!=NULL)
                data.time_ = data.time_ - atoi(itemList[7]);

            if(itemList[8]!=NULL)
            {
                if((token=strtok(itemList[8],"."))!=NULL)
                        dIP[ipIndex] = atoi(token) ;

                while((token=strtok(NULL,"."))!=NULL)
                {
                        if(ipIndex < 4)
                                dIP[++ipIndex] = atoi(token);
                }
            }
        }

                /******************IPV4*/
                data.isIPV4_ = true;
                data.cIP_[0]=dIP[0]; //128;
                data.cIP_[1]=dIP[1]; //127;
                data.cIP_[2]=dIP[2]; //126;
                data.cIP_[3]=dIP[3]; //125;
                /***********************/

        memcpy(sendPtr,&data,sizeof(ST_ODA_RESULT)) ;
        sendCount++ ;
        sendPtr++ ;
        totalSendCount++ ;

                // printf("key[13][%c]\n", data.key_[13]);

        //printf("APN : %s\n", data.cAPN_);
        //printf("NOW : %lu, EVENT_TIME : %lu\n", time(0), data.time_);

        if ( apiObj->Write((char *)sendBuffer,sizeof(ST_ODA_RESULT)*sendCount,0 ) != RBUS_API_OK )
        {
            printf("[%s-%d] RBUS Write() fail!-%s\n",__FILE__,__LINE__,apiObj->GetAPIErrorMessage()) ;
            break ;
        }
        sendPtr = (ST_ODA_RESULT *)sendBuffer ;
        sendCount = 0 ;
    }
    fclose(fp) ;

    printf("%d data send finished!\n",totalSendCount) ;

    exit(0); 
}
