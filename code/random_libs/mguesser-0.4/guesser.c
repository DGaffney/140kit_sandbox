/* Copyright (C) 2000-2008 Lavtech.com corp. All rights reserved.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/types.h>
#include <dirent.h>

#ifndef UDM_GUESSER_STANDALONE
#include "udm_config.h"
#else
#include <unistd.h>
#endif

#include "udm_common.h"
#include "udm_crc32.h"
#include "udm_guesser.h"
#include "udm_utils.h"

#ifndef UDM_GUESSER_STANDALONE
#include "udm_unicode.h"
#include "udm_log.h"
#endif

int UdmLoadLangMapFile(UDM_ENV * Env, const char * filename)
{
  FILE * f;
  char str[1000];
  int nitems= 0;
  UDM_LANGMAP *map;
#ifndef UDM_GUESSER_STANDALONE
  UDM_CHARSET * cs;
#endif

  if (!(f= fopen(filename,"r")))
  {
    Env->errcode= 1;
    sprintf(Env->errstr,"Can't open LangMapFile '%s'\n",filename);
    return -1;
  }

  Env->LangMapList.maps= (UDM_LANGMAP*)realloc(Env->LangMapList.maps,(Env->LangMapList.nmaps+1)*sizeof(UDM_LANGMAP));
  Env->LangMapList.nmaps++;
  map= &Env->LangMapList.maps[Env->LangMapList.nmaps-1];
  memset(map, 0, sizeof(UDM_LANGMAP));

  while(fgets(str,sizeof(str),f))
  {
    if (str[0] == '#' || str[0] == ' ' || str[0] == '\t')
      continue;

    if (!strncmp(str,"Charset:",8))
    {
      char *charset, *lasttok;
      if ((charset= udm_strtok_r(str+8," \t\n\r",&lasttok)))
      {
        UDM_FREE(map->charset);
        map->charset= strdup(charset);
      }
    }
    else if (!strncmp(str,"Language:",9))
    {
      char *lang, *lasttok;
      
      if ((lang= udm_strtok_r(str+9," \t\n\r",&lasttok)))
      {
        UDM_FREE(map->lang);
        map->lang= strdup(lang);
      }
    }
    else
    {
      char *s;
      int count;
      
      if (!(s= strchr(str,'\t')))
        continue;
      *s= '\0';

      if (((count= atoi(s+1)) == 0) || (strlen(str)<1) || (strlen(str)>UDM_LM_MAXGRAM))
        continue;

      for (s= str; *s; s++)
      {
        if(*s == '_')
          *s=' ';
      }
      if(*str)
      {
        int hindex;
        hindex= ((unsigned int)UdmCRC32(str,strlen(str)))&UDM_LM_HASHMASK;
        map->memb[hindex].count= count;
        /*
        strcpy(Env->LangMapList.maps[Env->LangMapList.nmaps-1].memb[hindex].str,str);
        */
        nitems++;
      }
    }
  }
  fclose(f);
  
  if (!map->lang)
  {
    Env->errcode= 1;
    sprintf(Env->errstr,"No language definition in LangMapFile '%s'\n",filename);
    return -1;
  }

  if (!map->charset)
  {
    Env->errcode= 1;
    sprintf(Env->errstr,"No charset definition in LangMapFile '%s'\n",filename);
    return -1;
  }
#ifndef UDM_GUESSER_STANDALONE
  if (!(cs= UdmGetCharSet(map->charset)))
  {
    Env->errcode= 1;
    sprintf(Env->errstr,"Unknown charset '%s' in LangMapFile '%s'\n",
      Env->LangMapList.maps[Env->LangMapList.nmaps-1].charset,filename);
    return -1;
  }
#endif
  UdmPrepareLangMap(map);
  return 0;
}


int UdmLoadLangMapList(UDM_ENV * Env, const char * mapdir)
{
  DIR * dir;
  struct dirent * item;
  char fullname[1024]= "";
  char name[1024]= "";
  int res= 0;

  /*Env->LangMapList.nmaps= 0;*/
  dir= opendir(mapdir);
  if(!dir)
    return 0;

  while ((item= readdir(dir)))
  {
    char * tail;
    strcpy(name,item->d_name);
    if((tail= strstr(name,".lm")))
    {
      *tail= '\0';
      sprintf(fullname,"%s/%s",mapdir,item->d_name);
      res= UdmLoadLangMapFile(Env,fullname);
      if(res<0)
      {
        return res;
      }
    }
  }
  closedir(dir);
  return 0;
}


