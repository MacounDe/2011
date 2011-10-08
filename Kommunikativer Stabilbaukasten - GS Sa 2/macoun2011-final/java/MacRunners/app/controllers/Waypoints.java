package controllers;

import models.User;
import models.Waypoint;
import play.mvc.Controller;

public class Waypoints extends Controller {
	
	public static void create(String token, Waypoint waypoint) {	
		User user = User.findByToken(token);
		if (user == null)
			forbidden();
		
		waypoint.user = user;
		waypoint.save();
		renderText("ok: " + waypoint.id + " " + waypoint);
	}

}
