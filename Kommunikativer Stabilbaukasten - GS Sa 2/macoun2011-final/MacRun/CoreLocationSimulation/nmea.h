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

#include <time.h>

#define GPGGA "GPGGA"
#define GPGLL "GPGLL"
#define GPGSA "GPGSA"
#define GPGSV "GPGSV"
#define GPRMC "GPRMC"
#define PRWIZCH "PRWIZCH"

struct OUTDATA {
    int fdin;
    int fdout;

    time_t last_update;		/* When we got last data from GPS receiver */

    long cmask;
    char utc[20];		/* UTC date / time in format "mm/dd/yy hh:mm:ss" */

    double latitude;		/* Latitude and longitude in format "d.ddddd" */

    double longitude;

    double altitude;		/* Altitude in meters */

    double speed;		/* Speed over ground, knots */

    double track;		/* Track made good, degress True */

    int satellites;		/* Number of satellites used in solution */

    int status;			/* 0 = no fix, 1 = fix, 2 = dgps fix */

    int mode;			/* 1 = no fix, 2 = 2D, 3 = 3D */

    double pdop;		/* Position dilution of precision */

    double hdop;		/* Horizontal dilution of precision */

    double vdop;		/* Vertical dilution of precision */

    int in_view;		/* # of satellites in view */

    int PRN[12];		/* PRN of satellite */

    int elevation[12];		/* elevation of satellite */

    int azimuth[12];		/* azimuth */

    int ss[12];			/* signal strength */

    int used[12];		/* used in solution */

    int ZCHseen;		/* flag */

    int Zs[12];			/* for the rockwell PRWIZCH */

    int Zv[12];			/*                  value */

    int year;

    int month;

    int day;

    int hours;

    int minutes;

    int seconds;

    double separation;

    double mag_var;

    double course;

    int seen[12];

    int valid[12];		/* signal valid */
};

#define C_LATLON	1
#define C_SAT		2
#define C_ZCH		4

/* prototypes */
extern void doNMEA(short refNum);
extern void processGPRMC(const char *sentence);
extern void processGPGGA(const char *sentence);
extern void processGPGSV(const char *sentence);
extern void processPRWIZCH(const char *sentence);
extern void processGPGSA(const char *sentence);
extern void processGPGLL(const char *sentence);
extern int checksum(const char *sentence);
extern struct OUTDATA gNMEAdata;
