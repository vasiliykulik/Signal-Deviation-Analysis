package ua.sda.analyzer;

import java.util.Collection;
import java.util.Collections;

/**
 * Created by Vasiliy Kylik (Lightning) on 15.05.2018.
 */
public interface SignalCalculate {

    Integer minUpStreamSNR(Collection measurements);
    Integer avgUpStreamSNR(Collection measurements);
    Integer maxUpStreamSNR(Collection measurements);
    Integer minDownStreamSNR(Collection measurements);
    Integer avgDownStreamSNR(Collection measurements);
    Integer maxDownStreamSNR(Collection measurements);
    Integer minUpStreamTXPower(Collection measurements);
    Integer avgUpStreamTXPower(Collection measurements);
    Integer maxUpStreamTXPower(Collection measurements);


}
