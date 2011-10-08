package models;

import play.*;
import play.data.validation.*;
import play.db.jpa.*;
import play.libs.Codec;
import play.libs.Crypto;

import javax.persistence.*;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.*;

@Entity
public class User extends Model {

	@Required
	@Column(unique=true, nullable=false)
	public String username;
	
	@Required
	@Password
	@Column(nullable=false)
	public String passwordHash;
	
	public String token;
	public byte[] aesKey;

	public User(String username, String passwordHash) {
		super();
		this.username = username;
		this.setPasswordHash(passwordHash);
	}
	
	public String getPasswordHash() {
		throw new IllegalAccessError("Cannot read password hash");
	}
	
	public void setPasswordHash(String passwordHash) {
		this.passwordHash = Codec.hexSHA1(passwordHash);
	}

	public static User connect(String username, String passwordHash) {
	    return find("byUsernameAndPasswordHash", username, Codec.hexSHA1(passwordHash)).first();
	}


	public static User findByUsername(String username) {
		return find("byUsername",username).first();
	}
	
	public static User findByToken(String token) {
		return find("byToken",token).first();
	}
}
