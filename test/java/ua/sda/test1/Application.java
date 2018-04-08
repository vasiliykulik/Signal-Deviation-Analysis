package ua.sda.test1;

/**
 * Created by Vasiliy Kylik (Lightning) on 04.04.2018.
 */
public class Application {
    public static void main(String[] args) {
        f(1);
    }

    public static void f(int arg) {
        if (arg < 37) {
            f(arg + 10);
        }
        System.out.println(arg);
    }
}
/*
* рекурсия
 * будет вызов метода с новым значением
 * а сейчас выведется переменная на экран
 * и так до того момента пока переменнаяя не выйдет за границы условия и будет выведена на экран
* */