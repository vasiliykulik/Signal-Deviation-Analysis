package ua.sda;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author Vasiliy Kylik on(Rocket) on 26.03.2018.
 */
/*Проверяем Cleaner для одного Measurement,  подаем одну строку измерений, подаем через String*/

public class TestMeasurementsCleaner {
	public static void main(String[] args) throws ParseException {

		// null measurements
		String s0 = "23-03-2018 08:08:51</td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_history.php?mac=ACB3131C4923&period=5\" onclick=\"initAd()\">ACB3.131C.4923</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cmts_info/act.cmts_info.php?cmts=sub-20\" onclick=\"initAd()\">sub-20</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=51020,51030,51010,51000\" onclick=\"initAd()\">1001</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=5100--,5101--,5102--,5103--,5104--,5105--,5106--,5107--\" onclick=\"initAd()\">1</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=51030\" onclick=\"initAd()\">Us 5/1/0/3/0</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=5100--\" onclick=\"initAd()\">Ds 5100</a></td><td bgcolor=\"#FF7C7C\">53</td><td>5</td><td bgcolor=\"#8CFF40\">29.7</td><td bgcolor=\"#8CFF40\">3.6</td><td bgcolor=\"\"></td><td>31</td><td><font ><b>online</font></b></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_online.php?mac=ACB3131C4923\" >Сейчас</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/?ACT=work.cubic&query_mac=acb3131c4923\" >Инфо</a></td></tr>";
		// fine String
		String s1 = "26-03-2018 23:09:15</td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_history.php?mac=CCA46275B5C7&period=5\" onclick=\"initAd()\">CCA4.6275.B5C7</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cmts_info/act.cmts_info.php?cmts=sub-20\" onclick=\"initAd()\">sub-20</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=51020,51030,51010,51000\" onclick=\"initAd()\">1001</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=5100--,5101--,5102--,5103--,5104--,5105--,5106--,5107--\" onclick=\"initAd()\">1</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=51030\" onclick=\"initAd()\">Us 5/1/0/3/0</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=5100--\" onclick=\"initAd()\">Ds 5100</a></td><td bgcolor=\"#8CFF40\">46</td><td>6.5</td><td bgcolor=\"#8CFF40\">30.3</td><td bgcolor=\"#8CFF40\">6.4</td><td bgcolor=\"#8CFF40\">36.3</td><td>31</td><td><font ><b>online</font></b></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_online.php?mac=CCA46275B5C7\" >Сейчас</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/?ACT=work.cubic&query_mac=cca46275b5c7\" >Инфо</a></td></tr>";
		String s2 = "26-03-2018 17:09:16</td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_history.php?mac=001DD0C0A8CF&period=5\" onclick=\"initAd()\">001D.D0C0.A8CF</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cmts_info/act.cmts_info.php?cmts=sub-20\" onclick=\"initAd()\">sub-20</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=51020,51030,51010,51000\" onclick=\"initAd()\">1001</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=5100--,5101--,5102--,5103--,5104--,5105--,5106--,5107--\" onclick=\"initAd()\">1</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=51030\" onclick=\"initAd()\">Us 5/1/0/3/0</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=5100--\" onclick=\"initAd()\">Ds 5100</a></td><td bgcolor=\"#8CFF40\">43.6</td><td>5</td><td bgcolor=\"#8CFF40\">30.8</td><td bgcolor=\"#8CFF40\">9.3</td><td bgcolor=\"\"></td><td>34</td><td><font ><b>online</font></b></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_online.php?mac=001DD0C0A8CF\" >Сейчас</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/?ACT=work.cubic&query_mac=001dd0c0a8cf\" >Инфо</a></td></tr>";
		String s3 = "27-03-2018 00:08:50</td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_history.php?mac=ACB3131C4923&period=5\" onclick=\"initAd()\">ACB3.131C.4923</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cmts_info/act.cmts_info.php?cmts=sub-20\" onclick=\"initAd()\">sub-20</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=51020,51030,51010,51000\" onclick=\"initAd()\">1001</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=5100--,5101--,5102--,5103--,5104--,5105--,5106--,5107--\" onclick=\"initAd()\">1</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=51030\" onclick=\"initAd()\">Us 5/1/0/3/0</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=5100--\" onclick=\"initAd()\">Ds 5100</a></td><td bgcolor=\"#8CFF40\">45</td><td>6.5</td><td bgcolor=\"#8CFF40\">30.8</td><td bgcolor=\"#8CFF40\">9.7</td><td bgcolor=\"#8CFF40\">38.9</td><td>33</td><td><font ><b>online</font></b></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_online.php?mac=ACB3131C4923\" >Сейчас</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/?ACT=work.cubic&query_mac=acb3131c4923\" >Инфо</a></td></tr>";
		String ok = "23-03-2018 00:04:00</td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_history.php?mac=CCA462762D15&period=5\" onclick=\"initAd()\">CCA4.6276.2D15</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cmts_info/act.cmts_info.php?cmts=sub-1\" onclick=\"initAd()\">sub-1</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-1&ifaces=51020,51000,51010,51030\" onclick=\"initAd()\">1001</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-1&ifaces=5100--,5101--,5102--,5103--,5104--,5105--,5106--,5107--\" onclick=\"initAd()\">1</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-1&iface=51030\" onclick=\"initAd()\">Us 5/1/0/3/0</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-1&iface=5100--\" onclick=\"initAd()\">Ds 5100</a></td><td bgcolor=\"#FFFF53\">52.8</td><td>4</td><td bgcolor=\"#8CFF40\">28.5</td><td bgcolor=\"#8CFF40\">-.8</td><td bgcolor=\"#8CFF40\">38.2</td><td>26</td><td><font ><b>online</font></b></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_online.php?mac=CCA462762D15\" >Сейчас</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/?ACT=work.cubic&query_mac=cca462762d15\" >Инфо</a></td></tr>    ";
		String bad = "27-03-2018 07:04:20</td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_history.php?mac=E83EFC5DB779&period=5\" onclick=\"initAd()\">E83E.FC5D.B779</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cmts_info/act.cmts_info.php?cmts=sub-1\" onclick=\"initAd()\">sub-1</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-1&ifaces=51020,51000,51010,51030\" onclick=\"initAd()\">1001</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-1&ifaces=5100--,5101--,5102--,5103--,5104--,5105--,5106--,5107--\" onclick=\"initAd()\">1</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-1&iface=51030\" onclick=\"initAd()\">Us 5/1/0/3/0</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-1&iface=5100--\" onclick=\"initAd()\">Ds 5100</a></td><td bgcolor=\"#8CFF40\">45.5</td><td>5</td><td bgcolor=\"#8CFF40\">32.3</td><td bgcolor=\"#8CFF40\">6.7</td><td bgcolor=\"\"></td><td>27</td><td><font ><b>online</font></b></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_online.php?mac=E83EFC5DB779\" >Сейчас</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/?ACT=work.cubic&query_mac=e83efc5db779\" >Инфо</a></td></tr><tr bgcolor=\"#D8D8D8\" ";
		/*null measurement*/
String currentTesting = "11-10-2018 11:05:19</td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/modem/act.measures_history.php?mac=943BB1D30331&period=5\" onclick=\"initAd()\">943B.B1D3.0331</a></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/cmts_info/act.cmts_info.php?cmts=sub-9\" onclick=\"initAd()\">sub-9</a></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-9&ifaces=71000,71010,71020,71030\" onclick=\"initAd()\">1041</a></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-9&ifaces=7100--,7101--,7102--,7103--,7104--,7105--,7106--,7107--\" onclick=\"initAd()\">21</a></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/cable_info/act.iface_info.php?cmts=sub-9&iface=71030\" onclick=\"initAd()\">Us 7/1/0/3/0</a></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/cable_info/act.iface_info.php?cmts=sub-9&iface=7100--\" onclick=\"initAd()\">Ds 7100</a></td><td bgcolor=\"#FF7C7C\">56.2</td><td>10</td><td bgcolor=\"#FF7C7C\">0</td><td bgcolor=\"#8CFF40\">5.4</td><td bgcolor=\"#8CFF40\">43</td><td>24</td><td><font ><b>online</font></b></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/modem/act.measures_online.php?mac=943BB1D30331\" >������</a></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/?ACT=work.cubic&query_mac=943bb1d30331\" >����</a></td></tr><tr bgcolor=\"#F0F0F0\" ";
/*String currentTesting = "14-09-2018 01:08:42</td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/modem/act.measures_history.php?mac=CCA46275AAC7&period=5\" onclick=\"initAd()\">CCA4.6275.AAC7</a></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/cmts_info/act.cmts_info.php?cmts=sub-7\" onclick=\"initAd()\">sub-7</a></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-7&ifaces=402,403,400,401\" onclick=\"initAd()\">1001</a></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-7&ifaces=000--,001--,002--,003--,004--,005--,006--,007--\" onclick=\"initAd()\">1</a></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/cable_info/act.iface_info.php?cmts=sub-7&iface=403\" onclick=\"initAd()\">Us 4/0.3/0</a></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/cable_info/act.iface_info.php?cmts=sub-7&iface=000--\" onclick=\"initAd()\">Ds 000</a></td><td bgcolor=\"#8CFF40\">46.8</td><td>6</td><td bgcolor=\"#8CFF40\">28.8</td><td bgcolor=\"#8CFF40\">4.8</td><td bgcolor=\"#8CFF40\">38.2</td><td>34</td><td><font ><b>online</font></b></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/work/modem/act.measures_online.php?mac=CCA46275AAC7\" >Сейчас</a></td><td bgcolor=\"#D8D8D8\"><a href=\"https://work.volia.com/w2/?ACT=work.cubic&query_mac=cca46275aac7\" >Инфо</a></td></tr>";*/
String currentTesting20180914 = "23-03-2018 06:07:44</td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_history.php?mac=ACB3131C4923&period=5\" onclick=\"initAd()\">ACB3.131C.4923</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cmts_info/act.cmts_info.php?cmts=sub-20\" onclick=\"initAd()\">sub-20</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=51020,51030,51010,51000\" onclick=\"initAd()\">1001</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=5100--,5101--,5102--,5103--,5104--,5105--,5106--,5107--\" onclick=\"initAd()\">1</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=51030\" onclick=\"initAd()\">Us 5/1/0/3/0</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=5100--\" onclick=\"initAd()\">Ds 5100</a></td><td bgcolor=\"#FF7C7C\">53</td><td>5</td><td bgcolor=\"#8CFF40\">29.2</td><td bgcolor=\"#8CFF40\">3.8</td><td bgcolor=\"#8CFF40\">38.2</td><td>31</td><td><font ><b>online</font></b></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/work/modem/act.measures_online.php?mac=ACB3131C4923\" >������</a></td><td bgcolor=\"#D8D8D8\"><a href=\"http://work.volia.net/w2/?ACT=work.cubic&query_mac=acb3131c4923\" >����</a></td></tr><tr bgcolor=\"#F0F0F0\" ";

		// Count td, tr tegs
		String[] validation0 = s0.split("#");
		String[] validation1 = s1.split("#");
		String[] validation2 = s2.split("#");
		String[] validation3 = s3.split("#");
		System.out.println("validation0 # split result count " + validation0.length);
		System.out.println("validation1 # split result count " + validation1.length);
		System.out.println("validation2 # split result count " + validation2.length);
		System.out.println("validation3 # split result count " + validation3.length);


		Pattern p1 = Pattern.compile("(\\d\\d-\\d\\d-\\d\\d\\d\\d\\s\\d\\d:\\d\\d:\\d\\d)</td>.*");// " >Инфо</a></td></tr><tr bgcolor="#......" wildcard instead this statement because last row have no end marker as previous rows
		Matcher m1 = p1.matcher(currentTesting);
		if (m1.find()) {
			Date dateTime = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m1.group(1));
			System.out.println("1 group" + " " + dateTime);
		}


