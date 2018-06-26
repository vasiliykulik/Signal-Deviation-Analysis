package ua.sda.controllerdao;

import org.hibernate.SessionFactory;
import ua.sda.dao.HibernateDAOImpl;
import ua.sda.entity.opticalnodeinterface.Modem;

import org.hibernate.cfg.Configuration;

import java.util.Collection;
import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 29.05.2018.
 */
public class ModemDAOControllerImpl implements ModemDAOController {
    HibernateDAOImpl hibernateDAO = new HibernateDAOImpl(new Configuration().configure().buildSessionFactory());

    public void save(List<Modem> modems) {
        hibernateDAO.save(modems);
    }

    public Collection<Modem> readDB() {
        return hibernateDAO.readDB();
    }

    public void removeFromDB() {
        hibernateDAO.removeFromDB();

    }
}
