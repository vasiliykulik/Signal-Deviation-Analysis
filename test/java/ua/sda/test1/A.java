package ua.sda.test1;

/**
 * Created by Vasiliy Kylik (Lightning) on 04.04.2018.
 */
public class A {
    {
        System.out.println("dynamic a");
    }
    static {
        System.out.println("static a");
    }
    A(){
        System.out.println("A");
    }

    public static void main(String[] args) {
        new B();
    }
}
class B extends A{
    {
        System.out.println("dynamic B");
    }
    static {
        System.out.println("static B");
    }
    B(){
        System.out.println("B");
    }
}
/*
* Сначала static a
* затем создаем new B(); так как наследуется от А, то выполняется и А
* выполняется static B
* затем блок кода класса А dynamic a
* Затем конструктор А А
* затем блок кода dynamic B
* и конструктор В В
* */