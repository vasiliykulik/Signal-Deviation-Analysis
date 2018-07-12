package ua.sda.readers;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.util.List;

/**
 * @author Vasiliy Kylik on(Rocket) on 12.07.2018.
 */
public interface MeasurementsReader {
  List<Measurement> getMeasurements(String linkToURL, String userName, String password) throws Exception;
}
