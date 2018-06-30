package ua.sda.comparators;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.util.Comparator;

/**
 * Created by Vasiliy Kylik (Lightning) on 25.06.2018.
 * <p>
 * Take modem<p>
 * Sort measurements in descending order by USSNR and so on
 * find the best value US SNR (a larger value)
 * if several equal values, next find the best value DS SNR (a larger value)
 * next find the best value MicroReflx
 * next find the best value US TX POWER (a smaller value)
 * next find the best value(a smaller value) of US RX Power
 *
 * @return {@code int a negative integer, zero, or a positive integer as the first argument is less than, equal to, or greater than the second.}
 */


public class ComparatorFindMaxSNR implements Comparator<Measurement> {
    @Override
    public int compare(Measurement o1, Measurement o2) {
        // from larger to smaller, for descending order
        int result = o2.getUsSNR().compareTo(o1.getUsSNR());
        if (result != 0) {
            return result;
        }
        result = o2.getDsSNR().compareTo(o1.getDsSNR());
        if (result != 0) {
            return result;
        }
        result = o2.getMicroReflex().compareTo(o1.getMicroReflex());
        if (result != 0) {
            return result;
        }
        // from smaller to larger, for descending order
        result = o1.getUsTXPower().compareTo(o2.getUsTXPower());
        if (result != 0) {
            return result;
        }
        return o1.getUsRXPower().compareTo(o2.getUsRXPower());
    }
}
