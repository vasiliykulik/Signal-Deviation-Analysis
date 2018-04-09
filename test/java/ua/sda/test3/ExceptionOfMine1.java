package ua.sda.test3;

/**
 * Created by Vasiliy Kylik (Lightning) on 09.04.2018.
 */
public class ExceptionOfMine1 extends Exception {
    public static void main(String[] args) {
        System.out.println("hi!, ");
        try {
            System.out.println("a");
            throw new ExceptionOfMine1();
        } catch (ExceptionOfMine1 e) {
            System.out.println("b");
        } catch (Exception e) {
            System.out.println("c");
        } finally {
            System.out.println("d");
        }
        System.out.println("e");
    }
    /* Output
    * hi!,
a
b
d
e*/
}
