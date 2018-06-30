package ua.sda.test2;

/**
 * Created by Vasiliy Kylik (Lightning) on 09.04.2018.
 */
public class Test {
    public static int i1 = 0;
    private int i2 = 0;
    public Test() {
        i1++;
        i2++;
    }

    public static void main(String[] args) {
        Test t = new Test();
        Test t2 = new Test();
        System.out.println(t.i1);
        System.out.println(t.i2);
    }
}
// Output
// 2
// 1