void UdmFreeLangMapList(UDM_ENV * env)
{
  size_t i;
  
  if(!env)
    return;
  for (i= 0; i<env->LangMapList.nmaps; i++)
  {
    if (env->LangMapList.maps[i].charset)
    {
      UDM_FREE(env->LangMapList.maps[i].charset);
    }
    if(env->LangMapList.maps[i].lang)
    {
      UDM_FREE(env->LangMapList.maps[i].lang);
    }
  }
  free(env->LangMapList.maps);
}


void UdmBuildLangMap(UDM_LANGMAP * map,const char * text,size_t textlen)
{
  const char * end= text+textlen;
  int prevb= ' ';

  for ( ; text <= end; text++)
  {
    char buf[UDM_LM_MAXGRAM+3];
    size_t buflen= 0;
    const char * t;
    int code;
    int prev= 0;

    code= (unsigned char)(*text);
    if (code<' ')continue;
    if ((code == ' ')&&(prevb == ' '))continue;
    prevb= code;

    t= text;
    for (buflen= 0; buflen < UDM_LM_MAXGRAM; buflen++)
    {
      int hindex;

      for ( ;t <= end; t++)
      {
        code= (unsigned char)(*t);
        if (code<' ')continue;
        if ((code == ' ')&&(prev == ' '))continue;
        prev= code;
        break;
      }
      if (t > end)break;
      t++;

      buf[buflen]= code;
      buf[buflen+1]= '\0';

      hindex= UdmCRC32(buf,buflen+1);
      hindex= ((unsigned int)(hindex))&(UDM_LM_HASHMASK);
      map->memb[hindex].count++;

#ifdef DEBUG_GUESSER
      /* Print collision */
      if(map->memb[hindex].str[0])
      {
        int res;
        res= strcmp(map->memb[hindex].str,buf);
        if (res)
        {
          printf("Coll %04X '%s' '%s'\n",hindex,map->memb[hindex].str,buf);
          strcpy(map->memb[hindex].str,buf);
        }
      }
#endif
      strcpy(map->memb[hindex].str,buf);
    }
  }
}


static int cmpm(const void * i1,const void * i2)
{
  const UDM_LANGITEM * m1= i1;
  const UDM_LANGITEM * m2= i2;
  
  return(m2->count-m1->count);
}

void UdmPrintLangMap(UDM_LANGMAP * map)
{
  size_t i;
  
  printf("#\n");
  printf("#\n");
  printf("#\n");
  printf("\n");
  printf("Language: %s\n",map->lang);
  printf("Charset:  %s\n",map->charset);
  printf("\n");
  printf("\n");
  qsort(map->memb,UDM_LM_HASHMASK+1,sizeof(UDM_LANGITEM),&cmpm);
  for (i= 0; i <= UDM_LM_HASHMASK && i <= map->topcount ; i++)
  {
    char * s;
    if (!map->memb[i].count)
      break;
    
    for (s= map->memb[i].str; *s ;s++)
      if (*s == ' ')
        *s= '_';
    
    printf("%s\t%d\n",map->memb[i].str,map->memb[i].count);
  }
}

void UdmPrepareLangMap(UDM_LANGMAP * map)
{
  int i;
  int nmemb= UDM_LM_HASHMASK+1;
  float expectation= 0;
  float dispersion= 0;

  /* Calculate math expectation */
  for (i= 0; i < nmemb; i++)
  {
    expectation+= map->memb[i].count;
  }
  expectation/= nmemb;

  /* Calculate math dispersion */
  for (i= 0; i < nmemb; i++)
  {
    dispersion+= (map->memb[i].count-expectation)*(map->memb[i].count-expectation);
  }
  map->expectation= expectation;
  map->dispersion= sqrt(dispersion/nmemb);
}


