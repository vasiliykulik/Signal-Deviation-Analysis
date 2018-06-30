package ua.sda.entity.drafts;

import sun.misc.BASE64Encoder;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * @author Vasiliy Kylik on(Rocket) on 05.04.2018.
 */
public class Reader {
	String urlString; String userName; String password;

	public Reader(String urlString, String userName, String password) {
		this.urlString = urlString;
		this.userName = userName;
		this.password = password;

	}

	public BufferedReader getCon() throws IOException {
		URL url = new URL(urlString);
		HttpURLConnection con = (HttpURLConnection) url.openConnection();

		// set up url connection to get retrieve information back
		con.setRequestMethod("GET");
		con.setDoInput(true);

		// stuff the Authorization request header
		// the password to the encoder, encoder to the connection, StreamReader take InputStream from connection and to the BufferedReader
		byte[] encodedPassword = (userName + ":" + password).getBytes();
		BASE64Encoder encoder = new BASE64Encoder();
		con.setRequestProperty("Authorization",
				"Basic " + encoder.encode(encodedPassword));
		BufferedReader in = new BufferedReader(
				new InputStreamReader(con.getInputStream(), "koi8_r"));
		return in;
	}




}
