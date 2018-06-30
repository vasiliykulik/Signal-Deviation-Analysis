package ua.sda.db;
import java.sql.*;

/**
 * Created by Vasiliy Kylik (Lightning) on 06.05.2018.
 */
public class TestH2 {

        public static void main(String[] a)
                throws Exception {
            Connection conn = DriverManager.
                    getConnection("jdbc:h2:~/test", "sa", "");
            // add application code here
            conn.close();
        }

}
