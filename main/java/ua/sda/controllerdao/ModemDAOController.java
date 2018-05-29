package ua.sda.controllerdao;

import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.Collection;
import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 27.05.2018.
 */
public interface ModemDAOController {    void save(List<Modem> modems);

    Collection<Modem> readDB();

    void removeFromDB();

}
