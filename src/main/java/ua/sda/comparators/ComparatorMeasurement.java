package ua.sda.comparators;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.util.Comparator;

/**
 * @author Vasiliy Kylik on(Rocket) on 18.03.2018.
 * for sorting Measurement in descending order
 */
public class ComparatorMeasurement implements Comparator<Measurement> {

	@Override
	public int compare(Measurement o1, Measurement o2) {
		return o2.getDateTime().compareTo(o1.getDateTime());
	}
}
