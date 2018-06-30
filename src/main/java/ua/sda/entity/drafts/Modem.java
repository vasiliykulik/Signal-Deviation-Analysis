package ua.sda.entity.drafts;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.util.List;

/**
 * Created by Vasiliy Kylik on 13.07.2017.
 */
public class Modem {
  private String linkToMACAddress;
  private String MACAddress;
  private List<Measurement> measurements;
  private Location location;
}
