package ua.sda.controller;

import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.ArrayList;
import java.util.List;

/**
 * @author Vasiliy Kylik on(Rocket) on 12.07.2018.
 */
public class MultiThreadRetriveDataController implements RetrieveDataController {
  @Override
  public List<Modem> getAll(String userName, String password, String urlString) {
    List<Modem> modems = new ArrayList<>();
    return modems;
  }
}
