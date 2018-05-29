package ua.sda.analyzer;

import ua.sda.entity.opticalnodeinterface.Measurement;
import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.Collection;
import java.util.stream.IntStream;

/**
 * Created by Vasiliy Kylik (Lightning) on 15.05.2018.
 */
public class SignalCalculateImpl implements SignalCalculate {


    @Override
    public Integer min(Modem modem) {
        for(Measurement measurement:modem.getMeasurements()){
            measurement.
        }
        return null;
    }

    @Override
    public Integer avg(Modem modem) {
        return null;
    }

    @Override
    public Integer max(Modem modem) {
        return null;
    }
}