float UdmCheckLangMap(UDM_LANGMAP * map0,UDM_LANGMAP * map1)
{
  float res= 0;
  float exp0= 0;
  float exp1= 0;
  float up= 0;
  float nmemb= UDM_LM_HASHMASK+1;
  int i;
  UDM_LANGITEM * mp0, *mp1;

  /* Abort if one of dispertions is 0 */
  if ((map0->dispersion<0.00001) ||
      (map1->dispersion<0.00001))
    return 0;

  exp0= map0->expectation;
  exp1= map1->expectation;

  for (i= 0, mp0= map0->memb, mp1= map1->memb; i < nmemb; i++, mp0++, mp1++)
  {
    up+= (mp0->count-exp0)*(mp1->count-exp1);
  }
  up/= nmemb;

  res= up/map0->dispersion/map1->dispersion;
  return res;
}


/* Structure to sort guesser results */
typedef struct
{
  UDM_LANGMAP * map;
  float quality;
} UDM_MAPSTAT;

static int statcmp(const void * i1, const void * i2)
{
  float fres;
  fres= ((const UDM_MAPSTAT*)(i2))->quality - ((const UDM_MAPSTAT*)(i1))->quality;
  if (fres<0) return -1;
  if (fres>0) return +1;
  return 0;
}

/*************************************************************************/

#ifndef UDM_GUESSER_STANDALONE

int  UdmGuessCharSet(UDM_AGENT * Indexer,UDM_DOCUMENT * Doc)
{
  int i;
  UDM_MAPSTAT * mapstat;

  /* 
    TODO for Guesser
    
    There are three sources to detect charset:
    1. HTTP header:  Content-Type: ... charset=XXX
    2. <META HTTP-EQUIV="Content-Type" Contnet="... charset=YYY">
    3. ZZZ[i] - array of guessed charsets in mapstat[]
    good(ZZZ[n]) means that guesser returned good results for n.

    Now we may have various combinations:
    Simple situations, non-guessed and guessed charsets
    seem to be the same. At least one of non-guessed
    charset is the same with the best guessed charset
    and guessed charset gave good results:

    1. XXX==YYY==ZZZ[0],      good(ZZZ[0]). Take XXX value.
    2. No YYY, XXX=ZZZ[0] and good(ZZZ[0]). Take XXX value.
    3. No XXX, YYY=ZZZ[0] and good(ZZZ[0]). Take YYY value.
    4. XXX<>YYY, XXX==ZZZ[0], good(ZZZ[0]). Take XXX value.
    5. XXX<>YYY, YYY==ZZZ[0], good(ZZZ[0]). Take XXX value.
      4 and 5 seem to be webmaster mistake.

    There are the same fith situations when ZZZ[x] is still good 
    enough, but it is not the best one, i.e. x>0 
    Choose charset in the same way.
  */

  /* Prepare document langmap */
  UdmPrepareLangMap(&Doc->LangMap);

  /* Allocate memory for comparison statistics */
  mapstat= (UDM_MAPSTAT *)malloc(Indexer->Conf->LangMapList.nmaps*sizeof(UDM_MAPSTAT));
  for (i= 0; i < Indexer->Conf->LangMapList.nmaps; i++)
  {
    mapstat[i].quality= UdmCheckLangMap(&Indexer->Conf->LangMapList.maps[i],&Doc->LangMap);
    mapstat[i].map= &Indexer->Conf->LangMapList.maps[i];
  }

  /* Sort statistics in quality order */
  qsort(mapstat,Indexer->Conf->LangMapList.nmaps,sizeof(UDM_MAPSTAT),&statcmp);

  /* Display results, best language is shown first */
  for (i= 0; i < Indexer->Conf->LangMapList.nmaps; i++)
  {
    if (mapstat[i].quality < 0.800)
      break;
    if (!Doc->charset)
    {
      if (mapstat[i].map->charset)
      {
        Doc->charset= strdup(mapstat[i].map->charset);
      }
    }
    if (!Doc->lang)
    {
      if (mapstat[i].map->lang)
      {
        Doc->lang= strdup(mapstat[i].map->lang);
      }
    }
    if (i>4)
      break;
    UdmLog(Indexer,UDM_LOG_EXTRA,"Guesser: %.5f %s-%s",mapstat[i].quality,mapstat[i].map->lang,mapstat[i].map->charset);
  }
  free(mapstat);
  return 0;
}

#endif



/***************************************************************/

#ifdef UDM_GUESSER_STANDALONE

