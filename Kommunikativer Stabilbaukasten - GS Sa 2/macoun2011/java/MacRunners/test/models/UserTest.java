package models;

import org.junit.*;

import java.util.*;

import javax.persistence.PersistenceException;

import play.test.*;
import models.*;

public class UserTest extends UnitTest {

    @Before
    public void setup() {
        Fixtures.deleteDatabase();
    }
    
	@Test
	public void testCreateAndRetrieveUser() throws Exception {
		new User("Bob","secret").save();
		User bob = User.find("byUsername", "Bob").first();
		assertNotNull(bob);
		assertEquals("Bob",bob.username);
	}

	@Test(expected=PersistenceException.class)
	public void testCreateUserTwice() throws Exception {
		new User("Bob","secret").save();
		new User("Bob","secret").save();
	}
	
	@Test
	public void testConnect() throws Exception {
		new User("Bob","secret").save();
		User bob = User.connect("Bob","secret");
		assertNotNull(bob);
		assertEquals("Bob",bob.username);
	}

	@Test
	public void testConnectWrongPassword() throws Exception {
		new User("Bob","secret").save();
		User bob = User.connect("Bob","sesdfgsdgcret");
		assertNull(bob);
	}

	@Test
	public void testConnectWrongUsername() throws Exception {
		new User("Bob","secret").save();
		User bob = User.connect("Bobby","secret");
		assertNull(bob);
	}
	
	@Test(expected=IllegalAccessError.class)
	public void testNoPasswordRead() throws Exception {
		User bob = new User("Bob","secret").save();
		String password = bob.passwordHash;
		// should not come here
	}
}
