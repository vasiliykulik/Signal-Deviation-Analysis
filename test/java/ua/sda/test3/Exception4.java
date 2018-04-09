package ua.sda.test3;

/**
 * Created by Vasiliy Kylik (Lightning) on 09.04.2018.
 */
public class Exception4 {
    public static void main(String[] args) {
        System.out.println("a");
        try{
            System.out.println("b");
        }catch (Exception e){
            System.out.println("c");
        }finally {
            System.out.println("d");
        }
        System.out.println("e");
    }
    // output
    //a
    //b
    //d
    //e
}
