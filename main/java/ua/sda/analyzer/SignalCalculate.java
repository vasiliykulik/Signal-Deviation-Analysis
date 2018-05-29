package ua.sda.analyzer;

import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.Collection;
import java.util.Collections;

/**
 * Created by Vasiliy Kylik (Lightning) on 15.05.2018.
 * Create object for return values
 */
public interface SignalCalculate {

    Integer minUpStreamSNR(Modem modem);
    Integer avgUpStreamSNR(Modem modem);
    Integer maxUpStreamSNR(Modem modem);
    Integer minDownStreamSNR(Modem modem);
    Integer avgDownStreamSNR(Modem modem);
    Integer maxDownStreamSNR(Modem modem);
    Integer minUpStreamTXPower(Modem modem);
    Integer avgUpStreamTXPower(Modem modem);
    Integer maxUpStreamTXPower(Modem modem);


}
