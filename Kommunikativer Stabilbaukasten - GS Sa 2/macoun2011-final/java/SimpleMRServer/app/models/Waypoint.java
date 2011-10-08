package models;

import java.util.Date;

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


	public Waypoint(double longitude, double latitude, long timestamp) {
		super();
		this.longitude = longitude;
		this.latitude = latitude;
		this.timestamp = timestamp;
	}
	
	public String toString() {
		return String.format("Waypoint: (%f,%f) at %s",latitude,longitude,""+timestamp);
	}

}
