package com.javarush.task.task20.task2017;

import java.io.*;

/* 
Десериализация
пойман был глюк что в IDEA не смогла защитать мне решение (было потрачена часа 2 на это понимаение)
решилось вставкой кода на сайте
*/
public class Solution {
    public A getOriginalObject(ObjectInputStream objectStream) {

        try {
            Object ob = objectStream.readObject();
        //    if(ob instanceof B) {                        // Это для вычленения класса B
        //        throw new ClassNotFoundException();
        //    }
            if (ob instanceof A) {
                return (A) ob;
            } else {
                throw new ClassNotFoundException();
            }

        } catch (ClassNotFoundException e) {
            System.out.println("Other class");
            return null;
        } catch (Exception e) {
            System.out.println("Other errors");
            return null;
        }
    }

    public static class A implements Serializable {
    }

    public static class B extends A {
        public B() {
            System.out.println("inside B");
        }
    }

    public static void main(String[] args) {
        Solution solution = new Solution();
        A a = new A();
        B b = new B();
        try (FileOutputStream fos = new FileOutputStream("zad17.dat");
            ObjectOutputStream oos = new ObjectOutputStream(fos)){
            //oos.writeObject(a);
            oos.writeObject(b);

        } catch (IOException e) {
            e.printStackTrace();
        }


        try (FileInputStream fis = new FileInputStream("zad17.dat");
            ObjectInputStream ois = new ObjectInputStream(fis)){

            //solution.getOriginalObject(ois);
            System.out.println(solution.getOriginalObject(ois));
        }catch (IOException e) {
            System.out.println("Последний IO");

        }

    }
}
