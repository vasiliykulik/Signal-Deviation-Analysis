package ua.sda.test1;

/**
 * Created by Vasiliy Kylik (Lightning) on 04.04.2018.
 */
public class Test {
    public static void changeNumber(int a) {
        a = 3;
    }

    public static void changeA(Aa a) {
        a.i = 3;
    }

    public static void main(String[] args) {
        int i = 7;
        changeNumber(i);
        System.out.println(i);
        Aa a = new Aa();
        changeA(a);
        System.out.println(a.i);
    }
}
/*
* первый метод просто вернет 3
* а выведем мы 7
* создадим 6 но перезаписав выведем 3
* */
