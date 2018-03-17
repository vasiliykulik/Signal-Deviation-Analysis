package entity.comparators;

import entity.opticalnodeinterface.Measurement;

import java.util.Comparator;
import java.util.Date;

/**
 * @author Vasiliy Kylik on(Rocket) on 18.03.2018.
 */
public class ComparatorMeasurement implements Comparator<Measurement> {

	@Override
	public int compare(Measurement o1, Measurement o2) {
		return o2.getDateTime().compareTo(o1.getDateTime());
	}
}
