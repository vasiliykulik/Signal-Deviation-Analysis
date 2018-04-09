package ua.sda.test3;

/**
 * Created by Vasiliy Kylik (Lightning) on 09.04.2018.
 */
public class Exception3 {
    public static void main(String[] args) throws Exception {
        try {
            System.out.println("a");
            throw new NullPointerException();
        } catch (NullPointerException e) {
            System.out.println("b");
            throw new Exception();
        } catch (Exception e) {
            System.out.println("c");
        }
    }
    //Output
    /*Exception in thread "main" java.lang.Exception
            a
    b
    at ua.sda.test3.Exception3.main(Exception3.java:13)
    at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
    at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
    at java.lang.reflect.Method.invoke(Method.java:498)
    at com.intellij.rt.execution.application.AppMain.main(AppMain.java:147)*/
}
