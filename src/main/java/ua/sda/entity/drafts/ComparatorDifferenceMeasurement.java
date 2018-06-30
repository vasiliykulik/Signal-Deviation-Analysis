package ua.sda.entity.drafts;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.util.Comparator;

/**
 * Created by Vasiliy Kylik (Lightning) on 13.06.2018.
 */
public class ComparatorDifferenceMeasurement implements Comparator<Measurement> {
    @Override
    public int compare(Measurement o1, Measurement o2) {
        return o1.getDateTime().compareTo(o2.getDateTime());
    }
}
