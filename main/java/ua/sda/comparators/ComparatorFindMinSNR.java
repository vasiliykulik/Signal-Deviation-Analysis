package ua.sda.comparators;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.util.Comparator;

/**
 * Created by Vasiliy Kylik (Lightning) on 25.06.2018.
 * Take modem<p>
 * Sort measurements in ascending order by USSNR and so on
 * find the worst value US SNR (a smaller value )
 * if several equal values, next find the worst value DS SNR (a smaller value)
 * if several equal values next find the worst value MicroReflx
 * next find the worst value US TX POWER (a larger value)
 * next find the worst value (a larger value) of US RX Power
 * <p>
 * <p>
 * may be DS Level, because because we exclude the effect of noise of the interface in the reverse channel for all the modems interface
 *
 * @return {@code a negative integer, zero, or a positive integer as the first argument is less than, equal to, or greater than the second.}
 */

public class ComparatorFindMinSNR implements Comparator<Measurement> {
    @Override
    public int compare(Measurement o1, Measurement o2) {
        // from smaller to larger, for ascending order
        int result = o1.getUsSNR().compareTo(o2.getUsSNR());
        if (result != 0) {
            return result;
        }
        result = o1.getDsSNR().compareTo(o2.getDsSNR());
        if (result != 0) {
            return result;
        }
        result = o1.getMicroReflex().compareTo(o2.getMicroReflex());
        if (result != 0) {
            return result;
        }
        // from larger to smaller, for ascending order
        result = o2.getUsTXPower().compareTo(o1.getUsTXPower());
        if (result != 0) {
            return result;
        }
        // from larger to smaller for ascending order
        return o2.getUsRXPower().compareTo(o1.getUsRXPower());
    }
}
