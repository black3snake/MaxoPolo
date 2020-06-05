package com.javarush.task.task20.task2016;

import java.io.*;

/*
Минимум изменений
как всегда я дописал все действия для серилизации в main
*/
public class Solution {
    public static class A implements Serializable {
        String name = "A";
        private static final long serialVersionUID = 1L;

        public A(String name) {
            this.name += name;
        }

        @Override
        public String toString() {
            return name;
        }
    }

    public static class B extends A {
        String name = "B";

        public B(String name) {
            super(name);
            this.name += name;
        }
    }

    public static class C extends B {
        String name = "C";

        public C(String name) {
            super(name);
            this.name += name;
        }
    }

    public static void main(String[] args) {
            C c = new C("ОПА");
            B b = new C("ОПА");
            A a = new C("ОПА");
        System.out.println("------------Сжимаю ----------");
        System.out.println(a.name);
        System.out.println(b.name);
        System.out.println(c.name);

        try (FileOutputStream fos = new FileOutputStream("zad16.dat");
             ObjectOutputStream oos = new ObjectOutputStream(fos))   {
            oos.writeObject(a);
            oos.writeObject(b);
            oos.writeObject(c);
            oos.flush();
        }catch (IOException e) {
            e.printStackTrace();
        }
        try(FileInputStream fis = new FileInputStream("zad16.dat");
            ObjectInputStream ois = new ObjectInputStream(fis)) {
            A aR = (A) ois.readObject();
            B bR = (B) ois.readObject();
            C cR = (C) ois.readObject();
            System.out.println("---------------- Надутый ----------------");
            System.out.println(aR.name);
            System.out.println(bR.name);
            System.out.println(cR.name);

        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }


    }
}
