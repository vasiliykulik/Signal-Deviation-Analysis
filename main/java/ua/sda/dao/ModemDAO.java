package ua.sda.dao;

import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.Collection;
import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 23.04.2018.
 */
public interface ModemDAO {

    void save(List<Modem> modems);

    Collection<Modem> readDB();

    void removeFromDB();
}
