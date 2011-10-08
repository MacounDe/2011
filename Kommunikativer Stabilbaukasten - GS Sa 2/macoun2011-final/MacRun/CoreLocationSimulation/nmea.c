/***********************************************************************
 
 Copyright (c) 2001-2008 Fritz Ganter and the GpsDrive Development Teamp
 
 Website: www.gpsdrive.de
 
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
 
 DAdaptations from Pascal Bihler, 2008, 2009
 
 *********************************************************************/

#include <stdio.h>
#include <math.h>
#include <string.h>
#include "nmea.h"

extern struct OUTDATA gNMEAdata;
static void do_lat_lon(const char *sentence, int begin);
static char *field(const char *sentence, short n);

static void update_field_i(const char *sentence, int fld, int *dest, int mask);
#if 0
static void update_field_f(const char *sentence, int fld, double *dest, int mask);
#endif
/* ----------------------------------------------------------------------- */

/*
   The time field in the GPRMC sentence is in the format hhmmss;
   the date field is in the format ddmmyy. The output will
   be in the format:

   mm/dd/yyyy hh:mm:ss
   01234567890123456789
 */

void processGPRMC(const char *sentence)
{
    char s[20], d[10], e[10], t[2];
    int tmp;

    sscanf(field(sentence, 9), "%s", d);	/* Date: ddmmyy */

    strncpy(s, d + 2, 2);	/* copy month */
	strncpy(t, d+2, 2);
	sscanf(t, "%2d", &gNMEAdata.month);
	

    strncpy(s + 3, d, 2);	/* copy date */
	strncpy(t, d, 2);
	sscanf(t, "%2d", &gNMEAdata.day);

    sscanf((d+4), "%2d", &tmp);
	
	strncpy(t, d+4, 2);
	sscanf(t, "%2d", &gNMEAdata.year);
	
    /* Tf.: Window the year from 1990 to 2089. This buys us some time. */
    if (tmp < 90) {
      strncpy(s + 6, "20", 2);	/* 21th century */
		gNMEAdata.year += 2000;
	}else{
		strncpy(s + 6, "19", 2);	/* 20th century */
		gNMEAdata.year += 1900;
	}

    strncpy(s + 8, d + 4, 2);	/* copy year */		

    sscanf(field(sentence, 1), "%s", e);	/* Time: hhmmss */

    strncpy(s + 11, e, 2);	/* copy hours */
	strncpy(t, e, 2);
	sscanf(t, "%2d", &gNMEAdata.hours);

    strncpy(s + 14, e + 2, 2);	/* copy minutes */
	strncpy(t, e+2, 2);
	sscanf(t, "%2d", &gNMEAdata.minutes);

    strncpy(s + 17, e + 4, 2);	/* copy seconds */
	strncpy(t, e+4, 2);
	sscanf(t, "%2d", &gNMEAdata.seconds);

    s[2] = s[5] = '/';		/* add the '/'s, ':'s, ' ' and string terminator */

    s[10] = ' ';
    s[13] = s[16] = ':';
    s[19] = '\0';

    strcpy(gNMEAdata.utc, s);

    /* A = valid, V = invalid */
    if (strcmp(field(sentence, 2), "V") == 0)
	gNMEAdata.status = 0;
#if 0    /* Let the GGA sentence do the update so we catch diff fixes */
    else
	gNMEAdata.status = 0;
#endif

    sscanf(field(sentence, 7), "%lf", &gNMEAdata.speed);
    sscanf(field(sentence, 8), "%lf", &gNMEAdata.track);

    do_lat_lon(sentence, 3);

}

/* ----------------------------------------------------------------------- */

void processGPGGA(const char *sentence)
{
    do_lat_lon(sentence, 2);
    /* 0 = none, 1 = normal, 2 = diff */
    sscanf(field(sentence, 6), "%d", &gNMEAdata.status);
    sscanf(field(sentence, 7), "%d", &gNMEAdata.satellites);
    sscanf(field(sentence, 9), "%lf", &gNMEAdata.altitude);
}

/* ----------------------------------------------------------------------- */

void processGPGSA(const char *sentence)
{
    /* 1 = none, 2 = 2d, 3 = 3d */
    sscanf(field(sentence, 2), "%d", &gNMEAdata.mode);
    sscanf(field(sentence, 15), "%lf", &gNMEAdata.pdop);
    sscanf(field(sentence, 16), "%lf", &gNMEAdata.hdop);
    sscanf(field(sentence, 17), "%lf", &gNMEAdata.vdop);
}

/* ----------------------------------------------------------------------- */