/*
  Load langmaps from multiple directories
  separated by ':' character.
*/
int UdmLoadLangMapListMultipleDirs(UDM_ENV *Env, const char *mapdirs)
{
  char *tok, *lasttok, *dirs= strdup(mapdirs);
  for (tok= udm_strtok_r(dirs, ":", &lasttok);
       tok;
       tok= udm_strtok_r(NULL, ":", &lasttok))
  {
    UdmLoadLangMapList(Env, tok);
    if (Env->errcode)
      return 1;
    
  }
  free(dirs);
  return 0;
}

void usage()
{
  printf("mguesser %s\n\n",MGUESSER_VERSION);
  printf("To guess use:\n\n");
  printf("\tmguesser [-d dir] [-n maxhits]< FILENAME\n\n");
  printf("To create a new language map use:\n\n");
  printf("\tmguesser -p -c charset -l language [-t numtopgrams]< FILENAME\n");
} 

int main(int argc,char ** argv)
{
  int ch;
  int verbose= 0;
  int print= 0;
  int n= 1000;
  char buf[1024]= "";
  UDM_ENV env;
  UDM_LANGMAP mchar;
  char *charset= NULL;
  char *lang= NULL;
  const char *dir= LMDIR;

  /* Init structures */
  memset(&env,0,sizeof(env));
  memset(&mchar,0,sizeof(mchar));
  mchar.topcount= UDM_LM_TOPCNT;

  while((ch= getopt(argc,argv,"pv?c:l:n:d:t:"))!= -1)
  {
    switch(ch)
    {
      case 'd':
        dir= optarg;
        break;
      case 'n':
        n= atoi(optarg);
        break;
      case 'c':
        charset= optarg;
        break;
      case 'l':
        lang= optarg;
        break;
      case 'p':
        print++;
        break;
      case 'v':
        verbose++;
        break;
      case 't':
        mchar.topcount= atoi(optarg);
        break;
      case '?':
      default:
        usage();
        exit(1);
    }
  }
  argc-= optind;
  argv+= optind;


  if (!print)
  {
    /* Load all available lang ngram maps */
    if(verbose)
    {
      fprintf(stderr,"Loading language maps from '%s'\n", dir);
    }
    UdmLoadLangMapListMultipleDirs(&env, dir);
    if(env.errcode)
    {
      printf("Error: '%s'\n",env.errstr);
      return 1;
    }

    if(verbose)
    {
      fprintf(stderr,"%d maps found\n",env.LangMapList.nmaps);
    }
  }
  
  
  /* Add each STDIN line statistics */
  while(fgets(buf,sizeof(buf),stdin))
  {
    UdmBuildLangMap(&mchar,buf,strlen(buf));
  }
  
  
  if (print)
  {
    /* Display built langmap */
    if (!charset)
    {
      fprintf(stderr,"You must specify charset using -c\n");
    }
    else if(!lang)
    {
      fprintf(stderr,"You must specify language using -l\n");
    }
    else
    {
      mchar.lang= strdup(lang);
      mchar.charset= strdup(charset);
      UdmPrintLangMap(&mchar);
    }
  }
  else
  {
    int i;
    UDM_MAPSTAT * mapstat;
    
    /* Prepare map to comparison */
    UdmPrepareLangMap(&mchar);

    /* Allocate memory for comparison statistics */
    mapstat= (UDM_MAPSTAT *)malloc(env.LangMapList.nmaps*sizeof(UDM_MAPSTAT));

    /* Calculate each lang map        */
    /* correlation with text          */
    /* and store in mapstat structure */

    for (i= 0; i < env.LangMapList.nmaps; i++)
    {
      mapstat[i].quality= UdmCheckLangMap(&env.LangMapList.maps[i],&mchar);
      mapstat[i].map= &env.LangMapList.maps[i];
    }

    /* Sort statistics in quality order */
    qsort(mapstat,env.LangMapList.nmaps,sizeof(UDM_MAPSTAT),&statcmp);


    /* Display results. Best language is shown first. */
    for (i= 0; (i < env.LangMapList.nmaps) && (i < n); i++)
    {
      printf("%.10f\t%s\t%s\n",mapstat[i].quality<0?0:mapstat[i].quality,mapstat[i].map->lang,mapstat[i].map->charset);
    }

    /* Free variables */
    free(mapstat);
  }
  
  UdmFreeLangMapList(&env);

  return 0;
}

#endif
