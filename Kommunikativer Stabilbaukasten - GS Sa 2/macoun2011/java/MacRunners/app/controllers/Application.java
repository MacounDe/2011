package controllers;

import play.*;
import play.mvc.*;

import java.util.*;

import models.*;

public class Application extends Controller {


    @Before
    static void setRenderArgs() {
        if(Security.isConnected()) {
            renderArgs.put("user", Security.connected());
            User user = User.findByUsername(Security.connected());
            if (user != null)
            	renderArgs.put("waypoints", Waypoint.findAll());
        }
    }
    
    public static void index() {
        render();
    }

}