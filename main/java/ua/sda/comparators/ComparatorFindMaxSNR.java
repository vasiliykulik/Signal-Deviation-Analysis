package ua.sda.comparators;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.util.Comparator;

/**
 * Created by Vasiliy Kylik (Lightning) on 25.06.2018.
 */
public class ComparatorFindMaxSNR implements Comparator<Measurement> {
    @Override
    public int compare(Measurement o1, Measurement o2) {
        int result = o1.getUsSNR().compareTo(o2.getUsSNR());
        if (result!=0){
            return result;
        }
        return 0;
    }
}
