package ua.sda.testCollectionForeach;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 18.06.2018.
 */
public class TestForEach {

    public static void main(String[] args) {
        List<A> a = new ArrayList<>();
        a.add(new A(1));
        a.add(new A(2));
        a.add(new A(3));
        System.out.println("try to print a");
        a.forEach(System.out::println);
        List <B> b = new ArrayList<>();
        b.forEach(a::add);
        System.out.println("try to print b");
        b.forEach(System.out::println);
        /*try to print a
A{a=1}
A{a=2}
A{a=3}
try to print b*/
    }

    static class A{
        int a;

        public A() {
        }

        public A(int a) {
            this.a = a;
        }

        public int getA() {
            return a;
        }

        public void setA(int a) {
            this.a = a;
        }

        @Override
        public String toString() {
            return "A{" +
                    "a=" + a +
                    '}';
        }
    }

   static class B extends A{
        int b;

        public B(){

        }

        public B(int b) {
            this.b = b;
        }

        public B(int a, int b) {
            super(a);
            this.b = b;
        }

        public int getB() {
            return b;
        }

        public void setB(int b) {
            this.b = b;
        }

        @Override
        public String toString() {
            return "B{" +
                    "b=" + b +
                    '}';
        }
    }
}
