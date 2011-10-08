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
 
 Adaptations from Pascal Bihler, 2008, 2009
 
 *********************************************************************/

#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <fcntl.h>
#include <string.h>
#include <syslog.h>
#include "nmea.h"


struct OUTDATA gNMEAdata;

int debug = 0;



void process_message(const char *sentence)
{
    const char *message = sentence + 1;

    if (checksum(sentence)) {
	if (strncmp(GPGSV, message, 5) == 0) {
	    processGPGSV(message);
	} else if (strncmp(GPGLL, message, 5) == 0) {
		processGPGLL(message);
	} else if (strncmp(GPGGA, message, 5) == 0) {
	    processGPGGA(message);
	} else if (strncmp(GPRMC, message, 5) == 0) {
	    processGPRMC(message);
	} else if (strncmp(GPGSA, message, 5) == 0) {
	    processGPGSA(message);
	} else if (strncmp(PRWIZCH, message, 7) == 0) {
	    processPRWIZCH(message);
	} else {
	    if (debug > 1) {
		fprintf(stderr, "Unknown sentence: \"%s\"\n",
			sentence);
	    }
	}
    }
}


void process_exception(const char *sentence)
{
		fprintf(stderr, "Unknown exception: \"%s\"\n",
		sentence);
}

void handle_message(const char *sentence)
{
    if (debug > 5)
	fprintf(stderr, "%s\n", sentence);
    if (*sentence == '$')
	process_message(sentence);
    else
	process_exception(sentence);

    if (debug > 2) {
	fprintf(stderr,
		"Lat: %f Lon: %f Alt: %f Sat: %d Mod: %d Time: %s\n",
		gNMEAdata.latitude,
		gNMEAdata.longitude,
		gNMEAdata.altitude,
		gNMEAdata.satellites,
		gNMEAdata.mode,
		gNMEAdata.utc);
    }
}
