package models;

import java.util.Date;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.ManyToOne;

import play.data.validation.Required;
import play.data.binding.As;
import play.db.jpa.Model;

@Entity
public class Waypoint extends Model {
	
	@Required
	public double longitude;

	@Required
	public double latitude;

	@Required
	public long timestamp;

	@Required
    @ManyToOne
    public User user;

	public Waypoint(double longitude, double latitude, long timestamp) {
		super();
		this.longitude = longitude;
		this.latitude = latitude;
		this.timestamp = timestamp;
	}
	
	public static List<Waypoint> findByUser(User user) {
		return Waypoint.find("byUser",user).fetch();
	}

}
