package controllers;


import helpers.AES;
import helpers.RSA;

import java.util.UUID;

import javax.persistence.PersistenceException;

import models.User;
import play.data.validation.Required;
import play.libs.Codec;
import play.mvc.Router;

public class Security extends controllers.Secure.Security {
	
	static boolean authenticate(String username, String password) {
	    return User.connect(username, Codec.hexSHA1(password)) != null;
	}
	static void onDisconnected() {
	    Application.index();
	}
	static void onAuthenticated() {
	    Application.index();
	}
	
	public static void register(@Required String username, @Required String password) {
		response.contentType = "text/javascript";
		try {
			new User(username,Codec.hexSHA1(password)).save();
	        session.put("username", username);
			renderText("top.location.href='" + Router.reverse("Application.index").url +"'"); // redirect to index page via ajax reload
		} catch(PersistenceException e) { // Username already exists
			renderText("$('#name').addClass( 'ui-state-error' );updateTips('Benutzerkonto besteht bereits.')");
		}
	}

	public static void login(@Required String username, @Required String password) {
		response.contentType = "text/javascript";
		
		if (authenticate(username, password)) {

	        // Mark user as connected
	        session.put("username", username);
			renderText("top.location.href='" + Router.reverse("Application.index").url +"'"); // redirect to index page via ajax reload
	        
		} else { // Username already exists
			renderText("$('#name').addClass( 'ui-state-error' );updateTips('Benutzername oder Kennwort unbekannt.')");
		}
	}
	
	public static void connect(String key, String username, String passwordHash) {

		byte[] aesKey = RSA.sharedInstance().decryptWithPrivateKey(key);
		
		username = AES.decrypt(username, aesKey);
		User user = User.connect(username, passwordHash);
		if (user == null) {
			unauthorized();
		}
		
		String token = UUID.randomUUID().toString();
		user.aesKey = aesKey;
		user.token = token;
		user.save();
		
		renderText(AES.encrypt(token, aesKey));
	}

	
}

