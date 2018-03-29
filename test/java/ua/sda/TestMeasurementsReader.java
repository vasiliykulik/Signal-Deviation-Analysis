package ua.sda;

import ua.sda.cleaners.CleanerForParserMeasurementEntity;
import ua.sda.comparators.ComparatorMeasurement;
import ua.sda.entity.opticalnodeinterface.Measurement;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author Vasiliy Kylik on(Rocket) on 26.03.2018.
 */
public class TestMeasurementsReader {
	public static void main(String[] args) throws IOException, ParseException {
		FileReader fileReader = new FileReader("D:\\IdeaProjects\\Signal Deviation Analysis\\src\\test\\resources\\testForMeasurementsNull1.html");
		//  InputStreamReader on a FileInputStream.
		BufferedReader br = new BufferedReader(fileReader);

		String inputLine;
		String htmlLineWithTable = null; // line with table
		List<String> tableRows = new ArrayList<>();
		List<Measurement> measurements = new ArrayList<>();

		while ((inputLine = br.readLine()) != null) {
			if (inputLine.matches(".*align=\"center\"><td>.*")) {
				htmlLineWithTable = CleanerForParserMeasurementEntity.htmlLineCleaning(inputLine);
				System.out.println("Look at htmlLineWithTable: ");
				System.out.println(htmlLineWithTable);// test for Html line with table
			}
		}
		if (htmlLineWithTable != null) {
			tableRows.addAll(Arrays.asList(htmlLineWithTable.split("align=\"center\"><td>")));
			//System.out.println(Arrays.asList(htmlLineWithTable.split("align=\"center\"><td>")));// test for Html line with table
			System.out.println("Look at tableRows: ");
			for (String ret : tableRows) {
				System.out.println("Look at each table Row: " + "TableRows size: " + tableRows.size() + " ret value in tableRows position: " + tableRows.indexOf(ret));
				System.out.println(ret);
			}
		}
		System.out.println("-------------------------------------------------------------------------------------------------------");
		boolean isNewLinkToCurrentMeasurement = false;
		boolean isNewLinkToInfoPage = false;
		for (String retval : tableRows) {
			String[] validation0 = retval.split("#");
			if (!isNewLinkToCurrentMeasurement & !isNewLinkToInfoPage) {
				//  check for empty cells in measurements columns

				Measurement measurement = null;
				if (true) {
					measurement = CleanerForParserMeasurementEntity.measurementEntityCleaning(retval);
					// after adding List<Measurements> to Modem entity, it may be a case of not reading measurements- and this field will remain null
					// but the expected behavior is skipping one measurement from the list
					System.out.println("Look at First returned Measurement: ");
					System.out.println(measurement);
					// TODO null measurements
					System.out.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
					System.out.println(measurement.getLinkToCurrentState() + measurement.getLinkToInfoPage() + measurement.getDateTime() + measurement.getDsRxPower() +
							measurement.getDsSNR() + measurement.getMicroReflex() + measurement.getUsRXPower() + measurement.getUsSNR() + measurement.getUsTXPower());
					System.out.println(measurement);

					if (measurement.getDsSNR()!=0.0&
							measurement.getDsRxPower()!=0.0&
							measurement.getMicroReflex()!=0.0&
							measurement.getUsRXPower()!=0.0&measurement.getUsSNR()!=0.0&measurement.getUsTXPower()!=0.0) {
						System.out.println("measurement is not NULL");
						measurements.add(measurement);
					}

					System.out.println("Look at First added Measurement: ");
					System.out.println(measurement);
					isNewLinkToCurrentMeasurement = true;
					isNewLinkToInfoPage = true;
				}
			}
			// case if first measurement not valid - so "measurements.get(0)" cause exception IndexOutOfBoundsException
			// (check isNewLinkToCurrentMeasurement & isNewLinkToInfoPage flags) make sure that we have 0 index (first element in Collection)
			System.out.println("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
			System.out.println("Look at measurements size: " + measurements.size());
			if (measurements.size() > 0) {
				System.out.println("Look at measurement (0): " + measurements.get(0));
			}
			if (isNewLinkToCurrentMeasurement & isNewLinkToInfoPage & measurements.size() > 0) {
				//  check for empty cells in measurements columns (color marker when cells are not empty)
				if (validation0.length == 13) {
					if (measurements.get(0).getLinkToCurrentState() != null & measurements.get(0).getLinkToInfoPage() != null) {
						Measurement measurement = CleanerForParserMeasurementEntity.
								measurementEntityCleaningWithLinks(retval, measurements.get(0).getLinkToCurrentState(), measurements.get(0).getLinkToInfoPage());
						System.out.println("Look at Next returned Measurement: ");
						System.out.println(measurement);
						measurements.add(measurement);
						System.out.println("Look at Next added Measurement: ");
						System.out.println(measurement);

					}
				}
			}
		}

		// check sorting by Date, sort if needed
		measurements.sort(new ComparatorMeasurement());
	}

}
