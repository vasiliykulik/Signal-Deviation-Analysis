package ua.sda.dao;

/**
 * Created by Vasiliy Kylik (Lightning) on 23.04.2018.
 */
public interface GenericDAO<T> {
    void save(T entity);
    void read(T entity);
}