		Pattern p2 = Pattern.compile("(\\d\\d-\\d\\d-\\d\\d\\d\\d\\s\\d\\d:\\d\\d:\\d\\d)</td>.*" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>");// " >Инфо</a></td></tr><tr bgcolor="#......" wildcard instead this statement because last row have no end marker as previous rows
		Matcher m2 = p2.matcher(currentTesting);
		if (m2.find()) {
			Date dateTime = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m2.group(1));
			Float usTXPower = Float.valueOf(m2.group(2));
			System.out.println("2 group" + " " + dateTime.toString() + " " + usTXPower.toString());
		}


		Pattern p5 = Pattern.compile("" +
				"(\\d\\d-\\d\\d-\\d\\d\\d\\d\\s\\d\\d:\\d\\d:\\d\\d)</td>.*" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td>([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>");
		Matcher m5 = p5.matcher(currentTesting);
		if (m5.find()) {
			Date dateTime = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m5.group(1));
			Float usTXPower = Float.valueOf(m5.group(2));
			Float usRXPower = Float.valueOf(m5.group(3));
			Float usSNR = Float.valueOf(m5.group(4));
			Float dsRxPower = Float.valueOf(m5.group(5));
			System.out.println("5 group" + " " + dateTime.toString() + " " + usTXPower.toString() + " " + usRXPower + " " + usSNR + " " + dsRxPower);
		}


		Pattern p6 = Pattern.compile("" +
				"(\\d\\d-\\d\\d-\\d\\d\\d\\d\\s\\d\\d:\\d\\d:\\d\\d)</td>.*" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td>([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>");
		Matcher m6 = p6.matcher(currentTesting);
		if (m6.find()) {
			Date dateTime = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m6.group(1));
			Float usTXPower = Float.valueOf(m6.group(2));
			Float usRXPower = Float.valueOf(m6.group(3));
			Float usSNR = Float.valueOf(m6.group(4));
			Float dsRxPower = Float.valueOf(m6.group(5));
			Float dsSNR = Float.valueOf(m6.group(6));
			System.out.println("6 group" + " " + dateTime.toString() + " " + usTXPower.toString() + " " + usRXPower + " " + usSNR + " " + dsRxPower + " " + dsSNR);
		}


		Pattern p7 = Pattern.compile("" +
				"(\\d\\d-\\d\\d-\\d\\d\\d\\d\\s\\d\\d:\\d\\d:\\d\\d)</td>.*" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td>([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td>([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td><font ><b>.*</font></b></td>");
		Matcher m7 = p7.matcher(currentTesting);
		if (m7.find()) {
			Date dateTime = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m7.group(1));
			Float usTXPower = Float.valueOf(m7.group(2));
			Float usRXPower = Float.valueOf(m7.group(3));
			Float usSNR = Float.valueOf(m7.group(4));
			Float dsRxPower = Float.valueOf(m7.group(5));
			Float dsSNR = Float.valueOf(m7.group(6));
			Float microReflex = Float.valueOf(m7.group(7));
			System.out.println("7 group" + " " + dateTime.toString() + " " + usTXPower.toString() + " " + usRXPower + " " + usSNR + " " + dsRxPower + " " + dsSNR + " " + microReflex);
		}

		Pattern p8 = Pattern.compile("" +
				"(\\d\\d-\\d\\d-\\d\\d\\d\\d\\s\\d\\d:\\d\\d:\\d\\d)</td>.*" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td>([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td>([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td><font ><b>.*</font></b></td>" +
				"<td bgcolor=\"#......\"><a href=\\\"(https:\\/\\/work.volia.com\\/w2\\/work\\/modem\\/act.measures_online.php\\?mac=............)\" >.*</a></td>");
		Matcher m8 = p8.matcher(currentTesting);
		if (m8.find()) {
			Date dateTime = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m8.group(1));
			Float usTXPower = Float.valueOf(m8.group(2));
			Float usRXPower = Float.valueOf(m8.group(3));
			Float usSNR = Float.valueOf(m8.group(4));
			Float dsRxPower = Float.valueOf(m8.group(5));
			Float dsSNR = Float.valueOf(m8.group(6));
			Float microReflex = Float.valueOf(m8.group(7));
			String linkToCurrentMeasurement = m8.group(8);
			System.out.println("8 group" + " " + dateTime.toString() + " " + usTXPower.toString() + " " + usRXPower + " " + usSNR + " " + dsRxPower + " " + dsSNR + " " + microReflex + " " + linkToCurrentMeasurement);
		}

		Pattern p9 = Pattern.compile("" +
				"(\\d\\d-\\d\\d-\\d\\d\\d\\d\\s\\d\\d:\\d\\d:\\d\\d)</td>.*" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td>([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td>([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
				"<td><font ><b>.*</font></b></td>" +
				"<td bgcolor=\"#......\"><a href=\\\"(https:\\/\\/work.volia.com\\/w2\\/work\\/modem\\/act.measures_online.php\\?mac=............)\" >.*</a></td>" +
				"<td bgcolor=\"#......\"><a href=\\\"(https:\\/\\/work.volia.com\\/w2\\/\\?ACT=work.cubic&query_mac=............).*");// " >Инфо</a></td></tr><tr bgcolor="#......" wildcard instead this statement because last row have no end marker as previous rows
		Matcher m9 = p9.matcher(currentTesting);
		if (m9.find()) {
			Date dateTime = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m9.group(1));
			Float usTXPower = Float.valueOf(m9.group(2));
			Float usRXPower = Float.valueOf(m9.group(3));
			Float usSNR = Float.valueOf(m9.group(4));
			Float dsRxPower = Float.valueOf(m9.group(5));
			Float dsSNR = Float.valueOf(m9.group(6));
			Float microReflex = Float.valueOf(m9.group(7));
			String linkToCurrentMeasurement = m9.group(8);
			String linkToInfoPage = m9.group(9);
			System.out.println("9 group" + " " + dateTime.toString() + " " + usTXPower.toString() + " " + usRXPower + " " + usSNR + " " + dsRxPower + " " + dsSNR + " " + microReflex + " " + linkToCurrentMeasurement + " " + linkToInfoPage);
		}
	}
}
