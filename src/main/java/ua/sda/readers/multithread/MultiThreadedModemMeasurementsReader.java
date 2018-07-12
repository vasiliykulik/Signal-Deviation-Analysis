package ua.sda.readers.multithread;

import ua.sda.entity.opticalnodeinterface.Measurement;
import ua.sda.readers.MeasurementsReader;

import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 05.07.2018.
 */
public class MultiThreadedModemMeasurementsReader implements MeasurementsReader {


  @Override
  public List<Measurement> getMeasurements(String linkToURL, String userName, String password) throws Exception {

    return null;
  }
}
