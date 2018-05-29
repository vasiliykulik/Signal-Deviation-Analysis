package ua.sda.dao;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

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
    public void save(List<Modem> modems) {
        try (Session session = sessionFactory.openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                for (int i = 0; i < modems.size() - 1; i++) {
                    session.save(modems.get(i));
                    if (i % 50 == 0) {
                        session.flush();
                        session.clear();
                    }
                }
                tx.commit();
                session.close();
            } catch (Exception e) {
                session.beginTransaction().rollback();
                LOGGER.error("Exception occurred while save Modems, rollback " + e);

            }
        }
    }

    @Override
    public Collection<Modem> readDB() {
        List<Modem> modemList = new ArrayList<>();
        try (Session session = sessionFactory.getCurrentSession()) {
            try {
                modemList = session.createQuery("FROM Modem").list();
            } catch (Exception e) {
                LOGGER.error("Exception occurred while reading modems from DB " + e);
            }
        }
        return modemList;

    }

    @Override
    public void removeFromDB() {
        try (Session session = sessionFactory.getCurrentSession()) {
            try {
                session.beginTransaction();
                session.delete(session.createQuery("DELETE FROM Modem"));
                session.getTransaction().commit();
            } catch (Exception e) {
                session.getTransaction().rollback();
                LOGGER.error("Exception occurred while deleting modems from DB" + " , rollback " + e);
            }
        }
    }
}
