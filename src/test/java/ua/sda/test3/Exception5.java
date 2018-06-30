package ua.sda.test3;

/**
 * Created by Vasiliy Kylik (Lightning) on 09.04.2018.
 */
public class Exception5 {
    public static int divide(int a, int b) {
        try {
            return a / b;
        } catch (Exception e) {
            return 0;
        } finally {
            return 10;
        }
    }

    public static void main(String[] args) {
        int i = divide(11, 0);
        System.out.println(i);
    }
    //Output
    //10
}
