package controllers;

import models.Waypoint;
import play.mvc.Controller;

public class Waypoints extends Controller {

	public static void create(Waypoint waypoint) {
		waypoint.save();
		renderText("ok: " + waypoint.id + " " + waypoint);
	}

}