void processGPGSV(const char *sentence)
{
    int n, m, f = 4;

    sscanf(field(sentence, 2), "%d", &n);
    update_field_i(sentence, 3, &gNMEAdata.in_view, C_SAT);

    n = (n - 1) * 4;
    m = n + 4;

    while (n < gNMEAdata.in_view && n < m) {
	update_field_i(sentence, f++, &gNMEAdata.PRN[n], C_SAT);
	update_field_i(sentence, f++, &gNMEAdata.elevation[n], C_SAT);
	update_field_i(sentence, f++, &gNMEAdata.azimuth[n], C_SAT);
	if (*(field(sentence, f)))
	    update_field_i(sentence, f, &gNMEAdata.ss[n], C_SAT);
	f++;
	n++;
    }
}

/* ----------------------------------------------------------------------- */

void processPRWIZCH(const char *sentence)
{
    int i;

    for (i = 0; i < 12; i++) {
	update_field_i(sentence, 2 * i + 1, &gNMEAdata.Zs[i], C_ZCH);
	update_field_i(sentence, 2 * i + 2, &gNMEAdata.Zv[i], C_ZCH);
    }
    gNMEAdata.ZCHseen = 1;
}

/* ----------------------------------------------------------------------- */

void processGPGLL(const char *sentence)
{
    do_lat_lon(sentence, 1);

    /* A = valid, V = invalid */
    if (strcmp(field(sentence, 6), "V") == 0)
        gNMEAdata.status = 0;
}

/* ----------------------------------------------------------------------- */

static void do_lat_lon(const char *sentence, int begin)
{
    double lat, lon, d, m;
    char str[20], *p;
    int updated = 0;

    if (*(p = field(sentence, begin + 0)) != '\0') {
	strncpy(str, p, 20);
	sscanf(p, "%lf", &lat);
	m = 100.0 * modf(lat / 100.0, &d);
	lat = d + m / 60.0;
	p = field(sentence, begin + 1);
	if (*p == 'S')
	    lat = -lat;
	if (gNMEAdata.latitude != lat) {
	    gNMEAdata.latitude = lat;
	    gNMEAdata.cmask |= C_LATLON;
	}
        updated++;
    }
    if (*(p = field(sentence, begin + 2)) != '\0') {
	strncpy(str, p, 20);
	sscanf(p, "%lf", &lon);
	m = 100.0 * modf(lon / 100.0, &d);
	lon = d + m / 60.0;

	p = field(sentence, begin + 3);
	if (*p == 'W')
	    lon = -lon;
	if (gNMEAdata.longitude != lon) {
	    gNMEAdata.longitude = lon;
	    gNMEAdata.cmask |= C_LATLON;
	}
        updated++;
    }
    if (updated == 2)
        gNMEAdata.last_update = time(NULL);
}


static void update_field_i(const char *sentence, int fld, int *dest, int mask)
{
    int tmp;

    sscanf(field(sentence, fld), "%d", &tmp);

    if (dest == NULL) return;
    
    if (tmp != *dest)
    {
        *dest = tmp;
        gNMEAdata.cmask |= mask;
    }
}

#if 0
static void update_field_f(const char *sentence, int fld, double *dest, int mask)
{
    double tmp;

    scanf(field(sentence, fld), "%lf", &tmp);

    if (tmp != *dest) {
	*dest = tmp;
	gNMEAdata.cmask |= mask;
    }
}
#endif

/* ----------------------------------------------------------------------- */

int checksum(const char *sentence)
{
    /* static for speed */
    static char s[100], csum[3];
    /* int for speed */
    int i = 1, mesg_len, checksum = 0, csum_orig;

    strncpy (s, sentence, 99);
    s[99] = 0;
    mesg_len = strlen (s) - 3;
    while (('\0' != s[i]) && (i < mesg_len))
        checksum ^= s[i++];
	
    if (s[mesg_len] != '*')
    {
        fprintf(stderr, "checksum error: checksum not preceded with '*'\n");
        return 0;
    }

    strcpy (csum, (s + mesg_len + 1));
    sscanf (csum, "%X", &csum_orig);

    /*
    fprintf(stderr, "\n%s\norigchecksum: %0X, my:%0X\n", s, csum_orig, checksum);
    */

    if (csum_orig == checksum)
    {
        return 1; /* returning checksum could return 0, 1 time out of 2^8 */
    }
    else
    {
        fprintf(stderr, "checksum error: NMEA: \"%s\", read as: %#04X, calculated as: %#04X\n",
                csum, csum_orig, checksum);
        return 0;
    }

    //    unsigned char sum = '\0';
    //    char c, *p = sentence, csum[3];

    //    while ((c = *p++) != '*')
    //	sum ^= c;

    //    sprintf(csum, "%02X", sum);
    //    return (strncmp(csum, p, 2) == 0);
}

/* ----------------------------------------------------------------------- */

/* field() returns a string containing the nth comma delimited
   field from sentence string
 */

static char *field(const char *sentence, short n)
{
    static char result[100];
    
    while (n-- > 0)
	while (*sentence++ != ',');
    strcpy(result, sentence);
    char *r = result;
    while (*r && *r != ',' && *r != '*' && *r != '\r')
	r++;

    *r = '\0';
    return result;
}
