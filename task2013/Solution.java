package com.javarush.task.task20.task2013;

import java.io.*;
import java.util.List;

/* 
Externalizable Person
*/
public class Solution {
    public static class Person implements Externalizable {
        private String firstName;
        private String lastName;
        private int age;
        private Person mother;
        private Person father;
        private List<Person> children;

        public Person() {
        }

        public Person(String firstName, String lastName, int age) {
            this.firstName = firstName;
            this.lastName = lastName;
            this.age = age;
        }

        public void setMother(Person mother) {
            this.mother = mother;
        }

        public void setFather(Person father) {
            this.father = father;
        }

        public void setChildren(List<Person> children) {
            this.children = children;
        }

        public String getFirstName() {
            return firstName;
        }

        public String getLastName() {
            return lastName;
        }

        public int getAge() {
            return age;
        }


        @Override
        public void writeExternal(ObjectOutput out) throws IOException {
            out.writeObject(mother);
            out.writeObject(father);
            out.writeUTF(getFirstName());
            out.writeUTF(getLastName());
            out.writeInt(getAge());
            out.writeObject(children);
        }

        @Override
        public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException {
            setMother((Person) in.readObject());
            setFather((Person) in.readObject());
            firstName = in.readUTF();
            lastName = in.readUTF();
            age = in.readInt();
            setChildren((List<Person>) in.readObject());

        }


    }

    public static void main(String[] args) {
        testWrite();
        testRead();

    }

    public static void testWrite() {
        Person person = new Person("Иван", "Иванов", 33);

        try (FileOutputStream fos = new FileOutputStream("zad13.dat");
        ObjectOutputStream oos = new ObjectOutputStream(fos)) {
            oos.writeObject(person);

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    public static void testRead() {
        try(FileInputStream fis = new FileInputStream("zad13.dat");
            ObjectInputStream ois = new ObjectInputStream(fis)) {

            Person personRes = (Person) ois.readObject();
            System.out.println(personRes.getFirstName());
            System.out.println(personRes.getLastName());
            System.out.println(personRes.getAge());
            System.out.println(personRes.father);
            System.out.println(personRes.mother);
            System.out.println(personRes.children);



        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
}
