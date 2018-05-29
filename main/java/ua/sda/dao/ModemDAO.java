package ua.sda.dao;

import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.Collection;

/**
 * Created by Vasiliy Kylik (Lightning) on 23.04.2018.
 */
public interface ModemDAO {
    void save(Collection<Modem> t);

    Collection<Modem> read();
}
