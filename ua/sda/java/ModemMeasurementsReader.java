import entity.opticalnodeinterface.Measurement;
import sun.misc.BASE64Encoder;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

/**
 * The {@code ModemMeasurementsReader} class represents a dao
 * to obtain Addresses with Links to modems.
 * <p>
 * This implementation uses a
 * <p>
 * URL and BASE64Encoder to create
 * <p>
 * HttpURLConnection to create
 * <p>
 * InputStreamReader to create
 * <p>
 * BufferedReader to read HTML lines
 *
 * @author Vasiliy Kylik on 13.07.2017.
 */
public class ModemMeasurementsReader {
	/**
	 * Parses HTML page for a Measurements info to build a List of measurements
	 *
	 * @param linkToURL link to single interface of Optical Node(s)
	 * @param userName  username to web interface
	 * @param password  password to web interface
	 * @return {@code measurements }List of measurements for particularly taken modem;
	 * {@code isNewLinkToInfoPage} - parsed only ones, after that value only is assigned
	 */
	public List<Measurement> getMeasurements(String linkToURL, String userName, String password) throws Exception {
		URL url = new URL(linkToURL);
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

		List<Measurement> measurements = new ArrayList<>();

		String inputLine;

		String htmlLineWithTable = null; // line with table
		String[] tableRows = null; //
		boolean isNewTime = false;
		boolean isNewUsTXPower = false;
		boolean isNewUsRXPower = false;
		boolean isNewUsSNR = false;
		boolean isNewDsSNR = false;
		boolean isNewMicroReflex = false;
		boolean isNewLinkToInfoPage = false;

		// Take Html line with table of measurements to read one string table
		// ("align="center"><td>" - first row mark, start of row mark)
		// ("/a></td></tr>" - end of row mark)
		// ("<tr><td colspan="11" align="center">" - end of table mark)
		while ((inputLine = in.readLine()) != null) {
			if (inputLine.matches(".*align=\"center\"><td>.*")) {
				htmlLineWithTable = CleanerForParserMeasurementEntity.htmlLineCleaning(inputLine);
				// System.out.println(table);// test for Html line with table
			}
		}
		// cut HTML one line table into table row blocks and add to collection (List), implemented using array
		if (htmlLineWithTable != null) {
			tableRows = htmlLineWithTable.split("align=\"center\"><td>");
			// (tableRow - 16-03-2018 14:07:44</td><td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/modem/act.measures_history.php?mac=001DD3F6A317&period=5" onclick="initAd()">001D.D3F6.A317</a></td><td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cmts_info/act.cmts_info.php?cmts=sub-20" onclick="initAd()">sub-20</a></td><td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=51020,51030,51010,51000" onclick="initAd()">1001</a></td><td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=5100--,5101--,5102--,5103--,5104--,5105--,5106--,5107--" onclick="initAd()">1</a></td><td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=51030" onclick="initAd()">Us 5/1/0/3/0</a></td><td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=5100--" onclick="initAd()">Ds 5100</a></td><td bgcolor="#8CFF40">47</td><td>7.5</td><td bgcolor="#8CFF40">32.3</td><td bgcolor="#8CFF40">1.6</td><td bgcolor="#8CFF40">37.3</td><td>31</td><td><font ><b>online</font></b></td><td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/modem/act.measures_online.php?mac=001DD3F6A317" >Сейчас</a></td><td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/?ACT=work.cubic&query_mac=001dd3f6a317" >Инфо</a></td></tr><tr bgcolor="#F0F0F0" )
		}


		// TODO while taking each table row, pull required fields ( using Matcher.group 9 positions (two last (2,1) needs to be taken only once, it is links)), creating objects and placing into List

		// TODO check sorting by Date, sort if needed

		return measurements;
	}
}
