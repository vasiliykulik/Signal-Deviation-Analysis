package ua.sda.dao;

import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.Collection;

/**
 * Created by Vasiliy Kylik (Lightning) on 27.05.2018.
 */
public class HibernateDAOImpl implements ModemDAO {

    private static final Logger LOGGER = LoggerFactory.getLogger(HibernateDAOImpl.class);
    private SessionFactory sessionFactory;

    public HibernateDAOImpl(SessionFactory sessionFactory) {
        this.sessionFactory = sessionFactory;
    }

    @Override
    public void save(Collection<Modem> t) {

    }

    @Override
    public Collection<Modem> read() {
        return null;
    }
}
