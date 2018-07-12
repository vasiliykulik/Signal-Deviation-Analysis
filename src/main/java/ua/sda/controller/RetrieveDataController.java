package ua.sda.controller;

import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.List;

/**
 * @author Vasiliy Kylik on(Rocket) on 13.07.2018.
 */
public interface RetrieveDataController {
  public List<Modem> getAll(String userName, String password, String urlString);
}
